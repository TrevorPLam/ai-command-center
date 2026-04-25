# 10-Dashboard — Personal AI Command Center Frontend

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.  
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.

---

## 📋 Frontend Context

All tasks implicitly rely on the shared infrastructure defined in `01-Foundations.md`.  
**Do not repeat any of the following** – they are global:

- React 18 + TypeScript (strict mode)
- Zustand (UI state) + TanStack Query (server state)
- Tailwind CSS v4 (`@theme` CSS‑first) + shadcn/ui
- Motion v12 with `useReducedMotion()` guard
- Testing: Vitest + RTL + MSW
- Routing: React Router v7 (data mode, lazy routes)
- Virtualization: `@tanstack/react-virtual`
- Drag & drop: dnd‑kit with shared `useDndSensors` hook
- Forms: react‑hook‑form + zod
- Offline: Dexie (centralised `CommandCenterDB`)
- Accessibility: WCAG 2.2 AA, keyboard navigation, focus restoration

---

## 🧱 Cross‑Cutting Foundations (Module‑Specific)

| ID | Area | Requirement |
|----|------|-------------|
| DASH-C01 | Animation | Scroll-triggered: `viewport={{ once: true }}` |
| DASH-C02 | Animation | Animate only `transform` and `opacity` |
| DASH-C03 | Virtualization | `@tanstack/react-virtual` for ActivityFeed |
| DASH-C04 | State | Filter updates via `useTransition` + `startTransition` |
| DASH-C05 | Data Fetching | Optimistic updates via canonical pattern |
| DASH-C06 | Accessibility | ActivityFeed: `role="log"` + `aria-live="polite"` |
| DASH-C07 | Layout | RightPanel on `/` injected with `AttentionQueue` |

---

## 🎯 Motion Tier Assignment

| Component | Tier | Allowed Techniques |
|-----------|------|--------------------|
| AmbientStatusBanner | Alive | Animated conic-gradient border, spring height |
| AgentCard | Alive | Staggered entrance, hover oklch glow, layoutId morph |
| ActivityEntry | Alive | Spring slide-in for new items |
| DecisionPacket | Quiet | Entrance fade (≤200ms), spring countdown |
| ActivityFeed Rows | Static | No animation |

---

## 🗂️ Task DASH-000: Domain Contract Layer

**Priority:** 🔴 High  
**Est. Effort:** 0.75 hours  
**Depends On:** FND-006  

**Related Files**  
- `src/types/dashboard.ts`
- `src/schemas/dashboard.ts`
- `src/queries/dashboard.ts`

### Subtasks

- [ ] **DASH-000A**: Define TypeScript interfaces for Agent, ActivityEntry, and DecisionPacket.
- [ ] **DASH-000B**: Create Zod schemas mirroring types for runtime API validation.
- [ ] **DASH-000C**: Create `queryOptions` for agents, activity, and attention-queue with Zod parsing.
- [ ] **DASH-000D**: Create stub fetch functions in `src/api/dashboard.ts`.

### Definition of Done

- [ ] Types and schemas strictly match API contract.
- [ ] Zod parsing implemented at the query boundary.
- [ ] All types exported and compile correctly.
- [ ] All tests pass.

---

## 🗂️ Task DASH-001: Mock Data & Custom Hooks

**Priority:** 🔴 High  
**Est. Effort:** 1.0 hours  
**Depends On:** DASH-000, FND-004  

**Related Files**  
- `src/mocks/factories/dashboard.ts`
- `src/mocks/handlers/dashboard.ts`
- `src/hooks/useDashboard.ts`

### Subtasks

- [ ] **DASH-001A**: Create data factories using `@faker-js/faker` with reproducible seeds.
- [ ] **DASH-001B**: Implement stateful MSW handlers that persist mutations in-memory.
- [ ] **DASH-001C**: Create custom hooks consuming `queryOptions` with full inference.
- [ ] **DASH-001D**: Implement optimistic mutations for decision approvals/rejections.
- [ ] **DASH-001E**: **[TEST]** Verify hook behavior and optimistic rollbacks.

### Definition of Done

- [ ] Factories produce valid, deterministic test data.
- [ ] MSW session maintains state across reloads.
- [ ] Optimistic updates feel instant and roll back correctly on error.
- [ ] All tests pass.

---

## 🗂️ Task DASH-002: Page Layout & Route Configuration

**Priority:** 🔴 High  
**Est. Effort:** 0.5 hours  
**Depends On:** FND-007, FND-008  

**Related Files**  
- `src/pages/Dashboard.tsx`
- `src/router/routes.ts`

### Subtasks

- [ ] **DASH-002A**: Create two-column Dashboard layout with responsive breakpoints.
- [ ] **DASH-002B**: Configure route with `lazy` loading and prefetching loader.
- [ ] **DASH-002C**: Inject `AttentionQueue` into RightPanel via outlet context.
- [ ] **DASH-002D**: **[TEST]** Verify navigation and layout rendering.

### Definition of Done

