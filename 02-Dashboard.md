# 02-Dashboard — Personal AI Command Center Frontend (Enhanced v2)

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done. **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.

---

## 📐 Reasoning Memo

### Task count: 7 → 8

DASH-000 in v1 bundled TypeScript types, Zod schemas, queryOptions, factories, MSW handlers, and custom hooks. These have a strict dependency order: types must exist before factories can be typed, and queryOptions must exist before hooks can be written. Splitting into **DASH-000 (Contract Layer)** and **DASH-001 (Mock Implementation Layer)** creates clean commit boundaries and allows the typing work to proceed in parallel with other foundation tasks.

All other tasks remain combined. Splitting ActivityEntry from ActivityFeed, or DecisionPacket from AttentionQueue, would create artificial granularity — those components are tightly coupled and build together naturally.

### Key corrections from research incorporated

| Issue | v1 Mistake | Correction |
|-------|-----------|------------|
| **No `@faker-js/faker`** | Hand-written static mock values | Use `@faker-js/faker` with `faker.seed()` for reproducible, realistic data |
| **MSW handlers are stateless** | Each handler returns fresh data; mutations have no effect | Handlers must maintain in-memory state; approved decisions stay approved |
| **No `delay()` in handlers** | All requests respond instantly | Add `delay(300-800)` to surface loading skeleton states |
| **`VariableSizeList` Row not memoized** | Row re-renders on every scroll event | Wrap Row in `memo()` — the #1 `react-window` performance requirement |
| **`useTransition` pattern wrong** | Dual shadow state (`filter` + `deferredFilter`) | Single state, `startTransition(() => setFilter(val))` — React defers it |
| **`onMutate` in `.mutate()` call** | Per-call override pattern (one-shot) | `onMutate/onError/onSettled` belong in `useMutation()` definition |
| **No `LayoutGroup`** | Global `layoutId` values can collide if component renders twice | Wrap `AgentFleetPanel` in `LayoutGroup id="agent-fleet"` |
| **`AnimatePresence` without `mode`** | Exiting items hold space while animating out | Use `mode="popLayout"` for list removals — frees space immediately |
| **No `layoutScroll`** | `layoutId` morph ignores scroll offset in scrollable drawer | Add `layoutScroll` to scrollable container in `AgentDetailDrawer` |
| **Optimistic update immutability** | `setQueryData` mutates the cache array directly | Always spread/copy: `old => old.filter(...)`, never mutate `old` in-place |

### Testing structure

Testing is embedded as subtasks within each component task. Infrastructure is assumed complete (FND-004).

---

## 🧱 Cross-Cutting Foundations for Dashboard

| ID | Requirement |
|----|-------------|
| **DASH-C01** | All scroll-triggered animations: `viewport={{ once: true }}` |
| **DASH-C02** | Animate only `transform` and `opacity` — never layout properties |
| **DASH-C03** | `staggerChildren` in parent `transition`; `delayChildren` for initial delay |
| **DASH-C04** | `react-window` mandatory for ActivityFeed. `VariableSizeList`. Row wrapped in `memo()` |
| **DASH-C05** | Filter updates via `useTransition` + single `startTransition` — not debounce |
| **DASH-C06** | Optimistic updates: `onMutate` → `cancelQueries` → snapshot → immutable `setQueryData` → `onError` rollback → `onSettled` invalidate |
| **DASH-C07** | ActivityFeed: `role="log"` + `aria-live="polite"` |
| **DASH-C08** | Countdown timer: `useMotionValue` + `useSpring` with `skipInitialAnimation: true` |
| **DASH-C09** | RightPanel on `/` route: `AttentionQueue`. Injected via route-scoped context. |
| **DASH-C10** | `@faker-js/faker` with `faker.seed(12345)` for all test factories |
| **DASH-C11** | MSW handlers maintain in-memory state; mutations must persist within session |
| **DASH-C12** | `LayoutGroup` wrapper required on any component that uses `layoutId` in a reusable pattern |

### 🎯 Motion Tier Assignment

| Component | Tier | Technique |
|-----------|------|-----------|
| AmbientStatusBanner | **Alive** | Animated `@property` conic-gradient border, spring pulse when thinking |
| AgentCard | **Alive** | `staggerChildren: 0.08`, `whileHover` spring with `oklch()` glow, `layoutId` morph |
| ActivityEntry (new items) | **Alive** | Spring slide-in (`stiffness: 300, damping: 30`) |
| DecisionPacket entrance | **Quiet** | `opacity + y` fade-in (≤200ms) |
| DecisionPacket countdown | **Quiet** | `useSpring` with `skipInitialAnimation: true` |
| AttentionQueue empty state | **Quiet** | Opacity fade (≤150ms) |
| ActivityFeed virtualized rows | **Static** | No animation — instant |

---

## 🗂️ Task DASH-000: Domain Contract Layer — Types, Zod Schemas & queryOptions
**Priority:** 🔴 High | **Est. Effort:** 45 min | **Depends On:** FND-006 (TanStack Query)

> Types and schemas must exist before factories can be typed and before queryOptions can be written. This is the contract that everything else implements against.

### Related Files
- `src/types/dashboard.ts` · `src/schemas/dashboard.ts` · `src/queries/dashboard.ts`

