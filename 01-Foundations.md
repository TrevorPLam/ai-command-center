# 01-Foundations — Personal AI Command Center Frontend (Enhanced v2)

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.
> **Versioning Note**: This document supersedes v1. See the Reasoning Memo below for all structural decisions.

---

## 📐 Reasoning Memo: Why This Version Is Structured Differently

Before the task list, here is the explicit reasoning behind every structural decision, answered directly.

### Question 1: Should we increase the number of parent tasks?

**Yes — from 11 to 14 tasks.** The v1 list had three structural problems:

**Problem A — FND-000 and FND-002 were duplicate tasks.** Both covered CSS-first design tokens and Tailwind v4 `@theme` configuration. They have been **merged into one task (FND-000)**, which eliminates the confusion of doing the "same thing twice" and the awkward dependency `FND-002 depends on FND-001 depends on FND-000`.

**Problem B — FND-001 was doing too much.** It bundled project scaffolding, *all* dependency installation, code quality toolchain (ESLint, Prettier), Git hooks, *and* provider wiring into a single task. That is four distinct concerns. Each has been given its own task. A developer should be able to complete "scaffold the project" in one focused session without also configuring ESLint 9's flat config (a non-trivial task in itself). This also allows better parallelization: a second developer can start on the testing infrastructure (FND-004) while the first finishes the toolchain (FND-003).

**Problem C — React Router v7 had no dedicated parent task.** It was buried as a line item in FND-001 with no subtasks, no definition of done, and no anti-patterns. React Router v7 introduces three distinct modes (declarative, data, framework) and the choice of `createBrowserRouter` with route-level lazy loading is a meaningful architectural decision that deserves its own task.

The new structure is: FND-000 through FND-013 (14 tasks).

### Question 2: Should we reprioritize anything?

**Yes — two changes:**

1. **Code quality toolchain (FND-003) is now 🔴 High** (was buried as subtasks inside FND-001 at medium importance). Research confirms ESLint 9's flat config is a non-trivial setup, and getting it wrong early means fixing lint debt across dozens of files later. It must be set up *before* writing any component code — not after.

2. **Provider Composition (FND-008) is now its own 🔴 High task.** The order of providers matters (`RouterProvider` → `QueryClientProvider` → `ThemeProvider`) and gets it wrong surprisingly often, causing subtle hydration/context bugs. Making this explicit prevents that.

### Question 3: Should testing be subtasks instead of a standalone task?

**Both — infrastructure stays standalone; test-writing becomes subtasks inside each component task.** This is the professional approach:

- **FND-004: Testing Infrastructure** remains a standalone task because you cannot write tests until Vitest, RTL, MSW, and Browser Mode are properly configured. This is pure toolchain work.
- **Every component task (FND-009 through FND-013) now ends with an explicit `Write Tests` subtask block.** This enforces the professional habit of writing tests *alongside* the component, not in a deferred batch. Deferred testing is where test coverage debt is born.

### Other Key Corrections from Research

| Finding | Source | Action |
|---------|--------|--------|
| Zustand docs say middleware must be applied *only* at the combined store level, not inside individual slices | Official Zustand docs | Added explicit anti-pattern warning |
| Motion v12 now supports `oklch()` color animation directly | Motion docs (March 2026) | Added to FND-000 advanced patterns |
| MSW `onUnhandledRequest: 'error'` is the correct best practice | Official MSW docs | Added to FND-004 |
| React Router v7 dropped the `react-router-dom` package — import is now just `react-router` | LogRocket Jan 2026 | Corrected in FND-007 |
| Vitest Browser Mode (not jsdom) is now the *recommended* path for component testing | Vitest docs March 2026 | FND-004 updated accordingly |
| ESLint 9 now has `defineConfig()` helper — use it | ESLint blog March 2025 | Added to FND-003 |
| `@testing-library/user-event` `userEvent.setup()` must be called per-test | RTL docs | Added to FND-004 |
| Zustand: don't prefix slice creator functions with `use` — breaks Rules of Hooks | Zustand discussion | Added anti-pattern |
| `persist` middleware: use `partialize` to persist only what's needed, not the whole store | Zustand docs | Added to FND-005 |

---

## 📋 Pre-Flight: 2026 Standards & Key Research Findings

| Concern | v1 Spec | **2026 Reality** | Status |
|---------|---------|-----------------|--------|
| **Tailwind v4 Config** | `tailwind.config.ts` | CSS-first via `@theme` in `index.css`. Config file ignored. | ✅ Confirmed |
| **Tailwind v4 Dark Mode** | Class toggle | `@custom-variant dark (&:where(.dark, .dark *));` | ✅ Confirmed |
| **Motion Library** | `motion` ≥11.0 | v12 — import from `motion/react`. Package renamed from `framer-motion`. | ✅ Confirmed |
| **Motion v12 OKLCH** | Not mentioned | v12 can animate `oklch()` color values directly | 🆕 **NEW** |
| **React Router** | "React Router v6" | v7 ships as `react-router` (not `react-router-dom`). Three modes: declarative, data, framework. | ⚠️ Updated |
| **Vitest Component Testing** | Browser Mode as optional | Browser Mode (Playwright) is now **recommended over jsdom** | ⚠️ Updated |
| **MSW Setup** | `server.listen()` | `server.listen({ onUnhandledRequest: 'error' })` — catch missing handlers | 🆕 **NEW** |
| **ESLint 9** | Flat config | `defineConfig()` helper is now available and preferred | 🆕 **NEW** |
| **Zustand Middleware** | On root store | Docs: middleware must be applied **only at the combined store**, not in slices | ⚠️ Critical |
| **WCAG Target** | 2.2 AA | 2.2 AA is the 2026 standard | ✅ Confirmed |

### 🎯 Motion Hierarchy (Motion v12)

| Level | Use Case | Allowed Techniques |
|-------|----------|--------------------|
| **Alive** | Core nav, state changes, feedback | Spring physics (`stiffness: 300, damping: 30`), `layoutId`, glow on hover |
| **Quiet** | Secondary elements, tooltips, reveals | Opacity fades, transitions ≤150ms |
| **Static** | Dense tables, repeated list items | No animation — instant changes |

**Motion v12 Performance Rules (non-negotiable):**
- Only animate `transform` and `opacity` — never `width`, `height`, `top`, `left`
- Use `layout` prop for size changes instead of explicit dimension animations
- Use `viewport={{ once: true }}` on scroll-triggered animations
- Use `useReducedMotion()` from `motion/react` — respect OS accessibility settings
- Use `useMotionValue` + `useTransform` for high-frequency updates (parallax, cursor tracking)
- `oklch()` colors can now be animated directly in v12 — use this for glow effects

---

