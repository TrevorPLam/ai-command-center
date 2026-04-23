Based on research into the latest calendar application patterns (2025–2026), react-big-calendar's resource management capabilities, RFC 5545 iCalendar standards, browser notification APIs, and WCAG 2.2 accessibility requirements, I've produced a fully refreshed and enhanced calendar task list. The following document integrates all original tasks plus new parent tasks and enhancements, using the exact formatting you provided.

---

# 05‑Calendar — Personal AI Command Center Frontend (Enhanced v4)

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.

**Calendar library: `react-big-calendar ^1.19.4`.** This library meets all feature requirements: Month/Week/Day/Agenda/Resource views, drag‑and‑drop via `withDragAndDrop`, date‑fns localization, and time‑zone handling. No alternative library is under consideration for the MVP.

## 🔬 Research Findings — Calendar Module

| Finding | Source | Action Required |
|---------|--------|-----------------|
| **WCAG 2.5.7 Dragging Movements (AA) requires single-pointer alternatives for all drag actions.** Every drag-to-create or drag-to-resize MUST have a button- or keyboard-based alternative. | WCAG 2.2 spec | CAL‑010 and CAL‑007 must include "Click to create" and keyboard shortcuts for event creation and resizing |
| **`react-big-calendar` DnD requires the `withDragAndDrop` HOC** from `react-big-calendar/lib/addons/dragAndDrop` and its own CSS import. This is a separate addon, not enabled by default. | react-big-calendar docs | CAL‑010: wrap with `withDragAndDrop(Calendar)`, import `dragAndDrop/styles.css` |
| **Events array passed to `react-big-calendar` must be memoized** — the library performs deep comparison on event arrays and will re-render the full grid on every parent render if the array reference changes. | react-big-calendar GitHub issues | CAL‑009, CAL‑010: `const events = useMemo(...)` — never pass inline array |
| **TanStack Query optimistic updates: `cancelQueries` is mandatory** before `setQueryData` in `onMutate`. Without it, a slow in-flight refetch will overwrite the optimistic state when it resolves. | TanStack Query v5 docs | All mutation `onMutate` handlers must `await queryClient.cancelQueries(...)` first |
| **`onSettled` (not `onSuccess`) is the correct place for `invalidateQueries`** — it runs on both success and error, ensuring cache stays consistent even after rollback. | TanStack Query v5 docs, TkDodo | All mutations use `onSettled` for invalidation |
| **Recurring events require an exception model** — editing a single occurrence stores an EXDATE or overrides the series via `recurringEventId` + `originalStart`. The three edit modes are: "this event", "this and following", "all events". These are fundamentally different mutations. | RFC 5545, Nylas docs, Google Calendar UX | CAL‑013: dedicated recurring edit flow task |
| **Mini-calendar sidebar is a standard navigation affordance** in every production calendar (Google, Outlook, Apple). It allows month-at-a-glance navigation without changing the main view and is a required UX element. | G2 research 2025, product analysis | CAL‑008: mini-calendar + event filters sidebar |
| **Event conflict detection** — Apple Calendar iOS 26 and all enterprise calendar apps provide overlap warnings at creation time. This is now a UX standard expectation. | Apple WWDC 2025, G2 2025 | CAL‑008 + CAL‑002: detect overlapping events and warn |
| **iCal (.ics) import/export** is expected in every production calendar, enabling interoperability with Google Calendar, Outlook, and Apple Calendar. | RFC 5545, Syncfusion 2025 | CAL‑006: dedicated import/export task |
| **`useTransition` + `startTransition` is the 2026 pattern for view navigation debouncing** | Steve Kinney, React 2026 | CAL‑001: use `useTransition` when navigating between months/weeks |
| **`react-hook-form` + `zod` is the standard for event form validation** | dev.to 2026 | CAL‑008: use `zodResolver` with schema validation |
| **`rrule.js` v2.7 is the standard library for recurring events (RFC 5545)** | npm 2026 | CAL‑008: recurrence selector; CAL‑013: series manipulation |
| **date-fns v4 introduces first-class timezone support** via `@date-fns/tz` and `TZDate`. Use `TZDate` for all stored event times to avoid DST bugs. | date-fns v4 docs | CAL‑000: store all event start/end as UTC; CAL‑014: display in user timezone |
| **`react-window` `VariableSizeList` is recommended for agenda virtualization with 50+ events** | CSDN 2026 | CAL‑004 |
| **Motion `keyframes` with `useReducedMotion` guard** for current time indicator; apply the same guard to all Alive-tier animations | Motion docs, WCAG 2.2 | CAL‑010, CAL‑008 |
| **Scroll position in week/day time grids must be preserved on view change** — jumping to top of 24‑hour grid on every navigation is a common UX failure | react-big-calendar GitHub | CAL‑010: persist `scrollToTime` in `calendarSlice` |
| **Error boundaries per view + Suspense skeletons** — missing from original spec. Calendar data loading should show skeleton grids, not blank content. | React 19 best practices | CAL‑001: `<ErrorBoundary>` + `<Suspense fallback={<CalendarSkeleton />}>` per view |
| **Working hours configuration** on week/day views highlights non-working time and sets default event creation bounds. Used in Outlook, Google Calendar. | Syncfusion scheduler docs | CAL‑014: working hours UI config |
| **Multi‑calendar resource views** — react-big-calendar supports resources to display events across multiple calendars side by side. Required for team calendars, room scheduling, and calendar toggles. | react-big-calendar DeepWiki 2025 | CAL‑002: multi‑calendar management with resource prop |
| **Webcal Subscription Links** — generating a webcal:// or https:// endpoint for read‑only calendar subscriptions is a baseline feature for interoperability. | webcal.guru, RFC 5545 | CAL‑003: generate shareable subscription URLs |
| **Browser Notifications API** — calendar reminders must integrate with `Notification.requestPermission()` and show system notifications at event reminder times. | Web Notifications API, 2025 | CAL‑005: reminder service with browser integration |
| **RFC 5545 ICS Generation Nuances** — ICS files require CRLF line endings, 75‑byte line folding, and escaped semicolons/commas/backslashes. Silent import failures occur otherwise. | dev.to 2026, RFC 5545 §3.1 | CAL‑006: ensure export meets strict RFC compliance |
| **Calendar resource grouping layouts** — react-big-calendar `resourceGroupingLayout` toggles between grouping by resource then day (`false`) vs day then resource (`true`). | react-big-calendar resource management 2025 | CAL‑002: support both grouping layouts |
| **Bulk event actions (delete, color change)** — users expect checkboxes and action bars in Agenda view. Optimization with `onMutate` must handle multiple IDs. | TanStack Query patterns 2025 | CAL‑007: bulk event actions with optimistic updates |
| **Attendee RSVP workflow** — enterprise calendars allow attendees to accept/decline events. This requires `attendees` array with status and `useUpdateAttendeeStatus` mutation. | Google Calendar / Outlook feature parity | CAL‑004: attendee invitations and RSVP management |
| **Reminder snooze workflow** — event reminders must support "Snooze 5 min" and "Dismiss". State stored locally, mute until next reminder time. | Apple Calendar / Google Calendar UX | CAL‑005: snooze functionality in reminder service |


