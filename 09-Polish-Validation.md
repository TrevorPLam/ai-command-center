Below is the complete updated task document, fully reproduced and enhanced, with all changes integrated.

***

# 09-Polish & Validation — Personal AI Command Center Frontend (Enhanced v3)

> **Status indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.  
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.  
> **Versioning Note**: This document supersedes `09-Polish-Validation-Enhanced-v2.md`.

***

## Cross‑Cutting Foundations for Polish & Validation

| ID | Area | Requirement |
|----|------|-------------|
| **POL-C01** | Performance Targets | Core Web Vitals: **LCP < 2.5s**, **INP < 200ms**, **CLS < 0.1** on mobile with 4G throttling. [vettedoutsource](https://vettedoutsource.com/blog/production-readiness-checklist/) Lighthouse Performance & Accessibility scores ≥ 90. |
| **POL-C02** | Bundle Budget | Vendor chunk < 500KB, total initial JS < 2MB (uncompressed), enforced via Lighthouse CI budgets. [github](https://github.com/gorrion-io/production-readiness-checklist) |
| **POL-C03** | Accessibility | WCAG 2.1/2.2 AA baseline, zero **critical** violations in axe‑core and pa11y. [muz](https://muz.li/blog/how-to-make-your-ui-accessible-a-practical-checklist-for-2026/) Manual screen‑reader pass (NVDA/VoiceOver) required. |
| **POL-C04** | Environment Validation | All `VITE_*` environment variables validated with Zod at startup; missing or invalid values fail the app boot. [abbacustechnologies](https://www.abbacustechnologies.com/web-dev-checklist-2026/) |
| **POL-C05** | Code Splitting | Route‑level `lazy` imports for all pages; `manualChunks` for stable vendor libraries and heavy UI libs. |
| **POL-C06** | Error Resilience | Root `<ErrorBoundary>` plus per‑route boundaries for risky sections; Suspense fallbacks for lazy routes and data fetching. [abbacustechnologies](https://www.abbacustechnologies.com/web-dev-checklist-2026/) |
| **POL-C07** | Testing Pyramid | Unit (Vitest), Component (RTL + Vitest), Integration (Vitest + MSW), E2E (Playwright), Visual (Chromatic/Percy), A11y checks (axe/pa11y) in CI. [shsxnk](https://www.shsxnk.com/tools/ci-readiness) |
| **POL-C08** | Security & Privacy | No secrets in frontend bundles, XSS‑safe rendering, robust auth/session handling, and basic CSP/security headers documented. [domainoptic](https://domainoptic.com/security/react/) |
| **POL-C09** | Observability | Client‑side error logging and Core Web Vitals RUM wired into analytics; dashboards can show whether a release is healthy. [vettedoutsource](https://vettedoutsource.com/blog/production-readiness-checklist/) |

***

## Task POL‑001: Performance & Bundle Optimization

**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** All previous modules

Focus: offline bundle analysis and targeted optimizations to meet Core Web Vitals and bundle budgets.

### Related Files

- `vite.config.ts`, `package.json`, `src/lib/performance.ts`, `src/lib/rum.ts`

### Subtasks

- [ ] **POL‑001A**: Install bundle analyzer  
  - `pnpm add -D rollup-plugin-visualizer`. [pagepro](https://pagepro.co/blog/web-development-best-practices/)
  - Configure in `vite.config.ts` to generate `stats.html` on production builds.  
  - Open `stats.html` and document top 10 heaviest modules and why they are needed.

- [ ] **POL‑001B**: Configure `manualChunks` in `vite.config.ts`
  ```ts
  rollupOptions: {
    output: {
      manualChunks: {
        'vendor-react': ['react', 'react-dom', 'react-router'],
        'vendor-query': ['@tanstack/react-query'],
        'vendor-motion': ['motion'],
        'ui-shadcn': ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu', '...'],
        'charts': ['recharts'],
        'dnd': ['@dnd-kit/core', '@dnd-kit/sortable'],
      },
    },
  }
  ```
  - Goal: vendor chunk < 500KB, total initial JS < 2MB (uncompressed). [github](https://github.com/gorrion-io/production-readiness-checklist)
  - Move rarely used or admin‑only views behind route‑level `lazy` imports.

- [ ] **POL‑001C**: Core Web Vitals lab audit (Lighthouse DevTools, Mobile + 4G throttling)  
  - Record **LCP**, **INP**, **CLS** for `/`, `/dashboard`, `/chat`, `/projects`, `/analytics`.  
  - If LCP > 2.5s: check images (dimensions, formats), render‑blocking CSS/JS, and initial data fetching strategy. [abbacustechnologies](https://www.abbacustechnologies.com/web-dev-checklist-2026/)
  - If INP > 200ms: use Performance panel to identify long tasks >50ms; defer non‑critical work with `requestIdleCallback` or `startTransition`.  
  - If CLS > 0.1: fix layout shifts via fixed dimensions and placeholders.

- [ ] **POL‑001D**: Optimize expensive interactions  
  - Use `useTransition` / `startTransition` for expensive filtering and sorting in Dashboard, Transactions, and News modules. [abbacustechnologies](https://www.abbacustechnologies.com/web-dev-checklist-2026/)
  - Use `useDeferredValue` for large searchable lists (e.g., Audit, Transactions) to avoid blocking typing.  

- [ ] **POL‑001E**: Image optimization  
  - Ensure all non‑critical images use `loading="lazy"` and have width/height attributes. [pagepro](https://pagepro.co/blog/web-development-best-practices/)
  - Use responsive sources (`srcset`) or a CDN for key hero/illustration images if present.

- [ ] **POL‑001F**: Introduce RUM (Core Web Vitals client collection)  
  - Add `src/lib/rum.ts` with a function to capture real‑user LCP/INP/CLS using `web-vitals` or equivalent. [vettedoutsource](https://vettedoutsource.com/blog/production-readiness-checklist/)
  - Send metrics to a mock `/api/rum` endpoint or logging function for now (to be surfaced in POL‑003).

### Definition of Done

- `stats.html` has no unexplained monolithic chunks; bundle budgets met (vendor < 500KB, initial JS < 2MB).  
- Lighthouse (mobile, 4G) Performance ≥ 90, LCP < 2.5s, INP < 200ms, CLS < 0.1 on key routes. [github](https://github.com/gorrion-io/production-readiness-checklist)
- Expensive interactions use React concurrent patterns (`useTransition`, `useDeferredValue`).  
- RUM hook for Core Web Vitals is implemented and can be consumed by analytics.

### Anti‑Patterns

- ❌ Assuming desktop broadband performance is sufficient; always test with throttling. [abbacustechnologies](https://www.abbacustechnologies.com/web-dev-checklist-2026/)
- ❌ Leaving repeated heavy libraries in multiple chunks instead of centralizing them via `manualChunks`.  
- ❌ Not measuring after changes; performance work without numbers is incomplete. [github](https://github.com/gorrion-io/production-readiness-checklist)

***

## Task POL‑002: Quality Gates & Testing

**Priority:** 🔴 High | **Est. Effort:** 4 hours | **Depends On:** POL‑001, FND‑004 (Testing Infrastructure)

Focus: enforce quality via CI with a full testing pyramid (unit → visual), plus performance and a11y gates.

### Related Files

- `.github/workflows/ci.yml`, `lighthouserc.js`, `.pa11yci.json`, `playwright.config.ts`, `src/**/*.{test,spec}.tsx`, `.eslintrc`, `vitest.config.ts`

### Subtasks

- [ ] **POL‑002A**: Lighthouse CI in GitHub Actions  
  - Install `@lhci/cli` and create `lighthouserc.js`:
    ```js
    module.exports = {
      ci: {
        collect: { url: ['http://localhost:4173/'], numberOfRuns: 3 },
        assert: {
          preset: 'lighthouse:recommended',
          assertions: {
            'categories:performance': ['error', { minScore: 0.9 }],
            'categories:accessibility': ['error', { minScore: 0.9 }],
            'resource-summary:script:size': ['error', { maxNumericValue: 500000 }],
          },
        },
        upload: { target: 'temporary-public-storage' },
      },
    };
    ``` [github](https://github.com/gorrion-io/production-readiness-checklist)  
  - Integrate into CI workflow so it runs on PRs and main.

- [ ] **POL‑002B**: Automated accessibility audits  
  - `pnpm add -D pa11y-ci axe-core @axe-core/cli`.  
  - Create `.pa11yci.json` with routes: `/`, `/dashboard`, `/chat`, `/budget/transactions`, `/projects`, `/analytics`, `/audit`.  
  - Add `pa11y-ci` step to GitHub Actions; fail PR on critical WCAG 2.1/2.2 AA violations. [muz](https://muz.li/blog/how-to-make-your-ui-accessible-a-practical-checklist-for-2026/)
  - Add `axe` checks to a small set of representative component tests (e.g., Layout, Sidebar, Chat view).

- [ ] **POL‑002C**: Testing pyramid implementation  
  - **Unit tests (Vitest)**:  
    - Cover pure utilities, data mappers, and hooks that don't touch DOM or network.  
  - **Component tests (React Testing Library + Vitest)**:  
    - Test key components (Sidebar, AgentCard, Dashboard widgets, Modals) for render, interaction, and basic a11y.  
  - **Integration tests (Vitest + MSW)**:  
    - Test module‑level flows (Dashboard summaries, Chat message lifecycle, Kanban board updates) with mocked APIs via MSW. [shsxnk](https://www.shsxnk.com/tools/ci-readiness)

- [ ] **POL‑002D**: Playwright E2E tests (critical flows)  
  - At minimum:  
    - Test 1: Login → dashboard → open first agent → send message → navigate to chat.  
    - Test 2: Create project → move card to “In Review” → status updates optimistically.  
    - Test 3: Open calendar → create event → verify it appears in Month view.  
  - Configure Playwright with `projects: [{ name: 'chromium' }]` and wire into CI. [momentic](https://momentic.ai/blog/software-testing-basics)

- [ ] **POL‑002E**: Visual regression testing  
  - If Storybook is present: integrate Chromatic or Percy for key stories (Sidebar, Navigation, Dashboard, Chat layout).  
  - If not using Storybook: adopt Playwright screenshot tests for a small set of pages at common viewports. [momentic](https://momentic.ai/blog/software-testing-basics)

- [ ] **POL‑002F**: Static analysis & type safety gates  
  - Ensure `pnpm lint` and `pnpm typecheck` run in CI and fail on any warning/error. [shsxnk](https://www.shsxnk.com/tools/ci-readiness)
  - Enforce Prettier/ESLint rules for consistent code style.

### Definition of Done

- CI runs LHCI, pa11y/axe, unit, component, integration, E2E, and visual tests on every PR.  
- PRs are blocked if performance < 90, accessibility < 90, tests fail, or lint/typecheck fails.  
- Critical flows (auth, dashboard, chat, projects, calendar) are covered by at least integration + E2E tests.

### Anti‑Patterns

- ❌ Overreliance on E2E tests instead of unit/integration tests (flaky, slow). [shsxnk](https://www.shsxnk.com/tools/ci-readiness)
- ❌ Running Lighthouse or a11y checks only locally.  
- ❌ Tests coupled to live backends instead of MSW or controlled fixtures.

***

## Task POL‑003: Analytics, Audit & RUM

**Priority:** 🟠 Medium | **Est. Effort:** 3 hours | **Depends On:** BUDG‑008 (Investments & Reports), CHAT‑002 (Chat State), POL‑001

Focus: in‑app analytics, audit logs, and basic front‑end observability (client logs + RUM).

### Related Files

- `src/pages/CostAnalyticsPage.tsx`, `src/pages/AuditLogPage.tsx`, `src/queries/analytics.ts`, `src/lib/logging.ts`, `src/lib/rum.ts`

### Subtasks

- [ ] **POL‑003A**: Cost Analytics page  
  - `CostAnalyticsPage` with:  
    - **CostByAgentChart**: Donut chart (Recharts) showing token usage per agent with staggered animations, respecting reduced motion. [abbacustechnologies](https://www.abbacustechnologies.com/web-dev-checklist-2026/)
    - **BudgetOverview**: Total spend vs monthly cap; time range selector (7d/30d/90d); project breakdown table.  
  - Data served from `useCostAnalytics()` (mock for now).

- [ ] **POL‑003B**: Audit Log page  
  - Table with columns: Timestamp, User, Action, Target, IP, Status.  
  - Filters: date range, user, action type; server‑like pagination or virtualized scrolling for long lists (`react-window`). [abbacustechnologies](https://www.abbacustechnologies.com/web-dev-checklist-2026/)
  - Data from `useAuditLog()` (mock).

- [ ] **POL‑003C**: Client‑side logging utility  
  - Create `src/lib/logging.ts` with a `logClientEvent(event)` function for front‑end errors and important UX events. [vettedoutsource](https://vettedoutsource.com/blog/production-readiness-checklist/)
  - Integrate with global error boundary (POL‑004) and optional manual logging points.

- [ ] **POL‑003D**: Wire RUM metrics  
  - Use `src/lib/rum.ts` from POL‑001 to send Core Web Vitals to the logging/analytics endpoint.  
  - Optionally expose a simple internal “Performance” panel for debugging (dev‑only).

- [ ] **POL‑003E**: Tests  
  - Tests for Cost Analytics and Audit pages verifying charts render, filters work, virtualization is active, and `prefers-reduced-motion` is honored. [muz](https://muz.li/blog/how-to-make-your-ui-accessible-a-practical-checklist-for-2026/)

### Definition of Done

- `/analytics` and `/audit` routes are functional and integrated into navigation.  
- Cost analytics charts and budget overviews render correctly; audit log filters and virtualization work with mock data.  
- Client‑side logging and RUM hooks are implemented and used by other tasks.

### Anti‑Patterns

- ❌ Logging raw user content or PII in analytics/audit logs. [digiqt](https://digiqt.com/blog/reactjs-security-best-practices/)
- ❌ Observability limited to server logs only; no front‑end view of errors/performance. [vettedoutsource](https://vettedoutsource.com/blog/production-readiness-checklist/)

***

## Task POL‑004: Production Hardening & Env Safety

**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** POL‑001, POL‑002, POL‑003

Focus: environment safety, error boundaries, offline/failure behavior, strict build quality.

### Related Files

- `src/lib/env.ts`, `src/main.tsx`, `src/components/ErrorBoundary.tsx`, `src/components/GlobalErrorFallback.tsx`, `public/manifest.json`, `index.html`, `.env.example`, `README.md`

### Subtasks

- [ ] **POL‑004A**: Environment Variable Validation  
  - Implement `src/lib/env.ts` using Zod to validate all `VITE_*` variables (`VITE_API_BASE_URL`, `VITE_APP_TITLE`, etc.). [digiqt](https://digiqt.com/blog/reactjs-security-best-practices/)
  - Invoke `envSchema.parse(import.meta.env)` at the app entry; on failure, log via `logClientEvent` and prevent app mount.

- [ ] **POL‑004B**: Global & route‑level error boundaries  
  - Wrap `<RouterProvider>` with `<ErrorBoundary fallback={<GlobalErrorFallback />}>`.  
  - Add route‑level error boundaries for riskier sections (Chat, Analytics, Projects). [dev](https://dev.to/maurya-sachin/react-error-boundaries-practical-error-handling-building-resilient-frontend-applications-1i4a)
  - Ensure errors are logged via `logClientEvent` and provide a retry/reload option.

- [ ] **POL‑004C**: Offline and network failure handling  
  - Detect offline status (via `navigator.onLine` or equivalent) and show a banner with retry behavior for key actions.  
  - Ensure API failures show meaningful UI states (with actions to retry, go back, or contact support). [vettedoutsource](https://vettedoutsource.com/blog/production-readiness-checklist/)

- [ ] **POL‑004D**: SEO & PWA meta tags  
  - Add/verify `manifest.json` with app name, icons, theme color.  
  - Add meta tags to `index.html`: `description`, `keywords`, Open Graph (`og:title`, `og:description`, `og:image`), Twitter Card tags. [abbacustechnologies](https://www.abbacustechnologies.com/web-dev-checklist-2026/)
  - Add static `robots.txt` and `sitemap.xml`.

- [ ] **POL‑004E**: Final build validation  
  - Run `pnpm build` and ensure zero TypeScript errors and zero warnings.  
  - Run `pnpm lint --max-warnings 0` and fix issues.  
  - Run `pnpm preview` and test on a real mobile device or emulator, verifying main flows.  

- [ ] **POL‑004F**: Documentation & examples  
  - Update `README.md` with final setup instructions, `pnpm` commands, and environment variable documentation. [getdx](https://getdx.com/blog/production-readiness-checklist/)
  - Ensure `.env.example` lists all required `VITE_*` variables with clear descriptions and placeholders.

### Definition of Done

- Env validation fails fast and prevents broken deployments.  
  - On invalid env, app does not mount, and meaningful errors are logged.  
- Error boundaries catch unexpected errors, display a global fallback, and log to client logging.  
- Offline and failure states are properly surfaced to users.  
- Build, lint, and typecheck are clean; PWA and meta tags are in place.

### Anti‑Patterns

- ❌ Allowing the app to start with missing/invalid env vars. [digiqt](https://digiqt.com/blog/reactjs-security-best-practices/)
- ❌ Swallowing errors silently in error boundaries.  
- ❌ “Something went wrong” messages without actionable detail.

***

## Task POL‑005: UX, Accessibility & States Polish

**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** POL‑001, POL‑002

Focus: consistent UX quality, state coverage, and manual accessibility polish.

### Related Files

- `src/components/*`, `src/layouts/*`, `src/pages/*`, design tokens/theme files

### Subtasks

- [ ] **POL‑005A**: Loading & skeleton states  
  - Ensure all primary views (dashboard, chat, projects, calendar, analytics, audit) use consistent skeleton or shimmer placeholders. [abbacustechnologies](https://www.abbacustechnologies.com/web-dev-checklist-2026/)
  - Confirm skeletons do not cause layout shifts and respect `prefers-reduced-motion`. [muz](https://muz.li/blog/how-to-make-your-ui-accessible-a-practical-checklist-for-2026/)

- [ ] **POL‑005B**: Empty and edge states  
  - For list‑based views (projects, transactions, audit log, analytics): show clear empty states with calls to action (e.g., “Create your first project”).  
  - For AI chat: handle no history, no response, rate limit, quota exceeded, and backend errors with helpful guidance. [vettedoutsource](https://vettedoutsource.com/blog/production-readiness-checklist/)

- [ ] **POL‑005C**: Error message clarity  
  - Replace vague errors (“Something went wrong”) with specific, actionable messages where possible. [muz](https://muz.li/blog/how-to-make-your-ui-accessible-a-practical-checklist-for-2026/)
  - For forms, place error messages next to fields and associate them with ARIA attributes.

- [ ] **POL‑005D**: Interaction and microcopy consistency  
  - Standardize button labels, confirmation text, destructive action wording, and tooltips. [abbacustechnologies](https://www.abbacustechnologies.com/web-dev-checklist-2026/)
  - Ensure keyboard shortcuts (if any) are documented and consistent.

- [ ] **POL‑005E**: Accessibility pass (manual + automated)  
  - Use keyboard to complete all key tasks using only Tab, Enter, Escape, Arrow keys. [muz](https://muz.li/blog/how-to-make-your-ui-accessible-a-practical-checklist-for-2026/)
  - Verify focus states on all interactive elements (visible and high contrast).  
  - Check touch targets are ≥44×44px where applicable. [muz](https://muz.li/blog/how-to-make-your-ui-accessible-a-practical-checklist-for-2026/)
  - Run a short screen‑reader pass (NVDA or VoiceOver) through core workflows.

- [ ] **POL‑005F**: Typography & layout sanity  
  - Ensure base font size ≥16px and line height ≈1.5 for body text; avoid overly wide text columns. [muz](https://muz.li/blog/how-to-make-your-ui-accessible-a-practical-checklist-for-2026/)
  - Confirm headings follow a logical hierarchy and no levels are skipped.

### Definition of Done

- All core views have clear loading, empty, and error states.  
- Accessibility expectations from POL‑C03 and the checklist are met beyond automated tools. [muz](https://muz.li/blog/how-to-make-your-ui-accessible-a-practical-checklist-for-2026/)
- Copy and interaction patterns feel consistent across modules.

### Anti‑Patterns

- ❌ Relying solely on automated a11y tools with no manual keyboard/screen‑reader testing. [muz](https://muz.li/blog/how-to-make-your-ui-accessible-a-practical-checklist-for-2026/)
- ❌ Generic error text that does not explain what went wrong or how to fix it.

***

## Task POL‑006: Security, Privacy & Compliance

**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** POL‑003, POL‑004

Focus: secure frontend behavior, auth/session robustness, safe rendering of data, and basic privacy/user‑control standards.

### Related Files

- `src/auth/*`, `src/lib/env.ts`, `src/lib/security.ts`, `src/lib/logging.ts`, `src/components/PrivacyBanner.tsx`, `src/components/ConsentSettings.tsx`

### Subtasks

- [ ] **POL‑006A**: Auth & session robustness  
  - Validate login/logout flows, session expiration, and token refresh behavior.  
  - Ensure expired or invalid tokens are handled gracefully (logout or refresh) and do not leave the UI in a half‑authenticated state. [digiqt](https://digiqt.com/blog/reactjs-security-best-practices/)
  - Handle 401/403 responses consistently in data fetching layers.

- [ ] **POL‑006B**: Secrets and AI key handling  
  - Confirm that no secret keys (e.g., provider API keys) are exposed in `VITE_*` env vars or build artifacts; they must stay server‑side. [domainoptic](https://domainoptic.com/security/react/)
  - If users connect their own keys, clearly show what’s stored where and avoid ever writing them to logs.

- [ ] **POL‑006C**: XSS & injection protection  
  - Audit usage of `dangerouslySetInnerHTML`; replace with safe render paths where possible. [domainoptic](https://domainoptic.com/security/react/)
  - For unavoidable HTML rendering, sanitize with a library like DOMPurify before render. [domainoptic](https://domainoptic.com/security/react/)
  - Apply schema‑based validation (Zod/Yup) to user input at the UI edge before sending data downstream. [digiqt](https://digiqt.com/blog/reactjs-security-best-practices/)

- [ ] **POL‑006D**: Security headers & CSP (front‑end expectations)  
  - Document recommended security headers: CSP, X‑Frame‑Options, X‑Content‑Type‑Options, Referrer‑Policy. [domainoptic](https://domainoptic.com/security/react/)
  - Ensure the frontend avoids inline scripts/styles that would block strict CSP adoption later.

- [ ] **POL‑006E**: Privacy & telemetry controls  
  - Implement a simple privacy/analytics consent banner if non‑essential tracking is used. [digiqt](https://digiqt.com/blog/reactjs-security-best-practices/)
  - Provide a “Privacy & Analytics” settings view letting users opt out of non‑essential telemetry where possible.  
  - Ensure analytics and logs do not store PII or raw AI prompts/responses; redact or hash sensitive fields. [digiqt](https://digiqt.com/blog/reactjs-security-best-practices/)

- [ ] **POL‑006F**: Compliance UX basics  
  - Surface links to Privacy Policy and Terms where users expect them (footer/account settings).  
  - Ensure copy around logging/analytics accurately reflects what is collected. [abbacustechnologies](https://www.abbacustechnologies.com/web-dev-checklist-2026/)

### Definition of Done

- No secrets in the frontend bundle; key handling follows modern React security guidance. [domainoptic](https://domainoptic.com/security/react/)
- Auth/session flows fail safely and predictably.  
- User‑generated content is rendered safely, and XSS vectors are minimized.  
- Users are informed and have basic control over telemetry where applicable.

### Anti‑Patterns

- ❌ Logging raw AI prompts/responses or user identifiers in client logs or analytics. [digiqt](https://digiqt.com/blog/reactjs-security-best-practices/)
- ❌ Relying on obscurity instead of documented, enforced security controls.  
- ❌ Ignoring session timeout and refresh edge cases.

***

## Dependency Graph (Polish & Validation)

```
POL‑001 (Performance & Bundle Optimization)
     │
POL‑002 (Quality Gates & Testing)
     │
POL‑003 (Analytics, Audit & RUM)
     │
POL‑004 (Production Hardening & Env Safety)
     │
├── POL‑005 (UX, Accessibility & States Polish)
└── POL‑006 (Security, Privacy & Compliance)
```

***

## Final Project Completion Checklist

**Performance & Metrics**

- [ ] `rollup-plugin-visualizer` configured; vendor < 500KB, total initial JS < 2MB. [github](https://github.com/gorrion-io/production-readiness-checklist)
- [ ] Core Web Vitals validated in lab: LCP < 2.5s, INP < 200ms, CLS < 0.1 on key routes (mobile, 4G). [github](https://github.com/gorrion-io/production-readiness-checklist)
- [ ] RUM for Core Web Vitals sending real‑user metrics to logging/analytics. [vettedoutsource](https://vettedoutsource.com/blog/production-readiness-checklist/)
- [ ] Route‑based code splitting active; `manualChunks` separates stable vendors and heavy libs.

**Quality Gates & Testing**

- [ ] CI runs LHCI with performance/accessibility thresholds ≥ 0.9. [github](https://github.com/gorrion-io/production-readiness-checklist)
- [ ] `pa11y-ci` and axe audit critical pages; zero critical WCAG 2.1/2.2 AA violations. [muz](https://muz.li/blog/how-to-make-your-ui-accessible-a-practical-checklist-for-2026/)
- [ ] Unit, component, integration, E2E, and visual tests pass in CI. [shsxnk](https://www.shsxnk.com/tools/ci-readiness)
- [ ] `pnpm lint` and `pnpm typecheck` run with no warnings/errors. [shsxnk](https://www.shsxnk.com/tools/ci-readiness)

**Analytics, Audit & Observability**

- [ ] `/analytics` page shows cost breakdowns, budgets, and time‑range controls.  
- [ ] `/audit` page lists actions with filters and virtualized scrolling.  
- [ ] Client‑side `logClientEvent` and RUM integrations are wired and used by error boundaries and critical UX flows. [vettedoutsource](https://vettedoutsource.com/blog/production-readiness-checklist/)

**Production Hardening**

- [ ] Environment variables validated with Zod; app fails fast on invalid/missing config. [digiqt](https://digiqt.com/blog/reactjs-security-best-practices/)
- [ ] Global and route‑level error boundaries prevent white screens and log errors.  
- [ ] Offline and network failure states are visible and actionable.  
- [ ] PWA manifest, SEO, and social meta tags are present and correct.  
- [ ] `pnpm build` and `pnpm preview` verified on real device/emulator.

**UX, Accessibility & States**

- [ ] All primary views have consistent skeleton/placeholder loading states.  
- [ ] Empty and error states are clear, specific, and actionable. [muz](https://muz.li/blog/how-to-make-your-ui-accessible-a-practical-checklist-for-2026/)
- [ ] Keyboard navigation works; focus states are visible for all interactive elements. [muz](https://muz.li/blog/how-to-make-your-ui-accessible-a-practical-checklist-for-2026/)
- [ ] Touch targets meet minimum sizes where appropriate. [muz](https://muz.li/blog/how-to-make-your-ui-accessible-a-practical-checklist-for-2026/)
- [ ] Screen‑reader pass confirms labels, headings, and navigation order are sensible.

**Security, Privacy & Compliance**

- [ ] No secrets or provider keys in frontend bundles; key handling patterns are documented. [domainoptic](https://domainoptic.com/security/react/)
- [ ] Auth/session flows handle expiry, invalid tokens, and 401/403 consistently.  
- [ ] User‑generated content is sanitized before HTML rendering; `dangerouslySetInnerHTML` is either removed or tightly controlled. [domainoptic](https://domainoptic.com/security/react/)
- [ ] Recommended security headers and CSP constraints are documented for deployment. [domainoptic](https://domainoptic.com/security/react/)
- [ ] Telemetry and logging avoid PII and sensitive payloads; privacy/analytics preferences are exposed to the user. [digiqt](https://digiqt.com/blog/reactjs-security-best-practices/)