## 🧱 Cross-Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **C-01** | Background Color | `#050507` (blue-shifted near-black) via `--background` CSS var |
| **C-02** | Motion Library | `motion` v12 — `import { motion } from "motion/react"` |
| **C-03** | Virtualisation | `@tanstack/react-virtual` (`useVirtualizer`) for all virtualized lists. This aligns with the TanStack ecosystem already in use (Query, Table). Existing `react-window` patterns in the Chat and News modules are acceptable implementations but should be considered technical debt to migrate when those modules are revisited. |
| **C-04** | Design Tokens | CSS custom properties + `@theme inline` mapping, `oklch()` required |
| **C-05** | Glass Scope | `.noise-overlay` only for shells, drawers, command palette |
| **C-06** | Reduced Motion | `useReducedMotion()` from `motion/react` — checked before every animation |
| **C-07** | Page Transitions | `AnimatePresence` + `motion.div` keyed by `location.pathname` |
| **C-08** | Focus Restoration | Store trigger ref in `uiSlice`; restore on modal/drawer close |
| **C-09** | Keyboard Hints | `<kbd>` tags (e.g. `⌘K`) |
| **C-10** | Accessibility | WCAG 2.2 AA — Focus Not Obscured (2.4.12), Target Size (2.5.8) |
| **C-11** | Test Pattern | `userEvent.setup()` called fresh per test; `screen` preferred over `container` |
| **C-12** | Router Import | `import { ... } from "react-router"` — NOT `react-router-dom` |
| **C-13** | Motion Tokens | All `motion` components must use shared tokens from `src/lib/motion.ts`. Inline animation objects (e.g., `transition={{ duration: 0.2 }}`) are prohibited outside of `src/lib/motion.ts`. |

---

## 🎨 Task FND-000: Design Tokens & CSS-First Theme System
**Priority:** 🔴 High | **Est. Effort:** 45 min | **Depends On:** None

> **Note:** This task merges the former FND-000 and FND-002 from v1. They covered the same concern and the split created redundant work.

### Related Files
- `src/index.css` · `src/components/theme-provider.tsx` · `src/components/theme-toggle.tsx`

### Subtasks
- [ ] **FND-000A**: Define the `@theme` block at the top of `src/index.css` immediately after `@import "tailwindcss";`
  - All color tokens use `oklch()` — no hex, no hsl. Example: `--color-accent: oklch(62% 0.19 264);`
  - Token categories: `--color-*`, `--font-*`, `--spacing-*`, `--radius-*`, `--shadow-*`
  - Use `@theme inline` (not bare `@theme`) so tokens generate both CSS vars *and* Tailwind utilities
- [ ] **FND-000B**: Configure dark mode selector variant: `@custom-variant dark (&:where(.dark, .dark *));`
  - Place this *before* the `@theme` block
  - Define light tokens in `:root {}` and dark tokens in `@layer theme { :root { @variant dark { ... } } }`
- [ ] **FND-000C**: Define semantic color tokens following shadcn/ui naming conventions (`--background`, `--foreground`, `--muted`, `--card`, `--border`, `--input`, `--ring`, `--primary`, `--secondary`, `--accent`, `--destructive`)
  - Set `--background` to `oklch(9.8% 0.006 264)` (renders as `#050507`)
  - Set `--ring` (accent) to `oklch(62% 0.19 264)` (renders as `#0066ff` - electric blue)
- [ ] **FND-000D**: Add `@layer base` block: apply `background-color` to `body`, set `color-scheme` on `:root`
- [ ] **FND-000E**: Add the `.noise-overlay` utility in `@layer utilities`
  - Uses a CSS `url("data:image/svg+xml,...")` noise pattern
  - Scope: only used on glass surfaces (sidebar, drawers, command palette)
- [ ] **FND-000F**: Add `@property` declarations for animated conic-gradient borders (used by AmbientStatusBanner)
- [ ] **FND-000G**: Create `ThemeProvider` component using `next-themes` with `attribute="class"`, `defaultTheme="dark"`, `enableSystem`
- [ ] **FND-000H**: Create `ThemeToggle` component (icon button, keyboard accessible, 24×24px minimum hit area)
- [ ] **FND-000I**: Create `src/lib/tokens.ts` — typed re-export of token names as TypeScript constants for safe consumption outside CSS:
  ```ts
  export const tokens = {
    background: 'oklch(9.8% 0.006 264)',
    accent: 'oklch(62% 0.19 264)',
  } as const;
  ```
- [ ] **FND-000J**: Create `src/lib/motion.ts` — shared animation tokens for consistent motion across the application:
  ```ts
  export const springAlive = { type: 'spring' as const, stiffness: 300, damping: 30 };
  export const fadeQuiet = { duration: 0.15 };
  ```
  These tokens enforce the Motion Hierarchy: use `springAlive` for Alive-tier elements (core nav, state changes), use `fadeQuiet` for Quiet-tier elements (tooltips, reveals), and no animation for Static-tier elements (dense tables).

> **Directory Convention Note (Optional):** Consider organizing animated components with a directory convention (`src/components/motion/` for Alive/Quiet, `src/components/static/` for Static) as a visual signal for reviewers. However, the primary enforcement mechanism is the code review checklist in POL-005G, not folder placement.

### Definition of Done
- No `tailwind.config.ts` file exists anywhere in the project
- `@theme inline` block contains all tokens with `oklch()` values
- `@custom-variant dark` directive is present
- Dark mode toggles correctly using class switching on `<html>`
- `body` background renders `#050507`
- `.noise-overlay` class is available
- `src/lib/tokens.ts` exports typed token constants
- `src/lib/motion.ts` exports shared animation tokens

### Anti-Patterns
- ❌ `tailwind.config.ts` with Tailwind v4 — this file is silently ignored
- ❌ Hex or HSL color values — breaks `bg-accent/50` alpha modifier syntax in v4
- ❌ `@apply` for component styles — use React components with Tailwind utilities instead
- ❌ Applying dark mode via `@media (prefers-color-scheme: dark)` alone — prevents manual toggle
- ❌ Bare `@theme` instead of `@theme inline` — `@theme` without `inline` does not generate Tailwind utilities from custom properties that reference other vars

---

## 🟢 Task FND-001: Project Scaffold & Vite Configuration
**Priority:** 🔴 High | **Est. Effort:** 30 min | **Depends On:** None

### Related Files
- `package.json` · `vite.config.ts` · `tsconfig.json` · `tsconfig.node.json` · `index.html`

### Subtasks
- [ ] **FND-001A**: Scaffold with Vite: `pnpm create vite@latest . --template react-ts`
- [ ] **FND-001B**: Configure `vite.config.ts`:
  - Add `@tailwindcss/vite` plugin (replaces PostCSS dependency for Vite projects)
  - Add `@vitejs/plugin-react` with `fastRefresh: true`
  - Add path alias: `resolve: { alias: { '@': path.resolve(__dirname, './src') } }`
  - Add `build.sourcemap: true` for production debugging
  - Add `optimizeDeps.exclude: ['motion']` to prevent pre-bundling animation library
