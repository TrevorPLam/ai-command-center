Below is the fully refreshed and expanded Projects task list. It retains every task from the previous version, adds all the new tasks identified from the Karbon research, and maintains the exact formatting conventions you established (status indicators, priority levels, subtask structure, Definition of Done, Acceptance Criteria, related files, etc.).

---

# 04-Projects — Personal AI Command Center Frontend (Enhanced v4)

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.
> **Source Research**: Karbon accounting practice management software — feature analysis conducted April 2026. Karbon combines email, tasks, workflows, Kanban boards, My Week personal planning, automators, AI agents, time/budget tracking, document management, and Practice Intelligence into one platform.

---

## 🧱 Cross-Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **PROJ-C01** | State Selectors | All Zustand subscriptions use selector functions: `useProjectStore(s => s.activeView)` — never `useProjectStore()`. Full-store subscriptions cause re-renders on every state change. |
| **PROJ-C02** | Optimistic Mutations | All mutations: `onMutate` → snapshot → `onError` rollback → `onSettled` invalidate. Use `onSettled`, not `onSuccess` (fires on both success and error). |
| **PROJ-C03** | Filter Performance | All list/Kanban filters use `useTransition`. No `setTimeout` debounce. `isPending` state drives visual loading indicator. |
| **PROJ-C04** | WCAG 2.5.7 (AA) | **Keyboard shortcuts alone do not satisfy WCAG 2.5.7.** The criterion requires a single-pointer (click/tap) alternative — i.e., a visible button. Keyboard navigation (`KeyboardSensor`) is a bonus on top of the required button alternative. Both Kanban and My Week MUST have "Move to…" buttons on draggable items. |
| **PROJ-C05** | Virtualization Stack | TanStack Table + TanStack Virtual for all tabular data. TanStack Virtual (`useVirtualizer`) for task lists and Triage stream. No `react-base-table`, no `react-window` — they are outside the existing TanStack ecosystem already used in this codebase. |
| **PROJ-C06** | dnd-kit Sensors | Use the shared `useDndSensors()` hook from `src/shared/dnd`. Never configure sensors inline. See C-14 in 01-Foundations.md. |
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
| Triage item entry | **Alive** | Slide in from top + opacity, staggered by 0.03s |
| Quick Peek overlay | **Alive** | Scale `0.95→1` + opacity, spring stiffness 400 damping 25 |
| Automation rule triggered indicator | **Alive** | Brief blue pulse on affected work item card |
| Comment @mention dropdown | **Quiet** | Opacity fade 100ms |

---

## 🗃️ Task PROJ-000: Mock Data Layer
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** FND-004 (Testing), FND-006 (TanStack Query)

### Related Files
`src/mocks/factories/projects.ts` · `src/mocks/factories/triage.ts` · `src/mocks/handlers/projects.ts` · `src/mocks/handlers/triage.ts` · `src/mocks/handlers/automations.ts` · `src/queries/projects.ts`

### Subtasks

- [ ] **PROJ-000A**: Create `src/mocks/factories/projects.ts`:
  - `createMockProject(overrides?)`: realistic fields — `id`, `name`, `status` (`'planned' | 'active' | 'on-hold' | 'in-review' | 'completed' | 'archived'`), `priority` (`'low' | 'medium' | 'high' | 'urgent'`), `startDate`, `dueDate`, `progress` (0–100), `budgetAmount`, `budgetUsed`, `ownerId`, `tags[]`, `memberIds[]`, `workType`, `filingDeadlineId`, `isRecurring`, `recurringScheduleId`, `templateId`
  - `createMockTask(projectId, overrides?)`: `id`, `title`, `description`, `status`, `priority`, `assigneeId`, `dueDate`, `sectionId`, `order`, `taskType` (`'billable' | 'non-billable'`), `estimatedHours`, `subtasks[]`, `isClientTask`, `clientReminderCount`, `conditionalActive`, `toolCalls?`
  - `createMockSection(projectId, overrides?)`: `id`, `name`, `order`, `collapsed`, `conditionalActive`, `automatorRules[]`
  - `createMockProjectTemplate(overrides?)`: named presets — "Product Launch" (12 tasks), "Home Renovation" (8 tasks), "Marketing Campaign" (10 tasks), "Software Release" (15 tasks), "Event Planning" (9 tasks), "Blank" (0 tasks)
- [ ] **[TEST] PROJ-000A**: Factories produce valid typed data; overrides merge correctly; IDs are unique across calls (use `crypto.randomUUID()`)

- [ ] **PROJ-000B**: Create `src/mocks/factories/triage.ts`:
  - `createMockTriageItem(overrides?)`: `id`, `type` (`'email' | 'notification' | 'work_assignment' | 'client_task' | 'comment' | 'decision'`), `subject`, `preview`, `sender`, `timestamp`, `isRead`, `isCleared`, `colorCode` (grey/pink/standard), `assignedTo`, `timelineIds[]`, `plannedWeek` (`'this-week' | 'next-week' | 'later' | null`)
- [ ] **[TEST] PROJ-000B**: Triage items have correct color codes by type; `isCleared` items filter correctly

- [ ] **PROJ-000C**: Create `src/mocks/handlers/projects.ts` with MSW handlers:
  - `GET /api/projects` → paginated project list with optional `?status=&priority=&search=&workType=&assignee=`
  - `GET /api/projects/:id` → single project detail with tasks, sections, budget info
  - `GET /api/projects/:id/tasks` → tasks grouped by section
  - `POST /api/projects` → create project; echoes back with generated ID; supports `templateId` for seeding tasks
  - `PATCH /api/projects/:id` → update project fields (partial merge)
  - `DELETE /api/projects/:id` → soft-delete (sets `status: 'archived'`)
  - `POST /api/projects/:id/tasks` → create task within a section
  - `PATCH /api/tasks/:id` → update task (status, assignee, order, section, conditionalActive)
  - `PATCH /api/tasks/:id/reorder` → update `order` field for drag-to-reorder
  - `POST /api/projects/bulk` → create work items for up to 100 contacts from a template
  - `GET /api/templates` → template list
  - `POST /api/projects/:id/sections` → add section
  - `PATCH /api/sections/:id` → update section (name, collapsed, conditionalActive)
- [ ] **[TEST] PROJ-000C**: Each handler returns correct shape; `PATCH` merges partial updates; `DELETE` returns 204; bulk creation creates N projects

- [ ] **PROJ-000D**: Create `src/mocks/handlers/triage.ts` with MSW handlers:
  - `GET /api/triage` → paginated triage stream with optional `?type=&isRead=&isCleared=`
  - `PATCH /api/triage/:id` → mark read/cleared, update planned week, assign
  - `POST /api/triage/:id/clear` → move to cleared items
  - `GET /api/triage/delegated` → list delegated triage access grants
- [ ] **[TEST] PROJ-000D**: Triage stream returns items in reverse chronological order; clearing an item sets `isCleared: true`

- [ ] **PROJ-000E**: Create `src/mocks/handlers/automations.ts` with MSW handlers:
  - `GET /api/automations/global` → list of global automator rules
  - `PATCH /api/automations/global/:id` → toggle/update global automator
  - `GET /api/automations/tasklist/:projectId` → tasklist automators for a project's sections
  - `POST /api/automations/tasklist` → add tasklist automator (trigger → condition → action)
  - `PATCH /api/automations/tasklist/:id` → update automator rule
  - `DELETE /api/automations/tasklist/:id` → remove automator
- [ ] **[TEST] PROJ-000E**: Tasklist automator creation returns rule with generated ID; rules are scoped to sections

- [ ] **PROJ-000F**: Create `src/queries/projects.ts` with Query Key Factory:
  ```ts
  export const projectKeys = {
    all: ['projects'] as const,
    lists: () => [...projectKeys.all, 'list'] as const,
    list: (filters: ProjectFilters) => [...projectKeys.lists(), filters] as const,
    details: () => [...projectKeys.all, 'detail'] as const,
    detail: (id: string) => [...projectKeys.details(), id] as const,
    tasks: (projectId: string) => [...projectKeys.detail(projectId), 'tasks'] as const,
    templates: () => [...projectKeys.all, 'templates'] as const,
    triage: () => [...projectKeys.all, 'triage'] as const,
    automations: () => [...projectKeys.all, 'automations'] as const,
    automationsByProject: (projectId: string) => [...projectKeys.automations(), projectId] as const,
    savedViews: () => [...projectKeys.all, 'saved-views'] as const,
    recurringSchedules: () => [...projectKeys.all, 'recurring-schedules'] as const,
  }
  ```
- [ ] **[TEST] PROJ-000F**: Key factory produces structurally distinct arrays per entity; `list({ status: 'active' })` differs from `list({ status: 'completed' })`

- [ ] **PROJ-000G**: Define `projectsQueryOptions(filters)`, `projectDetailQueryOptions(id)`, and `triageQueryOptions(filters)` with:
  - `staleTime: 30_000` (30s — projects change less frequently than chat messages)
  - `gcTime: 5 * 60 * 1000` (5 min)
- [ ] **PROJ-000H**: Define mutation hooks: `useCreateProject()`, `useUpdateProject()`, `useDeleteProject()`, `useCreateTask()`, `useUpdateTask()`, `useReorderTask()`, `useClearTriageItem()`, `useCreateAutomationRule()`, `useUpdateAutomationRule()`, `useDeleteAutomationRule()` — all implement full `onMutate → snapshot → onError → onSettled` pattern
- [ ] **[TEST] PROJ-000H**: `useUpdateProject` optimistically mutates cache; rollback on error; `onSettled` invalidates `projectKeys.detail(id)`

### Definition of Done
- Factories produce realistic typed data with `crypto.randomUUID()` IDs for projects, tasks, sections, triage items, and automator rules
- MSW handlers cover all CRUD endpoints with query param support for projects, triage, and automations
- `projectKeys` factory fully typed and extended with triage, automations, saved views, and recurring schedules keys
- All mutation hooks implement optimistic pattern with rollback
- MSW handlers support bulk work creation (up to 100 contacts from template)
- `createWrapper()` from CHAT spec reused (or extended) for project tests

---

## 🔧 Task PROJ-001: Project State — Zustand `projectSlice`
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** FND-005 (Zustand)

### Related Files
`src/stores/slices/projectSlice.ts` · `src/stores/slices/triageSlice.ts` · `src/stores/index.ts`

### Subtasks

- [ ] **PROJ-001A**: Define `projectSlice` state shape:
  ```ts
  type ProjectState = {
    activeView: 'list' | 'kanban' | 'timeline' | 'my-week' | 'workload'
    filters: {
      status: ProjectStatus[]
      priority: Priority[]
      tags: string[]
      assignee: string[]
      workType: string[]
      dueDateRange: { from: Date | null; to: Date | null }
      search: string
    }
    sort: { field: 'name' | 'status' | 'dueDate' | 'priority' | 'progress' | 'budgetUsed'; order: 'asc' | 'desc' }
    selectedProjectId: string | null
    expandedTaskIds: string[]         // `Set` is not serializable; store as array and derive `Set` via `useMemo` where needed
    expandedSectionIds: Set<string>
    taskDrawerTaskId: string | null
    quickPeekProjectId: string | null
    colleagueWeekUserId: string | null
    selectedTaskIds: string[]         // `Set` is not serializable; store as array and derive `Set` via `useMemo` where needed
    bulkActionBarVisible: boolean
  }
  ```
