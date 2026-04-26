# Frontend rules

These rules apply to all frontend code. Violating a **HARD** rule will block a PR.

> **Canonical source**: Architecture rules are defined in [02-ARCH-OVERVIEW.md § Architecture rules](02-ARCH-OVERVIEW.md). This file extends them with frontend-specific constraints.

---

## Z-index

- (HARD) Toast: 60, Command Palette: 50, Modal: 40, Drawer: 30, Sheet: 20.

---

## Zustand state

- (HARD) Always use `useShallow` when selecting objects from a Zustand store to avoid unnecessary re‑renders.
- (HARD) Never use `useState` for global UI state; it belongs in Zustand slices.
- (HARD) Slices cannot import each other; cross‑slice access must use `get()` (ZUSTANDCIRCULAR rule).

---

## React compiler & memoization

- (HARD) React Compiler enabled globally; no manual `useMemo`/`useCallback`/`React.memo`.
- (HARD) Exception: React Hook Form components need the `"use no memo"` directive.
- (MED) Zustand `persist` wrappers must use conditional rendering, not Suspense.

### React compiler production readiness assessment (April 2026)

- **Status**: React Compiler v1.0 released October 7, 2025 - STABLE release
- **Production Validation**: Battle-tested on major apps at Meta (e.g., Meta Quest Store)
- **Performance Results**: Up to 12% improvement in initial loads and cross-page navigations; some interactions >2.5× faster; memory usage stays neutral
- **Compatibility**: React 17 and up; safe by design (skips optimization if cannot safely optimize rather than breaking code)
- **Known Issues**: Some third-party library hooks return new objects on every render, breaking memoization chains (e.g., TanStack Query's useMutation(), Material UI's useTheme(), React Router's useLocation())
- **Recommendation**: Only compile own source code with React Compiler; do NOT compile 3rd-party code. Library authors have full control over whether to use React Compiler or manually optimize.

---

## UI patterns

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

---

## Drag & drop

- (HARD) All drag‑and‑drop uses a centralised `dnd‑kit` facade (never import directly from the library elsewhere).
- (HARD) `DragOverlay` must be used to render a copy of the dragged element, never drag the original DOM node.
- (HARD) Keyboard alternatives must be provided for all drag operations (WCAG 2.5.7).

---

## Editor / Monaco

- (HARD) Monaco Editor is sandboxed in a separate iframe with its own CSP.
- (HARD) Monaco is lazy‑loaded (React.lazy + Suspense + skeleton), never in the initial bundle.

---

## Storage

- (HARD) `localStorage` usage limited to ≤3 MB; implement an eviction priority.
- (HARD) Zustand `persist` must include version, migrate, and partialize functions.

---

## URL state

- (HARD) More than 3 URL search params must use `useQueryStates` (not multiple `useQueryState` calls).

---

## Design tokens

- (HARD) No hardcoded hex/RGB colours; reference OKLCH CSS custom properties only.

---

## Accessibility (all UI)

- (HARD) WCAG 2.2 AA everywhere, including keyboard navigation, screen reader announcements, and focus order.
- (HARD) Canvas‑only or purely visual components must have an alternative text representation.
- (MED) Use `react-helmet-async` for per‑route meta tags.