- [ ] **FND-001C**: Configure `tsconfig.json`:
  - `"strict": true` — enables all strict checks
  - `"noUncheckedIndexedAccess": true` — catches unsafe array indexing
  - `"exactOptionalPropertyTypes": true` — distinguishes `undefined` from missing
  - `"paths": { "@/*": ["./src/*"] }` — must match vite alias
  - `"moduleResolution": "bundler"` — correct for Vite/ESM projects
- [ ] **FND-001D**: Add `@types/node` as a dev dependency for `path` access in `vite.config.ts`
- [ ] **FND-001E**: Create `src/index.css` with `@import "tailwindcss";` as its first and only line (tokens added in FND-000)
- [ ] **FND-001F**: Strip all Vite boilerplate from `src/App.tsx` and `src/main.tsx`; leave only entry points
- [ ] **FND-001G**: Verify `pnpm dev` starts successfully; verify background is `#050507`; verify `tsc --noEmit` passes

### Definition of Done
- Dev server starts on `localhost:5173` with blank `#050507` background
- TypeScript strict mode: `tsc --noEmit` passes with 0 errors
- Path alias `@/` resolves correctly in both TS and Vite
- No `tailwind.config.ts` anywhere

### Anti-Patterns
- ❌ `"moduleResolution": "node"` — this is for CommonJS. Vite projects must use `"bundler"` or `"node16"`/`"nodenext"`
- ❌ Forgetting to add `paths` in `tsconfig.json` to match the Vite alias — IDE won't resolve `@/` imports
- ❌ Using `@vitejs/plugin-react-swc` alongside `@tailwindcss/vite` without testing compatibility

---

## 🟢 Task FND-002: Core Dependencies Installation
**Priority:** 🔴 High | **Est. Effort:** 20 min | **Depends On:** FND-001

> **Note:** Separating dependency installation from project scaffold allows a clean commit boundary and prevents "I installed something and now Vite won't start" debugging sessions.

### Related Files
- `package.json` · `components.json` · `src/lib/utils.ts`

### Subtasks
- [ ] **FND-002A**: Install Tailwind v4 + Vite plugin: `pnpm add tailwindcss @tailwindcss/vite`
- [ ] **FND-002B**: Install shadcn/ui runtime deps: `pnpm add class-variance-authority clsx tailwind-merge lucide-react`
- [ ] **FND-002C**: Install animation: `pnpm add motion@12.38.0`
- [ ] **FND-002D**: Install state + data: `pnpm add zustand@5.0.12 immer @tanstack/react-query@5.99.2 zod@4.3.6`

> ⚠️ **Zod v4 Performance Note**  
> Zod v4 schema creation is 8–17× slower than v3. **All schemas must be defined at module scope.** Never define a schema inside a component body, hook, or render function. Use `z.infer<typeof schema>` to derive TypeScript types instead of writing separate interfaces.
- [ ] **FND-002E**: Install routing: `pnpm add react-router`
  - **CRITICAL:** The package is `react-router`, NOT `react-router-dom`. v7 merged the two.
- [ ] **FND-002F**: Install virtualisation: `pnpm add @tanstack/react-virtual@3.13.24`
- [ ] **FND-002G**: Install theme: `pnpm add next-themes`
- [ ] **FND-002H**: Install dev deps: `pnpm add -D tw-animate-css @types/node`
  - `tw-animate-css` replaces the deprecated `tailwindcss-animate`
- [ ] **FND-002I**: Create `src/lib/utils.ts` with the `cn()` utility using `clsx` + `tailwind-merge`
- [ ] **FND-002J**: Create `components.json` with **empty** `tailwind.config` field (required for shadcn v4 compat)
- [ ] **FND-002K**: Add first shadcn component: `pnpm dlx shadcn@latest add button` — verify it renders
- [ ] **FND-002L**: Install React Query DevTools: `pnpm add -D @tanstack/react-query-devtools`

> **Note:** These versions are confirmed as of April 23, 2026. Verify against the npm registry during implementation and update if patches have been released.

### Definition of Done
- All packages installed with no peer dependency warnings
- `import { motion } from "motion/react"` compiles without error
- `import { useNavigate } from "react-router"` compiles without error
- `<Button>Test</Button>` renders with correct shadcn styling
- `pnpm build` succeeds

### Anti-Patterns
- ❌ Installing `framer-motion` — deprecated; use `motion`
- ❌ Installing `react-router-dom` — merged into `react-router` in v7
- ❌ Installing `tailwindcss-animate` — deprecated; use `tw-animate-css`
- ❌ Importing from `"framer-motion"` — the package still exists but is no longer maintained

---

## 🛡️ Task FND-003: Code Quality Toolchain
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** FND-001

> **Why its own task:** ESLint 9's flat config is a non-trivial setup. Getting it wrong early means accumulating lint debt across all future component files. This must be established and verified *before writing any component code.*

### Related Files
- `eslint.config.js` · `.prettierrc` · `.prettierignore` · `.husky/` · `lint-staged.config.js` · `package.json`

### Subtasks
- [ ] **FND-003A**: Install ESLint 9 + plugins:
  ```
  pnpm add -D eslint @eslint/js typescript-eslint eslint-plugin-react
  eslint-plugin-react-hooks eslint-plugin-jsx-a11y globals
  eslint-config-prettier eslint-plugin-prettier prettier
  ```
- [ ] **FND-003B**: Create `eslint.config.js` using the new `defineConfig()` helper:
  - Use `tseslint.config(...)` as the outer wrapper
  - Include: `eslint.configs.recommended`, `tseslint.configs.recommendedTypeChecked`, `reactPlugin.configs.flat.recommended`, `reactPlugin.configs.flat['jsx-runtime']`, `reactHooks.configs.recommended`, `jsxA11y.flatConfigs.recommended`
  - Add `prettierRecommended` last (must come last to disable formatting rules)
  - Set `languageOptions.parserOptions.projectService: true` for type-aware linting
  - Disable TypeScript rules for `*.js/*.mjs` files with `tseslint.configs.disableTypeChecked`
  - Add `ignores: ['dist/', 'node_modules/', 'coverage/', '**/*.d.ts']`
- [ ] **FND-003C**: Create `.prettierrc`:
  ```json
  {
    "semi": true,
    "trailingComma": "all",
    "singleQuote": true,
    "printWidth": 100,
    "tabWidth": 2,
    "endOfLine": "lf"
  }
  ```
