I will now conduct comprehensive research on modern budgeting apps and calendar UI patterns to enhance the existing Budget Module spec. This will ensure the refreshed task list is fully aligned with 2025–2026 industry best practices, especially those from Monarch Money and Copilot Money, which lead the market with their financial calendar and AI-powered planning features.

---

### 🔍 Research Synthesis: The "Financial Calendar" Paradigm

Leading personal finance platforms in 2026 have converged on a core concept: the **financial calendar** is the central planning interface that ties budgeting, goals, and cash flow together.

**Monarch Money's Approach.** Monarch presents a unified dashboard where a "clean, customizable" widget system lets users prioritize budgets, cash flow, and investments. A key feature is its **calendar view of upcoming recurring charges**, which transforms a list of bills into a visual, time-based schedule for managing cash flow. It also automatically detects subscriptions, addressing a major source of financial tracking errors.

**Copilot Money's Approach.** Copilot emphasizes **forward-looking intelligence**. Its "Cash Flow" feature uses AI to categorize transactions, forecast patterns, and provide real-time insights into overspending. Crucially, it suggests savings goals based on a user's actual cash flow and spending patterns, directly tying a plan's feasibility to the user's financial calendar.

**Synthesis for the Task List.** This research directly informs the following key enhancements to the Budget module:

- **First-Class Calendar View:** The current `TransactionList` must be augmented with a true Calendar View that displays past, scheduled, and planned transactions on a single grid. This is the user's primary "schedule" for money.
- **Smart Goal Planning:** Creating a goal should not be a standalone form. It should analyze the user's projected cash flow (from the calendar) to determine if a target monthly contribution is realistic, providing a "Feasibility Score."
- **Unified Data & Interactivity:** Users should be able to drag to reschedule planned transactions, click to filter, and toggle the visibility of different transaction types, all within a consistent and performant interface.
- **Automation & Rule Engine:** The system should not just record data; it should proactively help users by suggesting categories for new transactions and automatically detecting recurring bills.

---

*(The following is the full, updated version of `07-Budget.md`, enhanced with all new tasks and subtasks.)*

# 07-Budget — Personal AI Command Center Frontend (Enhanced v3)

> **Status indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.


## 📐 Reasoning Memo: The "Financial Calendar" Paradigm

The Budget module is being re-envisioned as a **Financial Calendar**. Instead of a mere historical ledger, it is a forward-looking planning tool. This shift is informed directly by research into modern finance apps like Monarch and Copilot, which prioritize cash flow visibility and goal feasibility.

This necessitates several high-priority enhancements:

- **From "Expense Trackers" to "Planned Events"**: Users need to easily add *future* transactions (Paychecks, Rent, discretionary spending plans) and see their impact. This is the core calendar metaphor.
- **First-Class Recurrence Engine**: Bills and subscriptions should be managed with the same sophistication as calendar recurring events (custom rules, end dates, exceptions).
- **Visual Cash Flow Projection**: The `RecurringPage` should be supplemented by a dynamic **Cash Flow Timeline/Calendar** that aggregates all planned, recurring, and scheduled transactions.
- **Direct Manipulation**: Drag-and-drop to adjust the timing of planned transactions should be a primary, fluid interaction.
- **Goal Feasibility Modeling**: Setting a goal should feel like the "Find a Time" feature. The system analyzes the financial calendar to suggest a realistic plan for achieving the goal by a target date.

## 🔬 Research Findings — Budget Module

| Finding | Source | Action Required |
|---------|--------|-----------------|
| Leading personal finance apps in 2026 center their experience around a customizable dashboard with a dedicated "Recurring" or "Calendar" view for managing future cash flow. | Monarch, Copilot | BUDG-006: Augment transactions page with a `TransactionCalendarView`. Strengthen BUDG-010 to be a core recurring management hub. |
| AI-powered features like Copilot Intelligence proactively suggest savings goals based on analyzed cash flow and recurring payments. | Copilot | BUDG-008: Enhance `GoalsPage` to include a "Plan it" feature that analyzes cash flow and suggests feasible contribution plans. |
| For complex financial data, clarity is paramount. Use clean layouts, highlight critical metrics, and choose the right chart (line for trends, bar for comparisons) to facilitate decision-making. | Best Practices | BUDG-004, BUDG-005, BUDG-011: Ensure all dashboards and reports adhere to these principles. |
| An events calendar component like `react-big-calendar` is well-suited for this task, with built-in support for month/week/day views, event drag-and-drop, and customization. | React Big Calendar | BUDG-006: Use `react-big-calendar` for the new `TransactionCalendarView`. |
| Automating tedious tasks like transaction categorization and subscription detection is a key value proposition for modern finance apps. | Monarch, Copilot | BUDG-007: Add support for creating rules to auto-categorize future transactions. |
| RHF + Zod is the industry standard for high-performance forms in React, ensuring type safety and a smooth UI. | RHF/Zod Patterns | Apply consistently to all budget forms (`TransactionDetailDrawer`, `CategoryEditorModal`, `AddGoalModal`, etc.). |