### Subtasks
- [ ] **DASH-000A**: Define TypeScript interfaces in `src/types/dashboard.ts`:
  ```ts
  export type AgentStatus = 'thinking' | 'idle' | 'error' | 'waiting'
  export type ActivityEntryType = 'tool_call' | 'decision' | 'error' | 'info'
  export type DecisionPriority = 'critical' | 'high' | 'medium'

  export interface Agent {
    id: string
    name: string
    avatarInitials: string
    status: AgentStatus
    currentTask: string
    tokenSpend: number
    uptime: number // seconds
    model: string
    temperature: number
    maxTokens: number
  }

  export interface ActivityEntry {
    id: string
    timestamp: string // ISO 8601
    type: ActivityEntryType
    agentId: string
    agentName: string
    description: string
    details?: string // JSON or markdown for expanded view
  }

  export interface DecisionPacket {
    id: string
    priority: DecisionPriority
    agentId: string
    agentName: string
    taskContext: string
    decisionRequest: string
    timeSensitive: boolean
    expiresAt?: string // ISO 8601, present if timeSensitive
  }
  ```

- [ ] **[TEST] DASH-000A**: TypeScript interfaces defined; all required fields present; types compile without errors

- [ ] **DASH-000B**: Create Zod schemas in `src/schemas/dashboard.ts` — schemas mirror the types and serve as runtime validators at API boundaries:
  ```ts
  export const AgentSchema = z.object({
    id: z.string().uuid(),
    name: z.string(),
    // ... mirror Agent type exactly
  })
  export type Agent = z.infer<typeof AgentSchema> // types derived from schemas
  ```
  Note: if Zod schemas are the source of truth, delete `src/types/dashboard.ts` and export types from schemas instead.

- [ ] **[TEST] DASH-000B**: Zod schemas validate correctly; types derived from schemas; runtime validation works

- [ ] **DASH-000C**: Create `src/queries/dashboard.ts` with `queryOptions` for all dashboard domains:
  ```ts
  export const agentsQueryOptions = queryOptions({
    queryKey: ['agents'],
    queryFn: () => fetchAgents().then(data => AgentListSchema.parse(data)),
    staleTime: 1000 * 30, // 30s — agents update frequently
  })
  export const activityQueryOptions = queryOptions({
    queryKey: ['activity'],
    queryFn: () => fetchActivity().then(data => ActivityListSchema.parse(data)),
    staleTime: 1000 * 10,
  })
  export const attentionQueueQueryOptions = queryOptions({
    queryKey: ['attention-queue'],
    queryFn: () => fetchAttentionQueue().then(data => DecisionListSchema.parse(data)),
    staleTime: 1000 * 15,
  })
  ```
  Runtime Zod `.parse()` at the query boundary catches API shape mismatches immediately.

- [ ] **[TEST] DASH-000C**: queryOptions defined for all domains; staleTime values correct; Zod parse at query boundary

- [ ] **DASH-000D**: Create stub fetch functions in `src/api/dashboard.ts` (thin wrappers around `fetch()`; MSW will intercept these in dev and test):
  ```ts
  export const fetchAgents = () => fetch('/api/agents').then(r => r.json())
  export const fetchActivity = () => fetch('/api/activity').then(r => r.json())
  export const fetchAttentionQueue = () => fetch('/api/attention-queue').then(r => r.json())
  export const approveDecision = (id: string) => fetch(`/api/decisions/${id}/approve`, { method: 'POST' }).then(r => r.json())
  export const rejectDecision = (id: string) => fetch(`/api/decisions/${id}/reject`, { method: 'POST' }).then(r => r.json())
  export const deferDecision = (id: string) => fetch(`/api/decisions/${id}/defer`, { method: 'POST' }).then(r => r.json())
  ```

- [ ] **[TEST] DASH-000D**: Stub fetch functions created; return promises; MSW can intercept

### Definition of Done
- All interfaces/types exported from `src/types/dashboard.ts` or derived from Zod schemas
- Zod schemas parse without error for all shape variations
- `queryOptions` defined for agents, activity, attention-queue
- Stub fetch functions created (MSW intercepts these in next task)
- `tsc --noEmit` passes

### Anti-Patterns
- ❌ Defining types inline inside component files — types are the contract between tasks; they must be centralized
- ❌ Using `any` as query function return type — the entire point of Zod at the query boundary is runtime type safety
- ❌ Duplicating type definitions across `types/` and `schemas/` — pick one source of truth

---

## 🏭 Task DASH-001: Mock Data Factories, MSW Handlers & Custom Hooks
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** DASH-000, FND-004 (Testing Infra)

### Related Files
- `src/mocks/factories/dashboard.ts` · `src/mocks/handlers/dashboard.ts` · `src/hooks/useDashboard.ts`

### Subtasks

**Factories:**
- [ ] **DASH-001A**: Install `@faker-js/faker` as a dev dependency: `pnpm add -D @faker-js/faker`

- [ ] **[TEST] DASH-001A**: Dependency installed; package.json includes @faker-js/faker

