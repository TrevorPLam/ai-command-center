---
name: analytics-components
description: Guides the creation of analytics components including CostAnalyticsPage, CostBreakdownChart, BudgetOverview, AuditLogPage, and AuditEntryRow for tracking AI usage and system activity
---

## Analytics Components

### CostAnalyticsPage.tsx (`/settings/analytics`)
Main analytics page for cost tracking.

**Budget Overview (BudgetOverview.tsx):**
- Monthly token budget vs actual spend
- Progress bar: green < 80%, amber 80-99%, red ≥ 100%
- Warning threshold indicator
- Days remaining in month
- Projected monthly spend
- Reset budget button

**Cost Breakdown Chart (CostBreakdownChart.tsx):**
- Bar chart showing cost by model (GPT-4, Claude, etc.)
- Line chart showing cost over time (daily, weekly, monthly)
- Toggle: Per-model breakdown / Total cost
- Time range selector: 7D / 30D / 90D / All
- Download CSV button (mocked)
- Hover tooltips with detailed breakdown

**Model Performance:**
- Table showing: Model name, Total tokens, Cost, Avg response time, Error rate
- Sortable columns
- Filter by model type

**Usage Patterns:**
- Peak usage hours (heat map)
- Most used features
- Token efficiency metrics

### AuditLogPage.tsx (`/settings/analytics/audit`)
Chronological log of all system actions.

**Filter bar:**
- Date range picker
- Action type filter (Tool Call / API Request / User Action / System Event)
- Severity filter (Info / Warning / Error / Critical)
- User filter
- Search input

**Audit Entry List:**
- Each AuditEntryRow shows: timestamp, action type, user/agent, description, severity badge, details button
- Sort by timestamp (newest first)
- Pagination: 50 per page
- Export log button (mocked)

### AuditEntryRow.tsx
- Timestamp (formatted)
- Action type badge (colored)
- User/agent name + avatar
- Description (one line, truncated)
- Severity badge (Info: blue, Warning: amber, Error: red, Critical: purple)
- Details button (chevron)
- Expand: shows full details with JSON payload
- Hover: subtle white/8 background

## Data Requirements

All analytics components must use realistic mock data from `src/lib/mockData/settings.ts` with:
- Cost data by model and time period
- Budget settings and thresholds
- Audit log entries with various action types and severities
- Usage patterns and metrics

## State Management

- Use TanStack Query for fetching analytics data
- Use Zustand for UI-only state (filters, date range, expanded rows)
- Use recharts for charts (bar, line, heat map)

## Accessibility Requirements (WCAG 2.2 AA)

- CostAnalyticsPage: proper ARIA landmarks (main, nav, aside), semantic HTML
- CostBreakdownChart: aria-labels, keyboard navigation for interactive charts, role="img"
- AuditLogPage: table role, proper column headers, scope attributes
- AuditEntryRow: aria-expanded state for details, proper button roles
- All interactive elements: 7:1 color contrast ratio minimum
- Filter controls: proper labels, aria-describedby for help text
- Focus management: visible focus indicators, logical tab order
- Dynamic content: aria-live regions for real-time updates
- Screen readers: announce sorting/filtering changes
- Keyboard navigation: all interactive elements reachable via keyboard

## Visual Identity

- Glass panels: backdrop-blur-md bg-white/5 border border-white/10 rounded-xl
- Electric blue accent: #0066ff → #00aaff for CTAs and active states
- Severity colors: Info (blue), Warning (amber), Error (red), Critical (purple)
- Progress bars: green (< 80%), amber (80-99%), red (≥ 100%)
- 150ms ease-out transitions on all interactive elements
- Skeleton loaders on all data fetch states

**Tailwind v3 & shadcn/ui Notes (2026):**
- shadcn/ui uses Tailwind v3 with standard CSS configuration
- Components use forwardRef for ref forwarding (React 18 pattern)
- HSL colors are used in standard format
- Default style is available; use new-york style if preferred

## Chart Implementation

- Use recharts for all charts
- Bar chart: cost by model
- Line chart: cost over time
- Heat map: peak usage hours
- Pie chart: cost distribution
- All charts: responsive, tooltips, legends
- Dark theme colors for charts
- Export as PNG option (mocked)

## Data Visualization

- Show absolute numbers and percentages
- Use compact notation for large numbers (1.2M, 345K)
- Color-code by severity or threshold
- Show trend indicators (up/down arrows)
- Hover for detailed breakdowns
- Compare to previous period (week-over-week, month-over-month)
