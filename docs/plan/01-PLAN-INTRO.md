# INTRO

## How to Read This Document

This document is the single source of truth for project rules, technology versions, performance budgets, and design patterns. Everything in it is concrete and must be followed exactly by any AI agent or human contributor.

**Pattern tags** (like `@OptimisticMutation`) are short labels for recurring front-end behaviors. They are defined once in the Glossary and then used in component descriptions for brevity.

**Domain shortcuts** (like `ORG scoping`) are terms defined at the start of the relevant section that condense frequently referenced architectural patterns.

The document is organized by topic. Use the table of contents or simply scroll to the area you need.

---

## Pattern Tag Glossary

Tags are capitalised, self-documenting abbreviations. They appear in component tables to indicate which patterns and behaviours a component uses.

- **@MotionGuard**: Animates only `transform` and `opacity`; respects `prefers-reduced-motion` (instant transition).
- **@AnimatePresence**: Page-level enter/exit transition (React AnimatePresence wrapper).
- **@Spring**: Spring animation with tension ≥300 and damping ≥30.
- **@StaggerChildren**: Staggered animation for child elements (max 3 children).
- **@OpacityFade**: Opacity fade ≤150ms.
- **@Static**: No animation (static element).
- **@PopLayout**: Pop-in layout animation for new elements.
- **@OptimisticMutation**: Immediate UI update, revert on failure; pending state (opacity 0.5, italic, pulse); 5-second undo for deletes.
- **@VirtualizeList**: Virtualized list to handle large data sets.
- **@ChatCache**: AI responses cached indefinitely (staleTime:Infinity).
- **@InlineEdit**: Inline editing triggered by click, with debounced auto-save.
- **@InfiniteScroll**: Infinite scroll / load-more pattern.
- **@DebounceAutoSave**: 300ms debounce, auto-save on edits.
- **@SSEStream**: Server-Sent Events for real‑time data streaming.
- **@TieredMemory**: Memory management with retention tiers (working, episodic, semantic).
- **@PromptCaching**: Uses prompt caching for LLM calls to reduce latency/cost.
- **@TriageColor**: Color-coded triage indicators.
- **@TimezoneAware**: All times displayed in user’s timezone; uses ZonedDateTime.
- **@KeyboardShortcuts**: Keyboard shortcuts for accessibility and power users.
- **@HoverPrefetch**: Hover triggers data prefetch (200ms debounce).
- **@Upload**: File upload logic.
- **@FileHandling**: File manipulation (read, write, copy).
- **@SandboxIframe**: Runs content inside a sandboxed iframe (e.g., Monaco editor).
- **@A2AFlow**: Agent-to-agent communication flow.
- **@WorkflowExecution**: Workflow execution display and state machine.
- **@Recurring**: Recurring event logic (rschedule + Temporal adapter).

**Spec/Architecture tags** (for documentation, not runtime):
- **@SpecTemplate**: Document follows SPEC-TEMPLATE.md.
- **@ComponentTiering**: Tier 1 (standalone spec), Tier 2 (grouped module), Tier 3 (design system only).
- **@CrossCuttingSpec**: Specification for a cross‑cutting service.
- **@FlowContract**: Contract for a user‑facing flow.
- **@APIContract**: OpenAPI 3.1 contract.
- **@EventContract**: Event and webhook contract.
- **@TestContract**: Testing contract and coverage targets.
- **@OpsRunbook**: Operational runbook.
- **@FeatureFlag**: Feature flag usage and rollout.
- **@CostControl**: Cost tracking and budgeting.
- **@MigrationStrategy**: Database migration strategy (expand‑contract, etc.).
- **@Observability**: Observability instrumentation.
- **@SecurityMatrix**: Security control mapping.
- **@MCPSecurity**: MCP security enforcement.
- **@Passkeys**: Passkey/WebAuthn integration.
- **@TauriDesktop**: Tauri desktop application capabilities.
- **@MobileNotif**: Mobile push notifications.
- **@AIGuardrails**: AI guardrails (input/output/runtime).
- **@SSRFPrevention**: Server‑side request forgery protection.
- **@PrivacyAI**: AI privacy controls (training opt‑out, differential privacy).
- **@StripeBilling**: Stripe billing integration.
- **@ComplianceCode**: Compliance automation (SOC2, EU AI Act).
- **@YjsLifecycle**: Yjs collaboration lifecycle (garbage collection, undo, snapshots).
- **@NylasV3**: Nylas v3 webhook processing.
- **@OTelGenAI**: OpenTelemetry GenAI instrumentation.
- **@OfflineFirst**: Offline‑first data patterns (tombstones, idempotency keys).
- **@RealtimeLimits**: Realtime channel and memory limits.
- **@UploadSecurity**: File upload security scanning (ClamAV).
- **@RecurrenceEngine**: Recurrence rule engine.

