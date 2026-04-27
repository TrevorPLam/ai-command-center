# Frontend Route Tree & Code Splitting Map

Defines URL patterns, lazy-loading boundaries, and bundle budgets for all frontend routes.

---

## Route Tree Diagram

```text
/ (Dashboard)
├── /chat (ChatPage)
├── /projects (ProjectsPage)
│   ├── /projects/triage (TriagePage)
│   └── /projects/:id (ProjectDetailPage)
├── /calendar (CalendarPage)
├── /budget (BudgetPage)
├── /email (EmailPage)
├── /contacts (ContactsPage)
├── /documents (DocumentsPage)
├── /media (MediaPage)
├── /news (NewsPage)
├── /analytics (AnalyticsPage)
├── /audit (AuditLogPage)
├── /settings (SettingsPage)
│   └── /settings/export (ExportImportPage)
├── /login (LoginPage)
├── /signup (SignupPage)
├── /oauth/callback (OAuthCallbackPage)
├── /agents (AgentStudioPage)
├── /agents/analytics (AgentAnalyticsPage)
├── /agents/playground (AgentPlaygroundPage)
├── /conference (ConferencePage)
├── /research (ResearchPage)
└── /translation (TranslationPage)
```

---

## Route Table

| Route | Component | Lazy Load | Heavy Dependencies | Bundle Budget | Suspense Fallback | Error Boundary |
|-------|-----------|-----------|-------------------|---------------|------------------|----------------|
| `/` | Dashboard | No | None | Initial ≤150 KB | None | Global |
| `/chat` | ChatPage | Yes | Yjs (CollabCanvas) | Lazy ≤800 KB | Skeleton | Route |
| `/projects` | ProjectsPage | Yes | React Flow (A2AFlowEditor) | Lazy ≤800 KB | Skeleton | Route |
| `/projects/triage` | TriagePage | Yes | None | Lazy ≤800 KB | Skeleton | Route |
| `/projects/:id` | ProjectDetailPage | Yes | None | Lazy ≤800 KB | Skeleton | Route |
| `/calendar` | CalendarPage | Yes | react-big-calendar | Lazy ≤800 KB | Skeleton | Route |
| `/budget` | BudgetPage | Yes | Tremor | Lazy ≤800 KB | Skeleton | Route |
| `/email` | EmailPage | Yes | None | Lazy ≤800 KB | Skeleton | Route |
| `/contacts` | ContactsPage | Yes | None | Lazy ≤800 KB | Skeleton | Route |
| `/documents` | DocumentsPage | Yes | Yjs (RealTimeCoEdit) | Lazy ≤800 KB | Skeleton | Route |
| `/media` | MediaPage | Yes | None | Lazy ≤800 KB | Skeleton | Route |
| `/news` | NewsPage | Yes | None | Lazy ≤800 KB | Skeleton | Route |
| `/analytics` | AnalyticsPage | Yes | Tremor | Lazy ≤800 KB | Skeleton | Route |
| `/audit` | AuditLogPage | Yes | None | Lazy ≤800 KB | Skeleton | Route |
| `/settings` | SettingsPage | Yes | None | Lazy ≤800 KB | Skeleton | Route |
| `/settings/export` | ExportImportPage | Yes | None | Lazy ≤800 KB | Skeleton | Route |
| `/login` | LoginPage | Yes | SimpleWebAuthn | Lazy ≤800 KB | Skeleton | Route |
| `/signup` | SignupPage | Yes | SimpleWebAuthn | Lazy ≤800 KB | Skeleton | Route |
| `/oauth/callback` | OAuthCallbackPage | Yes | SimpleWebAuthn | Lazy ≤800 KB | Skeleton | Route |
| `/agents` | AgentStudioPage | Yes | Monaco | Lazy ≤800 KB | Skeleton | Route |
| `/agents/analytics` | AgentAnalyticsPage | Yes | Tremor | Lazy ≤800 KB | Skeleton | Route |
| `/agents/playground` | AgentPlaygroundPage | Yes | Monaco | Lazy ≤800 KB | Skeleton | Route |
| `/conference` | ConferencePage | Yes | LiveKit | Lazy ≤800 KB | Skeleton | Route |
| `/research` | ResearchPage | Yes | None | Lazy ≤800 KB | Skeleton | Route |
| `/translation` | TranslationPage | Yes | None | Lazy ≤800 KB | Skeleton | Route |