## 🧱 Cross‑Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **CAL‑C01** | State Management | Zustand `calendarSlice` for view, selectedDate, navigation, filters, timezone, workingHours, sidebarOpen, calendars[], activeCalendarIds. Never `useState` for global UI. |
| **CAL‑C02** | Date Handling | All stored event times are UTC (`TZDate` from `@date‑fns/tz`). Display uses user locale/timezone from `calendarSlice.timezone`. |
| **CAL‑C03** | Optimistic Updates | All event mutations follow: `cancelQueries` → `getQueryData` snapshot → `setQueryData` optimistic → return context → `onError` rollback → `onSettled` invalidate. |
| **CAL‑C04** | Virtualization | `react‑big‑calendar` handles week/day virtualization. Agenda view uses `react‑window` `VariableSizeList` for >50 events. |
| **CAL‑C05** | Drag Accessibility (WCAG 2.5.7) | Every drag interaction MUST have a button- or keyboard-based alternative. |
| **CAL‑C06** | Keyboard Navigation | Arrow keys navigate dates; Enter/Space selects; Page Up/Down changes month; Home/End moves to week start/end; `Ctrl+Shift+Arrows` for event resizing/moving. |
| **CAL‑C07** | ARIA Grid Pattern | Month view: `role="grid"`, `role="columnheader"`, `role="gridcell"`, `aria‑selected`. Resource views: each resource column marked with `role="columnheader"`. |
| **CAL‑C08** | Timezone Consistency | `TZDate` for all event start/end. Display: `format(date, 'h:mm a', { in: tz(userTimezone) })`. |
| **CAL‑C09** | Memoization | Events array passed to `react‑big‑calendar` always wrapped in `useMemo`. Accessor functions defined outside components. |
| **CAL‑C10** | Error + Loading States | Every view is wrapped in `<ErrorBoundary>` + `<Suspense fallback={<CalendarSkeleton />}>`. |
| **CAL‑C11** | Recurring Events | Event data model distinguishes master events from occurrence overrides via `recurringEventId` + `originalStart`. Edit flows respect three‑mode modal (this / this & following / all). |
| **CAL‑C12** | Notification Permissions | Browser `Notification` permission request occurs on user gesture only (e.g., "Enable Reminders" button). Permission state stored in `calendarSlice.notificationsEnabled`. |
| **CAL‑C13** | Focus Restoration | After closing any modal/drawer, return focus to the element that triggered it (store ref in Zustand). |


### 🎯 Motion Tier Assignment

| Component | Tier | Allowed Techniques |
|-----------|------|--------------------|
| Month view event chips | **Quiet** | `boxShadow` fade on hover (≤150ms) |
| Current time indicator | **Alive** | Motion `keyframes` pulse; `useReducedMotion` guard |
| Event composer modal | **Alive** | `scale: 0.95→1, opacity: 0→1`; `useReducedMotion` guard |
| Event detail drawer | **Quiet** | Spring slide via `AnimatePresence` |
| Agenda list items | **Static** | No animation |
| View transition | **Alive** | `AnimatePresence` cross‑fade with `layoutId` for selected date |
| Mini‑calendar sidebar | **Quiet** | Slide‑in on open (`x: ‑16→0`) |
| Reminder toast | **Alive** | Slide‑in from bottom; `useReducedMotion` guard |


## 🗃️ Task CAL‑000: Mock Data Layer
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** FND‑004 (Testing Infra), FND‑006 (TanStack Query)

### Related Files
`src/mocks/factories/calendar.ts` · `src/mocks/handlers.ts` · `src/queries/calendar.ts`

### Subtasks

- [ ] **CAL‑000A** Create `src/mocks/factories/calendar.ts`:
  - `createMockEvent(overrides?)` returns: `id`, `title`, `start` (UTC `TZDate`), `end` (UTC `TZDate`), `allDay`, `description`, `location`, `color`, `calendarId`, `projectId` (nullable), `reminder`, `recurrence` (RRULE string, nullable), `recurringEventId` (nullable — links occurrence to master), `originalStart` (nullable — original UTC time before edit), `attendees` (array of `{ email: string, name: string, status: 'accepted' | 'declined' | 'tentative' | 'pending' }`), `exdates` (array of Date), `conferenceUrl` (nullable), `eventTimezone` (nullable)
  - `createMockEvents(count: 20–50)` returns varied events across current month ±2 weeks, including: all‑day, multi‑day, overlapping, and a recurring series (3–4 instances)
  - `createMockEventSeries(rrule: string, count: number)` generates master + expanded occurrences for recurring‑event testing
  - `createMockCalendars()` returns array of 3–5 calendar objects: `{ id, name, color, source: 'local' | 'google' | 'outlook', visible: true, readOnly: false }`

- [ ] **CAL‑000B** Update `src/mocks/handlers.ts`:
  ```ts
  http.get('/api/calendar/events', ({ request }) => {
    const url = new URL(request.url)
    const start = url.searchParams.get('start')
    const end = url.searchParams.get('end')
    const calendarIds = url.searchParams.getAll('calendarId')
    return HttpResponse.json(createMockEvents({ start, end, calendarIds: calendarIds.length ? calendarIds : undefined }))
  })
  http.post('/api/calendar/events', async ({ request }) =>
    HttpResponse.json({ ...await request.json(), id: crypto.randomUUID() }, { status: 201 }))
  http.put('/api/calendar/events/:id', async ({ request }) =>
    HttpResponse.json(await request.json()))
  http.delete('/api/calendar/events/:id', () =>
    new HttpResponse(null, { status: 204 }))
  // Bulk operations
  http.post('/api/calendar/events/bulk', async ({ request }) =>
    HttpResponse.json(await request.json()))
  // Recurring‑specific: edit one / this‑and‑following / all
  http.put('/api/calendar/events/:id/recurring', async ({ request }) =>
    HttpResponse.json(await request.json()))
  // Attendee RSVP
  http.patch('/api/calendar/events/:id/attendees', async ({ request }) =>
    HttpResponse.json(await request.json()))
  ```

- [ ] **CAL‑000C** Create `src/queries/calendar.ts` with Query Key Factory:
  ```ts
  export const calendarKeys = {
    all: ['calendar'] as const,
    events: (start: Date, end: Date, calendarIds?: string[]) =>
      [...calendarKeys.all, 'events', start.toISOString(), end.toISOString(), calendarIds?.join(',')] as const,
    event: (id: string) => [...calendarKeys.all, 'event', id] as const,
    search: (query: string) => [...calendarKeys.all, 'search', query] as const,
    calendars: () => [...calendarKeys.all, 'calendars'] as const,
    subscribers: (calendarId: string) => [...calendarKeys.all, 'subscribers', calendarId] as const,
  }
  ```

- [ ] **CAL‑000D** Define `eventsQueryOptions(start: Date, end: Date, calendarIds?: string[])`:
  - `staleTime: 1000 * 60 * 2`
  - `queryFn: () => fetchEvents(start, end, calendarIds)` — fetches events overlapping the range, filtered by optional calendarIds

- [ ] **CAL‑000E** Create `useCalendarEvents(start, end)` consuming `eventsQueryOptions`

- [ ] **CAL‑000F** Create mutation hooks — each MUST follow the full optimistic pattern:
  ```ts
  onMutate: async (input) => {
    await queryClient.cancelQueries({ queryKey: calendarKeys.events(start, end) })
    const previous = queryClient.getQueryData(calendarKeys.events(start, end))
    queryClient.setQueryData(calendarKeys.events(start, end), (old) => /* optimistic */)
    return { previous }
  },
  onError: (_err, _input, context) => {
    queryClient.setQueryData(calendarKeys.events(start, end), context?.previous)
  },
  onSettled: () => {
    queryClient.invalidateQueries({ queryKey: calendarKeys.all })
  },
  ```
  - `useCreateEvent()` — optimistic: append to cache with temp `id: 'optimistic-${Date.now()}'`
  - `useUpdateEvent()` — optimistic: replace matching event in cache
  - `useDeleteEvent()` — optimistic: filter out from cache
  - `useBulkUpdateEvents()` — optimistic: replace matching event IDs in cache
  - `useBulkDeleteEvents()` — optimistic: filter out matching event IDs
  - `useUpdateRecurringEvent()` — accepts `mode: 'this' | 'thisAndFollowing' | 'all'`; updates cache accordingly
  - `useUpdateAttendeeStatus()` — optimistic: update attendee status in cache

- [ ] **CAL‑000G** Create `useSearchEvents(query: string)`:
  - `enabled: query.length >= 2`
  - `staleTime: 1000 * 30`
  - Client‑side filter of cached events (no extra API call for offline‑first feel)

- [ ] **CAL‑000H** Create `useCalendars()` and `useUpdateCalendar()` hooks

