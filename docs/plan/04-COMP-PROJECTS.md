---
file_name: 04-COMP-PROJECTS.md
steering: TO PARSE - READ INTRO
document_type: component_specification
module: Projects
tier: feature
component_count: 24
dependencies:
- ~s/projectSlice
- ~p/ProjectsPage
motion_requirements:
- @M (MotionGuard)
- @AP (AnimatePresence)
- @Q (OpacityFade)
- @E (InlineEdit)
accessibility:
- WCAG 2.2 AA compliance
- Keyboard navigation
- Screen reader support
performance:
- Virtualization for large lists
- View switching optimization
last_updated: 2026-04-25
version: 1.0
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Projects
ProjectsPage|P|Page|@M,AP|B1+P2|~s/projectSlice,~p/ProjectsPage|viewSwitcher layoutId
ViewSwitcher|P|Switcher|@M,Q|g9|~s/projectSlice|active via zu
FilterBar|P|Bar|P2|-|~s/projectSlice|clear,useTransition
ProjectListView|P|List|@V,@E,@H|B1|-|10 cols
ProjectKanbanView|P|Kanban|@O,AG|dnd+B3|~s/projectSlice|pointerWithin
ProjectTimelineView|P|Timeline|-|g4+LCP|svg|zoom Day/Week/Month/Quarter
MyWeekView|P|View|@O|dnd+B3|~s/projectSlice|colleague week
WorkloadView|P|View|P2|-|-|click bar→task list
TriagePage|P|Page|@V,@T,@TRIAGE|-|~s/triageSlice|swipe,kbd(E,A,P)
TriageActionTray|P|Tray|@O|-|~s/triageSlice|comment blue/white
TriageIntegrationHub|P|Hub|-|-|~h/useTriage|type icons
ProjectDetailPage|P|Page|@E,@O,@M,AP|FT|~s/projectSlice|tab nav URL(g27)
TaskList|P|List|@V,@E,@O|dnd+B3|-|subtask count
TaskDetailDrawer|P|Drawer|@M,@E,@O,@D,AS|B1+FT|~s/projectSlice|tabs lazy,@mention,debounce500ms
TaskChecklist|P|Checklist|@O,AG|dnd+B3|-|live% in tab
TaskComments|P|Comments|@O|dp+rta|-|internal/external
QuickPeekOverlay|P|Overlay|@M,Q|FT aria-modal|~s/projectSlice|cached data
ProjectTemplateLibrary|P|Library|-|-|-|save as template
RecurringWorkDialog|P|Dialog|@R|zod|~shared/recurrence|preview next5
ClientTaskConfig|P|Config|@E|-|-|badge
AutomationRulesPanel|P|Panel|@O|-|~s/projectSlice|triggered=strikethrough
TimeBudgetPanel|P|Panel|@O|-|~s/projectSlice|green<75%,amber<100%,red
PracticeIntelligence|P|Dashboard|-|-|-|agent log
GlobalSearchDialog|P|Dialog|@K|FT|-|type:,before:,after:
