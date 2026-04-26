---
steering: TO PARSE — READ INTRO
file_name: 04-COMP-PROJECTS-KANBAN-SPEC.md
document_type: component_specification
module: Projects
tier: core
status: draft
owner: Trevor
description: Kanban board component for visual project management with drag-and-drop task organization, swimlanes, and real-time collaboration.
last_updated: 2026-04-26
version: 1.0
dependencies: [04-COMP-PROJECTS.md, 01-PLAN-ZUSTAND.md, 02-ARCH-DATABASE.md]
related_adrs: [ADR_003, ADR_085]
related_rules: [XCT_01, XCT_02, g4, S1, S28]
complexity: high
risk_level: medium
---

# Kanban Board — Component Specification

## 1. Purpose

### 1.1 What This Is
A visual project management Kanban board component that enables drag-and-drop task organization across customizable columns, swimlanes, and workflows. It supports real-time collaboration, task filtering, and project analytics.

### 1.2 User Story
As a project manager, I want to organize tasks visually on a Kanban board so that I can track progress, manage workflows, and collaborate with my team in real-time.

### 1.3 Non-Goals
- Does NOT handle task creation (delegated to TaskComposer)
- Does NOT implement Gantt chart view (separate component)
- Does NOT support advanced reporting (Phase 2 feature)
- Does NOT handle project templates (Phase 2 feature)

## 2. UX States

### 2.1 State Catalog
| State ID | State Name | Trigger Condition | Visual Behavior | User Action Available |
|----------|------------|-------------------|-----------------|----------------------|
| S-LOADING | Loading | Board data fetching | Skeleton columns with loading shimmer | None |
| S-EMPTY | Empty | No tasks in project | Empty board with "Add task" CTA | Create task, import tasks |
| S-DATA | Data Present | Tasks loaded, ≥1 task | Full Kanban board with columns | Drag tasks, filter, search |
| S-ERROR | Error | Fetch failed, network error | Error message + retry button | Retry, refresh |
| S-FILTERING | Filtering | Active filter applied | Filter indicator, filtered tasks | Clear filter, modify filter |
| S-COLLABORATING | Collaborating | Multiple users active | User cursors, live updates | Collaborate, see changes |
| S-EDITING | Editing | Column/workflow edit mode | Edit controls on columns | Edit columns, save changes |

### 2.2 State Transition Diagram
S-LOADING → S-EMPTY | S-DATA | S-ERROR
S-DATA → S-FILTERING (on filter) → S-DATA (on clear)
S-DATA → S-COLLABORATING (on other user join) → S-DATA (on leave)
S-DATA → S-EDITING (on edit mode) → S-DATA (on save)
S-ERROR → S-LOADING (on retry) → S-DATA (on success)

### 2.3 DO NOT
- DO NOT allow task drag without proper permissions
- DO NOT auto-save board layout without user action
- DO NOT show other users' cursors when offline

## 3. Transitions & Animations

### 3.1 Motion Patterns Used
| Pattern | Lexicon Ref | Applied To | Duration/Spring | Notes |
|---------|-------------|------------|-----------------|-------|
| @M | MotionGuard | Drag-drop, column transitions | — | Respects prefers-reduced-motion |
| @DD | DragDrop | Task card movement | — | @dnd-kit library integration |
| @OF | OpacityFade | Filter transitions, hover states | ≤150ms | Quick feedback |
| @AP | AnimatePresence | Column enter/exit, task cards | — | Smooth transitions |

### 3.2 DO NOT (HARD constraints from Lexicon)
- DO NOT animate drag-drop positions (handled by @dnd-kit). (Rule XCT_01)
- DO NOT use spring animations for filter changes (use fade). (Rule g4)
- DO NOT animate when prefers-reduced-motion is active. Instant transitions. (Rule g6)

## 4. Data Shapes

### 4.1 Zustand Slice
Reference: 01-PLAN-ZUSTAND-TYPES.md ProjectsSlice
```typescript
interface ProjectsSlice {
  activeProjectId: string | null;
  projects: Record<string, Project>;
  tasks: Record<string, Task>;
  columns: Record<string, Column>;
  swimlanes: Record<string, Swimlane>;
  boardView: 'kanban' | 'list' | 'timeline';
  filters: TaskFilters;
  collaborators: Record<string, User>;
}
```

### 4.2 Database Tables Referenced
| Table | Columns Used | RLS Policy |
|-------|-------------|------------|
| projects | id, org_id, name, created_at, updated_at | org_id = auth.jwt()->>org_id |
| tasks | id, org_id, project_id, title, status, assignee_id, created_at | org_id = auth.jwt()->>org_id |
| columns | id, org_id, project_id, name, position, created_at | org_id = auth.jwt()->>org_id |

### 4.3 API Payloads
#### Get Board Data
```json
{
  "project_id": "string // ULID",
  "include_tasks": boolean,
  "include_swimlanes": boolean
}
```
#### Update Task Position
```json
{
  "task_id": "string // ULID",
  "column_id": "string // ULID",
  "position": "number",
  "swimlane_id": "string // optional ULID"
}
```
#### Response (200)
```json
{
  "data": {
    "project": {},
    "tasks": [],
    "columns": [],
    "swimlanes": []
  },
  "error": null,
  "meta": {}
}
```

