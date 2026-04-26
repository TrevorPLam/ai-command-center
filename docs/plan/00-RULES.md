# Unified Rules Register

This document provides a human-readable view of all project rules. For the authoritative source, see [00-RULES.yaml](00-RULES.yaml).

All rules are categorized by domain with severity levels:
- **HARD**: Violations will block a PR or deployment
- **MEDIUM**: Best practices that should be followed

---

## Security Rules (SEC-)

| ID | Severity | Description | Check |
|----|----------|-------------|-------|
| SEC-01 | HARD | Use SanitizedHTML for all user-generated HTML (STRICT, RICH, EMAIL profiles) | lint-rule or manual review |
| SEC-02 | HARD | Supabase storage access only via StorageService wrapper | lint-rule or manual review |
| SEC-03 | HARD | Nylas API calls only from FastAPI backend | lint-rule or manual review |
| SEC-04 | HARD | Only supabase-js allowed in browser; Prisma never in frontend | lint-rule or manual review |
| SEC-05 | HARD | Prisma schema changes must update RLS policies | schema validation |
| SEC-06 | HARD | Global CSP enforced in production (nonce-based, strict-dynamic) | CSP monitoring |
| SEC-07 | HARD | unsafe-eval only for Monaco/Babel in sandboxed iframes | security audit |
| SEC-08 | HARD | JWT stored only in httpOnly cookie, never in Zustand/localStorage | security audit |
| SEC-09 | HARD | All /v1/* API calls through centralized api.ts client | lint-rule or manual review |
| SEC-10 | HARD | DOMPurify >=3.4.0 mandatory; automated CVE audit in CI | CI version check |
| SEC-11 | HARD | CSP nonce cryptographically random per request; strict-dynamic | security audit |
| SEC-12 | HARD | LiveKit tokens scoped to rooms and capabilities; RBAC enforced | security audit |
| SEC-13 | HARD | RBAC applied to all resources; no ad-hoc permission checks | security audit |
| SEC-14 | HARD | Rate limiting enforced per user and organization | monitoring alert |
| SEC-15 | HARD | Organization deletion cascades; notify admins 7 days before | workflow validation |
| SEC-16 | HARD | Agent-driven UI only uses trusted GenUI catalog components | security audit |
| SEC-17 | HARD | Yjs collaboration opt-in per document type | configuration validation |
| SEC-18 | HARD | AI cost hard cap enforced at LLM proxy level | runtime validation |
| SEC-19 | HARD | MCP tool registration requires admin approval; all logged | workflow validation |
| SEC-20 | HARD | AI cost thresholds trigger alerts and rate limits | monitoring alert |
| SEC-21 | HARD | OpenAPI 3.1 single source of truth; Orval generates types | CI gate configuration |
| SEC-22 | HARD | pgvector-retrieved chunks pass guardrails input layer | runtime validation |
| SEC-23 | HARD | Secret rotation failure treated as P1 incident; SOC2 evidence | incident response validation |
| SEC-24 | HARD | Use Grype (not Trivy) for Docker scanning; credential isolation | CI workflow validation |
| SEC-25 | HARD | Supabase auth_admin role requires SELECT grants on user tables | database permission validation |
| SEC-26 | HARD | Sentry projects strip PII; Session Replay masks text | security audit |
| SEC-27 | HARD | ClamAV v1.4.x sidecar in production; freshclam hourly | CI version check |
| SEC-28 | HARD | Three DOMPurify profiles; test matrix ensures XSS prevention | test suite validation |

---

## Backend Rules (BE-)

| ID | Severity | Description | Check |
|----|----------|-------------|-------|
| BE-01 | HARD | All AI calls must go through the LiteLLM proxy | lint-rule or manual review |
| BE-02 | HARD | Prisma client never runs in the browser | lint-rule or manual review |
| BE-03 | HARD | Nylas API access is only from FastAPI | lint-rule or manual review |
| BE-04 | HARD | Vercel Edge Functions cannot connect to a database directly; use Vercel Serverless (300s) with Neon serverless driver, or route through FastAPI | lint-rule or manual review |
| BE-05 | HARD | /v1/* endpoints follow OpenAPI 3.1 contract; Schemathesis blocks merge on drift | Schemathesis CI gate |
| BE-06 | HARD | PostgreSQL Row-Level Security (RLS) is enabled on all tables that contain tenant data | pgTAP test suite |
| BE-07 | MEDIUM | Supabase Realtime channels are limited to 100 total connections and 20 per user; memory alert at 40 MB per channel | monitoring alert |
| BE-08 | HARD | Offline-first pattern: soft deletes via deleted_at column (nullable millisecond timestamp); all primary keys are ULIDs | schema validation |
| BE-09 | HARD | Every asynchronous operation is idempotent: key = actor_id + monotonic counter | schema validation |
| BE-10 | HARD | PowerSync is the primary offline sync mechanism (Phase 2); bucket YAML rules per orgId | manual review |
| BE-11 | HARD | Supabase Realtime payload caps: Broadcast max 256 KB - 3 MB, Postgres Changes max 1 MB | monitoring alert |
| BE-12 | HARD | Orval >=8.2.0; generate TypeScript types from OpenAPI; never run on untrusted specs | CI version check |
| BE-13 | HARD | LiteLLM >=1.83.7 with cosign verification | CI version check |
| BE-14 | HARD | Grype (not Trivy) for Docker scanning; scanners isolated from CI credential store | CI workflow validation |
| BE-15 | HARD | TypeScript tsc --erasableSyntaxOnly --noEmit gate in CI; ban TypeScript enums | TypeScript CI gate |
| BE-16 | HARD | MSW handlers are generated from the OpenAPI spec via openapi-backend for testing | test generation validation |
| BE-17 | HARD | Every table that stores user data must have an org_id column and an active RLS policy | pgTAP test suite |
| BE-18 | HARD | All tables must have a created_at timestamp column | schema validation |

---

## Collaboration Rules (COLL-)

| ID | Severity | Description | Check |
|----|----------|-------------|-------|
| COLL-01 | HARD | Y-Sweet self-hosted (Jamsocket shutdown); Docker deployment, 50 MB document limit, GC enabled, undo truncated to last 5 snapshots | configuration validation |
| COLL-02 | HARD | LiveKit Agents v2.0 only; semantic turn detection mandatory | version check |
| COLL-03 | MEDIUM | Yjs collaboration is opt-in per document; disconnect cleanup ensures channel unsubscription | configuration validation |

---

## Frontend Rules (FE-)

| ID | Severity | Description | Check |
|----|----------|-------------|-------|
| FE-01 | HARD | Vite SPA only; no Next.js (ADR_001) | lint-rule or manual review |
| FE-02 | HARD | Zustand v5 for global state (ADR_003) | package.json version check |
| FE-03 | HARD | react-big-calendar pinned to ^1.19.4 for React 19 compatibility | package.json version check |
| FE-04 | HARD | dnd-kit is the primary DnD library; no migration to PragmaticDnD (ADR_085) | lint-rule or manual review |
| FE-05 | HARD | react-helmet-async for document head | package.json dependency check |
| FE-06 | HARD | Use Temporal.ZonedDateTime for all calendar events (never PlainDateTime); rschedule + @rschedule/temporal-date-adapter replaces rrule.js on the frontend (ADR_109) | lint-rule or manual review |
| FE-07 | HARD | Tremor v3.18.x for charting (ADR_105) | package.json version check |
| FE-08 | HARD | OKLCH-based design tokens; no hardcoded colours | lint-rule or manual review |
| FE-09 | HARD | Toast: 60, Command Palette: 50, Modal: 40, Drawer: 30, Sheet: 20 (Z-index) | lint-rule or manual review |
| FE-10 | HARD | Always use useShallow when selecting objects from a Zustand store to avoid unnecessary re-renders | lint-rule or manual review |
| FE-11 | HARD | Never use useState for global UI state; it belongs in Zustand slices | lint-rule or manual review |
| FE-12 | HARD | Slices cannot import each other; cross-slice access must use get() (ZUSTANDCIRCULAR rule) | lint-rule or manual review |
| FE-13 | HARD | React Compiler enabled globally; no manual useMemo/useCallback/React.memo | lint-rule or manual review |
| FE-14 | HARD | Exception: React Hook Form components need the "use no memo" directive | lint-rule or manual review |
| FE-15 | MEDIUM | Zustand persist wrappers must use conditional rendering, not Suspense | lint-rule or manual review |
| FE-16 | HARD | Empty states always render an EmptyState component with a call-to-action; never show a blank screen | lint-rule or manual review |
| FE-17 | HARD | Loading states: skeleton/shimmer if load time <2 seconds; spinner if >2 seconds | lint-rule or manual review |
| FE-18 | HARD | Error states: display a retry button and human-readable message | lint-rule or manual review |
| FE-19 | HARD | Offline state: show a connectivity indicator; queue actions for later | lint-rule or manual review |
| FE-20 | HARD | Optimistic mutations: pending = opacity 0.5 + italic + pulse; 5-second undo for delete operations | lint-rule or manual review |
| FE-21 | HARD | Stagger no more than 3 children in any animation | lint-rule or manual review |
| FE-22 | HARD | Only transform and opacity may be animated. No layout property animations | lint-rule or manual review |
| FE-23 | HARD | Respect prefers-reduced-motion; if active, all animations become instant | lint-rule or manual review |
| FE-24 | HARD | Avoid animations longer than 5 seconds (WCAG 2.2.2) | lint-rule or manual review |
| FE-25 | MEDIUM | Filter updates should be wrapped in useTransition to keep the UI responsive | lint-rule or manual review |
| FE-26 | HARD | All drag-and-drop uses a centralised dnd-kit facade (never import directly from the library elsewhere) | lint-rule or manual review |
| FE-27 | HARD | DragOverlay must be used to render a copy of the dragged element, never drag the original DOM node | lint-rule or manual review |
| FE-28 | HARD | Keyboard alternatives must be provided for all drag operations (WCAG 2.5.7) | accessibility audit |
| FE-29 | HARD | Monaco Editor is sandboxed in a separate iframe with its own CSP | security audit |
| FE-30 | HARD | Monaco is lazy-loaded (React.lazy + Suspense + skeleton), never in the initial bundle | bundle size analysis |
| FE-31 | HARD | localStorage usage limited to <=3 MB; implement an eviction priority | lint-rule or manual review |
| FE-32 | HARD | Zustand persist must include version, migrate, and partialize functions | lint-rule or manual review |
| FE-33 | HARD | More than 3 URL search params must use useQueryStates (not multiple useQueryState calls) | lint-rule or manual review |
| FE-34 | HARD | No hardcoded hex/RGB colours; reference OKLCH CSS custom properties only | lint-rule or manual review |
| FE-35 | HARD | WCAG 2.2 AA everywhere, including keyboard navigation, screen reader announcements, and focus order | accessibility audit |
| FE-36 | HARD | Canvas-only or purely visual components must have an alternative text representation | accessibility audit |
| FE-37 | MEDIUM | Use react-helmet-async for per-route meta tags | lint-rule or manual review |

---

## AI Core Rules (AI-)

| ID | Severity | Description | Check |
|----|----------|-------------|-------|
| AI-01 | HARD | Default orchestrator: Gemma 4 E2B (local, native tool calling). Fallback: Qwen3.5 4B. Cloud models are premium only | configuration validation |
| AI-02 | HARD | Free-tier users are restricted to local models only; AI must never make cloud API calls for them | runtime validation |
| AI-03 | HARD | Claude Sonnet 4.6 is the default cloud model when authorised; Opus 4.7 for complex tasks | configuration validation |
| AI-04 | HARD | Haiku 4.5 must never be used in agentic contexts (poor injection guard) | lint-rule or manual review |
| AI-05 | HARD | All new agents created after May 1, 2026 must use claude-sonnet-4-6 or opus-4-7 model IDs; legacy IDs cleaned by June 1, 2026 | migration validation |
| AI-06 | HARD | OpenAI Assistants and ChatCompletions APIs must be migrated to the Responses API by August 26, 2026 | migration validation |
| AI-07 | HARD | Input guardrails: PII detection, jailbreak detection, toxicity screening | DeepEval test suite |
| AI-08 | HARD | Output guardrails: Hallucination detection, safety validation, schema enforcement | DeepEval test suite |
| AI-09 | HARD | Runtime guardrails: Tool authorization and cost threshold checks | DeepEval test suite |
| AI-10 | HARD | All guardrail decisions are logged to audit_logs | audit log validation |
| AI-11 | HARD | Synchronous pre-call budget check enforced at the LiteLLM proxy; if budget exceeded, return 429 and a cost limit banner | runtime validation |
| AI-12 | HARD | Multi-level budgets: org, team, user, model | configuration validation |
| AI-13 | HARD | Alert thresholds: at 15% remaining notify admin; at 5% notify admin + engineering; at 0% hard stop | monitoring alert |
| AI-14 | HARD | ai_cost_log is a TimescaleDB hypertable; x-litellm-tags carry org_id, user_id, feature | schema validation |
| AI-15 | HARD | DeepEval for AI evaluation; RAGAS alongside for RAG | CI gate configuration |
| AI-16 | HARD | Tool-calling precision >=90% (block if <85%) | DeepEval CI gate |
| AI-17 | HARD | Hallucination rate <=2% | DeepEval CI gate |
| AI-18 | HARD | Accuracy >= base-2% | DeepEval CI gate |
| AI-19 | HARD | Latency <= base+10% (warn), >20% block | DeepEval CI gate |
| AI-20 | HARD | Token usage <= base+15% (warn) | DeepEval CI gate |
| AI-21 | HARD | All evaluator LLM-as-judge calls go through the LiteLLM proxy for cost tracking | runtime validation |
| AI-22 | HARD | Prompt caching enabled; static content cached first | configuration validation |
| AI-23 | HARD | Chat cache hit rate target >70%, RAG cache hit rate >90% | monitoring alert |
| AI-24 | HARD | Contextual Retrieval activated only when corpus >50K chunks, precision improvement >15%, and cache hit rate >60% | configuration validation |
| AI-25 | HARD | All local models must be registered in the Model Trust Registry before use in agentic workflows | registry validation |
| AI-26 | HARD | Model quantisation: default GGUF Q4_K_M (<4.5 GB RAM); evaluated weekly for tool-calling pass rate | monitoring alert |
| AI-27 | HARD | The Verifier cascade (Phi-4-mini-reasoning) checks reasoning, schema validity, and budget before an action is committed (Phase 1) | runtime validation |

---

## Summary

- **Total Rules**: 113
- **HARD Rules**: 108
- **MEDIUM Rules**: 5
- **Security Rules**: 28
- **Backend Rules**: 18
- **Collaboration Rules**: 3
- **Frontend Rules**: 37
- **AI Rules**: 27