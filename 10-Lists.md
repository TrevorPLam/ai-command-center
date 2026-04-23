Based on comprehensive research into modern list and note-taking applications (Notion, Todoist, Microsoft To Do, Google Keep, Apple Notes, Obsidian, and Things 3), I have identified the key features, interaction patterns, and technical requirements for a dedicated Lists module. This module serves as a flexible organization system for everything from quick grocery lists to structured project ideas and reading lists.

---

# 10-Lists — Personal AI Command Center Frontend (Enhanced v1)

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.

---

## 🔬 Research Findings — Lists Module

| Finding | Source | Action Required |
|---------|--------|-----------------|
| **Quick capture is essential** — Users abandon apps that require multiple steps to add an item. Leading apps (Google Keep, Apple Notes) support instant entry with smart defaults. | UX Research 2025 | LIST-002: Implement Quick Add with intelligent list detection and one-tap capture. |
| **Hierarchy drives organization** — Flat lists become unmanageable beyond 20 items. Nested/checklist structures (Notion, Workflowy) enable infinite nesting while maintaining scannability. | Notion UX Analysis | LIST-003: Support nested items with indentation UI and keyboard shortcuts (Tab/Shift+Tab). |
| **Multiple view modes are standard** — Users expect to toggle between list, board (Kanban), and grid views for the same data (Notion databases, Todoist boards). | Product Analysis 2025 | LIST-004: Implement view switcher (List/Board/Grid) with state persistence per list. |
| **Smart categorization reduces friction** — Auto-categorization by date, location, or content type (shopping vs ideas) reduces manual organization (Google Keep labels, Apple Notes folders). | AI in Productivity Apps 2026 | LIST-001: Implement list templates with auto-categorization hints based on content. |
| **Offline-first is non-negotiable** — Lists are often accessed in stores, transit, or areas with poor connectivity. Dexie/IndexedDB sync patterns from News module should be reused. | PWA Best Practices 2026 | LIST-006: Implement Dexie-based offline storage with sync queue for list operations. |
| **Collaboration features increase retention** — Shared grocery lists, trip planning, and project tasks drive daily active use (Notion share, Todoist collaboration). | Collaboration UX 2025 | LIST-007: Implement share links with view/edit permissions and real-time sync indicators. |
| **Rich content beyond text** — Checkboxes, images, links, and voice memos are standard expectations (Apple Notes sketching, Google Keep images). | Mobile UX Patterns 2026 | LIST-003: Support multiple content types: text, checkbox, image, link preview, voice. |
| **Template system accelerates usage** — Pre-built templates for groceries, packing, books, movies reduce blank-page anxiety (Notion templates, Todoist projects). | Template UX Research | LIST-001: Create template library with 10+ common list types and custom template builder. |
| **Natural language parsing** — "Buy milk tomorrow" should auto-set due date (Todoist, Microsoft To Do, Things 3 all implement this). | NLP in Task Apps 2026 | LIST-002: Implement natural language due date parsing in Quick Add. |
| **Bulk operations are power-user essential** — Multi-select, drag-to-reorder, and batch actions (delete, move, tag) are expected in mature list apps. | Power User Patterns 2025 | LIST-005: Implement bulk selection mode with action bar for batch operations. |
| **Search and filter are primary navigation** — Heavy users rely on search over browsing; filters by tag, due date, and content type are essential (Obsidian graph, Notion filters). | Information Architecture 2026 | LIST-008: Implement full-text search with filters (tag, date, list type, completed status). |
| **Archive vs Delete** — Users want to clear active lists without losing history ( Todoist archive, Things logbook). | Data Retention UX | LIST-003: Implement archive functionality separate from delete with archive browser. |
| **Drag-and-drop reordering** — Manual sort order is critical for prioritization (Reorder grocery aisles, task priority). | dnd-kit Best Practices | LIST-005: Implement dnd-kit based drag-and-drop for item reordering within and between lists. |
| **Progress indicators motivate** — Visual progress (circle charts, completion percentage) drives continued usage (Streaks, Habit tracking apps). | Behavioral Design 2026 | LIST-004: Implement progress indicators for checkable lists with completion stats. |

---

## 🧱 Cross-Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **LIST-C01** | State Management | Zustand `listsSlice` for active list, view mode, filters, and selection state. URL sync for shareable list links. |
| **LIST-C02** | Data Persistence | Dexie for offline list storage; sync queue for pending mutations. Optimistic updates with rollback. |
| **LIST-C03** | Content Types | Unified content model supporting: text, checkbox, image, link (with preview), voice memo (blob). |
| **LIST-C04** | Hierarchy | Nested items up to 5 levels deep; indentation UI; keyboard navigation (Tab/Shift+Tab/Enter/Backspace). |
| **LIST-C05** | View Modes | List view (default), Board view (Kanban columns by status/tag), Grid view (card-based for media lists). |
| **LIST-C06** | Templates | 10+ built-in templates (Groceries, Books, Movies, Packing, Ideas, Project Tasks, Gift Ideas, Restaurants, Bucket List, Shopping); custom template builder. |
| **LIST-C07** | Quick Capture | Global keyboard shortcut (⌘/Ctrl+Shift+L), mobile quick action, natural language parsing for due dates and categories. |
| **LIST-C08** | Collaboration | Share links with view/edit permissions; real-time presence indicators; conflict resolution for concurrent edits. |
| **LIST-C09** | Search & Filter | Full-text search across all lists; filters by tag, due date, completion status, content type, list category. |
| **LIST-C10** | Bulk Operations | Multi-select mode (Shift+click, Cmd/Ctrl+click); batch actions (delete, move, tag, archive); drag-to-reorder. |
| **LIST-C11** | Accessibility | WCAG 2.2 AA: keyboard navigation, ARIA labels for checkboxes, focus management, reduced-motion support. |
| **LIST-C12** | Motion | Alive tier for item entry/exit, reordering, and view transitions; Quiet tier for checkbox toggles and progress updates. |
| **LIST-C13** | Import/Export | CSV import for bulk list creation; JSON export for backup; Markdown export for notes integration. |

### 🎯 Motion Tier Assignment

| Component | Tier | Allowed Techniques |
|-----------|------|--------------------|
| New item entry | **Alive** | `y: -8→0`, `opacity: 0→1`, spring `stiffness: 300, damping: 30` |
| Item deletion | **Alive** | `x: 0→100%`, `opacity: 1→0`, `height: auto→0` with `AnimatePresence` |
| Drag reorder | **Alive** | `scale: 1.02` + glow shadow on drag; `layout` prop for position morphing |
| Checkbox toggle | **Quiet** | Instant state change; subtle `scale: 0.95→1` spring on click |
| View switch | **Alive** | Cross-fade with `AnimatePresence`; `layoutId` for shared elements |
| Board column drag | **Alive** | Same as PROJ-004 Kanban: `scale: 1.02` + glow, drop indicator animation |
| Progress bar fill | **Alive** | `scaleX: 0→1`, `transformOrigin: 'left'` on load |
| Template selection | **Quiet** | `opacity` fade, `scale: 0.98→1` on hover |
| Bulk action bar | **Alive** | `y: 100%→0` slide-up with `AnimatePresence` |
| Search results | **Static** | Instant render; no animation to prevent jank during typing |

---

## 🗃️ Task LIST-000: Lists Domain Model & Mock Data
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** FND-004 (Testing), FND-006 (TanStack Query)

### Related Files
`src/domain/lists/types.ts` · `src/schemas/listSchema.ts` · `src/mocks/factories/lists.ts` · `src/mocks/handlers/lists.ts` · `src/queries/lists.ts`

### Subtasks

- [ ] **LIST-000A**: Define core domain types in `src/domain/lists/types.ts`:
  ```ts
  export type ListType = 'simple' | 'checklist' | 'kanban' | 'notes' | 'bookmarks'
  export type ListItemContent = 
    | { type: 'text'; text: string }
    | { type: 'checkbox'; text: string; checked: boolean }
    | { type: 'image'; url: string; caption?: string }
    | { type: 'link'; url: string; title: string; preview?: LinkPreview }
    | { type: 'voice'; blobUrl: string; duration: number; transcript?: string }
  
  export interface ListItem {
    id: string
    content: ListItemContent
    parentId: string | null  // For nesting
    order: number            // For manual sort
    createdAt: string
    updatedAt: string
    tags: string[]
    dueDate?: string
    archivedAt?: string
  }
  
  export interface List {
    id: string
    title: string
    type: ListType
    icon: string  // Lucide icon name
    color: string // Theme color
    items: ListItem[]
    templateId?: string
    shareConfig?: { allowEdit: boolean; publicAccess: boolean }
    createdAt: string
    updatedAt: string
  }
  ```