- [ ] **FND-003D**: Create `.prettierignore` (mirrors `.gitignore` entries: `dist/`, `node_modules/`, `*.generated.ts`)
- [ ] **FND-003E**: Add scripts to `package.json`:
  - `"lint": "eslint . --max-warnings 0"` — zero-tolerance lint policy
  - `"lint:fix": "eslint . --fix"`
  - `"format": "prettier --write \"src/**/*.{ts,tsx,css}\""`
  - `"format:check": "prettier --check \"src/**/*.{ts,tsx,css}\""`
- [ ] **FND-003F**: Install and configure `husky` + `lint-staged`:
  - `pnpm add -D husky lint-staged`
  - `pnpm exec husky init`
  - `lint-staged` config: run `eslint --fix` + `prettier --write` on staged `.ts/.tsx/.css` files
- [ ] **FND-003G**: Install `@commitlint/cli` + `@commitlint/config-conventional`; add `.husky/commit-msg` hook
  - Enforces conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`
- [ ] **FND-003H**: Run `pnpm lint` on the current (mostly empty) codebase — verify 0 errors

### Definition of Done
- `pnpm lint` passes with 0 warnings
- `pnpm format:check` passes
- Committing a file with a lint error is blocked by husky
- Committing with a non-conventional commit message is blocked
- Type-aware linting is active (slower but catches actual bugs)

### Anti-Patterns
- ❌ Using `.eslintrc.js` format — removed in ESLint 9
- ❌ Placing `prettierRecommended` anywhere except last in the config array
- ❌ Using `husky` without running `pnpm exec husky init` first — hooks won't fire
- ❌ Omitting `eslint-plugin-jsx-a11y` — accessibility rules must be enforced at lint time, not just audit time
- ❌ `--max-warnings 0` omitted from CI lint script — warnings silently become technical debt

---

## 🧪 Task FND-004: Testing Infrastructure
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** FND-001, FND-002

> **Note:** This task sets up the *infrastructure* only. Writing tests is a subtask within each subsequent feature task. If infrastructure is not set up before FND-009, developers will write untestable components and defer testing — which is where coverage debt begins.

### Related Files
- `vitest.config.ts` · `src/test/setup.ts` · `src/mocks/handlers.ts` · `src/mocks/server.ts` · `playwright.config.ts` (Browser Mode)

### Subtasks
- [ ] **FND-004A**: Install testing dependencies:
  ```
  pnpm add -D vitest @vitest/browser vitest-browser-react
  @testing-library/react @testing-library/jest-dom @testing-library/user-event
  msw playwright @vitest/coverage-v8
  ```
- [ ] **FND-004B**: Configure `vitest.config.ts`:
  ```ts
  export default defineConfig({
    test: {
      globals: true,
      // Use jsdom for unit/hook tests; Browser Mode for component tests
      environment: 'jsdom',
      setupFiles: ['./src/test/setup.ts'],
      coverage: {
        provider: 'v8',
        reporter: ['text', 'lcov', 'html'],
        include: ['src/**'],
        exclude: ['src/mocks/**', 'src/test/**', '**/*.d.ts'],
        thresholds: { lines: 80, branches: 75, functions: 80, statements: 80 }
      }
    }
  })
  ```
- [ ] **FND-004C**: Create `src/test/setup.ts`:
  - `import '@testing-library/jest-dom'`
  - Mock `window.matchMedia` (required for any component that uses media queries or dark mode)
  - Mock `IntersectionObserver` and `ResizeObserver`
  - `afterEach(() => cleanup())` — RTL auto-cleanup
- [ ] **FND-004D**: Configure MSW:
  - `src/mocks/handlers.ts` — empty array initially; populated per-domain
  - `src/mocks/server.ts` using `setupServer(...handlers)` from `msw/node`
  - Add to `setup.ts`: `beforeAll(() => server.listen({ onUnhandledRequest: 'error' }))`, `afterEach(() => server.resetHandlers())`, `afterAll(() => server.close())`
  - `onUnhandledRequest: 'error'` is critical — it catches tests that hit real network by accident
- [ ] **FND-004E**: Configure Vitest Browser Mode for component tests (add a separate `vitest.browser.config.ts`):
  - `provider: 'playwright'`, `browser: { name: 'chromium', headless: true }`
  - Use `vitest-browser-react` for rendering components in real browser context
  - Add script: `"test:browser": "vitest --config vitest.browser.config.ts"`
- [ ] **FND-004F**: Add test scripts to `package.json`:
  - `"test": "vitest"` — unit + hook tests (jsdom)
  - `"test:browser": "vitest --config vitest.browser.config.ts"` — component tests (real browser)
  - `"test:ui": "vitest --ui"` — visual test runner
  - `"test:coverage": "vitest run --coverage"`
  - `"test:ci": "vitest run --coverage"` — for CI pipeline
- [ ] **FND-004G**: Write a smoke test for the `cn()` utility to verify the setup works end-to-end
- [ ] **FND-004H**: Configure Motion test helpers:
  - Add `vi.useFakeTimers()` and `vi.runAllTimers()` pattern in a `src/test/motion-helpers.ts` file for testing animation completion states
- [ ] **FND-004I**: Verify `pnpm test` runs and the smoke test passes
- [ ] **FND-004J**: Add `coverage/` and `.vitest-cache/` to `.gitignore`

### Definition of Done
- `pnpm test` runs and passes
- `pnpm test:coverage` generates a coverage report
- MSW server starts/stops correctly around each test
- `window.matchMedia`, `IntersectionObserver`, `ResizeObserver` all mocked in setup
- Motion test helpers available

### Testing Pyramid for This Project
- **Unit** (Vitest + jsdom): Pure functions, Zustand slices, utility hooks — fast, numerous
- **Component** (Vitest Browser Mode + RTL): UI components — focus on behavior, not DOM structure
- **Integration** (Vitest + MSW): Components with mocked API responses
- **E2E** (Playwright): 3–5 critical flows (open app, run command palette, toggle sidebar, navigate routes)

### Anti-Patterns
- ❌ Omitting `onUnhandledRequest: 'error'` in MSW setup — tests silently make real HTTP calls
- ❌ Calling `userEvent.click()` without `userEvent.setup()` first — the stateless API is deprecated
- ❌ Using `container` instead of `screen` for queries — `screen` is RTL best practice
- ❌ Testing Motion animation states with real timers — use `vi.useFakeTimers()` instead
- ❌ Skipping the `window.matchMedia` mock — dark mode and media queries will throw in jsdom
- ❌ Mixing Browser Mode and jsdom in the same config file — maintain two separate configs

---

## 🔧 Task FND-005: Zustand Store Architecture (Slices Pattern)
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** FND-002

### Related Files
- `src/stores/index.ts` · `src/stores/slices/uiSlice.ts` · `src/stores/slices/projectSlice.ts` · `src/stores/slices/budgetSlice.ts` · `src/stores/slices/newsSlice.ts`

### Subtasks
- [ ] **FND-005A**: Define the `StateCreator` type alias for use across all slices:
  ```ts
  type AppStateCreator<T> = StateCreator<AppState, [['zustand/immer', never], ['zustand/devtools', never]], [], T>
  ```
  This allows slices to have type-safe access to cross-slice state via `get()` without carrying middleware types in each slice file.
- [ ] **FND-005B**: Create typed slices — each in its own file, each returning typed state + actions:
  - `uiSlice`: `sidebarExpanded`, `rightPanelOpen`, `commandPaletteOpen`, `focusTriggerRef`, `toggleSidebar`, `openRightPanel`, `closeRightPanel`, `openCommandPalette`, `closeCommandPalette`, `setFocusTrigger`
  - `projectSlice`: `activeView`, `filters`, `selectedProjectId`
  - `budgetSlice`: `transactionFilters`, `dateRange`
  - `newsSlice`: `activeTopics`, `feedFrequency`
- [ ] **FND-005C**: Compose slices into root store in `src/stores/index.ts`:
  - **CRITICAL:** Apply all middleware at the *combined store* level only — never inside individual slices
  - Middleware order: `devtools(immer(persist(...)))` (outermost first)
  - `persist` config: use `partialize` to persist only `uiSlice` state (not server-mirror state)
  ```ts
  export const useStore = create<AppState>()(
    devtools(
      immer(
        persist(
          (...a) => ({
            ...createUiSlice(...a),
            ...createProjectSlice(...a),
            ...createBudgetSlice(...a),
            ...createNewsSlice(...a),
          }),
          {
            name: 'app-storage',
            partialize: (state) => ({ ui: { sidebarExpanded: state.ui.sidebarExpanded } }),
          }
        )
      )
    )
  )
  ```
- [ ] **FND-005D**: Export granular selector hooks (atomic selectors prevent unnecessary re-renders):
  ```ts
  export const useSidebarExpanded = () => useStore((s) => s.ui.sidebarExpanded)
  export const useCommandPaletteOpen = () => useStore((s) => s.ui.commandPaletteOpen)
  ```
- [ ] **FND-005E**: Use an imperative focus registry (module‑scoped `Map`) outside the Zustand store for focus restoration on modal/drawer close; never store React refs in Zustand (causes immutability errors with immer middleware)
- [ ] **FND-005F**: Write unit tests for all slice actions (pure state transitions are ideal unit test targets)

### Definition of Done
- All slices defined with TypeScript interfaces
- Root store composes all slices using `(...a)` spread pattern
- All middleware applied at combined store level only
- `persist` uses `partialize` — only sidebar state persists
- Atomic selector hooks exported
- Slice action unit tests pass

### Anti-Patterns
- ❌ Applying `devtools` or `persist` inside individual slice files — leads to unexpected behavior (explicitly warned in Zustand docs)
- ❌ Naming slice creator functions `useUiSlice` — the `use` prefix breaks Rules of Hooks since these are plain functions, not hooks
- ❌ Storing server/API data in Zustand — that belongs in TanStack Query cache
- ❌ `persist`-ing the entire store — use `partialize` to persist only what must survive page reload
- ❌ Storing derived/computed values in state — use selector functions instead

### Advanced Patterns
- Use `get()` inside action functions to read cross-slice state without coupling slice files to each other
- Add store version number to `persist` config with `version: 1` and a `migrate` function for future schema changes
- Use `subscribeWithSelector` middleware for advanced computed subscription patterns

---

## 🔌 Task FND-006: TanStack Query v5 Configuration
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** FND-002

### Related Files
- `src/lib/queryClient.ts` · `src/queries/` directory · `src/hooks/use*.ts`

### Subtasks
- [ ] **FND-006A**: Create `src/lib/queryClient.ts`:
  ```ts
  export const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 1000 * 60 * 5,      // 5 min — balance freshness vs network
        gcTime: 1000 * 60 * 10,         // 10 min — garbage collect inactive queries
        retry: 1,                         // Fail fast; don't hang on flaky networks
        refetchOnWindowFocus: false,      // Not needed for a local-first app
        refetchOnReconnect: true,
      },
    },
  })
  ```
- [ ] **FND-006B**: Create `src/queries/` directory with per-domain files: `agents.ts`, `projects.ts`, `news.ts`, `budget.ts`
- [ ] **FND-006C**: Define `queryOptions` for each domain as the single source of truth for query keys and fetch functions:
  ```ts
  export const agentsQueryOptions = queryOptions({
    queryKey: ['agents'],
    queryFn: fetchAgents,
    staleTime: 1000 * 60 * 2, // Agents change frequently
  })
  ```
- [ ] **FND-006D**: Create custom hooks that consume `queryOptions` (not wrap `useQuery` directly):
  ```ts
  export function useAgents() {
    return useQuery(agentsQueryOptions)
  }
  ```
  This pattern preserves full TypeScript inference across the query key, data shape, and error type.
- [ ] **FND-006E**: Set `staleTime: Infinity` for static/rarely-changing data (app config, user profile)
- [ ] **FND-006F**: Set up React Query DevTools (dev-only, lazy loaded):
  ```tsx
  const ReactQueryDevtools = lazy(() =>
    import('@tanstack/react-query-devtools').then(m => ({ default: m.ReactQueryDevtools }))
  )
  ```
- [ ] **FND-006G**: Write unit tests for `queryOptions` using MSW handlers

### Definition of Done
- `QueryClient` created with correct defaults
- `queryOptions` defined for all domains
- Custom hooks consume `queryOptions` with full type inference
- DevTools lazy-loaded in development only

### Anti-Patterns
- ❌ Wrapping `useQuery` in a custom hook without `queryOptions` — destroys type inference for `data`, `error`, `isLoading`
- ❌ Using `queryKey: ['agents']` inline in multiple places — query key collisions; use `queryOptions` as single source
- ❌ Not setting `staleTime` — defaults to `0`, causing a refetch on every component mount
- ❌ Mirroring TanStack Query cache data into Zustand — the cache IS the state; this creates sync bugs

---

## �️ Task FND-006.5: API Client & Mock Data Infrastructure
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** FND-006, FND-004

### Related Files
- `src/api/client.ts` · `src/mocks/factories/` · `src/lib/formatters.ts`

### Subtasks
- [ ] **FND-006.5A**: Create `src/api/client.ts` with Axios instance (baseURL: `http://localhost:8000`)
- [ ] **FND-006.5B**: Create mock data factories in `src/mocks/factories/` (agents, projects, tasks, calendar, budget, news)
- [ ] **FND-006.5C**: Create `src/lib/formatters.ts` (formatCurrency, formatTokenAmount, formatRelativeTime)
- [ ] **FND-006.5D**: Update MSW handlers in `src/mocks/handlers.ts` to return mock data
- [ ] **FND-006.5E**: Wire the mock `fetch` functions into the `queryFn` of the `queryOptions` defined in FND-006

