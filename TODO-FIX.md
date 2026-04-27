To satisfy the requirement that each task is **SMALL** and **of a single kind**, the following parent tasks must be split. Many contain too many subtasks, or subtasks that are themselves large, mixing different concerns. A **small task** should be achievable in 1‑3 hours and focus on one deliverable (one component, one endpoint, one config file, etc.).

---

### Tasks Requiring Immediate Splitting

#### **T‑001 – Monorepo & Workspace Setup**
*26 subtasks, mixing tooling, scaffolding, CI, and documentation.*  
Split into individual tasks, each of the same kind:

- `T‑001‑root` – Root workspace initialisation (`pnpm-workspace.yaml`, `package.json`, `.npmrc`, `catalogMode`)
- `T‑001‑turbo` – Turborepo & base TypeScript config (`turbo.json`, `tsconfig.base.json`, pipelines)
- `T‑001‑backend` – Backend scaffold (FastAPI project, `pyproject.toml` with all tooling sections, `Dockerfile`, `package.json` for Turbo)
- `T‑001‑frontend` – Frontend scaffold (Vite + React + TS + Tailwind, `vite-env.d.ts`)
- `T‑001‑shared` – Shared package scaffold (`packages/shared`, path aliases)
- `T‑001‑lint` – ESLint & Prettier configuration (root configs, ignore files)
- `T‑001‑git` – Git hygiene (`.gitignore`, `.gitattributes`, `.editorconfig`, `.nvmrc`, `.python-version`)
- `T‑001‑husky` – Husky pre‑commit (lint + typecheck)
- `T‑001‑docs` – Root documentation (`README.md`, `CONTRIBUTING.md`, `PULL_REQUEST_TEMPLATE.md`)
- `T‑001‑docker` – Docker Compose & infrastructure (`docker-compose.yml`, `infra/clamav/`, `.dockerignore`)
- `T‑001‑windsurf` – `.windsurfrules` (stack constraints)

#### **T‑003 – FastAPI Backend Skeleton & Supabase Connection**
*15 subtasks, spanning core app, database, middleware, testing, logging.*  
Split into:

- `T‑003a` – FastAPI app with lifespan & `/health` endpoint
- `T‑003b` – Database engine & session factory (`database.py`, `get_db_session` dependency)
- `T‑003c` – JWT middleware & auth dependencies (`auth.py`)
- `T‑003d` – Core configuration (`config.py` with pydantic-settings, `constants.py`)
- `T‑003e` – Logging & telemetry (`logging_config.py`, `telemetry.py`)
- `T‑003f` – Cache wrapper (`cache.py`)
- `T‑003g` – API version router & deps (`api_v1.py`)
- `T‑003h` – Test conftest & DB readiness script (`conftest.py`, `db_check.py`)
- `T‑003i` – `__init__.py` files in all directories (or folded into each directory’s creation task)

#### **T‑005 – Vite SPA Shell & Design Tokens**
*26 subtasks, mixing CSS system, shell components, hooks, mocks, assets.*  
Split into:

- `T‑005a` – Tailwind 4 with OKLCH tokens (`tokens.css`, `index.css`, `postcss.config.js`)
- `T‑005b` – AppShell layout (header, sidebar, main, `AnimatePresence`)
- `T‑005c` – Sidebar navigation component
- `T‑005d` – React Router + `NuqsAdapter` + lazy routes
- `T‑005e` – `EnvValidation` component
- `T‑005f` – `ErrorBoundaryFallback` and wrapping
- `T‑005g` – `EmptyState` component
- `T‑005h` – `useReducedMotion` hook
- `T‑005i` – Temporal polyfill setup
- `T‑005j` – DOMPurify sanitizer (three profiles) – **already T‑031, keep separate**
- `T‑005k` – Zustand persistence wrapper (`persistence.ts`)
- `T‑005l` – MSW & Vitest initialisation (`mocks/browser.ts`, `test/setup.ts`)
- `T‑005m` – Static assets (`robots.txt`, `favicon.ico`)
- `T‑005n` – Global type definitions & `reset.css`
- `T‑005o` – `ui/index.ts` barrel export & locales directory

#### **T‑006 – Zustand Slices**
*13 subtasks, one per store slice.*  
**Split each slice into its own task:** every store slice (`authSlice`, `uiSlice`, etc.) is a small, independent unit. No single task should hold more than one slice.

#### **T‑012 – Chat UI**
*8 subtasks, multiple components and hooks.*  
Split into:

- `T‑012a` – `ThreadList` with infinite scroll
- `T‑012b` – `MessageList` with `VirtuosoMessageList`
- `T‑012c` – `ChatInput` with `SlashMenu`
- `T‑012d` – `useSSE` hook
- `T‑012e` – `useChat` hook (custom transport)

#### **T‑016 – Calendar UI**
*7 subtasks, multiple views.*  
Split into:

- `T‑016a` – `MonthView`
- `T‑016b` – `WeekDayView`
- `T‑016c` – `AgendaView`
- `T‑016d` – `EventComposer`
- `T‑016e` – `EventDetailDrawer`
- `T‑016f` – `dndFacade` and drag‑and‑drop wiring on `WeekDayView`

#### **T‑020 – Dashboard & Realtime**
*8 subtasks, mixed component creation.*  
Split into:

- `T‑020a` – Enable Realtime on Supabase tables (HUMAN step)
- `T‑020b` – `useRealtime` hook
- `T‑020c` – `AmbientStatusBanner`
- `T‑020d` – `ActivityFeed`
- `T‑020e` – `AttentionQueue`
- `T‑020f` – `Dashboard` page composition

#### **T‑023 – Stripe & Budgets**
*9 subtasks, billing + frontend + webhooks.*  
Split into:

- `T‑023a` – `cost_budgets` model & admin API
- `T‑023b` – Pre‑call budget middleware (429)
- `T‑023c` – `CostLimitBanner` component
- `T‑023d` – Stripe webhook endpoint & signature verification
- `T‑023e` – Meter event creation & alert thresholds
- `T‑023f` – Stripe listen script

#### **T‑024 – CSP, Rate Limiting & Audit**
*Three unrelated security layers.*  
Split into:

- `T‑024a` – CSP middleware (nonce)
- `T‑024b` – Rate limiting middleware (Upstash)
- `T‑024c` – Audit log helper & integration

#### **T‑041 / T‑042 – Deployments**
*Multiple steps mixing Docker, config, and human secrets.*  
Split into:

- Backend deployment: `T‑041-docker` (Dockerfile), `T‑041-fly` (fly.toml), `T‑041-secrets` (secrets setup), `T‑041-deploy` (deploy & smoke test)
- Frontend deployment: `T‑042-vercel` (vercel.json & config), `T‑042-build` (build verification), `T‑042-deploy`

---

### General Principle
**Every parent task with more than 4–5 subtasks, or with subtasks that are themselves nontrivial, must be broken into separate parent tasks.** This ensures each task is truly small, of a single type, and can be completed sequentially without context switching. All cross‑cutting (backend + frontend) tasks must also be split by discipline.

If you need the full re‑numbered task list after applying these changes, I can generate that as well.