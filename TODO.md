Proceeding with the first 15 tasks of the refreshed Phase 0 list, fully aligned with the Python‑only backend and incorporating all critical missing pieces identified through our passes.

---

### T‑001‑root: Root Workspace Initialisation
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** None  

### Definition of Done
- [ ] Root `package.json` with packageManager pin to pnpm@>=10.29.1
- [ ] `pnpm-workspace.yaml` with `catalogMode: strict`
- [ ] `.npmrc` with engine-strict=true

### Out of Scope
- Other workspace packages (handled in subsequent tasks)

### Rules to Follow
- **pnpm‑specific**: Use `catalogMode: strict` to prevent version drift across workspaces.

### Anti‑Patterns
- ❌ NPM or Yarn workspaces (only pnpm allowed).

### Subtasks
- [ ] T‑001‑root‑01: Initialise root `package.json` with packageManager pin — **AGENT** `/package.json`
- [ ] T‑001‑root‑02: Create `pnpm-workspace.yaml` with `catalogMode: strict` — **AGENT** `/pnpm-workspace.yaml`
- [ ] T‑001‑root‑03: Create `.npmrc` with engine-strict=true — **AGENT** `/.npmrc`

---

### T‑001‑turbo: Turborepo & Base TypeScript Config
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑root  

### Definition of Done
- [ ] Turborepo installed
- [ ] `turbo.json` with `build`, `lint`, `typecheck` tasks (including Python run commands)
- [ ] `tsconfig.base.json` with `erasableSyntaxOnly`, strict mode, path aliases (frontend only)

### Out of Scope
- Workspace-specific tsconfigs (handled in individual package tasks)

### Rules to Follow
- **BE‑15**: TypeScript `tsc --erasableSyntaxOnly --noEmit` gate enforced in CI (frontend only).

### Advanced Coding Patterns
- Turborepo `tasks` with topological ordering (wrap Python tasks via `package.json` scripts or direct commands).

### Subtasks
- [ ] T‑001‑turbo‑01: Install Turborepo — **AGENT**
- [ ] T‑001‑turbo‑02: Generate `turbo.json` with `build`, `lint`, `typecheck` tasks (include Python run commands) — **AGENT** `/turbo.json`
- [ ] T‑001‑turbo‑03: Create `tsconfig.base.json` with `erasableSyntaxOnly`, strict mode, path aliases (frontend only) — **AGENT** `/tsconfig.base.json`

---

### T‑001‑backend: Backend Scaffold
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑root  

### Definition of Done
- [ ] `apps/backend/` directory with empty FastAPI project
- [ ] `pyproject.toml` with [tool.mypy], [tool.ruff], [tool.pytest.ini_options], [tool.alembic]
- [ ] `requirements.txt` or pip dependencies in pyproject.toml
- [ ] `Dockerfile` for backend
- [ ] `package.json` with name and scripts (seed, generate, etc.) for Turbo task orchestration

### Out of Scope
- Actual application code; only tooling and empty project structure.

### Rules to Follow
- ❌ Using TypeScript for backend services.

### Subtasks
- [ ] T‑001‑backend‑01: Scaffold `apps/backend/` (empty FastAPI + `requirements.txt`, `Dockerfile`) — **AGENT** `/apps/backend/`
- [ ] T‑001‑backend‑02: Add [tool.mypy] with strict settings to pyproject.toml — **AGENT**
- [ ] T‑001‑backend‑03: Add [tool.ruff] with lint/format rules to pyproject.toml — **AGENT**
- [ ] T‑001‑backend‑04: Add [tool.pytest.ini_options] with asyncio_mode and test paths to pyproject.toml — **AGENT**
- [ ] T‑001‑backend‑05: Add [tool.alembic] (optional) for migration config to pyproject.toml — **AGENT**
- [ ] T‑001‑backend‑06: Create apps/backend/package.json with name, scripts (seed, generate, etc.) to enable Turbo task orchestration — **AGENT**

---

### T‑001‑frontend: Frontend Scaffold
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑root, T‑001‑turbo  

### Definition of Done
- [ ] `apps/web/` directory with Vite + React + TypeScript + Tailwind project
- [ ] `vite-env.d.ts` created

### Out of Scope
- Design tokens, shell components (handled in T‑005 tasks)

### Rules to Follow
- **FE‑01**: Vite SPA only (no Next.js).

### Subtasks
- [ ] T‑001‑frontend‑01: Scaffold `apps/web/` (Vite + React + TypeScript + Tailwind) — **AGENT** `/apps/web/`
- [ ] T‑001‑frontend‑02: Create `vite-env.d.ts` with Vite client types reference — **AGENT** `/apps/web/src/vite-env.d.ts`

---

### T‑001‑shared: Shared Package Scaffold
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑root, T‑001‑turbo, T‑001‑frontend  

### Definition of Done
- [ ] `packages/shared/` directory with TypeScript project
- [ ] `packages/shared/src/` directory created
- [ ] "@repo/shared": "workspace:*" added to apps/web/package.json dependencies
- [ ] Path alias "@shared/*": ["./packages/shared/src/*"] added to tsconfig.base.json

### Out of Scope
- Actual shared types/utilities (filled as needed)

### Subtasks
- [ ] T‑001‑shared‑01: Scaffold `packages/shared/` (shared types/utilities, TypeScript) — **AGENT** `/packages/shared/`
- [ ] T‑001‑shared‑02: Create `packages/shared/src/` directory — **AGENT**
- [ ] T‑001‑shared‑03: Add "@repo/shared": "workspace:*" to apps/web/package.json dependencies — **AGENT**
- [ ] T‑001‑shared‑04: Add path alias "@shared/*": ["./packages/shared/src/*"] to tsconfig.base.json — **AGENT**

---

### T‑001‑lint: ESLint & Prettier Configuration
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑root, T‑001‑backend, T‑001‑frontend  

### Definition of Done
- [ ] Root `eslint.config.mjs` configured across all workspaces
- [ ] Root `.prettierrc` configured
- [ ] `.prettierignore` created

### Out of Scope
- Workspace-specific lint configs (if needed, handled in package tasks)

### Subtasks
- [ ] T‑001‑lint‑01: Configure ESLint (`eslint.config.mjs`) across all workspaces — **AGENT** `/eslint.config.mjs`
- [ ] T‑001‑lint‑02: Configure Prettier (`.prettierrc`) — **AGENT** `/.prettierrc`
- [ ] T‑001‑lint‑03: Create `.prettierignore` — **AGENT**

---

### T‑001‑git: Git Hygiene
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑root  

### Definition of Done
- [ ] Root `.gitignore` created
- [ ] `.gitattributes` to enforce LF line endings
- [ ] `.editorconfig` created
- [ ] `.nvmrc` (Node 20) created
- [ ] `.python-version` (3.12) created
- [ ] `.env.example` created

### Subtasks
- [ ] T‑001‑git‑01: Create root `.gitignore` — **AGENT**
- [ ] T‑001‑git‑02: Create `.gitattributes` to enforce LF line endings — **AGENT**
- [ ] T‑001‑git‑03: Create `.editorconfig` — **AGENT**
- [ ] T‑001‑git‑04: Create `.nvmrc` (Node 20) — **AGENT**
- [ ] T‑001‑git‑05: Create `.python-version` (3.12) — **AGENT**
- [ ] T‑001‑git‑06: Create `.env.example` — **AGENT**

---

### T‑001‑husky: Husky Pre‑Commit
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑lint, T‑001‑turbo  

### Definition of Done
- [ ] `.husky/pre-commit` hook configured to run `lint` and `typecheck`

### Subtasks
- [ ] T‑001‑husky‑01: Set up `.husky/pre-commit` to run `lint` and `typecheck` — **AGENT**

---

### T‑001‑docs: Root Documentation
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑root  

### Definition of Done
- [ ] Root `README.md` created
- [ ] `CONTRIBUTING.md` created
- [ ] `.github/PULL_REQUEST_TEMPLATE.md` created

### Subtasks
- [ ] T‑001‑docs‑01: Create root `README.md` — **AGENT**
- [ ] T‑001‑docs‑02: Create `CONTRIBUTING.md` — **AGENT**
- [ ] T‑001‑docs‑03: Add `.github/PULL_REQUEST_TEMPLATE.md` — **AGENT**

---

### T‑001‑docker: Docker Compose & Infrastructure
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑backend  

### Definition of Done
- [ ] Root `docker-compose.yml` orchestrating: FastAPI, Supabase (local), Redis, Ollama, LiteLLM
- [ ] `apps/backend/.dockerignore` created
- [ ] `infra/clamav/Dockerfile` created
- [ ] `infra/clamav/freshclam.conf` created

### Subtasks
- [ ] T‑001‑docker‑01: Create root `docker-compose.yml` orchestrating: FastAPI, Supabase (local), Redis, Ollama, LiteLLM — **AGENT**
- [ ] T‑001‑docker‑02: Create `apps/backend/.dockerignore` — **AGENT**
- [ ] T‑001‑docker‑03: Create `infra/clamav/Dockerfile` — **AGENT**
- [ ] T‑001‑docker‑04: Create `infra/clamav/freshclam.conf` — **AGENT**

---

### T‑001‑windsurf: Windsurf Rules
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑root  

### Definition of Done
- [ ] `.windsurfrules` created with stack constraints

### Subtasks
- [ ] T‑001‑windsurf‑01: Create `.windsurfrules` with stack constraints — **AGENT**

---

### T‑001‑security: GitHub Security Workflows
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑docker  

### Definition of Done
- [ ] `.github/workflows/security-scan.yml` created with Grype and ClamAV

### Rules to Follow
- **BE‑14**: Grype for Docker scanning (not Trivy).

### Subtasks
- [ ] T‑001‑security‑01: Create `.github/workflows/security-scan.yml` with Grype and ClamAV — **AGENT**

---

### T‑001‑validate: Monorepo Validation
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑turbo, T‑001‑lint, T‑001‑shared  

### Definition of Done
- [ ] `pnpm install` succeeds with no warnings
- [ ] Turborepo `build`, `lint`, `typecheck` pipelines run without errors across workspaces

### Out of Scope
- Actual application code; only tooling and empty packages.

### Rules to Follow
- **BE‑15**: TypeScript `tsc --erasableSyntaxOnly --noEmit` gate enforced in CI (frontend only).
- **FE‑01**: Vite SPA only (no Next.js).
- **FE‑08**: OKLCH‑based design tokens – no hardcoded colours.

### Advanced Coding Patterns
- Use **pnpm catalogs** for shared dependency versions.

### Anti‑Patterns
- ❌ Placing application code outside of `apps/` or `packages/`.

### Subtasks
- [ ] T‑001‑validate‑01: Run `pnpm install` and validate monorepo structure — **HUMAN**

---

### T‑002: Database Schema & SQLModel Configuration
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑backend  

### Definition of Done
- [ ] All foundation + core tables defined as SQLModel classes (organizations, users, organization_members, projects, tasks, events, threads, messages, notifications, audit_logs, feature_flags, connected_accounts).
- [ ] Alembic initialised and first migration generated.
- [ ] Migration applied to local Supabase instance.
- [ ] RLS policies enabled and tested via pgTAP (at least 10 tables covered).
- [ ] `created_at` on all tables, ULID primary keys, `deleted_at` soft‑delete columns.

### Out of Scope
- AI‑specific tables (agent_definitions, ai_cost_log) – these arrive later.
- TimescaleDB hypertable setup (done when `ai_cost_log` is created).

### Rules to Follow
- **BE‑08**: ULID primary keys via `gen_random_ulid()`, soft deletes.
- **BE‑09**: Idempotency keys = `actor_id + monotonic_counter`.
- **BE‑17**: `org_id` + RLS on every tenant‑data table.
- **BE‑18**: `created_at` timestamp column mandatory.

### Advanced Coding Patterns
- Use **SQLModel** (SQLAlchemy 2.0 + asyncpg) with Alembic migrations.
- RLS tested atomically with pgTAP.

### Anti‑Patterns
- ❌ Using `updated_at` only; `created_at` must always be present.
- ❌ Skipping RLS tests – every table verified.

### Subtasks
- [ ] T‑002‑01: Create SQLModel classes for organisations, users, members — **AGENT** `/apps/backend/app/models/`
- [ ] T‑002‑02: Add core tables: projects, tasks, events, threads, messages, notifications — **AGENT**
- [ ] T‑002‑03: Add audit_logs, feature_flags, connected_accounts — **AGENT**
- [ ] T‑002‑04: Initialise Alembic (`alembic init`) and create initial migration — **AGENT** `/apps/backend/alembic/`
- [ ] T‑002‑04a: Customise `alembic/env.py` to import all SQLModel models from `app.models` — **AGENT**
- [ ] T‑002‑04b: Create `alembic.ini` and `alembic/script.py.mako` — **AGENT**
- [ ] T‑002‑05: Write pgTAP RLS tests (one per table with org_id) — **AGENT** `/apps/backend/tests/rls/`
- [ ] T‑002‑06: Apply migration and verify RLS isolation manually — **HUMAN**
- [ ] T‑002‑07: In `supabase/config.toml` set `schema_migrations = "local"` to disable Supabase auto‑migrations — **AGENT**

---

### T‑003a: FastAPI App with Lifespan & Health Endpoint
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑backend  

### Definition of Done
- [ ] FastAPI app initialised with lifespan async context manager.
- [ ] `/health` endpoint returning `{"status": "ok"}`.
- [ ] App runs locally and responds to health check.

### Out of Scope
- Database connection, auth middleware, or business logic.

### Rules to Follow
- ❌ Using deprecated `@app.on_event("startup")` or `"shutdown"` – use lifespan instead.

### Subtasks
- [ ] T‑003a‑01: Initialise FastAPI project (`main.py`, `requirements.txt`, `Dockerfile`) with lifespan pattern — **AGENT** `/apps/backend/`
- [ ] T‑003a‑02: Implement `/health` endpoint returning `{"status": "ok"}` — **AGENT** `/apps/backend/app/main.py`
- [ ] T‑003a‑03: Test end‑to‑end: start backend, call `/health` — **HUMAN**

---

### T‑003b: Database Engine & Session Factory
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑backend, T‑002, T‑003a  

### Definition of Done
- [ ] SQLModel, SQLAlchemy, asyncpg installed in `pyproject.toml`.
- [ ] Database module with async engine and session factory created.
- [ ] `get_db_session` dependency for FastAPI routes.
- [ ] Basic CRUD on `organizations` table works.

### Rules to Follow
- SQLAlchemy async engine instantiated inside lifespan and stored in `app.state`.
- ❌ Exposing SQLAlchemy models directly in API responses – use Pydantic models.

### Subtasks
- [ ] T‑003b‑01: Install SQLModel, SQLAlchemy, asyncpg; configure async engine in `pyproject.toml` — **AGENT** `/apps/backend/`
- [ ] T‑003b‑02: Create database module with async engine and session factory — **AGENT** `/apps/backend/app/core/database.py`
- [ ] T‑003b‑03: Create `app/api/deps.py` – `get_db_session` dependency — **AGENT**
- [ ] T‑003b‑04: Update main.py lifespan to initialise async engine — **AGENT** `/apps/backend/app/main.py`