- [ ] **LIST-000B**: Create Zod schemas in `src/schemas/listSchema.ts`:
  - `ListItemContentSchema` discriminated union by `type`
  - `ListItemSchema` with validation for nesting depth (max 5 levels)
  - `ListSchema` with all fields and metadata validation

- [ ] **LIST-000C**: Create `src/mocks/factories/lists.ts` with factories:
  - `createMockList(type, overrides?)` — Generates list with realistic items
  - `createMockListItem(type, overrides?)` — Single item factory
  - `createMockGroceryList()` — Pre-populated with common groceries
  - `createMockBookList()` — Pre-populated with sample books
  - `createMockIdeaList()` — Pre-populated with project ideas
  - `createMockNestedTaskList()` — Deeply nested project tasks

- [ ] **LIST-000D**: Create `src/mocks/handlers/lists.ts` with MSW handlers:
  - `GET /api/lists` — Paginated list overview with item counts
  - `GET /api/lists/:id` — Full list with all items (nested structure)
  - `POST /api/lists` — Create new list (supports templateId)
  - `PATCH /api/lists/:id` — Update list metadata
  - `DELETE /api/lists/:id` — Soft delete (sets deletedAt)
  - `POST /api/lists/:id/items` — Add item to list
  - `PATCH /api/lists/:id/items/:itemId` — Update item content/metadata
  - `DELETE /api/lists/:id/items/:itemId` — Remove item
  - `PATCH /api/lists/:id/items/reorder` — Bulk reorder items
  - `POST /api/lists/:id/items/:itemId/nested` — Add nested child item
  - `GET /api/lists/templates` — Available templates
  - `POST /api/lists/:id/share` — Generate share link
  - `DELETE /api/lists/:id/share` — Revoke share link

- [ ] **LIST-000E**: Create `src/queries/lists.ts` with Query Key Factory:
  ```ts
  export const listKeys = {
    all: ['lists'] as const,
    lists: () => [...listKeys.all, 'overview'] as const,
    list: (id: string) => [...listKeys.all, 'detail', id] as const,
    templates: () => [...listKeys.all, 'templates'] as const,
    search: (query: string) => [...listKeys.all, 'search', query] as const,
  }
  ```

- [ ] **LIST-000F**: Define query options and mutation hooks:
  - `listsQueryOptions()` — Overview with `staleTime: 60_000`
  - `listDetailQueryOptions(id)` — Full list with `staleTime: 30_000`
  - `useCreateList()` — Optimistic create with template support
  - `useUpdateList()` — Optimistic metadata update
  - `useDeleteList()` — Optimistic soft delete
  - `useAddItem()` — Optimistic item append
  - `useUpdateItem()` — Optimistic item update with rollback
  - `useReorderItems()` — Optimistic reorder with rollback
  - `useArchiveItem()` — Soft delete item

### Tests
- [ ] Factory produces valid nested structures up to 5 levels deep
- [ ] MSW handlers maintain in-memory state; mutations persist within session
- [ ] `useReorderItems` optimistically updates order and rolls back on error
- [ ] Query keys are structurally distinct per entity

### Definition of Done
- Full domain model with nested item support
- Mock factories for common list types (groceries, books, ideas, tasks)
- MSW handlers for all CRUD operations
- Query key factory and mutation hooks with optimistic updates

### Anti-Patterns
- ❌ Flattening nested items into separate queries — destroys atomic list operations
- ❌ Storing list content as plain strings — loses rich content type information
- ❌ Missing `parentId` in item model — prevents hierarchical organization
- ❌ Not validating nesting depth — allows infinite recursion

---

## 🔧 Task LIST-001: Lists State Management & Templates
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** FND-005 (Zustand), LIST-000

### Related Files
`src/stores/slices/listsSlice.ts` · `src/data/listTemplates.ts` · `src/hooks/useListTemplates.ts`

### Subtasks

- [ ] **LIST-001A**: Create `src/stores/slices/listsSlice.ts`:
  ```ts
  interface ListsSlice {
    // Active state
    activeListId: string | null
    activeViewMode: 'list' | 'board' | 'grid'
    expandedItemIds: string[]         // `Set` is not serializable; store as array and derive `Set` via `useMemo` where needed
    selectedItemIds: string[]         // `Set` is not serializable; store as array and derive `Set` via `useMemo` where needed
    bulkMode: boolean
    
    // Filters
    searchQuery: string
    filterTags: string[]
    filterDueDate: 'all' | 'today' | 'week' | 'overdue' | null
    filterCompleted: 'all' | 'active' | 'completed'
    
    // UI state
    quickAddOpen: boolean
    templateDrawerOpen: boolean
    shareDialogOpen: boolean
    
    // Actions
    setActiveList: (id: string | null) => void
    setViewMode: (mode: ListsSlice['activeViewMode']) => void
    toggleItemExpanded: (id: string) => void
    toggleItemSelected: (id: string) => void
    selectAllVisible: (ids: string[]) => void
    clearSelection: () => void
    setBulkMode: (enabled: boolean) => void
    setSearchQuery: (q: string) => void
    setFilters: (filters: Partial<Pick<ListsSlice, 'filterTags' | 'filterDueDate' | 'filterCompleted'>>) => void
    clearFilters: () => void
    openQuickAdd: () => void
    closeQuickAdd: () => void
    openTemplateDrawer: () => void
    closeTemplateDrawer: () => void
  }
  ```

- [ ] **LIST-001B**: Export atomic selectors:
  - `useActiveList()`, `useViewMode()`, `useListFilters()`, `useBulkSelection()`, `useQuickAddState()`

- [ ] **LIST-001C**: Create `src/data/listTemplates.ts` with built-in templates:
  ```ts
  export const BUILT_IN_TEMPLATES = [
    { id: 'groceries', name: 'Grocery List', icon: 'ShoppingCart', type: 'checklist', defaultItems: ['Milk', 'Bread', 'Eggs', 'Vegetables', 'Fruit'] },
    { id: 'books', name: 'Books to Read', icon: 'BookOpen', type: 'simple', defaultItems: ['The Design of Everyday Things', 'Atomic Habits'] },
    { id: 'movies', name: 'Movies to Watch', icon: 'Film', type: 'simple', defaultItems: [] },
    { id: 'packing', name: 'Packing List', icon: 'Luggage', type: 'checklist', defaultItems: ['Toothbrush', 'Charger', 'Passport', 'Medications'] },
    { id: 'ideas', name: 'Project Ideas', icon: 'Lightbulb', type: 'notes', defaultItems: [] },
    { id: 'tasks', name: 'Project Tasks', icon: 'CheckSquare', type: 'checklist', defaultItems: ['Research', 'Design', 'Development', 'Testing'] },
    { id: 'gift-ideas', name: 'Gift Ideas', icon: 'Gift', type: 'simple', defaultItems: [] },
    { id: 'restaurants', name: 'Restaurants to Try', icon: 'Utensils', type: 'bookmarks', defaultItems: [] },
    { id: 'bucket-list', name: 'Bucket List', icon: 'Mountain', type: 'checklist', defaultItems: [] },
    { id: 'shopping', name: 'Shopping List', icon: 'ShoppingBag', type: 'checklist', defaultItems: [] },
  ] as const
  ```

- [ ] **LIST-001D**: Create `useListTemplates()` hook:
  - Returns built-in + user-created templates
  - `createCustomTemplate(list)` mutation
  - `deleteCustomTemplate(id)` mutation

- [ ] **LIST-001E**: Persist view mode per list to `localStorage`:
  - Each list remembers user's preferred view mode
  - Use `partialize` to store only view preferences

### Tests
- [ ] State updates correctly for all actions
- [ ] Atomic selectors prevent unnecessary re-renders
- [ ] Template data loads and creates lists with correct default items
- [ ] View mode persists across page reloads

### Definition of Done
- Complete lists slice with filter and selection state
- 10 built-in templates with appropriate default items
- Custom template creation supported
- View mode persistence per list

### Anti-Patterns
- ❌ Persisting full list content to Zustand — use Dexie for content, Zustand for UI state only
- ❌ Not using atomic selectors — causes re-renders on every list change
- ❌ Hardcoding templates without user customization

---

## 📋 Task LIST-002: Lists Page Layout & Quick Capture
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** FND-007 (Router), LIST-001

### Related Files
`src/pages/ListsPage.tsx` · `src/components/lists/ListsLayout.tsx` · `src/components/lists/QuickAddModal.tsx` · `src/components/lists/ListSidebar.tsx` · `src/router/routes.ts`

### Subtasks

- [ ] **LIST-002A**: Configure `/lists` route in `src/router/routes.ts`:
  ```ts
  {
    path: 'lists',
    lazy: () => import('@/pages/ListsPage'),
    loader: () => queryClient.ensureQueryData(listsQueryOptions()),
  },
  {
    path: 'lists/:listId',
    lazy: () => import('@/pages/ListsPage'),
    loader: ({ params }) => queryClient.ensureQueryData(listDetailQueryOptions(params.listId!)),
  }
  ```