- [ ] **DASH-001B**: Create `src/mocks/factories/dashboard.ts` using `@faker-js/faker`:
  ```ts
  import { faker } from '@faker-js/faker'

  // Seed for reproducible test data — same inputs always produce same outputs
  // Call faker.seed() in test setup; do NOT call it here (leave unseeded for dev randomness)

  const AGENT_NAMES = ['Orchestrator', 'Researcher', 'Planner', 'Executor', 'Reviewer']

  export const createAgent = (overrides: Partial<Agent> = {}): Agent => ({
    id: faker.string.uuid(),
    name: faker.helpers.arrayElement(AGENT_NAMES),
    avatarInitials: faker.string.alpha({ length: 2, casing: 'upper' }),
    status: faker.helpers.arrayElement(['thinking', 'idle', 'error', 'waiting'] as const),
    currentTask: faker.hacker.phrase(),
    tokenSpend: faker.number.int({ min: 100, max: 50000 }),
    uptime: faker.number.int({ min: 60, max: 86400 }),
    model: 'claude-sonnet-4-6',
    temperature: 0.7,
    maxTokens: 4096,
    ...overrides,
  })

  export const createAgentFleet = (count = 4): Agent[] =>
    Array.from({ length: count }, (_, i) =>
      createAgent({ name: AGENT_NAMES[i % AGENT_NAMES.length], status: i === 0 ? 'thinking' : 'idle' })
    )

  export const createActivityEntry = (overrides: Partial<ActivityEntry> = {}): ActivityEntry => ({
    id: faker.string.uuid(),
    timestamp: faker.date.recent({ days: 1 }).toISOString(),
    type: faker.helpers.arrayElement(['tool_call', 'decision', 'error', 'info'] as const),
    agentId: faker.string.uuid(),
    agentName: faker.helpers.arrayElement(AGENT_NAMES),
    description: faker.hacker.phrase(),
    details: faker.datatype.boolean() ? JSON.stringify({ result: faker.lorem.sentence() }, null, 2) : undefined,
    ...overrides,
  })

  export const createActivityFeed = (count = 50): ActivityEntry[] =>
    Array.from({ length: count }, () => createActivityEntry())
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())

  export const createDecisionPacket = (overrides: Partial<DecisionPacket> = {}): DecisionPacket => {
    const timeSensitive = faker.datatype.boolean()
    return {
      id: faker.string.uuid(),
      priority: faker.helpers.arrayElement(['critical', 'high', 'medium'] as const),
      agentId: faker.string.uuid(),
      agentName: faker.helpers.arrayElement(AGENT_NAMES),
      taskContext: faker.lorem.sentence(),
      decisionRequest: faker.lorem.sentences(2),
      timeSensitive,
      expiresAt: timeSensitive
        ? new Date(Date.now() + faker.number.int({ min: 30000, max: 300000 })).toISOString()
        : undefined,
      ...overrides,
    }
  }

  export const createAttentionQueue = (count = 3): DecisionPacket[] =>
    Array.from({ length: count }, () => createDecisionPacket())
  ```

- [ ] **[TEST] DASH-001B**: Factories produce valid data; faker seeded correctly; all factory functions work

- [ ] **DASH-001C**: Create `src/mocks/handlers/dashboard.ts` with **stateful** handlers:
  ```ts
  import { http, HttpResponse, delay } from 'msw'
  import { createAgentFleet, createActivityFeed, createAttentionQueue } from '../factories/dashboard'

  // In-memory state — mutations persist within the MSW session
  let agentsDb = createAgentFleet()
  let activityDb = createActivityFeed(50)
  let attentionQueueDb = createAttentionQueue(3)

  export const dashboardHandlers = [
    http.get('/api/agents', async () => {
      await delay(300)
      return HttpResponse.json(agentsDb)
    }),
    http.get('/api/activity', async () => {
      await delay(500)
      return HttpResponse.json(activityDb)
    }),
    http.get('/api/attention-queue', async () => {
      await delay(300)
      return HttpResponse.json(attentionQueueDb)
    }),
    http.get('/api/agents/:id', async ({ params }) => {
      await delay(200)
      const agent = agentsDb.find(a => a.id === params.id)
      if (!agent) return new HttpResponse(null, { status: 404 })
      return HttpResponse.json(agent)
    }),
    http.post('/api/decisions/:id/approve', async ({ params }) => {
      await delay(400) // Simulate network latency for rollback testing
      attentionQueueDb = attentionQueueDb.filter(d => d.id !== params.id)
      return HttpResponse.json({ success: true })
    }),
    http.post('/api/decisions/:id/reject', async ({ params }) => {
      await delay(400)
      attentionQueueDb = attentionQueueDb.filter(d => d.id !== params.id)
      return HttpResponse.json({ success: true })
    }),
    http.post('/api/decisions/:id/defer', async ({ params }) => {
      await delay(200)
      attentionQueueDb = attentionQueueDb.map(d =>
        d.id === params.id ? { ...d, priority: 'medium' as const, timeSensitive: false } : d
      )
      return HttpResponse.json({ success: true })
    }),
  ]
  ```
  Note: export `dashboardHandlers` and spread into `src/mocks/handlers.ts` root handlers array.

- [ ] **[TEST] DASH-001C**: MSW handlers intercept requests; in-memory state persists; delay() works

- [ ] **DASH-001D**: Add a `resetDashboardDb()` export for test isolation:
  ```ts
  export const resetDashboardDb = () => {
    faker.seed(12345) // Deterministic data in tests
    agentsDb = createAgentFleet()
    activityDb = createActivityFeed(50)
    attentionQueueDb = createAttentionQueue(3)
  }
  ```
  Call this in test `beforeEach` to guarantee a clean slate.

- [ ] **[TEST] DASH-001D**: resetDashboardDb() resets all state; faker.seed(12345) produces deterministic data

