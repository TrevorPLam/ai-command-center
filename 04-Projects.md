# 04-Projects — Personal AI Command Center Frontend (Enhanced v3)

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.

---

## 🧱 Cross-Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **PROJ-C01** | State Selectors | All Zustand subscriptions use selector functions: `useProjectStore(s => s.activeView)` — never `useProjectStore()`. Full-store subscriptions cause re-renders on every state change. |
| **PROJ-C02** | Optimistic Mutations | All mutations: `onMutate` → snapshot → `onError` rollback → `onSettled` invalidate. Use `onSettled`, not `onSuccess` (fires on both success and error). |
| **PROJ-C03** | Filter Performance | All list/Kanban filters use `useTransition`. No `setTimeout` debounce. `isPending` state drives visual loading indicator. |
| **PROJ-C04** | WCAG 2.5.7 (AA) | **Keyboard shortcuts alone do not satisfy WCAG 2.5.7.** The criterion requires a single-pointer (click/tap) alternative — i.e., a visible button. Keyboard navigation (`KeyboardSensor`) is a bonus on top of the required button alternative. Both Kanban and My Week MUST have "Move to…" buttons on draggable items. |
| **PROJ-C05** | Virtualization Stack | TanStack Table + TanStack Virtual for all tabular data. TanStack Virtual (`useVirtualizer`) for task lists. No `react-base-table`, no `react-window` — they are outside the existing TanStack ecosystem already used in this codebase. |
| **PROJ-C06** | dnd-kit Sensors | Always combine `PointerSensor` (with `activationConstraint: { distance: 5 }` to prevent accidental drag-on-click) and `KeyboardSensor` (with `sortableKeyboardCoordinates`). Activate both via `useSensors`. |
| **PROJ-C07** | DragOverlay Pattern | `DragOverlay` always renders a **clone** of the dragged item, not the original. Apply `boxShadow: '0 0 16px oklch(62% 0.19 264 / 0.4)'` to overlay clone. Original card reduces to opacity 0.4 while dragging. |
| **PROJ-C08** | Inline Edit Contract | All inline-editable fields: `useForm({ defaultValues: current })` → Enter/blur saves → Escape calls `reset(original)` and cancels. Validation via Zod schema. Save via optimistic mutation. |
| **PROJ-C09** | Hover Prefetch | Project rows/cards: `onMouseEnter` calls `queryClient.prefetchQuery(projectDetailQueryOptions(id))` with a 200ms delay (cancel on `onMouseLeave` with `clearTimeout`) to avoid aggressive prefetch on cursor pass-through. |
| **PROJ-C10** | Test Infrastructure | All network calls mocked via MSW handlers in `src/mocks/handlers/projects.ts`. Fresh `QueryClient` per test via `createWrapper()`. Zustand store reset between tests via `useProjectStore.setState(initialState)` in `beforeEach`. |

### Motion Tier Assignment

| Component | Tier | Technique |
|-----------|------|-----------|
| View switcher active state | **Quiet** | Opacity fade 150ms; active indicator slides with `layout` prop |
| Project list rows | **Static** | Instant render; no animation |
| Kanban card (drag overlay) | **Alive** | Scale `1.02` + blue glow boxShadow; `rotate: 1deg` tilt |
| Kanban drop indicator | **Alive** | `scaleY: 0→1`, spring stiffness 400 damping 30 |
| Timeline bar entrance | **Alive** | `scaleX: 0→1`, `transformOrigin: 'left'`, staggered by task index |
| Timeline tooltip | **Quiet** | `AnimatePresence` opacity 150ms |
| Task row expand | **Alive** | `layout` prop for height; `AnimatePresence` for subtask list |
| My Week lane drop indicator | **Alive** | Same as Kanban drop indicator |
| Task Drawer open/close | **Alive** | `x: '100%'→0` slide, spring stiffness 300 damping 35 |
| Project Detail tabs | **Quiet** | Active underline slides via `layout` prop |

---

## 🗃️ Task PROJ-000: Mock Data Layer
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** FND-004 (Testing), FND-006 (TanStack Query)

### Related Files
`src/mocks/factories/projects.ts` · `src/mocks/handlers/projects.ts` · `src/queries/projects.ts`

### Subtasks

- [ ] **PROJ-000A**: Create `src/mocks/factories/projects.ts`:
  - `createMockProject(overrides?)`: realistic fields — `id`, `name`, `status` (`'active' | 'on-hold' | 'completed' | 'archived'`), `priority` (`'low' | 'medium' | 'high' | 'urgent'`), `startDate`, `dueDate`, `progress`, `ownerId`, `tags[]`, `memberIds[]`
  - `createMockTask(projectId, overrides?)`: `id`, `title`, `status`, `priority`, `assigneeId`, `dueDate`, `sectionId`, `order`, `subtasks[]`, `description`, `toolCalls?`
  - `createMockSection(projectId, overrides?)`: `id`, `name`, `order`, `collapsed`
  - `createMockProjectTemplate(overrides?)`: named preset with seed tasks and sections
- [ ] **[TEST] PROJ-000A**: Factories produce valid data; overrides merge correctly; IDs are unique across calls (use `crypto.randomUUID()`)

- [ ] **PROJ-000B**: Create `src/mocks/handlers/projects.ts` with MSW handlers:
  - `GET /api/projects` → paginated project list with optional `?status=&priority=&search=`
  - `GET /api/projects/:id` → single project detail
  - `GET /api/projects/:id/tasks` → tasks with sections
  - `POST /api/projects` → create project; echoes back with generated ID
  - `PATCH /api/projects/:id` → update project fields
  - `DELETE /api/projects/:id` → soft-delete
  - `POST /api/projects/:id/tasks` → create task
  - `PATCH /api/tasks/:id` → update task (status, assignee, order, section)
  - `GET /api/templates` → template list
- [ ] **[TEST] PROJ-000B**: Each handler returns correct shape; `PATCH` merges partial updates; `DELETE` returns 204

- [ ] **PROJ-000C**: Create `src/queries/projects.ts` with Query Key Factory:
  ```ts
  export const projectKeys = {
    all: ['projects'] as const,
    lists: () => [...projectKeys.all, 'list'] as const,
    list: (filters: ProjectFilters) => [...projectKeys.lists(), filters] as const,
    details: () => [...projectKeys.all, 'detail'] as const,
    detail: (id: string) => [...projectKeys.details(), id] as const,
    tasks: (projectId: string) => [...projectKeys.detail(projectId), 'tasks'] as const,
    templates: () => [...projectKeys.all, 'templates'] as const,
  }
  ```