---

## Lazy-Load Boundaries

### Monaco Editor (≤2 MB)

**Routes**: `/agents`, `/agents/playground`

**Strategy**: React.lazy() with Suspense. Monaco loaded in separate chunk via dynamic import.

**Rationale**: Monaco is sandboxed in iframe per FE-29, FE-30. Too large for initial bundle.

**Implementation**:

```tsx
const MonacoEditor = React.lazy(() => import('monaco-editor'));
```

**Fallback**: Skeleton loader with 200ms timeout before spinner.

---

### Yjs (≤300 KB)

**Routes**: `/chat` (CollabCanvas), `/documents` (RealTimeCoEdit)

**Strategy**: Lazy load per route. Yjs loaded only when collaboration features accessed.

**Rationale**: Collaboration is opt-in per COLL-03. Not needed for all users.

**Implementation**:

```tsx
const CollabCanvas = React.lazy(() => import('@/components/chat/CollabCanvas'));
const RealTimeCoEdit = React.lazy(() => import('@/components/documents/RealTimeCoEdit'));
```

**Fallback**: Skeleton loader.

---

### LiveKit (≤800 KB combined)

**Routes**: `/conference`

**Strategy**: Lazy load entire ConferencePage with LiveKit dependencies.

**Rationale**: Video conferencing is feature-gated. Not in initial bundle.

**Implementation**:

```tsx
const ConferencePage = React.lazy(() => import('@/pages/ConferencePage'));
```

**Fallback**: Skeleton loader with camera/microphone permission prompt.

---

### react-big-calendar (≤150 KB)

**Routes**: `/calendar`, `/budget` (TransactionCalendarView)

**Strategy**: Lazy load per route. Calendar views loaded on demand.

**Rationale**: Calendar is major feature but not on critical path to LCP.

**Implementation**:

```tsx
const CalendarPage = React.lazy(() => import('@/pages/CalendarPage'));
const BudgetPage = React.lazy(() => import('@/pages/BudgetPage'));
```

**Fallback**: Skeleton loader with date placeholder.

---

### React Flow (≤200 KB)

**Routes**: `/projects` (A2AFlowEditor)

**Strategy**: Lazy load within ProjectsPage. Flow editor loaded only when needed.

**Rationale**: A2A flow editing is advanced feature. Not on initial render.

**Implementation**:

```tsx
const A2AFlowEditor = React.lazy(() => import('@/components/chat/A2AFlowEditor'));
```

**Fallback**: Skeleton loader with node placeholder.

---

### Tremor (≤15 KB)

**Routes**: `/budget`, `/analytics`, `/agents/analytics`

**Strategy**: Shared chunk. Loaded once, reused across charting routes.

**Rationale**: Small enough to share. Avoids duplication.

**Implementation**:

```tsx
// Vite manual chunk config
build: {
  rollupOptions: {
    output: {
      manualChunks: {
        tremor: ['@tremor/react'],
      },
    },
  },
}
```

**Fallback**: Skeleton loader with chart placeholder.

---

### SimpleWebAuthn (≤12 KB)

**Routes**: `/login`, `/signup`, `/oauth/callback`

**Strategy**: Lazy load per auth route. Auth is not on critical path for authenticated users.

**Rationale**: Auth routes separate from main app flow.

**Implementation**:

```tsx
const LoginPage = React.lazy(() => import('@/pages/LoginPage'));
const SignupPage = React.lazy(() => import('@/pages/SignupPage'));
const OAuthCallbackPage = React.lazy(() => import('@/pages/OAuthCallbackPage'));
```

**Fallback**: Skeleton loader with auth form placeholder.

---

### PowerSync (≤50 KB)

**Routes**: All routes (global)

**Strategy**: Load in initial bundle but defer initialization.

**Rationale**: Offline sync is core feature. Small enough for initial bundle.

**Implementation**:

```tsx
// Load in main.tsx but defer connect()
import { PowerSyncDatabase } from '@powersync/react';
```

**Fallback**: None (synchronous load).

---