- [ ] / route renders Dashboard with correct columns.
- [ ] Data is prefetched before component mount.
- [ ] Page transitions are smooth and location-keyed.
- [ ] All tests pass.

---

## 🗂️ Task DASH-003: AmbientStatusBanner Implementation

**Priority:** 🔴 High  
**Est. Effort:** 1.5 hours  
**Depends On:** DASH-001, DASH-002  

**Related Files**  
- `src/components/dashboard/AmbientStatusBanner.tsx`
- `src/hooks/useAgentStatus.ts`

### Subtasks

- [ ] **DASH-003A**: Implement `useAgentStatus` hook to derive fleet-wide thinking state.
- [ ] **DASH-003B**: Build banner with animated conic-gradient border via `@property`.
- [ ] **DASH-003C**: Implement smooth entrance/exit via `AnimatePresence` and `layout`.
- [ ] **DASH-003D**: **[TEST]** Verify banner visibility and reduced motion compliance.

### Definition of Done

- [ ] Banner only appears when agents are active.
- [ ] Border animation is GPU-accelerated and respects OS settings.
- [ ] Dismiss state persists in local storage.
- [ ] All tests pass.

---

## 🗂️ Task DASH-004: Agent Fleet Panel & Cards

**Priority:** 🔴 High  
**Est. Effort:** 2.5 hours  
**Depends On:** DASH-001, DASH-002  

**Related Files**  
- `src/components/dashboard/AgentFleetPanel.tsx`
- `src/components/dashboard/AgentCard.tsx`

### Subtasks

- [ ] **DASH-004A**: Build `AgentCard` with status pulses and oklch glow effects.
- [ ] **DASH-004B**: Implement `layoutId` for smooth card-to-drawer morphing.
- [ ] **DASH-004C**: Build grid panel with staggered entrance animations.
- [ ] **DASH-004D**: Wrap panel in `LayoutGroup` to namespace animation IDs.
- [ ] **DASH-004E**: **[TEST]** Verify card interactions and grid responsiveness.

### Definition of Done

- [ ] Cards stagger in gracefully on first load.
- [ ] Status pulses only active during `thinking` state.
- [ ] All hover effects are spring-based and feel "alive".
- [ ] All tests pass.

---

## 🗂️ Task DASH-005: Activity Feed Virtualization

**Priority:** 🔴 High  
**Est. Effort:** 3.5 hours  
**Depends On:** DASH-001, DASH-002  

**Related Files**  
- `src/components/dashboard/ActivityFeed.tsx`
- `src/components/dashboard/ActivityEntry.tsx`

### Subtasks

- [ ] **DASH-005A**: Build `ActivityEntry` with expandable details and spring chevrons.
- [ ] **DASH-005B**: Implement virtualization using `@tanstack/react-virtual`.
- [ ] **DASH-005C**: Setup filter tabs using `useTransition` for non-blocking UI.
- [ ] **DASH-005D**: Implement `role="log"` and `aria-live` for accessible updates.
- [ ] **DASH-005E**: **[TEST]** Verify virtualization performance and accessibility.

- [ ] **[TEST] DASH-006I**: Packets render with correct priority badge class
- [ ] **[TEST] DASH-006J**: Approve button calls `approveDecision(packet.id)`
- [ ] **[TEST] DASH-006K**: Optimistic update removes packet immediately (before server responds)
- [ ] **[TEST] DASH-006L**: Failed approval restores packet and shows error toast
- [ ] **[TEST] DASH-006M**: Countdown timer updates every second (use `vi.useFakeTimers()`)
- [ ] **[TEST] DASH-006N**: Empty state renders when `packets = []`

### Definition of Done
- `AnimatePresence mode="popLayout"` — exiting packets don't block remaining items from repositioning
- `layout` prop on packet wrappers — remaining packets animate to new positions
- Countdown uses `useMotionValue` + `useSpring` with `skipInitialAnimation: true`
- Approve/Reject/Defer: optimistic remove with rollback on error
- All 6 tests pass

### Anti-Patterns
- ❌ `AnimatePresence` without `mode="popLayout"` — exiting packet holds its space while animating out; remaining packets don't reflow until exit completes
- ❌ `setInterval` countdown updating `useState` — triggers a React re-render every second; use `useMotionValue` to bypass React
- ❌ Mutating the cache array directly in `setQueryData` — always return a new array

---

## 🟠 Task DASH-007: AgentDetailDrawer
**Priority:** 🟠 Medium
**Est. Effort:** 2 hours
**Depends On:** DASH-004

### Related Files
- `src/components/agents/AgentDetailDrawer.tsx` · `src/stores/slices/uiSlice.ts` (update)

### Subtasks

**Implementation:**
- [ ] **DASH-007A**: Extend `uiSlice`:
  - Add `agentDrawerOpen: boolean`, `selectedAgentId: string | null`
  - Add `openAgentDrawer(id: string)` and `closeAgentDrawer()`
- [ ] **DASH-007B**: Build `AgentDetailDrawer` using shadcn/ui `Sheet` (right side, 480px):
  - Header: large avatar, agent name, `StatusIndicator`
  - Body: current task (full), token usage sparkline placeholder, session history list, config (model, temperature — read-only)
  - Footer: "Send Message" CTA
