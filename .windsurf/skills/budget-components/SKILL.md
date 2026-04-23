---
name: budget-components
description: Guides the creation of budget and finance components including BudgetDashboard, TransactionList, GoalsPage, AccountsPage, RecurringPage, InvestmentsPage, and ReportsPage with comprehensive financial tracking
---

## Budget Components

### BudgetPage.tsx
Main budget page with secondary navigation.

**Secondary Nav Tabs:**
- Overview | Transactions | Goals | Accounts | Recurring | Investments | Reports

### BudgetDashboard.tsx (`/budget`)

**NetWorthCard.tsx:**
- Large number: total net worth
- Delta vs last month (green arrow up / red down)
- Sparkline chart (last 12 months)
- Breakdown: Assets total vs Liabilities total

**CashFlowSummary.tsx:**
- This month: Income vs Expenses, net savings
- Savings rate % (large, colored: green if positive)
- Progress bar: spending vs monthly budget cap

**Budget Categories section:**
- Grid of BudgetCategoryCard components
- Each card: category icon + name (Housing, Food & Dining, Transportation, Entertainment, Health, Shopping, Subscriptions, Personal Care, Savings, Investments, Other)
- Planned vs Actual amounts
- Progress bar: green < 80%, amber 80–99%, red ≥ 100%
- % of budget used
- Clicking opens filtered transaction list

**SpendingTrendChart.tsx:**
- Line chart: last 12 months of spending by category (stacked or individual, togglable)
- Bar chart option: monthly income vs expenses
- Use recharts or simple SVG chart
- Chart type toggle (Line / Bar)
- Time range selector (3M / 6M / 1Y)

**Recent Transactions:** last 5 transactions with "View All" link to `/budget/transactions`

### TransactionList.tsx (`/budget/transactions`)
- Search bar
- Filter: Date range picker, Category multi-select, Account multi-select, Amount range (min/max), Transaction type (Income / Expense / Transfer)
- Sort: Date / Amount / Category / Merchant
- Each TransactionRow: date, merchant name + logo placeholder, category badge, account name, amount (red for expense, green for income)
- Clicking row opens TransactionDetailDrawer (right sheet)
- Pagination: 50 per page, load more button

### TransactionRow.tsx
- Date (formatted)
- Merchant name + logo placeholder
- Category badge
- Account name
- Amount (colored: red for expense, green for income)
- Hover: subtle white/8 background
- Click: opens TransactionDetailDrawer

### TransactionDetailDrawer.tsx
Right-side sheet (320px):
- Merchant name + logo
- Date
- Amount (large, colored)
- Category selector (editable)
- Account selector
- Notes textarea
- Split transaction option
- Tags
- Recurring toggle
- Edit + Delete buttons

### GoalsPage.tsx (`/budget/goals`)
Two sections:

**Saving Goals:** Cards for goals like Emergency Fund, Vacation, Down Payment
- Each GoalCard: goal name, target amount, current amount, progress bar, monthly contribution, projected completion date, Edit button

**Payoff Goals:** Cards for debts (credit card, student loan, auto)
- Each card: creditor, balance remaining, interest rate, minimum payment, payoff progress bar, projected payoff date, Edit button

"Add Goal" button opens modal: Goal type (Save / Pay off), Name, Target amount, Target date, Monthly contribution amount.

### GoalCard.tsx
- Goal name
- Target amount vs current amount
- Progress bar (animated)
- Monthly contribution
- Projected completion date
- Edit button
- Hover: subtle lift

### AccountsPage.tsx (`/budget/accounts`)
Groups connected accounts by type:

- **Checking & Savings:** Account name, institution name, balance, last synced timestamp
- **Credit Cards:** Account name, institution, current balance, credit limit, utilization % progress bar
- **Loans:** Account name, institution, remaining balance, interest rate, monthly payment
- **Investments:** Account name, institution, current value, day change ($ and %)
- **Real Estate / Assets:** Custom assets with estimated value and last updated date

Each AccountCard: logo placeholder, name, institution, balance (large), secondary metrics, Edit + Unlink buttons. "Add Account" button at top.