- [ ] **LIST-002B**: Create `src/pages/ListsPage.tsx` with three-column layout:
  - Left sidebar (280px): List navigation, search, "New List" button
  - Center content (flex-1): Active list with view switcher and items
  - Right panel (320px, collapsible): Item details, tags, due date (when item selected)

- [ ] **LIST-002C**: Implement global keyboard shortcut:
  - `⌘/Ctrl+Shift+L` opens Quick Add from anywhere in app
  - Uses command palette pattern from Dashboard

- [ ] **LIST-002D**: Build `QuickAddModal` component:
  - Single input with natural language parsing
  - Detects list type from keywords: "buy" → groceries, "read" → books, "watch" → movies
  - Parses due dates: "Buy milk tomorrow", "Call mom Friday 3pm"
  - Smart defaults: Adds to most recently used list of detected type
  - One-tap submission with `Enter`

- [ ] **LIST-002E**: Build `ListSidebar` component:
  - Search input for filtering lists by title
  - List of user's lists with item count badges
  - "New List" button opens template drawer
  - Drag-to-reorder lists (dnd-kit)
  - Collapses to icon-only on narrow screens

- [ ] **LIST-002F**: Build `TemplateDrawer` component:
  - Slides from right (same as other drawers in app)
  - Grid of template cards with icon, name, preview
  - "Create from Template" action
  - "Blank List" option at top

- [ ] **LIST-002G**: Add view mode switcher in list header:
  - Three icon buttons: List, Board, Grid
  - Active state with `layoutId` animated indicator
  - Persisted per list in Zustand + localStorage

- [ ] **LIST-002H**: Implement `useNaturalLanguageParse()` hook:
  - Parses text for due dates ("tomorrow", "next week", "Friday")
  - Detects list category from keywords
  - Returns `{ text: string, dueDate?: Date, suggestedListType?: ListType }`

### Tests
- [ ] Route renders with correct layout; list ID from URL loads correct list
- [ ] Keyboard shortcut opens Quick Add modal
- [ ] Natural language parser correctly extracts due dates
- [ ] Template drawer opens and creates lists with correct items
- [ ] View mode switcher updates and persists

### Definition of Done
- Lists page with three-column responsive layout
- Global Quick Add shortcut with NLP parsing
- Template drawer with 10+ templates
- View mode switcher (List/Board/Grid)
- Sidebar with search and list navigation

### Anti-Patterns
- ❌ Opening Quick Add via menu navigation only — requires keyboard shortcut for power users
- ❌ Not persisting view mode — users expect their preference to stick
- ❌ Ignoring natural language — forces manual date entry

---

## 📝 Task LIST-003: List Items & Content Types
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** LIST-002, LIST-000

### Related Files
`src/components/lists/ListItem.tsx` · `src/components/lists/ListItemContent.tsx` · `src/components/lists/NestedItemTree.tsx` · `src/components/lists/ItemToolbar.tsx`

### Subtasks

- [ ] **LIST-003A**: Build `ListItemContent` component supporting all content types:
  - **Text**: Simple text with inline editing on double-click
  - **Checkbox**: Checkbox + text with line-through when checked
  - **Image**: Thumbnail with lightbox expand; caption below
  - **Link**: URL with automatic preview (title, favicon, description)
  - **Voice**: Play button with waveform visualization, transcript below

- [ ] **LIST-003B**: Build `ListItem` wrapper component:
  - Drag handle (six dots) on left for reordering
  - Hover reveals `ItemToolbar` (add sub-item, delete, move, tag)
  - Indentation visual (4px per level, max 5 levels)
  - Selection checkbox in bulk mode
  - `layoutId` for smooth reordering animations

- [ ] **LIST-003C**: Implement nested item hierarchy:
  - `NestedItemTree` component recursively renders children
  - Expand/collapse chevron for items with children
  - Indentation guides (subtle vertical lines)
  - Keyboard shortcuts: `Tab` indent, `Shift+Tab` outdent, `Enter` new sibling, `Backspace` at start to outdent/delete

- [ ] **LIST-003D**: Build `ItemToolbar` component:
  - "Add sub-item" button (creates nested child)
  - "Add below" button (creates sibling)
  - Tag selector (add/remove tags)
  - Due date picker
  - Move to another list (dropdown)
  - Archive button
  - Delete button (with confirmation)

- [ ] **LIST-003E**: Implement inline editing:
  - Double-click or `Enter` on selected item enters edit mode
  - `Escape` cancels, `Enter` saves
  - Auto-resize textarea for multi-line text
  - Rich text toolbar (bold, italic, link) for notes type

- [ ] **LIST-003F**: Build `ContentTypeSwitcher`:
  - Dropdown to change item type (text ↔ checkbox ↔ image, etc.)
  - Preserves content when possible (text → checkbox keeps text)
  - Handles type-specific options (image upload, link URL)

- [ ] **LIST-003G**: Implement archive functionality:
  - Archived items hidden by default
  - "Show archived" toggle in list settings
  - Archive browser modal for viewing/restoring archived items

### Tests
- [ ] All content types render correctly with sample data
- [ ] Nested items display with correct indentation
- [ ] Keyboard shortcuts (Tab, Shift+Tab, Enter, Backspace) work as expected
- [ ] Inline editing saves on Enter, cancels on Escape
- [ ] Content type switcher preserves data appropriately
- [ ] Archive/unarchive flow works with UI updates

### Definition of Done
- All 5 content types (text, checkbox, image, link, voice) supported
- Nested hierarchy with visual indentation and keyboard controls
- Inline editing with rich text support for notes
- Item toolbar with all actions
- Archive system with browser

### Anti-Patterns
- ❌ Not supporting nesting — flat lists don't scale for complex organization
- ❌ Content type changes losing data — always preserve or transform intelligently
- ❌ Missing keyboard controls — power users rely on keyboard navigation

---

## 🎨 Task LIST-004: View Modes (List/Board/Grid)
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** LIST-003

### Related Files
`src/components/lists/views/ListView.tsx` · `src/components/lists/views/BoardView.tsx` · `src/components/lists/views/GridView.tsx` · `src/components/lists/ViewSwitcher.tsx`

### Subtasks

- [ ] **LIST-004A**: Build `ListView` (default):
  - Vertical stack of items with nested indentation
  - Smooth reordering via dnd-kit `SortableContext`
  - Collapsible nested sections
  - Progress bar at top showing completion % (for checklists)

- [ ] **LIST-004B**: Build `BoardView` (Kanban-style):
  - Columns based on item status or tags
  - Default columns: "To Do", "In Progress", "Done" (or tag-based)
  - Drag items between columns updates status/tag
  - Column add/remove UI
  - Uses same dnd-kit sensors as Projects Kanban (PROJ-004)
  - `DragOverlay` with glow effect during drag

- [ ] **LIST-004C**: Build `GridView` (media-focused):
  - Card-based layout for image-heavy lists (books, movies, restaurants)
  - Larger thumbnails with title overlay
  - Masonry-style layout (or uniform grid)
  - Click to expand details in modal
  - Best for bookmarks and media lists

- [ ] **LIST-004D**: Implement view-specific state:
  - Board view column configuration persisted per list
  - Grid view sort order (by title, date, custom)
  - All views share same underlying item data (no duplication)

- [ ] **LIST-004E**: Add view transition animation:
  - `AnimatePresence` mode="wait" for view switches
  - Cross-fade with subtle scale (0.98 → 1)
  - Duration: 150ms (Quiet tier)

- [ ] **LIST-004F**: Build `ProgressIndicator` component:
  - Circular progress for mobile
  - Linear progress bar for desktop list view
  - Shows "X of Y completed" text
  - Celebratory animation when 100% reached (confetti or checkmark pulse)

### Tests
- [ ] List view renders nested items correctly
- [ ] Board view allows drag between columns with state update
- [ ] Grid view displays cards in responsive grid
- [ ] View switcher transitions smoothly
- [ ] Progress indicator updates when checkboxes toggled

### Definition of Done
- Three functional view modes with unique layouts
- Drag-and-drop reordering in List view
- Drag-between-columns in Board view
- Responsive grid in Grid view
- Progress indicators for checkable lists
- Smooth view transitions

### Anti-Patterns
- ❌ Duplicating item data per view — use shared data with view-specific rendering
- ❌ Not persisting column config in Board view — users lose customization
- ❌ Missing progress indication — users need feedback on completion

---

## 🔀 Task LIST-005: Drag, Drop & Bulk Operations
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** LIST-004

### Related Files
`src/components/lists/SortableListItem.tsx` · `src/components/lists/BulkActionBar.tsx` · `src/hooks/useListDnd.ts`

### Subtasks