- [ ] **DASH-001E**: Create `src/hooks/useDashboard.ts` with custom hooks consuming `queryOptions`:
  ```ts
  export function useAgents() { return useQuery(agentsQueryOptions) }
  export function useAgent(id: string) {
    return useQuery({ ...agentsQueryOptions, queryKey: ['agents', id], select: agents => agents.find(a => a.id === id) })
  }
  export function useActivityFeed() { return useQuery(activityQueryOptions) }
  export function useAttentionQueue() { return useQuery(attentionQueueQueryOptions) }

  export function useApproveDecision() {
    const queryClient = useQueryClient()
    return useMutation({
      mutationFn: approveDecision,
      onMutate: async (id) => {
        await queryClient.cancelQueries({ queryKey: ['attention-queue'] })
        const previous = queryClient.getQueryData<DecisionPacket[]>(['attention-queue'])
        // Immutable update — never mutate the cached array directly
        queryClient.setQueryData<DecisionPacket[]>(['attention-queue'], old => old?.filter(p => p.id !== id) ?? [])
        return { previous }
      },
      onError: (_err, _id, context) => {
        if (context?.previous) {
          queryClient.setQueryData(['attention-queue'], context.previous)
        }
        toast.error('Failed to approve — decision restored')
      },
      onSettled: () => queryClient.invalidateQueries({ queryKey: ['attention-queue'] }),
    })
  }

  // useRejectDecision and useDeferDecision follow the same pattern
  ```

- [ ] **[TEST] DASH-001E**: Custom hooks consume queryOptions; type inference works; optimistic updates implemented correctly

- [ ] **DASH-001F**: Verify `pnpm test` passes — MSW intercepts factory data and hooks return typed values

- [ ] **[TEST] DASH-001F**: Tests pass; MSW intercepts; hooks return typed values

### Definition of Done
- Factories use `@faker-js/faker` and produce schema-valid data
- `resetDashboardDb()` exported and works with `faker.seed(12345)`
- MSW handlers maintain in-memory state for mutations
- All handlers include `delay()` for realistic latency
- Custom hooks consume `queryOptions` with full type inference
- Optimistic updates use `onMutate` in `useMutation()` definition, not in `.mutate()` override
- Cache updates use immutable spreads/filters

### Anti-Patterns
- ❌ Hand-written static mock objects — brittle, tedious, doesn't test edge cases
- ❌ `faker.seed()` called inside factory functions — call it only in test setup files for reproducibility
- ❌ Stateless MSW mutation handlers — if approve/reject/defer don't update the in-memory db, the UI re-fetches stale data and the packet reappears
- ❌ `onMutate` defined inside `.mutate(id, { onMutate... })` — that's a per-call one-shot override, not the standard pattern
- ❌ `setQueryData(['attention-queue'], old => { old.splice(...); return old })` — mutating the cached array directly causes stale closure bugs; always return a new array

---

## 🟢 Task DASH-002: Dashboard Page Layout & Route Configuration
**Priority:** 🔴 High | **Est. Effort:** 30 min | **Depends On:** FND-007 (Router), FND-008 (Provider Tree)

### Related Files
- `src/pages/Dashboard.tsx` · `src/router/routes.ts` · `src/layouts/AppShell.tsx`

### Subtasks

**Implementation:**
- [ ] **DASH-002A**: Create `src/pages/Dashboard.tsx`:
  - Two-column grid: `grid-cols-[1fr_320px]` for ≥768px; single column on mobile
  - Left column (`<main>`): `AmbientStatusBanner`, `AgentFleetPanel`, `ActivityFeed`
  - Right column: populated via AppShell's outlet context (contains `AttentionQueue`)
- [ ] **DASH-002B**: Configure the route in `src/router/routes.ts`:
  - `index: true`, `lazy: () => import('@/pages/Dashboard')`
  - Route-level `loader`: `() => queryClient.ensureQueryData(agentsQueryOptions)` — prefetch agents before rendering
- [ ] **DASH-002C**: Route-inject `AttentionQueue` into RightPanel via `AppShell`:
  - Use React Router's `useMatches()` or outlet context to determine which component the RightPanel should render per route
  - Dashboard route → `AttentionQueue`; other routes → null (panel closes or shows generic content)
- [ ] **DASH-002D**: Add page transition wrapper:
  ```tsx
  <motion.div
    key={location.pathname}
    initial={{ opacity: 0, y: 8 }}
    animate={{ opacity: 1, y: 0 }}
    exit={{ opacity: 0, y: -8 }}
    transition={{ duration: 0.15, ease: 'easeOut' }}
  >
    {/* dashboard content */}
  </motion.div>
  ```
- [ ] **DASH-002E**: Add `<Suspense fallback={<DashboardSkeleton />}>` around lazy-loaded page content

**Tests:**
- [ ] **[TEST] DASH-002F**: `/` route renders Dashboard component
- [ ] **[TEST] DASH-002G**: Route loader calls `queryClient.ensureQueryData` (mock queryClient)
- [ ] **[TEST] DASH-002H**: `DashboardSkeleton` renders during lazy load (mock `Suspense`)

### Definition of Done
- `/` renders Dashboard with two-column layout
- Agents prefetched in route loader before component mounts
- RightPanel displays `AttentionQueue` on `/`
- Page transition animation triggers

### Anti-Patterns
- ❌ Missing `key` on page transition `motion.div` — `AnimatePresence` won't detect the route change
- ❌ Fetching data in `useEffect` inside Dashboard instead of route `loader` — waterfall render

---

## 🟢 Task DASH-003: AmbientStatusBanner
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** DASH-001, DASH-002

### Related Files
- `src/components/dashboard/AmbientStatusBanner.tsx` · `src/hooks/useAgentStatus.ts`

