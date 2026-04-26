
# Critical User Flows

This document describes the key user flows and system interactions in the AI Command Center platform.

## Authentication Flow

When a user logs into the application, the following sequence occurs:

1. User enters credentials on the **LoginPage**, which calls `signInWithPassword` to authenticate with Supabase Auth.
2. Upon successful authentication, the **authSlice** in Zustand is updated with the current user information.
3. The JWT token contains embedded `org_id` and `user_role` claims for authorization.
4. The `onAuthStateChange` listener triggers query invalidation and realtime reconnect, then redirects the user to the **Dashboard**.

## Chat Flow

The chat interaction follows this pattern:

1. User types a message in **ChatInput**, which creates a **Message** entity and adds it to **MessageList** with optimistic mutation (`@O`) using a client-generated message ID.
2. The frontend establishes an SSE connection via `useSSE` to the FastAPI backend at `/v1/chat`.
3. The LLM processes the request and streams tokens back through the SSE connection.
4. Tokens are rendered incrementally in **MessageBubble** components.
5. When complete, the full message is cached with `staleTime: 0` and `gcTime: Infinity` to ensure freshness while preventing premature garbage collection.

## Email Sending Flow

Sending an email involves multiple services:

1. User composes an email in the **Compose** interface and clicks send.
2. Frontend POSTs to `/v1/email/send` with FastAPI JWT authentication.
3. FastAPI proxy forwards the request to the Nylas API with proper OAuth credentials.
4. Nylas sends the email and later triggers a webhook notification.
5. The webhook is processed by an Edge Function, which upserts the email record.
6. Realtime updates push the new email to the user's inbox via Supabase Realtime.

## Cost Budget Enforcement Flow

AI cost governance follows a multi-tier enforcement model:

1. The LiteLLM proxy intercepts all AI requests and extracts `x-litellm-tags` containing `org_id`, `user_id`, and `feature`.
2. The system queries **cost_budgets** and calculates usage percentage from **ai_cost_log** (TimescaleDB hypertable).
3. **Budget Thresholds:**
   - Below 85%: Request forwarded and logged normally.
   - At 85%: Warning notification sent to admin (15% remaining alert).
   - At 95%: Warning sent to admin and engineering team (5% remaining alert).
   - At 100%: Request blocked with HTTP 429 and **CostLimitBanner** displayed to user.
4. Cost forecasts are available via `GET /v1/cost-forecast`, which uses TimescaleDB continuous aggregates to return projected costs, confidence intervals, trends, and recommended actions.

## Nylas Webhook Processing Flow

Email synchronization via Nylas webhooks:

1. Nylas POSTs to `/v1/evnt/webhook/nylas` with webhook payload.
2. FastAPI verifies HMAC-SHA256 signature and acknowledges within 10 seconds.
3. System extracts `nylas_id` and checks for uniqueness via `UNIQUE(org_id, nylas_id)` constraint.
4. If not found locally, the system fetches the email from Nylas (upsert-first pattern).
5. Conflict resolution uses Last-Write-Wins (LWW) via `uat` (updated-at) timestamp.
6. Historical filtering requests are queued for async processing.
7. Monitoring alerts trigger if failure rate exceeds 5% over 5 minutes.
8. Nylas automatically disables the webhook URL after 95% failure rate over 72 hours.

### Nylas Webhook Failure Patterns

Nylas uses a two-tier failure state model for webhook endpoints:

#### Failing State (15-minute window)

- Triggered when Nylas receives 95% non-200 responses or non-responses over 15 minutes

- While in failing state, Nylas continues delivering webhook notifications for 72 hours with exponential backoff

- Email notification sent when endpoint transitions to failing state

- Add `@nylas.com` to email allowlist to prevent notifications from going to spam

#### Failed State (72-hour window)

- Triggered when 95% non-200 responses or non-responses persist over 72 hours

- Webhook endpoint marked as failed and stops receiving notifications

- Email notification sent when endpoint transitions to failed state

- Manual reactivation required via Nylas Dashboard or Webhooks API

- Nylas does NOT send notifications for events that occurred while endpoint was failed

- Events missed during failed state are lost unless manually retrieved via API polling

#### Industry Comparison

- Nylas's 95% threshold is more conservative than typical circuit breaker patterns (50% failure rate)

- This design choice reduces false positives from transient failures

- Hookdeck guide suggests 50% failure rate over 1-minute window or 5 of 10 requests failed for circuit breakers

### Grant Expiration Handling

#### Best Practices

- Subscribe to `grant.*` notifications (recommended approach) to monitor status changes

- When `grant.expired` notification received, prompt user to re-authenticate immediately

- Alternative methods: Poll Get all grants endpoint and check `grant_status`, or monitor Nylas Dashboard

- Nylas cannot access user data when grant is expired

#### Re-authentication Flow

- When user re-authenticates successfully, Nylas checks when grant was last valid

- If grant was out of service < 72 hours: Nylas sends backfill notifications for changes during outage

- If grant was out of service > 72 hours: Nylas does NOT send backfill notifications

- For > 72 hour outages: Query Nylas APIs for objects that changed between `grant.expired` and `grant.updated` timestamps

#### Critical Limitation

- Message tracking events (message.opened, message.link_clicked, thread.replied) cannot be backfilled if grant was out of service > 72 hours

- These events are permanently lost and must be accepted as data gap

- Support cannot replay webhooks - manual API retrieval is the only recovery mechanism

## MCP Policy Enforcement Flow

Model Context Protocol tool execution follows zero-trust principles:

1. Agent requests tool execution via `POST /v1/mcp/execute` to the zero-trust gateway.
2. System checks **mcp2_tool_authorizations** table, requiring OAuth authentication (API keys not permitted).
3. Arguments are validated against schema allowlist.
4. Policy evaluation is deterministic (allow, deny, or require approval).
5. High-risk operations trigger elicitation (pause for human approval).
6. Approved operations execute in sandbox environment and are logged.
7. Denied operations return error with policy reason and are logged to **mcp2_policy_evaluations**.

## Specification Validation Flow

Component specification enforcement in CI:

1. Components flagged with pattern tags like `@OptimisticMutation`, `@SSEStream`, `@Recurring`, `@XCT`, `@Upload`, or `@KeyboardShortcuts` are checked for an associated specification or linked parent spec.
2. If missing, DoD1 is blocked and the PR author is notified.
3. If present, the system validates YAML frontmatter and all 9 required sections.
4. Tier is auto-assigned:
   - Pattern-tagged components → Tier 1
   - Cards and list items → Tier 2
   - Presentational components → Tier 3
5. Results are stored in **spec_metadata** and the CI gate is triggered.

## Optimistic UI Flow

Optimistic updates provide immediate user feedback:

1. For create, update, or delete operations, `useOptimistic` immediately updates the UI.
2. Pending state displays with opacity 0.5, italic styling, and pulse animation.
3. A temporary ULID is generated for new entities; the request includes an idempotency key (IC).
4. On success: The optimistic state matches the confirmed server state.
5. On failure: Automatic rollback occurs with error toast and 5-second undo window.
