---
trigger: glob
globs: src/App.tsx, src/main.tsx, src/components/layout/*.tsx
---

# React Router v6 Rules

This project uses React Router v6 for client-side routing. Follow these patterns.

Note: React Router v7 was released in November 2024, but this project is locked to v6 per tech-stack constraints.

<router_setup>
- Use createBrowserRouter for route configuration
- Define all routes in a central router configuration
- Use BrowserRouter in main.tsx to wrap the app
- Configure error boundaries for route-level error handling
</router_setup>

<route_structure>

```typescript
// src/router/index.tsx
import { createBrowserRouter, Navigate } from 'react-router-dom';
import { Layout } from '@/components/layout/Layout';
import { Dashboard } from '@/pages/Dashboard';
import { Chat } from '@/pages/Chat';
import { Projects } from '@/pages/Projects';
import { ProjectDetail } from '@/pages/ProjectDetail';
import { Calendar } from '@/pages/Calendar';
import { News } from '@/pages/News';
import { Budget } from '@/pages/Budget';
import { BudgetTransactions } from '@/pages/BudgetTransactions';
import { BudgetGoals } from '@/pages/BudgetGoals';
import { BudgetAccounts } from '@/pages/BudgetAccounts';
import { BudgetRecurring } from '@/pages/BudgetRecurring';
import { BudgetInvestments } from '@/pages/BudgetInvestments';
import { BudgetReports } from '@/pages/BudgetReports';
import { Settings } from '@/pages/Settings';
import { SettingsAnalytics } from '@/pages/SettingsAnalytics';
import { SettingsMemory } from '@/pages/SettingsMemory';
import { SettingsIntegrations } from '@/pages/SettingsIntegrations';

export const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout />,
    errorElement: <ErrorBoundary />,
    children: [
      { index: true, element: <Dashboard /> },
      { path: 'chat', element: <Chat /> },
      { path: 'projects', element: <Projects /> },
      { path: 'projects/:projectId', element: <ProjectDetail /> },
      { path: 'calendar', element: <Calendar /> },
      { path: 'news', element: <News /> },
      { path: 'budget', element: <Budget /> },
      { path: 'budget/transactions', element: <BudgetTransactions /> },
      { path: 'budget/goals', element: <BudgetGoals /> },
      { path: 'budget/accounts', element: <BudgetAccounts /> },
      { path: 'budget/recurring', element: <BudgetRecurring /> },
      { path: 'budget/investments', element: <BudgetInvestments /> },
      { path: 'budget/reports', element: <BudgetReports /> },
      { path: 'settings', element: <Settings /> },
      { path: 'settings/analytics', element: <SettingsAnalytics /> },
      { path: 'settings/memory', element: <SettingsMemory /> },
      { path: 'settings/integrations', element: <SettingsIntegrations /> },
      { path: '*', element: <Navigate to="/" replace /> },
    ],
  },
]);
```

</route_structure>

<route_parameters>
- Use useParams hook to access route parameters
- Type parameters with TypeScript interfaces
- Use useSearchParams for query parameters
- Handle undefined parameters gracefully
</route_parameters>

<navigation_patterns>
- Use useNavigate hook for programmatic navigation
- Use Link component for declarative navigation
- Use NavLink for active state styling
- Use Navigate component for redirects
- Preserve state with navigate(location, { state: {} })
</navigation_patterns>

<lazy_loading>
- Use React.lazy() for route-based code splitting
- Wrap lazy routes in Suspense with loading fallback
- Load heavy components on demand
- Split by route for optimal bundle size
</lazy_loading>

<error_handling>
- Create errorElement for route-level error boundaries
- Use ErrorBoundary component for graceful error handling
- Provide fallback UI for failed route loads
- Log errors for debugging
- Offer recovery options (retry, go back)
</error_handling>

<route_protection>
- Use wrapper components for protected routes
- Check authentication in route loaders if needed
- Redirect unauthorized users to login
- Store redirect location for post-login navigation
</route_protection>

<accessibility>
- Use semantic HTML for navigation
- Ensure keyboard navigation works
- Provide ARIA labels for navigation elements
- Manage focus when routes change
- Announce route changes to screen readers
</accessibility>

<performance>
- Use React.lazy() for code splitting
- Implement route-level caching
- Prefetch routes on hover or intent
- Avoid unnecessary re-renders on navigation
- Use transition API for non-urgent navigation
</performance>