## 🧱 Cross-Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **BUDG-C01** | State Management | Zustand `budgetSlice` for date range, active view, filters, and selected items. URL sync for shareable filters. |
| **BUDG-C02** | Data Fetching | `useInfiniteQuery` for paginated data. `staleTime: 0` for transactions, longer for categories/goals. Optimistic mutations with rollback. |
| **BUDG-C03** | Form Handling | All settings forms use `react-hook-form` + `zod` + `@hookform/resolvers`; schemas are the single source of truth. |
| **BUDG-C04** | Accessibility | All charts must have accessible tabular counterparts. Color should not be the sole means of conveying information. |
| **BUDG-C05** | Feedback | All saves show subtle toast + inline confirmation. Destructive actions require confirmation. |
| **BUDG-C06** | Virtualization | TanStack Table + TanStack Virtual for all large lists. `VariableSizeList` for dynamic row heights. |
| **BUDG-C07** | Drag-and-Drop | dnd-kit for all drag interactions (Kanban, My Week, within-list reordering). Always provide a keyboard-accessible alternative (WCAG 2.5.7). |
| **BUDG-C08** | Motion | Respects `prefers-reduced-motion` for all Alive/Quiet tier animations. |
| **BUDG-C09** | Error Resilience | Each major view wrapped in `<ErrorBoundary>` with `<Suspense fallback={<Skeleton />}>`. |
| **BUDG-C10** | Offline Support | Dexie for local persistence of unsynced transactions and pending mutations. |

### 🎯 Motion Tier Assignment

| Component | Tier | Allowed Techniques |
|-----------|------|--------------------|
| View switcher active state | **Quiet** | Opacity fade 150ms; active indicator slides with `layout` prop |
| Project list rows | **Static** | Instant render; no animation |
| Kanban card (drag overlay) | **Alive** | Scale `1.02` + blue glow boxShadow; `rotate: 1deg` tilt |
| Kanban drop indicator | **Alive** | `scaleY: 0→1`, spring stiffness 400 damping 30 |
| Timeline bar entrance | **Alive** | `scaleX: 0→1`, `transformOrigin: 'left'`, staggered by task index |
| Timeline tooltip | **Quiet** | `AnimatePresence` opacity 150ms |
| Transaction calendar event drag/resize | **Alive** | Scale `1.02` + glow boxShadow on drag; `rotate: 1deg` tilt |
| Goal progress bar fill | **Alive** | `scaleX: 0→1`, `transformOrigin: 'left'` on initial load |

## 🧱 Task BUDG‑000: Budget Domain Model & Utilities
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** FND‑001 (TypeScript Base)

### Related Files
- `src/domain/budget/types.ts` · `src/domain/budget/utils.ts` · `src/domain/budget/derivations.ts`

### Subtasks

- [ ] **BUDG‑000A**: Define core types: `Account`, `Transaction`, `Category`, `Goal`, `RecurringItem`, `Holding`, `ReportConfig`, `BudgetPeriod`. Enums: `TransactionType`, `AccountType`, `SyncStatus`, `ReconciliationStatus`. **NEW**: Added `TransactionSource` ('past', 'scheduled', 'planned') to distinguish record type.
- [ ] **BUDG‑000B**: Define `BudgetRule` type for transaction rules (conditions + actions).
- [ ] **BUDG‑000C**: Implement currency/date utilities: Normalize amounts to minor units, parse/format dates and ranges, signed amounts for income vs expense.
- [ ] **BUDG‑000D**: Implement derivation helpers: Net worth, cash flow, category totals, budget utilization per category and per period, projected completion for goals.
- [ ] **BUDG‑000E**: **Tests**: Unit tests for all domain helpers and derivations.

### Definition of Done
- All budget-related entities share a consistent domain model.
- Utility functions are pure, typed, and covered by tests.