### Tests
- [ ] Factory produces events with all required fields including `attendees`, `calendarId`, `recurringEventId`
- [ ] `createMockEventSeries` produces linked master + occurrence objects
- [ ] `createMockCalendars` returns 3–5 calendars with distinct colors
- [ ] MSW handlers respond correctly to all endpoints, including bulk and attendee endpoints
- [ ] `useCreateEvent` applies optimistic state and rolls back on 500 response
- [ ] `cancelQueries` is called before `setQueryData` in every mutation (test with spy)
- [ ] `onSettled` invalidates `calendarKeys.all` regardless of success/error

### Definition of Done
- Full mock factory with recurring/attendee/calendar support
- All mutations implement `cancelQueries → snapshot → optimistic → rollback → invalidate`
- Query key factory covers events, single event, search, calendars, and subscribers
- `pnpm test` passes

### Anti‑Patterns
- ❌ `onSuccess` for `invalidateQueries` — use `onSettled`
- ❌ `setQueryData` before `cancelQueries` — race condition
- ❌ Hardcoded `id` in optimistic create — use `'optimistic-${Date.now()}'` prefix for easy identification
- ❌ Mutating the previous cache snapshot before returning it as context


## 🔧 Task CAL‑001: Calendar Page Layout & State Management
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** FND‑007 (Router), CAL‑000

### Related Files
`src/pages/CalendarPage.tsx` · `src/stores/slices/calendarSlice.ts` · `src/router/routes.ts` · `src/components/calendar/CalendarSkeleton.tsx`

### Subtasks

**Zustand Slice:**
- [ ] **CAL‑001A** Create `src/stores/slices/calendarSlice.ts`:
  ```ts
  interface CalendarSlice {
    // View & Navigation
    view: 'month' | 'week' | 'day' | 'agenda' | 'resourceWeek'
    selectedDate: Date
    scrollToTime: Date // persisted scroll position for week/day views
    // Modals
    selectedEventId: string | null
    composerOpen: boolean
    composerInitialDate: Date | null
    composerInitialEvent: CalendarEvent | null // pre‑fills for edit
    drawerOpen: boolean
    // Sidebar
    sidebarOpen: boolean
    // Filters
    eventFilters: { colors: string[]; projectIds: string[]; searchQuery: string; calendarIds: string[] }
    // Multi‑Calendar
    calendars: Calendar[]
    activeCalendarIds: string[]
    // Preferences
    timezone: string // IANA tz string, e.g. 'America/Chicago'
    timeFormat: '12h' | '24h'
    workingHours: { start: number; end: number } // hours, e.g. { start: 9, end: 17 }
    notificationsEnabled: boolean
    // Actions
    setView: (view: CalendarSlice['view']) => void
    navigateNext: () => void
    navigatePrev: () => void
    navigateToday: () => void
    setSelectedDate: (date: Date) => void
    setScrollToTime: (time: Date) => void
    openComposer: (opts?: { date?: Date; event?: CalendarEvent }) => void
    closeComposer: () => void
    openDrawer: (eventId: string) => void
    closeDrawer: () => void
    toggleSidebar: () => void
    setEventFilters: (filters: Partial<CalendarSlice['eventFilters']>) => void
    toggleCalendarVisibility: (calendarId: string) => void
    setTimezone: (tz: string) => void
    setTimeFormat: (fmt: '12h' | '24h') => void
    setWorkingHours: (hours: CalendarSlice['workingHours']) => void
    setNotificationsEnabled: (enabled: boolean) => void
  }
  ```

- [ ] **CAL‑001B** Implement navigation using date‑fns with timezone awareness:
  - Month: `addMonths(selectedDate, ±1)`
  - Week: `addWeeks(selectedDate, ±1)`
  - Day: `addDays(selectedDate, ±1)`
  - Agenda: `addMonths(selectedDate, ±1)`
  - All: apply user's IANA timezone when formatting display

- [ ] **CAL‑001C** Export atomic selector hooks: `useCalendarView()`, `useSelectedDate()`, `useCalendarFilters()`, `useCalendarPreferences()`, `useCalendarSidebar()`, `useActiveCalendars()`

- [ ] **CAL‑001D** Persist `view`, `timezone`, `timeFormat`, `workingHours`, `sidebarOpen`, and `activeCalendarIds` to `localStorage` via Zustand `persist` middleware

**Page Layout:**
- [ ] **CAL‑001E** Create `src/pages/CalendarPage.tsx`:
  - Top bar: view switcher (Month/Week/Day/Agenda/Resource Week), nav arrows, "Today", "New Event", search icon, sidebar toggle, overflow menu (⌘) containing Import/Export, Print, Subscribe to Calendar, Keyboard Shortcuts
  - Left sidebar: collapsible, renders `<MiniCalendarSidebar />` (CAL‑002), `<CalendarList />` (CAL‑002)
  - Main content: `<ErrorBoundary>` → `<Suspense fallback={<CalendarSkeleton view={view} />}>` → active view component
  - Right: not used (full‑width)

- [ ] **CAL‑001F** Create `src/components/calendar/CalendarSkeleton.tsx`:
  - Month variant: 7‑column grid of pulse‑animated cells
  - Week/Day variant: time‑gutter + column skeleton with pulse‑animated event blocks
  - Resource Week variant: multiple columns per day with resource headers
  - Agenda variant: list of skeleton rows

- [ ] **CAL‑001G** Configure route in `src/router/routes.ts`:
  ```ts
  {
    path: 'calendar',
    lazy: () => import('@/pages/CalendarPage'),
    loader: ({ context: { queryClient } }) => {
      const now = new Date()
      return queryClient.ensureQueryData(
        eventsQueryOptions(startOfMonth(now), endOfMonth(now))
      )
    },
  }
  ```

- [ ] **CAL‑001H** Wrap view navigation in `useTransition`:
  ```tsx
  const [isPending, startTransition] = useTransition()
  const handleNavigate = (dir: 'next' | 'prev') =>
    startTransition(() => navigate(dir))
  ```
  Show subtle opacity pulse on main content when `isPending`

- [ ] **CAL‑001I** Add `AnimatePresence` page‑transition wrapper with cross‑fade

### Tests
- [ ] Navigating to `/calendar` renders `CalendarPage` with top bar and skeleton during load
- [ ] View switcher calls `setView` and updates visible component
- [ ] Next/prev/today update `selectedDate` correctly for all view types
- [ ] Route loader prefetches current‑month events via `ensureQueryData`
- [ ] `calendarSlice` state persists across simulated page reload (localStorage mock)
- [ ] `workingHours`, `timezone`, `timeFormat`, `activeCalendarIds` are readable from selector hooks
- [ ] Toggling calendar visibility updates `activeCalendarIds` and filters events

### Definition of Done
- Zustand slice provides full calendar state including timezone, workingHours, and multi‑calendar support
- Page layout renders skeleton during load and error state on failure
- Route prefetches data; view transitions debounced with `useTransition`
- State persisted to localStorage

### Anti‑Patterns
- ❌ `useState` for view or selectedDate — must be Zustand
- ❌ Skipping `cancelQueries` guard in skeleton — skeleton must show real suspense boundary
- ❌ Persisting `selectedDate` to localStorage — causes stale date on reload
- ❌ Not wrapping each view in `ErrorBoundary` — calendar data errors must be isolated


## 🗓️ Task CAL‑002: Multi‑Calendar Support & Calendar List Sidebar
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** CAL‑001, CAL‑000

### Related Files
`src/components/calendar/CalendarList.tsx` · `src/components/calendar/AddCalendarModal.tsx` · `src/components/calendar/ResourceWeekView.tsx`

### Subtasks

- [ ] **CAL‑002A** Build `CalendarList` sidebar component (below mini‑calendar):
  - Section headers: "My Calendars", "Other Calendars"
  - Each calendar row: colored checkbox, name, visibility toggle (eye icon), dropdown menu (Edit, Delete, Share, Refresh)
  - "Add Calendar" button opens `AddCalendarModal`

- [ ] **CAL‑002B** Implement `AddCalendarModal`:
  - Three tabs: "Create New" (name, color picker) / "Connect Account" (Google/Outlook OAuth stubs) / "Subscribe" (URL input for `.ics` feed)
  - For OAuth: mock connection with success toast; store `source: 'google'` with `sourceId`
  - For URL: validate input format (`https://` or `webcal://`), show preview of found events before subscribing