### Definition of Done
- Axios client configured
- All mock data functions return realistic, typed data
- Formatters correctly handle dates, currencies, and token amounts
- `queryOptions` successfully fetch mock data via MSW

---

## �🗺️ Task FND-007: React Router v7 Route Architecture
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** FND-002

> **Note:** This task was missing from v1. React Router v7 requires an explicit architectural decision between its three modes. The wrong choice is difficult to reverse.

### Related Files
- `src/router/index.tsx` · `src/router/routes.ts` · `src/pages/` directory

### Subtasks
- [ ] **FND-007A**: Choose the correct React Router v7 mode:
  - **Declarative Mode** — simple `<BrowserRouter>` + `<Routes>`. No data loaders. Use only for trivial apps.
  - **Data Mode** — `createBrowserRouter()` with route-level `loader` functions. Eliminates waterfall fetches. **Recommended for this project.**
  - **Framework Mode** — full SSR/file-based routing. Not applicable for this Vite SPA.
  - **Decision: Data Mode** — use `createBrowserRouter` with `loader` functions that integrate with TanStack Query's `queryClient.ensureQueryData()` for prefetching
- [ ] **FND-007B**: Define the route tree in `src/router/routes.ts`:
  ```ts
  export const router = createBrowserRouter([
    {
      path: '/',
      element: <AppShell />,
      children: [
        { index: true, lazy: () => import('@/pages/Dashboard') },
        { path: 'chat', lazy: () => import('@/pages/Chat') },
        { path: 'projects', lazy: () => import('@/pages/Projects'),
          loader: () => queryClient.ensureQueryData(projectsQueryOptions) },
        { path: 'calendar', lazy: () => import('@/pages/Calendar') },
        { path: 'news', lazy: () => import('@/pages/News') },
        { path: 'budget', lazy: () => import('@/pages/Budget') },
        { path: 'settings', lazy: () => import('@/pages/Settings') },
      ],
    },
  ])
  ```