## 🗃️ Task BUDG‑001: Mock Data Layer & Query Contracts
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** BUDG‑000, FND‑004 (Testing), FND‑006 (TanStack Query)

### Related Files
- `src/mocks/factories/budget.ts` · `src/mocks/handlers/budget.ts` · `src/queries/budget.ts`

### Subtasks

- [ ] **BUDG‑001A**: Create `src/mocks/factories/budget.ts` with factories for `Account`, `Transaction`, `Category`, `Goal`, `Recurring`, `Holding`, `BudgetPeriod`.
- [ ] **BUDG‑001B**: Ensure factories produce:
  - 5–10 accounts, 20–50 transactions per period, 8–12 categories, 3–5 goals, 5–10 recurring items, 5–10 holdings.
  - **NEW**: `createMockPlannedTransaction()` factory for future-dated, non-recurring planned spending/saving.
  - **NEW**: `createMockRecurring()` must support complex RRULE-like patterns: "Every 2 weeks on Friday," "Last day of the month," etc.
  - **NEW**: `createMockNetWorthGoal()` and `createMockPaydownGoal()` for goal system.
- [ ] **BUDG‑001C**: Create `src/mocks/handlers/budget.ts` covering all CRUD endpoints (accounts, transactions, categories, goals, recurring, periods, reconciliation, holdings, reports, import/export, rules).
- [ ] **BUDG‑001D**: Create `src/queries/budget.ts` with query key factory for all entities.
- [ ] **BUDG‑001E**: Define `transactionsInfiniteQueryOptions` with `getNextPageParam` (cursor-based) and `maxPages` to limit cached pages.
- [ ] **BUDG‑001F**: Create mutation hooks with optimistic updates (`useCreateTransaction`, `useUpdateTransaction`, etc.).
- [ ] **BUDG‑001G**: **Tests**: Hook tests for transactions infinite query (initial load, load-more, end-of-list, error, empty state).
- [ ] **BUDG‑001H**: **Tests**: Mutation tests for optimistic updates and rollback.

### Definition of Done
- Mock data and handlers power all budget endpoints.
- Query keys and options are type-safe and covered by tests.
- All mutations follow optimistic update with rollback patterns.

## 🔧 Task BUDG‑002: Budget State Management & URL Sync
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** BUDG‑001, FND‑005 (Zustand), FND‑007 (Router)

### Related Files
- `src/stores/slices/budgetSlice.ts` · `src/lib/queryClient.ts` · `src/hooks/useBudgetUrlState.ts`

### Subtasks

- [ ] **BUDG‑002A**: Create `budgetSlice` interface with state for date range, selected account, filters, active view, and active report. **NEW**: Added `visibleTransactionTypes` to toggle view of past, scheduled, planned events.
- [ ] **BUDG‑002B**: Export atomic selector hooks (`useBudgetDateRange`, `useBudgetFilters`, `useBudgetActiveView`, etc.).
- [ ] **BUDG‑002C**: Implement `useBudgetUrlState()` to sync filters, date range, active view, and active report to query params, and hydrate Zustand state from URL on load.
- [ ] **BUDG‑002D**: Update `queryClient.ts` with appropriate `staleTime` defaults for various budget data.
- [ ] **BUDG‑002E**: **Tests**: Unit tests for slice actions and selectors.
- [ ] **BUDG‑002F**: **Tests**: Integration tests for URL ↔ state sync.

### Definition of Done
- Budget UI state is centralized and URL-synced.
- Query client defaults align with financial freshness requirements.

## 🧩 Task BUDG‑003: Budget Route Shell, Suspense & Error Boundaries
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** BUDG‑002

### Related Files
- `src/pages/BudgetPage.tsx` · `src/components/budget/BudgetLayout.tsx` · `src/components/budget/BudgetErrorBoundary.tsx` · `src/components/budget/BudgetSkeletons.tsx`

### Subtasks

- [ ] **BUDG‑003A**: Create `BudgetPage` route with horizontal secondary nav (Overview, Planner, Transactions, Goals, Accounts, Recurring, Investments, Reports). **NEW**: Added "Calendar" view to the navigation items.
- [ ] **BUDG‑003B**: Implement `BudgetLayout` with top-level Suspense boundary, top-level ErrorBoundary, and child boundaries per major section.
- [ ] **BUDG‑003C**: Add skeletons for dashboard cards, tables, and forms.
- [ ] **BUDG‑003D**: Add generic empty states per section (no transactions, no goals, no recurring items, no holdings).
- [ ] **BUDG‑003E**: Implement `BudgetErrorBoundary` with friendly error message, "Try again" button, and support link.
- [ ] **BUDG‑003F**: Wire TanStack Query error states into boundaries and toast notifications.
- [ ] **BUDG‑003G**: **Tests**: Tests for loading, error, and empty states per section.
- [ ] **BUDG‑003H**: **Tests**: Tests for retry behavior and boundary resets.

### Definition of Done
- Budget route has robust navigation, loading, and error handling.
- Individual section failures do not break the entire budget area.

## 📊 Task BUDG‑004: Budget Overview Dashboard
**Priority:** 🔴 High | **Est. Effort:** 3.5 hours | **Depends On:** BUDG‑001, BUDG‑003

### Related Files
- `src/components/budget/BudgetDashboard.tsx` · `src/components/budget/NetWorthCard.tsx` · `src/components/budget/CashFlowSummary.tsx` · `src/components/budget/BudgetCategoryCard.tsx` · `src/components/budget/SpendingTrendChart.tsx` · `src/components/budget/OverviewDataTable.tsx`

### Subtasks

- [ ] **BUDG‑004A**: Implement `BudgetDashboard` as default view for `/budget`.
- [ ] **BUDG‑004B**: Layout with net worth/cash flow row, category utilization grid, spending trend chart with drill-down link to Transactions.
- [ ] **BUDG‑004C**: Install `react-sparkline-chart` if not present.
- [ ] **BUDG‑004D**: Implement `NetWorthCard` with total net worth, delta vs last month, 12-month sparkline, and assets/liabilities breakdown.
- [ ] **BUDG‑004E**: Implement `CashFlowSummary` with income, expenses, net savings, savings rate, and progress vs monthly target.
- [ ] **BUDG‑004F**: Implement category cards with planned vs actual, percent used, color-coded thresholds, and hover popover showing last 5 transactions.
- [ ] **BUDG‑004G**: Implement `SpendingTrendChart` with Recharts (line/bar toggle; 3M/6M/1Y range), respecting reduced motion preference.
- [ ] **BUDG‑004H**: Implement `OverviewDataTable` as accessible numeric summary for charts.
- [ ] **BUDG‑004I**: **Tests**: Tests for net worth calculation and sparkline rendering.
- [ ] **BUDG‑004J**: **Tests**: Tests for category card thresholds and popover loading.
- [ ] **BUDG‑004K**: **Tests**: Tests for chart mode toggle, range selection, and reduced-motion behavior.

### Definition of Done
- Overview dashboard shows key metrics and chart/table pairs.
- All charts have accessible tabular counterparts.

## 📅 Task BUDG‑005: Budget Planner & Category Management
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** BUDG‑002, BUDG‑001

### Related Files
- `src/pages/BudgetPlannerPage.tsx` · `src/components/budget/BudgetPlanner.tsx` · `src/components/budget/CategoryEditorModal.tsx`

### Subtasks

- [ ] **BUDG‑005A**: Create `BudgetPlannerPage` with month selector, category allocation grid, and summary (planned vs actual, remaining, overspend). **NEW**: Add a "Forecast" toggle that overlays planned and scheduled transactions from the calendar onto the current budget view.
- [ ] **BUDG‑005B**: Implement allocations (planned amount per category, rollover options, carryover display from previous month).
- [ ] **BUDG‑005C**: Implement category actions (add/edit/archive categories, reorder categories within groups).
- [ ] **BUDG‑005D**: Implement `CategoryEditorModal` using `react-hook-form` + `zodResolver`.
- [ ] **BUDG‑005E**: Enforce validation rules for name, color, allocation, and rollover settings.
- [ ] **BUDG‑005F**: **Tests**: Tests for allocation math, rollover behavior, overspend status.
- [ ] **BUDG‑005G**: **Tests**: Tests for category add/edit/archive and planner persistence.

### Definition of Done
- Users can set and manage monthly budgets per category.
- Planner reflects actual spending and rollover rules.

## 💰 Task BUDG‑006: Transactions Workspace (Virtualized List & Financial Calendar)
**Priority:** 🔴 High | **Est. Effort:** 3.5 hours | **Depends On:** BUDG‑001, BUDG‑002

### Related Files
- `src/pages/TransactionsPage.tsx` · `src/components/budget/TransactionList.tsx` · `src/components/budget/TransactionCalendarView.tsx` · `src/components/budget/PlannedTransactionModal.tsx`

### Subtasks

- [ ] **BUDG‑006A**: Implement `useTransactionsInfinite()` with `useInfiniteQuery` (cursor-based pagination, page size 50).
- [ ] **BUDG‑006B**: Implement filter/search UI (debounced search bar, date range, category multi-select, etc.).
- [ ] **BUDG‑006B1** (NEW): Implement `TransactionCalendarView` using `react-big-calendar` with month/week/day views. Merges Past, Scheduled, and Planned transactions onto a single calendar, with days showing a net total (green/red). Click a day filters the virtualized transaction list.
- [ ] **BUDG‑006B2** (NEW): Add view toggle to the top of the TransactionPage: `[SegmentedControl: "List"] [SegmentedControl: "Calendar"]`.
- [ ] **BUDG‑006C**: Implement `TransactionList` using `react-window` `VariableSizeList` with `estimatedItemSize`, height measurement cache, and `resetAfterIndex`.
- [ ] **BUDG‑006C1** (NEW): Extend the "Add Transaction" `Dialog` to support `type: 'past' | 'planned'`. If `planned`, the date picker defaults to a future date and includes an option to make it recurring.
- [ ] **BUDG‑006D**: Implement `TransactionRow` with date, merchant, category badge, account, amount, and click-to-open-drawer. **NEW**: Visually distinguish `past`, `scheduled`, and `planned` entries.
- [ ] **BUDG‑006D1** (NEW): In `TransactionCalendarView`, past transactions are read-only "events". Scheduled and Planned transactions are draggable and resizable (fires optimistic update).
- [ ] **BUDG‑006E**: Implement selection and bulk actions (checkbox per row, select-all, bulk recategorize, bulk tag, bulk delete).
- [ ] **BUDG‑006F**: Use semantic table structure with sortable headers and ARIA attributes.
- [ ] **BUDG‑006G**: **Tests**: Tests for virtualized rendering and pagination.
- [ ] **BUDG‑006H**: **Tests**: Tests for filter behavior and URL persistence.
- [ ] **BUDG‑006I**: **Tests**: Tests for bulk actions and selection UX.

### Definition of Done
- Transactions workspace supports virtualized infinite scroll, rich filtering, and a fully interactive Financial Calendar view.
- Users can add, edit, and reschedule one-time and recurring future transactions directly from both the list and calendar views.

## 🔍 Task BUDG‑007: Transaction Detail Drawer, Split Transactions & Rules
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** BUDG‑006

### Related Files
- `src/components/budget/TransactionDetailDrawer.tsx` · `src/schemas/transactionSchema.ts` · `src/components/budget/TransactionRulesForm.tsx`

### Subtasks

- [ ] **BUDG‑007A**: Create `transactionSchema` using Zod.
- [ ] **BUDG‑007B**: Create `transactionRuleSchema` for rules (conditions: merchant, description, amount range, account; actions: set category, tags, notes, rename merchant). **NEW**: Rules now support applying to both past and future transactions.
- [ ] **BUDG‑007C**: Implement `TransactionDetailDrawer` with shadcn `Sheet`, fetching the transaction by ID and using RHF with Zod resolver.
- [ ] **BUDG‑007D**: Implement optimistic update on save and delete using mutation hooks.
- [ ] **BUDG‑007E**: Implement split editor (add/remove lines, each with category, amount, validation).
- [ ] **BUDG‑007F**: Implement `TransactionRulesForm` for creating rules from a transaction, showing a preview of what would change.
- [ ] **BUDG‑007G**: Implement focus trapping, escape-to-close, and focus restoration.
- [ ] **BUDG‑007H**: **Tests**: Tests for drawer open/close, validation, split math.
- [ ] **BUDG‑007I**: **Tests**: Tests for rule creation and application preview.
- [ ] **BUDG‑007J**: **Tests**: Tests for optimistic updates and rollback.

### Definition of Done
- Transaction drawer supports full edit, split, and rule creation workflows.
- Users can create robust rules to automate the categorization and management of their financial calendar.

## 🎯 Task BUDG‑008: Goals Page (Saving & Payoff Goals)
**Priority:** 🟠 Medium | **Est. Effort:** 3 hours | **Depends On:** BUDG‑002, BUDG‑001

### Related Files
- `src/pages/GoalsPage.tsx` · `src/components/budget/GoalCard.tsx` · `src/components/budget/AddGoalModal.tsx`

