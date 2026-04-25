---
steering: TO PARSE - READ INTRO
document_type: component_specification
module: Budget
tier: feature
component_count: 7
dependencies:
- budgetSlice
- rbc (react-big-calendar)
- ~shared/recurrence
motion_requirements:
- @M (MotionGuard)
- @Z (TimezoneAware)
- @AP (AnimatePresence)
- @AS (Spring animations)
- @O (OptimisticMutation)
- @R (Recurring)
- @V (VirtualizeList)
- @I (InfiniteScroll)
accessibility:
- WCAG 2.2 AA compliance
- Keyboard navigation
- Screen reader support
performance:
- LCP optimization
- Virtualization for large lists
last_updated: 2026-04-25
version: 1.0
---

#C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Budget
BudgetPage|B|Page|@M,@Z,AP|g10|~s/budgetSlice|URL sync(g27)
BudgetDashboard|B|Dashboard|@V|LCP|-|chart/table
TransactionList|B|List|@V,@I|-|-|past/sched/planned
TransactionCalendarView|B|Calendar|@O,AS|dnd+B3|rbc|future editable
GoalCard|B|Card|@O|-|-|feasibility
RecurringCalendar|B|Calendar|@R,@O,AS|-|~shared/recurrence|shared engine
CashFlowForecast|B|Forecast|-|LCP|-|LCP