- [ ] **[TEST] PROJ-001A**: Initial state has correct defaults; state shape matches TypeScript type

- [ ] **PROJ-001B**: Define actions: `setActiveView`, `setFilter`, `clearFilters`, `setSort`, `setSelectedProject`, `toggleTaskExpanded`, `toggleSectionExpanded`, `openTaskDrawer`, `closeTaskDrawer`, `openQuickPeek`, `closeQuickPeek`, `setColleagueWeekUser`, `toggleTaskSelected`, `selectAllTasks`, `clearTaskSelection`, `showBulkActionBar`, `hideBulkActionBar`
- [ ] **[TEST] PROJ-001B**: Each action produces correct next state; `toggleTaskExpanded` toggles correctly; `selectAllTasks` selects all visible task IDs

- [ ] **PROJ-001C**: Export atomic selector hooks — **never export the full store**:
  ```ts
  export const useActiveView = () => useProjectStore(s => s.activeView)
  export const useProjectFilters = () => useProjectStore(s => s.filters)
  export const useProjectSort = () => useProjectStore(s => s.sort)
  export const useTaskDrawer = () => useProjectStore(s => ({ taskId: s.taskDrawerTaskId, open: s.openTaskDrawer, close: s.closeTaskDrawer }))
  export const useQuickPeek = () => useProjectStore(s => ({ projectId: s.quickPeekProjectId, open: s.openQuickPeek, close: s.closeQuickPeek }))
  export const useColleagueWeek = () => useProjectStore(s => ({ userId: s.colleagueWeekUserId, setUser: s.setColleagueWeekUser }))
  export const useBulkSelection = () => useProjectStore(s => ({ selectedIds: s.selectedTaskIds, toggle: s.toggleTaskSelected, selectAll: s.selectAllTasks, clear: s.clearTaskSelection }))
  ```
- [ ] **[TEST] PROJ-001C**: Changing `filters` does not trigger re-render in component subscribed only to `activeView`

- [ ] **PROJ-001D**: Define `triageSlice` state shape:
  ```ts
  type TriageState = {
    activeFilter: 'all' | 'unread' | 'cleared' | 'assigned-to-me' | 'decisions'
    selectedItemId: string | null
    delegatedUserId: string | null
    isDelegatedView: boolean
  }
  ```
  Actions: `setFilter`, `selectItem`, `clearSelection`, `setDelegatedView`, `exitDelegatedView`
- [ ] **[TEST] PROJ-001D**: Triage state independent from project state; delegated view toggle works

- [ ] **PROJ-001E**: Add Zustand `devtools` and `persist` (for `activeView`, `sort`, and `savedViews` only — do not persist filters, expanded items, selections, or triage state):
  ```ts
  persist(devtools(projectSlice), {
    name: 'project-ui',
    partialize: (state) => ({ activeView: state.activeView, sort: state.sort }),
  })
  ```
- [ ] **[TEST] PROJ-001E**: `activeView` survives store re-initialization; filters do not persist

### Definition of Done
- `projectSlice` covers all views, filters, sort, drawer/quick-peek state, colleague week, bulk selection
- `triageSlice` covers triage filters, selection, and delegated view
- All selectors are atomic; no component subscribes to full store
- `persist` saves only view and sort preferences

### Anti-Patterns
- ❌ `useProjectStore()` without selector — subscribes to entire store; re-renders on every action
- ❌ Persisting filter state — filters should be ephemeral; persisting them causes stale filter state across sessions
- ❌ `Set` in persisted state — `JSON.stringify` cannot serialize a `Set`; convert to array for persistence if needed

---

## 🗂️ Task PROJ-002: Projects Page Layout, Route & View Switcher
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** PROJ-000, PROJ-001, FND-007 (Router)

### Related Files
`src/pages/ProjectsPage.tsx` · `src/components/projects/ViewSwitcher.tsx` · `src/components/projects/ProjectFilterBar.tsx` · `src/router/routes.ts`

### Subtasks

- [ ] **PROJ-002A**: Configure routes in `src/router/routes.ts`:
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
- [ ] **[TEST] PROJ-002A**: Navigating to `/projects` prefetches project list; loader uses `ensureQueryData` (non-blocking)

- [ ] **PROJ-002B**: Build `ProjectsPage` layout:
  - Top bar: `ViewSwitcher` (left), "New Project" button + "Bulk Create" button (right), `ProjectFilterBar` (below top bar, collapsible on mobile)
  - Content area: renders the active view component based on `useActiveView()`
  - Page transition: `<motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }}>` on mount
- [ ] **[TEST] PROJ-002B**: Switching `activeView` renders correct view component; filter bar collapse works on mobile

- [ ] **PROJ-002C**: Build `ViewSwitcher` — five icon-buttons: List, Kanban, Timeline, My Week, Workload:
  - Active state: `bg-white/10` background + active indicator `<motion.div layoutId="view-indicator">` (slides under active icon)
  - Each button: `aria-label="<ViewName> view"` + `aria-pressed={isActive}`
  - On click: `setActiveView(view)` from store
- [ ] **[TEST] PROJ-002C**: Clicking each button updates store `activeView`; `aria-pressed` reflects active state; layout animation indicator present

- [ ] **PROJ-002D**: Build `ProjectFilterBar`:
  - Status multi-select (shadcn Popover + Checkbox)
  - Priority multi-select (same pattern)
  - Assignee multi-select (team member list)
  - Work type multi-select (configurable types)
  - Due date range picker (shadcn DateRangePicker)
  - Search input (debounced via `useTransition`)
  - "Clear filters" button (visible only when any filter is active)
  - "Save View As" button (triggers saved view dialog — PROJ-014)
  - Filter changes dispatch to `useProjectStore` actions; `useTransition` wraps store dispatch
- [ ] **[TEST] PROJ-002D**: Filter changes update store; `isPending` shows loading indicator; "Clear filters" resets all filters

- [ ] **PROJ-002E**: "New Project" button opens a shadcn `Dialog`:
  - Form with `react-hook-form` + Zod schema: name (required, 3–100 chars), status, priority, start/due dates, work type, budget amount, description (optional)
  - Link to template library ("Start from template" secondary link)
  - On submit: call `useCreateProject()` mutation → optimistically append to list cache → close dialog
- [ ] **[TEST] PROJ-002E**: Form validates name length; submit calls mutation; dialog closes on success; optimistic row appears immediately

- [ ] **PROJ-002F**: "Bulk Create" button opens dialog:
  - Select template, select contacts (multi-select, up to 100), confirm
  - Calls `POST /api/projects/bulk` with `{ templateId, contactIds }`
  - Progress indicator during creation
  - Success toast with count: "Created 47 work items"
- [ ] **[TEST] PROJ-002F**: Bulk creation calls correct endpoint; progress indicator shown; success toast appears

- [ ] **PROJ-002G**: Export button (cloud icon) in top bar:
  - Downloads current filtered view as CSV (projects) or Excel-format
  - Toast: "Export started — 142 rows"
- [ ] **[TEST] PROJ-002G**: Export triggers file download; CSV contains filtered data, not all data

### Definition of Done
- Routes defined with loader prefetch
- Page layout with view switcher (5 views), filter bar, new project button, bulk create, export
- View switcher with animated `layoutId` indicator; ARIA `aria-pressed`
- Filter bar uses `useTransition`; 6 filter dimensions
- "New Project" dialog with Zod validation and optimistic mutation
- "Bulk Create" dialog with template + contact selection
- Export button downloads CSV of filtered view

---

## 📋 Task PROJ-003: Project List View — TanStack Table + Virtual
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** PROJ-000, PROJ-001, PROJ-002

### Related Files
`src/components/projects/ProjectListView.tsx` · `src/components/projects/ProjectListColumns.tsx`

### Subtasks

- [ ] **PROJ-003A**: Define columns via `createColumnHelper<Project>()`:
  ```ts
  export const projectColumns = [
    columnHelper.display({ id: 'select', ... }),                    // Row checkbox (for bulk actions)
    columnHelper.accessor('name', { header: 'Project', ... }),      // Clickable name
    columnHelper.accessor('status', { header: 'Status', ... }),     // Status badge dropdown (inline edit)
    columnHelper.accessor('priority', { header: 'Priority', ... }), // Priority chip
    columnHelper.accessor('dueDate', { header: 'Due', ... }),       // Relative date
    columnHelper.accessor('progress', { header: 'Progress', ... }), // Mini progress bar (0–100%)
    columnHelper.accessor('budgetUsed', { header: 'Budget', ... }), // Budget used % with color coding
    columnHelper.accessor('memberIds', { header: 'Members', ... }), // Avatar stack (max 5 + overflow)
    columnHelper.display({ id: 'plannedWeek', ... }),               // My Week planned column (editable)
    columnHelper.display({ id: 'actions', ... }),                   // ⋯ kebab menu
  ]
  ```
- [ ] **[TEST] PROJ-003A**: All 10 columns render in correct order; column definitions are type-safe

- [ ] **PROJ-003B**: Implement `useReactTable` with:
  - `getCoreRowModel()`, `getSortedRowModel()`
  - Server-side filtering: pass `filters` from Zustand to `projectsQueryOptions`; do NOT use client-side `getFilteredRowModel` for server-driven filters
  - Client-side sort on already-fetched data
  - `columnVisibility` state: hide progress, budget, members columns on `<768px`
- [ ] **[TEST] PROJ-003B**: Clicking column header sorts; sort order toggles asc/desc; hidden columns not in DOM on mobile viewport

- [ ] **PROJ-003C**: Integrate `useVirtualizer` for rows:
  ```ts
  const virtualizer = useVirtualizer({
    count: rows.length,
    getScrollElement: () => tableContainerRef.current,
    estimateSize: () => 52,        // Fixed row height
    overscan: 10,
  })
  ```
  Render only `virtualizer.getVirtualItems()` inside `<tbody>`. Table container fills viewport.
- [ ] **[TEST] PROJ-003C**: At 200 mock projects, DOM contains ≤30 row elements; scroll does not add more DOM nodes

- [ ] **PROJ-003D**: Hover prefetch with cancel-on-leave:
  ```ts
  let prefetchTimer: ReturnType<typeof setTimeout>
  const handleMouseEnter = (id: string) => {
    prefetchTimer = setTimeout(() => queryClient.prefetchQuery(projectDetailQueryOptions(id)), 200)
  }
  const handleMouseLeave = () => clearTimeout(prefetchTimer)
  ```
- [ ] **[TEST] PROJ-003D**: Hovering row >200ms calls `prefetchQuery`; leaving before 200ms does not call it

- [ ] **PROJ-003E**: Inline status editing: clicking status badge opens a `Popover` with status options. Selecting calls `useUpdateProject()` mutation optimistically. `Escape` closes without saving.
- [ ] **[TEST] PROJ-003E**: Status popover opens on click; selection immediately updates badge; Escape closes without API call

- [ ] **PROJ-003F**: Planned Week column: clicking opens a popover with "This Week", "Next Week", "Later", "None". Selecting updates project's planned week via `useUpdateProject()`.
- [ ] **[TEST] PROJ-003F**: Planned week changes update store; colleague week view reflects change