### Subtasks

- [ ] **BUDG‑008A**: Implement `GoalsPage` with Saving and Payoff sections.
- [ ] **BUDG‑008B**: Implement `GoalCard` with target, current, progress, monthly contribution, projected completion date, and details for payoff goals (creditor, interest rate, etc.).
- [ ] **BUDG‑008C**: Implement `AddGoalModal` using RHF + Zod. **NEW**: Add a "Feasibility Score" panel that analyzes the user's financial calendar and projected cash flow to determine if the goal's target monthly contribution and date are realistic.
- [ ] **BUDG‑008D**: Wire `useCreateGoal()` and `useUpdateGoal()` with optimistic updates.
- [ ] **BUDG‑008E**: **Tests**: Tests for create/edit flows, projection logic, and the new feasibility analysis.

### Definition of Done
- Goals page manages saving and payoff goals with projections and feasibility analysis.
- Optimistic updates keep UI responsive.

## 🏦 Task BUDG‑009: Accounts Page, Reconciliation & Sync Status
**Priority:** 🟠 Medium | **Est. Effort:** 3 hours | **Depends On:** BUDG‑002, BUDG‑001

### Related Files
- `src/pages/AccountsPage.tsx` · `src/components/budget/AccountCard.tsx` · `src/components/budget/AccountDetailDrawer.tsx` · `src/components/budget/ReconciliationPanel.tsx`

### Subtasks

- [ ] **BUDG‑009A**: Implement grouped accounts by type with balances and utilization.
- [ ] **BUDG‑009B**: Add "last synced" indicator and manual refresh button per institution.
- [ ] **BUDG‑009C**: Implement `ReconciliationPanel` for unmatched transactions, potential duplicates, and match suggestions.
- [ ] **BUDG‑009D**: Implement actions for accept, ignore, merge duplicates.
- [ ] **BUDG‑009E**: Implement `AccountDetailDrawer` with balance history mini-chart and account-level settings.
- [ ] **BUDG‑009F**: Implement `useUnlinkAccount()` and `useUpdateAccountSyncStatus()` with optimistic updates.
- [ ] **BUDG‑009G**: **Tests**: Tests for grouping, sync status, and refresh flows.
- [ ] **BUDG‑009H**: **Tests**: Tests for reconciliation actions and account unlink behavior.

### Definition of Done
- Accounts view surfaces balances, sync status, and reconciliation actions.
- Users can resolve duplicates and unmatched entries.

## 🔄 Task BUDG‑010: Recurring Page & Cash-Flow Forecast
**Priority:** 🟠 Medium | **Est. Effort:** 3 hours | **Depends On:** BUDG‑002, BUDG‑001

### Related Files
- `src/pages/RecurringPage.tsx` · `src/components/budget/RecurringItemRow.tsx` · `src/components/budget/RecurringCalendar.tsx` · `src/components/budget/CashFlowForecast.tsx`

### Subtasks

- [ ] **BUDG‑010A**: Implement `RecurringPage` with tabs for Bills & Subscriptions / Income. **NEW**: Ensure this page features a prominent `RecurringCalendar` as a core component, not a separate tab.
- [ ] **BUDG‑010B**: Implement `RecurringItemRow` with edit/delete and active toggle. **NEW**: Expand row to display recurrence summary (e.g., "Monthly on the 15th").
- [ ] **BUDG‑010C**: Implement `RecurringCalendar` using the existing calendar library (or `react-big-calendar`) to show next 30 days of recurring items. **NEW**: The calendar should support directly dragging to reschedule an instance of a recurring item.
- [ ] **BUDG‑010C1** (NEW): Implement an "Edit Series" modal that provides standard calendar series options: "This Instance Only," "This and All Future Instances," "All Instances."
- [ ] **BUDG‑010D**: Implement `CashFlowForecast` with a projected balance curve (Recharts) considering recurring items and known income. Highlight dates with potential shortfall.
- [ ] **BUDG‑010E**: Wire `useUpdateRecurring()` mutation with optimistic toggle.
- [ ] **BUDG‑010F**: **Tests**: Tests for calendar rendering, projection logic, toggles, and the new series editing modal.

### Definition of Done
- Recurring items are manageable with a visual forecast of upcoming cash flow.
- Users have granular control over editing individual instances or entire series.

## 📈 Task BUDG‑011: Investments Page, Reports & Data Import/Export
**Priority:** 🟢 Low | **Est. Effort:** 3.5 hours | **Depends On:** BUDG‑002, BUDG‑001

