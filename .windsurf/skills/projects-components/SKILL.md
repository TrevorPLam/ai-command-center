---
name: projects-components
description: Guides the creation of project management components including ProjectsPage with multiple views (List, Kanban, Timeline, My Week, Workload), ProjectDetailPage, TaskDetailDrawer, and ProjectTemplateLibrary
---

## Projects Components

### ProjectsPage.tsx
Main projects page with view switcher and filters.

**Top bar:**
- Page title "Projects"
- View switcher: List | Kanban | Timeline | My Week | Workload (icon buttons, active = blue)
- "New Project" button (blue, top-right)
- Filter bar: Status (All / Active / On Hold / Completed / Archived), Priority, Due Date range, Tag filter (multi-select chips)
- Sort: Due Date / Last Updated / Alphabetical / Priority

### ProjectListView.tsx
Table view with columns:
- Project Name (clickable, navigates to detail)
- Status badge (colored)
- Priority badge (colored)
- Due Date
- Tag chips
- Progress bar (% tasks complete)
- Owner avatar
- Row hover: subtle white/8 background

### ProjectKanbanView.tsx
Drag-and-drop kanban board using @dnd-kit/core:
- Columns: Not Started | In Progress | On Hold | In Review | Completed
- Each column shows project cards
- Cards show: project name, due date, priority dot, task count, progress bar
- Drag between columns to update status
- Electric blue highlight on drop target

### ProjectTimelineView.tsx
Gantt-style horizontal timeline:
- Left column: project names (fixed width)
- Right: horizontal bars spanning start → due date
- Color-coded by status
- Zoom: Week / Month / Quarter
- Hover tooltip shows project details
- Current date indicator (red vertical line)

### MyWeekView.tsx
Inspired by Karbon's "My Week" feature:
- Four swim lanes: To Plan | This Week | Later | Cleared
- Cards can be dragged between lanes
- Each card: task name, parent project badge, due date, priority
- "Due Today" filter button at top
- Tasks organized by due date within lanes

### WorkloadView.tsx
Bar chart of tasks per day:
- Time range: current week + 2 weeks ahead
- Shows task count per day
- Over-committed days shown in red (> 5 tasks)
- Simple capacity planning for personal use
- Click day to see task list

### ProjectDetailPage.tsx
Full project workspace at `/projects/:projectId`.

**Header:**
- Project name (inline editable)
- Status dropdown
- Priority dropdown
- Due date picker
- Tag chips (add/remove)
- Description (rich text display)
- Edit button

**Tabs across top:** Tasks | Timeline | Files | Notes | Activity

**Tasks tab (default):**
- Task list rendered as TaskRow components
- Each row: checkbox, task name (inline editable), assignee, due date, priority badge, status badge, subtask count indicator, expand chevron
- Expanding shows SubtaskList (nested tasks, same row format)
- Inline "Add task" row at bottom
- "Add Section" button to group tasks under headings
- Clicking task name opens TaskDetailDrawer

**Timeline tab:** Gantt view scoped to this project's tasks

**Notes tab:** Simple rich-text editor with auto-save indicator

**Activity tab:** Chronological log of all changes

### ProjectCard.tsx
- Project name
- Status badge
- Priority dot
- Due date
- Progress bar
- Task count
- Tag chips
- Hover: subtle lift and shadow
- Click: navigates to project detail

### TaskRow.tsx
- Checkbox (complete/incomplete)
- Task name (inline editable)
- Assignee avatar
- Due date
- Priority badge
- Status badge
- Subtask count indicator
- Expand chevron
- Hover: subtle white/8 background
- Click name: opens TaskDetailDrawer

### TaskDetailDrawer.tsx
Right-side sheet (320px):
- Task title (large, editable)
- Status selector (Not Started / In Progress / Blocked / In Review / Done)
- Priority selector (Low / Medium / High / Critical)
- Due date + start date pickers
- Description textarea (markdown supported)
- ChecklistPanel: named checklists with items, each with checkbox, label, assignee, due date
- Subtasks list with add button
- Comments section (mock thread)
- Activity log for this task
- Tags
- Attachments (mock file list)

### SubtaskList.tsx
- Nested list of subtasks
- Same row format as TaskRow
- Indented with visual hierarchy
- Add subtask button
- Drag to reorder

### ChecklistPanel.tsx
- Named checklists (e.g., "Launch Checklist", "Review Checklist")
- Each checklist has items
- Each item: checkbox, label, assignee, due date
- "Add checklist" and "Add item" buttons
- Progress indicator per checklist

### ProjectTemplateLibrary.tsx
Accessible via "New Project" → "Use Template":
- Grid of pre-built templates
- Templates: Home Renovation, Product Launch, Content Calendar, Learning Goal, Travel Planning, Event Planning
- Each card: template name, description, task count, estimated duration
- Clicking uses template structure as new project scaffold

## Data Requirements

All projects components must use realistic mock data from `src/lib/mockData/projects.ts` and `src/lib/mockData/tasks.ts` with:
- Multiple projects with different statuses and priorities
- Tasks with subtasks and checklists
- Project templates
- Realistic due dates and time ranges

## State Management

- Use TanStack Query for fetching projects and tasks
- Use Zustand for UI-only state (view mode, filters, drawer open/close)
- Use @dnd-kit/core for drag-and-drop in kanban and My Week views

**@dnd-kit/core Patterns (2026):**
- Use @dnd-kit/core for performant, accessible drag-and-drop
- @dnd-kit/react provides React components and hooks
- useDraggable hook requires unique id
- Proper ARIA attributes for accessibility (aria-grabbed, aria-dropeffect)
- Keyboard navigation support for drag operations
- Collision detection with collision detection algorithm
- Sensors for different input methods (mouse, touch, keyboard)

## Accessibility Requirements (WCAG 2.2 AA)

- ProjectsPage: proper ARIA landmarks (main, nav), semantic HTML, keyboard navigation for view switcher
- ProjectListView: table role, proper column headers, scope attributes, sortable column indicators
- ProjectKanbanView: aria-grabbed/aria-dropeffect for drag items, proper drag and drop ARIA
- ProjectTimelineView: aria-label for timeline, keyboard navigation, role="grid"
- TaskDetailDrawer: focus trap when open, role="dialog", aria-modal="true"
- All interactive elements: 4.5:1 color contrast ratio minimum
- Focus management: visible focus indicators, focus restoration after drawer close
- Dynamic content: aria-live regions for task updates
- Screen readers: announce project status changes, task completion
- Keyboard navigation: all interactive elements reachable via keyboard, escape to close modals

## Visual Identity

- Glass panels: backdrop-blur-md bg-white/5 border border-white/10 rounded-xl
- Electric blue accent: #0066ff → #00aaff for CTAs and active states
- Status colors: Active (green), On Hold (amber), Completed (blue), Archived (gray)
- Priority colors: Critical (red), High (orange), Medium (yellow), Low (green)
- 150ms ease-out transitions on all interactive elements
- Skeleton loaders on all data fetch states

**Tailwind v3 & shadcn/ui Notes (2026):**
- shadcn/ui uses Tailwind v3 with standard CSS configuration
- Components use forwardRef for ref forwarding (React 18 pattern)
- HSL colors are used in standard format
- Default style is available; use new-york style if preferred