- [ ] **[TEST] PROJ-000C**: Key factory produces structurally distinct arrays per entity; `list({ status: 'active' })` differs from `list({ status: 'completed' })`

- [ ] **PROJ-000D**: Define `projectsQueryOptions(filters)` and `projectDetailQueryOptions(id)` with:
  - `staleTime: 30_000` (30s — projects change less frequently than chat messages)
  - `gcTime: 5 * 60 * 1000` (5 min)
- [ ] **PROJ-000E**: Define mutation hooks: `useCreateProject()`, `useUpdateProject()`, `useDeleteProject()`, `useUpdateTask()` — all implement full `onMutate → snapshot → onError → onSettled` pattern
- [ ] **[TEST] PROJ-000E**: `useUpdateProject` optimistically mutates cache; rollback on error; `onSettled` invalidates `projectKeys.detail(id)`

### Definition of Done
- Factories produce realistic typed data with `crypto.randomUUID()` IDs
- MSW handlers cover all CRUD endpoints with query param support
- `projectKeys` factory fully typed
- All mutation hooks implement optimistic pattern with rollback
- `createWrapper()` from CHAT spec reused (or extended) for project tests

---

## 🔧 Task PROJ-001: Project State — Zustand `projectSlice`
**Priority:** 🔴 High | **Est. Effort:** 45 min | **Depends On:** FND-005 (Zustand)

### Related Files
`src/stores/slices/projectSlice.ts` · `src/stores/index.ts`

### Subtasks

- [ ] **PROJ-001A**: Define `projectSlice` state shape:
  ```ts
  type ProjectState = {
    activeView: 'list' | 'kanban' | 'timeline' | 'my-week' | 'workload'
    filters: {
      status: ProjectStatus[]
      priority: Priority[]
      tags: string[]
      dueDateRange: { from: Date | null; to: Date | null }
      search: string
    }
    sort: { field: 'name' | 'status' | 'dueDate' | 'priority' | 'progress'; order: 'asc' | 'desc' }
    selectedProjectId: string | null
    expandedTaskIds: Set<string>
    taskDrawerTaskId: string | null
  }
  ```
- [ ] **[TEST] PROJ-001A**: Initial state has correct defaults; state shape matches TypeScript type

- [ ] **PROJ-001B**: Define actions: `setActiveView`, `setFilter`, `clearFilters`, `setSort`, `setSelectedProject`, `toggleTaskExpanded`, `openTaskDrawer`, `closeTaskDrawer`
- [ ] **[TEST] PROJ-001B**: Each action produces correct next state; `toggleTaskExpanded` adds to Set if absent, removes if present

- [ ] **PROJ-001C**: Export atomic selector hooks — **never export the full store**:
  ```ts
  export const useActiveView = () => useProjectStore(s => s.activeView)
  export const useProjectFilters = () => useProjectStore(s => s.filters)
  export const useProjectSort = () => useProjectStore(s => s.sort)
  export const useTaskDrawer = () => useProjectStore(s => ({
    taskId: s.taskDrawerTaskId,
    open: s.openTaskDrawer,
    close: s.closeTaskDrawer,
  }))
  ```
- [ ] **[TEST] PROJ-001C**: Changing `filters` does not trigger re-render in component subscribed only to `activeView`

- [ ] **PROJ-001D**: Add Zustand `devtools` and `persist` (for `activeView` and `sort` only — do not persist filters or expanded tasks):
  ```ts
  persist(devtools(projectSlice), {
    name: 'project-ui',
    partialize: (state) => ({ activeView: state.activeView, sort: state.sort }),
  })
  ```
- [ ] **[TEST] PROJ-001D**: `activeView` survives a store re-initialization (simulates page reload); filters do not persist

### Definition of Done
- `projectSlice` covers all views, filters, sort, drawer state
- All selectors are atomic; no component subscribes to full store
- `persist` saves only view and sort preferences
- Zustand store reset in `beforeEach` via `useProjectStore.setState(initialState)`

### Anti-Patterns
- ❌ `useProjectStore()` without selector — subscribes to entire store; re-renders on every action
- ❌ Persisting filter state — filters should be ephemeral; persisting them causes stale filter state across sessions
- ❌ `Set` in persisted state — `JSON.stringify` cannot serialize a `Set`; convert to array for persistence if needed

---

## 🗂️ Task PROJ-002: Projects Page Layout, Route & View Switcher
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** PROJ-000, PROJ-001, FND-007 (Router)

### Related Files
`src/pages/ProjectsPage.tsx` · `src/components/projects/ViewSwitcher.tsx` · `src/components/projects/ProjectFilterBar.tsx`

### Subtasks

- [ ] **PROJ-002A**: Configure route in `src/router/routes.ts`:
  ```ts
  {
    path: 'projects',
    lazy: () => import('@/pages/ProjectsPage'),
    loader: () => queryClient.ensureQueryData(projectsQueryOptions({})),
  }
  {
    path: 'projects/:projectId',
    lazy: () => import('@/pages/ProjectDetailPage'),
    loader: ({ params }) => queryClient.ensureQueryData(projectDetailQueryOptions(params.projectId!)),
  }
  ```
- [ ] **[TEST] PROJ-002A**: Navigating to `/projects` prefetches project list; loader does not block render (uses `ensureQueryData` not `await`)

- [ ] **PROJ-002B**: Build `ProjectsPage` layout:
  - Top bar: `ViewSwitcher` (left), "New Project" button (right), `ProjectFilterBar` (below top bar, collapsible on mobile)
  - Content area: renders the active view component based on `useActiveView()`
  - Page transition: `<motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}>` on mount
- [ ] **[TEST] PROJ-002B**: Switching `activeView` in store renders corresponding view component; filter bar collapse works on mobile

- [ ] **PROJ-002C**: Build `ViewSwitcher` — five icon-buttons: List, Kanban, Timeline, My Week, Workload:
  - Active state: `bg-white/10` background + active indicator `<motion.div layoutId="view-indicator">` (slides under active icon)
  - Each button: `aria-label="<ViewName> view"` + `aria-pressed={isActive}`
  - On click: `setActiveView(view)` from store