### Subtasks

**Implementation:**
- [ ] **DASH-003A**: Create `useAgentStatus()` hook:
  - Consumes `useAgents()`
  - Returns `{ isAnyThinking, thinkingCount, statusMessage }`
  - `isAnyThinking = agents.some(a => a.status === 'thinking')`
- [ ] **DASH-003B**: Build `AmbientStatusBanner`:
  - Full-width, top of left column
  - Displays: status message, thinking agent count, dismiss button
  - Dismiss state: `uiSlice` or `localStorage` (survives refresh)
- [ ] **DASH-003C**: Animated conic-gradient border via `@property`:
  ```css
  /* Already declared in index.css FND-000F */
  @property --border-angle {
    syntax: '<angle>';
    initial-value: 0deg;
    inherits: false;
  }
  ```
  Apply `animation: border-rotate 4s linear infinite` only when `isAnyThinking`
- [ ] **DASH-003D**: Entrance/exit via `AnimatePresence`:
  - `initial={{ opacity: 0, height: 0, marginBottom: 0 }}`
  - `animate={{ opacity: 1, height: 'auto', marginBottom: '1rem' }}`
  - Use `layout` prop on adjacent elements to smoothly shift content when banner mounts/unmounts
- [ ] **DASH-003E**: `useReducedMotion()` check: disable border rotation (static border), keep opacity transitions at `duration: 0`

**Tests:**
- [ ] **[TEST] DASH-003F**: Banner renders when `isAnyThinking = true`, hidden when false
- [ ] **[TEST] DASH-003G**: Dismiss persists (check `localStorage` or `uiSlice` update)
- [ ] **[TEST] DASH-003H**: `useReducedMotion = true` → no CSS animation class on border element

### Definition of Done
- Banner appears/disappears with `AnimatePresence`
- Animated border runs only when agents are thinking
- Dismiss persists across refresh
- `useReducedMotion` respected

### Anti-Patterns
- ❌ Animating `height: 'auto'` without `layout` on siblings — siblings jump instead of slide
- ❌ Dismiss state in component `useState` — resets on navigation

---

## 🟢 Task DASH-004: AgentFleetPanel & AgentCard
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** DASH-001, DASH-002

### Related Files
- `src/components/dashboard/AgentFleetPanel.tsx` · `src/components/dashboard/AgentCard.tsx`

### Subtasks

**Implementation (AgentCard):**
- [ ] **DASH-004A**: Build `AgentCard` component:
  - Avatar (initials in colored circle), name, `StatusIndicator`, current task (truncated, 2 lines), token spend, uptime
  - Expand button (chevron) — calls `openAgentDrawer(agent.id)` from Zustand `uiSlice`
- [ ] **DASH-004B**: Status indicator colors:
  - `thinking` → electric blue pulse (Motion keyframe: `scale: [1, 1.3, 1]` + `opacity: [1, 0.5, 1]`)
  - `idle` → green static dot
  - `error` → red static dot
  - `waiting` → amber static dot
  - All pulse animations gated on `!useReducedMotion()`
- [ ] **DASH-004C**: `whileHover` spring effect:
  ```tsx
  whileHover={{ y: -3, boxShadow: '0 0 20px oklch(62% 0.19 264 / 0.25)' }}
  transition={{ type: 'spring', stiffness: 400, damping: 17 }}
  ```
  This uses `oklch()` directly — supported in Motion v12 for glow values.
- [ ] **DASH-004D**: `layoutId` for drawer morph: `layoutId={`agent-card-${agent.id}`}` on the card's `motion.div` container

**Implementation (AgentFleetPanel):**
- [ ] **DASH-004E**: Build `AgentFleetPanel`:
  - Consumes `useAgents()`
  - Grid: `grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4`
- [ ] **DASH-004F**: Staggered entrance — wrap grid in `LayoutGroup id="agent-fleet"` to namespace `layoutId` values:
  ```tsx
  <LayoutGroup id="agent-fleet">
    <motion.div
      variants={containerVariants}
      initial="hidden"
      animate="visible"
      viewport={{ once: true }}
    >
      {agents.map(agent => <AgentCard key={agent.id} agent={agent} />)}
    </motion.div>
  </LayoutGroup>
  ```
  ```ts
  const containerVariants = {
    hidden: {},
    visible: { transition: { staggerChildren: 0.08, delayChildren: 0.1 } },
  }
  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.3 } },
  }
  ```
  Pass `variants={itemVariants}` to each `AgentCard`'s outer `motion.div`.
- [ ] **DASH-004G**: `viewport={{ once: true }}` on container — prevents re-animation on scroll
- [ ] **DASH-004H**: Empty state: `"No agents active"` with icon + placeholder CTA
- [ ] **DASH-004I**: Loading skeleton: 3 skeleton cards while `isLoading` (matches grid layout)

**Tests:**
- [ ] **[TEST] DASH-004J**: Agent cards render with name, status, truncated task
- [ ] **[TEST] DASH-004K**: Expand button dispatches `openAgentDrawer(agent.id)` to Zustand
- [ ] **[TEST] DASH-004L**: Empty state renders when `agents = []`
- [ ] **[TEST] DASH-004M**: Loading skeleton renders when `isLoading = true`
- [ ] **[TEST] DASH-004N**: `thinking` status indicator has correct class/attributes