- [ ] **PROJ-003G**: Bulk actions: when rows are selected (checkbox), a bulk action bar slides in (`AnimatePresence`): "Change Status", "Change Priority", "Assign to…", "Move to My Week…", "Delete". Bulk mutations call individual mutations with `Promise.allSettled` and report failures.
- [ ] **[TEST] PROJ-003G**: Selecting 3 rows shows bulk bar; "Delete" calls 3 delete mutations; deselecting hides bulk bar; partial failure toast lists failed items

### Definition of Done
- TanStack Table with 10 typed columns; sorting and server-side filtering
- TanStack Virtual: bounded DOM node count at any dataset size
- Hover prefetch with 200ms debounce and cancel
- Inline status editing via Popover; optimistic update
- Planned Week column with popover selector
- Bulk actions bar with `AnimatePresence`; partial failure handling

### Anti-Patterns
- ❌ `getFilteredRowModel()` for server-driven filters — double-filters and stales the display
- ❌ `position: relative` + `top` for virtual rows — use `transform: translateY`
- ❌ Prefetch without debounce — triggers on cursor pass-through; always add 200ms delay

---

## 📌 Task PROJ-004: Kanban View
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** PROJ-000, PROJ-001

### Related Files
`src/components/projects/ProjectKanbanView.tsx` · `src/components/projects/KanbanColumn.tsx` · `src/components/projects/KanbanCard.tsx`

### Subtasks

- [ ] **PROJ-004A**: Define Kanban columns: config-driven array (not hardcoded). Default columns: `Planned → Ready to Start → In Progress → In Review → Completed`. Columns map to project `status` values. Column headers show count badge and team member capacity when sorted by assignee.
- [ ] **[TEST] PROJ-004A**: Five columns render; column titles match status labels; empty columns show empty state placeholder; count badges are correct

- [ ] **PROJ-004B**: Install @dnd-kit/core:

  ```sh
  pnpm add @dnd-kit/core@6.3.1
  ```

  > "`@dnd-kit/core@6.3.1` was last updated December 2024. Development has moved to the newer `@dnd-kit/react` and `@dnd-kit/dom` packages. For the MVP, `@dnd-kit/core` meets all requirements. Schedule evaluation of `@dnd-kit/react` or `@atlaskit/pragmatic-drag-and-drop` as a POL-001 performance/debt review item."
- [ ] **PROJ-004C**: Configure `DndContext` sensors using the shared `useDndSensors()` hook from `src/shared/dnd`:
  ```ts
  import { useDndSensors } from '@/shared/dnd/useDndSensors';
  const sensors = useDndSensors();
  ```
  Collision detection: custom algorithm — `pointerWithin` first (cross-column), `closestCenter` fallback (within-column).
- [ ] **[TEST] PROJ-004B**: `PointerSensor` does not trigger drag on single click; `KeyboardSensor` activates on Space/Enter

- [ ] **PROJ-004C**: Each column wrapped in `<SortableContext items={columnCardIds}>`. Each card uses `useSortable`. Track `activeId` on `onDragStart`. Render `<DragOverlay>` with cloned card + glow. Original card at 0.4 opacity.
  > **⚠️ LayoutGroup Requirement:** Wrap the entire Kanban view in `<LayoutGroup id="projects-kanban">` to namespace all `layoutId` values used within it (e.g., view switcher indicator, card morph animations). `layoutId` is global across the site; without namespacing, multiple Kanban instances or other components using the same `layoutId` values will collide. See FND-013K for the full audit procedure.
- [ ] **[TEST] PROJ-004C**: During drag, original card at 0.4 opacity; overlay clone follows cursor with glow + slight scale + tilt

- [ ] **PROJ-004D**: Drop indicator: animated insertion line between cards (`scaleY: 0→1`, spring stiffness 400 damping 30, electric blue).
- [ ] **[TEST] PROJ-004D**: Drop indicator renders at correct position between cards; disappears on drop

- [ ] **PROJ-004E**: `onDragEnd` handler:
  1. Determine source/target column from `active` and `over`
  2. Same column: `arrayMove` within column, update local order, dispatch `useReorderTask()` mutation
  3. Different column: move card to target column, update `status`, dispatch `useUpdateProject()` optimistic mutation
  4. Rollback if mutation fails
- [ ] **[TEST] PROJ-004E**: Same-column drop reorders without status change; cross-column drop updates status optimistically; API error rolls back

- [ ] **PROJ-004F**: **WCAG 2.5.7 single-pointer alternative** — "Move to…" button on each `KanbanCard` (in `⋯` menu): "Move to → [column name]" submenu. Rendered as `<button>` elements. Calls same mutation as drag.
- [ ] **[TEST] PROJ-004F**: "Move to → In Progress" button moves card without dragging; same mutation called

- [ ] **PROJ-004G**: Cards must NOT contain focusable children (`<input>`, `<textarea>`, `<select>`). Card click opens `QuickPeekOverlay` (PROJ-012A) via `useQuickPeek().open(projectId)`.
- [ ] **[TEST] PROJ-004G**: Clicking card body opens Quick Peek overlay; no inputs exist inside card DOM

- [ ] **PROJ-004H**: "Plan Work" option in card `⋯` menu: opens a popover showing team members' My Week planned status for this work item. Can update planned week for self or colleagues.
- [ ] **[TEST] PROJ-004H**: Plan Work popover shows each member's planned week; updating triggers mutation

### Definition of Done
- Config-driven Kanban columns with count badges and capacity indicators
- `PointerSensor` with `activationConstraint` + `KeyboardSensor`; custom collision detection
- `DragOverlay` clone with glow/tilt; original at 0.4 opacity; drop indicator animation
- Optimistic status update with rollback
- WCAG 2.5.7 "Move to…" button alternative (single-pointer)
- No focusable children inside cards; card click opens Quick Peek overlay
- Plan Work popover for viewing/updating team My Week assignments

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
  Import CSS: `import '@svar-ui/react-gantt/all.css'`. Apply CSS variable overrides for dark theme (override `--wx-background`, `--wx-color-primary` in scoped wrapper div).
- [ ] **[TEST] PROJ-005A**: Gantt component renders without console errors; theme variables applied (primary = electric blue)

- [ ] **PROJ-005B**: Transform `useProjects()` data to SVAR task format:
  ```ts
  const ganttTasks = projects.map(p => ({
    id: p.id,
    text: p.name,
    start: new Date(p.startDate ?? new Date()),
    end: new Date(p.dueDate ?? addDays(new Date(), 7)),
    progress: p.progress / 100,
    type: 'task',
  }))
  ```
  Handle missing dates gracefully (startDate → today, dueDate → 7 days from start).
- [ ] **[TEST] PROJ-005B**: Projects with missing dates render without crash; transformed array length matches projects length

- [ ] **PROJ-005C**: Zoom controls (Day / Week / Month / Quarter) as `<SegmentedControl>` above Gantt. Ephemeral component `useState`.
- [ ] **[TEST] PROJ-005C**: Clicking "Month" updates Gantt scale; zoom state ephemeral (does not survive view switch)

- [ ] **PROJ-005D**: Configure `<Gantt>` props:
  - `tasks={ganttTasks}`, `scales`, `columns`, dark theme wrapper
  - `onTaskUpdate`: dispatch `useUpdateProject({ startDate, dueDate })` optimistically
- [ ] **[TEST] PROJ-005D**: Dragging a Gantt bar calls `useUpdateProject`; optimistic update reflects in bar position

- [ ] **PROJ-005E**: Bar entrance animation via CSS:
  ```css
  .gantt-bar { animation: scaleInLeft 300ms ease forwards; transform-origin: left; }
  @keyframes scaleInLeft { from { transform: scaleX(0); opacity: 0; } to { transform: scaleX(1); opacity: 1; } }
  ```
  Stagger delay based on task index (CSS custom property).
- [ ] **[TEST] PROJ-005E**: Each bar has animation; delay increases with task index

- [ ] **PROJ-005F**: Empty state: when `projects.length === 0`, show illustration + "Create your first project" CTA.
- [ ] **[TEST] PROJ-005F**: Empty state renders when no projects; Gantt not rendered with zero tasks

### Definition of Done
- SVAR React Gantt with dark theme CSS overrides
- Data transformation handles missing dates gracefully
- Zoom controls (Day/Week/Month/Quarter); ephemeral state
- Drag-to-reschedule with optimistic mutation
- CSS bar entrance animation with staggered delay
- Empty state handled

---

## 📆 Task PROJ-006: My Week View
**Priority:** 🟠 Medium | **Est. Effort:** 2.5 hours | **Depends On:** PROJ-000, PROJ-001

### Related Files
`src/components/projects/MyWeekView.tsx` · `src/components/projects/WeekLane.tsx` · `src/components/projects/ColleagueWeekDropdown.tsx`

### Subtasks