- [ ] **LIST-005A**: Implement dnd-kit integration for list items:
  - `useSensors` with `PointerSensor` (distance: 5px) + `KeyboardSensor`
  - `SortableContext` with `vertical` strategy for List view
  - `DragOverlay` rendering clone with `scale: 1.02` + electric blue glow
  - Original item at `opacity: 0.4` during drag
  > **⚠️ LayoutGroup Requirement:** Wrap drag-and-drop views in `<LayoutGroup id="lists-dnd">` to namespace all `layoutId` values used for smooth reordering animations. `layoutId` is global across the site; without namespacing, multiple list instances or other components using the same `layoutId` values will collide. See FND-013K for the full audit procedure.

- [ ] **LIST-005B**: Implement cross-list drag:
  - Drag item from one list to another in sidebar
  - Drop indicator on list items in sidebar
  - Confirmation toast: "Moved 'Buy milk' to Shopping List"

- [ ] **LIST-005C**: Build bulk selection mode:
  - Checkbox appears on each item when `bulkMode: true`
  - `Shift+click` selects range
  - `Cmd/Ctrl+click` toggles individual items
  - "Select all visible" button
  - Bulk action bar slides up from bottom (`AnimatePresence`)

- [ ] **LIST-005D**: Build `BulkActionBar` component:
  - Actions: Delete, Archive, Move to List, Add Tag, Set Due Date
  - Shows count: "3 items selected"
  - "Clear selection" button
  - Execute actions on all selected items simultaneously

- [ ] **LIST-005E**: Implement optimistic bulk operations:
  - Immediate UI update showing action in progress
  - Rollback on error with toast notification
  - Partial failure handling (some items succeed, some fail)

- [ ] **LIST-005F**: Add keyboard shortcuts for bulk mode:
  - `Esc` exits bulk mode
  - `Space` toggles checkbox on focused item
  - `a` selects all (when in bulk mode)

### Tests
- [ ] Drag-and-drop reordering updates order optimistically
- [ ] Cross-list drag moves item between lists
- [ ] Bulk selection with Shift+click selects range
- [ ] Bulk action bar appears with correct item count
- [ ] Bulk operations update all selected items

### Definition of Done
- Smooth drag-and-drop within and between lists
- Bulk selection mode with range selection
- Bulk action bar with common operations
- Optimistic updates with rollback
- Keyboard shortcuts for power users

### Anti-Patterns
- ❌ No visual feedback during drag — use DragOverlay and opacity changes
- ❌ Missing bulk mode — forces repetitive single-item operations
- ❌ Not handling partial failures in bulk operations

---

## 🌐 Task LIST-006: Offline Support & Data Sync
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** LIST-000, LIST-001

### Related Files
`src/lib/db/lists.ts` · `src/hooks/useOfflineLists.ts` · `src/components/lists/OfflineStatusBar.tsx`

### Subtasks

- [ ] **LIST-006A**: Create `src/lib/db/lists.ts` extending Dexie:
  ```ts
  interface ListDB extends Dexie {
    lists: Table<List, string>
    items: Table<ListItem, string>
    pendingMutations: Table<PendingMutation, string>
  }
  
  interface PendingMutation {
    id: string
    type: 'create' | 'update' | 'delete'
    entity: 'list' | 'item'
    data: unknown
    timestamp: number
    retryCount: number
  }
  ```

- [ ] **LIST-006B**: Implement `useOfflineLists()` hook:
  - Reads lists from Dexie when offline
  - Writes to Dexie immediately on all operations
  - Queues mutations in `pendingMutations` table
  - Syncs queue when connection restored

- [ ] **LIST-006C**: Create sync engine:
  - Process pending mutations in order (FIFO)
  - Handle conflicts (last-write-wins with timestamp check)
  - Retry failed mutations with exponential backoff
  - Mark failed mutations for manual review after 3 retries

- [ ] **LIST-006D**: Build `OfflineStatusBar` component:
  - Shows offline state when `navigator.onLine === false`
  - Shows pending mutation count when online but queue not empty
  - "Sync now" button for manual sync
  - Last sync timestamp display

- [ ] **LIST-006E**: Implement optimistic offline updates:
  - UI updates immediately regardless of connection
  - Background sync handles server persistence
  - Visual indicator (subtle) for "pending sync" items

- [ ] **LIST-006F**: Handle conflict resolution UI:
  - Modal when server version differs from local on sync
  - Options: Keep mine, Keep theirs, Merge manually
  - Applies to list metadata and item content

### Tests
- [ ] Lists load from Dexie when offline
- [ ] Mutations queued correctly when offline
- [ ] Sync processes queue when connection restored
- [ ] Conflict resolution modal appears on divergent sync
- [ ] Offline status bar shows correct state

### Definition of Done
- Full offline support with Dexie persistence
- Mutation queue with retry logic
- Automatic sync on reconnection
- Conflict resolution UI
- Visual indicators for sync status

### Anti-Patterns
- ❌ Not queueing mutations offline — loses user data
- ❌ Silent conflict resolution — may surprise users
- ❌ No visual indication of sync status — users unsure if changes saved

---

## 👥 Task LIST-007: Sharing & Collaboration
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** LIST-006

### Related Files
`src/components/lists/ShareDialog.tsx` · `src/components/lists/CollaborationIndicators.tsx` · `src/hooks/useListSharing.ts`

### Subtasks

- [ ] **LIST-007A**: Build `ShareDialog` component:
  - Toggle: "Share with others"
  - Permission level: "Can view" / "Can edit"
  - Generate shareable link with token
  - Copy link button with confirmation
  - "Revoke access" button
  - List of active collaborators (mock for now)

- [ ] **LIST-007B**: Implement `useListSharing()` hook:
  - `generateShareLink(listId, permission)` mutation
  - `revokeShareLink(listId)` mutation
  - `updateSharePermission(listId, newPermission)` mutation

- [ ] **LIST-007C**: Build `CollaborationIndicators`:
  - Real-time presence indicators (mock: "2 people viewing")
  - Last edited timestamp and by whom
  - Live cursor indicators (stretch: WebSocket)
  - Sync indicators when remote changes arrive

- [ ] **LIST-007D**: Handle concurrent edit scenarios:
  - If remote item modified while local editing: show conflict toast
  - Auto-refresh list when remote changes detected
  - Visual indicator for "new remote changes" with refresh button

- [ ] **LIST-007E**: Implement permissions UI:
  - View-only mode: hide add/edit/delete controls
  - Edit mode: full functionality
  - Owner badge for list creator

- [ ] **LIST-007F**: Add share to specific integrations:
  - Share to Slack (mock OAuth)
  - Share to Email (mailto: link with list content)
  - Export as message/copy to clipboard

### Tests
- [ ] Share dialog generates link with correct permissions
- [ ] View-only mode hides editing controls
- [ ] Revoke share link updates UI
- [ ] Concurrent edit detection shows conflict indicator

### Definition of Done
- Share links with view/edit permissions
- Collaboration indicators (presence, last edit)
- Permission-based UI adaptation
- Concurrent edit handling
- Integration share options

### Anti-Patterns
- ❌ No permission differentiation — all shared links have full edit
- ❌ Missing concurrent edit handling — causes data loss
- ❌ No indication of other users — users unaware of shared status

---

## 🔍 Task LIST-008: Search & Advanced Filtering
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** LIST-002

### Related Files
`src/components/lists/SearchBar.tsx` · `src/components/lists/FilterPanel.tsx` · `src/hooks/useListSearch.ts`

### Subtasks

- [ ] **LIST-008A**: Implement `useListSearch()` hook:
  - Full-text search across all list titles and item content
  - Fuzzy matching for typos (fuse.js or similar)
  - Debounced search (300ms)
  - Results grouped by list with match highlights

- [ ] **LIST-008B**: Build `SearchBar` component:
  - Prominent search input in list sidebar
  - Clear button (X) when query present
  - Search icon
  - Keyboard shortcut `/` focuses search
  - Shows recent searches dropdown

- [ ] **LIST-008C**: Build `FilterPanel` component:
  - Tag filter: Checkboxes for all tags used in list
  - Due date filter: Today, This week, Overdue, No date, Custom range
  - Completion filter: All, Active, Completed, Archived
  - Content type filter: Text, Checkbox, Image, Link, Voice
  - "Clear all filters" button
  - Active filter count badge

- [ ] **LIST-008D**: Implement filter persistence:
  - URL query params for shareable filtered views
  - `?tags=groceries,urgent&due=today&completed=active`
  - Filters persist per list in Zustand (not localStorage)

- [ ] **LIST-008E**: Add search result highlighting:
  - Match text wrapped in `<mark>` element
  - Snippet view showing match context
  - Jump to item when clicked

- [ ] **LIST-008F**: Implement saved searches (stretch):
  - Save current filter combo as named view
  - Quick access to saved filters
  - "My frequent items" auto-generated filter