- [ ] **FND-007C**: Use `lazy` for every route — code-split each page into its own bundle
- [ ] **FND-007D**: Integrate TanStack Query prefetching in loaders:
  - Use `queryClient.ensureQueryData(queryOptions)` — fetches if stale, uses cache if fresh
  - This eliminates the "render → realize data needed → fetch → render again" waterfall
- [ ] **FND-007E**: Add an error boundary at the root route: `errorElement: <RootErrorBoundary />`
- [ ] **FND-007F**: Add `<Suspense fallback={<PageLoadingSkeleton />}>` around `<RouterProvider>` to handle lazy route loading
- [ ] **FND-007G**: Create placeholder page components in `src/pages/` for all routes so the app navigates without errors

### Definition of Done
- `createBrowserRouter` with Data Mode is configured
- All routes use `lazy` for code splitting
- Root error boundary present
- Navigation between all 7 main routes works
- `import from "react-router"` — zero `react-router-dom` imports

### Anti-Patterns
- ❌ Using `<BrowserRouter>` (declarative mode) when data loaders are available — creates waterfall fetches
- ❌ Importing from `"react-router-dom"` — merged into `"react-router"` in v7; the old package still technically works but is a maintenance liability
- ❌ Not using `lazy` for routes — a monolithic bundle eliminates the Vite code-splitting advantage
- ❌ Fetching data with `useEffect` inside route components instead of route `loader` functions — the loader fires before the component renders, eliminating flash-of-loading-state

---

## 🏗️ Task FND-008: App Entry Point & Provider Composition Tree
**Priority:** 🔴 High | **Est. Effort:** 30 min | **Depends On:** FND-005, FND-006, FND-007

> **Note:** Provider order matters. Wrong order causes subtle bugs that are hard to trace. This task makes provider composition an explicit architectural decision with its own definition of done.

### Related Files
- `src/main.tsx` · `src/App.tsx`

### Subtasks
- [ ] **FND-008A**: Compose the provider tree in `src/main.tsx` in this specific order:
  ```tsx
  ReactDOM.createRoot(document.getElementById('root')!).render(
    <React.StrictMode>
      <QueryClientProvider client={queryClient}>
        <ThemeProvider attribute="class" defaultTheme="dark" enableSystem>
          <RouterProvider router={router} />
          {import.meta.env.DEV && <ReactQueryDevtools initialIsOpen={false} />}
        </ThemeProvider>
      </QueryClientProvider>
    </React.StrictMode>
  )
  ```
  - `QueryClientProvider` wraps everything so route `loader` functions can access the query client
  - `ThemeProvider` wraps `RouterProvider` so all routes have access to theme context
  - `RouterProvider` replaces `App` as the root component — the router is the app
  - `ReactQueryDevtools` conditionally rendered in dev only