- [ ] **[TEST] PROJ-002C**: Clicking each button updates store `activeView`; `aria-pressed` reflects active state; layout animation indicator present

- [ ] **PROJ-002D**: Build `ProjectFilterBar`:
  - Status multi-select (shadcn Popover + Checkbox)
  - Priority multi-select (same)
  - Due date range picker (shadcn DateRangePicker)
  - Search input (debounced via `useTransition`)
  - "Clear filters" button (visible only when any filter is active)
  - Filter changes dispatch to `useProjectStore` actions; `useTransition` wraps the store dispatch
- [ ] **[TEST] PROJ-002D**: Filter changes update store; `isPending` shows loading indicator during transition; "Clear filters" resets all filters

- [ ] **PROJ-002E**: "New Project" button opens a shadcn `Dialog`:
  - Form with `react-hook-form` + Zod schema: name (required, 3-100 chars), status, priority, start/due dates, description (optional)
  - On submit: call `useCreateProject()` mutation → optimistically append to list cache → close dialog
  - Link to template library ("Start from template" secondary link below form)
- [ ] **[TEST] PROJ-002E**: Form validates name length; submit calls mutation with correct payload; dialog closes on success; optimistic row appears immediately

### Definition of Done
- Routes defined with loader prefetch
- Page layout renders with view switcher, filter bar, new project button
- View switcher with animated active indicator; ARIA `aria-pressed`
- Filter bar uses `useTransition` for non-blocking updates
- "New Project" dialog with validation and optimistic mutation

---

## 📋 Task PROJ-003: Project List View — TanStack Table + Virtual
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** PROJ-000, PROJ-001, PROJ-002

### Related Files
`src/components/projects/ProjectListView.tsx` · `src/components/projects/ProjectListColumns.tsx`

> **Why dedicated task:** The combination of TanStack Table (column model, sorting, filtering) + TanStack Virtual (row virtualization) + hover prefetch + inline status editing requires focused implementation. `react-base-table` is removed from the spec — it is unmaintained and outside the existing TanStack ecosystem.

### Subtasks

- [ ] **PROJ-003A**: Define columns via `createColumnHelper<Project>()`:
  ```ts
  const columnHelper = createColumnHelper<Project>()
  export const projectColumns = [
    columnHelper.display({ id: 'select', ... }),                    // Row checkbox
    columnHelper.accessor('name', { header: 'Project', ... }),      // With inline edit
    columnHelper.accessor('status', { header: 'Status', ... }),     // Status badge dropdown
    columnHelper.accessor('priority', { header: 'Priority', ... }), // Priority chip
    columnHelper.accessor('dueDate', { header: 'Due', ... }),        // Relative date
    columnHelper.accessor('progress', { header: 'Progress', ... }), // Mini progress bar
    columnHelper.accessor('memberIds', { header: 'Members', ... }), // Avatar stack
    columnHelper.display({ id: 'actions', ... }),                    // ⋯ kebab menu
  ]
  ```
- [ ] **[TEST] PROJ-003A**: All 8 columns render in correct order; column definitions are type-safe

- [ ] **PROJ-003B**: Implement `useReactTable` with:
  - `getCoreRowModel()`, `getSortedRowModel()`, `getFilteredRowModel()`
  - Server-side filtering: pass `filters` from Zustand store to `projectsQueryOptions`; do NOT use client-side `getFilteredRowModel` for status/priority (avoids double-filtering)
  - Client-side sort on already-fetched data
  - `columnVisibility` state: hide columns on `<768px` (hide progress, members on mobile)
- [ ] **[TEST] PROJ-003B**: Clicking column header sorts; sort order toggles asc/desc; hidden columns not in DOM on mobile viewport

- [ ] **PROJ-003C**: Integrate `useVirtualizer` for rows:
  ```ts
  const virtualizer = useVirtualizer({
    count: rows.length,
    getScrollElement: () => tableContainerRef.current,
    estimateSize: () => 52,        // Fixed row height (project list rows are uniform)
    overscan: 10,
  })
  ```
  Render only `virtualizer.getVirtualItems()` inside `<tbody>`. Table container has fixed height (fills viewport). `position: absolute` rows with `transform: translateY(virtualItem.start)`.
- [ ] **[TEST] PROJ-003C**: At 200 mock projects, DOM contains ≤30 row elements; scroll does not add more DOM nodes

- [ ] **PROJ-003D**: Hover prefetch with cancel-on-leave:
  ```ts
  let prefetchTimer: ReturnType<typeof setTimeout>
  const handleMouseEnter = (id: string) => {
    prefetchTimer = setTimeout(() =>
      queryClient.prefetchQuery(projectDetailQueryOptions(id)), 200)
  }
  const handleMouseLeave = () => clearTimeout(prefetchTimer)
  ```
- [ ] **[TEST] PROJ-003D**: Hovering row for >200ms calls `prefetchQuery`; leaving before 200ms does not call it

- [ ] **PROJ-003E**: Inline status editing: clicking status badge opens a `Popover` with 5 status options. Selecting calls `useUpdateProject()` mutation optimistically. `Escape` closes without saving.
- [ ] **[TEST] PROJ-003E**: Status popover opens on click; selection immediately updates badge (optimistic); Escape closes without API call

- [ ] **PROJ-003F**: Bulk actions: when rows are selected (checkbox), a bulk action bar appears above table: "Change status", "Assign", "Delete". Use `AnimatePresence` slide-in. Bulk mutations call `Promise.all` with individual `useUpdateProject` mutations.
- [ ] **[TEST] PROJ-003F**: Selecting 3 rows shows bulk bar; "Delete" calls 3 delete mutations; deselecting all hides bulk bar

### Definition of Done
- TanStack Table with 8 typed columns; sorting and server-side filtering
- TanStack Virtual: bounded DOM node count at any dataset size
- Hover prefetch with 200ms debounce and cancel
- Inline status editing via Popover; optimistic update
- Bulk actions bar with `AnimatePresence`

### Anti-Patterns
- ❌ `react-base-table` — unmaintained; not in TanStack ecosystem; no TypeScript column types
- ❌ `getFilteredRowModel()` for server-driven filters — double-filters and stales the display
- ❌ `position: relative` + `top` for virtual rows — forces layout recalculation; use `transform: translateY`
- ❌ Prefetch without debounce — triggers on cursor pass-through; always add 200ms delay