### Tests
- [ ] Search returns results across all lists
- [ ] Fuzzy matching handles typos
- [ ] Filter panel updates item visibility
- [ ] URL sync updates when filters change
- [ ] Search highlights matching text

### Definition of Done
- Full-text search with fuzzy matching
- Filter panel with all filter dimensions
- URL sync for shareable filtered views
- Search result highlighting
- Clear all filters action

### Anti-Patterns
- ❌ Search blocking UI — use debounce and loading state
- ❌ Filters not in URL — prevents sharing specific views
- ❌ No highlight of matches — users can't see why result matched

---

## ⏰ Task LIST-009: Reminders System
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** LIST-003

### Related Files
`src/components/lists/ReminderPicker.tsx` · `src/hooks/useReminders.ts` · `src/lib/notifications.ts`

### Subtasks

- [ ] **LIST-009A**: Extend domain model for reminders:
  ```ts
  export interface Reminder {
    id: string
    itemId: string
    type: 'due-date' | 'location' | 'custom'
    dueAt?: string
    location?: { lat: number; lng: number; radius: number; name: string }
    repeat?: 'none' | 'daily' | 'weekly' | 'monthly'
    completed: boolean
  }
  ```

- [ ] **LIST-009B**: Build `ReminderPicker` component:
  - Due date picker with time selection
  - Location picker with map integration (mock)
  - Repeat interval selector
  - "No reminder" option

- [ ] **LIST-009C**: Implement `useReminders()` hook:
  - Request notification permissions
  - Schedule browser notifications for due date reminders
  - Check location permissions for geofencing (mock)
  - Mark reminders as completed when item checked

- [ ] **LIST-009D**: Build notification system:
  - Browser notification API integration
  - In-app notification toast
  - Notification history panel
  - Snooze functionality (5min, 15min, 1hr, tomorrow)

- [ ] **LIST-009E**: Add reminder indicators:
  - Bell icon on items with reminders
  - Due time badge on list items
  - "Remind me" quick action in item toolbar

### Tests
- [ ] Due date reminder triggers notification at correct time
- [ ] Location reminder (mock) shows when entering geofence
- [ ] Notification permissions requested on first use
- [ ] Snooze functionality reschedules notification

### Definition of Done
- Due date reminders with browser notifications
- Location-based reminders (mock implementation)
- Repeat interval support
- Notification history and snooze
- Visual indicators for items with reminders

### Anti-Patterns
- ❌ Not requesting notification permissions — reminders won't work
- ❌ Silent notifications — users miss important alerts
- ❌ No snooze option — forces rigid timing

---

## 🔄 Task LIST-010: Recurring Tasks
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** LIST-009

### Related Files
`src/components/lists/RecurrencePicker.tsx` · `src/lib/recurrence.ts` · `src/hooks/useRecurringTasks.ts`

### Subtasks

- [ ] **LIST-010A**: Extend domain model for recurrence:
  ```ts
  export interface RecurrenceRule {
    frequency: 'daily' | 'weekly' | 'monthly' | 'yearly' | 'custom'
    interval: number  // e.g., every 2 weeks
    daysOfWeek?: number[]  // [0,2,4] for Mon, Wed, Fri
    dayOfMonth?: number  // 15th of each month
    endDate?: string
    count?: number  // Occurrences limit
  }
  ```

- [ ] **LIST-010B**: Build `RecurrencePicker` component:
  - Preset buttons: Daily, Weekly, Monthly, Yearly
  - Custom interval input (every X days/weeks)
  - Day selector for weekly recurrence
  - End date or occurrence limit option

- [ ] **LIST-010C**: Implement recurrence engine:
  - Calculate next occurrence based on rule
  - Handle edge cases (leap years, month boundaries)
  - Generate next N occurrences for preview
  - Stop at end date or occurrence limit

- [ ] **LIST-010D**: Implement auto-generation:
  - When recurring item completed, generate next instance
  - Preserve original recurrence rule on new instance
  - Link instances to original recurring task
  - Show "Repeats every X" indicator

- [ ] **LIST-010E**: Add recurrence management:
  - Edit recurrence rule on existing tasks
  - "Delete this and all future" option
  - "Delete only this instance" option
  - Pause/resume recurrence

### Tests
- [ ] Daily recurrence generates next day correctly
- [ ] Weekly recurrence respects selected days
- [ ] Monthly recurrence handles month boundaries
- [ ] Completion generates next instance
- [ ] Delete options work correctly

### Definition of Done
- Full recurrence rule support (daily, weekly, monthly, yearly, custom)
- Recurrence picker with presets and custom options
- Auto-generation of next instance on completion
- Edit and delete options for recurring tasks
- Visual indicators for recurring items

### Anti-Patterns
- ❌ Not handling month boundaries — breaks monthly recurrence
- ❌ No way to delete single instance — forces all-or-nothing
- ❌ Losing recurrence rule on new instance — breaks chain

---

## 🎯 Task LIST-011: Priority Levels
**Priority:** 🟠 Medium | **Est. Effort:** 1.5 hours | **Depends On:** LIST-003

### Related Files
`src/components/lists/PriorityPicker.tsx` · `src/components/lists/PriorityBadge.tsx` · `src/stores/slices/listsSlice.ts`

### Subtasks

- [ ] **LIST-011A**: Extend domain model for priority:
  ```ts
  export type Priority = 'none' | 'low' | 'medium' | 'high' | 'urgent'
  
  export interface ListItem {
    // ... existing fields
    priority: Priority
  }
  ```

- [ ] **LIST-011B**: Build `PriorityPicker` component:
  - 5 priority levels with color coding
  - Keyboard shortcut (1-5) for quick assignment
  - Dropdown in item toolbar
  - Priority legend in list header

- [ ] **LIST-011C**: Build `PriorityBadge` component:
  - Color-coded badges: none (gray), low (blue), medium (yellow), high (orange), urgent (red)
  - Small badge on list items
  - Sort by priority option
  - Filter by priority option

- [ ] **LIST-011D**: Add priority to sorting:
  - Sort by priority in FilterPanel
  - Urgent items at top, then high, medium, low, none
  - Secondary sort by due date within same priority
  - Persist sort preference per list

- [ ] **LIST-011E**: Add priority shortcuts:
  - `Ctrl+1` through `Ctrl+5` set priority
  - Show priority in keyboard shortcut hints
  - Priority indicator in Quick Add modal

### Tests
- [ ] Priority picker sets correct value
- [ ] Priority badges display with correct colors
- [ ] Sort by priority orders items correctly
- [ ] Keyboard shortcuts set priority
- [ ] Filter by priority shows correct items

### Definition of Done
- 5 priority levels with color coding
- Priority picker with keyboard shortcuts
- Visual priority badges on items
- Sort and filter by priority
- Priority persistence per list

### Anti-Patterns
- ❌ Too many priority levels — causes decision paralysis
- ❌ No visual distinction — users can't quickly identify urgent items
- ❌ Not supporting sort by priority — reduces utility

---

## 📅 Task LIST-012: Calendar Integration
**Priority:** 🟠 Medium | **Est. Effort:** 2.5 hours | **Depends On:** LIST-009

### Related Files
`src/components/lists/CalendarView.tsx` · `src/lib/calendarSync.ts` · `src/hooks/useCalendarIntegration.ts`

### Subtasks

- [ ] **LIST-012A**: Build `CalendarView` component:
  - Month/week/day views
  - Tasks displayed on due dates
  - Drag tasks to reschedule
  - Calendar event indicators

- [ ] **LIST-012B**: Implement calendar sync (mock):
  - Two-way sync with external calendars (Google, Apple, Outlook)
  - Create calendar events from tasks with due dates
  - Import calendar events as tasks
  - Conflict resolution (task vs event)

- [ ] **LIST-012C**: Add calendar integration settings:
  - Connect external calendar accounts (mock OAuth)
  - Select which calendars to sync
  - Sync frequency settings
  - Sync conflict preferences

- [ ] **LIST-012D**: Implement task-to-event conversion:
  - "Add to calendar" action in item toolbar
  - Select calendar for event
  - Map task fields to event fields
  - Link event back to task

- [ ] **LIST-012E**: Add event-to-task conversion:
  - "Create task from event" in calendar view
  - Preserve event details in task
  - Link task to original event
  - Bidirectional sync indicator

### Tests
- [ ] Calendar view displays tasks on correct dates
- [ ] Drag to reschedule updates task due date
- [ ] Task-to-event conversion creates calendar event
- [ ] Event-to-task conversion creates task
- [ ] Sync conflicts handled correctly

### Definition of Done
- Calendar view with month/week/day
- Two-way sync with external calendars (mock)
- Task-to-event and event-to-task conversion
- Calendar integration settings
- Conflict resolution for sync