### Related Files
- `src/pages/InvestmentsPage.tsx` · `src/pages/ReportsPage.tsx` · `src/components/budget/AssetAllocationDonut.tsx` · `src/components/budget/PerformanceChart.tsx` · `src/components/budget/ReportsList.tsx` · `src/components/budget/ReportDataTable.tsx` · `src/components/budget/ImportTransactionsModal.tsx`

### Subtasks

- [ ] **BUDG‑011A**: Implement `InvestmentsPage` with portfolio summary and holdings table.
- [ ] **BUDG‑011B**: Implement `AssetAllocationDonut` using Recharts `PieChart` with `innerRadius`, animating segments on mount and respecting reduced motion.
- [ ] **BUDG‑011C**: Implement `PerformanceChart` with time-range toggle.
- [ ] **BUDG‑011D**: Implement `ReportsPage` with pre-built and custom report slots.
- [ ] **BUDG‑011E**: Implement date range filter and saved report presets. **NEW**: Reports now support toggling inclusion of `past`, `scheduled`, and `planned` transactions.
- [ ] **BUDG‑011F**: Implement CSV export with progress toast.
- [ ] **BUDG‑011G**: Implement `ReportDataTable` components as accessible tabular views parallel to charts.
- [ ] **BUDG‑011H**: Implement `ImportTransactionsModal` with file upload, preview, column mapping, conflict warnings.
- [ ] **BUDG‑011I**: Wire mock preview and commit endpoints.
- [ ] **BUDG‑011J**: **Tests**: Tests for chart rendering, export initiation, and data tables.
- [ ] **BUDG‑011K**: **Tests**: Tests for import preview, mapping, and commit flows.

### Definition of Done
- Investments and reports pages offer both charts and accessible tables.
- Users can import and export transaction data reliably.

## 💾 Task BUDG‑012: Offline-First Support, PWA & Sync Engine
**Priority:** 🔴 High | **Est. Effort:** 3.5 hours | **Depends On:** BUDG‑006, BUDG‑007, BUDG‑009

### Related Files
- `src/lib/db.ts` · `src/hooks/useOfflineTransactions.ts` · `src/components/budget/OfflineStatusBar.tsx` · `public/service-worker.js`

### Subtasks

- [ ] **BUDG‑012A**: Install and configure Dexie in `src/lib/db.ts` with stores for `transactions`, `pendingMutations`, `syncMetadata`. **NEW**: Store for `offlineRules`.
- [ ] **BUDG‑012B**: Define schema versioning and indexes.
- [ ] **BUDG‑012C**: Implement `useOfflineTransactions()` to write to Dexie and queue mutations when offline, then sync when online. **NEW**: The sync engine now handles both offline transaction creation and newly created rules.
- [ ] **BUDG‑012D**: Implement service worker with caching and background sync for queued POST/PUT/DELETE where supported.
- [ ] **BUDG‑012E**: Fallback to online/offline events when Background Sync is unavailable.
- [ ] **BUDG‑012F**: Implement `OfflineStatusBar` showing offline state, number of pending changes, and last sync time.
- [ ] **BUDG‑012G**: Provide manual "Sync now" and "Retry failed" actions.
- [ ] **BUDG‑012H**: **Tests**: Tests for offline transaction creation and local persistence.
- [ ] **BUDG‑012I**: **Tests**: Tests for reconnect sync, conflict resolution, and deduplication.
- [ ] **BUDG‑012J**: **Tests**: Tests for background sync fallback behavior.

### Definition of Done
- Budget module operates offline with queued mutations and reliable sync.
- Users can see and control sync status and pending changes.

## 🆕 Task BUDG-013: Financial Planning Dashboard (NEW)
**Priority:** 🟠 Medium | **Est. Effort:** 3.5 hours | **Depends On:** BUDG‑006

A dedicated "Home" view that acts as a true "Calendar Week View" for money, similar to Monarch's customizable dashboard. It provides an at-a-glance summary of upcoming cash flow and key metrics.

### Related Files
- `src/pages/FinancialHomePage.tsx` · `src/components/budget/HomeCashFlowTimeline.tsx` · `src/components/budget/HomeGoalsTracker.tsx` · `src/components/budget/HomeBudgetCategories.tsx`