### Definition of Done
- Cards stagger in with `0.08s` delay per card
- `LayoutGroup id="agent-fleet"` wraps the panel (prevents `layoutId` namespace collision)
- `viewport={{ once: true }}` prevents re-animation
- Hover glow uses `oklch()` electric blue
- Empty state and loading skeleton handled
- All 5 tests pass

### Anti-Patterns
- ❌ No `LayoutGroup` — if `AgentFleetPanel` ever renders in two places (e.g., a modal preview + main dashboard), `layoutId` values collide and animations break
- ❌ Missing `viewport={{ once: true }}` — stagger animation fires every time user scrolls back
- ❌ `staggerChildren` on individual card `motion.div` — it must be on the container variants
- ❌ Drawer open state in card's `useState` — use Zustand for cross-component coordination

---

## 🟢 Task DASH-005: ActivityFeed & ActivityEntry
**Priority:** 🔴 High | **Est. Effort:** 3.5 hours | **Depends On:** DASH-001, DASH-002

### Related Files
- `src/components/dashboard/ActivityFeed.tsx` · `src/components/dashboard/ActivityEntry.tsx`

### Subtasks

**Implementation (ActivityEntry):**
- [ ] **DASH-005A**: Build `ActivityEntry` component:
  - Avatar initials, relative timestamp, type badge, description
  - Expandable details section (JSON/markdown): collapses by default
  - Chevron rotation: `animate={{ rotate: isExpanded ? 180 : 0 }}` with `transition={{ type: 'spring', stiffness: 300, damping: 25 }}`
  - Props: `entry`, `isExpanded`, `onToggle`, `style` (required for `react-window` absolute positioning)
- [ ] **DASH-005B**: Memoize `ActivityEntry` with `React.memo()` — entries inside a `VariableSizeList` re-render on every scroll without it

**Implementation (ActivityFeed):**
- [ ] **DASH-005C**: Filter state with `useTransition` — single state, correct pattern:
  ```tsx
  const [filter, setFilter] = useState<ActivityEntryType | 'all'>('all')
  const [isPending, startTransition] = useTransition()

  const handleFilterChange = (newFilter: typeof filter) => {
    startTransition(() => setFilter(newFilter))
  }

  const filteredEntries = useMemo(
    () => filter === 'all' ? entries : entries.filter(e => e.type === filter),
    [entries, filter]
  )
  ```
  `startTransition` tells React: "this state update is non-urgent; don't block the input." No shadow state needed.
- [ ] **DASH-005D**: Virtualization with `VariableSizeList`:
  ```tsx
  const rowHeights = useRef<Record<number, number>>({})
  const listRef = useRef<VariableSizeList>(null)

  const getItemSize = useCallback((index: number) => rowHeights.current[index] ?? 80, [])

  const setRowHeight = useCallback((index: number, height: number) => {
    if (rowHeights.current[index] !== height) {
      rowHeights.current[index] = height
      listRef.current?.resetAfterIndex(index, false) // false = don't re-render immediately
    }
  }, [])

  // Row component MUST be memoized
  const Row = memo(({ index, style }: ListChildComponentProps) => {
    const rowRef = useRef<HTMLDivElement>(null)
    useLayoutEffect(() => {
      if (rowRef.current) {
        setRowHeight(index, rowRef.current.getBoundingClientRect().height)
      }
    })
    return (
      <div style={style}>
        <div ref={rowRef}>
          <ActivityEntry entry={filteredEntries[index]} {...} />
        </div>
      </div>
    )
  })
  ```
- [ ] **DASH-005E**: Wrap `VariableSizeList` in `AutoSizer` from `react-virtualized-auto-sizer` (or set an explicit pixel height from parent container) — `react-window` requires a fixed `height` prop
- [ ] **DASH-005F**: New entry animation: new entries appear at top. Because the virtualized list doesn't use `AnimatePresence`, simulate the slide-in via the `ActivityEntry` component itself:
  - Wrap `ActivityEntry` in `motion.div` with `initial={{ opacity: 0, x: -16 }}`, `animate={{ opacity: 1, x: 0 }}`, spring transition
  - Key by `entry.id` so React creates a new element when a new entry arrives
- [ ] **DASH-005G**: ARIA attributes:
  - Container: `role="log"` (implicit `aria-live="polite"` — screen readers announce new entries when idle)
  - Each entry: `role="article"` + `aria-label={`${entry.agentName} ${entry.type} at ${relativeTime}`}`
  - Filter tabs: `role="tablist"` → `role="tab"` → `aria-selected`
- [ ] **DASH-005H**: `isPending` state from `useTransition` — show a subtle loading indicator (opacity pulse on the list) while filter is recalculating
- [ ] **DASH-005I**: Empty state per filter tab

**Tests:**
- [ ] **[TEST] DASH-005J**: Filter tabs render entries of correct type
- [ ] **[TEST] DASH-005K**: Expanding an entry calls `setRowHeight` and triggers `resetAfterIndex`
- [ ] **[TEST] DASH-005L**: `role="log"` present on container
- [ ] **[TEST] DASH-005M**: `role="tab"` elements have correct `aria-selected` values
- [ ] **[TEST] DASH-005N**: `isPending = true` while filter transition is in flight

### Definition of Done
- Virtualization uses `VariableSizeList` with memoized `Row` component
- `setRowHeight` + `resetAfterIndex` called on expand/collapse
- Filter uses `startTransition()` — single state, no shadow state
- `useMemo` on filtered entries to avoid recalculating on unrelated renders
- `role="log"` on container
- New entries animate in at top