### Anti-Patterns
- ❌ One-way sync only — creates duplicate work
- ❌ No conflict resolution — data loss risk
- ❌ Not handling time zones — incorrect event times

---

## 📍 Task LIST-013: Location-Based Reminders
**Priority:** 🟢 Low | **Est. Effort:** 2 hours | **Depends On:** LIST-009

### Related Files
`src/components/lists/LocationPicker.tsx` · `src/lib/geofencing.ts` · `src/hooks/useLocationReminders.ts`

### Subtasks

- [ ] **LIST-013A**: Build `LocationPicker` component:
  - Map interface for location selection
  - Search for places (Google Places API mock)
  - Radius slider (100m - 5km)
  - Saved locations (Home, Work, Grocery Store)

- [ ] **LIST-013B**: Implement geofencing (mock):
  - Request location permissions
  - Monitor user position (Geolocation API)
  - Check entry/exit of geofences
  - Trigger notification on geofence entry

- [ ] **LIST-013C**: Add location reminder UI:
  - "Remind me when I arrive at..." option
  - "Remind me when I leave..." option
  - Location icon on items with location reminders
  - Location badge with distance (when nearby)

- [ ] **LIST-013D**: Implement location services:
  - Background location monitoring (mock)
  - Battery-efficient polling
  - Fallback to approximate location
  - Error handling for denied permissions

- [ ] **LIST-013E**: Add location management:
  - Save frequently used locations
  - Edit existing location reminders
  - Bulk update location for multiple items
  - Location reminder history

### Tests
- [ ] Location picker saves coordinates and radius
- [ ] Geofence triggers notification on entry
- [ ] Location reminder shows on item
- [ ] Saved locations persist
- [ ] Permission denied handled gracefully

### Definition of Done
- Location picker with map and search
- Geofencing with entry/exit detection (mock)
- Location reminder UI with arrive/leave options
- Saved locations management
- Permission handling

### Anti-Patterns
- ❌ No radius control — triggers too early/late
- ❌ No arrive/leave distinction — limits use cases
- ❌ Not handling permission denial — breaks feature silently

---

## 📱 Task LIST-014: Widget Support
**Priority:** 🟢 Low | **Est. Effort:** 2 hours | **Depends On:** LIST-002

### Related Files
`src/components/widgets/ListWidget.tsx` · `src/lib/widget.ts` · `src/hooks/useWidget.ts`

### Subtasks

- [ ] **LIST-014A**: Build `ListWidget` component:
  - Compact view of single list
  - Quick add input
  - Check/uncheck items
  - "Open in app" button

- [ ] **LIST-014B**: Implement widget API (mock):
  - Register widget with system
  - Update widget content on data changes
  - Handle widget clicks to open app
  - Widget configuration (list selection, theme)

- [ ] **LIST-014C**: Add widget settings:
  - Select which list to display
  - Widget size options (small, medium, large)
  - Show/hide completed items
  - Theme selection (light/dark)

- [ ] **LIST-014D**: Implement widget interactions:
  - Quick add from widget
  - Toggle checkbox from widget
  - Sync widget state with app
  - Refresh widget on data changes

- [ ] **LIST-014E**: Add multiple widget types:
  - Today's tasks widget
  - Quick capture widget
  - Progress widget (completion %)
  - Upcoming reminders widget

### Tests
- [ ] Widget displays selected list
- [ ] Quick add from widget updates app
- [ ] Checkbox toggle syncs with app
- [ ] Widget settings persist
- [ ] Multiple widget types render correctly

### Definition of Done
- List widget with quick add and checkbox
- Widget API integration (mock)
- Widget configuration settings
- Multiple widget types
- Sync between widget and app

### Anti-Patterns
- ❌ No quick add from widget — reduces utility
- ❌ Widget not syncing — shows stale data
- ❌ Limited widget customization — poor UX

---

## 📧 Task LIST-015: Email-to-Task Conversion
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** LIST-002

### Related Files
`src/lib/emailParser.ts` · `src/components/lists/EmailImportModal.tsx` · `src/hooks/useEmailImport.ts`

### Subtasks

- [ ] **LIST-015A**: Build email parser:
  - Parse email subject as task title
  - Extract body as task description
  - Detect due dates from email content
  - Extract attachments for file support

- [ ] **LIST-015B**: Build `EmailImportModal` component:
  - Paste email content
  - Parse and preview task
  - Edit parsed fields before import
  - Select target list

- [ ] **LIST-015C**: Implement email integration (mock):
  - Generate unique email address per list
  - Monitor inbox for new emails
  - Auto-create tasks from emails
  - Reply with confirmation

- [ ] **LIST-015D**: Add email-to-task UI:
  - "Import email" button in Quick Add
  - Email import from share menu (mobile)
  - Bulk email import
  - Email import history

- [ ] **LIST-015E**: Handle email attachments:
  - Attach files to task from email
  - Show attachment count
  - Download attachments from task
  - Attachment preview

### Tests
- [ ] Email parser extracts title and body correctly
- [ ] Due dates detected from email content
- [ ] Import modal shows preview
- [ ] Auto-import creates tasks
- [ ] Attachments preserved

### Definition of Done
- Email parser with title, body, due date extraction
- Email import modal with preview
- Auto-import from unique email address (mock)
- Email attachment support
- Email import history

### Anti-Patterns
- ❌ No preview before import — creates bad tasks
- [ ] Not handling attachments — loses data
- ❌ No way to select target list — creates clutter

---

## ↩️ Task LIST-016: Undo/Redo Functionality
**Priority:** 🟠 Medium | **Est. Effort:** 1.5 hours | **Depends On:** LIST-001

### Related Files
`src/stores/slices/listsSlice.ts` · `src/lib/undoRedo.ts` · `src/components/lists/UndoToast.tsx`

### Subtasks

- [ ] **LIST-016A**: Implement undo/redo stack:
  ```ts
  interface HistoryEntry {
    action: string
    timestamp: number
    state: Partial<ListsSlice>
  }
  ```

- [ ] **LIST-016B**: Add undo/redo to lists slice:
  - Push state to stack on mutations
  - Undo restores previous state
  - Redo reapplies undone action
  - Limit stack size (50 entries)

- [ ] **LIST-016C**: Build `UndoToast` component:
  - Shows after destructive actions
  - "Undo" button with 5-second timeout
  - Auto-dismisses
  - Stacks multiple undoable actions

- [ ] **LIST-016D**: Add keyboard shortcuts:
  - `Ctrl+Z` undo
  - `Ctrl+Shift+Z` or `Ctrl+Y` redo
  - Show shortcut hints in menus
  - Disable when stack empty

- [ ] **LIST-016E**: Implement action grouping:
  - Group related actions (bulk delete)
  - Single undo for group
  - Show group summary in toast
  - Clear stack on navigation

### Tests
- [ ] Undo restores previous state
- [ ] Redo reapplies undone action
- [ ] Keyboard shortcuts work
- [ ] Toast shows correct action
- [ ] Action grouping works for bulk operations

### Definition of Done
- Undo/redo stack with 50-entry limit
- Undo toast with 5-second timeout
- Keyboard shortcuts (Ctrl+Z, Ctrl+Shift+Z)
- Action grouping for bulk operations
- Stack cleared on navigation

### Anti-Patterns
- ❌ No undo for destructive actions — user error permanent
- ❌ Unlimited stack size — memory leak
- ❌ No keyboard shortcuts — power user friction

---

## 📜 Task LIST-017: Activity Log/History
**Priority:** 🟢 Low | **Est. Effort:** 1.5 hours | **Depends On:** LIST-006

### Related Files
`src/components/lists/ActivityLog.tsx` · `src/lib/activityLog.ts` · `src/hooks/useActivityLog.ts`

### Subtasks

- [ ] **LIST-017A**: Extend domain model for activity:
  ```ts
  export interface ActivityEntry {
    id: string
    entityId: string
    entityType: 'list' | 'item'
    action: 'create' | 'update' | 'delete' | 'complete' | 'archive'
    changes: Record<string, { old: unknown; new: unknown }>
    userId?: string
    timestamp: string
  }
  ```

- [ ] **LIST-017B**: Build `ActivityLog` component:
  - Timeline view of all changes
  - Filter by entity, action, date range
  - Show change details (diff view)
  - Export log as CSV

- [ ] **LIST-017C**: Implement activity tracking:
  - Log all mutations to Dexie
  - Track user who made change (mock)
  - Store before/after state
  - Index for efficient queries

- [ ] **LIST-017D**: Add activity log UI:
  - "Show history" button in list settings
  - Activity log panel in right sidebar
  - Restore from history point
  - Diff view for changes

- [ ] **LIST-017E**: Implement activity sync:
  - Sync activity log with server
  - Conflict resolution for concurrent edits
  - Activity log for shared lists
  - Real-time activity feed

