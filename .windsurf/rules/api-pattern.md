---
trigger: glob
globs: src/api/*.ts
---

# API Pattern Rules

All API calls must follow this pattern:

<base_url>
- Base URL: http://localhost:8000
- All endpoints are under /api/v1/
</base_url>

<client_setup>
- Use TanStack Query v5 for all data fetching
- Create API client functions in src/api/
- Use TypeScript interfaces for request/response types
- Return mock data from src/lib/mockData/ for development
</client_setup>

<endpoints>
Follow these endpoint patterns (all return mocked data):
- GET /api/v1/health
- GET /api/v1/agents
- GET /api/v1/attention-queue
- POST /api/v1/attention-queue/:id/approve
- POST /api/v1/attention-queue/:id/reject
- GET /api/v1/chat/:thread_id
- POST /api/v1/chat
- GET /api/v1/chat/:thread_id/stream (SSE)
- GET /api/v1/cost-analytics
- GET /api/v1/audit-log
- GET /api/v1/memory
- GET /api/v1/mcp-servers
- GET /api/v1/projects
- POST /api/v1/projects
- GET /api/v1/projects/:id
- PUT /api/v1/projects/:id
- DELETE /api/v1/projects/:id
- GET /api/v1/projects/:id/tasks
- POST /api/v1/projects/:id/tasks
- PUT /api/v1/tasks/:id
- DELETE /api/v1/tasks/:id
- GET /api/v1/project-templates
- GET /api/v1/calendar/events
- POST /api/v1/calendar/events
- PUT /api/v1/calendar/events/:id
- DELETE /api/v1/calendar/events/:id
- GET /api/v1/budget/overview
- GET /api/v1/budget/categories
- GET /api/v1/budget/transactions
- GET /api/v1/budget/trends
- GET /api/v1/budget/goals
- POST /api/v1/budget/goals
- PUT /api/v1/budget/goals/:id
- GET /api/v1/budget/accounts
- GET /api/v1/budget/recurring
- GET /api/v1/budget/investments
- GET /api/v1/budget/reports/:type
- GET /api/v1/news/feed
- GET /api/v1/news/topics
- GET /api/v1/news/sources
- POST /api/v1/news/preferences
- GET /api/v1/news/bookmarks
- GET /api/v1/settings
- PUT /api/v1/settings
- GET /api/v1/settings/integrations
- PUT /api/v1/settings/integrations/:id
</endpoints>

<mock_data>
- All mock data must be in src/lib/mockData/
- Use realistic placeholder values
- Ensure mock data matches TypeScript interfaces
- Include edge cases and error states in mock data
</mock_data>
