# 21‑Calendar — Personal AI Command Center Frontend (Enhanced v4)

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.

---

<!-- SECTION: Frontend Context -->

## 📋 Frontend Context (Module‑Wide Assumptions)

> All tasks in this module implicitly rely on the shared infrastructure defined in `00‑Foundations.md`.
> **Do not repeat these in every task** – they are global.

- **Framework**: React 18 + TypeScript (strict mode)
- **State**: Zustand (UI) + TanStack Query (server state)
- **Styling**: Tailwind CSS v4 (CSS‑first `@theme`), shadcn/ui components
- **Animation**: Motion v12 (`framer-motion`) with `useReducedMotion()` guard
- **Testing**: Vitest + RTL + MSW (unit / component / integration)
- **Routing**: React Router v7 (data mode, lazy routes)
- **Virtualization**: `@tanstack/react-virtual`
- **Drag & Drop**: dnd‑kit with shared `useDndSensors` hook
- **Forms**: react‑hook‑form + zod
- **Offline**: Dexie (centralised `CommandCenterDB`)
- **Accessibility**: WCAG 2.2 AA, keyboard navigation, focus restoration

**Calendar library: `react-big-calendar ^1.19.4`.** This library meets all feature requirements: Month/Week/Day/Agenda/Resource views, drag‑and‑drop via `withDragAndDrop`, date‑fns localization, and time‑zone handling. No alternative library is under consideration for the MVP.

<!-- ENDSECTION: Frontend Context -->

<!-- SECTION: Research Findings -->

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

<!-- ENDSECTION: Research Findings -->

<!-- SECTION: Cross-Cutting Foundations -->

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

<!-- ENDSECTION: Cross-Cutting Foundations -->

<!-- SECTION: Motion Tier Assignment -->

### 🎯 Motion Tier Assignment

| Component | Tier | Technique |
|-----------|------|--------------------|
| Month view event chips | **Quiet** | `boxShadow` fade on hover (≤150ms) |
| Current time indicator | **Alive** | Motion `keyframes` pulse; `useReducedMotion` guard |
| Event composer modal | **Alive** | `scale: 0.95→1, opacity: 0→1`; `useReducedMotion` guard |
| Event detail drawer | **Quiet** | Spring slide via `AnimatePresence` |
| Agenda list items | **Static** | No animation |
| View transition | **Alive** | `AnimatePresence` cross‑fade with `layoutId` for selected date |
| Mini‑calendar sidebar | **Quiet** | Slide‑in on open (`x: ‑16→0`) |
| Reminder toast | **Alive** | Slide‑in from bottom; `useReducedMotion` guard |

<!-- ENDSECTION: Motion Tier Assignment -->

<!-- SECTION: Task CAL-000 -->

## 🗂️ Task CAL‑000: Mock Data Layer
**Priority:** 🔴 High
**Est. Effort:** 1.5 hours
**Depends On:** FND‑004 (Testing Infra), FND‑006 (TanStack Query)

<!-- ENDSECTION: Task CAL-000 -->

<!-- SECTION: Task CAL-001 -->

## 🔧 Task CAL‑001: Calendar Page Layout & State Management
**Priority:** 🔴 High
**Est. Effort:** 2.5 hours
**Depends On:** FND‑007 (Router), CAL‑000

<!-- ENDSECTION: Task CAL-001 -->

<!-- SECTION: Task CAL-002 -->

## 🗓️ Task CAL‑002: Multi‑Calendar Support & Calendar List Sidebar
**Priority:** 🔴 High
**Est. Effort:** 2.5 hours
**Depends On:** CAL‑001, CAL‑000

<!-- ENDSECTION: Task CAL-002 -->

<!-- SECTION: Task CAL-003 -->

## 🔗 Task CAL‑003: External Calendar Integration & Webcal Subscriptions
**Priority:** 🟠 Medium
**Est. Effort:** 2 hours
**Depends On:** CAL‑002, CAL‑006

<!-- ENDSECTION: Task CAL-003 -->

<!-- SECTION: Task CAL-004 -->

## 👥 Task CAL‑004: Attendee Invitations & RSVP Management
**Priority:** 🟠 Medium
**Est. Effort:** 2.5 hours
**Depends On:** CAL‑008, CAL‑011

<!-- ENDSECTION: Task CAL-004 -->

<!-- SECTION: Task CAL-005 -->

## 🔔 Task CAL‑005: Reminder Service & Browser Notifications
**Priority:** 🟠 Medium
**Est. Effort:** 2 hours
**Depends On:** CAL‑001, CAL‑000

<!-- ENDSECTION: Task CAL-005 -->

<!-- SECTION: Task CAL-006 -->

## 📤 Task CAL‑006: iCal Import & Export (Enhanced)
**Priority:** 🟢 Low
**Est. Effort:** 3 hours
**Depends On:** CAL‑000, CAL‑013, CAL‑002

<!-- ENDSECTION: Task CAL-006 -->

<!-- SECTION: Task CAL-007 -->

## 🗂️ Task CAL‑007: Bulk Event Actions
**Priority:** 🟠 Medium
**Est. Effort:** 1.5 hours
**Depends On:** CAL‑004 (Agenda View), CAL‑000

<!-- ENDSECTION: Task CAL-007 -->

<!-- SECTION: Task CAL-008 -->

## ✏️ Task CAL‑008: Event Composer Modal (Enhanced)
**Priority:** 🔴 High
**Est. Effort:** 3.5 hours
**Depends On:** CAL‑001, CAL‑000, CAL‑012

<!-- ENDSECTION: Task CAL-008 -->

<!-- SECTION: Task CAL-009 -->

## 📅 Task CAL‑009: Month View (Enhanced)
**Priority:** 🔴 High
**Est. Effort:** 3 hours
**Depends On:** CAL‑001, CAL‑012

<!-- ENDSECTION: Task CAL-009 -->

<!-- SECTION: Task CAL-010 -->

## ⏱️ Task CAL‑010: Week & Day Views (Enhanced)
**Priority:** 🔴 High
**Est. Effort:** 3.5 hours
**Depends On:** CAL‑001, CAL‑012

<!-- ENDSECTION: Task CAL-010 -->

<!-- SECTION: Task CAL-011 -->

## 🔍 Task CAL‑011: Event Detail Drawer (Enhanced)
**Priority:** 🔴 High
**Est. Effort:** 2 hours
**Depends On:** CAL‑001, CAL‑000, CAL‑014

<!-- ENDSECTION: Task CAL-011 -->

<!-- SECTION: Task CAL-012 -->

## 🗂️ Task CAL‑012: Agenda View (Enhanced)
**Priority:** 🟠 Medium
**Est. Effort:** 2.5 hours
**Depends On:** CAL‑001, CAL‑019

<!-- ENDSECTION: Task CAL-012 -->

<!-- SECTION: Task CAL-013 -->

## 🔁 Task CAL‑013: Recurring Event Edit Flows
**Priority:** 🔴 High
**Est. Effort:** 2 hours
**Depends On:** CAL‑005, CAL‑006, CAL‑000

<!-- ENDSECTION: Task CAL-013 -->

<!-- SECTION: Task CAL-014 -->

## 🌍 Task CAL‑014: Timezone Display Preferences & Working Hours
**Priority:** 🟠 Medium
**Est. Effort:** 2 hours
**Depends On:** CAL‑001

<!-- ENDSECTION: Task CAL-014 -->

<!-- SECTION: Module Completion Checklist -->

## Module Completion Checklist

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

<!-- ENDSECTION: Module Completion Checklist -->