- [ ] **PROJ-006A**: Define six swim lanes (Karbon's exact bucket model):
  ```ts
  const LANES = [
    { id: 'working-now', label: 'Working on Now', description: 'Currently active items' },
    { id: 'this-week',   label: 'This Week',     description: 'Due Mon–Sun this week' },
    { id: 'next-week',   label: 'Next Week',     description: 'Auto-moves to This Week on Monday' },
    { id: 'later',       label: 'Later',         description: 'Deferred with return date (up to 3 months)' },
    { id: 'to-plan',     label: 'To Plan',       description: 'Newly assigned, not yet scheduled' },
    { id: 'done',        label: 'Done',           description: 'Completed this week' },
  ]
  ```
  Lane assignment: `working-now` ← items where user started time tracking or manually moved; `this-week` ← `plannedWeek === 'this-week'`; `next-week` ← `plannedWeek === 'next-week'`; `later` ← items with explicit return date; `to-plan` ← newly assigned, no planned week; `done` ← completed tasks.
- [ ] **[TEST] PROJ-006A**: Task with `plannedWeek = 'this-week'` lands in This Week; task with no planned week lands in To Plan; task with return date in Later

- [ ] **PROJ-006B**: Colleague's Week dropdown: select a team member → lanes populate with that person's items. Shows capacity info (assigned vs available hours). Private/hidden items show banner: "Some items are hidden."
- [ ] **[TEST] PROJ-006B**: Switching colleague updates lanes; capacity bar appears; private item banner shown

- [ ] **PROJ-006C**: Each lane is `useDroppable`. Tasks within lane are `useSortable`. Use the shared `useDndSensors()` hook from `src/shared/dnd`. Cross-lane drop updates `plannedWeek` / `status`:
  - Drop in `working-now`: set as actively working
  - Drop in `this-week`: set `plannedWeek = 'this-week'`
  - Drop in `next-week`: set `plannedWeek = 'next-week'`
  - Drop in `later`: open date picker for return date (up to 3 months/54 weeks)
  - Drop in `to-plan`: clear planned week
  - Drop in `done`: set `status = 'done'`
- [ ] **[TEST] PROJ-006C**: Dropping into Later triggers date picker; dropping into This Week sets correct plannedWeek; done sets status

- [ ] **PROJ-006D**: **WCAG 2.5.7 single-pointer alternative**: "Move to lane" button on each task row (in `⋯` menu): "Move to → Working Now / This Week / Next Week / Later / To Plan / Done". Same mutations as drag.
- [ ] **[TEST] PROJ-006D**: "Move to → Later" button moves task without dragging; date picker appears

- [ ] **PROJ-006E**: "Add a note" inline at bottom of each lane: text input, Enter saves note linked to that lane's context.
- [ ] **PROJ-006F**: Bulk actions: Shift+click range selection within a lane; "Move selected to…" dropdown. Bulk items count shown.
- [ ] **[TEST] PROJ-006F**: Shift+click selects range; bulk move updates all selected items

- [ ] **PROJ-006G**: Lane drop indicator — same animated insertion line as PROJ-004D.
- [ ] **PROJ-006H**: Calendar sidebar integration: toggle calendar panel on right side showing current week. Drag work item from My Week lane onto calendar day/time to create a time block (default 30 min, adjustable).
- [ ] **[TEST] PROJ-006H**: Calendar toggle opens sidebar; drag to calendar creates time entry; adjustable duration

- [ ] **PROJ-006I**: In-page search: search box filters items across all lanes by client name, work name, email subject, note name.
- [ ] **[TEST] PROJ-006I**: Searching filters across all lanes; lanes with no matches collapse or show "No matches"

- [ ] **PROJ-006J**: Empty lane states: each empty lane shows muted placeholder "No tasks" + optional CTA.

### Definition of Done
- Six lanes matching Karbon's bucket model with correct assignment logic
- Colleague's Week dropdown with capacity info and privacy banner
- Cross-lane drag updates `plannedWeek`/`status` optimistically; Later lane opens date picker
- WCAG 2.5.7 "Move to lane" button alternative
- Bulk selection with Shift+click and "Move selected to…"
- Calendar sidebar integration: drag work items to block time
- In-page search across all lanes
- Drop indicator animation; empty lane states

---

## 📊 Task PROJ-007: Workload View
**Priority:** 🟠 Medium | **Est. Effort:** 1.5 hours | **Depends On:** PROJ-000, PROJ-001

### Related Files
`src/components/projects/WorkloadView.tsx`

### Subtasks

- [ ] **PROJ-007A**: Aggregate workload data:
  ```ts
  type WorkloadEntry = {
    memberId: string; memberName: string; date: string; taskCount: number;
    estimatedHours: number; capacity: number; overCapacity: boolean;
  }
  ```
  Default capacity: 8 hours/day per member. Use `useMemo`; recompute when tasks or date range changes.
- [ ] **[TEST] PROJ-007A**: Member with 10 estimated hours on Tuesday has `overCapacity: true`; totals match raw data

- [ ] **PROJ-007B**: Render as recharts `BarChart` with `layout="vertical"` (members on Y axis):
  - Each bar = member's total workload for selected period
  - `<Bar dataKey="estimatedHours">` with `<Cell fill>` conditionally red for `overCapacity`
  - `<Tooltip>` shows member name, task count, hours, capacity
  - `<ReferenceLine x={capacity}>` shows capacity limit as dashed vertical line
- [ ] **[TEST] PROJ-007B**: Over-capacity bars in red; reference line at capacity; tooltip shows on hover

- [ ] **PROJ-007C**: Timeline granularity toggle: "Week" / "2 Weeks" / "Month". Changes date range for aggregation. Ephemeral component `useState`.
- [ ] **[TEST] PROJ-007C**: "Month" aggregates across 30 days; bar heights change accordingly

- [ ] **PROJ-007D**: Click interaction: clicking a member bar filters a task list below the chart to show only that member's tasks. Task list uses TanStack Virtual. "Clear filter" appears above task list when active.
- [ ] **[TEST] PROJ-007D**: Clicking bar shows only that member's tasks; "Clear filter" resets to all

- [ ] **PROJ-007E**: Colleague Utilization summary panel: table showing each member's capacity, assigned hours, actual hours, utilization %. Data from mock.
- [ ] **[TEST] PROJ-007E**: Utilization panel shows all members with capacity vs actual breakdown

### Definition of Done
- Workload data aggregated with `useMemo`
- recharts `BarChart` with capacity reference line; over-capacity in red
- Granularity toggle (Week/2 Weeks/Month)
- Click-to-filter with virtualized task list below
- Colleague Utilization summary panel

---

## 📄 Task PROJ-008: Project Detail Page & Header
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** PROJ-000, PROJ-001

### Related Files
`src/pages/ProjectDetailPage.tsx` · `src/components/projects/ProjectHeader.tsx` · `src/components/projects/ProjectTabNav.tsx`

### Subtasks

- [ ] **PROJ-008A**: Create `ProjectDetailPage`:
  - Route: `/projects/:projectId` (configured in PROJ-002A)
  - Consumes `useProject(projectId)` from TanStack Query
  - Loading: skeleton layout matching header + tabs + content
  - Error: "Project not found" with back navigation
- [ ] **[TEST] PROJ-008A**: Loading renders skeleton; 404 renders error state; back button navigates to `/projects`

- [ ] **PROJ-008B**: Build `ProjectHeader`:
  - Project name: click-to-edit (`useForm` + Escape-to-cancel pattern per PROJ-C08)
  - Status dropdown (shadcn Select): changes `status` optimistically
  - Priority badge (shadcn Badge + Popover)
  - Progress bar (read-only, computed from task completion %)
  - Budget bar: `budgetUsed / budgetAmount` with color coding (green <75%, amber 75–100%, red >100%)
  - Member avatars (stack, max 5, "+N more" overflow)
  - Due date (shadcn DatePicker): updates `dueDate` optimistically
  - Filing deadline display: shows standardized deadline if configured
  - "Setup Repeating Work" button (when applicable, opens PROJ-013 dialog)
- [ ] **[TEST] PROJ-008B**: Name saves on Enter/blur; Escape restores original; status/priority/due-date changes call mutations; budget bar colors correct

- [ ] **PROJ-008C**: Build `ProjectTabNav` — six tabs: Tasks · Timeline · Files · Notes · Activity · Automators:
  - Active tab stored in URL search param `?tab=tasks` (deep-linkable)
  - Active underline indicator: `<motion.div layoutId="tab-indicator">`
  - Each tab: `aria-selected`, `role="tab"`, `tabIndex={isActive ? 0 : -1}`
  - Keyboard: ArrowLeft/ArrowRight moves focus
- [ ] **[TEST] PROJ-008C**: Tab URL param updates on click; `aria-selected` reflects active tab; ArrowRight moves focus; active indicator slides

- [ ] **PROJ-008D**: Tab content routing: Tasks → `ProjectTaskList` (PROJ-009); Timeline → scoped `ProjectTimelineView` (reuse PROJ-005 logic); Files → Document Panel (PROJ-016); Notes → textarea with debounced save; Activity → timestamped event list; Automators → Automation Rules panel (PROJ-017)
- [ ] **[TEST] PROJ-008D**: Switching to Notes renders textarea; typing saves after 1s debounce; Activity renders event list; Automators shows rules

### Definition of Done
- Loading skeleton, error state, and happy path all handled
- Inline name editing with Escape-to-cancel; status/priority/due-date/budget all editable with optimistic mutations
- Filing deadline display in header
- "Setup Repeating Work" button present
- Six tabs: URL search params, animated indicator, keyboard nav
- All tab panels wired to content components

---

## ✅ Task PROJ-009: Project Task List & Inline Creation
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** PROJ-008

### Related Files
`src/components/projects/ProjectTaskList.tsx` · `src/components/projects/TaskRow.tsx` · `src/components/projects/TaskSection.tsx`

### Subtasks

- [ ] **PROJ-009A**: Build `ProjectTaskList` with sections:
  - Render `TaskSection` components (collapsible), each with `TaskRow` children
  - "Add section" button at bottom
  - Section header: editable name (PROJ-C08 pattern); collapse toggles `expandedSectionIds` in store; conditional section shows toggle indicator and can be activated/deactivated manually
  - No virtualization at section level; virtualize only within a section if >50 tasks
- [ ] **[TEST] PROJ-009A**: Sections render with correct tasks; collapsing hides task rows; section name editable; conditional toggle works

- [ ] **PROJ-009B**: Virtualize large sections with `useVirtualizer`:
  - Apply only when `section.tasks.length > 50`
  - `estimateSize: () => 44` (fixed task row height)
  - If ≤50 tasks, render directly (no virtualizer overhead)
- [ ] **[TEST] PROJ-009B**: Section with 60 tasks renders ≤25 DOM rows; section with 30 tasks renders all 30 directly

- [ ] **PROJ-009C**: Build `TaskRow`:
  - Columns: checkbox (complete), title (clickable → opens TaskDrawer), task type badge (billable/non-billable), assignee avatar, priority badge, due date, subtask count, `⋯` menu
  - Checkbox toggles `status: 'done'` optimistically; CSS strikethrough
  - Client tasks: show reminder count badge + auto-reminder indicator
  - Conditional tasks: show "Conditional" badge when controlled by automator
  - Row hover: reveals drag handle, assign button, due date picker
  - `aria-label={task.title}`; `role="row"`
- [ ] **[TEST] PROJ-009C**: Checkbox toggles completion; client task shows reminder badge; conditional task shows indicator; hover reveals action buttons

- [ ] **PROJ-009D**: Within-section drag-to-reorder using `useSortable` + `DragOverlay`. Updates `order` field optimistically. Drag handle (left edge icon) is `attributes` target.
- [ ] **[TEST] PROJ-009D**: Dragging task row reorders within section; `order` mutation called; drag handle is activation target

- [ ] **PROJ-009E**: Inline task creation: "+ Add task" at bottom of each section opens inline `<input>`:
  - Enter: create task with title + `sectionId` via `useCreateTask()` → input stays open for next task
  - Task type selector (billable/non-billable) in creation row
  - Shift+Enter: create client task (external, with auto-reminders)
  - Escape: cancel and close input
- [ ] **[TEST] PROJ-009E**: Enter creates task and keeps input open; Shift+Enter creates client task; Escape closes; optimistic task appears

- [ ] **PROJ-009F**: "Add Section" button: inline input for section name; Enter creates section; Escape cancels.
- [ ] **[TEST] PROJ-009F**: New section appears at bottom of task list; can be renamed inline

### Definition of Done
- Sections with collapsible groups, conditional indicators, editable names
- TanStack Virtual for sections >50 tasks; direct render for ≤50
- Task rows with checkbox, hover actions, client/conditional badges, correct ARIA
- Within-section drag-to-reorder with drag handle
- Inline "+ Add task" stays open for multiple adds; Shift+Enter for client tasks
- Inline "+ Add section"

---

## 🗂️ Task PROJ-010: Task Detail Drawer
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** PROJ-009, PROJ-001

### Related Files
`src/components/projects/TaskDetailDrawer.tsx` · `src/components/projects/TaskChecklist.tsx` · `src/components/projects/TaskComments.tsx`

### Subtasks

- [ ] **PROJ-010A**: Build `TaskDetailDrawer`:
  - Triggered by `useTaskDrawer().taskId !== null`
  - Slides from right: `<motion.aside initial={{ x: '100%' }} animate={{ x: 0 }} exit={{ x: '100%' }} transition={{ type: 'spring', stiffness: 300, damping: 35 }}>`
  - Wrapped in `AnimatePresence`; `role="complementary"`; `aria-label="Task details"`
  - Close: X button + Escape key → `useTaskDrawer().close()`
  - Focus trap: Tab cycles within drawer only (`focus-trap-react` or manual)
- [ ] **[TEST] PROJ-010A**: Drawer animates from right; Escape closes; focus stays within drawer; `aria-label` present

- [ ] **PROJ-010B**: Drawer header: editable task title (PROJ-C08), status dropdown, priority badge, assignee select (avatar + name), due date picker, task type selector (billable/non-billable), client task toggle (on/off with reminder config).
- [ ] **[TEST] PROJ-010B**: Title saves on Enter/blur; Escape reverts; all fields call optimistic mutations

- [ ] **PROJ-010C**: Drawer tabs: Details · Checklist · Comments · Activity. Component `useState` for tab (drawer is overlay, not a navigable page). Same motion pattern as PROJ-008C.
- [ ] **[TEST] PROJ-010C**: Switching tabs renders correct panel; keyboard ArrowLeft/Right moves between tabs

- [ ] **PROJ-010D**: **Checklist tab** (`TaskChecklist`):
  - List of items: checkbox + editable text + assignee avatar (optional) + due date (optional) + delete button
  - "+ Add item" at bottom (inline input, stays open for multiple adds)
  - Completion percentage in tab label: "Checklist (3/5)"
  - Reordering via dnd-kit (within-list sort)
  - All mutations: `onMutate → onError → onSettled`
- [ ] **[TEST] PROJ-010D**: Checking item updates percentage; reordering calls order mutation; deleting removes optimistically

- [ ] **PROJ-010E**: **Comments tab** (`TaskComments`):
  - List of comments: avatar, name, timestamp, content, internal/external badge
  - Internal/External toggle: blue background = internal (team only); white = external (client-visible). Toggle switches between modes.
  - `@mention` autocomplete: type `@` → dropdown of team members; selecting inserts mention; mentioned user gets notification
  - `<TextareaAutosize>` input; `cacheMeasurements={true}`; submit on `Cmd+Enter`; `Enter` inserts newline
  - Optimistic: new comment appears immediately with `status: 'sending'` indicator
  - Error: comment shows red outline + "Retry" link
- [ ] **[TEST] PROJ-010E**: Cmd+Enter submits; @mention dropdown appears; internal/external toggle works; error shows retry

- [ ] **PROJ-010F**: **Description field** (in Details tab): `<TextareaAutosize>` with `minRows={3}`. Auto-saves on blur with 500ms debounce. "Last saved X minutes ago" timestamp below. Supports file uploads dragged into description area.
- [ ] **[TEST] PROJ-010F**: Editing and blurring saves after 500ms; timestamp updates; file upload works

- [ ] **PROJ-010G**: **Activity tab**: chronological log of changes to this task — status changes, reassignments, comments added, checklist items completed, files uploaded. Each entry: timestamp, user, action description, optional detail expansion.
- [ ] **[TEST] PROJ-010G**: Activity log renders in reverse chronological order; items have correct action descriptions

### Definition of Done
- Drawer slides in/out with spring; exit via `AnimatePresence`; focus trap
- Editable header (title, status, priority, assignee, due date, task type, client toggle)
- Four tabs: Details, Checklist, Comments, Activity
- Checklist: completion %, dnd-kit reorder, inline add
- Comments: `Cmd+Enter` submit, @mention autocomplete, internal/external toggle, optimistic with retry
- Description: debounced auto-save, file upload
- Activity log: chronological event list

### Anti-Patterns
- ❌ Tab state in URL params for drawer — use component state
- ❌ `TextareaAutosize` without `cacheMeasurements` — layout thrashing
- ❌ Missing focus trap — keyboard users lose context
- ❌ Saving description on every keystroke — debounce to 500ms

---

## 📋 Task PROJ-011: Quick Peek Overlay
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** PROJ-000, PROJ-001, PROJ-004

### Related Files
`src/components/projects/QuickPeekOverlay.tsx`

### Subtasks

- [ ] **PROJ-011A**: Build `QuickPeekOverlay`:
  - Triggered by `useQuickPeek().projectId !== null`
  - Modal overlay: `<motion.div initial={{ scale: 0.95, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}>` — spring stiffness 400 damping 25
  - Dismiss: click outside, Escape key, or "View Full Detail" button
  - Shows at-a-glance: project name, status, priority, due date, budget progress bar, pinned notes (first 2), last completed task, task list (first 5 with checkboxes), next tasks (upcoming 3)
  - "View Full Detail" button navigates to `/projects/:projectId`
  - Mark tasks off directly from overlay via checkbox (optimistic mutation)
- [ ] **[TEST] PROJ-011A**: Opening overlay animates scale+fade; task checkboxes work; "View Full Detail" navigates; Escape/click-outside closes

- [ ] **PROJ-011B**: Data fetched via `useProject(projectId)` (same query as detail page — leverages cache from hover prefetch PROJ-003D). Show skeleton while loading.
- [ ] **[TEST] PROJ-011B**: Overlay uses cached data when prefetched; skeleton shows on cache miss

- [ ] **PROJ-011C**: Accessible: `role="dialog"`, `aria-modal="true"`, `aria-label="Quick peek: {project name}"`. Focus trapped within overlay.
- [ ] **[TEST] PROJ-011C**: Focus cycles within overlay; `aria-modal` set; label includes project name

### Definition of Done
- Quick Peek overlay with spring entrance animation
- At-a-glance view: name, status, priority, budget, pinned notes, 5 tasks with checkboxes, upcoming tasks
- "View Full Detail" navigates to project detail page
- Uses cached data from hover prefetch
- Accessible dialog with focus trap

---

## 📚 Task PROJ-012: Project Template Library
**Priority:** 🟢 Low | **Est. Effort:** 1.5 hours | **Depends On:** PROJ-000, PROJ-002

### Related Files
`src/components/projects/ProjectTemplateLibrary.tsx`

### Subtasks

- [ ] **PROJ-012A**: Build template grid:
  - Cards: template icon, name, description, task count badge, estimated duration
  - Templates: "Product Launch" (12 tasks), "Home Renovation" (8 tasks), "Marketing Campaign" (10 tasks), "Software Release" (15 tasks), "Event Planning" (9 tasks), "Blank" (0 tasks)
  - Grid: 3 cols desktop, 2 cols tablet, 1 col mobile
  - Hover: card lifts with `boxShadow` transition (Quiet tier — pure CSS)
- [ ] **[TEST] PROJ-012A**: Six template cards render; blank template has no task count badge; grid responsive

- [ ] **PROJ-012B**: Clicking template opens "New Project" dialog (PROJ-002E) with:
  - Name pre-filled as template name (user can change)
  - Status set to "active", work type from template
  - `templateId` passed to `useCreateProject()` so backend seeds tasks and sections
  - Optimistic: project appears in list immediately; tasks load asynchronously
- [ ] **[TEST] PROJ-012B**: Clicking "Product Launch" opens dialog with name pre-filled; submit calls `useCreateProject({ templateId: 'product-launch' })`

- [ ] **PROJ-012C**: Template library accessible from two entry points:
  1. "New Project" dialog: "Start from template" link
  2. Projects list empty state: "Choose a template" primary CTA
- [ ] **[TEST] PROJ-012C**: Both entry points open template library; selecting template navigates to new project form

- [ ] **PROJ-012D**: "Save as Template" option in project detail `⋯` menu: creates template from existing work item (copies sections, tasks, automators).
- [ ] **[TEST] PROJ-012D**: Saving project as template creates new template entry; template includes all sections and tasks

### Definition of Done
- Six template cards in responsive grid
- Clicking template pre-fills New Project dialog; passes `templateId`
- Accessible from dialog link and empty state CTA
- "Save as Template" from existing project

---

## 🔁 Task PROJ-013: Recurring Work Scheduler
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** PROJ-000, PROJ-008

### Related Files
`src/components/projects/RecurringWorkDialog.tsx` · `src/components/projects/RecurringScheduleList.tsx` · `@/shared/recurrence/RecurrenceEngine.ts` · `@/shared/recurrence/helpers.ts` · `@/shared/recurrence/RecurrenceEditor.tsx`

### Subtasks

- [ ] **PROJ-013A**: Build `RecurringWorkDialog` using `RecurrenceEditor` from `@/shared/recurrence` for frequency configuration. Map frequency options to `RecurrenceRule`:
  - Daily, Weekly, Monthly, Quarterly (monthly with interval 3), Yearly
  - Use `ruleToRRULE()` and `rruleToHuman()` from `@/shared/recurrence/helpers` for rule conversion and display
  - Additional project-specific fields (due date offset, assignee, naming convention, folder, work creation timing, resource planning)
- [ ] **[TEST] PROJ-013A**: All sections render; frequency changes update preview; naming convention preview updates live

- [ ] **PROJ-013B**: Form validation: Use `recurrenceRuleSchema` from `@/shared/recurrence` for recurrence validation. Additional Zod validation for project-specific fields (due date offset positive integer, naming convention includes placeholder).
- [ ] **[TEST] PROJ-013B**: Validation errors shown for invalid offset; submit disabled until valid

- [ ] **PROJ-013C**: On submit: call `useCreateRecurringSchedule()` mutation with RRULE string from `RecurrenceEditor`. Use `RecurrenceEngine.getNextOccurrences()` to preview upcoming instances (next 5) with dates, assignee, and status.
- [ ] **[TEST] PROJ-013C**: Submit saves schedule; upcoming instances preview renders

- [ ] **PROJ-013D**: `RecurringScheduleList` component (shown in project header for recurring work):
  - List of all recurring schedules with edit/pause/delete actions
  - Visual indicator on projects that are part of a recurring series
- [ ] **[TEST] PROJ-013D**: Schedule list renders; pause toggles active state; delete removes schedule

- [ ] **PROJ-013E**: "Edit Schedule" from project options `⋯` menu reopens dialog pre-filled with current schedule values.
- [ ] **[TEST] PROJ-013E**: Edit mode loads existing values; changes save correctly

### Definition of Done
- Recurring Work dialog with 7 configurable areas matching Karbon's repeat settings
- Zod validation; dynamic naming preview
- Upcoming instances preview (next 5)
- Schedule list with edit/pause/delete
- "Edit Schedule" from project options

---

## 💾 Task PROJ-014: Saved Views
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** PROJ-002, PROJ-001

### Related Files
`src/components/projects/SavedViewsManager.tsx` · `src/components/projects/SaveViewDialog.tsx`

### Subtasks

- [ ] **PROJ-014A**: Build `SaveViewDialog`:
  - Triggered by "Save View As" button in filter bar (PROJ-002D)
  - Fields: view name (required), description (optional)
  - Captures current filter + sort + view mode state from Zustand
  - On save: persists to `localStorage` (key: `saved-project-views`) + MSW mock endpoint
- [ ] **[TEST] PROJ-014A**: Saving captures current filters; saved view appears in list; reloading page restores saved views list

- [ ] **PROJ-014B**: Build `SavedViewsManager`:
  - Dropdown or sidebar list of saved views, sorted by user-defined order
  - Click a saved view: applies filters + sort + view mode
  - Active saved view highlighted
  - "Edit Saved Views" mode: reorder (drag), rename (inline edit), delete
  - "Share" button: generates unique URL with view ID as query param; clicking URL applies the saved view's filters
- [ ] **[TEST] PROJ-014B**: Clicking saved view applies all filters and view mode; reorder works; share URL applies correct filters when opened

- [ ] **PROJ-014C**: URL sharing: `?view=view-id` param in URL. On mount, if `view` param present, load saved view and apply filters.
- [ ] **[TEST] PROJ-014C**: Navigating to `/projects?view=abc123` applies saved view filters

- [ ] **PROJ-014D**: Default views: provide 3 pre-built saved views as examples — "Overdue Work" (status != completed, due date < today), "Over Budget" (budget used > 75%), "My Active Projects" (assignee = current user, status = active).
- [ ] **[TEST] PROJ-014D**: Default views appear in list; can be customized and re-saved

### Definition of Done
- Save View dialog captures current filter/sort/view state
- Saved views list with reorder, rename, delete
- Share via unique URL; URL param applies saved view on load
- 3 pre-built default views
- Persisted to localStorage

---

## 🤝 Task PROJ-015: External Task Assignment (Client Tasks)
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** PROJ-009, PROJ-010

### Related Files
`src/components/projects/ClientTaskConfig.tsx` · `src/components/projects/ClientTaskReminderSettings.tsx`

### Subtasks

- [ ] **PROJ-015A**: Build `ClientTaskConfig`:
  - Toggle in TaskDrawer (PROJ-010B): "This is a client task"
  - When enabled, task gets external visibility; appears in client portal (mock)
  - Auto-reminder schedule: "Send reminder every [N] days, up to [M] reminders"
  - After 5 reminders with no response, auto-update work status (configurable)
- [ ] **[TEST] PROJ-015A**: Toggle changes task type; reminder config saves; after 5 mock reminders, status auto-updates

- [ ] **PROJ-015B**: Client task indicator on TaskRow (PROJ-009C): shows reminder count badge + days since last reminder.
- [ ] **[TEST] PROJ-015B**: Client task rows display reminder badge; count increments with mock reminders

- [ ] **PROJ-015C**: Client task section in project: can group client tasks in dedicated section. Client task sections support automators (e.g., "When all client tasks completed, update status").
- [ ] **[TEST] PROJ-015C**: Client task section renders distinct styling; automator triggers on completion

- [ ] **PROJ-015D**: Client task comments default to External visibility. Internal/External toggle in comment input (reuse PROJ-010E toggle).
- [ ] **[TEST] PROJ-015D**: New comments on client tasks default to External; toggle switches to Internal

### Definition of Done
- Client task toggle with auto-reminder schedule configuration
- Reminder count badge on client task rows
- Client task sections with distinct styling and automator support
- Comments default to External visibility with toggle

---

## 📁 Task PROJ-016: Document Panel
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** PROJ-008

### Related Files
`src/components/projects/DocumentPanel.tsx` · `src/components/projects/DocumentUploader.tsx` · `src/components/projects/DocumentFolderTree.tsx`

### Subtasks

- [ ] **PROJ-016A**: Build `DocumentPanel` (Files tab content in project detail):
  - Folder tree: client name → service type folders (e.g., Bookkeeping, Tax Return, Advisory)
  - File list: name, type icon, size, uploaded by, upload date
  - Upload button: drag-and-drop zone + file picker (up to 10MB per file)
  - Preview: click file opens preview modal (images, PDFs); other types show download link
  - Delete with confirmation
- [ ] **[TEST] PROJ-016A**: Folder tree renders; upload adds file to current folder; preview modal works for images; delete removes file

- [ ] **PROJ-016B**: Connected folder integration (placeholder):
  - "Connect Folder" button: links to external storage (Google Drive / OneDrive mock)
  - For recurring work: "Auto-create folder" checkbox — creates folder for each new work item in series
  - Folder breadcrumb navigation
- [ ] **[TEST] PROJ-016B**: Connect Folder opens mock integration dialog; auto-create checkbox saves preference

- [ ] **PROJ-016C**: Document sidebar (toggle from project header): narrow right panel showing quick-access document list with search. Same data, compact view.
- [ ] **[TEST] PROJ-016C**: Document sidebar toggles; search filters document list

### Definition of Done
- Folder tree with client/service-type structure
- File upload with drag-and-drop, preview, delete
- Connected folder placeholder (Google Drive / OneDrive)
- Auto-create folder for recurring work items
- Document sidebar for quick access

---

## ⚙️ Task PROJ-017: Workflow Automation Engine — Rule Builder
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** PROJ-000, PROJ-008

### Related Files
`src/components/projects/AutomationRulesPanel.tsx` · `src/components/projects/AutomationRuleBuilder.tsx` · `src/components/projects/GlobalAutomatorsSettings.tsx`

### Subtasks

- [ ] **PROJ-017A**: Build `GlobalAutomatorsSettings` (accessible from Settings > Workflow):
  - List of global rules with on/off toggles:
    - "When planned work reaches start date, update status to…" (configurable status)
    - "When email is assigned, set default status to…"
    - "When note is assigned, set default status to…"
    - "When first task completed, update work status to In Progress"
    - "When all tasks completed, mark work as Completed"
    - "When 5 client task reminders sent with no response, update status to…"
  - Each rule: description, status selector, active toggle
- [ ] **[TEST] PROJ-017A**: Six global automator rules render; toggling saves; status selectors work

- [ ] **PROJ-017B**: Build `AutomationRuleBuilder` (tasklist automator):
  - Trigger ("When") dropdown:
    - "All tasks in this section"
    - "All tasks in the section above"
    - "All sections & tasks above this section"
    - "The work" (triggers on work-level events)
    - "All tasks in a specific section" (section picker)
  - Condition ("Have the status"): multi-select from workflow statuses (Planned, Ready to Start, In Progress, Completed, custom statuses)
  - Action ("Then"): Change Status (dropdown), Change Due Date (date picker or offset), Change Assignee (user picker)
  - Visual rule preview: "When [trigger] have the status [condition], then [action]"
  - Multiple rules per section supported
- [ ] **[TEST] PROJ-017B**: Rule builder creates valid rule; preview renders correctly; multiple rules per section

- [ ] **PROJ-017C**: `AutomationRulesPanel` (Automators tab in project detail):
  - Lists all tasklist automators grouped by section
  - Each rule: description text, active toggle, edit button (opens builder pre-filled), delete button
  - Triggered automators appear with strikethrough + reset option
  - "Add Automator" button per section
- [ ] **[TEST] PROJ-017C**: Rules list renders grouped by section; toggling active works; edit opens builder pre-filled; triggered rules show strikethrough

- [ ] **PROJ-017D**: Automator trigger simulation:
  - When a task in a section is completed and an automator condition is met, the action fires (mock)
  - Visual feedback: brief blue pulse on affected work item card + activity timeline entry
  - Conditional sections: sections can be activated/deactivated manually or via automators
- [ ] **[TEST] PROJ-017D**: Completing all tasks in section triggers automator; pulse animation plays; activity entry created; conditional section toggles

### Definition of Done
- Global automators settings page with 6 configurable rules
- Tasklist automator rule builder: trigger → condition → action
- Automation rules panel in project detail, grouped by section
- Automator trigger simulation with visual feedback
- Conditional sections support (manual + automator-driven)

---

## 📥 Task PROJ-018: Triage Inbox — Shell & Item Rendering
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** PROJ-000, PROJ-001, TASK-002

### Related Files
`src/pages/TriagePage.tsx` · `src/components/triage/TriageStream.tsx` · `src/components/triage/TriageItem.tsx` · `src/components/triage/TriageActionTray.tsx`

### Subtasks

- [ ] **PROJ-018A**: Configure route for `/triage`:
  ```ts
  {
    path: 'triage',
    lazy: () => import('@/pages/TriagePage'),
    loader: () => queryClient.ensureQueryData(triageQueryOptions({})),
  }
  ```
  Add Triage to main sidebar navigation (between Chat and Projects).
- [ ] **[TEST] PROJ-018A**: Navigating to `/triage` renders page; sidebar Triage link works

- [ ] **PROJ-018B**: Build `TriagePage` layout:
  - Left: filter sidebar — "All", "Unread", "Cleared", "Assigned to Me", "Decisions", "Drafts", "Scheduled Emails", "Sent Emails"
  - Center: `TriageStream` — unified list of emails, notifications, work assignments, client tasks, comments, decisions
  - Right: `TriageActionTray` (when item selected — PROJ-019)
  - Split view toggle: list view (full width stream) or split view (stream + action tray)
- [ ] **[TEST] PROJ-018B**: Filter sidebar highlights active filter; split view toggle works

- [ ] **PROJ-018C**: Build `TriageItem`:
  - **Color coding**: Grey background = work assignments & internal notes; Pink background = client tasks & client requests; White/standard = emails & notifications
  - Content: subject line, preview text (first 2 lines), sender/actor avatar + name, relative timestamp, category icon
  - Unread indicator: bold subject + blue dot
  - Cleared items: reduced opacity, moved to "Cleared" filter view
  - Click: selects item (highlights), opens action tray on right
  - Keyboard: `E` to clear, `A` to assign to self, `P` to plan for this week (with `<kbd>` hints on hover)
- [ ] **[TEST] PROJ-018C**: Items color-coded correctly; unread items bold with blue dot; cleared items in separate view; keyboard shortcuts work

- [ ] **PROJ-018D**: Virtualize `TriageStream` with `useVirtualizer`:
  - `estimateSize: () => 72` (variable item height estimate)
  - `overscan: 15`
  - New items slide in from top with spring animation (Alive tier: `y: -20 → 0`, opacity `0 → 1`, stagger 0.03s)
- [ ] **[TEST] PROJ-018D**: 500+ triage items render with bounded DOM; new item animation plays; scroll performance smooth

- [ ] **PROJ-018E**: "Clear to zero" goal: progress indicator showing "12 items remaining" or "Triage zero! 🎉" empty state. Empty state: "Your Triage is clear — great work!" with illustration.
- [ ] **[TEST] PROJ-018E**: Counter decrements when items cleared; zero state shows celebration message

### Definition of Done
- Triage page with route, sidebar filter, stream, and split view
- Color-coded items (grey/pink/white) with unread/cleared states
- Virtualized stream with slide-in animation for new items
- Keyboard shortcuts (`E`, `A`, `P`) with `<kbd>` hints
- "Clear to zero" goal with progress indicator and empty state

---

## 🎯 Task PROJ-019: Triage Inbox — Action Tray & Item Actions
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** PROJ-018

### Related Files
`src/components/triage/TriageActionTray.tsx` · `src/components/triage/TriageDelegationSettings.tsx`

### Subtasks

- [ ] **PROJ-019A**: Build `TriageActionTray` (right panel when item selected):
  Five sections matching Karbon's design, ordered by importance:
  1. **Timeline** — "Add to Timeline" button: links item to existing work item (primary), organization timeline, or creates new work item from email. Shows current timeline associations. Multi-select: can add to multiple timelines.
  2. **My Week** — "Plan for This Week" toggle button. When clicked, item appears in This Week bucket. Clears item from Triage stream. Goal: spend ≤2 minutes per item — either clear, assign, or plan for week.
  3. **Assignment** — assign to self or team member dropdown.
  4. **Notify Me** — toggle (default on): if cleared, future replies/comments return to Triage. If off, only direct @mentions or direct emails return.
  5. **Visibility** — info display: who can see this item. Option to make contact/timeline private.
- [ ] **[TEST] PROJ-019A**: All five sections render; "Plan for This Week" clears item; Timeline linking works; Notify Me toggle saves

- [ ] **PROJ-019B**: **Comment within email**: Reply All / Reply / Forward buttons + Comment button. Comment has blue background (internal only). Emails have white background. @mention colleagues in comments.
- [ ] **[TEST] PROJ-019B**: Reply/Forward/Comment buttons work; Comment has blue background; @mention notifies

- [ ] **PROJ-019C**: Quick actions from stream (without selecting item):
  - Swipe right (or click checkmark icon): clear item
  - Swipe left (or click clock icon): plan for this week
  - `E` key: clear selected item
  - `A` key: assign to self
  - `P` key: plan for this week
- [ ] **[TEST] PROJ-019C**: Swipe actions work; keyboard shortcuts function on selected item

- [ ] **PROJ-019D**: Build `TriageDelegationSettings`:
  - Grant colleague access to your Triage inbox (temporary or permanent)
  - Delegates can manage emails, reply as themselves, assign, clear, add to timelines
  - Both delegator and delegate can view and take action
  - "View as [colleague]" toggle in Triage header when delegation active
  - Delegation can be updated or removed at any time
- [ ] **[TEST] PROJ-019D**: Granting delegation works; delegate can manage emails; "View as" toggle switches perspective; removal revokes access

- [ ] **PROJ-019E**: Shared Triage: teams can manage shared email inboxes (e.g., `info@`). Shared inbox appears alongside personal inbox in sidebar.
- [ ] **[TEST] PROJ-019E**: Shared inbox listed in sidebar; items in shared inbox visible to team members

### Definition of Done
- Action tray with 5 sections: Timeline, My Week, Assignment, Notify Me, Visibility
- Comment within email (blue = internal, white = external)
- Quick actions: swipe, keyboard shortcuts, icon buttons
- Delegated Triage: grant/revoke access, view as colleague
- Shared Triage: shared inbox management

---

## 🔗 Task PROJ-020: Triage Inbox — Integration Hub
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** PROJ-018, PROJ-019, TASK-006, TASK-007

### Related Files
`src/components/triage/TriageIntegrationHub.tsx` · `src/hooks/useTriage.ts`

### Subtasks

- [ ] **PROJ-020A**: Integrate real data sources into Triage stream:
  - **Agent outputs**: AgentFleetPanel activity (from TASK-006) → Triage items when agents produce decisions, summaries, or alerts
  - **Decision packets**: AttentionQueue items (from TASK-007) → Triage items with "Approve/Reject/Defer" inline actions
  - **Project work assignments**: When user is assigned to a project/task → Triage item
  - **Budget alerts**: When budget exceeds 75%/100% → Triage notification
  - **Comment mentions**: When @mentioned in any comment → Triage notification
  - **Recurring work created**: When scheduler creates new work item → Triage notification
- [ ] **[TEST] PROJ-020A**: Agent output appears in Triage; decision packet shows Approve/Reject buttons; budget alert triggers notification; @mention appears

- [ ] **PROJ-020B**: Triage item type icons and color coding:
  - Agent output: 🤖 robot icon, grey background
  - Decision: ⚡ lightning icon, amber highlight
  - Work assignment: 📋 clipboard icon, grey background
  - Budget alert: 💰 money icon, red highlight (if over budget)
  - @mention: 💬 speech bubble icon, blue dot
  - Client task update: 👤 person icon, pink background
- [ ] **[TEST] PROJ-020B**: Each type has correct icon and color; visual distinction between types is clear

- [ ] **PROJ-020C**: Triage notification preferences (Settings > Notifications):
  - Per-type toggles: enable/disable Triage notifications for each source
  - Sound toggle per type
  - Digest mode: "Real-time", "Hourly digest", "Daily digest"
- [ ] **[TEST] PROJ-020C**: Disabling Agent output toggle stops agent notifications; digest mode batches notifications

### Definition of Done
- Triage stream connected to agent outputs, decisions, project assignments, budget alerts, mentions, and recurring work
- Type-specific icons and color coding
- Notification preferences per source type with digest modes

---

## 🔍 Task PROJ-021: Global Search
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** PROJ-000, TASK-002

### Related Files
`src/components/search/GlobalSearchDialog.tsx` · `src/components/search/SearchResultItem.tsx`

### Subtasks

- [ ] **PROJ-021A**: Build `GlobalSearchDialog`:
  - Triggered by `Cmd+K` (integrate with existing CommandPalette) or dedicated `Cmd+Shift+F`
  - Search bar with instant-as-you-type results
  - Searches across: Projects, Tasks, Emails/Triage items, Notes, Comments, Documents, Contacts
  - Results grouped by entity type with section headers
  - Each result: entity icon, title, subtitle (context — e.g., project name for a task), relative timestamp
- [ ] **[TEST] PROJ-021A**: Typing "tax" returns projects, tasks, and emails containing "tax"; results grouped by type; real-time filtering

- [ ] **PROJ-021B**: Advanced search filters:
  - Type filter: "type:project", "type:task", "type:email", "type:note"
  - Date filter: "before:2026-01-01", "after:2025-06-01"
  - Status filter: "status:active"
  - Keyboard: ArrowUp/Down to navigate results, Enter to open, Escape to close
- [ ] **[TEST] PROJ-021B**: "type:task status:done" returns only completed tasks; date filters work; keyboard navigation functions

- [ ] **PROJ-021C**: Clicking a result navigates to the entity:
  - Project → `/projects/:id`
  - Task → opens ProjectDetailPage with TaskDrawer open
  - Email → opens Triage with item selected
  - Note → opens relevant project Notes tab
  - Document → opens DocumentPanel with file preview
- [ ] **[TEST] PROJ-021C**: Each result type navigates to correct location; context is preserved

- [ ] **PROJ-021D**: Recent searches saved locally (last 10). "No results" empty state with suggestions.
- [ ] **[TEST] PROJ-021D**: Recent searches appear on empty input; no-results state shows helpful suggestions

### Definition of Done
- Global search dialog with cross-entity search
- Results grouped by entity type
- Advanced search filters (type, date, status)
- Navigation to entity on result click
- Recent searches and no-results state

---

## ⏱️ Task PROJ-022: Time & Budget Tracking Panel
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** PROJ-000, PROJ-008

### Related Files
`src/components/projects/TimeBudgetPanel.tsx` · `src/components/projects/TimeEntryForm.tsx`

### Subtasks

- [ ] **PROJ-022A**: Build `TimeBudgetPanel` (accessible from project detail tab or header):
  - Budget section: total budget amount, budget used, remaining, progress bar with color coding (green <75%, amber 75–100%, red >100%)
  - Time section: estimated hours, actual hours tracked, remaining hours
  - Breakdown by team member: table with name, role, budgeted hours, actual hours, variance
  - Breakdown by task type: billable vs non-billable hours
- [ ] **[TEST] PROJ-022A**: Budget bar colors correct; member breakdown shows variance; task type breakdown splits billable/non-billable

- [ ] **PROJ-022B**: Build `TimeEntryForm`:
  - "Clock In" / "Clock Out" button for work item
  - Manual time entry: hours, minutes, date, task type (billable/non-billable), description
  - Weekly timesheet view: table of all time entries for the week
  - Submit for approval (mock workflow)
- [ ] **[TEST] PROJ-022B**: Clock In/Out works; manual entry saves; timesheet shows weekly entries; submit changes status

- [ ] **PROJ-022C**: Budget settings (admin):
  - Task types management: create/edit/delete types, toggle billable
  - Default capacity per team member (hours/week)
  - Budget estimate mode: by amount or by hours
- [ ] **[TEST] PROJ-022C**: Task types CRUD works; capacity settings save; estimate mode toggles

- [ ] **PROJ-022D**: WIP (Work in Progress) panel: filterable list of work items with billable time, fee type, client, work type. Identify highest-value work to complete.
- [ ] **[TEST] PROJ-022D**: WIP list renders with filters; sorting by value works

### Definition of Done
- Budget panel with total, used, remaining, and visual progress
- Time tracking with clock in/out and manual entry
- Breakdown by team member and task type (billable/non-billable)
- Weekly timesheet view
- Budget settings (task types, capacity, estimate mode)
- WIP panel with filters

---

## 📅 Task PROJ-023: Filing Deadlines Configuration
**Priority:** 🟢 Low | **Est. Effort:** 1.5 hours | **Depends On:** PROJ-000

### Related Files
`src/components/settings/FilingDeadlinesSettings.tsx` · `src/components/projects/FilingDeadlineBadge.tsx`

### Subtasks

- [ ] **PROJ-023A**: Build `FilingDeadlinesSettings` (Settings > Workflow > Filing Deadlines):
  - Table of standardized deadlines: name (e.g., "Individual Tax Return", "Corporate Tax Return"), standard due date (e.g., "April 15"), extension due date (e.g., "October 15")
  - Add/edit/delete deadlines
  - Apply to templates: checkbox to roll deadline out across all work items using that template
- [ ] **[TEST] PROJ-023A**: Deadlines CRUD works; applying to template updates all associated work items

- [ ] **PROJ-023B**: Build `FilingDeadlineBadge`:
  - Displayed on project header (PROJ-008B) when project has a filing deadline
  - Shows deadline name, due date, days remaining countdown
  - Color coding: green (>30 days), amber (7–30 days), red (<7 days), red pulsing (overdue)
  - Extension indicator: "Extension filed — due [date]"
- [ ] **[TEST] PROJ-023B**: Badge shows correct colors at different date ranges; extension indicator changes due date

- [ ] **PROJ-023C**: Automated extension management:
  - "File Extension" button on work item → updates deadline to extension date
  - Automator rule: "When extension filed, update due date to extension due date"
  - Bulk extension: apply extension status to up to 100 items at once
- [ ] **[TEST] PROJ-023C**: File Extension updates due date; automator triggers; bulk extension works

### Definition of Done
- Filing deadlines settings with CRUD and template application
- Filing deadline badge on project header with color-coded countdown
- Extension management with automator integration
- Bulk extension action

---

## 📊 Task PROJ-024: Practice Intelligence Dashboard (AI Agents)
**Priority:** 🟢 Low | **Est. Effort:** 3 hours | **Depends On:** PROJ-000, TASK-006, TASK-007

### Related Files
`src/components/intelligence/PracticeIntelligenceDashboard.tsx` · `src/components/intelligence/AIAgentActivity.tsx` · `src/components/intelligence/FIFOQueue.tsx`

### Subtasks

- [ ] **PROJ-024A**: Build `PracticeIntelligenceDashboard`:
  - Portfolio performance overview: revenue, utilization, realization rate, hours, billed rate — filterable by client, colleague, work type, date range
  - AI agents status panel: active agents list with current tasks, tokens consumed, actions taken
  - Revenue trend chart (recharts): monthly revenue vs target
  - Realization rate gauge: actual vs expected
- [ ] **[TEST] PROJ-024A**: Dashboard renders with mock data; filters work; charts animate on load

- [ ] **PROJ-024B**: Build `AIAgentActivity`:
  - Agentic AI embedded in task lists: AI agents automatically execute actions, fetch data, update statuses, communicate with clients
  - Agent activity log: timestamped entries of agent actions with expandable details
  - Agent control: pause/resume individual agents; configure agent behavior
- [ ] **[TEST] PROJ-024B**: Agent activity log renders; pause/resume works; agent actions appear in task timelines

- [ ] **PROJ-024C**: Build `FIFOQueue`:
  - First-In-First-Out queue visualization: ordered list of work items by intake date
  - Priority indicators: urgent items highlighted
  - Queue position badge on work items
  - Reorder capability for managers (override FIFO)
- [ ] **[TEST] PROJ-024C**: FIFO queue renders in order; position badges correct; reorder works

- [ ] **PROJ-024D**: AI pricing recommendations (placeholder):
  - Mock recommendations panel: suggested pricing for client proposals based on historical data
  - Confidence score per recommendation
  - Accept/Reject/Adjust actions
- [ ] **[TEST] PROJ-024D**: Recommendations render with confidence scores; Accept applies pricing

### Definition of Done
- Practice Intelligence dashboard with portfolio performance, AI agent status, revenue trends
- AI agent activity log with pause/resume controls
- FIFO queue visualization with position badges and reorder
- AI pricing recommendations panel (placeholder)

---

## ✅ Task PROJ-025: Final Polish — Projects Module
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** All PROJ tasks above

### Related Files
All project components.

### Subtasks

- [ ] **PROJ-025A**: Skeleton loaders: every TanStack Query loading state uses `Skeleton` component matching content shape (project list rows, Kanban cards, task rows, triage items, detail page sections).
- [ ] **PROJ-025B**: Empty states: every list uses `EmptyState` component with illustration, heading, subtext, and CTA button.
- [ ] **PROJ-025C**: Motion preference: `useMotionPreference()` called in every animated component. Reduced motion replaces springs with instant state changes or very short fades.
- [ ] **PROJ-025D**: Page transitions: `AnimatePresence` wrapping main content with `motion.div` keyed by `location.pathname`.
- [ ] **PROJ-025E**: Focus restoration: after closing any modal/drawer/overlay, focus returns to triggering element (stored ref in Zustand).
- [ ] **PROJ-025F**: Keyboard hints: `<kbd>` tags for common shortcuts visible on hover or in tooltips.
- [ ] **PROJ-025G**: Accessibility audit:
  - All interactive elements keyboard-reachable
  - Focus indicators visible (electric blue, `focus-visible`)
  - Color contrast ≥ 4.5:1 on all text
  - Screen reader announcements for dynamic content
  - `aria-*` attributes on all ARIA-relevant components
- [ ] **PROJ-025H**: Console check: zero errors or warnings in dev console. All `tsc --noEmit` passes.
- [ ] **PROJ-025I**: Build check: `npm run build` completes successfully. All routes render without crashing.
- [ ] **PROJ-025J**: Cross-cutting foundations (PROJ-C01 to PROJ-C10) verified across all project components.

### Definition of Done
- Skeletons on all loading states matching content shape
- Empty states with illustration + CTA on all empty lists
- `useMotionPreference` integrated in all animated components
- Page transitions across project routes
- Focus restoration after modal/drawer/overlay close
- Keyboard hints on hover/tooltip
- Full keyboard accessibility, focus indicators, screen reader support, color contrast
- Zero console errors; `tsc --noEmit` passes; `npm run build` succeeds

---

## 📊 Updated Dependency Graph

```
PROJ-000 (Mock Data + Query Keys + Mutations + Triage + Automations)
     │
PROJ-001 (Zustand projectSlice + triageSlice)
     │
PROJ-002 (Page Layout + Route + View Switcher + Filter Bar + Bulk Create + Export)
     │
     ├─────────────┬──────────────┬──────────────┬─────────────┬─────────────────┐
     │             │              │              │             │                 │
PROJ-003       PROJ-004       PROJ-005       PROJ-006     PROJ-007         PROJ-021
(List View)   (Kanban)      (Timeline)    (My Week)    (Workload)      (Global Search)
     │             │                              │
     │        PROJ-011                             │
     │      (Quick Peek)                           │
     │             │                              │
     └─────────────┴──────────────┬───────────────┘
                                  │
                             PROJ-008
                           (Detail Page)
                                  │
                    ┌─────────────┼─────────────┬──────────────┬────────────────┐
                    │             │             │              │                │
               PROJ-009      PROJ-016     PROJ-022       PROJ-013        PROJ-017
             (Task List)   (Documents)  (Time/Budget)  (Recurring)    (Automations)
                    │
               PROJ-010
             (Task Drawer)
                    │
               PROJ-015
           (External Tasks)

PROJ-012 (Templates) ──→ PROJ-002

PROJ-014 (Saved Views) ──→ PROJ-002

PROJ-018 (Triage Shell) ──→ PROJ-019 (Triage Actions) ──→ PROJ-020 (Triage Integration)

PROJ-023 (Filing Deadlines) ──→ PROJ-008

PROJ-024 (Practice Intelligence) ──→ TASK-006, TASK-007

PROJ-025 (Final Polish) ──→ ALL PROJ tasks
```

---

## 🏁 Projects Module Completion Checklist

**Data & State:**
- [ ] Mock factories for projects, tasks, sections, templates, triage items, automator rules
- [ ] MSW handlers for all CRUD endpoints with query param filtering
- [ ] `projectKeys` factory fully typed including triage, automations, saved views, recurring schedules
- [ ] All mutations: `onMutate → onError rollback → onSettled invalidate`
- [ ] Zustand `projectSlice`: all state, actions, atomic selectors
- [ ] Zustand `triageSlice`: triage filters, selection, delegated view
- [ ] `persist` saves only `activeView` and `sort`

**Page & Navigation:**
- [ ] Routes configured with loader prefetch for projects, project detail, and triage
- [ ] View switcher with animated `layoutId` indicator (5 views)
- [ ] Filter bar with `useTransition` — 6 filter dimensions
- [ ] "New Project" dialog with Zod validation and template linking
- [ ] Bulk Create dialog (up to 100 contacts from template)
- [ ] Export button (CSV download of filtered view)

**List View:**
- [ ] TanStack Table (10 typed columns) + TanStack Virtual
- [ ] Server-side filtering; client-side sort
- [ ] Hover prefetch with 200ms debounce and cancel
- [ ] Inline status editing via Popover; Planned Week column
- [ ] Bulk action bar with `AnimatePresence`; partial failure handling

**Kanban:**
- [ ] `PointerSensor` with `activationConstraint: { distance: 5 }` + `KeyboardSensor`
- [ ] Custom collision detection (`pointerWithin` + `closestCenter` fallback)
- [ ] `DragOverlay` clone with glow/tilt; original at 0.4 opacity
- [ ] Drop indicator animation
- [ ] WCAG 2.5.7: "Move to…" button alternative (single-pointer)
- [ ] No focusable children inside cards; card click opens Quick Peek
- [ ] Plan Work popover for team My Week assignments

**Timeline:**
- [ ] SVAR Gantt with dark theme CSS override
- [ ] Data transformation handles missing dates
- [ ] Zoom controls (Day/Week/Month/Quarter); ephemeral state
- [ ] Drag-to-reschedule with optimistic mutation
- [ ] CSS bar entrance animation with stagger

**My Week:**
- [ ] Six lanes matching Karbon's bucket model with correct assignment logic
- [ ] Colleague's Week dropdown with capacity info and privacy banner
- [ ] Cross-lane drag updates `plannedWeek`/`status` optimistically
- [ ] WCAG 2.5.7: "Move to lane" button alternative
- [ ] Bulk selection with Shift+click
- [ ] Calendar sidebar integration: drag work items to block time
- [ ] In-page search across all lanes

**Workload:**
- [ ] recharts `BarChart` with capacity reference line; over-capacity in red
- [ ] Granularity toggle (Week/2 Weeks/Month)
- [ ] Click bar → filter task list (virtualized)
- [ ] Colleague Utilization summary panel

**Project Detail:**
- [ ] Loading skeleton + error state
- [ ] Inline name editing with Escape-to-cancel
- [ ] Six tabs: URL search params, animated indicator, keyboard nav
- [ ] All header fields editable with optimistic mutations
- [ ] Filing deadline badge with countdown

**Task List:**
- [ ] Sections with collapsible groups, conditional indicators, editable names
- [ ] TanStack Virtual for sections >50 tasks
- [ ] Task rows with checkbox, hover actions, client/conditional badges, ARIA
- [ ] Within-section drag-to-reorder (drag handle activation)
- [ ] Inline "+ Add task" stays open for multiple adds; Shift+Enter for client tasks
- [ ] Inline "+ Add section"

**Task Drawer:**
- [ ] Spring slide-in/out; exit via `AnimatePresence`; focus trap
- [ ] Editable header (title, status, priority, assignee, due date, task type, client toggle)
- [ ] Four tabs: Details, Checklist, Comments, Activity
- [ ] Checklist with completion %, dnd-kit reorder, inline add
- [ ] Comments: `Cmd+Enter` submit, @mention autocomplete, internal/external toggle, optimistic with retry
- [ ] Description: debounced auto-save, file upload

**Quick Peek Overlay:**
- [ ] Spring entrance animation; at-a-glance project summary
- [ ] Task checkboxes work from overlay; "View Full Detail" navigates
- [ ] Uses cached data from hover prefetch; accessible dialog

**Templates:**
- [ ] Six template cards in responsive grid
- [ ] Pre-fills New Project dialog; passes `templateId`
- [ ] Accessible from dialog link and empty state CTA
- [ ] "Save as Template" from existing project

**Recurring Work:**
- [ ] 7-area configuration dialog matching Karbon's repeat settings
- [ ] Zod validation; dynamic naming preview
- [ ] Upcoming instances preview; schedule list with edit/pause/delete

**Saved Views:**
- [ ] Save View dialog; views list with reorder, rename, delete
- [ ] Share via unique URL; URL param applies saved view
- [ ] 3 pre-built default views; localStorage persistence

**External Tasks:**
- [ ] Client task toggle with auto-reminder schedule
- [ ] Reminder count badge; client task sections; comments default to External

**Document Panel:**
- [ ] Folder tree; file upload with drag-and-drop, preview, delete
- [ ] Connected folder placeholder; auto-create for recurring work
- [ ] Document sidebar for quick access

**Automation Engine:**
- [ ] Global automators (6 rules) + tasklist automator rule builder
- [ ] Rules panel grouped by section; trigger simulation with visual feedback
- [ ] Conditional sections (manual + automator-driven)

**Triage Inbox:**
- [ ] Triage page with color-coded stream, virtualized, slide-in animation
- [ ] Action tray: 5 sections (Timeline, My Week, Assignment, Notify Me, Visibility)
- [ ] Comment within email; quick actions (swipe/keyboard); Delegated Triage; Shared Triage
- [ ] Integration with agent outputs, decisions, project assignments, budget alerts, mentions
- [ ] Notification preferences per source type with digest modes

**Global Search:**
- [ ] Cross-entity search dialog; results grouped by type
- [ ] Advanced filters (type, date, status); navigation to entity on click
- [ ] Recent searches; no-results state

**Time & Budget:**
- [ ] Budget panel with progress, member breakdown, task type breakdown
- [ ] Clock in/out + manual time entry; weekly timesheet
- [ ] Task types management; WIP panel

**Filing Deadlines:**
- [ ] Deadlines settings with CRUD and template application
- [ ] Deadline badge with color-coded countdown; extension management; bulk extension

**Practice Intelligence:**
- [ ] Portfolio performance dashboard; AI agent activity log
- [ ] FIFO queue visualization; AI pricing recommendations (placeholder)

**Final Polish:**
- [ ] Skeletons, empty states, `useMotionPreference`, page transitions
- [ ] Focus restoration, keyboard hints, full accessibility audit
- [ ] Zero console errors; build succeeds; all routes render