---

## 📌 Task PROJ-004: Kanban View
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** PROJ-000, PROJ-001

### Related Files
`src/components/projects/ProjectKanbanView.tsx` · `src/components/projects/KanbanColumn.tsx` · `src/components/projects/KanbanCard.tsx`

### Subtasks

- [ ] **PROJ-004A**: Define Kanban columns: `Backlog → To Do → In Progress → In Review → Done`. Each column maps to a project `status` value. Column list is config-driven (array), not hardcoded.
- [ ] **[TEST] PROJ-004A**: Five columns render; column titles match status labels; empty columns show empty state placeholder

- [ ] **PROJ-004B**: Configure `DndContext` sensors:
  ```ts
  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: { distance: 5 }, // Prevents drag on click
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    }),
  )
  ```
  Collision detection: `closestCenter` for within-column sorting; `pointerWithin` for cross-column targeting. Combine with `rectIntersection` fallback:
  ```ts
  collisionDetection={customCollisionDetectionAlgorithm}
  ```
  where the custom algorithm tries `pointerWithin` first, then falls back to `closestCenter`.
- [ ] **[TEST] PROJ-004B**: `PointerSensor` does not trigger drag on a single click; `KeyboardSensor` activates on Space/Enter

- [ ] **PROJ-004C**: Wrap each column in `<SortableContext items={columnCardIds}>`. Each card uses `useSortable`. Track `activeId` in state on `onDragStart`. Render `<DragOverlay>` with a cloned card component using the `activeId`.
- [ ] **[TEST] PROJ-004C**: During drag, original card shows at 0.4 opacity; overlay clone follows cursor with glow

- [ ] **PROJ-004D**: Drop indicator: when dragging over a column, render an animated insertion line between cards:
  ```tsx
  <motion.div
    layoutId="drop-indicator"
    initial={{ scaleY: 0 }}
    animate={{ scaleY: 1 }}
    style={{ height: 2, background: 'oklch(62% 0.19 264)' }}
    transition={{ type: 'spring', stiffness: 400, damping: 30 }}
  />
  ```
- [ ] **[TEST] PROJ-004D**: Drop indicator renders at correct position between cards; disappears on drop

- [ ] **PROJ-004E**: `onDragEnd` handler:
  1. Determine source column and target column from `active` and `over`
  2. If same column: `arrayMove` within column, update local order
  3. If different column: move card to target column, update `status`
  4. Dispatch `useUpdateProject()` optimistic mutation for the status change
  5. Rollback if mutation fails
- [ ] **[TEST] PROJ-004E**: Dropping card in same column reorders without status change; dropping in different column updates status optimistically; API error rolls back

- [ ] **PROJ-004F**: **WCAG 2.5.7 single-pointer alternative** — "Move to…" button on each `KanbanCard`:
  - Visible as `⋯` kebab menu item: "Move to → [column name]" submenu
  - Rendered as `<button>` elements (single-pointer compliant)
  - Selecting a column calls the same `useUpdateProject()` mutation as drag
  - This satisfies WCAG 2.5.7 AA (keyboard shortcuts alone do not satisfy the criterion)
- [ ] **[TEST] PROJ-004F**: "Move to → In Progress" button moves card without dragging; same mutation called as drag

- [ ] **PROJ-004G**: Cards must NOT contain focusable children (`<input>`, `<textarea>`, `<select>`) — known dnd-kit conflict. Card click opens `TaskDetailDrawer` via `useTaskDrawer().open(taskId)`.
- [ ] **[TEST] PROJ-004G**: Clicking card body (not drag handle) opens drawer; no inputs exist inside card DOM

### Definition of Done
- Five status columns with config-driven setup
- `PointerSensor` with `activationConstraint: { distance: 5 }` + `KeyboardSensor`
- Custom collision detection (cross-column `pointerWithin` + within-column `closestCenter`)
- `DragOverlay` clone with glow; original at 0.4 opacity
- Drop indicator animation
- Optimistic status update with rollback
- WCAG 2.5.7 "Move to…" button alternative (single-pointer, not just keyboard)
- No focusable children inside cards

### Anti-Patterns
- ❌ No `activationConstraint` — every click becomes a drag attempt
- ❌ `closestCenter` for cross-column detection — misattributes the target when columns are adjacent; use `pointerWithin` first
- ❌ Focusable inputs inside `useSortable` cards — conflicts with dnd-kit focus management
- ❌ Keyboard-only alternative for WCAG 2.5.7 — the spec requires single-pointer (button); keyboard is supplementary

---

## 📅 Task PROJ-005: Timeline (Gantt) View
**Priority:** 🟠 Medium | **Est. Effort:** 2.5 hours | **Depends On:** PROJ-000, PROJ-001

### Related Files
`src/components/projects/ProjectTimelineView.tsx`

### Subtasks

- [ ] **PROJ-005A**: Install SVAR React Gantt:
  ```sh
  pnpm add @svar-ui/react-gantt
  ```
  Import CSS: `import '@svar-ui/react-gantt/all.css'`. Apply CSS variable overrides to match app dark theme (override `--wx-background`, `--wx-color-primary` etc. in a scoped wrapper div).
- [ ] **[TEST] PROJ-005A**: Gantt component renders without console errors; theme variables applied (primary color matches electric blue)

- [ ] **PROJ-005B**: Transform `useProjects()` data to SVAR task format:
  ```ts
  const ganttTasks = projects.map(p => ({
    id: p.id,
    text: p.name,
    start: new Date(p.startDate),
    end: new Date(p.dueDate),
    progress: p.progress,
    type: 'task',
  }))
  ```
  Handle missing `startDate` (set to today) and missing `dueDate` (set to 7 days from start) gracefully.
- [ ] **[TEST] PROJ-005B**: Projects with missing dates render without crash; transformed array has same length as projects array

- [ ] **PROJ-005C**: Configure zoom controls (Day / Week / Month / Quarter). Render as a `<SegmentedControl>` above the Gantt chart. Zoom state managed in component `useState` (ephemeral UI state — not in Zustand).
- [ ] **[TEST] PROJ-005C**: Clicking "Month" updates Gantt scale; zoom state does not survive view switch (ephemeral)