- [ ] **DASH-007C**: `layoutId` morph from AgentCard:
  - In `AgentDetailDrawer`, the main card content area uses `motion.div layoutId={`agent-card-${selectedAgentId}`}`
  - This must use the same `layoutId` as the card in `AgentCard`
  - `LayoutGroup id="agent-fleet"` in `AgentFleetPanel` (DASH-004F) namespaces the ID, so the drawer must be inside or connected to the same `LayoutGroup` — wrap the drawer's `motion.div` with the matching `layoutId` outside any `LayoutGroup` to allow cross-tree matching
  - The scrollable content inside the drawer needs `layoutScroll` prop to account for scroll offset during the morph
- [ ] **DASH-007D**: Focus restoration:
  - On `openAgentDrawer()`: store `document.activeElement` in `uiSlice.focusTriggerRef`
  - On drawer close: `focusTriggerRef.current?.focus()`
- [ ] **DASH-007E**: "Send Message" button: `navigate('/chat', { state: { agentId: selectedAgentId, prefill: true } })`
- [ ] **DASH-007F**: Fetch agent detail data: `useAgent(selectedAgentId)` — uses `select` to find agent from cached fleet list; no extra network request if fleet is cached

**Tests:**
- [ ] **[TEST] DASH-007G**: Drawer opens when `openAgentDrawer(id)` is called
- [ ] **[TEST] DASH-007H**: Correct agent data displays (mock `useAgent`)
- [ ] **[TEST] DASH-007I**: "Send Message" navigates to `/chat` with state payload
- [ ] **[TEST] DASH-007J**: Focus returns to expand button after close

### Definition of Done
- Drawer opens with `layoutId` morph from card
- `layoutScroll` on scrollable container inside drawer
- Focus restoration works
- `useAgent` uses `select` — no duplicate API request

### Anti-Patterns
- ❌ `layoutId` in drawer without matching the card's exact `layoutId` string — morph breaks silently
- ❌ Missing `layoutScroll` on scrollable drawer content — morph animates to wrong position when page is scrolled
- ❌ Separate `/api/agents/:id` call for drawer when fleet is already cached — use `select` on the existing cache

---

## 📊 Dependency Graph

```
DASH-000 (Types + Schemas + queryOptions)
     │
DASH-001 (Factories + MSW Handlers + Hooks)
     │
     ├──────────────────────────────────────────┐
     │                                          │
DASH-002 (Page Layout) ←───────────────────────┘
     │
     ├───────────────┬───────────────┬──────────┐
     │               │               │          │
DASH-003          DASH-004        DASH-005   DASH-006
(Banner)      (AgentPanel)   (ActivityFeed) (AttentionQueue)
                   │
              DASH-007 (Drawer)
```

---

## 🏁 Dashboard Completion Checklist

**Contract & Mocks:**
- [ ] Zod schemas defined; types derived from schemas
- [ ] `@faker-js/faker` used in all factories with `resetDashboardDb()` export
- [ ] MSW handlers stateful; mutations persist in-memory session
- [ ] `delay()` in all handlers for loading state testing
- [ ] `queryOptions` + custom hooks with full type inference
- [ ] Optimistic updates: `onMutate` in `useMutation()` + immutable cache updates

**Layout & Routing:**
- [ ] `/` prefetches agents in route `loader`
- [ ] `AttentionQueue` injected into RightPanel on `/`
- [ ] `DashboardSkeleton` shown during lazy load

**Components:**
- [ ] `AmbientStatusBanner`: animated border (reduced-motion gated), `AnimatePresence`, dismiss persisted
- [ ] `AgentFleetPanel`: wrapped in `LayoutGroup id="agent-fleet"`, `viewport={{ once: true }}`
- [ ] `AgentCard`: `staggerChildren: 0.08`, `oklch()` glow on hover, `layoutId`
- [ ] `ActivityFeed`: `VariableSizeList` + memoized `Row` + `resetAfterIndex` on expand
- [ ] `ActivityEntry`: memoized with `React.memo()`
- [ ] Filter: `startTransition(() => setFilter(...))` — single state
- [ ] `AttentionQueue`: `AnimatePresence mode="popLayout"` + `layout` prop on items
- [ ] `DecisionPacket`: `useMotionValue` + `useSpring` countdown (`skipInitialAnimation: true`)
- [ ] `AgentDetailDrawer`: `layoutId` morph + `layoutScroll` + focus restoration

**Accessibility:**
- [ ] `role="log"` + implicit `aria-live="polite"` on ActivityFeed
- [ ] `role="article"` on each decision packet
- [ ] All buttons: descriptive `aria-label`
- [ ] All interactive elements: visible focus indicators

**Performance:**
- [ ] All `viewport={{ once: true }}` on scroll-triggered animations
- [ ] `transform` + `opacity` only — no layout properties animated
- [ ] `VariableSizeList` Row wrapped in `React.memo()`
- [ ] `useMemo` on filtered activity entries