---

### T‑003c: JWT Middleware & Auth Dependencies
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑003a  

### Definition of Done
- [ ] JWT validation middleware extracts `org_id` from custom access token hook.
- [ ] Auth dependency for protected routes.

### Rules to Follow
- **SEC‑08**: JWT stored only in httpOnly cookie; never in Zustand/LocalStorage.

### Subtasks
- [ ] T‑003c‑01: Implement JWT validation middleware that extracts `org_id` from token — **AGENT** `/apps/backend/app/core/auth.py`
- [ ] T‑003c‑02: Write unit tests for auth middleware — **AGENT** `/apps/backend/tests/`

---

### T‑003d: Core Configuration
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑003a  

### Definition of Done
- [ ] `config.py` with `pydantic-settings` class for environment variables.
- [ ] `constants.py` with system-wide constants.
- [ ] Environment variables loaded securely.

### Rules to Follow
- **`pydantic-settings`** for config validation with `SettingsConfigDict(env_file='.env')`.
- ❌ Storing secrets in code.

### Subtasks
- [ ] T‑003d‑01: Create `app/core/config.py` with pydantic-settings class — **AGENT**
- [ ] T‑003d‑02: Create `app/core/constants.py` – system‑wide constants — **AGENT**

---

### T‑003e: Logging & Telemetry
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑003a  

### Definition of Done
- [ ] `logging_config.py` with JSON logging dictConfig.
- [ ] `telemetry.py` with TimescaleDB batching (BE‑07).

### Rules to Follow
- **BE‑07**: TimescaleDB batching for telemetry.

### Subtasks
- [ ] T‑003e‑01: Create `app/core/logging_config.py` – JSON logging dictConfig — **AGENT**
- [ ] T‑003e‑02: Create `app/core/telemetry.py` – TimescaleDB batching (BE‑07) — **AGENT**

---

### T‑003f: Cache Wrapper
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑003a  

### Definition of Done
- [ ] `cache.py` with Redis wrapper for passkeys and rate limiting.

### Subtasks
- [ ] T‑003f‑01: Create `app/core/cache.py` – Redis wrapper for passkeys, rate limiting — **AGENT**

---

### T‑003g: API Version Router & Deps
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑003a  

### Definition of Done
- [ ] `api_v1.py` master router aggregating all versioned endpoints.
- [ ] Router integrated into main FastAPI app.

### Subtasks
- [ ] T‑003g‑01: Create `app/api/api_v1.py` – master router aggregating all versioned endpoints — **AGENT**
- [ ] T‑003g‑02: Integrate api_v1 router into main.py — **AGENT** `/apps/backend/app/main.py`

---

### T‑003h: Test Conftest & DB Readiness Script
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑003b  

### Definition of Done
- [ ] `tests/conftest.py` with async DB fixtures for pytest.
- [ ] `scripts/db_check.py` script to wait for DB readiness.

### Subtasks
- [ ] T‑003h‑01: Create `tests/conftest.py` – async DB fixtures for pytest — **AGENT**
- [ ] T‑003h‑02: Create `scripts/db_check.py` – wait for DB readiness — **AGENT**

---

### T‑003i: Directory Init Files
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑003a  

### Definition of Done
- [ ] All `__init__.py` files created in: `app/`, `app/api/`, `app/core/`, `app/models/`, `app/services/`, `app/tools/`, `app/guardrails/`, `app/middleware/`, `tests/`, `tests/rls/`.

### Subtasks
- [ ] T‑003i‑01: Create all `__init__.py` files in `app/`, `app/api/`, `app/core/`, `app/models/`, `app/services/`, `app/tools/`, `app/guardrails/`, `app/middleware/`, `tests/`, `tests/rls/` — **AGENT**

---

### T‑004: Authentication & Organisation Switching (Supabase)
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑003a, T‑003c, T‑003d, T‑003g  

### Definition of Done
- [ ] Email/password sign‑up & sign‑in working through Supabase Auth.
- [ ] Custom access token hook embeds `org_id` and `role` in JWT.
- [ ] **`supabase_auth_admin` granted SELECT** on tables read by the auth hook (orgs, members).
- [ ] Organisation switching refreshes session and clears query client cache.
- [ ] Realtime client reconnects after org switch.

### Out of Scope
- Passkeys (Phase 3), OAuth providers, advanced RBAC.

### Rules to Follow
- **SEC‑08**: JWT httpOnly cookie only; never in local state.
- **AUTHHOOK01**: Custom token hook deployed to Supabase.
- **RLS** enforced on all tables via `org_id`.

### Advanced Coding Patterns
- Use **`supabase.auth.refreshSession()`** to update JWT on org switch.
- **TanStack Query** query client invalidation.

### Anti‑Patterns
- ❌ Calling `auth.updateUser()` to change org – only `refreshSession`.
- ❌ Storing `org_id` in Zustand (it belongs in JWT).

### Subtasks
- [ ] T‑004‑01: Configure Supabase project (enable email/pw auth, disable confirmations for dev) — **HUMAN** (Supabase Dashboard)
- [ ] T‑004‑02: Deploy custom access token hook SQL function — **AGENT** `/apps/backend/sql/auth_hook.sql`
- [ ] T‑004‑02a: Execute `GRANT SELECT ON TABLE public.organization_members TO supabase_auth_admin;` — **AGENT** ( additional SQL)
- [ ] T‑004‑03: Implement `POST /v1/auth/signup` and `POST /v1/auth/login` in FastAPI (proxying Supabase) — **AGENT** `/apps/backend/app/api/auth.py`
- [ ] T‑004‑04: Write Zustand `authSlice` (user session, login/logout actions) — **AGENT** `/apps/web/src/stores/authSlice.ts`
- [ ] T‑004‑05: Create `OrgSwitcher` component with `refreshSession` and query client reset — **AGENT** `/apps/web/src/components/OrgSwitcher.tsx`
- [ ] T‑004‑06: Unit/integration tests for auth flow — **AGENT** `/apps/backend/tests/`
- [ ] T‑004‑07: Manually test sign‑up, login, org switch in browser — **HUMAN**
- [ ] T‑004‑08: Create `supabase/config.toml` (disable email confirmations, set local ports) — **AGENT**

---

### T‑005a: Tailwind 4 with OKLCH Tokens
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑frontend  

### Definition of Done
- [ ] Tailwind v4 configured with tokens.css using @theme and @source directives.
- [ ] `index.css` with `@import "tailwindcss"`.
- [ ] `postcss.config.js` created if required.
- [ ] OKLCH-based design tokens (no hex/RGB).

### Rules to Follow
- **FE‑08**: OKLCH‑based design tokens (no hex/RGB).
- **FE‑34**: Never hardcode colours – reference CSS custom properties.

### Subtasks
- [ ] T‑005a‑01: Install tailwindcss@^4.2.2, @tailwindcss/vite, @tailwindcss/postcss — **AGENT** `/apps/web/package.json`
- [ ] T‑005a‑02: Configure Tailwind v4 with tokens.css using @theme and @source directives — **AGENT**
- [ ] T‑005a‑03: Add `@import "tailwindcss"` to src/index.css — **AGENT** `/apps/web/src/index.css`
- [ ] T‑005a‑04: Create `postcss.config.js` if required by Tailwind v4 — **AGENT**

---

### T‑005b: AppShell Layout
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑frontend, T‑005a  

### Definition of Done
- [ ] AppShell component with header, sidebar, main area.
- [ ] AnimatePresence page transitions.
- [ ] RightPanel integration.

### Rules to Follow
- **FE‑09**: Z‑index layer stack: Toast 60, CommandPalette 50, Modal 40, Drawer 30, Sheet 20.

### Subtasks
- [ ] T‑005b‑01: Build `AppShell` component (header, sidebar, main area) — **AGENT** `/apps/web/src/components/AppShell.tsx`

---

### T‑005c: Sidebar Navigation Component
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑005b  

### Definition of Done
- [ ] Sidebar component with basic nav items (Dashboard, Chat, etc.).
- [ ] Navigation state management.

### Subtasks
- [ ] T‑005c‑01: Build `Sidebar` component with basic nav items (Dashboard, Chat, etc.) — **AGENT** `/apps/web/src/components/Sidebar.tsx`

---

### T‑005d: React Router + NuqsAdapter + Lazy Routes
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑frontend  

### Definition of Done
- [ ] React Router set up with lazy-loaded routes.
- [ ] NuqsAdapter wrapping router for URL state.
- [ ] Router integrated into main app.

### Subtasks
- [ ] T‑005d‑01: Install react-router-dom, nuqs — **AGENT** `/apps/web/package.json`
- [ ] T‑005d‑02: Set up React Router with lazy‑loaded routes, wrap with `NuqsAdapter` — **AGENT** `/apps/web/src/router.tsx`

---

### T‑005e: EnvValidation Component
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑frontend  

### Definition of Done
- [ ] EnvValidation component created.
- [ ] Guard mount in main.tsx to prevent mount if required env vars missing.

### Subtasks
- [ ] T‑005e‑01: Create `EnvValidation` component; guard mount in `main.tsx` — **AGENT** `/apps/web/src/components/EnvValidation.tsx`

---

### T‑005f: ErrorBoundaryFallback and Wrapping
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑frontend, T‑005b  

### Definition of Done
- [ ] ErrorBoundaryFallback component built.
- [ ] AppShell wrapped with react-error-boundary.

### Subtasks
- [ ] T‑005f‑01: Install react-error-boundary — **AGENT** `/apps/web/package.json`
- [ ] T‑005f‑02: Build `ErrorBoundaryFallback` and wrap AppShell with `react-error-boundary` — **AGENT** `/apps/web/src/App.tsx`, `/apps/web/src/components/ErrorBoundaryFallback.tsx`

---

### T‑005g: EmptyState Component
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑frontend  

### Definition of Done
- [ ] EmptyState component built with call-to-action.

### Rules to Follow
- **FE‑16**: Empty states always render `EmptyState` component.

### Subtasks
- [ ] T‑005g‑01: Build `EmptyState` component — **AGENT** `/apps/web/src/components/EmptyState.tsx`

---

### T‑005h: useReducedMotion Hook
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑frontend  

### Definition of Done
- [ ] useReducedMotion hook implemented.
- [ ] Hook reads prefers-reduced-motion media query.

### Rules to Follow
- **FE‑23**: Respect `prefers‑reduced‑motion` via the `useReducedMotion` hook.

### Subtasks
- [ ] T‑005h‑01: Implement `useReducedMotion` hook in `hooks/useReducedMotion.ts` — **AGENT** `/apps/web/src/hooks/useReducedMotion.ts`

---

### T‑005i: Temporal Polyfill Setup
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑frontend  

### Definition of Done
- [ ] @js-temporal/polyfill imported at entry point.
- [ ] Temporal.ZonedDateTime available throughout app.

### Rules to Follow
- **FE‑06**: Temporal.ZonedDateTime via polyfill.

### Subtasks
- [ ] T‑005i‑01: Install @js-temporal/polyfill — **AGENT** `/apps/web/package.json`
- [ ] T‑005i‑02: Import `@js-temporal/polyfill` at top of `main.tsx` — **AGENT** `/apps/web/src/main.tsx`

---

### T‑005k: Zustand Persistence Wrapper
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑frontend  

### Definition of Done
- [ ] persistence.ts created with Zustand storage migration wrapper.
- [ ] Version, migrate, and partialize functions configured.

### Rules to Follow
- **FE‑15**: Persist wrappers must use conditional rendering, not Suspense.
- **FE‑32**: Zustand persist must include version, migrate, and partialize functions.

### Subtasks
- [ ] T‑005k‑01: Create `src/store/persistence.ts` (Zustand storage migration wrapper) — **AGENT**

---

### T‑005l: MSW & Vitest Initialisation
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑frontend  

### Definition of Done
- [ ] mocks/browser.ts with MSW initialisation.
- [ ] test/setup.ts with Vitest globals.
- [ ] src/__tests__/ directory created.

### Subtasks
- [ ] T‑005l‑01: Install msw, vitest — **AGENT** `/apps/web/package.json`
- [ ] T‑005l‑02: Create `src/__tests__/` directory — **AGENT**
- [ ] T‑005l‑03: Create `src/mocks/browser.ts` (MSW initialisation) — **AGENT**
- [ ] T‑005l‑04: Create `src/test/setup.ts` (Vitest globals) — **AGENT**

---

### T‑005m: Static Assets
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑frontend  

### Definition of Done
- [ ] public/robots.txt created.
- [ ] public/favicon.ico created.

### Subtasks
- [ ] T‑005m‑01: Add `public/robots.txt` and `public/favicon.ico` — **AGENT**

---

### T‑005n: Global Type Definitions & Reset CSS
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑frontend  

### Definition of Done
- [ ] src/types/ directory created with global type definitions.
- [ ] src/styles/reset.css with Tailwind preflight overrides.

### Subtasks
- [ ] T‑005n‑01: Create `src/types/` directory and global type definitions — **AGENT**
- [ ] T‑005n‑02: Create `src/styles/reset.css` – Tailwind preflight overrides — **AGENT**

---

### T‑005o: UI Barrel Export & Locales
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑frontend  

### Definition of Done
- [ ] src/components/ui/index.ts barrel export for UI components.
- [ ] src/locales/ directory with en/common.json (i18n foundation).

### Subtasks
- [ ] T‑005o‑01: Create `src/components/ui/index.ts` (barrel export for UI components) — **AGENT**
- [ ] T‑005o‑02: Create `src/locales/` directory with `en/common.json` (i18n foundation) — **AGENT**

---

### T‑005p: Vite Project Initialisation & Additional Libraries
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001‑frontend  

### Definition of Done
- [ ] Vite project generated in apps/web/ with react-ts template.
- [ ] Vite pinned to ^7.3.1 in package.json.
- [ ] vite-env.d.ts created with Vite client types reference.
- [ ] Additional libraries installed: react-helmet-async, framer-motion, sonner, cmdk, axe-core, @tremor/react, use-sound, @ai-sdk/react, react-virtuoso, babel-plugin-react-compiler, eslint-plugin-react-hooks@^7.0.0.
- [ ] No hardcoded colours in initial codebase.
- [ ] Visual walk-through of shell in browser.

### Rules to Follow
- **FE‑01**: Vite SPA only.
- **FE‑34**: Never hardcode colours – reference CSS custom properties.