- [ ] **PROJ-005D**: Configure `<Gantt>` props:
  - `tasks={ganttTasks}`
  - `scales={[{ unit: activeZoom, step: 1, format: '...' }]}`
  - `columns={[{ id: 'text', header: 'Project', width: 200 }]}`
  - `onTaskUpdate`: called when user drags a bar — dispatch `useUpdateProject({ startDate, dueDate })` optimistically
  - Dark theme via CSS variable override wrapper
- [ ] **[TEST] PROJ-005D**: Dragging a Gantt bar calls `useUpdateProject` with updated dates; optimistic update reflects immediately in bar position

- [ ] **PROJ-005E**: Bar entrance animation: SVAR does not expose per-bar animation hooks, so apply a CSS animation via the theme override:
  ```css
  .gantt-bar {
    animation: scaleInLeft 300ms ease forwards;
    transform-origin: left;
  }
  @keyframes scaleInLeft {
    from { transform: scaleX(0); opacity: 0; }
    to   { transform: scaleX(1); opacity: 1; }
  }
  ```
  Apply `animation-delay` based on task index via a CSS custom property injected by the `onTaskRender` callback.
- [ ] **[TEST] PROJ-005E**: Each bar has `animation` CSS property; delay increases with task index

- [ ] **PROJ-005F**: Empty state: when `projects.length === 0`, show illustration and "Create your first project" CTA rather than an empty Gantt.
- [ ] **[TEST] PROJ-005F**: Empty state renders when no projects; Gantt does not render with zero tasks

### Definition of Done
- SVAR React Gantt renders with dark theme override
- Data transformation handles missing dates gracefully
- Zoom controls (Day/Week/Month/Quarter)
- Drag-to-reschedule calls optimistic mutation
- CSS bar entrance animation with staggered delay
- Empty state handled

### Anti-Patterns
- ❌ `frappe-gantt` — vanilla JS only, no React integration, sparse feature set
- ❌ Custom SVG Gantt — weeks of work; SVAR is MIT-licensed and handles edge cases
- ❌ Zoom state in Zustand — ephemeral view preference; component `useState` is correct here

---

## 📆 Task PROJ-006: My Week View
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** PROJ-000, PROJ-001

### Related Files
`src/components/projects/MyWeekView.tsx` · `src/components/projects/WeekLane.tsx`

> **Why dedicated task:** My Week has distinct logic from the Workload view — dnd-kit cross-lane dragging, date-based lane assignment, and its own WCAG 2.5.7 alternative. Separate tasks avoid conflating two very different technical implementations.

### Subtasks

- [ ] **PROJ-006A**: Define four swim lanes:
  ```ts
  const LANES = [
    { id: 'to-plan',   label: 'To Plan',   description: 'Unscheduled tasks' },
    { id: 'this-week', label: 'This Week',  description: 'Due Mon–Sun' },
    { id: 'later',     label: 'Later',      description: 'Due after this week' },
    { id: 'cleared',   label: 'Cleared',    description: 'Completed this week' },
  ]
  ```
  Lane assignment logic: `to-plan` ← tasks with no `dueDate`; `this-week` ← tasks due within current ISO week; `later` ← tasks due after; `cleared` ← tasks with `status === 'done'` updated this week.
- [ ] **[TEST] PROJ-006A**: Task with `dueDate = next Monday` is in `later`; task with `dueDate = today` is in `this-week`; task with no `dueDate` is in `to-plan`

- [ ] **PROJ-006B**: Each lane is a `useDroppable` container. Tasks within a lane are `useSortable`. Use the same sensor config as PROJ-004B. Cross-lane drop changes task `dueDate` (moves to Monday of current week for `this-week`, clears `dueDate` for `to-plan`, sets `status: 'done'` for `cleared`).
- [ ] **[TEST] PROJ-006B**: Dropping task into `this-week` lane sets `dueDate` to Monday of current week; dropping into `cleared` sets status to done

- [ ] **PROJ-006C**: **WCAG 2.5.7 single-pointer alternative**: "Move to lane" button on each task row (visible in `⋯` menu): "Move to → This Week", "Move to → Later", "Move to → Cleared". These call the same mutation as the drag handler.
- [ ] **[TEST] PROJ-006C**: "Move to → Later" button moves task to Later lane without dragging

- [ ] **PROJ-006D**: "Add task to this week" inline creation at the bottom of the `this-week` lane:
  - Press Enter in the input to create a task with `dueDate = today` via `useCreateTask()` mutation
  - Escape clears the input without creating
- [ ] **[TEST] PROJ-006D**: Enter creates task with correct `dueDate`; Escape clears input; new task appears optimistically in lane

- [ ] **PROJ-006E**: Lane drop indicator — same animated insertion line as PROJ-004D.
- [ ] **PROJ-006F**: Empty lane state: each empty lane shows a muted placeholder "No tasks".

### Definition of Done
- Four lanes with correct task assignment logic
- Cross-lane drag updates `dueDate`/`status` optimistically
- WCAG 2.5.7 "Move to lane" button alternative
- Inline task creation at bottom of "This Week" lane
- Drop indicator animation; empty lane states

---

## 📊 Task PROJ-007: Workload View
**Priority:** 🟠 Medium | **Est. Effort:** 1.5 hours | **Depends On:** PROJ-000, PROJ-001

### Related Files
`src/components/projects/WorkloadView.tsx`

> **Why dedicated task:** Workload is recharts-based (no dnd-kit), has its own data aggregation logic (tasks per assignee per day), and its own interactive pattern (click bar → filter task list). Different enough from My Week to warrant isolation.

### Subtasks

- [ ] **PROJ-007A**: Aggregate workload data:
  ```ts
  // For each team member, for each day in the next 14 days:
  type WorkloadEntry = {
    memberId: string
    memberName: string
    date: string       // ISO date
    taskCount: number
    overCapacity: boolean  // taskCount > member.dailyCapacity (default: 3)
  }
  ```
  Use `useMemo` to compute this from task data; recompute only when tasks or date range changes.
- [ ] **[TEST] PROJ-007A**: Member with 4 tasks on Tuesday has `overCapacity: true`; total task count matches raw data