### AccountCard.tsx
- Logo placeholder
- Account name
- Institution name
- Balance (large)
- Secondary metrics (utilization, interest rate, etc.)
- Edit + Unlink buttons
- Hover: subtle lift

### RecurringPage.tsx (`/budget/recurring`)
Two tabs: **Bills & Subscriptions** | **Income**

Each RecurringItemRow: merchant/source name, amount, frequency (monthly/weekly/annual), next date, days until next, category badge, active toggle, Edit + Delete.

Calendar view toggle: shows upcoming recurring items on mini calendar for next 30 days. Color-coded: red = bill, green = income.

"Cash Flow Readiness" panel: shows upcoming 7-day cash flow projection — income in vs. bills out, net daily balance.

### RecurringItemRow.tsx
- Merchant/source name
- Amount
- Frequency badge
- Next date
- Days until next
- Category badge
- Active toggle
- Edit + Delete buttons
- Hover: subtle white/8 background

### InvestmentsPage.tsx (`/budget/investments`)
- **Portfolio Summary:** total value, day change, all-time gain/loss ($ and %)
- Holdings table: Symbol/Name, shares, current price, market value, day change, all-time return %, asset type badge
- Asset allocation donut chart (Stocks / Bonds / Cash / Real Estate / Other)
- Performance chart: portfolio value over time (1W / 1M / 3M / 6M / 1Y / All)

### InvestmentHoldingRow.tsx
- Symbol/Name
- Shares
- Current price
- Market value
- Day change ($ and %)
- All-time return %
- Asset type badge
- Hover: subtle white/8 background

### ReportsPage.tsx (`/budget/reports`)
Pre-built report cards:
- **Income vs Expenses** (by month, bar chart)
- **Spending by Category** (pie + table)
- **Net Worth Over Time** (line chart)
- **Savings Rate Trend** (line chart)
- **Year-in-Review** summary card (total income, total spend, total saved, top category, biggest month)

Each report has: date range picker, Download CSV / Download PNG button (mocked, shows toast).

## Data Requirements

All budget components must use realistic mock data from `src/lib/mockData/budget.ts` and `src/lib/mockData/transactions.ts` with:
- Realistic monetary values
- Various transaction types and categories
- Multiple accounts with different types
- Goals with progress tracking
- Recurring items with various frequencies
- Investment holdings with performance data

## State Management

- Use TanStack Query for fetching all budget data
- Use Zustand for UI-only state (active tab, filters, drawer open/close)
- Use recharts for charts (line, bar, pie, donut)

## Accessibility Requirements (WCAG 2.2 AA)

- BudgetPage: proper ARIA landmarks (main, nav), semantic HTML, keyboard navigation for tabs
- TransactionList: table role, proper column headers, scope attributes, sortable column indicators
- TransactionDetailDrawer: focus trap when open, role="dialog", aria-modal="true"
- All forms: proper labels, error announcements, aria-invalid for invalid fields
- Charts: aria-labels, keyboard navigation for interactive charts, role="img"
- All interactive elements: 4.5:1 color contrast ratio minimum
- Focus management: visible focus indicators, focus restoration after drawer close
- Dynamic content: aria-live regions for real-time updates
- Screen readers: announce balance changes, transaction additions
- Keyboard navigation: all interactive elements reachable via keyboard, escape to close modals

## Visual Identity

- Glass panels: backdrop-blur-md bg-white/5 border border-white/10 rounded-xl
- Electric blue accent: #0066ff → #00aaff for CTAs and active states
- Financial colors: Income (green), Expense (red), Neutral (gray)
- Progress bars: green (< 80%), amber (80-99%), red (≥ 100%)
- 150ms ease-out transitions on all interactive elements
- Skeleton loaders on all data fetch states

**Tailwind v3 & shadcn/ui Notes (2026):**
- shadcn/ui uses Tailwind v3 with standard CSS configuration
- Components use forwardRef for ref forwarding (React 18 pattern)
- HSL colors are used in standard format
- Default style is available; use new-york style if preferred

## Number Formatting

- Use proper currency formatting ($1,234.56)
- Show percentages with 1 decimal place (12.3%)
- Use compact notation for large numbers ($1.2M, $345K)
- Respect user locale settings
