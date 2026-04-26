# Frontend rules

These rules apply to all frontend code. Violating a **HARD** rule will block a PR.

> **Canonical source**: All rules are defined in [00-RULES.yaml](00-RULES.yaml). This file provides frontend-specific context.

---

## Z-index

- #FE-09: Toast: 60, Command Palette: 50, Modal: 40, Drawer: 30, Sheet: 20

---

## Zustand state

- #FE-10: Always use useShallow when selecting objects from a Zustand store to avoid unnecessary re-renders
- #FE-11: Never use useState for global UI state; it belongs in Zustand slices
- #FE-12: Slices cannot import each other; cross-slice access must use get() (ZUSTANDCIRCULAR rule)

---

## React compiler & memoization

- #FE-13: React Compiler enabled globally; no manual useMemo/useCallback/React.memo
- #FE-14: Exception: React Hook Form components need the "use no memo" directive
- #FE-15: Zustand persist wrappers must use conditional rendering, not Suspense

### React compiler production readiness assessment (April 2026)

- **Status**: React Compiler v1.0 released October 7, 2025 - STABLE release
- **Production Validation**: Battle-tested on major apps at Meta (e.g., Meta Quest Store)
- **Performance Results**: Up to 12% improvement in initial loads and cross-page navigations; some interactions >2.5× faster; memory usage stays neutral
- **Compatibility**: React 17 and up; safe by design (skips optimization if cannot safely optimize rather than breaking code)
- **Known Issues**: Some third-party library hooks return new objects on every render, breaking memoization chains (e.g., TanStack Query's useMutation(), Material UI's useTheme(), React Router's useLocation())
- **Recommendation**: Only compile own source code with React Compiler; do NOT compile 3rd-party code. Library authors have full control over whether to use React Compiler or manually optimize.

---

## UI patterns

- #FE-16: Empty states always render an EmptyState component with a call-to-action; never show a blank screen
- #FE-17: Loading states: skeleton/shimmer if load time <2 seconds; spinner if >2 seconds
- #FE-18: Error states: display a retry button and human-readable message
- #FE-19: Offline state: show a connectivity indicator; queue actions for later
- #FE-20: Optimistic mutations: pending = opacity 0.5 + italic + pulse; 5-second undo for delete operations
- #FE-21: Stagger no more than 3 children in any animation
- #FE-22: Only transform and opacity may be animated. No layout property animations
- #FE-23: Respect prefers-reduced-motion; if active, all animations become instant
- #FE-24: Avoid animations longer than 5 seconds (WCAG 2.2.2)
- #FE-25: Filter updates should be wrapped in useTransition to keep the UI responsive

---

## Drag & drop

- #FE-26: All drag-and-drop uses a centralised dnd-kit facade (never import directly from the library elsewhere)
- #FE-27: DragOverlay must be used to render a copy of the dragged element, never drag the original DOM node
- #FE-28: Keyboard alternatives must be provided for all drag operations (WCAG 2.5.7)

---

## Editor / Monaco

- #FE-29: Monaco Editor is sandboxed in a separate iframe with its own CSP
- #FE-30: Monaco is lazy-loaded (React.lazy + Suspense + skeleton), never in the initial bundle

---

## Storage

- #FE-31: localStorage usage limited to <=3 MB; implement an eviction priority
- #FE-32: Zustand persist must include version, migrate, and partialize functions

---

## URL state

- #FE-33: More than 3 URL search params must use useQueryStates (not multiple useQueryState calls)

---

## Design tokens

- #FE-34: No hardcoded hex/RGB colours; reference OKLCH CSS custom properties only

---

## Accessibility (all UI)

- #FE-35: WCAG 2.2 AA everywhere, including keyboard navigation, screen reader announcements, and focus order
- #FE-36: Canvas-only or purely visual components must have an alternative text representation
- #FE-37: Use react-helmet-async for per-route meta tags