- [ ] **PROJ-007B**: Render as recharts `BarChart` with `layout="vertical"` (members on Y axis, task count on X):
  - Each bar represents a member's total workload for the week
  - `<Bar dataKey="taskCount">` with `<Cell fill>` that conditionally applies red for `overCapacity`
  - `<Tooltip>` shows member name, task count, capacity
  - `<ReferenceLine x={defaultCapacity}` shows capacity limit as dashed vertical line
- [ ] **[TEST] PROJ-007B**: Over-capacity bars render in red; reference line at capacity value; tooltip shows on hover

- [ ] **PROJ-007C**: Timeline granularity toggle: "Week" / "2 Weeks" / "Month". Changes the date range for aggregation. Managed in component `useState`.
- [ ] **[TEST] PROJ-007C**: Switching to "Month" aggregates data across 30 days; bar heights change accordingly

- [ ] **PROJ-007D**: Click interaction: clicking a bar filters the task list below the chart to show only that member's tasks. Task list uses TanStack Virtual (reuse `useVirtualizer` pattern). "Clear filter" button appears above task list when active.
- [ ] **[TEST] PROJ-007D**: Clicking member bar shows only their tasks; "Clear filter" resets to all tasks

### Definition of Done
- Workload data aggregated with `useMemo`
- recharts `BarChart` with capacity reference line; over-capacity bars in red
- Granularity toggle (Week/2 Weeks/Month)
- Click-to-filter with virtualized task list below

---

## 📄 Task PROJ-008: Project Detail Page & Header
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** PROJ-000, PROJ-001

### Related Files
`src/pages/ProjectDetailPage.tsx` · `src/components/projects/ProjectHeader.tsx` · `src/components/projects/ProjectTabNav.tsx`

### Subtasks

- [ ] **PROJ-008A**: Create `ProjectDetailPage`:
  - Route: `/projects/:projectId` (configured in PROJ-002A)
  - Consumes `useProject(projectId)` from TanStack Query
  - Loading state: skeleton layout matching header + tabs + content
  - Error state: "Project not found" with back navigation
- [ ] **[TEST] PROJ-008A**: Loading renders skeleton; 404 response renders error state; back button navigates to `/projects`

- [ ] **PROJ-008B**: Build `ProjectHeader`:
  - Project name: click-to-edit via `useForm({ defaultValues: { name: project.name } })`
  - On blur or Enter: submit → call `useUpdateProject({ name })` mutation optimistically
  - On Escape: `reset({ name: project.name })` — cancels edit, restores original
  - Status dropdown (shadcn Select): changes `status` optimistically on select
  - Priority badge (shadcn Badge + Popover): same pattern as status
  - Progress bar (read-only, computed from task completion %)
  - Member avatars (stack, max 5, "+N more" overflow)
  - Due date (shadcn DatePicker): updates `dueDate` optimistically
- [ ] **[TEST] PROJ-008B**: Name field saves on Enter; Escape restores original value; status change calls mutation; progress bar reflects task count

- [ ] **PROJ-008C**: Build `ProjectTabNav` — five tabs: Tasks · Timeline · Files · Notes · Activity:
  - Active tab stored in URL search param `?tab=tasks` (not component state — deep-linkable)
  - Active underline indicator uses `<motion.div layoutId="tab-indicator">` for smooth slide
  - Each tab: `aria-selected`, `role="tab"`, `tabIndex={isActive ? 0 : -1}`
  - Keyboard navigation: ArrowLeft/ArrowRight moves focus between tabs
- [ ] **[TEST] PROJ-008C**: Tab URL param updates on click; `aria-selected` reflects active tab; ArrowRight moves focus to next tab; active indicator slides between tabs

- [ ] **PROJ-008D**: Tab content routing: Tasks → `ProjectTaskList` (PROJ-009); Timeline → `ProjectTimelineView` (PROJ-005); Files → placeholder; Notes → shadcn Textarea (saved with debounced mutation); Activity → list of timestamped events.
- [ ] **[TEST] PROJ-008D**: Switching to "Notes" tab renders textarea; typing saves after 1s debounce; Activity tab renders event list

### Definition of Done
- Loading skeleton, error state, and happy path all handled
- Inline project name editing with Escape-to-cancel
- Status, priority, due date all editable with optimistic mutations
- Tab navigation: URL search params, animated indicator, keyboard nav
- All tab panels wired to content components

### Anti-Patterns
- ❌ Tab state in Zustand or component `useState` — not deep-linkable; use URL search params
- ❌ `onKeyDown: e.key === 'Enter' && form.submit()` on the name input — submit is already handled by `react-hook-form`'s `handleSubmit`; double-submits on Enter
- ❌ Saving on every keystroke — debounce notes save to 1s; use `useCallback` with `useMemo`-memoized debounce

---

## ✅ Task PROJ-009: Project Task List & Inline Creation
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** PROJ-008

### Related Files
`src/components/projects/ProjectTaskList.tsx` · `src/components/projects/TaskRow.tsx` · `src/components/projects/TaskSection.tsx`

> **Why dedicated task:** Separated from `TaskDetailDrawer` (PROJ-010) because the list has its own complexity: sections, inline creation, virtualization, and row-level drag-to-reorder. These are independent of the drawer's detail tabs and form state.

### Subtasks

- [ ] **PROJ-009A**: Build `ProjectTaskList` with sections:
  - Render `TaskSection` components (collapsible), each with `TaskRow` children
  - "Add section" button at bottom
  - Section header: editable name (same inline edit pattern as PROJ-008B); collapse toggles `expandedSectionIds` in component state
  - No virtualization at the section level; virtualize only within a section if it exceeds 50 tasks
- [ ] **[TEST] PROJ-009A**: Sections render with correct tasks; collapsing section hides task rows; section name editable

- [ ] **PROJ-009B**: Virtualize large sections with `useVirtualizer`:
  - Apply only when `section.tasks.length > 50`
  - `estimateSize: () => 44` (fixed row height)
  - If `section.tasks.length <= 50`, render directly without virtualizer (simpler, avoids overhead)
- [ ] **[TEST] PROJ-009B**: Section with 60 tasks renders ≤25 DOM rows; section with 30 tasks renders all 30 directly