### Anti-Patterns
- ❌ `VariableSizeList` Row component not wrapped in `memo()` — re-renders on every scroll event, kills performance
- ❌ Dual filter state (`filter` + `deferredFilter`) — incorrect `useTransition` usage; single state + `startTransition` is all that's needed
- ❌ `resetAfterIndex(index, true)` (synchronous) — use `false` for async measurement to avoid layout thrash
- ❌ `overflow: hidden` on the `style` container div around `ActivityEntry` — prevents height measurement
- ❌ `AnimatePresence` wrapping `VariableSizeList` children — virtualized rows are not real React children; `AnimatePresence` has no effect

---

## 🟢 Task DASH-006: AttentionQueue & DecisionPacket
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** DASH-001, DASH-002

### Related Files
- `src/components/dashboard/AttentionQueue.tsx` · `src/components/dashboard/DecisionPacket.tsx`

### Subtasks

**Implementation (DecisionPacket):**
- [ ] **DASH-006A**: Build `DecisionPacket` component:
  - Priority badge: Critical=`bg-red-500/20 text-red-400 border border-red-500/30`, High=amber, Medium=blue
  - Agent avatar (initials) + name + task context + decision request
  - Approve (primary), Reject (secondary), Defer (ghost) buttons
  - Each button shows `isPending` spinner from its respective mutation hook
- [ ] **DASH-006B**: Countdown timer using `useMotionValue` + `useSpring`:
  ```tsx
  const secondsLeft = useMotionValue(initialSeconds)
  const smoothSeconds = useSpring(secondsLeft, {
    stiffness: 60,
    damping: 20,
    skipInitialAnimation: true, // Motion v12 — prevents animation on first render
  })

  useEffect(() => {
    if (!packet.timeSensitive || !packet.expiresAt) return
    const interval = setInterval(() => {
      const remaining = Math.max(0, (new Date(packet.expiresAt!).getTime() - Date.now()) / 1000)
      secondsLeft.set(remaining)
      if (remaining === 0) clearInterval(interval)
    }, 1000)
    return () => clearInterval(interval)
  }, [packet.expiresAt, secondsLeft])
  ```
  This avoids React re-renders on every tick — `useMotionValue` updates bypass React's render cycle.
- [ ] **DASH-006C**: `useReducedMotion()` check: if true, replace `useSpring` with direct `useMotionValue` update (no interpolation)
- [ ] **DASH-006D**: Card entrance: `initial={{ opacity: 0, y: 16 }}` · `animate={{ opacity: 1, y: 0 }}` · spring transition

**Implementation (AttentionQueue):**
- [ ] **DASH-006E**: Build `AttentionQueue`:
  - Consumes `useAttentionQueue()`, `useApproveDecision()`, `useRejectDecision()`, `useDeferDecision()`
  - `AnimatePresence mode="popLayout"` around the packet list — `popLayout` removes the exiting element from layout immediately, letting remaining packets animate into place without waiting
  ```tsx
  <AnimatePresence mode="popLayout">
    {packets.map(packet => (
      <motion.div
        key={packet.id}
        layout
        exit={{ opacity: 0, x: 40, transition: { duration: 0.2 } }}
      >
        <DecisionPacket
          packet={packet}
          onApprove={() => approveDecision(packet.id)}
          onReject={() => rejectDecision(packet.id)}
          onDefer={() => deferDecision(packet.id)}
        />
      </motion.div>
    ))}
  </AnimatePresence>
  ```
- [ ] **DASH-006F**: `layout` prop on each packet wrapper — when one packet exits, remaining packets animate smoothly into their new positions
- [ ] **DASH-006G**: Empty state: `"No pending decisions — agents running autonomously."` Fade in, quiet tier
- [ ] **DASH-006H**: ARIA: each packet `role="article"` + `aria-label` with priority and agent name; buttons with descriptive `aria-label`

**Tests:**
- [ ] **[TEST] DASH-006I**: Packets render with correct priority badge class
- [ ] **[TEST] DASH-006J**: Approve button calls `approveDecision(packet.id)`
- [ ] **[TEST] DASH-006K**: Optimistic update removes packet immediately (before server responds)
- [ ] **[TEST] DASH-006L**: Failed approval restores packet and shows error toast
- [ ] **[TEST] DASH-006M**: Countdown timer updates every second (use `vi.useFakeTimers()`)
- [ ] **[TEST] DASH-006N**: Empty state renders when `packets = []`

### Definition of Done
- `AnimatePresence mode="popLayout"` — exiting packets don't block remaining items from repositioning
- `layout` prop on packet wrappers — remaining packets animate to new positions
- Countdown uses `useMotionValue` + `useSpring` with `skipInitialAnimation: true`
- Approve/Reject/Defer: optimistic remove with rollback on error
- All 6 tests pass

### Anti-Patterns
- ❌ `AnimatePresence` without `mode="popLayout"` — exiting packet holds its space while animating out; remaining packets don't reflow until exit completes
- ❌ `setInterval` countdown updating `useState` — triggers a React re-render every second; use `useMotionValue` to bypass React
- ❌ Mutating the cache array directly in `setQueryData` — always return a new array

---

## 🟠 Task DASH-007: AgentDetailDrawer
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** DASH-004

### Related Files
- `src/components/agents/AgentDetailDrawer.tsx` · `src/stores/slices/uiSlice.ts` (update)

### Subtasks