### Subtasks
- [ ] T‑005p‑01: Generate Vite project in `apps/web/` with `react-ts` template — **AGENT** `/apps/web/`
- [ ] T‑005p‑02: Pin Vite to ^7.3.1 in package.json; add `/// <reference types="vite/client" />` in `vite-env.d.ts` — **AGENT** `/apps/web/src/vite-env.d.ts`
- [ ] T‑005p‑03: Install `react-helmet-async`, `framer-motion`, `sonner`, `cmdk`, `axe-core`, `@tremor/react`, `use-sound`, `@ai-sdk/react`, `react-virtuoso`, `babel-plugin-react-compiler`, `eslint-plugin-react-hooks@^7.0.0` — **AGENT** `/apps/web/package.json`
- [ ] T‑005p‑04: Verify no hardcoded colours in initial codebase — **AGENT** (lint rule)
- [ ] T‑005p‑05: Visual walk‑through of shell in browser — **HUMAN**


---
### T‑006a: React Compiler & ESLint Configuration
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑005p

### Definition of Done
- [ ] @babel/plugin-react-compiler installed and configured in vite.config.ts
- [ ] eslint-plugin-react-hooks@^7.0.0 installed and configured to enforce "use no memo" directive

### Rules to Follow
- **FE‑13**: React Compiler enabled globally; no manual memoisation.
- **FE‑14**: React Hook Form components need `"use no memo"` directive.

### Subtasks
- [ ] T‑006a‑01: Install @babel/plugin-react-compiler and add to vite.config.ts babel config — **AGENT** `/apps/web/vite.config.ts`
- [ ] T‑006a‑02: Install eslint-plugin-react-hooks and configure to enforce "use no memo" directive — **AGENT** `/apps/web/eslint.config.mjs`

---

### T‑006b: Persistence Wrapper
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑005k

### Definition of Done
- [ ] persistence.ts created with Zustand storage migration wrapper
- [ ] Version, migrate, and partialize functions configured

### Rules to Follow
- **FE‑15**: Persist wrappers must use conditional rendering, not Suspense.
- **FE‑32**: Zustand persist must include version, migrate, and partialize functions.

### Subtasks
- [ ] T‑006b‑01: Create `src/store/persistence.ts` (Zustand storage migration wrapper) — **AGENT**

---

### T‑006c: authSlice
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑006b

### Definition of Done
- [ ] authSlice created with user, login, logout, clear on logout
- [ ] Uses useShallow for object selectors
- [ ] No cross-slice imports (uses get() if needed)

### Rules to Follow
- **FE‑02**: Zustand v5.
- **FE‑10**: Always use `useShallow` when selecting objects.
- **FE‑12**: Slices cannot import each other – cross‑slice access via `get()`.
- **SEC‑08**: JWT only in httpOnly cookie; never in Zustand.

### Anti‑Patterns
- ❌ Storing JWT tokens in authSlice.

### Subtasks
- [ ] T‑006c‑01: Create `authSlice` (user, login, logout, clear on logout) — **AGENT** `/apps/web/src/stores/authSlice.ts`

---

### T‑006d: uiSlice
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑006b

### Definition of Done
- [ ] uiSlice created with cmdPaletteOpen, rightPanel
- [ ] Persisted with version, migrate, partialize
- [ ] Uses useShallow for object selectors

### Rules to Follow
- **FE‑02**: Zustand v5.
- **FE‑10**: Always use `useShallow` when selecting objects.
- **FE‑12**: Slices cannot import each other – cross‑slice access via `get()`.
- **FE‑32**: Zustand persist must include version, migrate, and partialize functions.

### Subtasks
- [ ] T‑006d‑01: Create `uiSlice` (cmdPaletteOpen, rightPanel) with persist — **AGENT** `/apps/web/src/stores/uiSlice.ts`

---

### T‑006e: orgSlice
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑006b

### Definition of Done
- [ ] orgSlice created with currentOrgId
- [ ] Persisted with version, migrate, partialize
- [ ] Uses useShallow for object selectors

### Rules to Follow
- **FE‑02**: Zustand v5.
- **FE‑10**: Always use `useShallow` when selecting objects.
- **FE‑12**: Slices cannot import each other – cross‑slice access via `get()`.
- **FE‑32**: Zustand persist must include version, migrate, and partialize functions.

### Subtasks
- [ ] T‑006e‑01: Create `orgSlice` (currentOrgId) with persist — **AGENT** `/apps/web/src/stores/orgSlice.ts`

---

### T‑006f: chatSlice
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑006b

### Definition of Done
- [ ] chatSlice created with activeThreadId
- [ ] Persisted with version, migrate, partialize
- [ ] Uses useShallow for object selectors

### Rules to Follow
- **FE‑02**: Zustand v5.
- **FE‑10**: Always use `useShallow` when selecting objects.
- **FE‑12**: Slices cannot import each other – cross‑slice access via `get()`.
- **FE‑32**: Zustand persist must include version, migrate, and partialize functions.

### Subtasks
- [ ] T‑006f‑01: Create `chatSlice` (activeThreadId) with persist — **AGENT** `/apps/web/src/stores/chatSlice.ts`

---

### T‑006g: projectSlice
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑006b

### Definition of Done
- [ ] projectSlice created with currentView, filters
- [ ] Persisted with version, migrate, partialize
- [ ] Uses useShallow for object selectors

### Rules to Follow
- **FE‑02**: Zustand v5.
- **FE‑10**: Always use `useShallow` when selecting objects.
- **FE‑12**: Slices cannot import each other – cross‑slice access via `get()`.
- **FE‑32**: Zustand persist must include version, migrate, and partialize functions.

### Subtasks
- [ ] T‑006g‑01: Create `projectSlice` (currentView, filters) with persist — **AGENT** `/apps/web/src/stores/projectSlice.ts`

---

### T‑006h: calendarSlice
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑006b

### Definition of Done
- [ ] calendarSlice created with activeDate, sidebarCal
- [ ] Persisted with version, migrate, partialize
- [ ] Uses useShallow for object selectors

### Rules to Follow
- **FE‑02**: Zustand v5.
- **FE‑10**: Always use `useShallow` when selecting objects.
- **FE‑12**: Slices cannot import each other – cross‑slice access via `get()`.
- **FE‑32**: Zustand persist must include version, migrate, and partialize functions.

### Subtasks
- [ ] T‑006h‑01: Create `calendarSlice` (activeDate, sidebarCal) with persist — **AGENT** `/apps/web/src/stores/calendarSlice.ts`

---

### T‑006i: dashboardSlice
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑006b

### Definition of Done
- [ ] dashboardSlice created with agentFilter
- [ ] Persisted with version, migrate, partialize
- [ ] Uses useShallow for object selectors

### Rules to Follow
- **FE‑02**: Zustand v5.
- **FE‑10**: Always use `useShallow` when selecting objects.
- **FE‑12**: Slices cannot import each other – cross‑slice access via `get()`.
- **FE‑32**: Zustand persist must include version, migrate, and partialize functions.

### Subtasks
- [ ] T‑006i‑01: Create `dashboardSlice` (agentFilter) with persist — **AGENT** `/apps/web/src/stores/dashboardSlice.ts`

---

### T‑006j: settingsSlice
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑006b

### Definition of Done
- [ ] settingsSlice created with all settings persisted to localStorage
- [ ] Persisted with version, migrate, partialize
- [ ] Uses useShallow for object selectors

### Rules to Follow
- **FE‑02**: Zustand v5.
- **FE‑10**: Always use `useShallow` when selecting objects.
- **FE‑12**: Slices cannot import each other – cross‑slice access via `get()`.
- **FE‑32**: Zustand persist must include version, migrate, and partialize functions.

### Subtasks
- [ ] T‑006j‑01: Create `settingsSlice` (all persisted to localStorage) — **AGENT** `/apps/web/src/stores/settingsSlice.ts`

---

### T‑006k: mcpSlice
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑006b

### Definition of Done
- [ ] mcpSlice created with versioning
- [ ] Persisted with version, migrate, partialize
- [ ] Uses useShallow for object selectors

### Rules to Follow
- **FE‑02**: Zustand v5.
- **FE‑10**: Always use `useShallow` when selecting objects.
- **FE‑12**: Slices cannot import each other – cross‑slice access via `get()`.
- **FE‑32**: Zustand persist must include version, migrate, and partialize functions.

### Subtasks
- [ ] T‑006k‑01: Create `mcpSlice` with versioning — **AGENT** `/apps/web/src/stores/mcpSlice.ts`

---

### T‑006l: agentStore
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑006b

### Definition of Done
- [ ] agentStore created with versioning
- [ ] Persisted with version, migrate, partialize
- [ ] Uses useShallow for object selectors

### Rules to Follow
- **FE‑02**: Zustand v5.
- **FE‑10**: Always use `useShallow` when selecting objects.
- **FE‑12**: Slices cannot import each other – cross‑slice access via `get()`.
- **FE‑32**: Zustand persist must include version, migrate, and partialize functions.

### Subtasks
- [ ] T‑006l‑01: Create `agentStore` with versioning — **AGENT** `/apps/web/src/stores/agentStore.ts`

---

### T‑006m: promptStore
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑006b

### Definition of Done
- [ ] promptStore created with versioning
- [ ] Persisted with version, migrate, partialize
- [ ] Uses useShallow for object selectors

### Rules to Follow
- **FE‑02**: Zustand v5.
- **FE‑10**: Always use `useShallow` when selecting objects.
- **FE‑12**: Slices cannot import each other – cross‑slice access via `get()`.
- **FE‑32**: Zustand persist must include version, migrate, and partialize functions.

### Subtasks
- [ ] T‑006m‑01: Create `promptStore` with versioning — **AGENT** `/apps/web/src/stores/promptStore.ts`

---

### T‑006n: Zustand Slices Verification
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑006a, T‑006b, T‑006c, T‑006d, T‑006e, T‑006f, T‑006g, T‑006h, T‑006i, T‑006j, T‑006k, T‑006l, T‑006m

### Definition of Done
- [ ] Each slice verified to comply with ZUSTANDCIRCULAR rule (no cross‑imports)
- [ ] App runs and stores rehydrate correctly

### Subtasks
- [ ] T‑006n‑01: Verify each slice complies with ZUSTANDCIRCULAR rule (no cross‑imports) — **AGENT** (lint check)
- [ ] T‑006n‑02: Run the app and check that stores rehydrate correctly — **HUMAN**

---

### T‑007: Frontend Auth UI & Protected Routes
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑004, T‑005, T‑006  

### Definition of Done
- [ ] `LoginPage` and `SignupPage` with Supabase email/pw auth.
- [ ] `ProtectedRoute` wrapper that redirects unauthenticated users.
- [ ] Zustand `authSlice.onAuthStateChange` listener that invalidates TanStack Query cache.
- [ ] Persistent auth state across page reloads (httpOnly cookie handled by Supabase).

### Out of Scope
- OAuth providers, passkeys, MFA.

### Rules to Follow
- **SEC‑08**: JWT only in httpOnly cookie; never in localStorage/Zustand.
- **FE‑05**: Use `react-helmet-async` for document head.
- **FE‑16**: Empty states always render `EmptyState` component.

### Advanced Coding Patterns
- Use **Supabase’s `onAuthStateChange`** to sync Zustand’s `authSlice` and invalidate queries.
- **TanStack Query’s `QueryClient.clear()`** on org switch.

### Anti‑Patterns
- ❌ Storing JWT in Zustand as a plain string.
- ❌ Using `localStorage` to persist auth tokens.
- ❌ Redirecting with `window.location.href` instead of React Router’s `Navigate`.

### Subtasks
- [ ] T‑007‑01: Build `LoginPage` with form, call `signInWithPassword`, handle errors — **AGENT** `/apps/web/src/pages/LoginPage.tsx`
- [ ] T‑007‑02: Build `SignupPage` with form, call `signUp`, show verification message — **AGENT** `/apps/web/src/pages/SignupPage.tsx`
- [ ] T‑007‑03: Implement `ProtectedRoute` component that checks `authSlice.session` — **AGENT** `/apps/web/src/components/ProtectedRoute.tsx`
- [ ] T‑007‑04: Wire `onAuthStateChange` in `App.tsx` to keep session in sync — **AGENT** `/apps/web/src/App.tsx`
- [ ] T‑007‑05: Add TanStack Query invalidation logic on auth state change — **AGENT** `/apps/web/src/lib/queryClient.ts`
- [ ] T‑007‑06: Style forms with Tailwind and glass‑effect (liquid glass) — **AGENT**
- [ ] T‑007‑07: Manually test sign‑up, login, logout, and protected redirect — **HUMAN**

---

### T‑008: Basic CI/CD Pipeline (GitHub Actions)
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001, T‑003, T‑005  

### Definition of Done
- [ ] GitHub Actions workflow runs on every PR: typecheck (tsc frontend, mypy backend), lint (ESLint, ruff), test:unit, test:component, test:rls.
- [ ] Orval codegen integrity check passes (once configured).
- [ ] TypeScript `tsc --erasableSyntaxOnly --noEmit` enforced.
- [ ] Alembic migration check runs.

### Out of Scope
- AI evaluation, contract tests, Docker build, Sentry upload (later).

### Rules to Follow
- **BE‑15**: tsc gate.
- **BE‑12**: Orval ≥8.2.0.
- **BE‑14**: Grype for Docker (not yet used).

### Advanced Coding Patterns
- Use **composite actions** for shared setup steps (pnpm install, Python venv).
- Python linting via `ruff` and type-check with `mypy`.

### Anti‑Patterns
- ❌ Skipping Python type checking.
- ❌ Running AI evaluations in every PR.

### Subtasks
- [ ] T‑008‑01: Create `.github/workflows/ci.yml` with checkout, install (pnpm + python), typecheck steps — **AGENT** `.github/workflows/ci.yml`
- [ ] T‑008‑02: Add `lint` job using ESLint and `ruff` — **AGENT**
- [ ] T‑008‑03: Add `test:unit` and `test:component` jobs (Vitest) — **AGENT**
- [ ] T‑008‑04: Add `test:rls` job with pgTAP (requires Supabase connection) — **AGENT**
- [ ] T‑008‑05: Add Alembic migration check — **AGENT**
- [ ] T‑008‑06: Add `orval:codegen` check (if OpenAPI spec present, placeholder) — **AGENT**
- [ ] T‑008‑07: Verify CI passes on a PR with a dummy change — **HUMAN**
- [ ] T‑008‑08: Create `.github/workflows/deploy.yml` (auto‑deploy to Fly.io / Vercel on merge to main) — **AGENT**
- [ ] T‑008‑09: Create `dependabot.yml` for security updates — **AGENT**
- [ ] T‑008‑10: Create `CODEOWNERS` file (optional) — **AGENT**

---

### T‑009: Local AI – Ollama & Model Registry
**Status:** 📋 Not Started | **Block:** 0B | **Dependencies:** T‑001  

### Definition of Done
- [ ] Ollama ≥0.21.1 running in Docker with custom image (curl installed for healthcheck).
- [ ] `OLLAMA_KEEP_ALIVE=24h` and `OLLAMA_LOAD_TIMEOUT=120s` configured.
- [ ] Gemma 4 E2B, Qwen3.5 4B pulled, quantized (GGUF Q4_K_M), and listed in model registry.
- [ ] Health check at `GET /api/tags` returns available models.
- [ ] CLI command to verify SHA‑256 hashes of downloaded models.