- [ ] **PROJ-009C**: Build `TaskRow`:
  - Columns: checkbox (complete), title (inline-editable), assignee avatar, priority badge, due date, `⋯` menu
  - Checkbox toggles `status: 'done'` optimistically; strikes through title with CSS `text-decoration: line-through`
  - Clicking title → open `TaskDetailDrawer` via `useTaskDrawer().open(task.id)` (no inline editing on title — edit happens in drawer)
  - Row hover: shows drag handle (left edge), assign button, due date picker
  - `aria-label={task.title}` on row; `role="row"`
- [ ] **[TEST] PROJ-009C**: Checkbox toggles completion optimistically; completed task has strikethrough; clicking title opens drawer; hover reveals action buttons

- [ ] **PROJ-009D**: Within-section drag-to-reorder using `useSortable` + `DragOverlay`. Reordering updates `order` field optimistically.
  - Use `activationConstraint: { distance: 5 }` on PointerSensor (consistent with PROJ-004B)
  - The drag handle (left edge icon) is the `attributes` target, not the full row
- [ ] **[TEST] PROJ-009D**: Dragging task row reorders within section; `order` mutation called with new position; drag handle is the activation target

- [ ] **PROJ-009E**: Inline task creation: "+ Add task" button at the bottom of each section opens an inline `<input>`:
  - Enter: create task with title + default `sectionId` via `useCreateTask()` → stays in edit mode for next task
  - Escape: cancel and close input
  - New task appears optimistically at bottom of section
- [ ] **[TEST] PROJ-009E**: Enter creates task and keeps input open; Escape closes; optimistic task appears; second Enter creates another task

### Definition of Done
- Sections with collapsible groups; inline section name editing
- TanStack Virtual for sections >50 tasks; direct render for ≤50
- Task rows with checkbox, hover actions, correct ARIA
- Within-section drag-to-reorder with drag handle
- Inline "+ Add task" creation; stays open for multiple adds

---

## 🗂️ Task PROJ-010: Task Detail Drawer
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** PROJ-009, PROJ-001

### Related Files
`src/components/projects/TaskDetailDrawer.tsx` · `src/components/projects/TaskChecklist.tsx` · `src/components/projects/TaskComments.tsx`

> **Why dedicated task:** The drawer has four distinct panels (Details, Checklist, Comments, Activity) and its own complex form state, independent of the list. Bundling it with PROJ-009 would create a 5-hour monolith.

### Subtasks

- [ ] **PROJ-010A**: Build `TaskDetailDrawer`:
  - Triggered by `useTaskDrawer().taskId !== null`
  - Renders as a sliding panel from the right: `<motion.aside initial={{ x: '100%' }} animate={{ x: 0 }} exit={{ x: '100%' }} transition={{ type: 'spring', stiffness: 300, damping: 35 }}`
  - Wrapped in `AnimatePresence` for exit animation
  - `role="complementary"` + `aria-label="Task details"` on the aside
  - Close button (`X`) + Escape key: both call `useTaskDrawer().close()`
  - Focus trap: when open, Tab cycles within the drawer only (use `focus-trap-react` or manual implementation)
- [ ] **[TEST] PROJ-010A**: Opening drawer animates from right; Escape closes; focus stays within drawer when tabbing; `aria-label` present

- [ ] **PROJ-010B**: Drawer header: editable task title (same `useForm` + Escape-to-cancel pattern), status dropdown, priority badge, assignee select (avatar + name), due date picker.
- [ ] **[TEST] PROJ-010B**: Title saves on Enter/blur; Escape reverts; status/assignee/priority changes call optimistic mutations

- [ ] **PROJ-010C**: Drawer tabs: Details · Checklist · Comments · Activity. Same tab pattern as PROJ-008C (but use component `useState` for tab, not URL param — drawer is an overlay, not a navigable page).
- [ ] **[TEST] PROJ-010C**: Switching tabs renders correct panel; keyboard ArrowLeft/Right moves between tabs

- [ ] **PROJ-010D**: **Checklist tab** (`TaskChecklist`):
  - List of checklist items: each has checkbox + editable text + delete button
  - "+ Add item" at bottom (same inline input pattern as PROJ-009E)
  - Completion percentage shown in tab label: "Checklist (3/5)"
  - Reordering via dnd-kit (within-list sort, same pattern as PROJ-009D)
  - All mutations: `onMutate → onError → onSettled`
- [ ] **[TEST] PROJ-010D**: Checking item updates percentage in tab label; reordering items calls order mutation; deleting item removes it optimistically

- [ ] **PROJ-010E**: **Comments tab** (`TaskComments`):
  - List of comments with avatar, name, timestamp, content
  - `<TextareaAutosize>` input at bottom (consistent with chat input); `cacheMeasurements={true}`
  - Submit on `Cmd+Enter`; `Enter` inserts newline
  - Optimistic: new comment appears immediately with `status: 'sending'` indicator
  - Error: comment shows red outline + "Retry" link
- [ ] **[TEST] PROJ-010E**: Cmd+Enter submits comment; new comment appears instantly (optimistic); error shows retry; Enter adds newline

- [ ] **PROJ-010F**: **Description field** (in Details tab): `<TextareaAutosize>` with `minRows={3}`. Auto-saves on blur with 500ms debounce. "Last saved X minutes ago" timestamp below.
- [ ] **[TEST] PROJ-010F**: Editing description and blurring calls save mutation after 500ms; timestamp updates after save

### Definition of Done
- Drawer slides in/out with spring; exit animation via `AnimatePresence`
- Focus trap active when drawer is open
- Header: editable title, status, priority, assignee, due date
- Four tabs: Details, Checklist, Comments, Activity
- Checklist: completion %, dnd-kit reorder, inline add
- Comments: `Cmd+Enter` submit, optimistic with retry on error
- Description: auto-save on blur with debounce

### Anti-Patterns
- ❌ Tab state in URL params for a drawer — URL should not reflect overlay state; use component state
- ❌ `TextareaAutosize` without `cacheMeasurements` — layout thrashing on every keystroke
- ❌ Missing focus trap — keyboard users can tab outside an open drawer and lose context
- ❌ Saving description on every keystroke — debounce to 500ms; `onChange` should only update local state

---

## 📚 Task PROJ-011: Project Template Library
**Priority:** 🟢 Low | **Est. Effort:** 1.5 hours | **Depends On:** PROJ-000, PROJ-002

### Related Files
`src/components/projects/ProjectTemplateLibrary.tsx`

