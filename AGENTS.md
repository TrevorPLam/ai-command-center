# Agent Instructions

**Purpose**: This document provides immutable rules, architectural boundaries, and output conventions for AI agents working on the AI Command Center codebase.

**Scope**: All AI agents must read and follow these instructions before making any code changes.

---

## Immutable Rules

### Backend Rules (BE-)

- **BE-01**: All AI calls must go through the LiteLLM proxy
- **BE-02**: Prisma client never runs in the browser
- **BE-03**: Nylas API access is only from FastAPI
- **BE-04**: Vercel Edge Functions cannot connect to a database directly; use Vercel Serverless (300s) with Neon serverless driver, or route through FastAPI
- **BE-05**: /v1/* endpoints follow OpenAPI 3.1 contract; Schemathesis blocks merge on drift
- **BE-06**: PostgreSQL Row-Level Security (RLS) is enabled on all tables that contain tenant data
- **BE-07**: Supabase Realtime channels are limited to 100 total connections and 20 per user; memory alert at 40 MB per channel
- **BE-08**: Offline-first pattern: soft deletes via deleted_at column (nullable millisecond timestamp); all primary keys are ULIDs
- **BE-09**: Every asynchronous operation is idempotent: key = actor_id + monotonic counter
- **BE-10**: PowerSync is the target primary offline sync mechanism. Phase 2 implements tombstone + outbox; Phase 4 delivers full bidirectional sync
- **BE-11**: Supabase Realtime payload caps: Broadcast max 256 KB - 3 MB, Postgres Changes max 1 MB
- **BE-12**: Orval >=8.2.0; generate TypeScript types from OpenAPI; never run on untrusted specs
- **BE-13**: LiteLLM >=1.83.7 with cosign verification
- **BE-14**: Grype (not Trivy) for Docker scanning; scanners isolated from CI credential store
- **BE-15**: TypeScript tsc --erasableSyntaxOnly --noEmit gate in CI; ban TypeScript enums
- **BE-16**: MSW handlers are generated from the OpenAPI spec via openapi-backend for testing
- **BE-17**: tenant-scoped application data; excludes identity/auth tables (users, organizations, connected_accounts)
- **BE-18**: All tables must have a created_at timestamp column

### Frontend Rules (FE-)

- **FE-01**: Vite SPA only; no Next.js (ADR_001)
- **FE-02**: Zustand v5 for global state (ADR_003)
- **FE-03**: react-big-calendar pinned to ^1.19.4 for React 19 compatibility
- **FE-04**: dnd-kit is the primary DnD library; no migration to PragmaticDnD (ADR_085)
- **FE-05**: react-helmet-async for document head
- **FE-06**: Use Temporal.ZonedDateTime for all calendar events (never PlainDateTime); rschedule + @rschedule/temporal-date-adapter replaces rrule.js on the frontend (ADR_109)
- **FE-07**: Tremor v3.18.x for charting (ADR_105)
- **FE-08**: OKLCH-based design tokens; no hardcoded colours
- **FE-09**: Toast: 60, Command Palette: 50, Modal: 40, Drawer: 30, Sheet: 20 (Z-index)
- **FE-10**: Always use useShallow when selecting objects from a Zustand store to avoid unnecessary re-renders
- **FE-11**: Never use useState for global UI state; it belongs in Zustand slices
- **FE-12**: Slices cannot import each other; cross-slice access must use get() (ZUSTANDCIRCULAR rule)
- **FE-13**: React Compiler enabled globally; no manual useMemo/useCallback/React.memo
- **FE-14**: Exception: React Hook Form components need the "use no memo" directive
- **FE-15**: Zustand persist wrappers must use conditional rendering, not Suspense
- **FE-16**: Empty states always render an EmptyState component with a call-to-action; never show a blank screen
- **FE-17**: Loading states: skeleton/shimmer if load time <2 seconds; spinner if >2 seconds
- **FE-18**: Error states: display a retry button and human-readable message
- **FE-19**: Offline state: show a connectivity indicator; queue actions for later
- **FE-20**: Optimistic mutations: pending = opacity 0.5 + italic + pulse; 5-second undo for delete operations
- **FE-21**: Stagger no more than 3 children in any animation
- **FE-22**: Only transform and opacity may be animated. No layout property animations
- **FE-23**: Respect prefers-reduced-motion; if active, all animations become instant
- **FE-24**: Avoid animations longer than 5 seconds (WCAG 2.2.2)
- **FE-25**: Filter updates should be wrapped in useTransition to keep the UI responsive
- **FE-26**: All drag-and-drop uses a centralised dnd-kit facade (never import directly from the library elsewhere)
- **FE-27**: DragOverlay must be used to render a copy of the dragged element, never drag the original DOM node
- **FE-28**: Keyboard alternatives must be provided for all drag operations (WCAG 2.5.7)
- **FE-29**: Monaco Editor is sandboxed in a separate iframe with its own CSP
- **FE-30**: Monaco is lazy-loaded (React.lazy + Suspense + skeleton), never in the initial bundle
- **FE-31**: localStorage usage limited to <=3 MB; implement an eviction priority
- **FE-32**: Zustand persist must include version, migrate, and partialize functions
- **FE-33**: More than 3 URL search params must use useQueryStates (not multiple useQueryState calls)
- **FE-34**: No hardcoded hex/RGB colours; reference OKLCH CSS custom properties only
- **FE-35**: WCAG 2.2 AA everywhere, including keyboard navigation, screen reader announcements, and focus order
- **FE-36**: Canvas-only or purely visual components must have an alternative text representation
- **FE-37**: Use react-helmet-async for per-route meta tags

### AI Core Rules (AI-)

- **AI-01**: Default orchestrator: Gemma 4 E2B (local, native tool calling). Fallback: Qwen3.5 4B. Cloud models are premium only
- **AI-02**: Free-tier users are restricted to local models only; AI must never make cloud API calls for them
- **AI-03**: Claude Sonnet 4.6 is the default cloud model when authorised; Opus 4.7 for complex tasks
- **AI-04**: Haiku 4.5 must never be used under any circumstances
- **AI-05**: All new agents created after May 1, 2026 must use claude-sonnet-4-6 or opus-4-7 model IDs; legacy IDs cleaned by June 1, 2026
- **AI-06**: OpenAI Assistants and ChatCompletions APIs must be migrated to the Responses API by August 26, 2026
- **AI-07**: Input guardrails: PII detection, jailbreak detection, toxicity screening
- **AI-08**: Output guardrails: Hallucination detection, safety validation, schema enforcement
- **AI-09**: Runtime guardrails: Tool authorization and cost threshold checks
- **AI-10**: All guardrail decisions are logged to audit_logs
- **AI-11**: Synchronous pre-call budget check enforced at the LiteLLM proxy; if budget exceeded, return 429 and a cost limit banner
- **AI-12**: Multi-level budgets: org, team, user, model
- **AI-13**: Alert thresholds: at 15% remaining notify admin; at 5% notify admin + engineering; at 0% hard stop
- **AI-14**: ai_cost_log is a TimescaleDB hypertable; x-litellm-tags carry org_id, user_id, feature
- **AI-15**: DeepEval for AI evaluation; RAGAS alongside for RAG
- **AI-16**: Tool-calling precision >=90% (block if <85%)
- **AI-17**: Hallucination rate <=2%
- **AI-18**: Accuracy >= base-2%
- **AI-19**: Latency <= base+10% (warn), >20% block
- **AI-20**: Token usage <= base+15% (warn)
- **AI-21**: All evaluator LLM-as-judge calls go through the LiteLLM proxy for cost tracking
- **AI-22**: Prompt caching enabled; static content cached first
- **AI-23**: Chat cache hit rate target >70%, RAG cache hit rate >90%
- **AI-24**: Contextual Retrieval activated only when corpus >50K chunks, precision improvement >15%, and cache hit rate >60%
- **AI-25**: All local models must be registered in the Model Trust Registry before use in agentic workflows
- **AI-26**: Model quantisation: default GGUF Q4_K_M (<4.5 GB RAM); evaluated weekly for tool-calling pass rate
- **AI-27**: The Verifier cascade (Phi-4-mini-reasoning) checks reasoning, schema validity, and budget before an action is committed (Phase 1)

### Security Rules (SEC-)

- **SEC-01**: Use SanitizedHTML for all user-generated HTML (STRICT, RICH, EMAIL profiles)
- **SEC-02**: Supabase storage access only via StorageService wrapper
- **SEC-03**: Nylas API calls only from FastAPI backend
- **SEC-04**: Only supabase-js allowed in browser; Prisma never in frontend
- **SEC-05**: Prisma schema changes must update RLS policies
- **SEC-06**: Global CSP enforced in production (nonce-based, strict-dynamic)
- **SEC-07**: unsafe-eval only for Monaco/Babel in sandboxed iframes
- **SEC-08**: JWT stored only in httpOnly cookie, never in Zustand/localStorage
- **SEC-09**: All /v1/* API calls through centralized api.ts client
- **SEC-10**: DOMPurify >=3.4.0 mandatory; automated CVE audit in CI
- **SEC-11**: CSP nonce cryptographically random per request; strict-dynamic
- **SEC-12**: LiveKit tokens scoped to rooms and capabilities; RBAC enforced
- **SEC-13**: RBAC applied to all resources; no ad-hoc permission checks
- **SEC-14**: Rate limiting enforced per user and organization
- **SEC-15**: Organization deletion cascades; notify admins 7 days before
- **SEC-16**: Agent-driven UI only uses trusted GenUI catalog components
- **SEC-17**: Yjs collaboration opt-in per document type
- **SEC-18**: AI cost hard cap enforced at LLM proxy level
- **SEC-19**: MCP tool registration requires admin approval; all logged
- **SEC-20**: AI cost thresholds trigger alerts and rate limits
- **SEC-21**: OpenAPI 3.1 single source of truth; Orval generates types
- **SEC-22**: pgvector-retrieved chunks pass guardrails input layer
- **SEC-23**: Secret rotation failure treated as P1 incident; SOC2 evidence
- **SEC-24**: Use Grype (not Trivy) for Docker scanning; credential isolation
- **SEC-25**: Supabase auth_admin role requires SELECT grants on user tables
- **SEC-26**: Sentry projects strip PII; Session Replay masks text
- **SEC-27**: ClamAV v1.4.x sidecar in production; freshclam hourly
- **SEC-28**: Three DOMPurify profiles; test matrix ensures XSS prevention

### Collaboration Rules (COLL-)

- **COLL-01**: default 50 MB document limit, configurable via Y_SWEET_MAX_BODY_SIZE
- **COLL-02**: LiveKit Agents v2.0 only; semantic turn detection mandatory
- **COLL-03**: Yjs collaboration is opt-in per document; disconnect cleanup ensures channel unsubscription

---

## Monorepo Structure

### Repository Layout

```text
ai-command-center/
├── docs/                    # Planning and architecture documentation
│   ├── 1/                  # Core documentation (MD.md, TASKS.md)
│   └── plan/               # Architecture specs, rules, decisions
├── prisma/                 # Database schema and migrations
│   └── schema.prisma       # Prisma schema (single source of truth)
├── research/               # Research findings and benchmarks
├── scripts/                # Build and generation scripts
├── specs/                  # API contracts and specifications
├── .github/                # GitHub Actions workflows
├── AGENTS.md               # This file - agent instructions
├── package.json            # Root package.json (documentation repo)
└── TODO.md                 # Project TODO list
```

### Package Structure

This is currently a documentation repository. The monorepo structure for application code will be:

```text
packages/
├── shared/                 # Shared TypeScript types and utilities
├── frontend/               # Vite SPA (React + TypeScript)
└── backend/                # FastAPI backend (Python)
```

### Build System

#### Root Commands (Documentation)

```bash
# Generate documentation tables
npm run generate:all
npm run generate:component-table
npm run generate:pattern-tags
npm run generate:security-controls
npm run generate:versions
```

#### Frontend Commands (Vite)

```bash
# Development
npm run dev                 # Start Vite dev server on port 3000

# Build
npm run build               # Build for production
npm run preview             # Preview production build

# Type checking
npm run typecheck           # TypeScript type checking (tsc --noEmit)
npm run typecheck:tsgo      # TypeScript 7.0 beta type checking (experimental)

# Linting
npm run lint                # ESLint
npm run lint:fix            # ESLint with auto-fix

# Testing
npm run test                # Run unit tests
npm run test:component      # Run component tests
npm run test:e2e            # Run Playwright E2E tests
```

#### Backend Commands (FastAPI)

```bash
# Development
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Type checking
mypy app/ --strict

# Linting
ruff check app/
ruff format app/

# Testing
pytest tests/ -v
pytest tests/ --cov=app
```

#### Database Commands (Prisma)

```bash
# Generate Prisma Client
npx prisma generate

# Run migrations
npx prisma migrate dev

# Reset database (dev only)
npx prisma migrate reset

# Open Prisma Studio
npx prisma studio
```

---

## Architectural Boundaries

### Backend Boundaries

- **Prisma only in FastAPI backend**: Never import Prisma client in frontend code. Use supabase-js for browser database access.
- **Nylas API only from FastAPI**: All Nylas API calls must go through the FastAPI backend. Never call Nylas directly from frontend.
- **LiteLLM proxy mandatory**: All AI calls must route through the LiteLLM proxy. Never call LLM providers directly.
- **Database access patterns**:
  - Frontend: supabase-js for auth and real-time
  - Backend: Prisma ORM for all database operations
  - Edge Functions: Use Neon serverless driver or route through FastAPI

### Frontend Boundaries

- **Zustand for global state only**: Never use useState for global UI state. All global state belongs in Zustand slices.
- **dnd-kit facade pattern**: Never import dnd-kit directly except in the centralized facade. All drag-and-drop must use the facade.
- **React Compiler global**: No manual useMemo/useCallback/React.memo except for React Hook Form components (use "use no memo" directive).
- **Cross-slice access restriction**: Zustand slices cannot import each other. Use get() for cross-slice access.
- **Monaco isolation**: Monaco Editor must be sandboxed in a separate iframe with its own CSP. Never load Monaco in the main bundle.

### Security Boundaries

- **JWT storage**: JWT tokens stored only in httpOnly cookies. Never store in Zustand or localStorage.
- **CSP enforcement**: Global CSP enforced in production with nonce-based strict-dynamic. unsafe-eval only for Monaco/Babel in sandboxed iframes.
- **RBAC enforcement**: All resource access must go through RBAC. No ad-hoc permission checks.
- **MCP security**: MCP tool registration requires admin approval. All MCP tools logged and audited.
- **AI cost enforcement**: Cost hard cap enforced at LLM proxy level. Pre-call budget check mandatory.

### Data Boundaries

- **Offline-first pattern**: All tables use soft deletes via deleted_at column. All primary keys are ULIDs.
- **Tenant isolation**: All application data is tenant-scoped (org_id). Identity/auth tables (users, organizations, connected_accounts) are excluded.
- **RLS mandatory**: PostgreSQL Row-Level Security enabled on all tenant data tables.
- **Timestamps**: All tables must have created_at timestamp column.

### AI Boundaries

- **Local models for free tier**: Free-tier users restricted to local models only. No cloud API calls for free tier.
- **Model exclusion**: Haiku 4.5 must never be used under any circumstances.
- **Guardrail layers**: Input, output, and runtime guardrails mandatory. All guardrail decisions logged.
- **Budget enforcement**: Multi-level budgets (org, team, user, model) with synchronous pre-call check.
- **Model registry**: All local models must be registered in Model Trust Registry before use.

---

## Output Conventions

### TypeScript Code Style

- **Type safety**: All code must be fully typed. Use `strict` mode in tsconfig.json.
- **No enums**: Ban TypeScript enums. Use union types or const assertions instead.
- **Imports**: Use absolute imports with `@/` alias for internal modules.
- **Component naming**: PascalCase for components (e.g., `UserProfile.tsx`).
- **Utility naming**: camelCase for utilities (e.g., `formatDate.ts`).
- **Type naming**: PascalCase for types (e.g., `UserProps`).
- **Interface vs type**: Use `interface` for object shapes that may be extended. Use `type` for unions, intersections, and primitives.

### React Component Conventions

- **Functional components only**: No class components.
- **Props interface**: Define props as interface before component.
- **Default exports**: Use default export for components.
- **Named exports**: Use named exports for utilities, hooks, and types.
- **File organization**: Keep component, styles, and tests in same directory when possible.

### Zustand Store Conventions

- **Slice naming**: camelCase for slice files (e.g., `uiSlice.ts`).
- **State interface**: Define state interface at top of slice.
- **Actions**: Group actions by domain (e.g., `setCurrentOrg`, `addMessage`).
- **Persist configuration**: Always include version, migrate, and partialize functions.
- **Cross-slice access**: Use `get()` to access other slices. Never import slices directly.

### Test File Conventions

- **Unit tests**: `.test.ts` or `.test.tsx` suffix (e.g., `formatDate.test.ts`).
- **Component tests**: `.component.test.tsx` suffix (e.g., `UserProfile.component.test.tsx`).
- **E2E tests**: `.e2e.ts` suffix (e.g., `login.e2e.ts`).
- **Test location**: Co-locate tests with source files in `__tests__` directory or adjacent to source.

### Documentation Conventions

- **Markdown**: Use CommonMark with GFM extensions.
- **Line length**: ≤100 characters per line.
- **Headings**: ATX syntax only. One H1 per document. Never skip levels.
- **Code blocks**: Fenced with language tag. Blank lines around code blocks.
- **Tables**: Leading/trailing pipes. Align logically.
- **Links**: Prefer inline links over reference links.

### API Contract Conventions

- **OpenAPI 3.1**: All API contracts must follow OpenAPI 3.1 specification.
- **Orval generation**: TypeScript types generated from OpenAPI via Orval >=8.2.0.
- **Schemathesis**: Contract testing via Schemathesis. Blocks merge on drift.
- **Versioning**: API version in URL path (e.g., `/v1/events`).

### Commit Message Conventions

- **Format**: Conventional Commits (e.g., `feat: add user profile page`).
- **Types**: feat, fix, docs, style, refactor, test, chore.
- **Scope**: Optional scope in parentheses (e.g., `feat(frontend): add user profile`).
- **Body**: Detailed explanation for non-trivial changes.
- **Breaking changes**: Mark with `!` after type/scope (e.g., `feat(frontend)!: change API`).

---

## Decision Log Reference

All architectural decisions are recorded in `docs/plan/01-PLAN-DECISIONS.md`. Before making new decisions:

1. Check the decision log for existing decisions.
2. If decision exists, follow it. Do not create a new decision.
3. If decision does not exist, create a new entry in the decision log.
4. Reversible decisions can be made by AI agents.
5. Costly/irreversible decisions require Trevor's explicit review.

Key ADRs to reference:

- **ADR_001**: Vite SPA, not Next.js
- **ADR_002**: Prisma schema + migrations, Supabase runtime
- **ADR_003**: Zustand v5 for state management
- **ADR_004**: LiteLLM as AI proxy/gateway
- **ADR_058**: OpenAPI 3.1 as single source of truth
- **ADR_084**: PowerSync as primary offline sync
- **ADR_085**: dnd-kit remains primary DnD library
- **ADR_086**: Vercel AI SDK v6 for streaming
- **ADR_108**: DeepEval as primary AI evaluation framework

---

## Version Reference

Exact versions and constraints are defined in `docs/plan/versions.yaml` (source of truth).

Key version pins:

- **React**: 18+ (React 20 adoption timeline: Q2 eval, Q3 migration)
- **TypeScript**: 6.0 (7.0 beta evaluation in progress)
- **Zustand**: v5
- **Vite**: Latest stable
- **Prisma**: 7 (Prisma Next evaluation postponed to Phase 3)
- **LiteLLM**: >=1.83.7 with cosign verification
- **Orval**: >=8.2.0
- **DOMPurify**: >=3.4.0
- **Grype**: Latest (replaces Trivy)
- **ClamAV**: v1.4.x
- **Tremor**: v3.18.x
- **react-big-calendar**: ^1.19.4