### Out of Scope
- Cloud models (LiteLLM will handle separately).
- Verifier model (Phase 1).

### Rules to Follow
- **AI‑01**: Default orchestrator: Gemma 4 E2B (local); fallback Qwen3.5 4B.
- **AI‑02**: Free tier – local models only.
- **AI‑25**: All local models registered before use.
- **AI‑26**: Quantisation: GGUF Q4_K_M (<4.5GB RAM).

### Advanced Coding Patterns
- Docker Compose with bind mount for model storage.
- Model registry as `models.json`.

### Anti‑Patterns
- ❌ Running models without SHA‑256 hash verification.
- ❌ Using cloud models for free‑tier users – must be blocked at proxy.

### Subtasks
- [ ] T‑009‑01: Write Dockerfile for Ollama (add curl) and `docker-compose.yml` — **AGENT** `/infra/ollama/Dockerfile`, `/docker-compose.yml`
- [ ] T‑009‑01a: Set `OLLAMA_KEEP_ALIVE=24h`, `OLLAMA_LOAD_TIMEOUT=120s` in compose — **AGENT**
- [ ] T‑009‑02: Pull Gemma 4 E2B (2B) and Qwen3.5 4B via Ollama — **HUMAN**
- [ ] T‑009‑03: Create model registry JSON with SHA‑256 — **AGENT** `/data/model-registry.json`
- [ ] T‑009‑04: Write health check script that calls Ollama’s `/api/tags` — **AGENT** `/scripts/check-ollama.sh`
- [ ] T‑009‑05: Verify models respond with a test prompt — **HUMAN**

---

### T‑010: LiteLLM Proxy & Intent Dispatcher
**Status:** 📋 Not Started | **Block:** 0B | **Dependencies:** T‑003, T‑009  

### Definition of Done
- [ ] LiteLLM ≥1.83.7 running as a Docker container with cosign verification.
- [ ] Proxy configured with routing priority: Gemma (order 1) → Qwen (order 2) → Sonnet (3) → Opus (4). Free tier blocked from cloud models.
- [ ] Intent Dispatcher routes deterministic tools to code, lightweight NLP to local models, complex to cloud.
- [ ] Synchronous pre‑call budget check stub returns 429 if budget exceeded.

### Out of Scope
- Full cost logging (TimescaleDB not yet set up).
- Verifier integration.

### Rules to Follow
- **BE‑01**: All AI calls through LiteLLM.
- **AI‑01**: Default orchestrator local.
- **AI‑02**: Free‑tier restricted to local models.
- **AI‑11**: Pre‑call budget check.

### Advanced Coding Patterns
- LiteLLM’s `router` with `model_list` and `order` for priority.
- Dispatcher as FastAPI middleware inspecting `x-litellm-tags`.

### Anti‑Patterns
- ❌ Bypassing proxy for any AI call.
- ❌ Hardcoding API keys directly in config – use env vars.

### Subtasks
- [ ] T‑010‑01: Write Dockerfile for LiteLLM with cosign verify step — **AGENT** `/infra/litellm/Dockerfile`
- [ ] T‑010‑02: Configure `litellm_config.yaml` with local Ollama and cloud API placeholders, set routing order — **AGENT** `/infra/litellm/config.yaml`
- [ ] T‑010‑03: Create FastAPI middleware that routes requests to LiteLLM — **AGENT** `/apps/backend/app/proxy.py`
- [ ] T‑010‑04: Implement rudimentary Intent Dispatcher: map tool names to executor — **AGENT** `/apps/backend/app/dispatcher.py`
- [ ] T‑010‑05: Add `GET /v1/ai-status` endpoint that checks LiteLLM health — **AGENT** `/apps/backend/app/api/ai.py`
- [ ] T‑010‑06: Test: send a simple prompt through proxy, verify it reaches Ollama — **HUMAN**

---

### T‑011: Chat – SSE Streaming Backend
**Status:** 📋 Not Started | **Block:** 0C | **Dependencies:** T‑003, T‑010  

### Definition of Done
- [ ] `POST /v1/chat` endpoint accepts a message, streams tokens back via Server‑Sent Events using `sse-starlette`.
- [ ] Uses LiteLLM proxy (local model by default).
- [ ] Tool‑calling flows supported: endpoint can accept tool results and continue streaming.

### Out of Scope
- LangGraph Supervisor integration (next task).
- Guardrails (task T‑014).