### Subtasks

- [ ] **PROJ-011A**: Build template grid:
  - Cards: template icon, name, description, task count badge
  - Templates: "Product Launch" (12 tasks), "Home Renovation" (8 tasks), "Marketing Campaign" (10 tasks), "Software Release" (15 tasks), "Event Planning" (9 tasks), "Blank" (0 tasks)
  - Grid layout: 3 cols desktop, 2 cols tablet, 1 col mobile
  - Hover: card lifts with `boxShadow` transition (Quiet tier — no Motion needed, pure CSS)
- [ ] **[TEST] PROJ-011A**: Six template cards render; blank template has no task count badge; grid is responsive

- [ ] **PROJ-011B**: Clicking a template opens the "New Project" dialog (from PROJ-002E) with:
  - Name pre-filled as template name (user can change)
  - Status set to "active"
  - `templateId` passed to `useCreateProject()` so the backend seeds the tasks
  - Optimistic: project appears in list immediately; tasks load asynchronously
- [ ] **[TEST] PROJ-011B**: Clicking "Product Launch" opens dialog with name pre-filled; submit calls `useCreateProject({ templateId: 'product-launch' })`

- [ ] **PROJ-011C**: Template library is accessible from two entry points:
  1. "New Project" dialog: "Start from template" link (below the blank form)
  2. Projects list empty state: "Choose a template" primary CTA
- [ ] **[TEST] PROJ-011C**: Both entry points open the template library in the same Dialog; selecting a template then navigates to the new project form

### Definition of Done
- Six template cards in responsive grid
- Clicking template pre-fills "New Project" dialog
- Accessible from both dialog link and empty state CTA
- `useCreateProject` receives `templateId` for server-side task seeding

---

## 📊 Dependency Graph

```
PROJ-000 (Mock Data + Query Keys + Mutations)
     │
PROJ-001 (Zustand projectSlice)
     │
PROJ-002 (Page Layout + Route + View Switcher + Filter Bar)
     │
     ├─────────────┬──────────────┬──────────────┬─────────────┐
     │             │              │              │             │
PROJ-003       PROJ-004       PROJ-005       PROJ-006     PROJ-007
(List View)   (Kanban)      (Timeline)    (My Week)    (Workload)
                                               │
                                          PROJ-008
                                        (Detail Page)
                                               │
                                    ┌──────────┴──────────┐
                                    │                     │
                               PROJ-009              PROJ-010
                             (Task List)           (Task Drawer)

PROJ-011 (Templates) ──→ PROJ-002 (integrates into New Project dialog)
```

---

## 🏁 Projects Module Completion Checklist

**Data & State:**
- [ ] Mock factories for projects, tasks, sections, templates
- [ ] MSW handlers for all CRUD endpoints with query param filtering
- [ ] `projectKeys` factory fully typed
- [ ] All mutations: `onMutate → onError rollback → onSettled invalidate`
- [ ] Zustand `projectSlice`: all state, actions, atomic selectors
- [ ] `persist` saves only `activeView` and `sort`

**Page & Navigation:**
- [ ] Routes configured with loader prefetch
- [ ] View switcher with animated `layoutId` indicator
- [ ] Filter bar with `useTransition` — no `setTimeout` debounce
- [ ] "New Project" dialog with Zod validation

**List View:**
- [ ] TanStack Table (8 typed columns) + TanStack Virtual
- [ ] Server-side filtering; client-side sort
- [ ] Hover prefetch with 200ms debounce and cancel
- [ ] Inline status editing via Popover
- [ ] Bulk action bar with `AnimatePresence`

**Kanban:**
- [ ] `PointerSensor` with `activationConstraint: { distance: 5 }` + `KeyboardSensor`
- [ ] Custom collision detection (`pointerWithin` + `closestCenter` fallback)
- [ ] `DragOverlay` clone with glow; original at 0.4 opacity
- [ ] Drop indicator animation
- [ ] WCAG 2.5.7: "Move to…" button alternative (single-pointer, not just keyboard)
- [ ] No focusable children inside cards

**Timeline:**
- [ ] SVAR Gantt with dark theme CSS override
- [ ] Data transformation handles missing dates
- [ ] Zoom controls (Day/Week/Month/Quarter)
- [ ] Drag-to-reschedule with optimistic mutation
- [ ] CSS bar entrance animation with stagger

**My Week:**
- [ ] Four lanes with date-based task assignment logic
- [ ] Cross-lane drag updates `dueDate`/`status` optimistically
- [ ] WCAG 2.5.7: "Move to lane" button alternative
- [ ] Inline task creation in "This Week" lane

**Workload:**
- [ ] recharts `BarChart` with capacity reference line; over-capacity in red
- [ ] Granularity toggle (Week/2 Weeks/Month)
- [ ] Click bar → filter task list (virtualized)

**Project Detail:**
- [ ] Loading skeleton + error state
- [ ] Inline name editing with Escape-to-cancel
- [ ] Tab nav: URL search params, animated indicator, keyboard nav
- [ ] All header fields editable with optimistic mutations

**Task List:**
- [ ] Sections with collapsible groups; editable section names
- [ ] TanStack Virtual for sections >50 tasks
- [ ] Task rows with checkbox, hover actions, ARIA
- [ ] Within-section drag-to-reorder (drag handle activation)
- [ ] Inline "+ Add task" stays open for multiple adds

**Task Drawer:**
- [ ] Spring slide-in/out; exit via `AnimatePresence`
- [ ] Focus trap when open
- [ ] Editable header (title, status, priority, assignee, due date)
- [ ] Four tabs: Details, Checklist, Comments, Activity
- [ ] Checklist with completion %, reorder, inline add
- [ ] Comments: `Cmd+Enter` submit, optimistic with retry
- [ ] Description: debounced auto-save

**Templates:**
- [ ] Six template cards in responsive grid
- [ ] Pre-fills New Project dialog; passes `templateId` to mutation
- [ ] Accessible from dialog link and empty state CTA

**Testing (global):**
- [ ] All custom hooks: `renderHook` + `createWrapper`
- [ ] All network calls: MSW handlers
- [ ] Zustand store reset in `beforeEach`
- [ ] Each implementation subtask has a co-located `[TEST]` subtask
- [ ] `pnpm test` passes for entire projects domain