### Tests
- [ ] All mutations logged correctly
- [ ] Activity log displays in timeline
- [ ] Filters work correctly
- [ ] Restore from history works
- [ ] Diff view shows changes accurately

### Definition of Done
- Activity log with before/after state
- Timeline view with filters
- Restore from history functionality
- Diff view for changes
- Activity sync for shared lists

### Anti-Patterns
- ❌ Not storing before/after state — can't restore
- ❌ No filters — overwhelming for active lists
- ❌ Not syncing activity — missing collaborative context

---

## 📊 Task LIST-018: Statistics/Analytics Dashboard
**Priority:** 🟢 Low | **Est. Effort:** 2 hours | **Depends On:** LIST-017

### Related Files
`src/components/lists/AnalyticsDashboard.tsx` · `src/hooks/useListAnalytics.ts` · `src/components/charts/CompletionChart.tsx`

### Subtasks

- [ ] **LIST-018A**: Build `AnalyticsDashboard` component:
  - Completion rate chart (line chart over time)
  - Tasks created vs completed (bar chart)
  - Productivity by day of week (heatmap)
  - List breakdown (pie chart)

- [ ] **LIST-018B**: Implement analytics calculations:
  - Daily completion rate
  - Average time to complete
  - Most productive hours
  - List completion distribution
  - Streak tracking

- [ ] **LIST-018C**: Add date range selector:
  - Last 7 days, 30 days, 90 days, custom
  - Compare periods
  - Export analytics data
  - Refresh on data changes

- [ ] **LIST-018D**: Build chart components:
  - Use recharts for visualizations
  - Responsive charts
  - Tooltips with details
  - Accessible charts (ARIA labels)

- [ ] **LIST-018E**: Add insights panel:
  - "You're 20% more productive on Tuesdays"
  - "You complete 80% of tasks within 3 days"
  - "Grocery list is your most active list"
  - Actionable suggestions

### Tests
- [ ] Charts render with correct data
- [ ] Date range selector updates charts
- [ ] Analytics calculations accurate
- [ ] Insights generated correctly
- [ ] Export works

### Definition of Done
- Analytics dashboard with 4 chart types
- Date range selector with comparison
- Analytics calculations for productivity metrics
- Insights panel with suggestions
- Export functionality

### Anti-Patterns
- ❌ Too many metrics — overwhelming
- ❌ No date range — can't see trends
- ❌ Static charts — not interactive

---

## 🎤 Task LIST-019: Voice Input
**Priority:** 🟠 Medium | **Est. Effort:** 1.5 hours | **Depends On:** LIST-002

### Related Files
`src/components/lists/VoiceInputButton.tsx` · `src/lib/speechRecognition.ts` · `src/hooks/useVoiceInput.ts`

### Subtasks

- [ ] **LIST-019A**: Implement speech recognition:
  - Use Web Speech API
  - Request microphone permissions
  - Handle browser compatibility
  - Fallback to text input

- [ ] **LIST-019B**: Build `VoiceInputButton` component:
  - Microphone icon with pulse animation when recording
  - Visual feedback for speech detection
  - Stop recording button
  - Error handling for denied permissions

- [ ] **LIST-019C**: Integrate with natural language parser:
  - Parse transcribed text with existing NLP
  - Extract due dates, priorities, tags
  - Show parsed result before submission
  - Edit transcribed text before adding

- [ ] **LIST-019D**: Add voice input to Quick Add:
  - Microphone button in Quick Add modal
  - "Tap to speak" instruction
  - Auto-stop on silence (3 seconds)
  - Auto-submit on confirmation

- [ ] **LIST-019E**: Add voice commands:
  - "Add [task] to [list]"
  - "Mark [task] as complete"
  - "Show [list]"
  - Voice command help panel

### Tests
- [ ] Speech recognition transcribes accurately
- [ ] Parsed text creates correct task
- [ ] Permission denied handled gracefully
- [ ] Voice commands execute correctly
- [ ] Fallback to text input works

### Definition of Done
- Web Speech API integration
- Voice input button with visual feedback
- Integration with NLP parser
- Voice commands for common actions
- Permission handling

### Anti-Patterns
- ❌ No visual feedback — users unsure if recording
- ❌ No fallback — breaks on unsupported browsers
- ❌ Not showing parsed result — errors go unnoticed

---

## 🔥 Task LIST-020: Habit Tracking
**Priority:** 🟢 Low | **Est. Effort:** 2 hours | **Depends On:** LIST-010

### Related Files
`src/components/lists/HabitTracker.tsx` · `src/lib/habits.ts` · `src/hooks/useHabits.ts`

### Subtasks

- [ ] **LIST-020A**: Extend domain model for habits:
  ```ts
  export interface Habit {
    id: string
    name: string
    frequency: 'daily' | 'weekly'
    targetDays: number[]  // [0,1,2,3,4,5,6] for daily
    streak: number
    bestStreak: number
    completions: Record<string, boolean>  // date -> completed
  }
  ```

- [ ] **LIST-020B**: Build `HabitTracker` component:
  - Calendar heatmap for habit completions
  - Streak counter with fire animation
  - "Mark complete" button for today
  - Habit statistics

- [ ] **LIST-020C**: Implement streak calculation:
  - Calculate current streak
  - Track best streak
  - Handle missed days
  - Streak recovery (one miss allowed)

- [ ] **LIST-020D**: Add habit management:
  - Create new habit from recurring task
  - Edit habit frequency
  - Archive/delete habits
  - Habit templates (exercise, meditation, reading)

- [ ] **LIST-020E**: Add habit reminders:
  - Daily reminder at specified time
  - "Don't break the streak" motivation
  - Streak celebration animation
  - Share streak on social (mock)

### Tests
- [ ] Habit tracker shows correct completions
- [ ] Streak calculation accurate
- [ ] Missed day breaks streak
- [ ] Habit creation from recurring task works
- [ ] Reminders trigger at correct time

### Definition of Done
- Habit tracker with calendar heatmap
- Streak calculation and display
- Habit management (create, edit, archive)
- Habit reminders
- Streak celebration

### Anti-Patterns
- ❌ No streak recovery — too punishing
- ❌ No motivation — low engagement
- ❌ Complex setup — high friction

---

## 🤖 Task LIST-021: Smart Suggestions
**Priority:** 🟢 Low | **Est. Effort:** 2 hours | **Depends On:** LIST-017

### Related Files
`src/components/lists/SuggestionPanel.tsx` · `src/lib/suggestions.ts` · `src/hooks/useSuggestions.ts`

### Subtasks

- [ ] **LIST-021A**: Implement suggestion engine:
  - Analyze task patterns (time of day, tags, lists)
  - Suggest similar tasks based on history
  - Detect recurring patterns not formalized
  - Suggest tags based on content

- [ ] **LIST-021B**: Build `SuggestionPanel` component:
  - "You might want to add..." section
  - Suggested tasks with one-tap add
  - Confidence score display
  - Dismiss suggestions

- [ ] **LIST-021C**: Add context-aware suggestions:
  - Suggest based on current list
  - Suggest based on time of day
  - Suggest based on recent activity
  - Suggest based on day of week

- [ ] **LIST-021D**: Implement suggestion learning:
  - Track suggestion acceptance rate
  - Improve suggestions over time
  - Ignore dismissed suggestions
  - Suggestion preferences

- [ ] **LIST-021E**: Add smart completions:
  - Autocomplete based on history
  - Suggest due dates based on similar tasks
  - Suggest list based on content
  - Smart tag suggestions

### Tests
- [ ] Suggestions based on patterns
- [ ] One-tap add works
- [ ] Context-aware suggestions relevant
- [ ] Learning improves suggestions
- [ ] Autocomplete works

### Definition of Done
- Pattern-based suggestion engine
- Suggestion panel with one-tap add
- Context-aware suggestions
- Suggestion learning system
- Smart completions

### Anti-Patterns
- ❌ Irrelevant suggestions — ignored by users
- ❌ No way to dismiss — annoying
- ❌ Not learning — suggestions don't improve

---

## 📎 Task LIST-022: File Attachments
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** LIST-003

### Related Files
`src/components/lists/FileAttachment.tsx` · `src/lib/fileStorage.ts` · `src/hooks/useFileAttachments.ts`

### Subtasks

- [ ] **LIST-022A**: Extend domain model for attachments:
  ```ts
  export interface Attachment {
    id: string
    itemId: string
    name: string
    type: string
    size: number
    url: string
    uploadedAt: string
  }
  ```

- [ ] **LIST-022B**: Build `FileAttachment` component:
  - Drag-and-drop file upload
  - File picker button
  - Attachment list with icons
  - Preview for images/PDFs

- [ ] **LIST-022C**: Implement file storage:
  - Upload to server (mock)
  - Store file metadata in Dexie
  - Generate preview thumbnails
  - Handle large files (chunking)