### Rules to Follow
- **BE‑01**: All AI calls through proxy.
- **BE‑05**: /v1/* follows OpenAPI contract.
- **FE‑06**: Dates via Temporal.ZonedDateTime (not relevant but keep consistency).

### Advanced Coding Patterns
- Use `sse-starlette`’s `EventSourceResponse` for proper connection management.
- Heartbeats every 15‑20 seconds.

### Anti‑Patterns
- ❌ Returning full response at once (must be streaming).
- ❌ Blocking the event loop with synchronous loops.

### Subtasks
- [ ] T‑011‑01: Implement `POST /v1/chat` endpoint with request validation — **AGENT** `/apps/backend/app/api/chat.py`
- [ ] T‑011‑01a: Install `sse-starlette` and use `EventSourceResponse` — **AGENT**
- [ ] T‑011‑02: Create SSE stream generator that calls LiteLLM proxy and yields tokens — **AGENT** `/apps/backend/app/services/streaming.py`
- [ ] T‑011‑03: Write unit test with a mock LiteLLM response — **AGENT** `/apps/backend/tests/test_chat.py`
- [ ] T‑011‑04: Test streaming in browser via curl or simple HTML page — **HUMAN**

---

### T‑012a: ThreadList with Infinite Scroll
**Status:** 📋 Not Started | **Block:** 0C | **Dependencies:** T‑005, T‑006, T‑011

### Definition of Done
- [ ] `ThreadList` component with infinite scroll using TanStack Query's `useInfiniteQuery`
- [ ] `ThreadListItem` component for individual thread items
- [ ] Empty state handled

### Rules to Follow
- **FE‑16**: Empty states always render `EmptyState` component.
- **FE‑17**: Loading: skeleton if <2s; spinner if >2s.
- **FE‑18**: Error: retry button + message.

### Advanced Coding Patterns
- **TanStack Query's `useInfiniteQuery`** for thread list pagination.

### Subtasks
- [ ] T‑012a‑01: Build `ThreadList` and `ThreadListItem` components — **AGENT** `/apps/web/src/components/chat/ThreadList.tsx`

---

### T‑012b: MessageList with Virtuoso
**Status:** 📋 Not Started | **Block:** 0C | **Dependencies:** T‑005, T‑006, T‑011

### Definition of Done
- [ ] `MessageList` component virtualized using `react-virtuoso`'s `VirtuosoMessageList`
- [ ] Imperative data management for message updates
- [ ] Empty state handled

### Rules to Follow
- **FE‑16**: Empty states always render `EmptyState` component.
- **FE‑17**: Loading: skeleton if <2s; spinner if >2s.
- **FE‑18**: Error: retry button + message.

### Subtasks
- [ ] T‑012b‑01: Build `MessageList` with `VirtuosoMessageList` — **AGENT** `/apps/web/src/components/chat/MessageList.tsx`

---

### T‑012c: ChatInput with SlashMenu
**Status:** 📋 Not Started | **Block:** 0C | **Dependencies:** T‑005, T‑006, T‑011

### Definition of Done
- [ ] `ChatInput` component with slash menu
- [ ] Static commands in slash menu
- [ ] Keyboard shortcuts (Cmd+Enter to send)
- [ ] Optimistic send with client-generated message ID

### Rules to Follow
- **FE‑20**: Optimistic mutations: pending = opacity 0.5 + italic + pulse; 5s undo for delete.
- **FE‑22**: Only transform and opacity can be animated.

### Subtasks
- [ ] T‑012c‑01: Build `ChatInput` with `SlashMenu` (static commands) — **AGENT** `/apps/web/src/components/chat/ChatInput.tsx`
- [ ] T‑012c‑02: Add optimistic send with client‑generated message ID — **AGENT**

---

### T‑012d: useSSE Hook
**Status:** 📋 Not Started | **Block:** 0C | **Dependencies:** T‑005, T‑006, T‑011

### Definition of Done
- [ ] `useSSE` hook to parse streamed tokens from `text/event-stream`
- [ ] Handles connection errors and reconnection logic

### Advanced Coding Patterns
- **`useSSE`** hook consuming `text/event-stream`.

### Subtasks
- [ ] T‑012d‑01: Create `useSSE` hook to parse streamed tokens — **AGENT** `/apps/web/src/hooks/useSSE.ts`

---

### T‑012e: useChat Hook with Custom Transport
**Status:** 📋 Not Started | **Block:** 0C | **Dependencies:** T‑005, T‑006, T‑011, T‑012d

### Definition of Done
- [ ] `useChat` hook using `@ai-sdk/react` with custom transport to `/v1/chat`
- [ ] Forwards credentials (httpOnly cookie)
- [ ] StaleTime: Infinity for AI responses
- [ ] Debounce input

### Rules to Follow
- **SEC‑08**: JWT only in httpOnly cookie; forwarded via credentials.

### Advanced Coding Patterns
- **`@ai-sdk/react`** with custom transport to FastAPI.
- Debounce input; staleTime: Infinity for AI responses.

### Subtasks
- [ ] T‑012e‑01: Create `useChat` hook using `@ai-sdk/react` with custom transport to `/v1/chat`, forwarding credentials — **AGENT** `/apps/web/src/hooks/useChat.ts`

---

### T‑012f: Chat UI Styling & Testing
**Status:** 📋 Not Started | **Block:** 0C | **Dependencies:** T‑012a, T‑012b, T‑012c, T‑012d, T‑012e

### Definition of Done
- [ ] Glass effect styling applied to chat components
- [ ] Respects `prefers-reduced-motion`
- [ ] Full chat flow tested manually

### Rules to Follow
- **FE‑22**: Only transform and opacity can be animated.
- **FE‑23**: Respect `prefers-reduced-motion`.

### Subtasks
- [ ] T‑012f‑01: Style with glass effect and respect `prefers-reduced-motion` — **AGENT**
- [ ] T‑012f‑02: Test the full chat flow manually — **HUMAN**

---

### T‑013: Agent Tools & LangGraph Supervisor
**Status:** 📋 Not Started | **Block:** 0C | **Dependencies:** T‑010, T‑011  

### Definition of Done
- [ ] LangGraph Supervisor state machine defined.
- [ ] At least the following tools implemented: `create_event`, `update_event`, `delete_event`, `list_tasks`, `create_task`.
- [ ] Tool‑calling loop works via SSE endpoint: assistant can call tool, backend executes, stream continues.
- [ ] Supervisor uses `AsyncPostgresSaver` for checkpointing (production ready).

### Out of Scope
- Full MCP integration.
- Multiple worker agents (single supervisor for now).
- LangMem (separate task later).

### Rules to Follow
- **BE‑09**: Idempotency keys.
- **AI‑16**: Tool‑calling precision ≥90%.

### Advanced Coding Patterns
- **LangGraph’s `create_supervisor`** with a dummy worker agent.
- Tools defined with JSON schema and `preferred_executor`.

### Anti‑Patterns
- ❌ Running tools without schema validation (Pydantic).
- ❌ Not logging tool calls to audit_logs.

### Subtasks
- [ ] T‑013‑01: Install `langgraph` and define a simple supervisor agent — **AGENT** `/apps/backend/app/agents/supervisor.py`
- [ ] T‑013‑01a: Replace `InMemorySaver` with `AsyncPostgresSaver` — **AGENT**
- [ ] T‑013‑02: Implement `calendar_tools.py` with create/update/delete event — **AGENT** `/apps/backend/app/tools/calendar_tools.py`
- [ ] T‑013‑03: Implement `task_tools.py` with list/create task — **AGENT** `/apps/backend/app/tools/task_tools.py`
- [ ] T‑013‑04: Wire tools into the chat endpoint so that tool calls are executed mid‑stream — **AGENT** `/apps/backend/app/api/chat.py`
- [ ] T‑013‑05: Write a basic integration test that triggers a tool call — **AGENT** `/apps/backend/tests/test_tools.py`
- [ ] T‑013‑06: Verify tool execution flow manually via chat UI — **HUMAN**

---

### T‑014: Guardrails – Input & Output Layers
**Status:** 📋 Not Started | **Block:** 0C | **Dependencies:** T‑011  

### Definition of Done
- [ ] Input guardrails: PII detection (presidio), jailbreak detection (simple regex/LlamaGuard), toxicity screening (local model).
- [ ] Output guardrails: basic factual consistency check (LM‑judge stub).
- [ ] All guardrail decisions logged to `audit_logs`.
- [ ] Blocking for jailbreak/PII; warning for toxicity.

### Out of Scope
- Full DeepEval evaluation suite.
- Runtime guard (tool auth, cost) – addressed elsewhere.

### Rules to Follow
- **AI‑07**, **AI‑08**, **AI‑09**: Three‑layer guardrails.
- **AI‑10**: All decisions to `audit_logs`.

### Advanced Coding Patterns
- Use **Guardrails‑AI** or custom middleware.
- Asynchronous calls to lightweight local models for classification.

### Anti‑Patterns
- ❌ Running guardrails on every SSE token – only on final output.
- ❌ Not logging decision and confidence score.

### Subtasks
- [ ] T‑014‑01: Install `presidio-analyzer` and `presidio-anonymizer` — **AGENT** `/apps/backend/requirements.txt`
- [ ] T‑014‑02: Implement `input_guard.py` checking PII, jailbreak, toxicity — **AGENT** `/apps/backend/app/guardrails/input_guard.py`
- [ ] T‑014‑03: Implement `output_guard.py` with simple factual consistency check — **AGENT** `/apps/backend/app/guardrails/output_guard.py`
- [ ] T‑014‑04: Write `audit_log` helper that inserts into `audit_logs` — **AGENT** `/apps/backend/app/services/audit.py`
- [ ] T‑014‑05: Integrate guards into chat endpoint — **AGENT** `/apps/backend/app/api/chat.py`
- [ ] T‑014‑06: Test with a known jailbreak prompt and verify block — **HUMAN**

---

### T‑015: Calendar – Events CRUD & API
**Status:** 📋 Not Started | **Block:** 0D | **Dependencies:** T‑002, T‑003  

### Definition of Done
- [ ] FastAPI endpoints: `POST /v1/events`, `GET /v1/events`, `PUT /v1/events/{id}`, `DELETE /v1/events/{id}` (soft delete).
- [ ] All endpoints validate `org_id` from JWT and apply RLS.
- [ ] `events` table includes `timezone`, `all_day_flag`, `recurrence_id`.
- [ ] Idempotency keys used for create/update.

### Out of Scope
- Recurrence engine expansion (T‑017).
- Google Calendar sync.

### Rules to Follow
- **BE‑05**: /v1/ endpoints OpenAPI 3.1 contract – start documenting.
- **BE‑08**: Soft deletes via `deleted_at`.
- **BE‑09**: Idempotency.

### Advanced Coding Patterns
- Use **Pydantic models** for request/response validation.
- Auto‑generate OpenAPI schema with FastAPI’s `openapi.json`.

### Anti‑Patterns
- ❌ Hard deletes.
- ❌ Accepting dates without timezone.

### Subtasks
- [ ] T‑015‑01: Define Pydantic schemas for Event create/update/read — **AGENT** `/apps/backend/app/schemas/event.py`
- [ ] T‑015‑02: Implement `event_service.py` with CRUD + soft‑delete — **AGENT** `/apps/backend/app/services/event_service.py`
- [ ] T‑015‑03: Create API router for `/v1/events` — **AGENT** `/apps/backend/app/api/events.py`
- [ ] T‑015‑04: Write unit tests with mocked SQLModel session — **AGENT** `/apps/backend/tests/test_events.py`
- [ ] T‑015‑05: Add to OpenAPI spec manually or extract from FastAPI — **AGENT** `/apps/backend/openapi.json`
- [ ] T‑015‑06: Test endpoints with Postman or curl — **HUMAN**

The next 15 tasks (T‑016 – T‑030) continue the refreshed Phase 0 list, incorporating all critical hidden gaps as subtasks within the existing flow. These tasks cover the full data apps, AI backbone, monetization, security, and the new foundational services needed before deployment.

---

### T‑016a: MonthView
**Status:** 📋 Not Started | **Block:** 0D | **Dependencies:** T‑005, T‑006, T‑015  

### Definition of Done
- [ ] `MonthView` component built using `react-big-calendar`.
- [ ] Styled with OKLCH tokens.
- [ ] Skeleton loaders added.
- [ ] Times displayed in user's `Temporal.ZonedDateTime`.

### Rules to Follow
- **FE‑03**: `react-big-calendar` pinned to ^1.19.4.
- **FE‑06**: Use `Temporal.ZonedDateTime`; never `PlainDateTime`.
- **FE‑34**: Never hardcode colours – reference CSS custom properties.

### Subtasks
- [ ] T‑016a‑01: Build `MonthView` component — **AGENT** `/apps/web/src/components/calendar/MonthView.tsx`
- [ ] T‑016a‑02: Style with OKLCH tokens; add skeleton loaders — **AGENT**

---

### T‑016b: WeekDayView
**Status:** 📋 Not Started | **Block:** 0D | **Dependencies:** T‑005, T‑006, T‑015  

### Definition of Done
- [ ] `WeekDayView` component built using `react-big-calendar`.
- [ ] Styled with OKLCH tokens.
- [ ] Skeleton loaders added.
- [ ] Times displayed in user's `Temporal.ZonedDateTime`.

### Rules to Follow
- **FE‑03**: `react-big-calendar` pinned to ^1.19.4.
- **FE‑06**: Use `Temporal.ZonedDateTime`; never `PlainDateTime`.
- **FE‑34**: Never hardcode colours – reference CSS custom properties.

### Subtasks
- [ ] T‑016b‑01: Build `WeekDayView` component — **AGENT** `/apps/web/src/components/calendar/WeekDayView.tsx`
- [ ] T‑016b‑02: Style with OKLCH tokens; add skeleton loaders — **AGENT**

---

### T‑016c: AgendaView
**Status:** 📋 Not Started | **Block:** 0D | **Dependencies:** T‑005, T‑006, T‑015  

### Definition of Done
- [ ] `AgendaView` component built using `react-big-calendar`.
- [ ] Styled with OKLCH tokens.
- [ ] Skeleton loaders added.
- [ ] Times displayed in user's `Temporal.ZonedDateTime`.

### Rules to Follow
- **FE‑03**: `react-big-calendar` pinned to ^1.19.4.
- **FE‑06**: Use `Temporal.ZonedDateTime`; never `PlainDateTime`.
- **FE‑34**: Never hardcode colours – reference CSS custom properties.

### Subtasks
- [ ] T‑016c‑01: Build `AgendaView` component — **AGENT** `/apps/web/src/components/calendar/AgendaView.tsx`
- [ ] T‑016c‑02: Style with OKLCH tokens; add skeleton loaders — **AGENT**

---

### T‑016d: EventComposer
**Status:** 📋 Not Started | **Block:** 0D | **Dependencies:** T‑005, T‑006, T‑015  

### Definition of Done
- [ ] `EventComposer` sheet/drawer built with form (title, time, timezone).
- [ ] Optimistic create/update mutations.
- [ ] Styled with OKLCH tokens.
- [ ] Skeleton loaders added.

### Rules to Follow
- **FE‑06**: Use `Temporal.ZonedDateTime`; never `PlainDateTime`.
- **FE‑09**: Z‑index Drawer 30, Modal 40.
- **FE‑20**: Optimistic mutations.
- **FE‑34**: Never hardcode colours – reference CSS custom properties.

### Subtasks
- [ ] T‑016d‑01: Build `EventComposer` sheet/drawer with form (title, time, timezone) — **AGENT** `/apps/web/src/components/calendar/EventComposer.tsx`
- [ ] T‑016d‑02: Style with OKLCH tokens; add skeleton loaders — **AGENT**

---

### T‑016e: EventDetailDrawer
**Status:** 📋 Not Started | **Block:** 0D | **Dependencies:** T‑005, T‑006, T‑015  

### Definition of Done
- [ ] `EventDetailDrawer` built with delete (soft) and 5s undo.
- [ ] Styled with OKLCH tokens.
- [ ] Skeleton loaders added.

### Rules to Follow
- **FE‑09**: Z‑index Drawer 30, Modal 40.
- **FE‑20**: Optimistic mutations, 5s undo for delete.
- **FE‑34**: Never hardcode colours – reference CSS custom properties.

### Subtasks
- [ ] T‑016e‑01: Build `EventDetailDrawer` with delete (soft) and undo — **AGENT** `/apps/web/src/components/calendar/EventDetailDrawer.tsx`
- [ ] T‑016e‑02: Style with OKLCH tokens; add skeleton loaders — **AGENT**

---

### T‑016f: dndFacade and Drag‑and‑Drop Wiring
**Status:** 📋 Not Started | **Block:** 0D | **Dependencies:** T‑016b  

### Definition of Done
- [ ] `dndFacade` created that wraps `@dnd-kit/core` (for non‑calendar drags).
- [ ] Drag‑and‑drop reschedule wired on `WeekDayView` using `withDragAndDrop` HOC.
- [ ] Keyboard alternatives for all drag operations (WCAG 2.5.7).

### Out of Scope
- Calendar DnD uses react-dnd internally (exception allowed per FE‑04).

### Rules to Follow
- **FE‑04**: dnd‑kit primary; calendar DnD exception allowed via `react-dnd` bridge.
- **FE‑26–28**: DnD via façade where possible; DragOverlay and keyboard alt.

### Advanced Coding Patterns
- **`withDragAndDrop` HOC** called outside the component to prevent scroll resets.

### Anti‑Patterns
- ❌ Importing dnd‑kit directly into calendar views (except the facade).

### Subtasks
- [ ] T‑016f‑01: Create `dndFacade` that wraps `@dnd-kit/core` — **AGENT** `/apps/web/src/lib/dndFacade.ts`
- [ ] T‑016f‑02: Wire drag‑and‑drop reschedule on `WeekDayView` using `withDragAndDrop` HOC — **AGENT**
- [ ] T‑016f‑03: Add keyboard alternatives for drag operations — **AGENT**

---

### T‑016g: Calendar Page Integration & Manual Walkthrough
**Status:** 📋 Not Started | **Block:** 0D | **Dependencies:** T‑016a, T‑016b, T‑016c, T‑016d, T‑016e, T‑016f  

### Definition of Done
- [ ] `CalendarPage` composed with all view components.
- [ ] Timezone selector added.
- [ ] Manual walkthrough completed: create, move, edit, delete events.

### Rules to Follow
- **FE‑06**: Use `Temporal.ZonedDateTime`; never `PlainDateTime`.

### Subtasks
- [ ] T‑016g‑01: Compose `CalendarPage` with all view components and timezone selector — **AGENT** `/apps/web/src/pages/CalendarPage.tsx`
- [ ] T‑016g‑02: Perform manual walkthrough: create, move, edit, delete events — **HUMAN**

---

### T‑017: Recurrence Engine & DST Handling
**Status:** 📋 Not Started | **Block:** 0D | **Dependencies:** T‑015, T‑016  

### Definition of Done
- [ ] Backend: `POST /v1/events` can create recurring events (rrule). `exdate` and exception storage supported.
- [ ] Frontend: `RecurringEditModal` with three edit modes (this, this and future, all).
- [ ] Recurrence engine uses `rschedule` + `@rschedule/temporal-date-adapter` on frontend.
- [ ] DST matrix tests pass (wall‑clock handling).

### Out of Scope
- Complex iCalendar import/export.

### Rules to Follow
- **FE‑06**: `rschedule` + Temporal adapter replaces rrule.js.
- **FE‑06**: Use `Temporal.ZonedDateTime` for all calendar events.
- **BE‑08**: ULID primary keys; soft deletes.

### Advanced Coding Patterns
- Use **`rschedule`** to generate occurrence instances client‑side.
- Store recurrence rule in `recurrence_rules` table separate from events.

### Anti‑Patterns
- ❌ Using `rrule.js` in frontend – must use `rschedule` + Temporal.
- ❌ Generating occurrences server‑side for every query.

### Subtasks
- [ ] T‑017‑01: Add `recurrence_rules` table and related SQLModel schema — **AGENT** `/apps/backend/app/models/recurrence.py`
- [ ] T‑017‑02: Create `POST /v1/recurrence` endpoint to store and retrieve rules — **AGENT** `/apps/backend/app/api/recurrence.py`
- [ ] T‑017‑03: Implement `rschedule` integration in a shared utility — **AGENT** `/packages/shared/recurrence.ts`
- [ ] T‑017‑03a: Install `@rschedule/temporal-date-adapter` — **AGENT** `/apps/web/package.json`
- [ ] T‑017‑04: Build `RecurringEditModal` component — **AGENT** `/apps/web/src/components/calendar/RecurringEditModal.tsx`
- [ ] T‑017‑05: Write DST test suite (at least 5 timezone/dst scenarios) — **AGENT** `/apps/web/tests/recurrence.test.ts`
- [ ] T‑017‑06: Test creating a weekly recurring event and verifying next occurrence — **HUMAN**

---

### T‑018: Tasks – CRUD & Kanban
**Status:** 📋 Not Started | **Block:** 0D | **Dependencies:** T‑002, T‑003  

### Definition of Done
- [ ] `tasks` table + API for CRUD, status changes, ordering.
- [ ] Kanban board with draggable columns and tasks (dnd‑kit).
- [ ] Optimistic status toggles (Todo → In Progress → Done) with pulse animation.
- [ ] EmptyState when no tasks exist.

### Out of Scope
- Nested subtasks, checklist UI, project‑level gantt.

### Rules to Follow
- **FE‑20**: Optimistic mutations, undo for deletes.
- **FE‑21**: Max 3 staggered children.
- **FE‑26–28**: DnD with façade, DragOverlay, keyboard alt.

### Advanced Coding Patterns
- Use **`@dnd-kit/sortable`** for vertical reordering within a column.
- Persist `order` field via backend.

### Anti‑Patterns
- ❌ Animating layout property during drag (use `transform`).
- ❌ Not providing keyboard shortcuts for reordering.

### Subtasks
- [ ] T‑018‑01: Create `TaskApi` endpoints: list, create, update, delete, reorder — **AGENT** `/apps/backend/app/api/tasks.py`
- [ ] T‑018‑02: Build `KanbanView` component with columns — **AGENT** `/apps/web/src/components/projects/KanbanView.tsx`
- [ ] T‑018‑03: Implement `TaskCard` with inline status toggle and delete — **AGENT** `/apps/web/src/components/projects/TaskCard.tsx`
- [ ] T‑018‑04: Wire drag‑and‑drop for tasks and columns via dnd‑kit façade — **AGENT**
- [ ] T‑018‑05: Style with Tailwind, add aria attributes for accessibility — **AGENT**
- [ ] T‑018‑06: Test moving tasks between columns and verify persistence — **HUMAN**

---

### T‑019: Google Calendar Read‑Only Sync
**Status:** 📋 Not Started | **Block:** 0D | **Dependencies:** T‑003, T‑015  

### Definition of Done
- [ ] `connected_accounts` table records Google OAuth grant.
- [ ] OAuth2 flow implemented in FastAPI (Google Calendar read‑only scope).
- [ ] `OAuthCallbackPage` on frontend handles the redirect and displays success/error.
- [ ] Periodic background job fetches events from Google Calendar API and upserts into local `events` table, linked to user’s `org_id`.

### Out of Scope
- Writing back to Google Calendar.
- Full Nylas integration.

### Rules to Follow
- **BE‑03**: Nylas/Google only from FastAPI.
- **BE‑08**: Soft deletes (if event removed from Google, mark deleted).

### Advanced Coding Patterns
- Use **`google-auth-library`** for OAuth2 and token refresh.
- **Background job** with `APScheduler`.

### Anti‑Patterns
- ❌ Storing Google tokens in plain text (encrypt at rest).
- ❌ Pulling events too frequently (respect quota).

### Subtasks
- [ ] T‑019‑01: Register Google OAuth app and obtain client ID/secret — **HUMAN**
- [ ] T‑019‑02: Implement `GET /v1/oauth/google` and callback to store grant — **AGENT** `/apps/backend/app/api/oauth.py`
- [ ] T‑019‑02a: Build `OAuthCallbackPage` component — **AGENT** `/apps/web/src/pages/OAuthCallbackPage.tsx`
- [ ] T‑019‑03: Write sync service that fetches Google events and upserts — **AGENT** `/apps/backend/app/services/google_sync.py`
- [ ] T‑019‑04: Schedule sync job every 15 minutes — **AGENT**
- [ ] T‑019‑05: Test with a real Google account and verify events appear — **HUMAN**

---

### T‑020a: Enable Realtime on Supabase Tables
**Status:** 📋 Not Started | **Block:** 0E | **Dependencies:** T‑002  

### Definition of Done
- [ ] Realtime enabled on `notifications` table.
- [ ] Realtime enabled on `events` table.
- [ ] Realtime enabled on `tasks` table.

### Rules to Follow
- **BE‑07**: Supabase Realtime channel limits (100 total, 20 per user).

### Subtasks
- [ ] T‑020a‑01: Enable Realtime on Supabase for `notifications` table — **HUMAN** (Supabase Dashboard)
- [ ] T‑020a‑02: Enable Realtime on `events` and `tasks` tables — **HUMAN**

---

### T‑020b: useRealtime Hook
**Status:** 📋 Not Started | **Block:** 0E | **Dependencies:** T‑020a  

### Definition of Done
- [ ] `useRealtime` hook created that subscribes to Supabase channel.
- [ ] Hook handles subscription lifecycle (subscribe/unsubscribe).
- [ ] Hook updates local state on INSERT events.

### Rules to Follow
- **BE‑07**: Supabase Realtime channel limits (100 total, 20 per user).

### Advanced Coding Patterns
- Use **Supabase Realtime's `channel.on('INSERT', ...)`** to update local state.

### Subtasks
- [ ] T‑020b‑01: Create `useRealtime` hook that subscribes to channel — **AGENT** `/apps/web/src/hooks/useRealtime.ts`

---

### T‑020c: AmbientStatusBanner
**Status:** 📋 Not Started | **Block:** 0E | **Dependencies:** T‑005, T‑020b  

### Definition of Done
- [ ] `AmbientStatusBanner` component built with loading state.
- [ ] Styled with liquid glass and motion guard.
- [ ] Skeleton loaders added.

### Rules to Follow
- **FE‑21**: Max 3 staggered children.
- **FE‑23**: Respect prefers-reduced-motion.

### Subtasks
- [ ] T‑020c‑01: Build `AmbientStatusBanner` with loading state — **AGENT** `/apps/web/src/components/dashboard/AmbientStatusBanner.tsx`
- [ ] T‑020c‑02: Style with liquid glass and motion guard — **AGENT**

---

### T‑020d: ActivityFeed
**Status:** 📋 Not Started | **Block:** 0E | **Dependencies:** T‑005, T‑020b  

### Definition of Done
- [ ] `ActivityFeed` component built with virtualization.
- [ ] Styled with liquid glass and motion guard.
- [ ] EmptyState for empty feeds.
- [ ] Skeleton loaders added.

### Rules to Follow
- **FE‑16**: EmptyState for empty feeds.
- **FE‑21**: Max 3 staggered children.
- **FE‑35**: WCAG 2.2 AA, aria-live for feed.

### Advanced Coding Patterns
- **TanStack Query's `useInfiniteQuery`** for activity history.

### Anti‑Patterns
- ❌ Showing `ActivityFeed` without `role="log"` and `aria‑live`.

### Subtasks
- [ ] T‑020d‑01: Build `ActivityFeed` with virtualization — **AGENT** `/apps/web/src/components/dashboard/ActivityFeed.tsx`
- [ ] T‑020d‑02: Style with liquid glass and motion guard — **AGENT**

---

### T‑020e: AttentionQueue
**Status:** 📋 Not Started | **Block:** 0E | **Dependencies:** T‑005, T‑020b  

### Definition of Done
- [ ] `AttentionQueue` component built as collapsible right panel.
- [ ] Styled with liquid glass and motion guard.
- [ ] Skeleton loaders added.

### Rules to Follow
- **FE‑21**: Max 3 staggered children.
- **FE‑23**: Respect prefers-reduced-motion.

### Subtasks
- [ ] T‑020e‑01: Build `AttentionQueue` as a collapsible right panel — **AGENT** `/apps/web/src/components/dashboard/AttentionQueue.tsx`
- [ ] T‑020e‑02: Style with liquid glass and motion guard — **AGENT**

---

### T‑020f: Dashboard Page Composition
**Status:** 📋 Not Started | **Block:** 0E | **Dependencies:** T‑020c, T‑020d, T‑020e  

### Definition of Done
- [ ] `Dashboard` page composed with `AmbientStatusBanner`, `ActivityFeed`, `AttentionQueue`.
- [ ] Notifications created server-side (e.g., when conflict detected).
- [ ] UI updates in real-time with Supabase Realtime.
- [ ] Manual walkthrough completed: trigger notification and confirm it appears.

### Out of Scope
- Proactive notification engine (Phase 1).
- Cross-user conflict detection.

### Rules to Follow
- **BE‑07**: Supabase Realtime channel limits (100 total, 20 per user).

### Subtasks
- [ ] T‑020f‑01: Build `Dashboard` page layout — **AGENT** `/apps/web/src/pages/DashboardPage.tsx`
- [ ] T‑020f‑02: Manually trigger a notification and confirm it appears in dashboard — **HUMAN**

---

### T‑021: Conflict Detection Agent
**Status:** 📋 Not Started | **Block:** 0E | **Dependencies:** T‑013, T‑015, T‑018  

### Definition of Done
- [ ] `detect_conflicts` tool implemented (pure code). Checks overlapping events/tasks, cross‑app.
- [ ] Orchestrator can call this tool via chat; results appear as a message.
- [ ] `resolve_conflict` tool (reschedule, ignore) updates underlying records.
- [ ] Conflict notifications are created and pushed via Realtime.

### Out of Scope
- External email conflict parsing (Phase 1).
- Proactive scanning (only on‑demand via chat or button).

### Rules to Follow
- **AI‑01**: Use deterministic code for conflict detection.
- **BE‑09**: Idempotency for resolution actions.

### Advanced Coding Patterns
- **Overlap algorithm** using temporal comparison with ZonedDateTime.
- Separate **`ConflictService`** that can be called from both chat tool and dashboard.

### Anti‑Patterns
- ❌ Using an LLM to compare dates – deterministic only.
- ❌ Not handling multi‑timezone comparisons.

### Subtasks
- [ ] T‑021‑01: Create `ConflictService` that queries events and tasks for overlaps — **AGENT** `/apps/backend/app/services/conflict.py`
- [ ] T‑021‑02: Register `detect_conflicts` as a tool with `preferred_executor: code` — **AGENT** `/apps/backend/app/tools/conflict_tools.py`
- [ ] T‑021‑03: Implement `resolve_conflict` tool (update event/task, create notification) — **AGENT**
- [ ] T‑021‑04: Write unit tests for overlap logic — **AGENT** `/apps/backend/tests/test_conflict.py`
- [ ] T‑021‑05: Test via chat: ask assistant to check conflicts, see result, resolve — **HUMAN**

---

### T‑022: AI Cost Logging (TimescaleDB)
**Status:** 📋 Not Started | **Block:** 0E | **Dependencies:** T‑002, T‑010  

### Definition of Done
- [ ] `ai_cost_log` hypertable created in TimescaleDB (or via extension on Supabase).
- [ ] LiteLLM proxy emits cost data with `x-litellm-tags` (org_id, user_id, feature).
- [ ] Background job (or middleware) writes cost records to `ai_cost_log`.
- [ ] Basic admin query to see token usage per org.

### Out of Scope
- Admin dashboard (Phase 2).
- Budget enforcement (T‑023).

### Rules to Follow
- **AI‑14**: `ai_cost_log` is a TimescaleDB hypertable.
- **AI‑11**: Pre‑call budget check stub.

### Advanced Coding Patterns
- Use **TimescaleDB continuous aggregates** for daily usage summaries.
- **Trigger** on LiteLLM’s callbacks or post‑request hook.

### Anti‑Patterns
- ❌ Using a regular table for high‑volume cost data (must be hypertable).
- ❌ Missing `org_id` in cost logs.

### Subtasks
- [ ] T‑022‑01: Add `ai_cost_log` migration and convert to hypertable — **AGENT** `/apps/backend/alembic/versions/`
- [ ] T‑022‑02: Configure LiteLLM to send callback to a new endpoint `/v1/cost/webhook` — **AGENT** `/infra/litellm/config.yaml`
- [ ] T‑022‑03: Implement `/v1/cost/webhook` endpoint that parses cost data and inserts — **AGENT** `/apps/backend/app/api/cost.py`
- [ ] T‑022‑04: Write a simple SQL query to verify cost records — **AGENT**
- [ ] T‑022‑05: Make a few AI calls and confirm costs logged — **HUMAN**

---

### T‑023a: Cost Budgets Model & Admin API
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** T‑003, T‑022  

### Definition of Done
- [ ] `stripe` Python package installed.
- [ ] `cost_budgets` table created with monthly limits per org/team/user/model.
- [ ] Admin API endpoints for CRUD operations on cost budgets.

### Out of Scope
- Team‑level budgets (single org for now).
- Self‑service plan management.

### Rules to Follow
- **AI‑11**, **AI‑12**: Multi‑level budgets (org, team, user, model).

### Subtasks
- [ ] T‑023a‑01: Install `stripe` Python package — **AGENT** `/apps/backend/requirements.txt`
- [ ] T‑023a‑02: Create `cost_budgets` SQLModel class — **AGENT** `/apps/backend/app/models/cost_budgets.py`
- [ ] T‑023a‑03: Create admin API endpoints for cost budgets CRUD — **AGENT** `/apps/backend/app/api/cost_budgets.py`

---

### T‑023b: Pre‑Call Budget Middleware
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** T‑023a  

### Definition of Done
- [ ] Budget check middleware implemented for `/v1/chat` and other AI endpoints.
- [ ] Returns 429 when budget exceeded.
- [ ] Hard cap enforced at proxy level.

### Rules to Follow
- **SEC‑18**: Hard cap at proxy level.
- **AI‑13**: Hard stop at 0% remaining.

### Advanced Coding Patterns
- Middleware that checks `cost_budgets` before forwarding to LiteLLM.

### Anti‑Patterns
- ❌ Allowing AI calls without budget check.

### Subtasks
- [ ] T‑023b‑01: Implement budget check middleware in `/v1/chat` and other AI endpoints — **AGENT** `/apps/backend/app/middleware/budget.py`

---

### T‑023c: CostLimitBanner Component
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** T‑023b  

### Definition of Done
- [ ] `CostLimitBanner` component built.
- [ ] Displays when 429 response received from budget check.
- [ ] Shows remaining budget and upgrade options.

### Subtasks
- [ ] T‑023c‑01: Build `CostLimitBanner` component — **AGENT** `/apps/web/src/components/CostLimitBanner.tsx`

---

### T‑023d: Stripe Webhook Endpoint
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** T‑023a  

### Definition of Done
- [ ] `POST /v1/webhooks/stripe` endpoint created.
- [ ] Signature verification using `stripe.Webhook.construct_event`.
- [ ] Handles `invoice.paid` and `customer.subscription.updated` events.

### Advanced Coding Patterns
- **Stripe webhook signature verification** using `stripe.Webhook.construct_event`.

### Anti‑Patterns
- ❌ Not verifying webhook signatures.

### Subtasks
- [ ] T‑023d‑01: Create `POST /v1/webhooks/stripe` endpoint with signature verification — **AGENT** `/apps/backend/app/api/webhooks.py`

---

### T‑023e: Meter Events & Alert Thresholds
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** T‑023a  

### Definition of Done
- [ ] Meter events sent to Stripe after AI calls via `stripe.billing.MeterEvent.create()`.
- [ ] Alert logic implemented (15%, 5%, 0% thresholds).
- [ ] Notifications sent at each threshold.

### Rules to Follow
- **AI‑13**: Alert thresholds (15%, 5%, 0%) fire notifications.

### Advanced Coding Patterns
- Background tasks for sending meter events (don't block AI calls).

### Anti‑Patterns
- ❌ Blocking AI calls while sending meter events to Stripe – use background tasks.

### Subtasks
- [ ] T‑023e‑01: Implement `MeterEvent` creation in cost service — **AGENT** `/apps/backend/app/services/cost.py`
- [ ] T‑023e‑02: Add alert logic that sends notification at thresholds — **AGENT**

---

### T‑023f: Stripe Listen Script & Testing
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** T‑023b, T‑023c, T‑023d, T‑023e  

### Definition of Done
- [ ] `scripts/stripe-listen.sh` created to forward webhooks to local FastAPI.
- [ ] End‑to‑end test: low budget exceeded, verify 429 and banner.
- [ ] Webhook tested with Stripe CLI.

### Subtasks
- [ ] T‑023f‑01: Create `scripts/stripe-listen.sh` to forward webhooks to local FastAPI — **AGENT**
- [ ] T‑023f‑02: Test with a low budget and exceed it, verify 429 and banner; test webhook with Stripe CLI — **HUMAN**
---

### T‑024: CSP, Rate Limiting & Audit
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** T‑005, T‑007  

### Definition of Done
- [ ] CSP header set with nonce, strict‑dynamic, `style-src-attr 'unsafe-inline'` for motion.
- [ ] Rate limiting via FastAPI‑Limiter + Upstash Redis – token bucket, 429 responses.
- [ ] Upstash Redis instance provisioned and env vars set.
- [ ] Basic audit logging of all mutations (WORM pattern with hash chaining stub).

### Out of Scope
- Full SOC2 evidence collection.
- Advanced dynamic rate limits per plan.

### Rules to Follow
- **SEC‑06**: Global CSP enforced in production.
- **SEC‑07**: `unsafe-eval` only for sandboxed iframes.
- **SEC‑11**: Nonce cryptographically random.
- **SEC‑14**: Rate limiting per user/org.

### Advanced Coding Patterns
- Use FastAPI middleware for CSP nonce generation and header injection.
- **Upstash** rate limiter with sliding window.

### Anti‑Patterns
- ❌ CSP using `unsafe-inline` for scripts (only nonce).
- ❌ Not differentiating rate limits per user type.

### Subtasks
- [ ] T‑024‑01: Provision Upstash Redis instance (free tier) — **HUMAN** (Upstash Dashboard)
- [ ] T‑024‑01a: Add Upstash connection details to `.env.example` — **AGENT**
- [ ] T‑024‑02: Implement CSP middleware in FastAPI (generate nonce per request) — **AGENT** `/apps/backend/app/core/csp.py`
- [ ] T‑024‑03: Configure rate limiting with Upstash Redis — **AGENT** `/apps/backend/app/core/rate_limit.py`
- [ ] T‑024‑04: Add `audit_logs` insertion to all mutation endpoints — **AGENT** modify services
- [ ] T‑024‑05: Verify CSP headers with browser devtools — **HUMAN**
- [ ] T‑024‑06: Simulate 101 req/min and confirm 429 — **HUMAN**

---

### T‑025: Seed Data Script
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑002  

### Definition of Done
- [ ] A Python seed script (`alembic/seed.py`) that creates a demo org, user, projects, tasks, and events using SQLModel.
- [ ] Script detects if data already exists and skips (idempotent).
- [ ] Used by all developers to bootstrap a local environment quickly.

### Out of Scope
- Production data; only development/staging.

### Rules to Follow
- **BE‑08**: ULID primary keys via `gen_random_ulid()`.
- **BE‑09**: Idempotency ensured by checking existing records.
- **BE‑10**: Use `asyncio.run()` to execute the SQLModel session.

### Advanced Coding Patterns
- Use `asyncio.run()` to execute the SQLModel session.
- Create demo organisation and automatically set as active.

### Anti‑Patterns
- ❌ Hard‑coding production credentials.
- ❌ Using JavaScript/TypeScript for backend seed logic.
- ❌ Not using `asyncio.run()` for SQLModel execution.

### Subtasks
- [ ] T‑025‑01: Write `alembic/seed.py` with org, user, project, task, event — **AGENT** `/apps/backend/alembic/seed.py`
- [ ] T‑025‑02: Add `"seed": "python alembic/seed.py"` to backend scripts — **AGENT** `/apps/backend/package.json` (scripts for turbo)
- [ ] T‑025‑03: Run seed and confirm data appears in local Supabase — **HUMAN**
- [ ] T‑025‑01a: (Optional) Create `supabase/seed.sql` for Supabase CLI seeding — **AGENT**
---

### T‑026: Basic Error Tracking – Sentry Setup
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑003, T‑005  

### Definition of Done
- [ ] Sentry SDK (`sentry-sdk` for Python, `@sentry/react` for frontend) installed.
- [ ] Initialized in `main.py` and `main.tsx` with DSN from environment.
- [ ] All uncaught errors reported; PII stripping enabled (masking emails, etc.).
- [ ] Vite build uploads source maps to Sentry, removing them from the public bundle.

### Out of Scope
- Full four‑project setup with Session Replay (Phase 1).

### Rules to Follow
- **ADR 114**: Four Sentry projects eventually; we start with basic tracking.
- **SEC‑26**: PII stripping.

### Advanced Coding Patterns
- Use `Sentry.init` with `beforeSend` callback.
- Backend integration via `SentryAsgiMiddleware`.

### Anti‑Patterns
- ❌ Shipping source maps to production without uploading to Sentry.

### Subtasks
- [ ] T‑026‑01: Install Sentry SDKs (`sentry-sdk`, `@sentry/react`) — **AGENT** `/apps/backend/requirements.txt`, `/apps/web/package.json`
- [ ] T‑026‑02: Configure Sentry in `main.py` and `main.tsx` — **AGENT** `/apps/backend/app/main.py`, `/apps/web/src/main.tsx`
- [ ] T‑026‑03: Enable source map upload in Vite build — **AGENT** `/apps/web/vite.config.ts`
- [ ] T‑026‑04: Trigger a test error and confirm it appears in Sentry dashboard — **HUMAN**

---

### T‑027: Resend Email Service Setup
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑003  

### Definition of Done
- [ ] Resend Python SDK installed.
- [ ] Internal `email_service.py` sends transactional emails via Resend.
- [ ] Supabase Auth configured to use Resend SMTP for password reset and email verification (or custom templates via internal endpoint).
- [ ] Welcome email template ready.

### Out of Scope
- Marketing emails.

### Rules to Follow
- **ADR 088**: Resend is primary transactional email provider.

### Advanced Coding Patterns
- Use `resend` Python package; API key in environment.
- Send emails asynchronously via FastAPI’s `BackgroundTasks`.

### Anti‑Patterns
- ❌ Using Supabase’s built‑in email without Resend for production.

### Subtasks
- [ ] T‑027‑01: Install `resend` — **AGENT** `/apps/backend/requirements.txt`
- [ ] T‑027‑02: Create `email_service.py` wrapper — **AGENT** `/apps/backend/app/services/email_service.py`
- [ ] T‑027‑03: Configure Supabase Auth to use Resend SMTP — **HUMAN** (Supabase Dashboard)
- [ ] T‑027‑04: Test password reset email delivery — **HUMAN**

---

### T‑028: OpenAPI Specification Generation & Commit
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑003  

### Definition of Done
- [ ] FastAPI generates `openapi.json` via a Python script (`scripts/export_openapi.py`), committed to `apps/backend/openapi.json`.
- [ ] The spec serves as the single source of truth for API contracts.
- [ ] CI step verifies that the committed spec matches the running FastAPI app (no drift).

### Out of Scope
- Manual editing of the spec.

### Rules to Follow
- **BE‑05**: /v1/* endpoints follow OpenAPI 3.1 contract.
- **ADR 058**: OpenAPI 3.1 as single source of truth.

### Advanced Coding Patterns
- Use `app.openapi()` and write to file.
- Pre‑commit hook (or GitHub Action) that runs the script and fails if differences exist.

### Anti‑Patterns
- ❌ Manually writing OpenAPI YAML/JSON – the backend must be the source.

### Subtasks
- [ ] T‑028‑01: Create script `export_openapi.py` to write `openapi.json` — **AGENT** `/apps/backend/scripts/export_openapi.py`
- [ ] T‑028‑02: Run script and commit the initial spec — **AGENT** `/apps/backend/openapi.json`
- [ ] T‑028‑03: Add CI check for spec freshness — **AGENT** `.github/workflows/ci.yml`
- [ ] T‑028‑04: Validate spec with Spectral — **HUMAN**

---

### T‑029: PostHog Group Analytics Integration
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑006 (orgSlice)  

### Definition of Done
- [ ] `posthog-js` and `@posthog/react` installed.
- [ ] PostHog Provider wrapping the app.
- [ ] `posthog.group('company', orgId)` called on login and org switch; `posthog.resetGroup()` on logout.
- [ ] All subsequent events automatically scoped to the organisation.

### Out of Scope
- Full event taxonomy (defined later).

### Rules to Follow
- **ADR 126**: PostHog Group Analytics mandatory from day one for org‑scoped events.
- **SEC‑08**: JWT never exposed to PostHog; only org ID.

### Advanced Coding Patterns
- Use a `useEffect` in `AuthProvider` that watches `authSlice.session` and `orgSlice.currentOrgId`.
- Wrap PostHog Provider with `NuqsAdapter` (already done).

### Anti‑Patterns
- ❌ Calling `posthog.group` without first identifying the user.
- ❌ Forgetting `resetGroup` on logout, leaking org data.

### Subtasks
- [ ] T‑029‑01: Install `posthog-js` and `@posthog/react` — **AGENT** `/apps/web/package.json`
- [ ] T‑029‑02: Create PostHog provider wrapper in `providers/PostHogProvider.tsx` — **AGENT** `/apps/web/src/providers/PostHogProvider.tsx`
- [ ] T‑029‑03: Wire group identification in auth store listener — **AGENT** `/apps/web/src/stores/authSlice.ts`
- [ ] T‑029‑04: Verify that a test event appears in PostHog dashboard under the correct org — **HUMAN**

---

### T‑030: Orval Codegen & MSW Handlers
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑028 (OpenAPI spec)  

### Definition of Done
- [ ] Orval ≥8.2.0 installed and configured to generate TypeScript types and a typed fetch client from `openapi.json`.
- [ ] MSW handlers auto‑generated from the same spec; used in Vitest tests.
- [ ] CI step checks that generated files match the spec (integrity hash).

### Out of Scope
- Mocking WebSocket/SSE endpoints with MSW (covered later with AsyncAPI).

### Rules to Follow
- **BE‑12**: Orval ≥8.2.0; generate types from OpenAPI.
- **BE‑16**: MSW handlers generated from OpenAPI spec.

### Advanced Coding Patterns
- Use Orval’s `output` config to produce a single `api-client.ts` with `fetch` wrapper, configure `override` to add auth headers.
- Commit generated code to Git.

### Anti‑Patterns
- ❌ Manually writing API client types – must be generated.
- ❌ Running Orval on untrusted specs.

### Subtasks
- [ ] T‑030‑01: Install `orval` and `msw` — **AGENT** `/apps/web/package.json`
- [ ] T‑030‑02: Create `orval.config.ts` with output target — **AGENT** `/apps/web/orval.config.ts`
- [ ] T‑030‑03: Add codegen script and CI check — **AGENT** `/apps/web/package.json`
- [ ] T‑030‑04: Run generation and verify MSW mocks work in a sample test — **HUMAN**

Continuing with the next 15 refreshed Phase 0 tasks (T‑031 – T‑045). These complete the foundation, add the remaining critical components, and prepare deployment.

---

### T‑031: SanitizedHTML Component (Three DOMPurify Profiles)
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑005  

### Definition of Done
- [ ] Reusable `SanitizedHTML` component accepts a `profile` prop: `'STRICT' | 'RICH' | 'EMAIL'`.
- [ ] Each profile configures DOMPurify (≥3.4.0) with appropriate `ALLOWED_TAGS` and `ALLOWED_ATTR`.
- [ ] Component renders sanitised HTML safely; no XSS leaks.
- [ ] Unit test proves known malicious payloads are stripped.

### Out of Scope
- Markdown parsing (done later); only raw HTML safety.

### Rules to Follow
- **SEC‑01**: Use SanitizedHTML for all user‑generated HTML.
- **SEC‑10**: DOMPurify ≥3.4.0 mandatory.
- **ADR 112**: Three profiles required.

### Advanced Coding Patterns
- Use `DOMPurify.sanitize()` with per‑profile configuration; memoize output to avoid re‑sanitising on every render.
- TypeScript discriminated union for the `profile` prop.

### Anti‑Patterns
- ❌ Using `dangerouslySetInnerHTML` without sanitisation anywhere in the codebase.
- ❌ Storing raw HTML in the database – always sanitise before rendering.

### Subtasks
- [ ] T‑031‑01: Install `dompurify` and `@types/dompurify` — **AGENT** `/apps/web/package.json`
- [ ] T‑031‑02: Create `SanitizedHTML` component with three profiles — **AGENT** `/apps/web/src/components/SanitizedHTML.tsx`
- [ ] T‑031‑03: Write unit tests for XSS prevention — **AGENT** `/apps/web/src/__tests__/SanitizedHTML.test.tsx`
- [ ] T‑031‑04: Manually test with rich text snippets containing malicious payloads — **HUMAN**

---

### T‑032: Centralised API Client (`api.ts`)
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑003 (backend running), T‑004 (auth)  

### Definition of Done
- [ ] `api.ts` exports a pre‑configured `fetch` wrapper that:
  - Adds `Content-Type: application/json`.
  - Forwards httpOnly cookies (`credentials: 'include'`).
  - Handles 401 responses (redirect to login).
  - Injects `org_id` header (read from JWT by middleware).
- [ ] All frontend API calls use this client exclusively.

### Out of Scope
- Advanced retry logic (added later with offline queue).

### Rules to Follow
- **SEC‑09**: All `/v1/*` API calls through centralised `api.ts` client.

### Advanced Coding Patterns
- Use a simple `fetch` wrapper with a custom error class; integrate with TanStack Query’s `queryFn`.
- The httpOnly cookie is automatically sent – no manual token handling.

### Anti‑Patterns
- ❌ Calling `fetch` directly from components.
- ❌ Storing the JWT in any JavaScript variable.

### Subtasks
- [ ] T‑032‑01: Create `api.ts` with fetch wrapper — **AGENT** `/apps/web/src/lib/api.ts`
- [ ] T‑032‑02: Update chat hook and all existing API callers to use `api.ts` — **AGENT** `/apps/web/src/hooks/useChat.ts`
- [ ] T‑032‑03: Unit test that 401 triggers redirect — **AGENT** `/apps/web/src/__tests__/api.test.ts`
- [ ] T‑032‑04: Verify in browser that requests carry the session cookie — **HUMAN**

---

### T‑033: StorageService Wrapper for Supabase Storage
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑003 (Supabase client)  

### Definition of Done
- [ ] `StorageService` class (or set of functions) that wraps `supabase.storage` operations: `upload`, `download`, `getPublicUrl`, `remove`.
- [ ] Handles per‑org bucket scoping via `org_id`.
- [ ] File size/type validation before upload.

### Out of Scope
- CDN or advanced caching; will be used by Documents and Media apps later.

### Rules to Follow
- **SEC‑02**: Supabase storage access only via StorageService wrapper.

### Advanced Coding Patterns
- Use Supabase’s `createBucket` if not exists on first upload.
- Return typed results (`{ data, error }`) to match frontend expectations.

### Anti‑Patterns
- ❌ Calling `supabase.storage` directly from frontend components.

### Subtasks
- [ ] T‑033‑01: Create `storage_service.py` in backend — **AGENT** `/apps/backend/app/services/storage_service.py`
- [ ] T‑033‑02: Expose necessary endpoints (if needed) — **AGENT** `/apps/backend/app/api/storage.py`
- [ ] T‑033‑03: Test uploading a test file and retrieving its URL — **HUMAN**

---

### T‑034: LangMem Memory Configuration
**Status:** 📋 Not Started | **Block:** 0C | **Dependencies:** T‑013 (LangGraph Supervisor)  

### Definition of Done
- [ ] LangMem Python package installed.
- [ ] `PostgresStore` configured with the same Supabase connection pool.
- [ ] `create_manage_memory_tool` and `create_search_memory_tool` registered in the supervisor (for background summary creation).
- [ ] Chat sessions resume from previous memory (cross‑session).

### Out of Scope
- Interactive memory retrieval with low latency (LangMem is used for background summarisation; interactive retrieval will use Mem0 later).

### Rules to Follow
- **F015**: LangMem for cross‑session summaries (replaces simple FIFO memory).
- **AI‑10**: Memory decisions logged to audit_logs.

### Advanced Coding Patterns
- Namespace tools under user ID (`("user-123",)`) so memory is scoped per user.
- Use `InMemoryStore` for tests, `PostgresStore` for production with embedding index.

### Anti‑Patterns
- ❌ Using LangMem for real‑time interactive retrieval (59s latency) – background tasks only.

### Subtasks
- [ ] T‑034‑01: Install `langmem` — **AGENT** `/apps/backend/requirements.txt`
- [ ] T‑034‑02: Create LangMem manager in `services/memory.py` — **AGENT** `/apps/backend/app/services/memory.py`
- [ ] T‑034‑03: Wire tools into supervisor agent — **AGENT** `/apps/backend/app/agents/supervisor.py`
- [ ] T‑034‑04: Test that a chat conversation reappears after restart — **HUMAN**

---

### T‑035: llama.cpp + ik_llama.cpp Fork Setup (Optional Performance Accelerator)
**Status:** 📋 Not Started | **Block:** 0B | **Dependencies:** T‑009  

### Definition of Done
- [ ] `ik_llama.cpp` fork cloned and built locally (or via Docker).
- [ ] Benchmarked against stock llama.cpp for tool‑calling throughput on Tier 1 CPU.
- [ ] Documented as an alternative backend; can be swapped in via environment variable (for future use).

### Out of Scope
- Production deployment of the fork (remain on Ollama’s built‑in backend for Phase 0; the fork is evaluated and ready for later).

### Rules to Follow
- **F007**: llama.cpp + ik_llama.cpp fork: BitNet, fused MoE, hybrid GPU/CPU.
- **AI‑25**: All models registered – fork just changes serving layer.

### Advanced Coding Patterns
- Use a dedicated Docker image for the ik_llama.cpp fork with same model volumes as Ollama.
- Quantisation must match GGUF Q4_K_M.

### Anti‑Patterns
- ❌ Replacing Ollama entirely before evaluating the fork; it’s an optional accelerator.

### Subtasks
- [ ] T‑035‑01: Clone `ik_llama.cpp` and compile with `make` — **AGENT** `/infra/llama-cpp/`
- [ ] T‑035‑02: Run a simple benchmark (requests per second) against stock llama.cpp — **AGENT** `/scripts/benchmark-llamacpp.sh`
- [ ] T‑035‑03: Document the fallback mechanism in `README.md` — **AGENT**
- [ ] T‑035‑04: Confirm the fork produces identical outputs for a few test prompts — **HUMAN**

---

### T‑036: Calendar–Project Linking Integration
**Status:** 📋 Not Started | **Block:** 0D | **Dependencies:** T‑016 (Calendar UI), T‑018 (Tasks)  

### Definition of Done
- [ ] Tasks with a `due_date` appear as an overlay on the calendar (Month/WeekDay view).
- [ ] Clicking a task in the calendar opens the `TaskDetailDrawer`.
- [ ] Creating/updating a task’s due date automatically updates the calendar overlay.

### Out of Scope
- Full cross‑app conflict resolution (conflict agent covers that).

### Rules to Follow
- **FE‑06**: ZonedDateTime for all dates.
- **J001**: Cross‑app conflict detection; this is the UI foundation.

### Advanced Coding Patterns
- Use a custom `dateCellWrapper` in `react-big-calendar` to inject task badges.
- Fetch tasks for the visible date range using `useQuery` and filter client‑side.

### Anti‑Patterns
- ❌ Duplicating task data into events; always query tasks directly.

### Subtasks
- [ ] T‑036‑01: Create `CalendarTaskOverlay` component — **AGENT** `/apps/web/src/components/calendar/CalendarTaskOverlay.tsx`
- [ ] T‑036‑02: Wire into `MonthView` and `WeekDayView` — **AGENT** `/apps/web/src/components/calendar/`
- [ ] T‑036‑03: Test that a task with a due date shows on the calendar — **HUMAN**

---

### T‑037: Vitest Configuration & Frontend Test Setup
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑005  

### Definition of Done
- [ ] Vitest installed and configured in the web workspace with path aliases matching Vite.
- [ ] MSW handlers mocked globally; coverage thresholds set (unit ≥80%, component ≥85%).
- [ ] Sample test running for a Zustand slice and a React component.

### Out of Scope
- Full test suite; only scaffold and configuration.

### Rules to Follow
- Test runner must be Vitest (per blueprint).
- **BE‑16**: MSW handlers generated from OpenAPI (already set up in T‑030).

### Advanced Coding Patterns
- Use `vitest` with `@testing-library/react` for component tests.
- Configure `vite.config.ts` to also export a test configuration.

### Anti‑Patterns
- ❌ Using Jest instead of Vitest.
- ❌ Missing `jsdom` environment for component tests.

### Subtasks
- [ ] T‑037‑01: Install `vitest`, `@testing-library/react`, `jsdom`, `msw` — **AGENT** `/apps/web/package.json`
- [ ] T‑037‑02: Create `vitest.config.ts` with path aliases and coverage — **AGENT** `/apps/web/vitest.config.ts`
- [ ] T‑037‑03: Write a simple store test to confirm setup — **AGENT** `/apps/web/src/stores/__tests__/authSlice.test.ts`
- [ ] T‑037‑04: Run `pnpm test:unit` and verify output — **HUMAN**

---

### T‑038: Playwright E2E Initial Setup
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑005, T‑007  

### Definition of Done
- [ ] Playwright installed and basic configuration created.
- [ ] A single E2E smoke test: visits login, signs up, and verifies redirection to dashboard.
- [ ] CI job added for E2E (can run nightly or on demand to start).

### Out of Scope
- Full E2E suite; only scaffold and one critical path.

### Rules to Follow
- E2E tests must not rely on live backend; use MSW or a staging environment. (For now, a separate staging deployment.)

### Advanced Coding Patterns
- Use Playwright’s `test.use({ storageState })` to skip login for authenticated tests.
- Integrate into GitHub Actions with a dedicated job.

### Anti‑Patterns
- ❌ Running E2E tests against production without data isolation.

### Subtasks
- [ ] T‑038‑01: Install `playwright` and `@playwright/test` — **AGENT** `/apps/web/package.json`
- [ ] T‑038‑02: Create `playwright.config.ts` — **AGENT** `/apps/web/playwright.config.ts`
- [ ] T‑038‑03: Write a smoke test (`e2e/auth.spec.ts`) — **AGENT** `/apps/web/e2e/`
- [ ] T‑038‑04: Add CI job for E2E (optional, not blocking on PR for now) — **AGENT** `.github/workflows/ci.yml`
- [ ] T‑038‑05: Run the smoke test locally and confirm pass — **HUMAN**

---

### T‑039: Schemathesis Contract Test Setup
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑028 (OpenAPI spec)  

### Definition of Done
- [ ] Schemathesis installed and configured to run against a running FastAPI instance.
- [ ] CI job added that starts the backend, runs Schemathesis against `/v1/*` (ignore SSE/WS endpoints), and fails on contract violation.
- [ ] Initial report clean (no violations) with current API.

### Out of Scope
- Testing real‑time endpoints; Schemathesis only validates HTTP REST.

### Rules to Follow
- **BE‑05**: Schemathesis blocks merge on API drift.

### Advanced Coding Patterns
- Use `schemathesis run` with `--checks all` and an ignore file for SSE/WS endpoints.
- Generate a test report in CI.

### Anti‑Patterns
- ❌ Running Schemathesis against production without rate limiting.
- ❌ Expecting it to validate WebSocket/SSE – not supported.

### Subtasks
- [ ] T‑039‑01: Install `schemathesis` in backend dev dependencies — **AGENT** `/apps/backend/pyproject.toml`
- [ ] T‑039‑02: Create a script to start server and run Schemathesis — **AGENT** `/scripts/contract-test.sh`
- [ ] T‑039‑03: Add CI job that calls the script — **AGENT** `.github/workflows/ci.yml`
- [ ] T‑039‑04: Verify that current API passes contract tests (or fix violations) — **HUMAN**

---

### T‑040: Environment Variable Template & Validation
**Status:** 📋 Not Started | **Block:** 0A | **Dependencies:** T‑001  

### Definition of Done
- [ ] `.env.example` at the monorepo root lists every required environment variable for both backend and frontend with placeholders.
- [ ] Backend `config.py` uses `pydantic-settings` to load and validate the environment; application fails fast if required variables are missing.
- [ ] Frontend `EnvValidation` component (already built) references this list.

### Out of Scope
- Doppler/Vault integration (Phase 2).

### Rules to Follow
- **SEC‑11**: Secrets must be externalised; no hardcoded values.

### Advanced Coding Patterns
- Use `SettingsConfigDict(env_file='.env')` in `pydantic-settings`.
- For CI, provide secrets via GitHub Actions secrets.

### Anti‑Patterns
- ❌ Committing actual `.env` files with real keys.
- ❌ Starting the application with missing environment variables – fail immediately.

### Subtasks
- [ ] T‑040‑01: Create `.env.example` with all variables — **AGENT** `/.env.example`
- [ ] T‑040‑02: Create `config.py` with `pydantic-settings` — **AGENT** `/apps/backend/app/core/config.py`
- [ ] T‑040‑03: Update `main.py` to validate on startup — **AGENT**
- [ ] T‑040‑04: Verify backend refuses to start with missing vars — **HUMAN**

---

### T‑041‑docker: Production Dockerfile
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** T‑003–T‑024, T‑040  

### Definition of Done
- [ ] Production Dockerfile for FastAPI with multi-stage build.
- [ ] Image optimized for size and security.

### Rules to Follow
- Use multi-stage Dockerfile to keep image small.

### Subtasks
- [ ] T‑041‑docker‑01: Write production Dockerfile for FastAPI — **AGENT** `/apps/backend/Dockerfile`

---

### T‑041‑fly: Fly.io Configuration
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** T‑041‑docker  

### Definition of Done
- [ ] `fly.toml` configured with health checks, `auto_stop_machines = "suspend"`, `auto_start_machines = true`, `min_machines_running = 0`.
- [ ] Deployment script with `alembic upgrade head`.

### Rules to Follow
- **Deployment**: Fly.io machines v2.

### Subtasks
- [ ] T‑041‑fly‑01: Configure `fly.toml` with health checks and auto‑stop — **AGENT** `/apps/backend/fly.toml`
- [ ] T‑041‑fly‑02: Add `alembic upgrade head` to deployment script — **AGENT**

---

### T‑041‑secrets: Fly Secrets Setup
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** T‑041‑fly  

### Definition of Done
- [ ] Fly secrets configured for all required environment variables.
- [ ] No `.env` file in Docker image.

### Anti‑Patterns
- ❌ Pushing `.env` file with secrets into the Docker image.

### Subtasks
- [ ] T‑041‑secrets‑01: Set up Fly secrets for required variables — **HUMAN**

---

### T‑041‑deploy: Deploy & Verify
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** T‑041‑secrets  

### Definition of Done
- [ ] FastAPI app deployed to Fly.io.
- [ ] Supabase connection established via private networking (6PN) or connection string.
- [ ] Health check passes (`/health`).
- [ ] Full API smoke tests pass.

### Subtasks
- [ ] T‑041‑deploy‑01: Deploy to Fly.io — **HUMAN**
- [ ] T‑041‑deploy‑02: Verify `/health` endpoint — **HUMAN**
- [ ] T‑041‑deploy‑03: Run full API smoke tests — **HUMAN**
---

### T‑042‑vercel: Vercel Configuration
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** T‑005–T‑024, T‑040  

### Definition of Done
- [ ] `vercel.json` includes SPA rewrite, security headers, and **cache headers for `/assets/*`** (`max-age=31536000, immutable`).
- [ ] All routes serve `index.html` correctly (SPA fallback).

### Rules to Follow
- **FE‑01**: Vite SPA only.
- **SEC‑06**: CSP enforced in production (already configured in T‑024).

### Advanced Coding Patterns
- Use Vercel's `"headers"` configuration to set immutable caching on hashed assets.

### Anti‑Patterns
- ❌ Forgetting to set cache headers – each page load re‑downloads all assets.

### Subtasks
- [ ] T‑042‑vercel‑01: Create `vercel.json` with SPA rewrite, headers, and cache optimisation — **AGENT** `/apps/web/vercel.json`

---

### T‑042‑build: Build Verification
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** T‑042‑vercel  

### Definition of Done
- [ ] Vite SPA builds successfully.
- [ ] Build step outputs static files; no serverless functions needed.
- [ ] Build artifacts verified.

### Subtasks
- [ ] T‑042‑build‑01: Run local build and verify output — **HUMAN**

---

### T‑042‑deploy: Deploy & Verify
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** T‑042‑build  

### Definition of Done
- [ ] Vite SPA deployed to Vercel.
- [ ] Environment variables set for `VITE_API_URL`, `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`.
- [ ] App loads, login works, calendar and chat functional.

### Out of Scope
- Custom domain configuration (can be added later).

### Subtasks
- [ ] T‑042‑deploy‑01: Set environment variables in Vercel dashboard — **HUMAN**
- [ ] T‑042‑deploy‑02: Deploy via Git integration — **HUMAN**
- [ ] T‑042‑deploy‑03: Verify the app loads, login works, calendar and chat functional — **HUMAN**

---

### T‑043: Pre‑Launch Security Audit
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** All previous  

### Definition of Done
- [ ] Manual review of all endpoints for OWASP Top 10 LLM vulnerabilities.
- [ ] Prompt injection and jailbreak test suite executed using known attack vectors.
- [ ] No critical/high findings left unresolved.
- [ ] All RLS policies re‑verified with pgTAP.
- [ ] Secrets management verified – no hardcoded keys.

### Out of Scope
- Full SOC2 Type I (Phase 3).
- External penetration test.

### Rules to Follow
- **All SEC‑ rules**.

### Advanced Coding Patterns
- Use **OWASP ZAP** basic scan; AgentProbe for AI‑specific attacks.
- Document findings in a security report.

### Anti‑Patterns
- ❌ Relying solely on automated scanners; manual review required.

### Subtasks
- [ ] T‑043‑01: Run OWASP ZAP baseline scan against staging — **HUMAN**
- [ ] T‑043‑02: Execute AI‑specific adversarial test suite (jailbreaks, prompt leaks) — **HUMAN**
- [ ] T‑043‑03: Verify all secrets are in environment variables (no hardcoded keys) — **AGENT** (audit script)
- [ ] T‑043‑04: Review RLS test results from CI — **HUMAN**
- [ ] T‑043‑05: Document any findings and fix — **HUMAN/AGENT**

---

### T‑044: Production Environment Variable Audit & Doppler/Vault Preparation
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** T‑040, T‑041, T‑042  

### Definition of Done
- [ ] Checklist of all production environment variables for Fly.io, Vercel, Supabase, Upstash, LiteLLM, Resend, Stripe, Sentry, PostHog.
- [ ] All secrets confirmed to be set in their respective platforms (not in code).
- [ ] Doppler/Vault setup researched and documented for future automated rotation; manual rotation process in place for now.

### Out of Scope
- Full Doppler/Vault integration (Phase 2).

### Rules to Follow
- **SEC‑23**: Secret rotation failure is P1 incident.
- **SEC‑08**: JWT private key stored securely (Supabase manages it).

### Advanced Coding Patterns
- Create a `SECRETS.md` (not committed) as a temporary inventory.
- Use `fly secrets list`, Vercel environment UI.

### Anti‑Patterns
- ❌ Using the same API keys across all environments.
- ❌ Not knowing where secrets live.

### Subtasks
- [ ] T‑044‑01: Create a `secrets-inventory.md` (keep local, not committed) listing all secrets and their locations — **HUMAN**
- [ ] T‑044‑02: Verify each secret is set in its respective platform — **HUMAN**
- [ ] T‑044‑03: Test that backend and frontend can start without local `.env` files (reading from platform secrets) — **HUMAN**
- [ ] T‑044‑04: Document manual rotation procedure — **AGENT** `/docs/operations/secret-rotation.md`

---

### T‑045: Final Integration & Smoke Tests
**Status:** 📋 Not Started | **Block:** 0F | **Dependencies:** All tasks  

### Definition of Done
- [ ] A checklist‑driven smoke test executed against the staging environment:
  - Sign up, login, org switch.
  - Create a project, task, and event.
  - Chat with the assistant; verify SSE streaming and tool calling (e.g., “create a task”).
  - Dashboard shows notifications.
  - AI costs logged.
  - Stripe test mode shows a charge attempt.
- [ ] All Phase 0 exit criteria met.

### Out of Scope
- Load testing, UAT with real users (Phase 1).

### Rules to Follow
- **J001, J002**: Core jobs must work.

### Advanced Coding Patterns
- Use a manual test script; can be later automated with Playwright.
- Record a demo video as evidence.

### Anti‑Patterns
- ❌ Declaring Phase 0 done without a cross‑app scenario (calendar + tasks + chat).

### Subtasks
- [ ] T‑045‑01: Execute the full smoke test checklist — **HUMAN**
- [ ] T‑045‑02: Fix any blocking issues — **HUMAN/AGENT**
- [ ] T‑045‑03: Record demo video / screenshots — **HUMAN**
- [ ] T‑045‑04: Tag `v0.0.1` in Git — **HUMAN**
- [ ] T‑045‑05: Create `pnpm clean:all` script (calls `reset-dev.sh`) and verify clean environment — **AGENT**

---

**End of Phase 0 Task List**