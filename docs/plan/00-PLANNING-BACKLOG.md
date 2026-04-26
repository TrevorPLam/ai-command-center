---
steering: TO PARSE — READ INTRO
file_name: 00-PLANNING-BACKLOG.md
document_type: planning_backlog
tier: strategic
status: active
owner: Trevor (Solo Founder)
description: Master backlog of all unresolved planning decisions, research topics, and specification gaps. Tracks what must be decided before each Phase block can begin execution.
last_updated: 2026-04-26
version: 1.0
dependencies: [00-STRAT-BLUEPRINT.md, 00-STRAT-PRD.md, 01-PLAN-MILESTONES.md, 01-PLAN-LEXICON.md]
related_adrs: []
related_rules: []
complexity: high
risk_level: critical
---

# Planning Backlog — Master Decision & Research Tracker

## README: How AI Agents Should Use This Document

This document is the single source of truth for what still needs to be decided before code execution begins. Every item here represents a gap that, if left unresolved, would force an agent to guess — and guesses compound into rework.

**Rules for agents:**
1. **Read this document first** when beginning any new planning session, after the blueprint and milestones.
2. **Only execute code** when all items in the "Ready for Code?" checklist for that block are marked RESOLVED.
3. **When assigned a backlog item**, produce a standalone markdown spec document (following the lexicon's `@SPEC` template: yaml frontmatter + 9 sections), then update this backlog to mark it RESOLVED.
4. **Never resolve an item by removing scope**. The blueprint principle holds: defer, split, sequence — never delete.
5. **Cross-reference against Domain E (Security & Compliance)** for every decision that touches AI behavior, data handling, or user-facing features.
6. **External research must be cited** with source URLs and retrieval dates.


## Backlog Item Priority Definitions

| Priority | Definition | Action Window |
|----------|------------|---------------|
| **P0** | Blocks Phase 0 Block execution. Must resolve before code. | Next planning session(s) — immediate |
| **P1** | Blocks Phase 1 execution or a Phase 0 polish item. | Before Phase 0 Block 0F completion |
| **P2** | Needed for Phase 2+ but can start research now. | Before Phase 1 exit gate |
| **P3** | Long-horizon. No block depends on it yet. | Anytime before Phase 3 |


## Category A: Implementation-Facing Specifications (Missing or Incomplete)

These items represent places where component specs (`04-COMP-*.md`) define patterns but lack the exact data shapes, prop interfaces, or state machines an AI agent would need to produce correct code.

### BP-001: Zustand Slice TypeScript Interfaces
- **Priority**: P0 (blocks all Phase 0 UI work)
- **Blocks**: Phase 0 Blocks 0C, 0D, 0E
- **Current state**: `01-PLAN-ZUSTAND.md` lists 60+ slice names with persistence notes only. No types defined.
- **Why this matters now**: The 2026 AI-native stack research confirms that "the orchestration layer is where reasoning, decision-making, and coordination take place" and that "context is the new bottleneck"[reference:0]. Zustand slices are the client-side orchestration layer — they must be typed correctly before any component can be built, because every AI agent building components will need to reference exact slice shapes.
- **Research basis**: Zustand v5 with `useShallow` is already mandated (ADR_003). The React 20 Compiler changes how state management interacts with rendering — reference comparisons are now compiler-managed, making exact type definitions more critical, not less[reference:1].
- **Suggested AI agent task**: "Using the Lexicon from `01-PLAN-LEXICON.md` and the component specs in `04-COMP-*.md`, infer and define the complete TypeScript interface for every Zustand slice listed in `01-PLAN-ZUSTAND.md`. Prioritize Phase 0 slices: `authSlice`, `orgSlice`, `chatSlice`, `calendarSlice`, `projectSlice`, `dashboardSlice`, `notificationSlice`, `costSlice`. Output a new file: `01-PLAN-ZUSTAND-TYPES.md`."
- **Status**: 🔴 NOT STARTED
- **Target session**: Immediate

### BP-002: Core Phase 0 Component Props & State Machines
- **Priority**: P0 (blocks component implementation)
- **Blocks**: Phase 0 Blocks 0C, 0D, 0E
- **Current state**: Component specs in `04-COMP-*.md` define pattern annotations (`@M`, `@O`, `@V`, etc.) but no prop interfaces or state machines.
- **Why this matters now**: For the conflict-detection "aha moment" demo, the exact props flowing between `ActivityFeed`, `AttentionQueue`, `DecisionPacket`, and `AgentDetailDrawer` must be defined. Without this, AI agents will build components that don't connect.
- **Specific components needing full specs** (Phase 0 critical path):
  - `ChatPage`, `ThreadList`, `MessageList`, `MessageBubble`, `ChatInput`, `ToolCallDisclosure`
  - `CalendarPage`, `MonthView`, `WeekDayView`, `EventComposer`, `EventDetailDrawer`
  - `ProjectsPage`, `ProjectKanbanView`, `TaskList`, `TaskDetailDrawer`
  - `DashboardPage`, `AmbientStatusBanner`, `ActivityFeed`, `AttentionQueue`, `DecisionPacket`
  - `AppShell`, `Sidebar`, `OrgSwitcher`, `CommandPalette`
- **Research basis**: Industry data shows that "orchestration complexity explodes fast" when multiple agents interact, and "the coordination overhead between agents becomes the bottleneck"[reference:2]. While this refers to AI agents, the same architectural principle applies to UI components — undefined interfaces between components create integration bottlenecks.
- **Suggested AI agent task**: "For each Phase 0 component listed above, produce a detailed prop interface (TypeScript), a state machine diagram (using FLOWC_01 SM pattern from the lexicon), and define exact event callbacks. Use the existing pattern annotations as constraints. Output as `04-COMP-{MODULE}-SPEC.md` for each module."
- **Status**: 🔴 NOT STARTED
- **Target session**: After BP-001

### BP-003: Database DDL for All Phase 0 Tables
- **Priority**: P0 (blocks Prisma schema generation)
- **Blocks**: Phase 0 Block 0A, all data-dependent blocks
- **Current state**: `02-ARCH-DATABASE.md` lists 63+ tables with key columns, but no CREATE TABLE statements, no exact column types, no constraint definitions.
- **Why this matters now**: Prisma schema generation is in Block 0A. The agent needs exact DDL. The Lexicon already defines key patterns (ULID for IDs, `deleted_at` for tombstones, `uat` for LWW conflict resolution, `org_id` on every table). These must be translated into executable SQL.
- **Specific Phase 0 tables**: `organizations`, `org_members`, `user_roles`, `role_permissions`, `events`, `tasks`, `projects`, `messages`, `threads`, `notifications`, `audit_logs`, `ai_cost_log`, `connected_accounts`, `feature_flags`, `recurrence_rules`, `agent_definitions`, `prompt_versions`
- **Research basis**: The multi-tenant RLS pattern is well-established for Supabase: every table gets `organization_id`, RLS policies check membership via a `team_members` join pattern, and `auth.uid()` provides user identity[reference:3]. The `service_role` key bypasses RLS — this must be explicitly documented in DDL comments[reference:4]. pgTAP testing is mandatory for every new table (HARD rule TESTC04b).
- **Suggested AI agent task**: "Generate complete CREATE TABLE statements for all Phase 0 tables, including column types (use UUID for primary keys, TIMESTAMPTZ for timestamps, JSONB for flexible data), foreign key constraints, NOT NULL constraints, default values, and RLS policies. Use the `02-ARCH-DATABASE.md` table list and `01-PLAN-LEXICON.md` domain shortcuts as source of truth. Output as `02-ARCH-DATABASE-DDL.sql`."
- **Status**: 🔴 NOT STARTED
- **Target session**: After BP-001

### BP-004: OpenAPI 3.1 Schema Fragments for Phase 0 Endpoints
- **Priority**: P0 (blocks API implementation and MSW mock generation)
- **Blocks**: Phase 0 Block 0A (FastAPI), Block 0C (chat endpoints), Block 0D (calendar/task CRUD)
- **Current state**: `02-ARCH-ENDPOINTS.md` lists 49 endpoints by method and path, but no request/response schemas or error codes.
- **Why this matters now**: The lexicon mandates that OAI 3.1 is the single source of truth, Orval generates TypeScript types from it, and Schemathesis runs contract tests in CI (APIC_01, APIC_02, APIC_003 rules). None of this is possible without schemas.
- **Phase 0 endpoints needing schemas**: Auth endpoints, `/v1/calendar/*` (CRUD), `/v1/tasks/*` (CRUD), `/v1/chat` (streaming + tool calls), `/v1/notifications/*`, `/v1/conflicts/detect`, `/v1/conflicts/resolve`, `/v1/cost/*`, `/v1/livekit/token`
- **Research basis**: The Vercel AI SDK v6 provides structured tool calling with JSON Schema enforcement[reference:5]. FastAPI's OpenAPI integration auto-generates schemas from Pydantic models, but the models must be designed first.
- **Suggested AI agent task**: "For every Phase 0 endpoint listed in `02-ARCH-ENDPOINTS.md`, produce an OpenAPI 3.1 schema fragment including: request body schema (JSON Schema), response schema (200, 400, 401, 403, 429), and authentication requirements (JWT with org_id claim). Follow the APIC_01 rule: use `$ref` and `allOf` for DRY, `oneOf` with discriminator for polymorphism, `additionalProperties: false`. Output as `02-ARCH-ENDPOINTS-SCHEMA.yaml`."
- **Status**: 🔴 NOT STARTED
- **Target session**: After BP-003

### BP-005: Error Taxonomy & User-Facing Message Catalogue
- **Priority**: P0 (blocks consistent UX across all components)
- **Blocks**: Phase 0 all blocks
- **Current state**: No standardized error catalogue exists. The Lexicon mentions pattern-based error handling (429 → RL, etc.) but no message templates.
- **Why this matters now**: Every component needs error states. Without a taxonomy, AI agents will produce inconsistent error messages across different components, degrading the "appearance of AI" UX that is an open strategic question.
- **Error categories needed**: `AUTH_ERROR`, `RATE_LIMITED`, `AI_FAILED`, `AI_FALLBACK_LOCAL`, `AI_UNAVAILABLE`, `VALIDATION_ERROR`, `NOT_FOUND`, `PERMISSION_DENIED`, `ORG_NOT_FOUND`, `SYNC_ERROR`, `NETWORK_ERROR`, `CONFLICT_DETECTED`, `CONFLICT_RESOLVED`, `CONFLICT_FAILED`
- **Research basis**: Enterprise-grade AI systems benefit from "FinOps tooling for AI inference, which covers token cost attribution, usage governance, and multi-model routing" — error handling for AI failures is distinct from traditional API errors because failures can be partial (model routed correctly but tool call failed) or cascading (orchestrator failure → verifier rejection)[reference:6].
- **Suggested AI agent task**: "Define a complete error taxonomy for the AI-integrated SaaS. For each error category, produce: HTTP status code, JSON response shape (`{error: {code, message, retryAfter?, details?}}`), user-facing message template (friendly, actionable), and when it should be logged to `audit_logs`. Follow the ERR_ENV pattern from `09-REF-KNOWLEDGE.md`. Output as `05-XCT-ERROR-TAXONOMY.md`."
- **Status**: 🔴 NOT STARTED
- **Target session**: After BP-001


## Category B: Undefined User Flows & UX Specifications

These items represent user journeys described at a narrative level but not specified to the detail an AI agent needs.

### BP-006: Conflict Detection UX — Complete Flow Specification
- **Priority**: P0 (this IS the core magic demo)
- **Blocks**: Phase 0 Blocks 0E, 0F
- **Current state**: The conflict flow is described narratively: "Agent detects conflict → Dashboard notification with action buttons." No error states, empty states, loading states, or escalation paths are defined.
- **States that must be specified**:
  1. **No conflicts found** — what does the dashboard show? Empty state with CTA?
  2. **Conflict detected, awaiting user action** — exact notification card design, action button labels, what happens on "Reschedule" vs "Move Task" vs "Ignore"
  3. **User takes action — optimistic UI** — what shows during resolution?
  4. **Resolution succeeds** — confirmation, undo window (5s per XCT_02 rule)
  5. **Resolution fails** — error state, retry option, escalation
  6. **Multiple conflicts detected** — how are they prioritized? Ordered list?
  7. **User dismisses without acting** — does conflict re-surface? When?
  8. **Conflict involves external calendar event** — different UX for read-only external events?
- **Research basis**: The core innovation is "cross-application, context-aware AI assistance" that "does not exist at scale in current products." The UX for this is novel and must be designed thoughtfully — it's the primary differentiator.
- **Suggested AI agent task**: "Using the blueprint's Design Axioms and the component specs for `AttentionQueue`, `DecisionPacket`, `ActivityFeed`, and `AmbientStatusBanner`, produce a complete UX flow specification for conflict detection and resolution. Cover all 8 states listed above. Include mock notification templates, deeplink structures, and accessibility requirements (WCAG 2.2 AA). Output as `10-UX-CONFLICT-FLOW.md`."
- **Status**: 🔴 NOT STARTED
- **Target session**: Immediate

### BP-007: First-Time User Onboarding Flow
- **Priority**: P0 (first impression for external testers)
- **Blocks**: Phase 0 Exit Gate
- **Current state**: `EmptyState` pattern exists as a lexicon rule (`FLOWC_03`), but no step-by-step guided onboarding is specified.
- **Flow**: Signup → Org creation → Connect Google Calendar → Create first project → Create first task → See dashboard → Trigger first conflict → Resolve conflict → "Aha" moment.
- **Research basis**: Industry data shows that AI SaaS products need to "start building demand while you're still building the product" and that "waitlist members become your beta testing pool" — but for a demo, the onboarding must be seamless[reference:7]. Solo founders using AI tools are now "routinely hitting $10K–$50K+ in monthly recurring revenue"[reference:8]. First impressions determine whether testers convert.
- **Suggested AI agent task**: "Design the complete first-time user onboarding flow from signup to first conflict resolution. Include: welcome screen, guided calendar connection (OAuth flow), suggested first project/task creation, empty states with CTAs for each app, first notification experience, and a 'congratulations' moment when the first conflict is detected. Every step must include loading, error, and empty states. Output as `10-UX-ONBOARDING-FLOW.md`."
- **Status**: 🔴 NOT STARTED
- **Target session**: After BP-006

### BP-008: Agent Tool-Calling Feedback Loop UX
- **Priority**: P0 (this is the user's window into AI operation)
- **Blocks**: Phase 0 Block 0C
- **Current state**: `ToolCallDisclosure` component exists in `04-COMP-CHAT.md` with pattern `@M,AS` but no detailed behavior specification.
- **What must be specified**:
  - How the user sees the agent's internal reasoning (ThinkingTracePanel states: collapsed, expanded, streaming)
  - Tool execution visualization (approved, pending, executing, succeeded, failed)
  - User approval flow for sensitive tool calls (per GRDL_01 runtime layer)
  - Tool output display (raw JSON vs. formatted summary)
  - Error states: tool not found, tool execution timeout, tool permission denied
  - The "appearance of AI" design question: how to make deterministic tool calls feel agentic
- **Research basis**: The "engagement layer is where intent is captured and responses are delivered"[reference:9]. For agentic systems, "observability is still way behind" and "most teams can't see nearly enough of what their agentic systems are doing" — the tool-calling UI IS the observability for end users[reference:10].
- **Suggested AI agent task**: "Produce a detailed UX specification for the agent tool-calling feedback loop. Define all states for `ToolCallDisclosure`, `ThinkingTracePanel`, and `GenUIRenderer` components. Include the approval gate for sensitive operations. Address the 'appearance of AI' open question with concrete design recommendations (animations, natural-language summaries, agent avatars). Output as `10-UX-TOOL-CALLING.md`."
- **Status**: 🔴 NOT STARTED
- **Target session**: After BP-006

### BP-009: CSP Nonce Integration with Vite + React 19
- **Priority**: P1 (security-critical but can be implemented after initial UI)
- **Blocks**: Phase 0 Block 0F (security audit)
- **Current state**: `05-XCT-CSP.md` defines the policy but not the Vite/React integration specifics for nonce injection.
- **Research basis**: CSP nonce strategy is a HARD rule (S6, S7, S11). DOMPurify ≥3.4.0 is mandatory (CVE-2026-41238 protection)[reference:11]. The nonce must be cryptographically random per request and injected into the Vite HTML template.
- **Suggested AI agent task**: "Research and document the exact implementation for CSP nonce injection in a Vite SPA + React 19 setup. Include: Vite plugin configuration, HTML template modification, nonce generation (cryptographically random, per-request), Monaco Editor sandboxing with separate CSP, and Report-Only mode for pre-production per `05-XCT-CSP.md`. Output as `05-XCT-CSP-IMPLEMENTATION.md`."
- **Status**: 🔴 NOT STARTED
- **Target session**: Before Block 0F

### BP-010: Offline Status & Tombstone UI Specification
- **Priority**: P2 (Phase 2 but tombstone data model is defined in Phase 0)
- **Blocks**: Phase 2 Block 2E (offline foundation)
- **Current state**: Data model patterns defined (`deleted_at`, ULID, IC keys), but no UI for offline state.
- **Research basis**: TanStack DB 0.6 now includes "persistence, offline support, and hierarchical data projection"[reference:12]. PowerSync confirmed as primary offline sync for Phase 2+. The UI patterns for "offline indicator," "sync status," and "conflict resolution modal" are not defined.
- **Suggested AI agent task**: "Design the offline status and sync UI. Include: connectivity indicator, sync status badge, pending changes queue view, conflict resolution modal, and empty states for when offline data is stale. Use the tombstone pattern from CRDB_01. Output as `10-UX-OFFLINE-FLOW.md`."
- **Status**: 🔴 NOT STARTED
- **Target session**: Before Phase 2


## Category C: Business Logic & Monetization Decisions

These are the "open questions" from the blueprint that need concrete answers before they block implementation.

### BP-011: Free vs. Pro Feature Matrix (Exact Limits)
- **Priority**: P0 (blocks Phase 0 Block 0F Stripe integration)
- **Blocks**: Phase 0 Block 0F, Phase 1 monetization
- **Current state**: High-level tiers defined (Free: local models, Pro: cloud, Team: fine-tuning), but exact limits not specified.
- **Decisions needed**:
  - Max AI calls per day for free tier (local models, so limits are about UX not cost)
  - Max projects/tasks/events per org per tier
  - Max connected calendars per tier
  - Max notification rules per tier
  - Data retention differences (if any)
  - Offline sync availability per tier
  - Max org members per tier (Free: 3 users per the PowerSync free tier note)
- **Research basis**: The freemium model in AI SaaS is evolving rapidly. Lovable's approach treats "freemium as growth infrastructure, not margin leakage"[reference:13]. The key insight from one practitioner: "Free user clicks → Check DB for cached visualization... If miss, show 'Generating visualizations is a Pro feature.' No Claude call. $0 marginal."[reference:14]. For Trevor's product, free users on local models already have near-zero marginal cost — the limits are about preventing abuse and creating upgrade incentive.
- **Strategic consideration**: At 10,000 free users, a cloud-dependent competitor burns $50K-$150K/month. Trevor's cost: ~$10 in electricity. **The free tier should be generous enough to become part of users' routines** — that's the structural moat.
- **Suggested AI agent task**: "Define the exact feature matrix for Free, Pro ($20-30/mo), Team ($50-100/user/mo), and Enterprise tiers. Specify every limit numerically. Justify each limit with reference to either cost, abuse prevention, or upgrade incentive. Ensure free tier is genuinely useful (per industry best practice) while creating natural upgrade moments. Follow the monetization model in `00-STRAT-PRD.md`. Output as `00-STRAT-TIER-MATRIX.md`."
- **Status**: 🔴 NOT STARTED
- **Target session**: Before Block 0F

### BP-012: Local Model Lifecycle & Governance Policy
- **Priority**: P1 (blocks Phase 1 Block 1D)
- **Blocks**: Phase 0 Block 0B (partial — needs strawman), Phase 1 Block 1D
- **Current state**: Open question in blueprint: "How to version, update, and deprecate local models without breaking user workflows."
- **Decisions needed**:
  - Auto-update vs. user-approval for model upgrades
  - Deprecation notice period (strawman: 30 days)
  - Migration path when a model is sunset (auto-migrate to successor?)
  - User-installed third-party model policy (allowed? gated behind a trust verification?)
  - Re-benchmarking frequency (strawman: weekly for active models)
  - How to handle model capability regression (a model update that reduces tool-calling accuracy)
- **Research basis**: The industry is moving toward "multi-model routing" as a standard pattern[reference:15]. Model staleness is a real concern — automated re-benchmarking is essential. Qwen3.5 4B at 97.5% tool-calling accuracy is the backup if Gemma 4 E2B underperforms. The Model Trust Registry (C.4 section of blueprint) already defines the metadata structure.
- **Suggested AI agent task**: "Produce a comprehensive local model lifecycle policy covering: update cadence, deprecation windows (minimum 30 days), user communication templates, migration automation, third-party model governance, and re-benchmarking schedule. Reference the Model Registry structure from `06-AI-LOCAL-INFRA.md` and the Model Trust Registry from `06-AI-ARCHITECTURE.md`. Output as `06-AI-MODEL-LIFECYCLE.md`."
- **Status**: 🔴 NOT STARTED
- **Target session**: Before Phase 1 Block 1D

### BP-013: Proactive Behavior Cadence Configuration
- **Priority**: P1 (blocks Phase 1 Block 1C)
- **Blocks**: Phase 1 Block 1C (proactive notification engine)
- **Current state**: Open question: "How often should agents check for conflicts? Tied to subscription tiers and per-feature configuration."
- **Decisions needed**:
  - Free tier: manual-only conflict detection (user triggers via chat)?
  - Pro tier: scheduled daily check? Event-driven (on calendar change)?
  - Team tier: near-real-time monitoring?
  - Per-feature granularity (calendar conflicts vs. email parsing vs. project deadline warnings)
  - Resource impact of different cadences on local models
- **Suggested AI agent task**: "Define the proactive behavior configuration model. Specify: cadence options per tier, which events trigger a proactive check, how to configure per-feature, and the resource budget for each cadence level. Reference the Intent Dispatcher to ensure proactive checks don't overwhelm local models. Output as `06-AI-PROACTIVE-CONFIG.md`."
- **Status**: 🔴 NOT STARTED
- **Target session**: Before Phase 1

### BP-014: Notification System Architecture (Channels, Preferences, Delivery)
- **Priority**: P1 (blocks Phase 1 notification features)
- **Blocks**: Phase 1 Block 1C, Email integration
- **Current state**: Tables exist (`notifications`, `notificationPreferences`), but delivery mechanisms and channel routing are not specified.
- **Decisions needed**:
  - Channel types: in-app (real-time), email (Resend), push (Expo, Phase 3)
  - Per-notification-type default channels
  - User preference granularity (per-type? per-channel? digest vs. immediate?)
  - Notification grouping / batching rules
  - Resend integration for transactional emails (primary per ADR_088)
- **Suggested AI agent task**: "Design the notification system architecture. Define: all notification types (conflict_detected, conflict_resolved, email_reschedule_request, task_due_soon, budget_warning, etc.), their default channels per tier, user preference model, batching/digest rules, and the Resend email template structure. Output as `05-XCT-NOTIFICATIONS.md`."
- **Status**: 🔴 NOT STARTED
- **Target session**: Before Phase 1


## Category D: Research & Validation Topics

These items require external research before a decision can be made. They are ideal for "context injection → research" sessions.

### BP-015: Local Model Tool-Calling Reliability Validation
- **Priority**: P0 CRITICAL (Block 0B go/no-go decision)
- **Blocks**: Phase 0 Block 0B
- **Current state**: Blueprint says "Decision point @ Week 5: If local tool-calling reliability <90% on Gemma 4 E2B, evaluate Qwen3.5 4B or Llama4-7B as fallback orchestrator."
- **Research needed**: What is the actual observed tool-calling pass rate of Gemma 4 E2B (2B active params) on a 40+ test case suite representative of the conflict detection and calendar/task CRUD tools? What about Qwen3.5 4B? What are the latency profiles on Tier 1 hardware (CPU-only, 16GB RAM)?
- **Research basis**: Qwen3.5 4B is reported at 97.5% tool-calling accuracy. Gemma 4 has "native tool calling support" via special tokens. But observed vs. reported accuracy can diverge significantly.
- **Suggested AI agent task**: "Research the latest (April 2026) independent benchmarks for Gemma 4 E2B and Qwen3.5 4B on structured tool calling. Find: tool-calling pass rates, latency on CPU-only hardware, multi-tool chaining success rates, and any known failure modes. Cite sources. Output findings as `06-AI-TOOL-CALLING-BENCHMARKS.md`."
- **Status**: 🔴 NOT STARTED
- **Target session**: Immediate — before Block 0B

### BP-016: Google Calendar API Free Tier Limits & OAuth Scope Strategy
- **Priority**: P0 (affects Phase 0 Block 0D design)
- **Blocks**: Phase 0 Block 0D (calendar sync)
- **Current state**: Blueprint says "Free API (1M req/day). Periodic fetch, not real-time." But exact quota structure, per-user limits, and OAuth verification requirements need confirmation.
- **Research needed**: Google Calendar API quota structure as of April 2026. OAuth verification requirements for read-only vs. read-write scopes. Push notification (webhook) availability for free tier. Outlook Graph API equivalent limits.
- **Suggested AI agent task**: "Research current (April 2026) Google Calendar API quotas, OAuth verification requirements, and webhook/push notification availability for free tier. Also research Microsoft Graph API for Outlook Calendar — quotas, auth model, and any EWS deprecation impact (EWS blocks non-Microsoft apps from Oct 2026 per blueprint risk registry). Output as `02-ARCH-CALENDAR-API-RESEARCH.md`."
- **Status**: 🔴 NOT STARTED
- **Target session**: Immediate — before Block 0D

### BP-017: Stripe Metered Billing + AI Cost Attribution Integration Details
- **Priority**: P0 (defines how money flows)
- **Blocks**: Phase 0 Block 0F
- **Current state**: Blueprint references `@stripe/ai-sdk`, `@stripe/token-meter`, `@stripe/agent-toolkit`. But the exact integration pattern — especially how local model usage (near-zero cost) is tracked vs. cloud model usage — needs specification.
- **Research needed**: Does `@stripe/token-meter` support custom metering for non-Stripe-instrumented calls (like local Ollama usage)? How to implement the "sync pre-call budget check" (COST_03 HARD rule)? What's the reconciliation pattern between LiteLLM cost logs and Stripe meters?
- **Suggested AI agent task**: "Research the Stripe three-package architecture (`@stripe/ai-sdk`, `@stripe/token-meter`, `@stripe/agent-toolkit`) as of April 2026. Document: how to meter both LiteLLM-proxied cloud calls and local Ollama calls, how to implement synchronous pre-call budget enforcement, the reconciliation pattern between `ai_cost_log` and Stripe meters, and the 30% markup automation. Output as `02-ARCH-STRIPE-INTEGRATION.md`."
- **Status**: 🔴 NOT STARTED
- **Target session**: Before Block 0F

### BP-018: i18n Framework Decision (Start in Phase 0 or Defer?)
- **Priority**: P2 (but decision needed now — string externalization is hard to retrofit)
- **Blocks**: Nothing yet, but retrofitting i18n after 50+ components is expensive
- **Current state**: i18n is listed as Phase 5 only ("East Asia market readiness"). But the Lexicon contains no i18n rules.
- **Research basis**: Trevor wants to "travel/live in East Asia" — this is a personal goal that could influence product strategy. Even if translations aren't implemented until Phase 5, string externalization (wrapping all user-facing strings in a `t()` function) costs almost nothing in Phase 0 and saves massive rework.
- **Suggested AI agent task**: "Evaluate i18n frameworks compatible with Vite SPA + React 19 (react-i18next, FormatJS, Lingui). Recommend whether to externalize strings in Phase 0 (no translations, just the wrapper) or defer entirely. Consider: bundle size impact, developer experience for AI agents, and Trevor's East Asia market goal. Output as `ADR-I18N.md`."
- **Status**: 🔴 NOT STARTED
- **Target session**: Before Phase 0 Block 0C (Chat UI)


## Category E: Planning Pipeline & Agent Onboarding

These items improve the planning corpus itself as a tool for AI agents.

### BP-019: Agent Onboarding Script ("START-HERE.md")
- **Priority**: P1 (every new AI session begins with context injection)
- **Blocks**: All future sessions
- **Current state**: No single entry point for a fresh AI agent. The consolidated `00-00-00.md` is comprehensive but ~4,000 lines.
- **What this document should contain**:
  1. Who Trevor is and how he works (non-developer, agentic coding, Windsurf)
  2. What the project is (one paragraph)
  3. Which 3 files to read first (blueprint, milestones, this backlog)
  4. What "done" looks like for any AI agent task
  5. Hard constraints (never remove features, always check Domain E, cite sources)
  6. Current session's objective
- **Suggested AI agent task**: "Create a 1-page `START-HERE.md` that orients any fresh AI agent in under 2 minutes. Include: Trevor's identity and workflow, project elevator pitch, required reading order, output standards, hard constraints, and a fillable 'current session objective' field. Output as `START-HERE.md`."
- **Status**: 🔴 NOT STARTED
- **Target session**: After this backlog is reviewed

### BP-020: Ready-for-Code Checklist per Phase 0 Block
- **Priority**: P0 (governs when code execution actually starts)
- **Blocks**: All Phase 0 execution
- **Current state**: Not formalized. The backlog items above define what needs resolution, but not mapped to specific blocks.
- **What this should be**: A checklist embedded in this document (see below) that maps each Phase 0 block to its prerequisite backlog items. All must be RESOLVED before code for that block is written.
- **Suggested AI agent task**: This will be populated below based on dependencies already identified in this backlog.
- **Status**: 🔴 NOT STARTED (being populated now)


## Ready-for-Code Checklist: Phase 0

### Block 0A: Platform Skeleton
- [ ] BP-003: Database DDL (at minimum: `organizations`, `org_members`, `user_roles`, `profiles`)
- [ ] BP-004: OpenAPI schemas for auth endpoints
- [ ] BP-005: Error taxonomy (auth errors, validation errors)
- [ ] BP-001: `authSlice`, `orgSlice` TypeScript interfaces

### Block 0B: Local AI Infrastructure
- [ ] BP-015: Tool-calling reliability benchmarks for Gemma 4 E2B & Qwen3.5 4B
- [ ] BP-012: Strawman model lifecycle policy (even if not final)
- [ ] BP-001: `mcpSlice`, `agentStore` TypeScript interfaces

### Block 0C: Chat + Agent Tool Calling
- [ ] BP-002: Chat component props and state machines
- [ ] BP-008: Agent tool-calling feedback loop UX
- [ ] BP-004: OpenAPI schemas for `/v1/chat`
- [ ] BP-001: `chatSlice`, `memoryStore`, `promptStore` TypeScript interfaces

### Block 0D: Data Apps — Calendar & Tasks
- [ ] BP-002: Calendar and Projects component props and state machines
- [ ] BP-003: DDL for `events`, `tasks`, `projects`, `recurrence_rules`, `connected_accounts`
- [ ] BP-004: OpenAPI schemas for calendar/task CRUD endpoints
- [ ] BP-016: Google Calendar API research
- [ ] BP-001: `calendarSlice`, `projectSlice`, `recurrenceStore` TypeScript interfaces

### Block 0E: Dashboard & Conflict Agent
- [ ] BP-002: Dashboard component props and state machines
- [ ] BP-006: Conflict detection UX (all 8 states)
- [ ] BP-003: DDL for `notifications`
- [ ] BP-001: `dashboardSlice`, `notificationSlice`, `triageSlice` TypeScript interfaces

### Block 0F: Monetization & Polish
- [ ] BP-007: First-time user onboarding flow
- [ ] BP-011: Free vs. Pro feature matrix
- [ ] BP-017: Stripe integration details
- [ ] BP-009: CSP nonce implementation
- [ ] BP-005: Error taxonomy (complete)


## Research Insights from April 2026 (Applied to This Backlog)

The following findings from current research have been incorporated into the backlog items above:

1. **AI-Native Services business model requires domain credibility**: "In traditional SaaS, you're selling a product. In AI-native services, you're selling yourself"[reference:16]. For Trevor, the "domain expertise" is the local-first, privacy-respecting AI assistant — this should be the center of all marketing and UX design.

2. **Agent orchestration complexity is the #1 scaling challenge**: "The coordination overhead between agents becomes the bottleneck, not the individual model calls"[reference:17]. This validates the Intent Dispatcher design and suggests that multi-agent complexity should be deferred as planned (Phase 2+).

3. **"Mirage PMF" is a known failure mode**: Revenue growth powered by human labor rather than AI leverage[reference:18]. For Trevor, this means the conflict detection must be fully automated, not human-curated.

4. **Cost management is now a dedicated discipline**: "Tokenomics and the underlying AI cost model" are central to AI business viability[reference:19]. The free-tier local-model strategy is structurally superior to any cloud-dependent competitor at scale.

5. **MCP security is a live crisis**: As of April 2026, ~7,000 internet-exposed MCP servers were found, many with no authorization[reference:20]. MCPSec L2 being mandatory (ADR_096) is correct and non-negotiable.

6. **EU AI Act deadlines are confirmed and fixed**: December 2, 2027 (stand-alone high-risk) and August 2, 2028 (embedded high-risk) are now firm[reference:21]. This provides 18+ months of runway before documentation needs to begin.

7. **Solo founders with AI tools are hitting $10K-$50K MRR**: The path is validated[reference:22]. The waitlist-before-product strategy is recommended for AI products specifically[reference:23].

8. **The AI-native stack has 5 layers**: Model, orchestration, tooling, workflow, interface[reference:24]. Trevor's blueprint maps cleanly: Domain C covers model+orchestration, Domains B+D cover tooling+interface, Domain F covers workflow.


## How to Use This Backlog in Practice

### Per Session Workflow:
1. Open this document. Check which items are marked 🔴 NOT STARTED.
2. Select the highest-priority item that blocks the next Phase block you intend to work on.
3. Inject this backlog + relevant planning docs into a fresh AI session.
4. Instruct: "Research and decide item BP-0XX. Produce a standalone markdown spec. Do not write production code."
5. Review the output. If satisfactory, mark the item 🟢 RESOLVED and file the output doc.
6. When all items for a block are RESOLVED, that block is cleared for code execution.

### Parallelization:
- Items with no cross-dependencies can be researched in parallel across different AI platforms.
- Items in Category A (BP-001 through BP-005) are largely sequential — types inform components, components inform flows.
- Items in Category C and D can be parallelized freely.

### Versioning:
- This backlog should be versioned. Each time an item is resolved, bump the minor version.
- Major version bump when all Phase 0 items are resolved (ready to execute).


## Summary Statistics

| Category | Total Items | P0 | P1 | P2 | P3 |
|----------|------------|----|----|----|-----|
| A: Implementation Specs | 5 | 5 | 0 | 0 | 0 |
| B: Undefined Flows | 5 | 3 | 1 | 1 | 0 |
| C: Business Logic | 4 | 1 | 3 | 0 | 0 |
| D: Research Topics | 4 | 3 | 0 | 1 | 0 |
| E: Pipeline | 2 | 1 | 1 | 0 | 0 |
| **TOTAL** | **20** | **13** | **5** | **2** | **0** |

**Current state**: 0 of 20 resolved. All Phase 0 blocks are blocked on at least one P0 item.

**Recommended attack sequence** (respects dependencies):
1. BP-001 (Zustand types) → unblocks everything
2. BP-015 (Local model benchmarks) + BP-016 (Calendar API research) → parallel
3. BP-003 (Database DDL) → after BP-001
4. BP-004 (OpenAPI schemas) → after BP-003
5. BP-005 (Error taxonomy) → after BP-001
6. BP-002 (Component props) → after BP-001
7. BP-006 (Conflict UX) + BP-007 (Onboarding) + BP-008 (Tool-calling UX) → parallel, after BP-002
8. BP-011 (Tier matrix) + BP-017 (Stripe integration) → parallel
9. BP-009 (CSP implementation) + BP-012 (Model lifecycle) + BP-013 (Proactive config) → parallel
10. BP-019 (START-HERE) + BP-020 (Checklist, done here) + BP-018 (i18n) → parallel
11. BP-010 (Offline UI) + BP-014 (Notifications) → before Phase 2

---

*This backlog is a living document. Update it after every planning session. An AI agent should never guess when it can check this file first.*