- [ ] **LIST-022D**: Add attachment UI:
  - Attachment icon on items with files
  - Attachment count badge
  - Download attachment button
  - Delete attachment with confirmation

- [ ] **LIST-022E**: Implement attachment sync:
  - Sync attachments with server
  - Conflict resolution for concurrent uploads
  - Offline attachment handling
  - Attachment versioning

### Tests
- [ ] File upload works
- [ ] Drag-and-drop functional
- [ ] Preview renders for images
- [ ] Download works
- [ ] Sync handles conflicts

### Definition of Done
- File attachment with drag-and-drop
- File storage with metadata
- Attachment preview for images/PDFs
- Download and delete functionality
- Attachment sync

### Anti-Patterns
- ❌ No file size limit — storage issues
- ❌ No preview — can't verify content
- ❌ Not handling conflicts — data loss

---

## 🔄 Task LIST-023: Custom Sorting
**Priority:** 🟠 Medium | **Est. Effort:** 1.5 hours | **Depends On:** LIST-003

### Related Files
`src/components/lists/SortOptions.tsx` · `src/hooks/useListSorting.ts` · `src/stores/slices/listsSlice.ts`

### Subtasks

- [ ] **LIST-023A**: Extend lists slice for sorting:
  ```ts
  interface ListsSlice {
    // ... existing fields
    sortBy: 'custom' | 'priority' | 'dueDate' | 'createdAt' | 'title'
    sortDirection: 'asc' | 'desc'
  }
  ```

- [ ] **LIST-023B**: Build `SortOptions` component:
  - Sort by dropdown (custom, priority, due date, created, title)
  - Sort direction toggle (asc/desc)
  - "Remember this sort" checkbox
  - Sort indicator in list header

- [ ] **LIST-023C**: Implement sorting logic:
  - Custom sort (manual drag order)
  - Priority sort (urgent → none)
  - Due date sort (nearest → farthest)
  - Created date sort (newest → oldest)
  - Title sort (A-Z)

- [ ] **LIST-023D**: Add sort persistence:
  - Remember sort preference per list
  - Persist to localStorage
  - Apply sort on list load
  - Reset to custom option

- [ ] **LIST-023E**: Add multi-level sorting:
  - Primary sort (e.g., priority)
  - Secondary sort (e.g., due date)
  - Tertiary sort (e.g., created date)
  - Sort preview tooltip

### Tests
- [ ] All sort options work correctly
- [ ] Sort direction toggle works
- [ ] Multi-level sorting applies correctly
- [ ] Sort preference persists
- [ ] Reset to custom works

### Definition of Done
- 5 sort options with direction toggle
- Multi-level sorting support
- Sort persistence per list
- Sort indicator in header
- Reset to custom option

### Anti-Patterns
- ❌ No multi-level sorting — insufficient for complex lists
- ❌ Not persisting sort — reverts on reload
- ❌ No sort indicator — users confused by order

---

## 🎯 Task LIST-024: Focus Mode
**Priority:** 🟢 Low | **Est. Effort:** 1.5 hours | **Depends On:** LIST-002

### Related Files
`src/components/lists/FocusMode.tsx` · `src/hooks/useFocusMode.ts` · `src/stores/slices/listsSlice.ts`

### Subtasks

- [ ] **LIST-024A**: Extend lists slice for focus mode:
  ```ts
  interface ListsSlice {
    // ... existing fields
    focusMode: boolean
    focusListId: string | null
  }
  ```

- [ ] **LIST-024B**: Build `FocusMode` component:
  - Full-screen overlay
  - Single list display
  - Hide sidebar and right panel
  - Minimal toolbar (exit focus, add item)

- [ ] **LIST-024C**: Implement focus mode UI:
  - "Enter focus mode" button in list header
  - Keyboard shortcut (F or Ctrl+Shift+F)
  - Progress indicator at top
  - Motivational quote or timer

- [ ] **LIST-024D**: Add focus mode features:
  - Pomodoro timer (25min work, 5min break)
  - Block distracting notifications
  - Show only uncompleted items
  - Focus session statistics

- [ ] **LIST-024E**: Implement focus mode persistence:
  - Remember focus mode state
  - Auto-enter focus mode for specific lists
  - Focus mode schedule (mock)
  - Exit focus mode on navigation

### Tests
- [ ] Focus mode hides sidebar and panels
- [ ] Keyboard shortcut enters/exits focus mode
- [ ] Pomodoro timer works
- [ ] Notifications blocked in focus mode
- [ ] Focus mode persists

### Definition of Done
- Focus mode with full-screen overlay
- Keyboard shortcut (F or Ctrl+Shift+F)
- Pomodoro timer integration
- Notification blocking
- Focus session statistics

### Anti-Patterns
- ❌ No easy exit — users feel trapped
- ❌ Blocking all notifications — miss important alerts
- ❌ No timer — just visual change

---

## 📊 Dependency Graph

```
LIST-000 (Domain Model & Mock Data)
     │
LIST-001 (State Management & Templates)
     │
LIST-002 (Page Layout & Quick Capture)
     │
     ├── LIST-003 (List Items & Content Types)
     │          │
     │          ├── LIST-004 (View Modes)
     │          │        │
     │          │        └── LIST-005 (Drag, Drop & Bulk Operations)
     │          │
     │          ├── LIST-008 (Search & Filtering)
     │          │
     │          ├── LIST-009 (Reminders System)
     │          │        │
     │          │        ├── LIST-010 (Recurring Tasks)
     │          │        │        │
     │          │        │        └── LIST-020 (Habit Tracking)
     │          │        │
     │          │        ├── LIST-011 (Priority Levels)
     │          │        │
     │          │        ├── LIST-012 (Calendar Integration)
     │          │        │
     │          │        └── LIST-013 (Location-Based Reminders)
     │          │
     │          ├── LIST-016 (Undo/Redo Functionality)
     │          │
     │          ├── LIST-019 (Voice Input)
     │          │
     │          ├── LIST-022 (File Attachments)
     │          │
     │          └── LIST-023 (Custom Sorting)
     │
     ├── LIST-006 (Offline Support & Data Sync)
     │          │
     │          ├── LIST-007 (Sharing & Collaboration)
     │          │
     │          └── LIST-017 (Activity Log/History)
     │                   │
     │                   ├── LIST-018 (Statistics/Analytics Dashboard)
     │                   │
     │                   └── LIST-021 (Smart Suggestions)
     │
     ├── LIST-014 (Widget Support)
     │
     ├── LIST-015 (Email-to-Task Conversion)
     │
     └── LIST-024 (Focus Mode)
```

---

## 🏁 Lists Module Completion Checklist

**Core Functionality:**
- [ ] All 5 content types render and edit correctly
- [ ] Nested items support 5 levels deep with keyboard navigation
- [ ] Three view modes (List/Board/Grid) functional
- [ ] Quick Add with natural language parsing works
- [ ] 10 built-in templates available
- [ ] Drag-and-drop reordering within and between lists

**Advanced Features:**
- [ ] Bulk selection and operations
- [ ] Full-text search with highlighting
- [ ] Advanced filtering with URL sync
- [ ] Archive system with browser
- [ ] Share links with permissions
- [ ] Offline support with Dexie sync

**Enhanced Features (New):**
- [ ] Reminders system with due date and location-based notifications
- [ ] Recurring tasks with full recurrence rule support
- [ ] Priority levels with color coding and sorting
- [ ] Calendar integration with two-way sync
- [ ] Location-based reminders with geofencing
- [ ] Widget support for home screen
- [ ] Email-to-task conversion with parsing
- [ ] Undo/redo functionality with toast notifications
- [ ] Activity log/history with timeline view
- [ ] Statistics/analytics dashboard with charts
- [ ] Voice input with Web Speech API
- [ ] Habit tracking with streaks
- [ ] Smart suggestions based on patterns
- [ ] File attachments with drag-and-drop
- [ ] Custom sorting with multi-level support
- [ ] Focus mode with Pomodoro timer

**Quality & UX:**
- [ ] Keyboard shortcuts for all major actions
- [ ] Motion hierarchy applied (Alive/Quiet tiers)
- [ ] WCAG 2.2 AA accessibility
- [ ] Mobile-responsive layout
- [ ] Optimistic updates with rollback
- [ ] Error boundaries and loading states

**Testing:**
- [ ] Unit tests for domain utilities and NLP parsing
- [ ] Component tests for ListItem, View modes, Quick Add
- [ ] Integration tests for drag-and-drop, bulk operations
- [ ] E2E tests for create list → add items → mark complete flow
- [ ] Tests for reminders, recurrence, and priority systems
- [ ] Tests for calendar sync and email parsing

---

*Document follows the specification format established in 01-Foundations through 09-Polish-Validation. For implementation guidance, reference the skills in `.windsurf/skills/` for component creation, drag-and-drop, form handling, and offline support patterns.*