### 4.4 Validation Rules
- project_id: must be valid ULID and user has access
- task_id: must be valid ULID and belongs to project
- position: number, ≥ 0, ≤ max tasks in column

## 5. Edge Cases & Error Handling

### 5.1 Edge Cases
| ID | Scenario | Expected Behavior | Test Verification |
|----|----------|-------------------|-------------------|
| EC-001 | 1000+ tasks in column | Virtualization, performance optimization | Add 1000 tasks to column |
| EC-002 | Drag to invalid position | Snap to valid position, show error | Drag beyond column bounds |
| EC-003 | Concurrent task moves | Last-writer-wins with conflict UI | Two users move same task |
| EC-004 | Network drop during drag | Queue move, sync on reconnect | Disconnect while dragging |
| EC-005 | Column deletion with tasks | Move tasks to default column | Delete column with tasks |

### 5.2 Error Scenarios
| Error Code | Trigger | User Sees | System Does | Recovery |
|------------|---------|-----------|-------------|----------|
| VALIDATION_ERROR | Invalid move position | "Invalid position" toast | 400 response | User must retry |
| PERMISSION_DENIED | User lacks edit access | Read-only mode | Disable drag-drop | Request permission |
| NETWORK_ERROR | Move fails | "Connection lost" banner | Retry with exponential backoff | Auto-retry 3x |
| TASK_NOT_FOUND | Invalid task ID | "Task not found" error | 404 response | Refresh board |

### 5.3 Race Conditions
- Task move while filtering: Update filter after move completes.
- Column edit while dragging: Finish drag, then apply column changes.
- Collaborator join while loading: Show collaborator after load completes.

## 6. Acceptance Criteria

### 6.1 Functional
- [ ] All 7 UX states render correctly
- [ ] Drag-drop works smoothly between columns
- [ ] Swimlanes organize tasks correctly
- [ ] Real-time collaboration shows other users
- [ ] Filters and search work properly
- [ ] Responsive design works on mobile

### 6.2 Performance
- [ ] Initial render ≤ 1000ms (p75)
- [ ] Drag-drop response ≤ 100ms
- [ ] Task rendering ≤ 50ms per 100 tasks
- [ ] Memory usage ≤ 20MB per 1000 tasks

### 6.3 Accessibility
- [ ] WCAG 2.2 AA: keyboard navigation functional
- [ ] WCAG 2.2 AA: screen reader announces task moves
- [ ] prefers-reduced-motion: animations disabled

### 6.4 Security
- [ ] CSP: no inline scripts
- [ ] RLS: all queries scoped to org_id
- [ ] Input: all task data sanitized

## 7. Accessibility

### 7.1 ARIA Roles & Labels
| Element | Role | aria-label | Notes |
|---------|------|------------|-------|
| Kanban board | application | "Kanban board for [project name]" | |
| Column | region | "[column name], [X] tasks" | |
| Task card | article | "[task title], assigned to [assignee]" | aria-grabbed state |
| Drop zone | none | aria-dropeffect="move" | On column containers |

### 7.2 Keyboard Navigation
| Key | Action | Notes |
|-----|--------|-------|
| Tab | Navigate through tasks and columns | |
| Arrow keys | Move between tasks in column | |
| Space | Grab/release task for drag | |
| Enter | Open task details | |
| Escape | Cancel drag, close modals | |
| Ctrl+F | Focus search input | |

### 7.3 Screen Reader Announcements
| Event | aria-live Region | Message |
|-------|-----------------|---------|
| Task moved | polite | "Moved [task] to [column]" |
| Column edited | assertive | "Column renamed to [name]" |
| User joined | polite | "[Username] joined board" |
| Error occurred | assertive | "Error: [message]" |

## 8. Testing Strategy

### 8.1 Unit Tests
- KanbanBoard renders empty state
- KanbanBoard renders with tasks
- KanbanBoard handles drag-drop
- KanbanBoard applies filters correctly

### 8.2 Component Tests
- Drag-drop between columns
- Swimlane functionality
- Real-time collaboration
- Responsive layout behavior

### 8.3 Integration Tests
- Complete task move flow
- Multi-user collaboration
- Filter and search combinations
- Board persistence

### 8.4 Security Tests
- Task data sanitization
- Project permission enforcement
- RLS compliance

## 9. Risks & Open Questions

### 9.1 Risks
- Performance with many tasks (mitigated by virtualization)
- Drag-drop conflicts (mitigated by proper state management)
- Data corruption during sync (mitigated by conflict resolution)

### 9.2 Open Questions
- Should board support custom workflows? → Phase 1.1
- Should tasks have dependencies? → Phase 2
- How should board analytics be displayed? → Design review

### 9.3 Assumptions
- All drag-drop uses @dnd-kit library
- Real-time updates use WebSocket connections
- Task positions are zero-indexed within columns
- Swimlanes are optional feature