**Implementation:**
- [ ] **DASH-007A**: Extend `uiSlice`:
  - Add `agentDrawerOpen: boolean`, `selectedAgentId: string | null`
  - Add `openAgentDrawer(id: string)` and `closeAgentDrawer()`
- [ ] **DASH-007B**: Build `AgentDetailDrawer` using shadcn/ui `Sheet` (right side, 480px):
  - Header: large avatar, agent name, `StatusIndicator`
  - Body: current task (full), token usage sparkline placeholder, session history list, config (model, temperature — read-only)
  - Footer: "Send Message" CTA
- [ ] **DASH-007C**: `layoutId` morph from AgentCard:
  - In `AgentDetailDrawer`, the main card content area uses `motion.div layoutId={`agent-card-${selectedAgentId}`}`
  - This must use the same `layoutId` as the card in `AgentCard`
  - `LayoutGroup id="agent-fleet"` in `AgentFleetPanel` (DASH-004F) namespaces the ID, so the drawer must be inside or connected to the same `LayoutGroup` — wrap the drawer's `motion.div` with the matching `layoutId` outside any `LayoutGroup` to allow cross-tree matching
  - The scrollable content inside the drawer needs `layoutScroll` prop to account for scroll offset during the morph
- [ ] **DASH-007D**: Focus restoration:
  - On `openAgentDrawer()`: store `document.activeElement` in `uiSlice.focusTriggerRef`
  - On drawer close: `focusTriggerRef.current?.focus()`
- [ ] **DASH-007E**: "Send Message" button: `navigate('/chat', { state: { agentId: selectedAgentId, prefill: true } })`
- [ ] **DASH-007F**: Fetch agent detail data: `useAgent(selectedAgentId)` — uses `select` to find agent from cached fleet list; no extra network request if fleet is cached

**Tests:**
- [ ] **[TEST] DASH-007G**: Drawer opens when `openAgentDrawer(id)` is called
- [ ] **[TEST] DASH-007H**: Correct agent data displays (mock `useAgent`)
- [ ] **[TEST] DASH-007I**: "Send Message" navigates to `/chat` with state payload
- [ ] **[TEST] DASH-007J**: Focus returns to expand button after close

### Definition of Done
- Drawer opens with `layoutId` morph from card
- `layoutScroll` on scrollable container inside drawer
- Focus restoration works
- `useAgent` uses `select` — no duplicate API request

### Anti-Patterns
- ❌ `layoutId` in drawer without matching the card's exact `layoutId` string — morph breaks silently
- ❌ Missing `layoutScroll` on scrollable drawer content — morph animates to wrong position when page is scrolled
- ❌ Separate `/api/agents/:id` call for drawer when fleet is already cached — use `select` on the existing cache

---

## 📊 Dependency Graph

```
DASH-000 (Types + Schemas + queryOptions)
     │
DASH-001 (Factories + MSW Handlers + Hooks)
     │
     ├──────────────────────────────────────────┐
     │                                          │
DASH-002 (Page Layout) ←───────────────────────┘
     │
     ├───────────────┬───────────────┬──────────┐
     │               │               │          │
DASH-003          DASH-004        DASH-005   DASH-006
(Banner)      (AgentPanel)   (ActivityFeed) (AttentionQueue)
                   │
              DASH-007 (Drawer)
```

---

## 🏁 Dashboard Completion Checklist

**Contract & Mocks:**
- [ ] Zod schemas defined; types derived from schemas
- [ ] `@faker-js/faker` used in all factories with `resetDashboardDb()` export
- [ ] MSW handlers stateful; mutations persist in-memory session
- [ ] `delay()` in all handlers for loading state testing
- [ ] `queryOptions` + custom hooks with full type inference
- [ ] Optimistic updates: `onMutate` in `useMutation()` + immutable cache updates

**Layout & Routing:**
- [ ] `/` prefetches agents in route `loader`
- [ ] `AttentionQueue` injected into RightPanel on `/`
- [ ] `DashboardSkeleton` shown during lazy load

**Components:**
- [ ] `AmbientStatusBanner`: animated border (reduced-motion gated), `AnimatePresence`, dismiss persisted
- [ ] `AgentFleetPanel`: wrapped in `LayoutGroup id="agent-fleet"`, `viewport={{ once: true }}`
- [ ] `AgentCard`: `staggerChildren: 0.08`, `oklch()` glow on hover, `layoutId`
- [ ] `ActivityFeed`: `VariableSizeList` + memoized `Row` + `resetAfterIndex` on expand
- [ ] `ActivityEntry`: memoized with `React.memo()`
- [ ] Filter: `startTransition(() => setFilter(...))` — single state
- [ ] `AttentionQueue`: `AnimatePresence mode="popLayout"` + `layout` prop on items
- [ ] `DecisionPacket`: `useMotionValue` + `useSpring` countdown (`skipInitialAnimation: true`)
- [ ] `AgentDetailDrawer`: `layoutId` morph + `layoutScroll` + focus restoration

**Accessibility:**
- [ ] `role="log"` + implicit `aria-live="polite"` on ActivityFeed
- [ ] `role="article"` on each decision packet
- [ ] All buttons: descriptive `aria-label`
- [ ] All interactive elements: visible focus indicators

**Performance:**
- [ ] All `viewport={{ once: true }}` on scroll-triggered animations
- [ ] `transform` + `opacity` only — no layout properties animated
- [ ] `VariableSizeList` Row wrapped in `React.memo()`
- [ ] `useMemo` on filtered activity entries