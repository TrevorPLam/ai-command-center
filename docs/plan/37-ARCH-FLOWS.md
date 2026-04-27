---
title: "Critical User Flows"
owner: "Architecture"
status: "active"
updated: "2026-04-26"
canonical: ""
---

This document describes the key user flows and system interactions in the AI Command Center platform.

## System-Level Data Flows

The following table describes how data flows between system components at the infrastructure level:

| Source | Destination | Protocol | Security Controls | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| Browser | FastAPI | HTTPS | JWT+org_id | `/v1/*` API endpoints |
| FastAPI | Supabase | TCP | Internal network, RLS enforced | Database queries (SQLModel) |
| FastAPI | LiteLLM | HTTPS | API key rot, cosign | LLM routing (Claude, GPT, Gemini) |
| FastAPI | MCP Server | HTTP | MCPSec L2, OAuth tool auth | SSRF allowlist, nonce replay protection |
| FastAPI | Stripe | HTTPS | API key 180d rotation | Billing (`@stripe`/ai-sdk) |
| FastAPI | Nylas | HTTPS | OAuth2, grant.expired webhook | Email sync (upsert-first, 10s ack) |
| FastAPI | LiveKit | WebSocket | Token TTL 6h, RBAC scoped | Voice pipeline (STT/LLM/TTS) |
| Supabase | Browser | WebSocket | JWT auth, org-scoped channels | Realtime CDC updates |
| FastAPI | TimescaleDB | TCP | Internal network | AI cost logging hypertable |
| FastAPI | Upstash | Redis | TLS encrypted | Rate limiting, semantic cache |
| FastAPI | Sentry | HTTPS | DSN via env var | Error tracking, session replays |
| FastAPI | PostHog | HTTPS | API key authentication | Product analytics, allow_training flag |
| FastAPI | OTel Collector | HTTPS | OTLP protocol | GenAI traces, PII redaction |

## Authentication flow

When a user logs into the application, the following sequence occurs:

1. User enters credentials on the **LoginPage**, which calls `signInWithPassword` to authenticate with Supabase Auth.
2. Upon successful authentication, the **authSlice** in Zustand is updated with the current user information.
3. The JWT token contains embedded `org_id` and `user_role` claims for authorization.
4. The `onAuthStateChange` listener triggers query invalidation and realtime reconnect, then redirects the user to the **Dashboard**.

## Chat flow

The chat interaction follows this pattern:

1. User types a message in **ChatInput**, which creates a **Message** entity and adds it to **MessageList** with optimistic mutation (``@O``) using a client-generated message ID.
2. The frontend establishes an SSE connection via `useSSE` to the FastAPI backend at `/v1/chat`.
3. The LLM processes the request and streams tokens back through the SSE connection.
4. Tokens are rendered incrementally in **MessageBubble** components.
5. When complete, the full message is cached with `staleTime: 0` and `gcTime: Infinity` to ensure freshness while preventing premature garbage collection.

## Email sending flow

Sending an email involves multiple services:

1. User composes an email in the **Compose** interface and clicks send.
2. Frontend POSTs to `/v1/email/send` with FastAPI JWT authentication.
3. FastAPI proxy forwards the request to the Nylas API with proper OAuth credentials.
4. Nylas sends the email and later triggers a webhook notification.
5. The webhook is processed by an Edge Function, which upserts the email record.
6. Realtime updates push the new email to the user's inbox via Supabase Realtime.

## Cost budget enforcement flow

AI cost governance follows a multi-tier enforcement model:

1. The LiteLLM proxy intercepts all AI requests and extracts `x-litellm-tags` containing `org_id`, `user_id`, and `feature`.
2. The system queries **cost_budgets** and calculates usage percentage from **ai_cost_log** (TimescaleDB hypertable).
3. **Budget Thresholds:**
   - Below 85%: Request forwarded and logged normally.
   - At 85%: Warning notification sent to admin (15% remaining alert).
   - At 95%: Warning sent to admin and engineering team (5% remaining alert).
   - At 100%: Request blocked with HTTP 429 and **CostLimitBanner** displayed to user.
4. Cost forecasts are available via `GET /v1/cost-forecast`, which uses TimescaleDB continuous aggregates to return projected costs, confidence intervals, trends, and recommended actions.

## Nylas webhook processing flow

Email synchronization via Nylas webhooks:

1. Nylas POSTs to `/v1/evnt/webhook/nylas` with webhook payload.
2. FastAPI verifies HMAC-SHA256 signature and acknowledges within 10 seconds.
3. System extracts `nylas_id` and checks for uniqueness via `UNIQUE(org_id, nylas_id)` constraint.
4. If not found locally, the system fetches the email from Nylas (upsert-first pattern).
5. Conflict resolution uses Last-Write-Wins (LWW) via `uat` (updated-at) timestamp.
6. Historical filtering requests are queued for async processing.
7. Monitoring alerts trigger if failure rate exceeds 5% over 5 minutes.
8. Nylas automatically disables the webhook URL after 95% failure rate over 72 hours.

For detailed operational procedures including webhook failure patterns and grant expiration handling, see [80-OPS-MANUAL.md](80-OPS-MANUAL.md#48-data-integrity).

## MCP policy enforcement flow

Model Context Protocol tool execution follows zero-trust principles:

1. Agent requests tool execution via `POST /v1/mcp/execute` to the zero-trust gateway.
2. System checks **mcp2_tool_authorizations** table, requiring OAuth authentication (API keys not permitted).
3. Arguments are validated against schema allowlist.
4. Policy evaluation is deterministic (allow, deny, or require approval).
5. High-risk operations trigger elicitation (pause for human approval).
6. Approved operations execute in sandbox environment and are logged.
7. Denied operations return error with policy reason and are logged to **mcp2_policy_evaluations**.

## Specification validation flow

Component specification enforcement in CI:

1. Components flagged with pattern tags like ``@OptimisticMutation``, ``@SSEStream``, ``@Recurring``, ``@XCT``, ``@Upload``, or ``@KeyboardShortcuts`` are checked for an associated specification or linked parent spec.
2. If missing, DoD1 is blocked and the PR author is notified.
3. If present, the system validates YAML frontmatter and all 9 required sections.
4. Tier is auto-assigned:
   - Pattern-tagged components → Tier 1
   - Cards and list items → Tier 2
   - Presentational components → Tier 3
5. Results are stored in **spec_metadata** and the CI gate is triggered.

## Optimistic UI flow

Optimistic updates provide immediate user feedback:

1. For create, update, or delete operations, `useOptimistic` immediately updates the UI.
2. Pending state displays with opacity 0.5, italic styling, and pulse animation.
3. A temporary ULID is generated for new entities; the request includes an idempotency key (IC).
4. On success: The optimistic state matches the confirmed server state.
5. On failure: Automatic rollback occurs with error toast and 5-second undo window.