### Subtasks
- [ ] **BUDG‑013A**: Create a new route for the Financial Planning Home (e.g., `/plan`).
- [ ] **BUDG‑013B**: Implement a **7-Day Cash Flow Timeline** component that visualizes daily net totals (green/red) and upcoming bills.
- [ ] **BUDG‑013C**: Implement a **Top 3 Goals Tracker** section showing progress, monthly contribution amount, and whether you are on track.
- [ ] **BUDG‑013D**: Implement a **Budget Category Summary** section showing top 3-5 active budget categories with a progress bar and quick-add planned transaction popover.
- [ ] **BUDG‑013E**: **Tests**: Tests for all new components and their integration with the rest of the budget module.

### Definition of Done
- A new, focused financial home page provides a calendar-centric view of cash flow, goals, and budgets.

## 🆕 Task BUDG-014: AI-Powered Anomaly Detection & Insights (NEW)
**Priority:** 🟢 Low | **Est. Effort:** 2.5 hours | **Depends On:** BUDG‑004

This task brings in a trend from apps like Copilot and FinSight: proactive, AI-powered insights to help users understand their financial health.

### Related Files
- `src/components/budget/SpendingInsightsCard.tsx` · `src/hooks/useSpendingInsights.ts`

### Subtasks
- [ ] **BUDG‑014A**: Create a `useSpendingInsights` hook that analyzes transaction data (via mock AI or simple statistical rules) for anomalies like "spending spike in groceries" or "unusual merchant."
- [ ] **BUDG‑014B**: Implement a `SpendingInsightsCard` component to be displayed on the Overview Dashboard.
- [ ] **BUDG‑014C**: The card shows 1-3 key insights, such as "You spent 30% more on dining this month than last" or "Your Amazon spending is up 15%."
- [ ] **BUDG‑014D**: Each insight includes a call to action, like "Review transactions" or "Adjust budget."
- [ ] **BUDG‑014E**: **Tests**: Tests for insight logic and component rendering.

### Definition of Done
- Users receive proactive, non-judgmental insights into their spending patterns on the main dashboard.

## ✅ Task BUDG‑015: Quality Gates, Testing & Accessibility
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** All BUDG tasks

### Related Files
- `package.json` (scripts) · `vitest.config.ts` · `src/tests/budget/*.test.tsx` · `src/tests/budget/accessibility.test.tsx`

### Subtasks

- [ ] **BUDG‑015A**: Ensure unit tests cover domain utilities, selectors, schemas, and pure derivations.
- [ ] **BUDG‑015B**: Ensure integration tests cover query hooks, optimistic mutations, forms, error boundaries, and route transitions.
- [ ] **BUDG‑015C**: Add E2E tests for critical flows: Load overview, Filter transactions, Edit/split transaction, Offline add → reconnect sync → verify UI, Create a goal and see feasibility score.
- [ ] **BUDG‑015D**: Run automated accessibility checks (axe) on all budget pages.
- [ ] **BUDG‑015E**: Verify table semantics, keyboard navigation, focus order, color contrast, and reduced-motion behavior.
- [ ] **BUDG‑015F**: Add tests or checks for infinite query cache size, `maxPages` configuration, and virtualized list performance.
- [ ] **BUDG‑015G**: Verify error boundaries and Suspense boundaries handle failures gracefully.

**Definition of Done**
- All BUDG tasks have passing tests.
- Accessibility checks show no WCAG 2.2 AA violations for the budget module.
- Budget module is performance-conscious, resilient, and ready for production.

## 📊 Dependency Graph

```
BUDG‑000 (Domain Model & Utilities)
     │
BUDG‑001 (Mock Data & Queries)
     │
BUDG‑002 (State & URL Sync)
     │
BUDG‑003 (Route Shell & Boundaries)
     │
     ├── BUDG‑004 (Overview Dashboard)
     ├── BUDG‑005 (Planner & Category Mgmt)
     ├── BUDG‑006 (Transactions Workspace)
     │       │
     │       └── BUDG‑007 (Transaction Detail & Rules)
     ├── BUDG‑008 (Goals Page)
     ├── BUDG‑009 (Accounts & Reconciliation)
     ├── BUDG‑010 (Recurring & Forecast)
     ├── BUDG‑011 (Investments, Reports & Import)
     ├── BUDG‑012 (Offline & Sync Engine)
     ├── BUDG-013 (Financial Home Page - NEW)
     └── BUDG-014 (AI-Powered Insights - NEW)

BUDG‑015 (Quality Gates) — depends on all tasks
```