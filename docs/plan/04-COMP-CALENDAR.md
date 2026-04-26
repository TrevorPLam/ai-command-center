---
steering: TO PARSE - READ INTRO
file_name: 04-COMP-CALENDAR.md
document_type: component_specification
module: Calendar
tier: feature
status: stable
owner: Product Engineering
component_count: 11
dependencies:
- calendarSlice
- rbc (react-big-calendar)
- ~shared/recurrence
motion_requirements:
- @M (MotionGuard)
- @Z (TimezoneAware)
- @AP (AnimatePresence)
- @AS (Spring animations)
- @O (OptimisticMutation)
- @R (Recurring)
accessibility:
- WCAG 2.2 AA compliance
- ARIA grid navigation
- Keyboard shortcuts
- Screen reader support
performance:
- LCP optimization
- Virtualization for large datasets
last_updated: 2026-04-25
version: 1.0
related_adrs: [ADR_082]
related_rules: [g10, dnd, B3, g4, B1, Q, zod, g9, g10]
complexity: medium
risk_level: medium
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Calendar
CalendarPage|A|Page|@M,@Z,AP|g10|~s/calendarSlice|Sheet mobile
MonthView|A|View|@M,@Z|g10|rbc|ARIA grid,kbd
WeekDayView|A|View|@O,AS|dnd+B3|rbc|Ctrl+Shift+Arrows
ResourceWeekView|A|View|@M|-|rbc|-
AgendaView|A|View|@V|-|rbc|role=list
EventComposer|A|Composer|@M,@R,@O,Q|-|-|optimistic create
EventDetailDrawer|A|Drawer|@O,Q|-|-|optimistic delete undo
RecurringEditModal|A|Modal|@R,@O|-|~shared/recurrence|store exceptions
TimezoneSelector|A|Selector|@Z|-|-|working hours
ReminderToast|A|Toast|@M,AS|-|-|browser notif
ImportExportDialog|A|Dialog|-|-|-|ICS,partial
BulkActionBar|A|Bar|@O|-|-|shift-click range