When you see a tag like `@MotionGuard, @OptimisticMutation` in a component entry, refer back here for the exact expectation.

---

## Domain Pattern Definitions

These terms describe recurring architectural strategies. They are used in rules and specs to avoid repetition.

- **ORG scoping**: Every database row belongs to exactly one organization (`org_id` column). Row‑Level Security (RLS) enforces that users only see their own org’s data.
- **Server‑wins rollback**: On conflict between client and server state, the server state replaces the client state and a rollback event is triggered.
- **Last‑write‑wins (LWW)**: Conflict resolution uses a `uat` (updated‑at) timestamp column; the newest timestamp wins.
- **Idempotency key (IC)**: Every asynchronous operation carries a key composed of `actor_id + monotonic_counter`; enforced unique in the database to prevent duplicate processing.
- **Expand‑contract (EBC)**: Database schema changes are applied in two steps: first add new columns/tables (expand), then remove old ones later (contract), ensuring zero‑downtime.
- **Zero‑downtime (ZDT)**: Deployments and migrations cause no service interruption.
- **Error budget (EB)**: Allowed failure window for an SLO before its availability target is breached.
- **Burn rate (BR)**: How fast the error budget is consumed; triggers alerts.

---

## 1. UI & State Management Rules

These rules apply to all frontend code. Violating a **HARD** rule will block a PR.

### Z‑Index
- (HARD) Toast: 60, Command Palette: 50, Modal: 40, Drawer: 30, Sheet: 20.

### Zustand State
- (HARD) Always use `useShallow` when selecting objects from a Zustand store to avoid unnecessary re‑renders.
- (HARD) Never use `useState` for global UI state; it belongs in Zustand slices.
- (HARD) Slices cannot import each other; cross‑slice access must use `get()` (ZUSTANDCIRCULAR rule).

### React Compiler & Memoization
- (HARD) React Compiler enabled globally; no manual `useMemo`/`useCallback`/`React.memo`.
- (HARD) Exception: React Hook Form components need the `"use no memo"` directive.
- (MED) Zustand `persist` wrappers must use conditional rendering, not Suspense.

#### React Compiler Production Readiness Assessment (April 2026)
- **Status**: React Compiler v1.0 released October 7, 2025 - STABLE release
- **Production Validation**: Battle-tested on major apps at Meta (e.g., Meta Quest Store)
- **Performance Results**: Up to 12% improvement in initial loads and cross-page navigations; some interactions >2.5× faster; memory usage stays neutral
- **Compatibility**: React 17 and up; safe by design (skips optimization if cannot safely optimize rather than breaking code)
- **Known Issues**: Some third-party library hooks return new objects on every render, breaking memoization chains (e.g., TanStack Query's useMutation(), Material UI's useTheme(), React Router's useLocation())
- **Recommendation**: Only compile own source code with React Compiler; do NOT compile 3rd-party code. Library authors have full control over whether to use React Compiler or manually optimize.

### UI Patterns
- (HARD) Empty states always render an `EmptyState` component with a call‑to‑action; never show a blank screen.
- (HARD) Loading states: skeleton/shimmer if load time <2 seconds; spinner if >2 seconds.
- (HARD) Error states: display a retry button and human‑readable message.
- (HARD) Offline state: show a connectivity indicator; queue actions for later.
- (HARD) Optimistic mutations: pending = opacity 0.5 + italic + pulse; 5‑second undo for delete operations.
- (HARD) Stagger no more than 3 children in any animation.
- (HARD) Only `transform` and `opacity` may be animated. No layout property animations.
- (HARD) Respect `prefers-reduced-motion`; if active, all animations become instant.
- (HARD) Avoid animations longer than 5 seconds (WCAG 2.2.2).
- (MED) Filter updates should be wrapped in `useTransition` to keep the UI responsive.

### Drag & Drop
- (HARD) All drag‑and‑drop uses a centralised `dnd‑kit` facade (never import directly from the library elsewhere).
- (HARD) `DragOverlay` must be used to render a copy of the dragged element, never drag the original DOM node.
- (HARD) Keyboard alternatives must be provided for all drag operations (WCAG 2.5.7).

### Editor / Monaco
- (HARD) Monaco Editor is sandboxed in a separate iframe with its own CSP.
- (HARD) Monaco is lazy‑loaded (React.lazy + Suspense + skeleton), never in the initial bundle.

### Storage
- (HARD) `localStorage` usage limited to ≤3 MB; implement an eviction priority.
- (HARD) Zustand `persist` must include version, migrate, and partialize functions.

### URL State
- (HARD) More than 3 URL search params must use `useQueryStates` (not multiple `useQueryState` calls).

### Design Tokens
- (HARD) No hardcoded hex/RGB colours; reference OKLCH CSS custom properties only.

### Accessibility (All UI)
- (HARD) WCAG 2.2 AA everywhere, including keyboard navigation, screen reader announcements, and focus order.
- (HARD) Canvas‑only or purely visual components must have an alternative text representation.
- (MED) Use `react-helmet-async` for per‑route meta tags.

---

## 2. Security Rules (S1 – S28)

All security rules are **HARD**. Violating any of them will block a deployment.

- **S1**: Never use `dangerouslySetInnerHTML`; all user‑generated HTML passes through `SanitizedHTML` with the appropriate profile (STRICT, RICH, or EMAIL).
- **S2**: Supabase storage access only via the `StorageService` wrapper; never call the Supabase client directly.
- **S3**: Nylas API calls happen only from the FastAPI backend; frontend never talks to Nylas directly.
- **S4**: Only supabase‑js is allowed in the browser; Prisma must never be imported in frontend code.
- **S5**: Every Prisma schema change must be checked for RLS impact; RLS policies must be updated accordingly.
- **S6**: Global Content‑Security‑Policy enforced in production (nonce‑based, `strict-dynamic`).
- **S7**: `'unsafe-eval'` is allowed only for Monaco Editor and Babel, and only within their sandboxed iframes (scoped to their nonces).
- **S8**: JWT is stored only in an httpOnly cookie; never put it in Zustand or `localStorage`.
- **S9**: All API calls under `/v1/*` must go through the centralised `api.ts` client.
- **S10**: DOMPurify ≥3.4.0 is mandatory; an automated CVE audit for DOMPurify runs in CI.
- **S11**: CSP nonce must be cryptographically random per request; nonce strategy with `strict-dynamic` is required.
- **S12**: LiveKit tokens are scoped to specific rooms and capabilities; RBAC is enforced on token generation.
- **S13**: Role‑Based Access Control is applied to all resources; no ad‑hoc permission checks.
- **S14**: Rate limiting is enforced per user and per organization.
- **S15**: Organization deletion cascades correctly; notify admins 7 days before permanent deletion.
- **S16**: Agent‑driven UI may only use components from the trusted GenUI catalog; no arbitrary component rendering.
- **S17**: Yjs collaboration is opt‑in per document type; separate documents for different collaboration scopes.
- **S18**: AI cost hard cap is enforced at the LLM proxy level; frontend also has a cost budget notification.
- **S19**: MCP tool registration requires admin approval; every invocation is logged.
- **S20**: AI cost thresholds trigger alerts and rate limits (RATE_LIMITED error) to enforce budgets.
- **S21**: OpenAPI 3.1 is the single source of truth; Orval generates TypeScript types from it; Schemathesis checks contract compliance in CI.
- **S22**: (GRDL03) All pgvector‑retrieved chunks pass through the guardrails input layer before being injected into a prompt.
- **S23**: (SECREC01) Failure of automated secret rotation is treated as a P1 incident; all rotations are logged as SOC2 evidence.
- **S24**: (GRYPEREPLACE) Use Grype (not Trivy) for Docker image scanning; scanners must be isolated from CI credentials.
- **S25**: (AUTHHOOK01) The Supabase `supabase_auth_admin` role must have SELECT grants on `user_roles`, `org_members`, and `role_permissions`; verified by pgTAP after each migration.
- **S26**: (SENTRY01) Four Sentry projects; before sending any event, PII is stripped; Session Replay masks all text.
- **S27**: (CLAMAVPROD) ClamAV v1.4.x runs as a sidecar in production; freshclam updates hourly; do not cache scan results.
- **S28**: (DPPROFILES) Three DOMPurify profiles: STRICT (no SVG), RICH (allowed div/span), EMAIL (links and images); test matrix ensures XSS prevention.

---

## 3. Architecture Rules

These define how services interact, which libraries to use, and development boundaries.

### Backend / API
- (HARD) All AI calls must go through the LiteLLM proxy.
- (HARD) Prisma client never runs in the browser.
- (HARD) Nylas API access is only from FastAPI.
- (HARD) Vercel Edge Functions cannot connect to a database directly; use Vercel Serverless (300s) with Neon serverless driver, or route through FastAPI.
- (HARD) `/v1/*` endpoints follow OpenAPI 3.1 contract; Schemathesis blocks merge on drift.
- (HARD) PostgreSQL Row‑Level Security (RLS) is enabled on all tables that contain tenant data.
- (MED) Supabase Realtime channels are limited to 100 total connections and 20 per user; memory alert at 40 MB per channel.

### Frontend
- (HARD) Vite SPA only; no Next.js (ADR_001).
- (HARD) Zustand v5 for global state (ADR_003).
- (HARD) react‑big‑calendar pinned to ^1.19.4 for React 19 compatibility.
- (HARD) dnd‑kit is the primary DnD library; no migration to PragmaticDnD (ADR_085).
- (HARD) `react-helmet-async` for document head.
- (HARD) Use `Temporal.ZonedDateTime` for all calendar events (never `PlainDateTime`); rschedule + @rschedule/temporal‑date‑adapter replaces rrule.js on the frontend (ADR_109).
- (HARD) Tremor v3.18.x for charting (ADR_105).
- (HARD) OKLCH‑based design tokens; no hardcoded colours.

### Collaboration & Real‑time
- (HARD) Y‑Sweet self‑hosted (Jamsocket shutdown); Docker deployment, 50 MB document limit, GC enabled, undo truncated to last 5 snapshots.
- (HARD) LiveKit Agents v2.0 only; semantic turn detection mandatory.
- (MED) Yjs collaboration is opt‑in per document; disconnect cleanup ensures channel unsubscription.

### Data & Offline
- (HARD) Offline‑first pattern: soft deletes via `deleted_at` column (nullable millisecond timestamp); all primary keys are ULIDs.
- (HARD) Every asynchronous operation is idempotent: key = `actor_id` + monotonic counter.
- (HARD) PowerSync is the primary offline sync mechanism (Phase 2); bucket YAML rules per orgId.
- (HARD) Supabase Realtime payload caps: Broadcast max 256 KB – 3 MB, Postgres Changes max 1 MB.

### CI / Tooling
- (HARD) Orval ≥8.2.0; generate TypeScript types from OpenAPI; never run on untrusted specs.
- (HARD) LiteLLM ≥1.83.7 with cosign verification.
- (HARD) Grype (not Trivy) for Docker scanning; scanners isolated from CI credential store.
- (HARD) TypeScript `tsc --erasableSyntaxOnly --noEmit` gate in CI; ban TypeScript enums.
- (HARD) MSW handlers are generated from the OpenAPI spec via `openapi-backend` for testing.

---

## 4. AI & Model Rules

These control which models are used, how they are secured, and how their performance is evaluated.

### Model Selection & Routing
- (HARD) Default orchestrator: Gemma 4 E2B (local, native tool calling). Fallback: Qwen3.5 4B. Cloud models are premium only.
- (HARD) Free‑tier users are restricted to local models only; AI must never make cloud API calls for them.
- (HARD) Claude Sonnet 4.6 is the default cloud model when authorised; Opus 4.7 for complex tasks.
- (HARD) Haiku 4.5 must never be used in agentic contexts (poor injection guard).
- (HARD) All new agents created after May 1, 2026 must use `claude-sonnet-4-6` or `opus-4-7` model IDs; legacy IDs cleaned by June 1, 2026.
- (HARD) OpenAI Assistants and ChatCompletions APIs must be migrated to the Responses API by August 26, 2026.

### Guardrails (3‑layer, all HARD)
- **Input**: PII detection, jailbreak detection, toxicity screening.
- **Output**: Hallucination detection, safety validation, schema enforcement.
- **Runtime**: Tool authorization and cost threshold checks.
- All guardrail decisions are logged to `audit_logs`.

### Cost & Budgets (all HARD)
- Synchronous pre‑call budget check enforced at the LiteLLM proxy; if budget exceeded, return 429 and a cost limit banner.
- Multi‑level budgets: org, team, user, model.
- Alert thresholds: at 15% remaining notify admin; at 5% notify admin + engineering; at 0% hard stop.
- `ai_cost_log` is a TimescaleDB hypertable; x‑litellm‑tags carry org_id, user_id, feature.

### Evaluation (HARD in CI)
- DeepEval for AI evaluation; RAGAS alongside for RAG.
- CI gates:
  - Tool‑calling precision ≥90% (block if <85%)
  - Hallucination rate ≤2%
  - Accuracy ≥ base‑2%
  - Latency ≤ base+10% (warn), >20% block
  - Token usage ≤ base+15% (warn)
- All evaluator LLM‑as‑judge calls go through the LiteLLM proxy for cost tracking.

### Caching & Context
- (HARD) Prompt caching enabled; static content cached first.
- (HARD) Chat cache hit rate target >70%, RAG cache hit rate >90%.
- (HARD) Contextual Retrieval activated only when corpus >50K chunks, precision improvement >15%, and cache hit rate >60%.

### Local Model Lifecycle
- All local models must be registered in the Model Trust Registry before use in agentic workflows.
- Model quantisation: default GGUF Q4_K_M (<4.5 GB RAM); evaluated weekly for tool‑calling pass rate.
- The Verifier cascade (Phi‑4‑mini‑reasoning) checks reasoning, schema validity, and budget before an action is committed (Phase 1).

---

## 5. Data & Offline Rules

- (HARD) Every table that stores user data must have an `org_id` column and an active RLS policy.
- (HARD) Soft deletes via `deleted_at` (nullable timestamp with millisecond precision) are mandatory for offline sync.
- (HARD) Primary keys are ULIDs.
- (HARD) Idempotency keys for all async operations: `actor_id` + monotonic counter, enforced by unique constraint.
- (HARD) Supabase Realtime limits: 100 channels per connection, 20 self‑service channels; payloads capped.
- (HARD) PowerSync bucket rules are defined per org via YAML; sync rules scoped to JWT orgId claim.
- (MED) Offline queue uses an outbox pattern initially; full PowerSync bidirectional sync in Phase 2.

---

## 6. Observability & SLOs

- (HARD) OpenTelemetry v1.40 with GenAI attributes mandatory for all AI interactions; `OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai`.
- (HARD) PII redacted at the collector level before traces are exported.
- **Service Level Objectives**:
  - TTFT (time to first token) ≤ 2 seconds at p95
  - Availability 99.9%
  - RAG response time ≤ 500 ms at p95
  - LCP ≤ 800 ms at p75
  - INP ≤ 200 ms
- (HARD) Multi‑burn‑rate alerting: P1 incidents fire if burn rate > 2% in 1 hour + 5 minutes; P2 fires at 6‑hour window; P3 at 3‑day window.
- (HARD) Error budget actions: at 50% consumed – notify; at 80% – feature freeze; at 100% – declare incident.

---

## 7. Performance Budgets & Thresholds

These are concrete numbers that must be respected in every build.

### Core Web Vitals
- LCP (Largest Contentful Paint): ≤800 ms (p75)
- INP (Interaction to Next Paint): ≤200 ms
- CLS (Cumulative Layout Shift): ≤0.1

### JavaScript Bundle Budgets (initial / lazy)
- Initial chunk: ≤150 KB
- Lazy chunk: ≤800 KB
- Monaco editor chunk: ≤2 MB
- React Flow chunk: ≤200 KB
- react‑big‑calendar chunk: ≤150 KB
- Yjs chunk: ≤300 KB
- Tremor chunk: ≤15 KB
- AI SDK chunk: ≤10 KB
- PowerSync chunk: ≤50 KB
- Temporal polyfill chunk: ≤20 KB (conditional, Safari only)
- rschedule chunk: ≤15 KB
- SimpleWebAuthn chunk: ≤12 KB (lazy, auth routes only)
- PostHog chunk: ≤19 KB (shared, feature flagged)

### Caching & Timing
- Search debounce: 300 ms
- Hover prefetch delay: 200 ms
- SSE heartbeat: 15–20 seconds
- SSE reconnect: 1s, 2s, 4s, 8s, max 30s (max 3 retries)
- Org switch cache clear + reconnect: <2 seconds
- Undo window for deletes: 5 seconds
- Stagger animation: max 3 children
- Spring stiffness ≥300, damping ≥30

### Cost & Rate Limits
- AI cost alerts: at 15% remaining → admin; 5% → admin+engineers; 0% → hard stop with 429.
- Cost forecast accuracy target: ±10%
- Stripe markup: 30%
- Platform rate limit: 1000 req/min per org
- Nylas webhook ACK timeout: 10 seconds
- Nylas auto‑disable: after 95% failure rate over 72 hours

### Operational Thresholds
- P0 incident response: immediate
- P0 update cadence: every 15 minutes
- Postmortem due: 48 hours
- Feature flag rollout: off → internal(2d) → beta(3d) → 5/20/50%(2d each) → 100%
- Kill switch: revert to 0% in under 5 minutes
- Secret rotation failure: P1 incident, manual rotation within 1 hour

---

## 8. Technology Version Pins

Exact versions or constraints that must be used in all environments.

- **TypeScript**: 6.0 in production; 7.0 beta (tsgo) evaluated in CI

### TypeScript 7.0 (tsgo) Beta Assessment (April 2026)

**Status**: TypeScript 7.0 Beta released via `@typescript/native-preview@beta` package. Stable release targeted within 2 months from beta announcement (April 2026 → June 2026).

**Beta Stability**:
- tsgo executable has identical behavior to tsc from TypeScript 6.0, just faster
- Editor support via TypeScript Native Preview extension for VS Code is described as "rock-solid" and "widely used by many teams for months"
- TypeScript can run side-by-side with TypeScript 6.0 via `@typescript/typescript6` package with `tsc6` entry point
- Stable programmatic API not available until TypeScript 7.1 or later
- Preview focuses on type checking (--noEmit mode); full emit, watch mode, build mode, plugin API still in development (landing in 2026)

**Performance vs tsc 6.0**:
- Benchmarks on microsoft/TypeScript repository (~400k lines, Apple M1 Pro):
  - Total time: 10.8x faster (tsc 0.284s → tsgo 0.026s)
  - Type checking: 30x faster (tsc 0.103s → tsgo 0.003s)
  - Parse: 8.9x faster (tsc 0.071s → tsgo 0.008s)
  - Bind: 6.4x faster (tsc 0.058s → tsgo 0.009s)
  - Peak memory: 2.9x less (tsc 68MB → tsgo 23MB)
- Scaling by project size:
  - < 10k lines: 4x speedup
  - 10k-100k lines: 6x speedup
  - 100k-500k lines: 8.8x speedup
  - 500k+ lines (monorepo): ~10x speedup

**Migration Complexity from tsc 6.0**:
- **Installation**: `npm install -D @typescript/native-preview@beta`
- **Configuration**: No changes required - tsgo accepts same flags as tsc and reads tsconfig.json as-is
- **Adoption Strategy**: Run both tsc and tsgo in CI pipeline during validation period (2-4 weeks). When tsgo produces identical results consistently, switch CI gate to tsgo
- **Breaking Changes**: TypeScript 6.0 deprecations become hard removals in 7.0 (target, moduleResolution, baseUrl, esModuleInterop, outFile, module values, alwaysStrict, downlevelIteration, legacy module keyword, asserts keyword, /// <reference no-default-lib>)
- **Behavioral Changes**: Type ordering in .d.ts output, inference changes from this-less optimization, silent moduleResolution default shift, "use strict" always emitted, esModuleInterop emit changes
- **Escape Hatch**: `ignoreDeprecations` mechanism available to temporarily silence deprecation warnings during migration
- **React**: 19.2.5; React 20 evaluated Q2 2026
- **Vite**: 8.0.0
- **Zustand**: 5.0.12
- **TanStack Query**: 5.100.1
- **Motion (Framer)**: 12.38.0 (import from `motion/react`)
- **Tailwind CSS**: 4.2.2
- **Prisma**: 7.8.0 (pgbouncer=true)
- **dnd‑kit**: 6.3.1 (community standard; no migration)
- **Node**: 24.15.0 LTS Krypton
- **Python**: 3.12
- **FastAPI**: 0.136.1
- **react‑big‑calendar**: ^1.19.4 (React 19 compatible)
- **Yjs**: 13.6.21
- **DOMPurify**: ≥3.4.0
- **nuqs**: ^2.5
- **react‑helmet‑async**: latest
- **LiveKit Agents**: ≥2.0.0 ONLY
- **LiveKit Server SDK**: ≥1.0.0
- **markmap**: latest
- **react‑resizable**: ^3.1.3
- **@ai‑sdk/react**: ^2.0 (Vercel AI SDK v6)
- **@tremor/react**: ^3.18
- **@stripe/ai‑sdk**: latest
- **@stripe/agent‑toolkit**: latest
- **@powersync/web**: latest
- **litellm**: >=1.83.7 (cosign + Grype verified)
- **orval**: >=8.2.0
- **@anthropic/mcp‑inspector**: >=0.14.1 (dev only)
- **tsgo**: 7.0 beta
- **temporal‑polyfill**: ^0.3.2 (~20KB)
- **pgvectorscale**: 0.4.0 (DiskANN)
- **@xyflow/react**: 12.10.2
- **OTel**: v1.40.0 + experimental GenAI
- **prisma‑next**: GA June‑July 2026 (Postgres); Phase 3 evaluation
- **rschedule**: latest
- **@rschedule/temporal‑date‑adapter**: latest
- **SimpleWebAuthn**: latest
- **deepeval**: latest
- **ragas**: >=0.2
- **openapi‑backend**: latest
- **pg_textsearch**: latest
- **basejump‑supabase_test_helpers**: latest
- **pyclamd**: latest

---

## 9. Application Routes

```
/login, /authlogin, /authsignup, /authcallback, /authreset, /authverify
/dashboard
/chat, /chat/:thread (hover prefetch)
/workflows, /workflow/:id
/projects, /project/:id, /triage
/calendar
/email
/contacts
/conference
/translation
/news
/documents
/research
/media
/budget
/settings, /settings/:section
/analytics
/auditlog
/agentstudio, /agentstudio/:agent, /agentplayground
```

---

## 10. Component Inventory

Component specifications are now maintained in dedicated files by module. This is the master index:

- **Shell**: `04-COMP-SHELL.md` (11 components)
- **Dashboard**: `04-COMP-DASHBOARD.md` (8 components)
- **Chat**: `04-COMP-CHAT.md` (22 components)
- **Workflow**: `04-COMP-WORKFLOW.md` (8 components)
- **Projects**: `04-COMP-PROJECTS.md` (24 components)
- **Calendar**: `04-COMP-CALENDAR.md` (11 components)
- **Email**: `04-COMP-EMAIL.md` (12 components)
- **Contacts**: `04-COMP-CONTACTS.md` (11 components)
- **Conference**: `04-COMP-CONFERENCE.md` (7 components)
- **Translation**: `04-COMP-TRANSLATION.md` (6 components)
- **News**: `04-COMP-NEWS.md` (6 components)
- **Documents**: `04-COMP-DOCUMENTS.md` (9 components)
- **Research**: `04-COMP-RESEARCH.md` (6 components)
- **Media**: `04-COMP-MEDIA.md` (6 components)
- **Budget**: `04-COMP-BUDGET.md` (7 components)
- **Settings**: `04-COMP-SETTINGS.md` (12 components)
- **Platform**: `04-COMP-PLATFORM.md` (11 components)

Cross‑cutting service components are defined in `05-XCT-SERVICES.md` (17 components). Each component listing includes the pattern tags and dependencies it follows.

---

## 11. Cross‑Cutting Services

These service implementations are described in `05-XCT-SERVICES.md`. They expose specific contracts:

- Motion service: ensures `transform`/`opacity` only, reduced‑motion aware.
- Optimistic mutation service: pending/rollback/undo logic.
- Realtime service: SSE + Supabase Realtime with auth and memory monitoring.
- Search service: debounced, URL‑synced, with filter syntax.
- Offline service: outbox pattern, tombstone management, idempotency keys.
- Auth/Org service: JWT handling, org switching with cache + RT cleanup.
- API contract codegen: OpenAPI → TypeScript types, hooks, MSW handlers, Schemathesis gate.
- Nylas webhook handler: upsert‑first, 10‑second ack, async queue.
- OTel GenAI instrumenter: standardised attributes, PII redaction.
- Offline sync engine: tombstones, ULIDs, conflict resolution.
- Realtime channel monitor: enforce channel/memory limits.
- Upload security scanner: ClamAV sidecar, chunked scanning.
- Recurrence engine: rschedule + Temporal adapter, DST handling.
- AI guardrails engine: 3‑layer input/output/runtime, full audit logging.
- SSRF prevention middleware: DNS validation, IPv4 allow‑list, redirect blocking.
- Stripe token meter: usage recording, 30% markup, reconciliation.
- Yjs lifecycle manager: GC, undo, snapshots, 50 MB limit.

---

## 12. Architecture Decisions (ADRs)

All architectural decisions are recorded in `01-PLAN-ADR-INDEX.md`. That index lists 126 ADRs, each with domain, summary, and status. When you need to know whether a design choice has already been made, consult that file.

---

## 13. Task List

The full task breakdown for Phase 0 and Phase 1 is maintained in `TASKS.md`. Status is tracked there. For an overview of milestones and deliverables, see `01-PLAN-MILESTONES.md`.

---

## 14. Pre‑Computed Quality Presets

These are named presets for LLM calls, specifying temperature (`temp`), `top_p`, and acceptable variance.

| Preset | Temperature / Top P | Variance |
|--------|---------------------|----------|
| G1 | 0.85 / 0.35 | ±2% |
| G2 | 0.80 / 0.30 | ±5% |
| G3 | 0.82 / 0.32 | ±2% |
| G4 | 0.80 / 0.40 | ±2% |
| G5 | 0.90 / 0.45 | ±2% |
| G6 | 0.85 / 0.45 | ±2% |
| G7 | 0.95 / 0.40 | ±2% |
| G8 | 0.90 / 0.40 | ±2% |

Use these directly when configuring model parameters in agent definitions.

---