### Temporal Polyfill (≤20 KB)

**Routes**: All routes (conditional)

**Strategy**: Conditional load for Safari only via feature detection.

**Rationale**: Only needed for browsers without native Temporal support.

**Implementation**:

```tsx
if (!globalThis.Temporal) {
  await import('@js-temporal/polyfill');
}
```

**Fallback**: None (synchronous load if needed).

---

### rschedule (≤15 KB)

**Routes**: `/calendar`, `/projects` (recurring events)

**Strategy**: Lazy load with calendar routes.

**Rationale**: Recurrence engine only needed for calendar features.

**Implementation**:

```tsx
const RecurringWorkDialog = React.lazy(() => import('@/components/projects/RecurringWorkDialog'));
```

**Fallback**: Skeleton loader.

---

## Suspense Fallbacks

### Standard Skeleton Pattern

All lazy routes use consistent skeleton fallback:

```tsx
<Suspense fallback={<PageSkeleton />}>
  <LazyComponent />
</Suspense>
```

**PageSkeleton**: Shimmer effect matching page layout structure.

**Timeout**: 200ms before showing spinner (per FE-17).

---

### Route-Specific Fallbacks

| Route | Fallback Notes |
|-------|----------------|
| `/chat` | Message list skeleton with 3 placeholder bubbles |
| `/projects` | Kanban column skeleton with 3 card placeholders |
| `/calendar` | Month grid skeleton with 7 day placeholders |
| `/budget` | Chart skeleton with bar placeholders |
| `/conference` | Video grid skeleton with 4 tile placeholders |
| `/agents` | Monaco editor skeleton with line placeholders |

---

## Error Boundaries

### Global Error Boundary

Wraps entire app in `App.tsx`. Catches unhandled errors.

**Behavior**: Log to Sentry, show error page with retry button.

---

### Route-Level Error Boundaries

Each lazy route wrapped in error boundary.

**Behavior**: Show route-specific error message, offer retry or navigation.

**Implementation**:

```tsx
<ErrorBoundary fallback={<RouteError />}>
  <Suspense fallback={<PageSkeleton />}>
    <LazyComponent />
  </Suspense>
</ErrorBoundary>
```

---

## Bundle Budget Summary

| Chunk Type | Budget | Notes |
|------------|--------|-------|
| Initial | ≤150 KB | Core app shell, routing, Zustand stores |
| Lazy route | ≤800 KB | Per-route chunks excluding heavy deps |
| Monaco | ≤2 MB | Sandbox iframe, loaded on demand |
| React Flow | ≤200 KB | A2A flow editor |
| react-big-calendar | ≤150 KB | Calendar views |
| Yjs | ≤300 KB | Collaboration features |
| Tremor | ≤15 KB | Shared charting library |
| AI SDK | ≤10 KB | Agent tool calling |
| PowerSync | ≤50 KB | Offline sync (initial bundle) |
| Temporal polyfill | ≤20 KB | Conditional, Safari only |
| rschedule | ≤15 KB | Recurrence engine |
| SimpleWebAuthn | ≤12 KB | Auth routes only |
| PostHog | ≤19 KB | Analytics, feature flagged |

---

## Hover Prefetch Strategy

Per component registry, hover prefetch delays:

- **ThreadListItem**: 200ms (chat thread content)
- **ProjectListView**: 200ms (project details)
- **NewsCard**: 200ms (article content)

**Implementation**: React Router v6 `useEffect` with `setTimeout` on hover.

---

## Code Splitting Configuration

### Vite Config

```typescript
// vite.config.ts
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom', 'react-router-dom'],
          ui: ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu'],
          tremor: ['@tremor/react'],
          motion: ['motion/react'],
          zustand: ['zustand'],
          tanstack: ['@tanstack/react-query'],
        },
      },
    },
  },
});
```

---

## Performance Targets

Per 80-OPS-PERFORMANCE.md:

- **LCP**: ≤800 ms (p75)
- **INP**: ≤200 ms
- **CLS**: ≤0.1

**Optimization notes**:

- Initial bundle ≤150 KB ensures fast LCP
- Lazy loading prevents blocking main thread
- Skeleton fallbacks prevent layout shift (CLS)
- Hover prefetch reduces perceived latency