- [ ] **FND-008B**: Delete `src/App.tsx` if it is no longer needed (root layout now lives in the router's root element)
- [ ] **FND-008C**: Create `src/layouts/AppShell.tsx` — this is the root layout component referenced by the router:
  - Contains: `<Sidebar />`, `<main>`, `<StatusBar />`, `<RightPanel />`, `<CommandPalette />`
  - Uses `<Outlet />` from `react-router` for page content
- [ ] **FND-008D**: Wrap `<Outlet />` in `<AnimatePresence mode="wait">` for page transitions, keyed by `location.pathname`
- [ ] **FND-008E**: Add a `<SkipLink />` component as the very first child of `<AppShell>` (keyboard accessibility)
- [ ] **FND-008F**: Verify the full render tree renders without errors

### Definition of Done
- Provider order is correct (QueryClient → Theme → Router)
- `AppShell` renders with Outlet
- Page transitions with `AnimatePresence` are working
- DevTools renders only in dev
- Skip link present

### Anti-Patterns
- ❌ `RouterProvider` wrapping `QueryClientProvider` — route loaders that use `queryClient` will fail
- ❌ `StrictMode` removed — always keep it in development to surface unsafe lifecycle patterns
- ❌ Importing `ReactQueryDevtools` at the top level (not lazy) — it will be included in the production bundle

---

## 🧭 Task FND-009: Global Layout — Sidebar Shell
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** FND-005, FND-008

### Related Files
- `src/components/layout/Sidebar.tsx` · `src/components/layout/NavItem.tsx`

### Subtasks

**Implementation:**
- [ ] **FND-009A**: Build `Sidebar` component using state from `useSidebarExpanded` hook
- [ ] **FND-009B**: Implement collapse/expand with spring animation:
  - `animate={{ width: isExpanded ? 240 : 64 }}`
  - `transition={{ type: "spring", stiffness: 300, damping: 30 }}`
  - Do not animate `width` as a CSS class change — Motion must own the width value
- [ ] **FND-009C**: Build nav items in spec order: Dashboard, Chat, Projects, Calendar, News, Budget, divider, Settings
- [ ] **FND-009D**: Implement active nav pill with `layoutId="activeNavPill"` using `motion.span` as the background indicator
- [ ] **FND-009E**: Build Settings accordion with inline expansion using `AnimatePresence`:
  - `initial={{ height: 0, opacity: 0 }}` / `animate={{ height: "auto", opacity: 1 }}`
  - Use `layout` prop to prevent height animation from triggering paint storms
- [ ] **FND-009F**: Apply glass styling: `backdrop-blur-md bg-white/5 border-r border-white/10`
- [ ] **FND-009G**: Apply `.noise-overlay` class to the glass surface
- [ ] **FND-009H**: Check `useReducedMotion()` — if true, disable spring animation and use instant width change
- [ ] **FND-009I**: Ensure WCAG 2.2 2.5.8 Target Size compliance: all nav items minimum 24×24px hit area; aim for 44×44px

**Tests (write alongside implementation, not after):**
- [ ] **FND-009J**: Test: sidebar expands when toggle is clicked
- [ ] **FND-009K**: Test: active route is visually indicated
- [ ] **FND-009L**: Test: Settings accordion expands and collapses
- [ ] **FND-009M**: Test: all nav items are keyboard-navigable (tab order correct)
- [ ] **FND-009N**: Test: `useReducedMotion = true` disables animations (mock the hook)

### Definition of Done
- Sidebar toggles with spring animation
- Active pill glides via `layoutId`
- Settings accordion animates correctly
- Glass + noise styling applied
- `useReducedMotion` respected
- All 5 tests pass

### Anti-Patterns
- ❌ Sidebar toggle state in React `useState` — it must be in Zustand so other components can open/close the sidebar
- ❌ Animating `width` via CSS class toggling instead of Motion — no spring physics
- ❌ Missing `aria-current="page"` on active nav item

---

## 🔔 Task FND-010: Global Layout — StatusBar Shell
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** FND-008

### Related Files
- `src/components/layout/StatusBar.tsx`

### Subtasks

**Implementation:**
- [ ] **FND-010A**: Create `StatusBar` component: fixed bottom, 32px height, full width, `z-50`
- [ ] **FND-010B**: Implement connection status pulse:
  - `animate={{ scale: [1, 1.2, 1], opacity: [1, 0.6, 1] }}`
  - `transition={{ repeat: Infinity, duration: 2, ease: "easeInOut" }}`
  - If `useReducedMotion()` returns true — show a static dot instead of pulsing
- [ ] **FND-010C**: Display: connection status, active agent count (mocked), current time, global token spend (mocked)
- [ ] **FND-010D**: Make items tabbable and clickable — clicking opens relevant panel
- [ ] **FND-010E**: Ensure focus indicators: `focus-visible:outline-2 focus-visible:outline-accent` meets WCAG 2.2 2.4.11

**Tests:**
- [ ] **FND-010F**: Test: status bar renders at fixed bottom position
- [ ] **FND-010G**: Test: clicking agent count calls the right action
- [ ] **FND-010H**: Test: pulse animation is disabled when `useReducedMotion = true`

### Definition of Done
- Fixed at bottom, full width, 32px
- Pulse animation respects `useReducedMotion`
- Focus indicators meet WCAG AA contrast

---

## 📐 Task FND-011: Global Layout — RightPanel Shell
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** FND-005, FND-008

### Related Files
- `src/components/layout/RightPanel.tsx`

### Subtasks

**Implementation:**
- [ ] **FND-011A**: Create `RightPanel` component (320px fixed right panel)
- [ ] **FND-011B**: Implement slide transition with `AnimatePresence`:
  - `initial={{ x: "100%" }}` · `animate={{ x: 0 }}` · `exit={{ x: "100%" }}`
  - `transition={{ type: "spring", stiffness: 300, damping: 30 }}`
- [ ] **FND-011C**: Panel open/close state from `useStore` (`rightPanelOpen` from `uiSlice`)
- [ ] **FND-011D**: Apply glass styling + `.noise-overlay` (consistent with sidebar)
- [ ] **FND-011E**: Add close button with `aria-label="Close panel"`
- [ ] **FND-011F**: Implement focus restoration using the imperative focus registry:
  - On open: register the trigger element in the module‑scoped registry
  - On unmount/close: restore focus by retrieving from the registry and calling `.focus()`

**Tests:**
- [ ] **FND-011G**: Test: panel slides in when `rightPanelOpen = true`
- [ ] **FND-011H**: Test: panel slides out when close button clicked
- [ ] **FND-011I**: Test: focus returns to trigger element after close

### Definition of Done
- Slides in/out with spring animation
- State driven by `uiSlice`
- Focus restoration works

---

## ⌨️ Task FND-012: Global Layout — CommandPalette Shell
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** FND-005, FND-008

### Related Files
- `src/components/layout/CommandPalette.tsx` · `src/hooks/useKeyboardShortcut.ts`

### Subtasks

**Implementation:**
- [ ] **FND-012A**: Create `useKeyboardShortcut(key, callback)` hook:
  - Handles `Cmd+K` (macOS) and `Ctrl+K` (Windows/Linux)
  - Binds to `document` — not a specific element
  - Cleans up on unmount
- [ ] **FND-012B**: Build `CommandPalette` as a Portal rendered into `document.body`
- [ ] **FND-012C**: Full-screen backdrop (`fixed inset-0 bg-black/60`) with centered 640px modal
- [ ] **FND-012D**: Apply glass styling + `.noise-overlay`
- [ ] **FND-012E**: ARIA roles: outer `div` gets `role="dialog"` + `aria-modal="true"` + `aria-label="Command palette"`. Input gets `role="combobox"` + `aria-expanded` + `aria-controls`
- [ ] **FND-012F**: Staggered item animation:
  ```ts
  const containerVariants = { visible: { transition: { staggerChildren: 0.05 } } }
  const itemVariants = { hidden: { opacity: 0, y: 10 }, visible: { opacity: 1, y: 0 } }
  ```
- [ ] **FND-012G**: Keyboard navigation: `↑↓` to navigate, `Enter` to select, `Escape` to close
- [ ] **FND-012H**: Focus trap using `@radix-ui/react-focus-trap` (or `@radix-ui/react-dialog`)
- [ ] **FND-012I**: Verify WCAG 2.2 2.4.12 Focus Not Obscured — the sticky status bar must not cover the focused item
- [ ] **FND-012J**: Focus restoration: on close, focus returns to the element that triggered the palette using the imperative focus registry

**Tests:**
- [ ] **FND-012K**: Test: `Cmd+K` opens the palette
- [ ] **FND-012L**: Test: `Escape` closes the palette
- [ ] **FND-012M**: Test: arrow keys navigate through items
- [ ] **FND-012N**: Test: focus is trapped inside the palette while open
- [ ] **FND-012O**: Test: focus returns to trigger after close

### Definition of Done
- `Cmd+K` / `Ctrl+K` opens palette
- Escape closes; focus restores
- Staggered item animation on open
- Focus trap active
- All 5 tests pass

### Anti-Patterns
- ❌ `<dialog>` element without focus trap management — built-in dialog has different behavior across browsers
- ❌ Keyboard shortcut bound to a component's `useEffect` that unmounts — use a persistent listener at document level
- ❌ Backdrop rendered outside a Portal — z-index conflicts with the sidebar

---

## ♿ Task FND-013: Accessibility Foundation & Focus Management
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** FND-009 through FND-012

### Related Files
- `src/hooks/useFocusRestoration.ts` · `src/components/ui/SkipLink.tsx` · All layout components

### Subtasks
- [ ] **FND-013A**: Add ARIA landmarks to `AppShell`: `<header role="banner">`, `<nav aria-label="Main navigation">`, `<main role="main" id="main-content">`, `<aside role="complementary">`, `<footer role="contentinfo">`
- [ ] **FND-013B**: Verify `SkipLink` component (added in FND-008E) is the first focusable element; visually hidden until focused; links to `#main-content`
- [ ] **FND-013C**: Audit all interactive elements:
  - Visible focus indicator: `focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-accent` (electric blue)
  - Focus indicator must meet WCAG 2.2 2.4.11: 3px minimum area, 3:1 contrast ratio against adjacent colors
- [ ] **FND-013D**: Audit all click targets: minimum 24×24px per WCAG 2.2 2.5.8; aim for 44×44px on all primary interactive elements
- [ ] **FND-013E**: Add `aria-live="polite"` regions for status announcements (connection status changes, agent count updates)
- [ ] **FND-013F**: Verify color contrast: normal text ≥4.5:1, large text ≥3:1, UI components ≥3:1 against background
- [ ] **FND-013G**: Verify WCAG 2.2 2.4.12 Focus Not Obscured: sticky status bar (32px) must not obscure the bottom-most focusable element; add `scroll-padding-bottom: 48px` to `<html>`
- [ ] **FND-013H**: Run automated audit with Axe DevTools (browser extension) — resolve all violations before marking done
- [ ] **FND-013I**: Run screen reader smoke test with VoiceOver (macOS) or NVDA (Windows) on: sidebar navigation, command palette, right panel open/close
- [ ] **FND-013J**: Write accessibility-focused tests using `@testing-library/jest-dom`:
  - `expect(element).toHaveFocus()` after modal close
  - `expect(nav).toHaveAttribute('aria-label', 'Main navigation')`
  - `expect(button).toBeVisible()` after skip link is focused
- [ ] **FND-013K**: Audit all components using `layoutId` for shared layout animations:
  - Verify each component that uses `layoutId` is wrapped in a module-scoped `LayoutGroup` with a unique `id` prop
  - `layoutId` is global across the site; without `LayoutGroup` namespacing, multiple instances of the same component will collide
  - Example: `<LayoutGroup id="projects-kanban">` wraps the entire Kanban view to namespace `layoutId` values used within it
  - Document any components that intentionally use cross-tree `layoutId` matching (e.g., card-to-drawer morph) and ensure they share the same `LayoutGroup` or are outside any `LayoutGroup`

### Definition of Done
- ARIA landmarks present on all major layout regions
- All focus indicators visible and meet WCAG 2.2 2.4.11 contrast requirements
- All click targets ≥24×24px
- Axe audit: zero violations
- Screen reader smoke test passes
- Focus restoration works for RightPanel and CommandPalette
- `useReducedMotion()` disables all animations across all components

---

## 📊 Dependency Graph (Updated)

```
FND-000 (Tokens & Theme)
     │
FND-001 (Scaffold & Vite)
     │
FND-002 (Dependencies)
     ├──────────────────────────────────┐
     │                                  │
FND-003 (Code Quality)            FND-004 (Testing Infra)
                                         │
                    ┌────────────────────┤
                    │                    │
              FND-005 (Zustand)    FND-006 (TanStack Query)
                    │                    │
              FND-007 (Router) ──────────┘
                    │
              FND-008 (Provider Tree)
                    │
        ┌──────────┬┴───────────┬──────────┐
        │          │            │          │
  FND-009      FND-010      FND-011    FND-012
 (Sidebar)  (StatusBar) (RightPanel) (CmdPalette)
        │          │            │          │
        └──────────┴────────────┴──────────┘
                         │
                   FND-013 (A11y)
```

---

## 🏁 Foundations Completion Checklist

**Theme & Config:**
- [ ] No `tailwind.config.ts` file exists
- [ ] `@theme inline` block with `oklch()` tokens in `index.css`
- [ ] `@custom-variant dark` directive present
- [ ] Background renders `#050507`
- [ ] `.noise-overlay` utility available

**Toolchain:**
- [ ] `pnpm lint` passes with 0 warnings
- [ ] `pnpm format:check` passes
- [ ] Husky pre-commit hook blocks lint failures
- [ ] Conventional commits enforced

**Dependencies:**
- [ ] `motion` v12 installed; imports from `motion/react`
- [ ] `react-router` v7 installed (not `react-router-dom`)
- [ ] `tw-animate-css` installed (not `tailwindcss-animate`)
- [ ] TypeScript strict mode with `noUncheckedIndexedAccess`: 0 errors

**Testing:**
- [ ] `pnpm test` passes
- [ ] MSW configured with `onUnhandledRequest: 'error'`
- [ ] Vitest Browser Mode configured for component tests
- [ ] `window.matchMedia`, `IntersectionObserver`, `ResizeObserver` mocked

**Architecture:**
- [ ] Zustand slices pattern; middleware applied only at combined store level
- [ ] TanStack Query `queryOptions` pattern with type-safe custom hooks
- [ ] React Router v7 Data Mode with `createBrowserRouter`
- [ ] All routes lazy-loaded with `lazy`
- [ ] Provider order correct: `QueryClient → Theme → Router`

**Layout Components (each):**
- [ ] Sidebar spring animation with `useReducedMotion` check
- [ ] Active nav pill via `layoutId`
- [ ] StatusBar fixed bottom with pulse (respects reduced motion)
- [ ] RightPanel slide animation with focus restoration
- [ ] CommandPalette `Cmd+K` with focus trap and focus restoration

**Accessibility:**
- [ ] WCAG 2.2 AA: all focus indicators visible (2.4.11)
- [ ] WCAG 2.2 AA: no focus obscured by status bar (2.4.12)
- [ ] WCAG 2.2 AA: all targets ≥24×24px (2.5.8)
- [ ] ARIA landmarks on all layout regions
- [ ] Axe audit: zero violations
- [ ] `pnpm build` succeeds