- [ ] **CAL‑002C** Create `useCalendars()` hook and integrate with MSW:
  - GET `/api/calendars` returns mock calendars
  - POST `/api/calendars` creates new local calendar
  - DELETE `/api/calendars/:id` removes calendar and cascades to events (optimistic mutation)
  - PATCH `/api/calendars/:id` updates name/color/visibility

- [ ] **CAL‑002D** Update event model: add `calendarId` field (default to user's primary calendar ID)

- [ ] **CAL‑002E** Filter events by `activeCalendarIds`: `useCalendarEvents` passes `calendarIds` param to `eventsQueryOptions`

- [ ] **CAL‑002F** Create `ResourceWeekView` using react‑big‑calendar resources:
  ```tsx
  const resources = activeCalendars.map(c => ({ resourceId: c.id, resourceTitle: c.name }))
  const resourceIdAccessor = (event: CalendarEvent) => event.calendarId
  <DnDCalendar
    view="resourceWeek"
    resources={resources}
    resourceIdAccessor={resourceIdAccessor}
    resourceTitleAccessor="resourceTitle"
  />
  ```
  - Supports drag‑to‑move events between calendars
  - `resourceGroupingLayout` toggle via toolbar: Resources by day / Day by resources

- [ ] **CAL‑002G** Implement "Hide calendar" (eye toggle): updates `activeCalendarIds` slice and filters events from all views

- [ ] **CAL‑002H** Calendar settings: per‑calendar configuration (default color for new events, notifications toggle, default reminder)

### Tests
- [ ] `CalendarList` renders local calendars and "Other Calendars" section
- [ ] Creating a new calendar adds it to the list and updates Zustand slice
- [ ] Deleting a calendar removes it and all associated events (optimistic)
- [ ] Toggling visibility checkbox removes/restores events from all views
- [ ] `ResourceWeekView` renders columns per calendar, events appear in correct calendar column
- [ ] Drag‑to‑move between calendars updates `event.calendarId` via mutation
- [ ] OAuth stubs show success toast and add calendar to list
- [ ] URL subscription validates, previews events, and adds read‑only calendar

### Definition of Done
- Multi‑calendar sidebar with visibility toggles and calendar management
- Resource Week view showing events grouped by calendar
- Event filtering by active calendar IDs
- OAuth and subscription stubs with preview

### Anti‑Patterns
- ❌ Storing `calendars` in React state — must be Zustand + React Query
- ❌ Not supporting `resourceIdAccessor` in drag‑and‑drop — prevents calendar‑to‑calendar moves
- ❌ Cascading delete client‑side without optimistic update pattern


## 🔗 Task CAL‑003: External Calendar Integration & Webcal Subscriptions
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** CAL‑002, CAL‑006

### Related Files
`src/components/calendar/CalendarShareModal.tsx` · `src/utils/webcal.ts`

### Subtasks

- [ ] **CAL‑003A** Build `CalendarShareModal` accessible from calendar dropdown:
  - Tabs: "Share with people" / "Get shareable link" / "Embed"
  - "Get shareable link" generates mock token for read‑only feed: `https://app.local/calendar/feed/${calendarId}?token=${mockToken}`
  - Display both **Webcal** (`webcal://...`) and **HTTPS** links
  - Copy button with success toast
  - "Regenerate link" button (in case of security concern)

- [ ] **CAL‑003B** Create mock endpoint for calendar feed:
  ```ts
  http.get('/api/calendar/feed/:calendarId', ({ params, request }) => {
    const token = new URL(request.url).searchParams.get('token')
    if (!isValidToken(token)) return new HttpResponse(null, { status: 401 })
    return new HttpResponse(generateICS([...events]), {
      headers: { 'Content-Type': 'text/calendar; charset=utf-8' }
    })
  })
  ```

- [ ] **CAL‑003C** Create `src/utils/webcal.ts`:
  ```ts
  export function generateCalendarFeed(token: string): string; // full URL
  export function validateFeedToken(token: string): boolean; // mock validation
  export function parseWebcalUrl(url: string): { calendarId: string; token: string };
  ```

- [ ] **CAL‑003D** External source refresh: "Refresh" button on Google/Outlook calendars triggers `useRefreshExternalCalendar` mutation (mock)

- [ ] **CAL‑003E** Conflict resolution settings per external calendar: "Keep mine", "Keep theirs", "Ask me"

### Tests
- [ ] `CalendarShareModal` generates both `webcal://` and `https://` URLs
- [ ] Copy button triggers clipboard write and shows toast
- [ ] Feed endpoint returns 401 with invalid token, 200 with valid ICS
- [ ] Generated ICS contains correct `PRODID`, `X‑WR‑CALNAME`, and `REFRESH‑INTERVAL` headers
- [ ] Refresh button triggers mock mutation and updates "Last synced" timestamp

### Definition of Done
- Shareable subscription links for each calendar (webcal:// and https://)
- Mock feed endpoint serving ICS with token validation
- External calendar refresh stub

### Anti‑Patterns
- ❌ Generating `webcal://` links without also providing HTTPS fallback — some clients only support HTTPS
- ❌ Forgetting `X‑WR‑CALNAME` header in ICS — subscriber won't know the calendar name


## 👥 Task CAL‑004: Attendee Invitations & RSVP Management
**Priority:** 🟠 Medium | **Est. Effort:** 2.5 hours | **Depends On:** CAL‑008, CAL‑011

### Related Files
`src/components/calendar/AttendeeInput.tsx` · `src/components/calendar/RSVPButtons.tsx` · `src/hooks/useAttendeeStatus.ts`

### Subtasks

- [ ] **CAL‑004A** Build `AttendeeInput` component for `EventComposer` (CAL‑008):
  - Email input with validation (`z.string().email()`)
  - Chip display of added attendees, with remove (×) icon
  - Optional: "Add guests" expander with role selector (optional / required)
  - On submit: `attendees` array included in event creation

- [ ] **CAL‑004B** Build `RSVPButtons` component for `EventDetailDrawer` (CAL‑011):
  - Three‑button group: ✅ Accept, ❓ Tentative, ❌ Decline
  - Current user's status highlighted, other attendees listed in a collapsible section with status badges
  - Attendance summary (e.g., "2 going, 1 maybe, 1 declined")

- [ ] **CAL‑004C** Create `useUpdateAttendeeStatus()` mutation:
  - Optimistic update of attendee status in `calendarKeys.events` cache
  - Updates `status` field for matching attendee email

- [ ] **CAL‑004D** Add attendee response to activity log: "John Smith changed status to Accepted"

- [ ] **CAL‑004E** Invitation email stub:
  - When event is created/updated with attendees, show toast: "Invitation email sent to 3 guests"

- [ ] **CAL‑004F** Drawing from user context: `currentUserEmail` from auth store should be displayed as "You" in attendee list

### Tests
- [ ] `AttendeeInput` validates email format and prevents duplicates
- [ ] Chips can be added (Enter/comma) and removed (× click)
- [ ] `RSVPButtons` renders current user's status highlighted
- [ ] Clicking "Accept" updates optimistic cache and shows success toast
- [ ] Attendee list in drawer shows status badges per attendee
- [ ] Activity log entry appears after status change

### Definition of Done
- Attendees can be added in composer
- RSVP buttons update attendee status
- Attendee list visible in drawer
- Email stubs shown as toast

### Anti‑Patterns
- ❌ Storing `attendees` as plain strings — must be `{ email: string; name?: string; status: string }` array
- ❌ Not implementing `cancelQueries` before optimistic attendee update


## 🔔 Task CAL‑005: Reminder Service & Browser Notifications
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** CAL‑001, CAL‑000

### Related Files
`src/services/reminderService.ts` · `src/components/calendar/ReminderToast.tsx` · `src/hooks/useNotificationPermission.ts`

### Subtasks

- [ ] **CAL‑005A** Create `src/hooks/useNotificationPermission.ts`:
  - Checks `Notification` API support and `Notification.permission`
  - Returns `{ permission, requestPermission, isSupported }`
  - Permission request only triggered by user gesture ("Enable Notifications" button in settings)

- [ ] **CAL‑005B** Build `ReminderToast` component:
  - Rendered via global toast system when reminder fires
  - Displays: event title, time, actions: "Snooze 5 min" and "Dismiss"
  - Animation: Alive‑tier slide‑in from bottom (with `useReducedMotion` guard)
  - Snooze: stores snooze timestamp locally; re‑fires after duration

- [ ] **CAL‑005C** Create `src/services/reminderService.ts`:
  ```ts
  class ReminderService {
    private timers: Map<string, NodeJS.Timeout>
    scheduleReminders(events: CalendarEvent[]): void // clears old, sets new
    clearAll(): void
    private fireReminder(event: CalendarEvent): void
  }
  ```
  - Each event with `reminder !== 'none'`: schedule `setTimeout` for `start - reminderOffset`
  - Max scheduling window: 7 days ahead (beyond that, schedule on app load)
  - Service runs in main thread; for background persistence, use Service Worker stub (optional)

- [ ] **CAL‑005D** Integrate with Zustand:
  - `calendarSlice.notificationsEnabled` toggles system notifications
  - Settings page toggle writes to slice + localStorage
  - ReminderService only fires if `notificationsEnabled && permission === 'granted'`

- [ ] **CAL‑005E** Mock reminder state in development:
  - Dev tools button: "Test reminder" fires a sample reminder toast immediately

### Tests
- [ ] Permission request triggers browser prompt and updates `permission` state
- [ ] Reminder schedules `setTimeout` for correct offset
- [ ] Snooze stores local time and re‑fires after snooze duration
- [ ] Dismiss removes reminder and does not re‑fire
- [ ] ReminderService clears timers on component unmount
- [ ] With `notificationsEnabled: false`, reminders are suppressed

### Definition of Done
- Browser notification permission handling
- Snoozeable reminder toasts
- Reminder scheduling based on event `reminder` field
- Global preferences toggle for notifications

### Anti‑Patterns
- ❌ Requesting notification permission on page load — must be user‑gesture only
- ❌ Leaving timers active after component unmount — memory leak
- ❌ Not checking `Notification.permission` before scheduling


## 📤 Task CAL‑006: iCal Import & Export (Enhanced)
**Priority:** 🟢 Low | **Est. Effort:** 3 hours | **Depends On:** CAL‑000, CAL‑013, CAL‑002

### Related Files
`src/utils/ical.ts` · `src/components/calendar/ImportExportPanel.tsx`

### Subtasks

- [ ] **CAL‑006A** Install libraries for iCal import/export:
  ```bash
  pnpm add ical.js ical-generator
  ```
  Use the `ical-generator` library to produce `.ics` content. This library correctly handles CRLF line endings, 75‑byte folding, and text escaping as required by RFC 5545. Manual string generation is error‑prone and must not be used.

- [ ] **CAL‑006B** Create `src/utils/ical.ts` with full RFC 5545 compliance:
  ```ts
  import ical from 'ical-generator';
  import { parseComponents } from 'ical.js';

  // Export using ical-generator
  export function eventsToICS(events: CalendarEvent[], calendarName?: string): string {
    const calendar = ical({ name: calendarName || 'Calendar' });
    events.forEach(event => {
      calendar.createEvent({
        start: event.start,
        end: event.end,
        summary: event.title,
        description: event.description,
        location: event.location,
        uid: event.id,
        stamp: new Date(),
        // Add recurrence, attendees, etc. as needed
      });
    });
    return calendar.toString();
  }

  // Import using ical.js
  export function parseICS(icsString: string): Partial<CalendarEvent>[] {
    const jcalData = parseComponents(icsString);
    // Convert jcalData to CalendarEvent format
    return [];
  }
  ```

- [ ] **CAL‑006C** Export flow enhancements:
  - Options: "Export visible calendars only" (respects `activeCalendarIds`)
  - Options: "Export selected date range" (current view range) or "Export all events"
  - Download triggers `.ics` file with filename: `calendar-export-${date}-${calendarNames}.ics`

- [ ] **CAL‑006D** Import flow enhancements:
  - Preview shows calendar selection: "Import into: [Primary Calendar]" dropdown
  - Progress indicator: event‑by‑event count asynchronously processed
  - Partial import: show "Imported 12 of 15 events. 3 failed."

- [ ] **CAL‑006E** Error handling:
  - Invalid `.ics` file: "Could not parse file. Ensure it's a valid iCal (.ics) file."
  - Validate DTSTART/DTEND conversion to UTC using `TZDate`
  - Ignore unsupported components (VALARM, VJOURNAL) gracefully

- [ ] **CAL‑006F** Recurring event export: master events export with full RRULE; occurrence overrides export as standalone VEVENTs with `RECURRENCE‑ID`

### Tests
- [ ] `foldLine` splits lines at 75‑byte boundaries, adding CRLF + space for continuation
- [ ] `escapeText` handles backslashes first, then semicolons/commas/newlines
- [ ] `eventsToICS` includes mandatory `DTSTAMP` per VEVENT
- [ ] `eventsToICS` correctly formats all‑day events with `DTSTART;VALUE=DATE`
- [ ] `parseICS` returns events with UTC‑normalized dates
- [ ] Export UI: calendar dropdown filters exported calendars
- [ ] Import preview shows event count and calendar selector
- [ ] Partial import failure shows partial success message

### Definition of Done
- Export generates strictly RFC 5545 compliant `.ics` (CRLF, folding, escaping, UID, DTSTAMP)
- Import parses `.ics`, previews, and batch‑creates with progress feedback
- Recurring events fully supported in both directions

### Anti‑Patterns
- ❌ Manual ICS string generation — use `ical-generator` library instead
- ❌ Omitting `DTSTAMP` in VEVENT — silent failure in Google Calendar/Outlook
- ❌ Parallel batch mutations on import — use sequential processing to avoid cache thrash
- ❌ Exporting local timezone datetimes — all DTSTART/DTEND must be UTC (`Z` suffix)


## 📊 Task CAL‑007: Bulk Event Actions
**Priority:** 🟠 Medium | **Est. Effort:** 1.5 hours | **Depends On:** CAL‑004 (Agenda View), CAL‑000

### Related Files
`src/components/calendar/BulkActionBar.tsx` · `src/hooks/useBulkEventSelection.ts`

### Subtasks

- [ ] **CAL‑019A** Create `src/hooks/useBulkEventSelection.ts`:
  ```ts
  interface BulkSelectionState {
    selectedIds: Set<string>
    toggle: (id: string) => void
    toggleAll: (ids: string[]) => void
    clear: () => void
    isSelected: (id: string) => boolean
    count: number
  }
  ```

- [ ] **CAL‑019B** Build `BulkActionBar` component (floating, bottom‑fixed when items selected):
  - Shows: "{N} events selected"
  - Actions: Delete, Change Color (dropdown), Move to Calendar (dropdown)
  - "Clear selection" button

- [ ] **CAL‑019C** Add checkboxes to `AgendaEventRow` (and optionally `MonthView` shift‑click selection):
  - Checkbox visible on hover/focus of row
  - Shift‑click range selection: select all events between first and last clicked

- [ ] **CAL‑019D** Implement bulk mutations:
  - `useBulkDeleteEvents()`: optimistic cache removal of all selected IDs
  - `useBulkUpdateEventsCalendar()`: change `calendarId` for all selected IDs
  - `useBulkUpdateEventsColor()`: change `color` for all selected IDs

- [ ] **CAL‑019E** Bulk optimistic update pattern:
  ```ts
  onMutate: async ({ ids, patch }) => {
    await queryClient.cancelQueries({ queryKey: calendarKeys.all })
    const previous = snapshot...
    // Update each matching event in multiple query caches
    queryClient.setQueriesData({ queryKey: calendarKeys.all }, (old) => {
      // Map over events and update matching IDs
    })
    return { previous }
  }
  ```

- [ ] **CAL‑019F** Keyboard accessibility:
  - `Space` toggles selection on focused row
  - `Escape` clears selection
  - `Delete` triggers bulk delete confirmation

### Tests
- [ ] Checkbox appears on row hover/focus
- [ ] Shift‑click selects range between first and last row
- [ ] `BulkActionBar` appears when 1+ events selected, displays correct count
- [ ] Delete action shows confirmation dialog, then optimistic removal
- [ ] Change color dropdown updates all selected events in cache
- [ ] Move to Calendar updates `calendarId` for all selected events
- [ ] `Escape` clears selection and hides action bar

### Definition of Done
- Bulk selection in Agenda view (shift‑click range)
- Floating action bar with delete, color change, calendar move
- Optimistic bulk mutations with proper cache updates
- Keyboard accessible

### Anti‑Patterns
- ❌ Updating `react‑big‑calendar` cache without proper `setQueriesData` pattern
- ❌ Not providing keyboard alternative for selection (WCAG 2.5.7)
- ❌ Forgetting to clear selection after bulk action completes


## ✏️ Task CAL‑008: Event Composer Modal (Enhanced)
**Priority:** 🔴 High | **Est. Effort:** 3.5 hours | **Depends On:** CAL‑001, CAL‑000, CAL‑012

### Related Files
`src/components/calendar/EventComposer.tsx` · `src/schemas/eventSchema.ts`

### Subtasks

- [ ] **CAL‑005A** Install dependencies:
  ```bash
  pnpm add react-hook-form zod@4.3.6 @hookform/resolvers@5.2.2 rrule
  ```

- [ ] **CAL‑005B** Update `src/schemas/eventSchema.ts`:
  ```ts
  export const eventSchema = z.object({
    title: z.string().min(1, 'Title is required').max(255),
    start: z.date(),
    end: z.date(),
    allDay: z.boolean().default(false),
    description: z.string().max(2000).optional(),
    location: z.string().max(500).optional(),
    color: z.enum(['blue', 'green', 'purple', 'red', 'orange', 'teal']).default('blue'),
    calendarId: z.string(),
    projectId: z.string().nullable().default(null),
    reminder: z.enum(['none', '5min', '15min', '30min', '1hour', '1day']).default('15min'),
    recurrence: z.enum(['none', 'daily', 'weekly', 'monthly', 'yearly']).default('none'),
    recurrenceEnd: z.enum(['never', 'count', 'until']).default('never'),
    recurrenceCount: z.number().int().min(1).max(999).optional(),
    recurrenceUntil: z.date().optional(),
    // Advanced recurrence
    weekdays: z.array(z.number().min(0).max(6)).optional(), // 0=Sun
    monthlyOnDay: z.number().min(1).max(31).optional(),
    monthlyOnWeekday: z.object({ week: z.number(), day: z.number() }).optional(),
    attendees: z.array(z.object({
      email: z.string().email(),
      name: z.string().optional(),
      status: z.enum(['pending', 'accepted', 'declined', 'tentative']).default('pending'),
      optional: z.boolean().default(false),
    })).default([]),
    conferenceUrl: z.string().url().optional().or(z.literal('')),
    eventTimezone: z.string().optional(), // override timezone for this event
  }).refine((d) => d.end >= d.start, {
    message: 'End time must be after start time',
    path: ['end'],
  })
  ```

- [ ] **CAL‑005C** Build `EventComposer` using shadcn `Dialog`:
  - Opens from `calendarSlice.composerOpen`
  - Pre‑fills with `composerInitialDate` (slot click) or `composerInitialEvent` (edit flow)
  - Calendar selector dropdown (shows `activeCalendars`)
  - Default start: round current time up to next 30‑min boundary
  - Default end: start + 1 hour

- [ ] **CAL‑005D** Form fields (updated):
  - Title (text input, autofocus)
  - Calendar selector (required)
  - All‑day toggle — hides time fields when enabled
  - Date + Start Time + End Time (with timezone indicator)
  - Timezone override dropdown (`eventTimezone`) — shown when different from user default
  - Description (textarea, optional)
  - Location (text input, optional)
  - "Add conferencing" button (generates placeholder Zoom/Meet URL)
  - Color picker (6 color preset swatches)
  - Link to project dropdown
  - Attendees input with role (optional/required)
  - Reminder dropdown
  - Repeat dropdown → if not 'none', expands to:
    - Advanced recurrence builder: weekdays picker, monthly options (day X or "first Monday")
    - Recurrence end options (Count / Until date)

- [ ] **CAL‑005E** Integrate `react‑hook‑form` with `zodResolver`:
  - `mode: 'onBlur'`
  - Inline error messages beneath each field
  - Disable submit button while `formState.isSubmitting`

- [ ] **CAL‑005F** Conflict detection before submit:
  - Check `useCalendarEvents(start, end)` cache for overlapping events (same day, overlapping time, not allDay)
  - If conflict found: show inline warning banner "Conflicts with: [event title] at [time]"
  - Warning is non‑blocking — user can proceed
  - Conflict check is skipped for all‑day events

- [ ] **CAL‑005G** Submit handler:
  ```ts
  onSubmit: async (values) => {
    const event = buildEventFromForm(values, userTimezone)
    if (composerInitialEvent?.recurringEventId && !composerInitialEvent?.id.startsWith('optimistic')) {
      // Editing a recurring occurrence — delegate to RecurringEditModal (CAL‑009)
      openRecurringEditModal(event)
      return
    }
    await createEventMutation.mutateAsync(event)
    closeComposer()
  }
  ```

- [ ] **CAL‑005H** Modal entrance animation (Alive tier, with `useReducedMotion` guard)

- [ ] **CAL‑005I** All interactive elements min 44×44px on mobile, 24×24px desktop (WCAG 2.5.8)

### Tests
- [ ] Composer opens on "New Event" click and on calendar slot click
- [ ] Pre‑fill: `composerInitialDate` sets start correctly; `composerInitialEvent` fills all fields
- [ ] Calendar dropdown shows only `activeCalendars`
- [ ] Advanced recurrence: weekdays selection produces correct RRULE
- [ ] "Add conferencing" generates placeholder URL
- [ ] Validation: empty title shows error; end < start shows error
- [ ] All‑day toggle hides time fields and clears time values
- [ ] Conflict detection banner appears when overlapping event exists
- [ ] Attendee chips can be added (with optional toggle) and removed
- [ ] Editing recurring event delegates to `openRecurringEditModal`
- [ ] Failed mutation rolls back optimistic update and shows toast

### Definition of Done
- Full event form with calendar selection, advanced recurrence, attendees, conferencing link
- Zod validation with inline errors
- Optimistic creation with rollback
- Recurring edit awareness — delegates to CAL‑009

### Anti‑Patterns
- ❌ Mutating a recurring event directly without mode selection
- ❌ Storing local timezone dates — all `start`/`end` must be converted to UTC before mutation
- ❌ Skipping `cancelQueries` in `onMutate` for create mutation


## 📅 Task CAL‑009: Month View (Enhanced)
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** CAL‑001, CAL‑012

### Related Files
`src/components/calendar/MonthView.tsx` · `src/components/calendar/EventChip.tsx` · `src/components/calendar/MoreEventsPopover.tsx`

### Subtasks

- [ ] **CAL‑002A** Install and configure `react‑big‑calendar` with resource support:
  ```bash
  pnpm add react-big-calendar@1.19.4 @types/react-big-calendar
  ```
  Configure `dateFnsLocalizer` with date‑fns v4 locale

- [ ] **CAL‑002B** Update `MonthView` to pass resources for multi‑calendar coloring:
  ```tsx
  const resources = activeCalendars.map(c => ({ resourceId: c.id, resourceTitle: c.name }))
  const eventPropGetter = (event) => ({
    style: { backgroundColor: `var(--calendar-${event.color})` }
  })
  ```

- [ ] **CAL‑002C** Build `EventChip` component with enhancements:
  - Displays: color dot + truncated title + exception marker (⤴) for modified occurrences
  - `whileHover={{ boxShadow: '0 0 8px oklch(...)' }}` (quiet tier)
  - `aria‑label` includes calendar name: `"${event.title}, ${calendarName}, ${formatEventTime(event)}"`
  - Min target size 24×24px (WCAG 2.5.8)
  - Right‑click context menu: Edit, Delete, Duplicate, Change Calendar

- [ ] **CAL‑002D** Limit visible chips per cell to 3; remaining shown via `popup` prop's built‑in "+n more" popover

- [ ] **CAL‑002E** Implement ARIA grid pattern via custom `components.dateHeader`:
  - Each date cell: `role="gridcell"`, `aria‑selected={isSelected}`, `aria‑label={format(date, 'EEEE, MMMM d, yyyy, N events scheduled')}`
  - Week row container: `role="row"`
  - Month grid wrapper: `role="grid"`, `aria‑label="Calendar, Month view"`

- [ ] **CAL‑002F** Dark‑theme CSS overrides (scoped to `.calendar‑month‑wrapper`)

- [ ] **CAL‑002G** Keyboard navigation (custom `onKeyDown` on grid container):
  - `ArrowRight/Left/Up/Down`: move focus to adjacent day
  - `Enter/Space`: open composer for focused day
  - `PageUp/PageDown`: previous/next month
  - `Home/End`: first/last day of week
  - `Shift+Click`: range selection for bulk actions (CAL‑019)

- [ ] **CAL‑002H** Responsive: on viewport <768px, show only 3 events per cell max; on <480px switch to a compact dot‑per‑event display

- [ ] **CAL‑002I** Week numbers toggle: add column showing ISO week number (controlled by `calendarSlice.showWeekNumbers`)

### Tests
- [ ] Month grid renders correct number of weeks for current month
- [ ] Events appear on correct dates with correct calendar‑specific colors
- [ ] Exception marker (⤴) appears on modified recurring occurrences
- [ ] Right‑click context menu opens with correct actions
- [ ] Clicking a day opens composer with `composerInitialDate` pre‑filled and default calendar
- [ ] Clicking an event opens drawer with correct `selectedEventId`
- [ ] Filtered events (by color, calendarId) are hidden when filters active
- [ ] Keyboard: `ArrowRight` moves focus, `Enter` opens composer, `PageUp` changes month
- [ ] Off‑range days are visually distinct and not interactive
- [ ] Week numbers column renders (when toggled)
- [ ] Memoization: events array reference is stable when unrelated state changes

### Definition of Done
- Month view renders with react‑big‑calendar, events memoized, multi‑calendar support
- ARIA grid pattern implemented with full screen reader support
- Keyboard navigation functional
- Right‑click context menu, exception markers, week numbers toggle

### Anti‑Patterns
- ❌ Building month grid from scratch
- ❌ Passing `events={rawEvents}` directly without `useMemo`
- ❌ Animating `width`/`height` on chips — `boxShadow` only
- ❌ Using `moment` localizer — use `dateFnsLocalizer`


## ⏱️ Task CAL‑010: Week & Day Views (Enhanced)
**Priority:** 🔴 High | **Est. Effort:** 3.5 hours | **Depends On:** CAL‑001, CAL‑012

### Related Files
`src/components/calendar/WeekView.tsx` · `src/components/calendar/DayView.tsx` · `src/components/calendar/CurrentTimeIndicator.tsx`

### Subtasks

- [ ] **CAL‑003A** Install DnD addon:
  ```ts
  import withDragAndDrop from 'react‑big‑calendar/lib/addons/dragAndDrop'
  import 'react‑big‑calendar/lib/addons/dragAndDrop/styles.css'
  const DnDCalendar = withDragAndDrop(Calendar)
  ```

- [ ] **CAL‑003B** Create `WeekView` and `DayView` components sharing `DnDCalendar` with resource support:
  ```tsx
  <DnDCalendar
    view={viewMode}
    events={events}
    resources={resources}
    resourceIdAccessor={(e) => e.calendarId}
    date={selectedDate}
    scrollToTime={scrollToTime}
    onEventDrop={handleEventDrop}
    onEventResize={handleEventResize}
    onSelectSlot={handleSelectSlot}
  />
  ```

- [ ] **CAL‑003C** `handleEventDrop({ event, start, end, resourceId })`:
  - If `resourceId` changed: update `event.calendarId`
  - If event is recurring: intercept and open `RecurringEditModal` (CAL‑009) before mutating
  - Call `setScrollToTime(scrollToTime)` to preserve position
  - Call `useUpdateEvent().mutate({ id, start, end, calendarId })`

- [ ] **CAL‑003D** `handleEventResize({ event, start, end })` — same pattern as drop

- [ ] **CAL‑003E** Configure time grid bounds (MIN_TIME, MAX_TIME, SCROLL_DEFAULT)

- [ ] **CAL‑003F** Build `CurrentTimeIndicator` with double gutter support for secondary timezone (CAL‑010)

- [ ] **CAL‑003G** Persist scroll position: on scroll event, `debounce(setScrollToTime, 300)`

- [ ] **CAL‑003H** 12/24‑hour toggle

- [ ] **CAL‑003I** Working hours highlight: grey overlay on rows outside `workingHours`

- [ ] **CAL‑003J** Resource grouping toggle: `resourceGroupingLayout={preferDayFirst}`

### Tests
- [ ] Week view renders 7 columns; Resource Week renders columns per calendar
- [ ] Day view renders single‑column time grid
- [ ] Drag‑to‑move between calendars updates `calendarId`
- [ ] Current time indicator renders at correct offset
- [ ] Drag‑to‑create calls `openComposer`
- [ ] Recurring event drag opens RecurringEditModal
- [ ] Scroll position is restored after view‑change round‑trip
- [ ] Resource grouping layout toggle switches grouping order

### Definition of Done
- Week/Day views render with DnD, time grid, current time indicator, multi‑calendar support
- Scroll position preserved across navigation
- Drag‑to‑move between calendars functional
- Working hours highlight applied

### Anti‑Patterns
- ❌ Using `Calendar` without `withDragAndDrop` for drag support
- ❌ Not handling `resourceId` param in drag handlers
- ❌ Missing `dragAndDrop/styles.css` import


## 🔍 Task CAL‑011: Event Detail Drawer (Enhanced)
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** CAL‑001, CAL‑000, CAL‑014

### Related Files
`src/components/calendar/EventDetailDrawer.tsx`

### Subtasks

- [ ] **CAL‑006A** Build `EventDetailDrawer` using shadcn `Sheet`:
  - Renders event header with calendar chip (color + name)
  - Date/time range formatted in user's `calendarSlice.timezone`
  - Location with "Open in Maps" link
  - Conferencing link with "Join" button
  - Attendees list with `RSVPButtons` (CAL‑014) and status indicators
  - Exception marker (⤴) and "Restore to series" button for modified occurrences

- [ ] **CAL‑006B** Action buttons row:
  - **Edit** (delegates to CAL‑009 if recurring)
  - **Delete** (delegates to CAL‑009 if recurring)
  - **Duplicate** (opens composer pre‑filled, omits ID, increments title)
  - **Copy Link** (copies shareable event URL to clipboard)
  - **Add to Calendar** (downloads `.ics` for this single event)

- [ ] **CAL‑006C** Fetch event: `useQuery(eventQueryOptions(selectedEventId))`
  - Show skeleton while loading
  - Show error state with "Retry" on query failure

- [ ] **CAL‑006D** Focus management: store `document.activeElement` on open; restore on close

- [ ] **CAL‑006E** Wrap drawer content in `AnimatePresence` for smooth content transition

### Tests
- [ ] Drawer opens when event chip, agenda row, or resource column event is clicked
- [ ] Calendar chip displays correct color and name
- [ ] Attendee list shows RSVP buttons for current user
- [ ] "Restore to series" appears for exception occurrences
- [ ] Duplicate opens composer with copied data (no ID)
- [ ] "Add to Calendar" downloads single‑event `.ics` file
- [ ] Focus returns to triggering element after close

### Definition of Done
- Drawer shows all event fields with timezone‑correct times
- RSVP integration with attendee status
- Duplicate and single‑event export actions
- Focus management and focus trap working


## 📋 Task CAL‑012: Agenda View (Enhanced)
**Priority:** 🟠 Medium | **Est. Effort:** 2.5 hours | **Depends On:** CAL‑001, CAL‑019

### Related Files
`src/components/calendar/AgendaView.tsx` · `src/components/calendar/AgendaEventRow.tsx`

### Subtasks

- [ ] **CAL‑012A** Build `AgendaView` with checkboxes for bulk selection (CAL‑019):
  - Checkbox on each row (visible on hover/focus)
  - Header checkbox for "Select all visible"

- [ ] **CAL‑012B** Implement virtualization with `react‑window` `VariableSizeList` (>50 events)

- [ ] **CAL‑012C** Build `AgendaEventRow` showing: checkbox, time range, calendar chip, title, location, exception marker

- [ ] **CAL‑012D** "Load More" extends range by +30 days

- [ ] **CAL‑012E** Empty state: "No upcoming events" + "Create event" CTA

- [ ] **CAL‑012F** Mini‑calendar integration: clicking date scrolls agenda to that group

### Tests
- [ ] Checkboxes visible on row hover; bulk selection works
- [ ] Events grouped by date, sorted chronologically
- [ ] Virtualization activates when >50 events
- [ ] "Load More" appends without resetting scroll
- [ ] Exception marker (⤴) displays for modified occurrences
- [ ] Empty state renders when no events exist

### Definition of Done
- Agenda with bulk selection checkboxes
- Virtualized for >50 events
- Calendar chip displays calendar association
- Mini‑calendar scroll sync works


## 🔁 Task CAL‑013: Recurring Event Edit Flows
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** CAL‑005, CAL‑006, CAL‑000

### Related Files
`src/components/calendar/RecurringEditModal.tsx` · `@/shared/recurrence/RecurrenceEngine.ts` · `@/shared/recurrence/helpers.ts`

### Subtasks

- [ ] **CAL‑013A** Recurring data model includes `exdates: Date[]` and exception markers

- [ ] **CAL‑013B** Build `RecurringEditModal` with three radio options

- [ ] **CAL‑013C** Use `RecurrenceEngine` from `@/shared/recurrence` for all RRULE operations:
  - Import `rruleToHuman`, `buildEditOperations`, `restoreExceptionToSeries` from `@/shared/recurrence/helpers`
  - Use `RecurrenceEngine.isValid()` for RRULE validation
  - Use `RecurrenceEngine.getOccurrences()` for expanding recurring events in date ranges
  - Helper functions provide three-mode edit operations (this / thisAndFollowing / all)

- [ ] **CAL‑013D** Implement `useUpdateRecurringEvent()` mutation supporting three modes

- [ ] **CAL‑013E** Implement `useDeleteRecurringEvent()` mutation with three modes

- [ ] **CAL‑013F** Handle orphaned overrides when master is deleted

- [ ] **CAL‑013G** "Restore to series" action for exceptions (removes EXDATE)

### Tests
- [ ] Modal renders with correct title
- [ ] Exception marker appears on modified occurrences
- [ ] "Restore to series" removes EXDATE and merges occurrence back to master
- [ ] Delete 'all' removes master and all linked occurrences
- [ ] Rollback restores full series state on API failure

### Definition of Done
- Three‑mode recurring edit modal for edit, delete, and restore
- Exception markers visible in all views
- Optimistic updates for all modes with full rollback

### Anti‑Patterns
- ❌ Directly mutating occurrence without writing EXDATE
- ❌ Deleting master without removing cached occurrences


## 🌍 Task CAL‑014: Timezone Display Preferences & Working Hours
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** CAL‑001

### Related Files
`src/components/calendar/TimezoneSelector.tsx` · `src/components/calendar/WorkingHoursConfig.tsx`

### Subtasks

- [ ] **CAL‑014A** Install `@date‑fns/tz`

- [ ] **CAL‑014B** Build `TimezoneSelector` with IANA timezone search

- [ ] **CAL‑014C** Timezone indicator in top bar

- [ ] **CAL‑014D** Secondary timezone in week/day view (second gutter)

- [ ] **CAL‑014E** Build `WorkingHoursConfig` component with per‑day schedule support (optional)

- [ ] **CAL‑014F** Create `src/utils/dateDisplay.ts` utilities

### Tests
- [ ] Selecting timezone updates all displayed event times
- [ ] Secondary gutter renders when `secondaryTimezone` set
- [ ] Working hours highlight applied to week/day view
- [ ] Default timezone auto‑detected

### Definition of Done
- User‑selectable timezone applied to all displayed times
- Optional secondary timezone gutter
- Working hours highlight in time grid


## ✅ Module Completion Checklist

## ✅ Module Completion Checklist (Updated)

**Foundation:**
- [ ] Mock factories: all‑day, multi‑day, recurring series, attendees, calendars
- [ ] All mutations follow `cancelQueries → snapshot → optimistic → rollback → onSettled invalidate`
- [ ] `calendarSlice` includes multi‑calendar state and notification preferences
- [ ] Route loader prefetches; Suspense skeleton per view; ErrorBoundary per view

**Views:**
- [ ] Month: memoized events, multi‑calendar colors, right‑click menu, exception markers, week numbers toggle
- [ ] Week/Day: `withDragAndDrop`, current time indicator, working hours, scroll preservation, inter‑calendar drag‑move
- [ ] Agenda: virtualized with checkboxes, bulk selection, Load More
- [ ] Resource Week: multi‑calendar columns, resource grouping toggle
- [ ] View switcher includes Resource Week

**Sidebar & Discovery:**
- [ ] Mini‑calendar with event dots, independent navigation
- [ ] Calendar list with visibility toggles, add/delete calendars
- [ ] Event search panel: debounced, multi‑field, keyboard navigable
- [ ] Filter bar: color + project + calendar filters

**Interactions:**
- [ ] Drag‑to‑create (Week/Day), drag‑to‑resize, drag‑to‑move (including between calendars)
- [ ] Keyboard alternatives for all drag ops (WCAG 2.5.7)
- [ ] `aria‑live` region announces keyboard mutations
- [ ] Bulk actions with shift‑click range selection and floating action bar

**Composer & Drawer:**
- [ ] Event composer: calendar selector, advanced recurrence, attendees, conferencing link
- [ ] Conflict detection warning (non‑blocking)
- [ ] Recurring edit modal: this / this & following / all (edit + delete + restore)
- [ ] Optimistic create/update/delete with full rollback
- [ ] Event detail drawer: RSVP buttons, duplicate action, single‑event export, restore exception

**Attendees & Notifications:**
- [ ] Attendee input with role (optional/required) and status
- [ ] RSVP buttons in drawer update attendee status optimistically
- [ ] Reminder service with browser notifications (permission on gesture)
- [ ] Snoozeable reminder toasts

**Multi‑Calendar & Sharing:**
- [ ] Calendar list with visibility toggles
- [ ] `AddCalendarModal` (Create / Connect / Subscribe)
- [ ] Shareable subscription links (`webcal://` and `https://`)
- [ ] ICS feed endpoint with token validation

**Timezone & Working Hours:**
- [ ] User timezone selector (IANA); auto‑detected default
- [ ] Optional secondary timezone gutter
- [ ] Working hours config; grey overlay in week/day view
- [ ] Centralized `dateDisplay.ts` utilities used everywhere

**Import/Export:**
- [ ] `.ics` export strictly RFC 5545 compliant (CRLF, folding, escaping)
- [ ] `.ics` import with preview, calendar selection, and partial‑failure reporting

**Accessibility:**
- [ ] ARIA grid pattern (Month view)
- [ ] WCAG 2.5.7: all drag ops have keyboard equivalents
- [ ] WCAG 2.5.8: 44×44px touch targets on mobile
- [ ] Focus restoration on all modal/drawer close
- [ ] `useReducedMotion` guard on all Alive‑tier animations
- [ ] Axe: zero violations across all views
- [ ] Keyboard shortcuts panel (`?` key)

**Testing:**
- [ ] All CAL tasks have passing tests per their subtask test sections
- [ ] `pnpm test` passes for calendar domain
- [ ] Axe playwright audit: zero violations
- [ ] Optimistic rollback verified for all mutation types
- [ ] Bulk action optimistic updates verified