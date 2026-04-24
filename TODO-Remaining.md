# TODO-Remaining.md — Phases 3-6: Accessibility, Infrastructure, Performance, and Polish

> **Split from**: TODO.md (lines 726-2131)
> **Purpose**: Remaining phases covering accessibility compliance, missing infrastructure, performance optimization, and quality polish.
> **Status**: Most tasks pending

---

## 🟠 Phase 3: Accessibility Compliance

---

### TASK-007: Add WCAG 2.5.7 Single-Pointer Alternatives to All Drag Interactions

**Status**: 🟡 Pending  
**Priority**: 🔴 Critical  
**Parent Task ID**: TASK-007

#### Subtasks

- [ ] **TASK-007-01**: In `22-Lists.md` (LIST‑004B, Board View), add a "Move to…" button alternative on each card that duplicates the drag-between-columns functionality using the `PROJ‑004F` pattern.  

  [CHECK PATH: `22-Lists.md`; CONFIRM ID: LIST‑004B exists and describes the Board View drag interaction] [VERIFY: `PROJ‑004F` pattern is still the canonical reference; if it has been updated, use the latest pattern]  
  **Target File**: `22-Lists.md`

- [ ] **TASK-007-02**: In `22-Lists.md` (LIST‑005A, List Item Reordering), add a "Reorder" button or keyboard shortcut (e.g., `Alt+↑` / `Alt+↓`) for moving items up and down.  

  [CONFIRM ID: LIST‑005A describes reordering; verify the shortcut does not conflict with existing hotkeys]  
  **Target File**: `22-Lists.md`

- [ ] **TASK-007-03**: In `21-Calendar.md` (CAL‑010, Week/Day Views), add a "Reschedule" dialog or button that opens on `Enter` / click, enabling date/time adjustment without dragging events on the time grid.  

  [CHECK PATH: `21-Calendar.md`; CONFIRM ID: CAL‑010 exists and covers drag interactions]  
  **Target File**: `21-Calendar.md`

- [ ] **TASK-007-04**: In `50-Budget.md` (BUDG‑006D1, Planned Transaction Rescheduling), add a "Change Date" button/popup accessible via keyboard as an alternative to dragging planned transactions on the financial calendar.  

  [CHECK PATH: `50-Budget.md`; CONFIRM ID: BUDG‑006D1]  
  **Target File**: `50-Budget.md`

- [ ] **TASK-007-05**: Add a WCAG 2.5.7 compliance checklist item to the module template (in `00-CONTRIBUTING.md` or `99-Polish-Validation.md`).  

  [CHECK PATH: `00-CONTRIBUTING.md` exists; if not, default to `99-Polish-Validation.md`][VERIFY: the template format is consistent with other checklist items]  
  **Target File**: `99-Polish-Validation.md`

#### Priority / Urgency

🔴 Critical. WCAG 2.5.7 (Dragging Movements) is a Level AA requirement. Without alternatives, users who cannot use a mouse or pointer cannot rearrange items, move calendar events, or manage Kanban boards. Some modules already have the pattern (`PROJ‑004F`); others must catch up.

#### Research / Investigation

The W3C Understanding Document for SC 2.5.7 states: "All functionality that uses a dragging movement for operation can be achieved by a single pointer without dragging." The `PROJ‑004F` implementation ("Move to…" submenu in the `⋯` menu) is a valid and proven pattern. The Calendar `react-big-calendar` library provides `onSelectEvent` and `onSelectSlot` callbacks that can be used to open a reschedule dialog. The Lists Board View uses dnd‑kit; the `PROJ‑004F` pattern can be reused directly.  
[VERIFY: `react-big-calendar` is still the chosen library; if changed, adapt the alternative accordingly]

#### Related Files

- `22-Lists.md` (LIST‑004B, LIST‑005A)
- `21-Calendar.md` (CAL‑010)
- `50-Budget.md` (BUDG‑006D1)
- `20-Projects.md` (PROJ‑004F — reference pattern)
- `99-Polish-Validation.md` (compliance checklist)

#### Definition of Done

- Every drag‑based interaction in every module has a documented button‑ or keyboard‑based alternative.
- The alternative uses the same mutation hooks as the drag operation.
- The module template (`00-CONTRIBUTING.md` or `99-Polish-Validation.md`) includes a WCAG 2.5.7 conformance item.

#### Acceptance Criteria

- Lists Board View cards have a "Move to…" option in their action menu.
- Calendar events have a "Reschedule" option on click or keyboard activation.
- Budget planned transactions have a "Change Date" action.
- All alternatives call the same optimistic mutations as the drag handlers.

#### Out of Scope

- Adding alternatives for drag operations that are not yet specified.
- Implementing the actual UI components (only spec updates).

#### Dependencies

- TASK‑001 (correct task references needed).
- `PROJ‑004F` must be finalized as the reference pattern.

#### Estimated Effort

2 hours

#### Testing Requirements

- Specification review: Verify each drag interaction has a corresponding alternative subtask.
- Accessibility audit: After implementation, run axe‑core to confirm no drag‑only interactions remain.

#### Validation Steps

1. Open each module spec and search for "drag", "dnd", "DragOverlay".
2. For each drag interaction found, verify there is a corresponding button/click alternative subtask.
3. Verify the alternative uses the same mutation as the drag handler.

#### Strict Rules

- The alternative must trigger the same mutation with the same parameters as the drag operation.
- The alternative must not be hidden behind a gesture — it must be reachable via keyboard.
- The alternative must be documented in the same task as the drag implementation.

#### Existing Code Patterns

Reference pattern from `PROJ‑004F`:

```
"Move to…" button on each `KanbanCard` (in `⋯` menu): "Move to → [column name]" submenu.
Rendered as `<button>` elements. Calls same mutation as drag.
```

[VERIFY: the exact implementation pattern in PROJ‑004F matches this description; update if needed]

#### Advanced Code Patterns

For Calendar, the alternative could be:

```tsx
// On event click/keypress, open a dialog:
const handleEventClick = (event) => {
  openRescheduleDialog({
    eventId: event.id,
    currentStart: event.start,
    currentEnd: event.end,
    onConfirm: (newStart, newEnd) => updateEventMutation.mutate({ id: event.id, start: newStart, end: newEnd }),
  });
};
```

[IMPLEMENT: ensure the `updateEventMutation` name matches the actual mutation defined in the Calendar spec]

#### Anti-Patterns

- ❌ Providing only a drag interaction with no button alternative.
- ❌ Using a different, less capable mutation for the alternative than the drag action.
- ❌ Making the alternative available only on hover (must be keyboard reachable).

---

### TASK-008: Add Screen Reader Announcements for Drag-and-Drop Reordering

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-008

#### Subtasks

- [ ] **TASK-008-01**: Update the shared `useDndSensors` hook specification in `01-Foundations.md` (C‑14 or new C‑17) to require an `onDragEnd` callback that updates a live region announcing the new position of the moved item.  

  [VERIFY: the current C‑ number for `useDndSensors`; if C‑14 is taken by something else, use the correct one]  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-008-02**: Define a shared `<LiveRegion>` component specification that renders a visually hidden `aria-live="polite"` container for drag announcements.  

  [VERIFY: the location in `01-Foundations.md` for this new component; ensure it is under the same cross-cutting section]  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-008-03**: Update `20-Projects.md` (PROJ‑004C, Kanban drag), `22-Lists.md` (LIST‑005A, List drag), and `50-Budget.md` (BUDG‑006, Calendar drag) to wire the live region announcement into their drag handlers.  

  [CHECK PATH: each of these files; CONFIRM ID: PROJ‑004C, LIST‑005A, BUDG‑006 still refer to the relevant drag tasks]  
  **Target Files**: `20-Projects.md`, `22-Lists.md`, `50-Budget.md`

#### Priority / Urgency

🟠 High. Screen reader users need to know where an item was moved after a drag‑and‑drop reorder. Without announcements, they cannot confirm the action succeeded or know the new position. This is covered by WCAG 4.1.3 (Status Messages).

#### Research / Investigation

`@dnd-kit`'s `onDragEnd` callback provides `active` (the dragged item) and `over` (the drop target). The `KeyboardSensor` already handles keyboard‑driven reordering, but no accessible feedback is built in. A common pattern is to update an `aria-live` region with text like "Moved 'Project Alpha' to column In Progress, position 3." This should be a shared utility used by all dnd‑kit consumers.  
[VERIFY: the version of `@dnd-kit` in use still provides these callbacks; confirm the API hasn't changed]

#### Related Files

- `01-Foundations.md` (C‑14 or new C‑17)
- `src/shared/dnd/useDndSensors.ts` (target implementation)
- `src/components/shared/LiveRegion.tsx` (target implementation)
- `20-Projects.md` (PROJ‑004C)
- `22-Lists.md` (LIST‑005A)
- `50-Budget.md` (BUDG‑006)

#### Definition of Done

- `useDndSensors` specification requires an announcement callback parameter.
- A shared `<LiveRegion>` component is specified.
- All drag operations in all modules produce an accessible announcement upon completion.

#### Acceptance Criteria

- After a Kanban card is moved via keyboard, the screen reader announces "Moved 'Card Name' to 'Column Name'."
- After a list item is reordered, the screen reader announces "Moved 'Item Name' to position 4."

#### Out of Scope

- Internationalization of announcement strings (use hardcoded English for MVP).
- Announcements during the drag operation (only on completion).

#### Dependencies

- TASK‑007 (WCAG 2.5.7 alternatives must exist first).

#### Estimated Effort

1.5 hours

#### Testing Requirements

- Accessibility testing: Verify live region updates with screen reader simulation in tests.
- Integration test: Confirm the live region is updated after a keyboard‑driven drag operation.

#### Validation Steps

1. Review the updated `useDndSensors` spec for the announcement callback parameter.
2. Verify each drag‑consuming module references the `LiveRegion` component.
3. Check that the announcement text includes the item name and new position.

#### Strict Rules

- The live region must be visually hidden but accessible to screen readers.
- Announcements must not fire on initial render, only on drag completion.
- The announcement text must be concise (one sentence).

#### Existing Code Patterns

The `useDndSensors` hook already exists in the spec. Extend it:

```typescript
export function useDndSensors(options?: {
  onAnnouncement?: (message: string) => void;
}) {
  // ... existing sensor config
  // On dragEnd, call options.onAnnouncement?.(message)
}
```

[VERIFY: the current spec for `useDndSensors` supports this kind of extension; if the signature differs, adapt]

#### Advanced Code Patterns

Pattern for `<LiveRegion>`:

```tsx
export function LiveRegion() {
  const [message, setMessage] = useState('');
  // Subscribe to announcements from dndSensors
  return (
    <div className="sr-only" aria-live="polite" aria-atomic="true">
      {message}
    </div>
  );
}
```

[IMPLEMENT: the subscription mechanism must be integrated with the actual announcement flow; decide if it's via context or store]

#### Anti-Patterns

- ❌ Firing announcements during the drag instead of on completion.
- ❌ Announcing technical IDs instead of human-readable names.
- ❌ Creating a separate live region per component instead of sharing one.

---

## 🟡 Phase 4: Missing Infrastructure

---

### TASK-009: Create Authentication Module Specification

**Status**: 🟡 Pending  
**Priority**: 🔴 Critical  
**Parent Task ID**: TASK-009

#### Subtasks

- [ ] **TASK-009-01**: Create `05-Auth.md` with the following tasks:

  - AUTH‑000: Define `User` type, `AuthSlice` (token, userId, isAuthenticated).
  - AUTH‑001: Implement `AuthProvider` that hydrates auth state from `secureVault` on boot, provides `login(email, pw)` and `logout()`.
  - AUTH‑002: Create global `apiClient` (`src/lib/apiClient.ts`) that adds `Authorization: Bearer <token>` header, handles 401/403, and triggers global logout.
  - AUTH‑003: Protect all routes with a `<RequireAuth>` wrapper; redirect unauthenticated users to `/login`.
  - AUTH‑004: Build login page with RHF + Zod validation, mock authentication.
  [CHECK: ensure `05-Auth.md` filename does not conflict with existing file] [VERIFY: the `secureVault` API mentioned in other specs is documented; if not, add its specification to AUTH‑001]  
  **Target File**: `05-Auth.md`

- [ ] **TASK-009-02**: Update `00-Plan.md` Phase 0 to include `AUTH‑000` through `AUTH‑004` as prerequisite tasks.  

  [CHECK PATH: `00-Plan.md` has a Phase 0 section; if not, insert one]  
  **Target File**: `00-Plan.md`

- [ ] **TASK-009-03**: Update all module specifications that reference `useUser()` or `currentUserId` to reference the auth slice.  

  [VERIFY: the exact references; search across all spec files for `useUser()` or `currentUserId` and list affected files]  
  **Target Files**: All module specs with user-dependent features

#### Priority / Urgency

🔴 Critical. Without authentication, there is no user session, no protected API calls, no personalized data. Every module that references a user implicitly assumes an authentication system exists. This must be specified before any module can be implemented.

#### Research / Investigation

The existing specs mention `secureVault` (`30-Email.md`), `userId` in Zustand slices (various), and `currentUser` in Calendar attendee specs (CAL‑004F). However, no specification defines how a user logs in, how tokens are stored, or how API calls are authenticated. For MVP, mock authentication with a fake JWT stored in `secureVault` is sufficient. The React Router v7 data mode supports `loader` functions that can redirect unauthenticated users.  
[VERIFY: React Router v7 is still the chosen version; its loader API may differ from earlier versions]

#### Related Files

- `05-Auth.md` (new)
- `00-Plan.md` (update Phase 0)
- `01-Foundations.md` (add cross-cutting rule for API client)
- `30-Email.md` (secureVault reference)
- `21-Calendar.md` (CAL‑004F)
- `src/stores/slices/authSlice.ts` (target implementation)
- `src/lib/apiClient.ts` (target implementation)

#### Definition of Done

- `05-Auth.md` contains complete task specifications for the authentication module.
- The Plan includes auth tasks in Phase 0.
- All module specs that reference user data include a "Depends On: AUTH‑001" or similar.

#### Acceptance Criteria

- `05-Auth.md` follows the same template as other module specs (Frontend Context, Cross‑Cutting Foundations, Motion Tier, Tasks with subtasks and tests).
- The API client specification handles 401, 403, and network errors uniformly.
- Login page specification includes validation, error states, and loading state.

#### Out of Scope

- Real OAuth integration (mock only for MVP).
- Multi‑factor authentication.
- Password reset flow (can be added later).

#### Dependencies

None (this is a new foundational specification).

#### Estimated Effort

2 hours (specification only)

#### Testing Requirements

- Specification review: Verify completeness and consistency with other modules.
- Implementation tests will cover login flow, token refresh, and route protection.

#### Validation Steps

1. Review `05-Auth.md` against the module specification template.
2. Verify the Plan includes auth tasks.
3. Check several module specs for updated `Depends On` fields.

#### Strict Rules

- Auth tokens must never be stored in localStorage. Use `secureVault` (IndexedDB with SubtleCrypto).
- The API client must be the only module that reads the token.
- All routes except `/login` must be protected.

#### Existing Code Patterns

N/A — New specification.

#### Advanced Code Patterns

The API client should follow this pattern:

```typescript
class ApiClient {
  private getToken: () => Promise<string | null>;

  async fetch<T>(url: string, options?: RequestInit): Promise<T> {
    const token = await this.getToken();
    const headers = new Headers(options?.headers);
    if (token) headers.set('Authorization', `Bearer ${token}`);

    const response = await fetch(url, { ...options, headers });
    if (response.status === 401) {
      useAuthStore.getState().logout();
      throw new ApiError('Unauthorized', 401);
    }
    if (!response.ok) {
      throw new ApiError(await response.text(), response.status);
    }
    return response.json();
  }
}

export const apiClient = new ApiClient();
```

[IMPLEMENT: the `useAuthStore` import path may differ; verify the store location]

#### Anti-Patterns

- ❌ Storing auth tokens in `localStorage`.
- ❌ Each module defining its own `fetch` wrapper.
- ❌ Not handling 401 globally (each component handling it separately).

---

### TASK-010: Create Global Notification Center Specification

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-010

#### Subtasks

- [ ] **TASK-010-01**: Create `08-Notifications.md` with tasks for:

  - NOTIF‑000: Define `Notification` type (id, type, title, body, link, priority, readAt, createdAt).
  - NOTIF‑001: Create `notificationSlice` with array of notifications, `unreadCount` selector, add/remove/markRead actions.
  - NOTIF‑002: Build `<NotificationBell>` component for the StatusBar showing unread count and dropdown list.
  - NOTIF‑003: Implement a pub/sub event bus (`createNotification(message)`) that any module can call to push a notification.
  - NOTIF‑004: Wire key event sources: agent decisions, budget alerts, email delivery, project assignments.
  [CHECK: filename `08-Notifications.md` is free; verify the event sources match current module specs]  
  **Target File**: `08-Notifications.md`

- [ ] **TASK-010-02**: Update `01-Foundations.md` StatusBar task (FND‑010) to reference the NotificationBell component.  

  [CONFIRM ID: FND‑010 is indeed the StatusBar task; if renumbered, adjust]  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-010-03**: Update `50-Budget.md` (BUDG‑014, spending insights), `20-Projects.md` (PROJ‑020, triage integration), `30-Email.md` (EMAIL‑009, follow‑up reminders) to publish notifications through the shared event bus.  

  [CONFIRM ID: BUDG‑014, PROJ‑020, EMAIL‑009 exist and cover those features; verify they still contain notification-related tasks]  
  **Target Files**: `50-Budget.md`, `20-Projects.md`, `30-Email.md`

#### Priority / Urgency

🟠 High. Multiple modules generate user‑facing notifications, but each currently describes standalone toast implementations. A centralized notification center provides a unified UI (bell icon with unread count), prevents notification fatigue, and allows users to manage notification preferences in one place.

#### Research / Investigation

The StatusBar already has a slot for indicators (`FND‑010`). The `settingsSlice` already manages notification preferences. What's missing is a shared notification queue and UI component. The event bus pattern is lightweight: a React Context or a simple Zustand slice that any module can import and call `addNotification(...)`. The `<NotificationBell>` renders in the StatusBar and shows a dropdown of recent notifications.  
[VERIFY: the `settingsSlice` location and API match the description; if it has changed, adjust]

#### Related Files

- `08-Notifications.md` (new)
- `01-Foundations.md` (FND‑010 — StatusBar)
- `50-Budget.md` (BUDG‑014)
- `20-Projects.md` (PROJ‑020)
- `30-Email.md` (EMAIL‑009)
- `src/stores/slices/notificationSlice.ts` (target implementation)

#### Definition of Done

- `08-Notifications.md` contains complete task specifications.
- The StatusBar specification includes the NotificationBell.
- Key event sources are specified to publish through the shared bus.

#### Acceptance Criteria

- Notification bell renders in the StatusBar.
- Clicking the bell opens a dropdown with recent notifications, sorted by recency.
- Unread count badge updates in real time.
- Any module can call `addNotification(...)` to push a notification.

#### Out of Scope

- Push notifications to the OS (browser Notification API is separate, handled in Calendar CAL‑005).
- Email delivery of notifications.
- Notification grouping or summarization.

#### Dependencies

- TASK‑009 (auth must exist for user‑specific notifications).
- `FND‑010` (StatusBar shell must exist).

#### Estimated Effort

2 hours (specification only)

#### Testing Requirements

- Specification review: Verify event sources are correctly mapped.
- Integration tests: After implementation, verify that completing a task or receiving an email pushes a notification.

#### Validation Steps

1. Review `08-Notifications.md` for completeness.
2. Verify the Plan includes notification tasks.
3. Check the StatusBar spec references the NotificationBell.

#### Strict Rules

- Notifications must be stored in Zustand only (no IndexedDB for MVP).
- Notification state must not be persisted across sessions.
- Max 50 notifications in the list; oldest are evicted.

#### Existing Code Patterns

N/A — New specification.

#### Advanced Code Patterns

The event bus pattern:

```typescript
// In notificationSlice:
addNotification: (notification) => set(state => ({
  notifications: [notification, ...state.notifications].slice(0, 50),
}))

// Usage from any module:
import { useNotificationStore } from '@/stores/slices/notificationSlice';
const addNotification = useNotificationStore(s => s.addNotification);
addNotification({
  id: crypto.randomUUID(),
  type: 'budget_alert',
  title: 'Overspend Alert',
  body: 'Dining category is 120% of budget.',
  link: '/budget?category=dining',
  priority: 'high',
});
```

[VERIFY: the `useNotificationStore` path matches the actual store location; adjust as needed]

#### Anti-Patterns

- ❌ Each module implementing its own notification toast independently.
- ❌ Storing notifications in module-specific state instead of the shared slice.
- ❌ Not providing a link/action for the notification.

---

### TASK-011: Create Global Route Map Specification

**Status**: 🟡 Pending  
**Priority**: 🔴 Critical  
**Parent Task ID**: TASK-011

#### Subtasks

- [ ] **TASK-011-01**: Create `00-Routes.md` listing every route path, its lazy import source, loader function summary, guard requirements, and special annotations (e.g., "requires Auth", "desktop only").  

  [CHECK: filename `00-Routes.md` is free]  
  **Target File**: `00-Routes.md`

- [ ] **TASK-011-02**: Populate `00-Routes.md` from the route specifications in each module spec and the Plan.  

  [VERIFY: all module spec files are accounted for; if new modules have been added, include them]  
  **Target File**: `00-Routes.md`

- [ ] **TASK-011-03**: Update `01-Foundations.md` FND‑007 to reference `00-Routes.md` as the canonical route source.  

  [CONFIRM ID: FND‑007 exists and is still the route configuration task]  
  **Target File**: `01-Foundations.md`

#### Priority / Urgency

🔴 Critical. The React Router v7 configuration is the backbone of navigation. Without a single source of truth for all routes, the router configuration will be assembled from scattered specifications, leading to missing routes, incorrect guards, and broken navigation. Agentic coding tools need a machine‑parseable route list.

#### Research / Investigation

Each module spec defines its own routes (e.g., `11-Chat.md` CHAT‑001C, `20-Projects.md` PROJ‑002A, `21-Calendar.md` CAL‑001G). The `00-Plan.md` gives a high‑level sequence but not the complete route table. A unified `00-Routes.md` should be a structured reference, not a narrative document — ideally with a table format and optional machine‑readable JSON alongside.  
[VERIFY: the route definitions in each module spec are still accurate; if any have been added or changed, capture them]

#### Related Files

- `00-Routes.md` (new)
- `01-Foundations.md` (FND‑007)
- All module specs with `### Subtasks` containing route configuration
- `00-Plan.md` (for sequence context)

#### Definition of Done

- `00-Routes.md` contains a complete table of all routes.
- Each route entry includes: path, method (GET/POST), lazy import path, auth requirement, module association.
- FND‑007 references this document as authoritative.

#### Acceptance Criteria

- Every route defined in any module spec appears in `00-Routes.md`.
- The table can be parsed to generate a React Router configuration automatically.

#### Out of Scope

- Defining route transition animations (those are per‑module).
- Specifying data loaders in full implementation detail (summary only).

#### Dependencies

- TASK‑002 (Plan must be aligned first).

#### Estimated Effort

2 hours

#### Testing Requirements

- Specification audit: Cross‑reference all module route definitions against the table.
- Automated: Build a script that extracts route definitions from `00-Routes.md` and compares them against all module specs.

#### Validation Steps

1. Search all module specs for route path definitions (e.g., `path: 'chat'`).
2. Verify each appears in `00-Routes.md`.
3. Check that all routes requiring auth are marked as such.

#### Strict Rules

- The route table must be the first section of the document for easy parsing.
- Use consistent column names: Path, Module, Lazy Import, Auth, Loader Summary.
- Sort by path alphabetically.

#### Existing Code Patterns

Table format example:

```markdown
| Path | Module | Lazy Import | Auth | Loader Summary |
|------|--------|-------------|------|----------------|
| `/` | Dashboard | `@/pages/Dashboard` | Yes | Prefetch agents |
| `/chat` | Chat | `@/pages/ChatPage` | Yes | Prefetch threads |
| `/calendar` | Calendar | `@/pages/CalendarPage` | Yes | Prefetch current month |
```

[VERIFY: these example paths match the actual route tables in the specs; update before finalizing]

#### Advanced Code Patterns

N/A — Specification only.

#### Anti-Patterns

- ❌ Defining the same route in two different module specs without acknowledging it.
- ❌ Missing auth requirement on routes that need it.
- ❌ Using different path conventions across modules.

---

### TASK-012: Create Global Seed Data Specification for Integration Tests

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-012

#### Subtasks

- [ ] **TASK-012-01**: Add a task `FND‑004J` to `01-Foundations.md` for creating `src/mocks/seed.ts` with `seedAllData()` that generates a consistent set of interrelated mock data (users, accounts, categories, contacts, projects, etc.).  

  [VERIFY: the next available sub‑ID under FND‑004 (e.g., FND‑004J) is free and follows the numbering convention; check `01-Foundations.md`]  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-012-02**: Update all module factory specifications to accept an optional `context` parameter containing shared IDs (e.g., `userId`, `projectId`) instead of generating random UUIDs.  

  [VERIFY: which modules have factory specifications; list them before updating]  
  **Target Files**: All module specs with factory tasks (NEWS‑000, BUDG‑001, CAL‑000, etc.)

- [ ] **TASK-012-03**: Require all integration tests to call `seedAllData()` before rendering.  

  [VERIFY: the integration test setup documentation (likely in `01-Foundations.md` FND‑004) is the right place]  
  **Target File**: `01-Foundations.md` (FND‑004)

#### Priority / Urgency

🟠 High. Without shared seed data, cross‑module integration tests will fail because IDs won't match (e.g., a transaction references a category that doesn't exist in the mock). This is essential for reliable multi‑module testing.

#### Research / Investigation

The current factory pattern generates fully random UUIDs every time. For single‑module tests, this is fine. But when testing that "completing a project task creates a budget transaction," the task's `projectId` must match an existing project, and the resulting transaction must reference a valid `categoryId`. A `seedAllData()` function can return a context object with all shared IDs, and factories can use these for their foreign keys.  
[VERIFY: the list of interrelated entities is still accurate; if the data model has changed, update seed data spec]

#### Related Files

- `01-Foundations.md` (FND‑004J)
- `src/mocks/seed.ts` (new)
- All module factory specifications
- All module mock handler specifications

#### Definition of Done

- `FND‑004J` is added to `01-Foundations.md` with a complete specification.
- Every factory specification notes that it can accept a `context` parameter.
- The seed function is documented to produce deterministic output when given a fixed `faker.seed()`.

#### Acceptance Criteria

- Calling `seedAllData()` returns a context with `user.id`, `account.id`, `category.id`, `project.id`, `contact.id`, etc.
- A factory called with `createMockTransaction({ accountId: context.accountId })` produces a valid transaction linked to the seeded account.
- Running the seed function with the same seed produces identical data.

#### Out of Scope

- Implementing the actual seed function (that is an implementation task).
- Ensuring referential integrity in production data (only mock data).

#### Dependencies

- TASK‑003 (centralized Dexie must be specified first).

#### Estimated Effort

2 hours

#### Testing Requirements

- Unit test: Verify `seedAllData()` returns consistent, referentially intact data.
- Integration test: Use seeded data in a multi‑module test and verify no ID mismatches.

#### Validation Steps

1. Review the `FND‑004J` specification for completeness.
2. Check that factory specs mention the `context` parameter.
3. Verify the seed function is deterministic with a fixed seed.

#### Strict Rules

- The seed function MUST use `faker.seed()` for determinism.
- All foreign key references in seeded data must point to IDs present in the same seed context.
- The seed function must export a `resetAllData()` companion that clears all mock state.

#### Existing Code Patterns

Example seed function pattern:

```typescript
export function seedAllData() {
  faker.seed(12345);

  const user = createMockUser();
  const accounts = createMockAccounts(3, { ownerId: user.id });
  const categories = createMockCategories(10);
  const contacts = createMockContacts(5, { userId: user.id });
  const projects = createMockProjects(3, { ownerId: user.id, memberIds: [user.id] });

  return { user, accounts, categories, contacts, projects };
}
```

[VERIFY: the faker import and seeding API match the installed version (`@faker-js/faker`)]

#### Advanced Code Patterns

Factories accepting context:

```typescript
export function createMockTransaction(overrides: Partial<Transaction> = {}, context?: SeedContext): Transaction {
  return {
    id: faker.string.uuid(),
    accountId: overrides.accountId || (context ? faker.helpers.arrayElement(context.accounts).id : faker.string.uuid()),
    categoryId: overrides.categoryId || (context ? faker.helpers.arrayElement(context.categories).id : faker.string.uuid()),
    // ...
  };
```

[VERIFY: the `Transaction` type and field names match the module spec definitions]

#### Anti-Patterns

- ❌ Generating all IDs randomly in integration tests.
- ❌ Hardcoding expected IDs in test assertions without using the seed context.
- ❌ Not resetting state between tests.

---

## 🟡 Phase 5: Performance and Production Readiness

---

### TASK-013: Specify Heavy Library Code-Splitting Strategy

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-013

#### Subtasks

- [ ] **TASK-013-01**: In `99-Polish-Validation.md` (POL‑001), add explicit `manualChunks` targets for: `@monaco-editor/react` (CHAT‑011), `@xyflow/react` (FLOW‑001), `react-big-calendar` (CAL and BUDG), `@babel/standalone` (CHAT‑012), `tesseract.js` (DOC‑005), `recharts` (BUDG).  

  [CONFIRM ID: each of these task IDs (CHAT‑011, FLOW‑001, CHAT‑012, DOC‑005) still references the heavy library feature; verify library names haven't changed]  
  **Target File**: `99-Polish-Validation.md`

- [ ] **TASK-013-02**: In `11-Chat.md` (CHAT‑011) and `12-Workflow.md` (FLOW‑001), add notes that these libraries must be lazy‑loaded with `<Suspense>` and a skeleton fallback.  

  [CHECK PATH: `12-Workflow.md` exists; if the workflow module has been renamed/merged, adjust]  
  **Target Files**: `11-Chat.md`, `12-Workflow.md`

- [ ] **TASK-013-03**: In `01-Foundations.md` (FND‑002), add the `vite-plugin-monaco-editor-esm` and similar Vite‑specific plugins to the dependency installation subtasks.  

  [VERIFY: the exact plugin name is still `vite-plugin-monaco-editor-esm`; check npm for the current package name]  
  **Target File**: `01-Foundations.md`

#### Priority / Urgency

🟠 High. The bundle budget in `POL‑C02` (vendor chunk <500KB, total initial JS <2MB) cannot be met without explicit code‑splitting. Monaco Editor alone is >5MB uncompressed. Without `manualChunks` and lazy loading, the initial bundle will far exceed the budget.

#### Research / Investigation

Vite's `rollupOptions.output.manualChunks` can group libraries into named chunks. Libraries like Monaco and React Flow should be loaded only when their respective features are activated (Chat Canvas, Workflow Editor). Using React's `lazy()` and `<Suspense>` with a skeleton ensures the main bundle stays small. The `vite-plugin-monaco-editor-esm` handles Monaco's Web Worker bundling correctly in Vite's ESM environment.  
[UPDATE IF: the project has moved to a different bundler or Vite version with different APIs, adjust accordingly]

#### Related Files

- `99-Polish-Validation.md` (POL‑001)
- `11-Chat.md` (CHAT‑011 — Collaboration Canvas)
- `12-Workflow.md` (FLOW‑001 — Workflow Canvas)
- `01-Foundations.md` (FND‑002 — Dependencies)

#### Definition of Done

- `POL‑001` lists all heavy libraries with their chunk names and the feature that triggers their lazy load.
- Each affected feature task includes a note about lazy loading with fallback skeleton.
- Vite‑specific plugins are documented in FND‑002.

#### Acceptance Criteria

- `manualChunks` configuration groups Monaco, React Flow, and other heavy libs into separate chunks.
- The initial bundle size is verifiable below 2MB after code‑splitting.
- Switching to the Canvas or Workflow view shows a skeleton while the chunk loads.

#### Out of Scope

- Implementing the actual `manualChunks` Rollup configuration.
- Measuring actual bundle sizes (that happens after implementation).

#### Dependencies

None.

#### Estimated Effort

1.5 hours

#### Testing Requirements

- Build analysis: After implementation, run `rollup-plugin-visualizer` to verify chunk sizes.
- Manual: Verify that navigating to Canvas view shows a skeleton before the editor renders.

#### Validation Steps

1. Review `POL‑001` for the complete list of heavy libraries.
2. Check that each library is associated with a specific feature/view.
3. Verify the lazy‑loading notes in the relevant module tasks.

#### Strict Rules

- No library larger than 1MB may be in the initial bundle.
- All heavy libraries must have a skeleton fallback specified.
- The `manualChunks` configuration must be documented, not just implied.

#### Existing Code Patterns

Vite config pattern:

```typescript
build: {
  rollupOptions: {
    output: {
      manualChunks: {
        'monaco-editor': ['@monaco-editor/react'],
        'react-flow': ['@xyflow/react'],
        'charts': ['recharts'],
      },
    },
  },
}
```

[VERIFY: these library names match the actual import specifiers in the codebase]

React lazy loading pattern:

```tsx
const CanvasEditor = lazy(() => import('@/components/chat/CanvasEditor'));
// Wrap in:
<Suspense fallback={<EditorSkeleton />}>
  <CanvasEditor />
</Suspense>
```

[IMPLEMENT: confirm the component paths exist; adjust if the directory structure has changed]

#### Advanced Code Patterns

N/A — Configuration only.

#### Anti-Patterns

- ❌ Importing heavy libraries at the top level of a page component.
- ❌ Not providing a skeleton fallback, causing a blank screen during load.
- ❌ Using `React.lazy` without `<Suspense>` (it will throw).

---

### TASK-014: Specify SSE and ReadableStream Testing Utilities

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-014

#### Subtasks

- [ ] **TASK-014-01**: Add a section to `01-Foundations.md` FND‑004 for mocking `ReadableStream` and `AbortController` in Vitest. Specify a `createSSEStream(tokens, options?)` utility that returns a `Response` with a readable stream and SSE‑formatted chunks.  

  [VERIFY: FND‑004 is the testing infrastructure task; if it has been reorganized, target the appropriate section]  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-014-02**: Update `11-Chat.md` (CHAT‑007D) to use the shared SSE mock utility instead of inline stream construction.  

  [CHECK PATH: `11-Chat.md`; CONFIRM ID: CHAT‑007D still contains the SSE stream consumption spec]  
  **Target File**: `11-Chat.md`

- [ ] **TASK-014-03**: Update `33-Translation.md` (TRANS‑006D) to use the shared SSE mock utility.  

  [CHECK PATH: `33-Translation.md`; CONFIRM ID: TRANS‑006D]  
  **Target File**: `33-Translation.md`

- [ ] **TASK-014-04**: Add test case patterns for partial chunk reassembly, `AbortError` suppression, and reconnect logic to the FND‑004 SSE section.  

  **Target File**: `01-Foundations.md`

#### Priority / Urgency

🟠 High. Streaming is used in Chat and Translation for real‑time updates. Testing stream consumption is notoriously tricky because of `ReadableStream` and `AbortController` interactions. Without shared test utilities, each module will implement its own (possibly buggy) test helpers, leading to false positives.

#### Research / Investigation

MSW can return `ReadableStream` responses. A common pattern is to create a `createSSEStream` function that takes an array of tokens and returns a `Response` with `Content-Type: text/event-stream`. The consumer reads with `response.body.getReader()`. Tests need to verify that partial chunks are buffered correctly, that `[DONE]` terminates the stream, and that `AbortError` is suppressed without calling `onError`.  
[VERIFY: MSW version in use supports `ReadableStream`; earlier versions may require polyfill]

#### Related Files

- `01-Foundations.md` (FND‑004)
- `src/test/sseMock.ts` (target implementation)
- `11-Chat.md` (CHAT‑007D)
- `33-Translation.md` (TRANS‑006D)

#### Definition of Done

- `FND‑004` contains a dedicated "SSE Testing" subsection with the `createSSEStream` utility specification.
- Both Chat and Translation stream handler specifications reference this utility.
- The subsection includes explicit test case patterns for the three key streaming edge cases.

#### Acceptance Criteria

- `createSSEStream(['Hello', ' world', '[DONE]'])` returns a Response whose reader yields the tokens.
- Partial chunk reassembly test passes: two `enqueue` calls whose concat forms a message are correctly reassembled.
- AbortError suppression test passes: aborting the reader does not trigger `onError`.

#### Out of Scope

- Implementing the actual utility (that is an implementation task).
- WebSocket testing utilities.

#### Dependencies

None.

#### Estimated Effort

1.5 hours

#### Testing Requirements

- Unit tests for the `createSSEStream` utility itself (verify it produces valid SSE).
- Integration tests: Use the utility in Chat and Translation stream tests.

#### Validation Steps

1. Review the SSE Testing section in `01-Foundations.md` for completeness.
2. Verify Chat and Translation MSW handler specs reference the utility.
3. Check that the three edge case patterns are documented.

#### Strict Rules

- The utility must return a standard `Response` object (MSW compatible).
- The `ReadableStream` must support cancellation via `AbortController.signal`.
- `[DONE]` must be sent as a separate chunk.

#### Existing Code Patterns

Specification for the utility:

```typescript
// src/test/sseMock.ts
export function createSSEStream(tokens: string[], options?: {
  delayMs?: number;
  shouldError?: boolean;
}): Response {
  const stream = new ReadableStream({
    async start(controller) {
      for (const token of tokens) {
        if (options?.shouldError) {
          controller.error(new Error('Simulated stream error'));
          return;
        }
        controller.enqueue(new TextEncoder().encode(`data: ${token}\n\n`));
        if (options?.delayMs) await new Promise(r => setTimeout(r, options.delayMs));
      }
      controller.close();
    },
  });

  return new Response(stream, {
    headers: { 'Content-Type': 'text/event-stream' },
  });
}
```

[VERIFY: the `TextEncoder` usage is compatible with the test environment (Node, jsdom); polyfill if needed]

#### Advanced Code Patterns

Test patterns to add to FND‑004:
- **Partial chunk reassembly**: Enqueue two chunks `'{"tok'` and `'en":"hello"}'` then verify the consumer reconstructs the full JSON.
- **AbortError suppression**: Call `abortController.abort()` mid‑stream and verify `onError` is NOT called.
- **Reconnect**: Verify `Last-Event-ID` header is sent on subsequent requests.
[IMPLEMENT: these patterns must match the actual consumer implementation details]

#### Anti-Patterns

- ❌ Using `EventSource` in tests (cannot be mocked easily; use `fetch` + `ReadableStream`).
- ❌ Not testing partial chunk reassembly (network packets fragment arbitrarily).
- ❌ Treating `AbortError` as a real error in tests.

---

## 🟢 Phase 6: Quality and Polish

---

### TASK-015: Create Shared UI Components Library Specification

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-015

#### Subtasks

- [ ] **TASK-015-01**: Create a task in `01-Foundations.md` (FND‑002‑L or new FND‑003B) specifying the following shared components:

  - `<EmptyState icon="..." title="..." description="..." action={{ label, onClick }} />`
  - `<ErrorScreen title="..." message="..." onRetry={() => void} />`
  - `<ConfirmDialog title="..." description="..." confirmLabel="..." onConfirm={() => void} variant="destructive" />`
  - `<LoadingSkeleton variant="card" | "table" | "text" count={5} />`
  [VERIFY: the next available sub‑ID under FND‑002 or FND‑003; check the current numbering in `01-Foundations.md`]  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-015-02**: Update all module specs that describe custom empty states or error screens to reference these shared components instead.  

  [VERIFY: which modules currently contain custom empty state/error specs; compile list before editing]  
  **Target Files**: `40-News.md`, `21-Calendar.md`, `50-Budget.md`, `20-Projects.md`, `22-Lists.md`

- [ ] **TASK-015-03**: Ensure the components follow the established `oklch()` color tokens and motion tier assignments.  

  [VERIFY: the `oklch()` token documentation location and naming convention]  
  **Target File**: `01-Foundations.md`

#### Priority / Urgency

🟠 High. At least six different modules independently specify skeleton loaders, empty states, and error screens with nearly identical requirements. Extracting these into shared components reduces implementation effort by ~20% and ensures consistent UX across the entire application.

#### Research / Investigation

The News module (`NEWS‑003G`, `NEWS‑003H`) specifies `FeedSkeleton` and `FeedEmptyState` components. The Budget module (`BUDG‑003C`, `BUDG‑003D`) specifies skeleton and empty state components. The Projects module (`PROJ‑025A`, `PROJ‑025B`) specifies skeleton loaders and empty states. All follow similar patterns but are defined independently. Centralizing them into a shared library eliminates duplication and ensures a single source of truth for UX patterns.  
[VERIFY: the list of module-specific components is still accurate; check if any have already been refactored]

#### Related Files

- `01-Foundations.md` (new task or sub-section)
- `src/components/shared/EmptyState.tsx` (target)
- `src/components/shared/ErrorScreen.tsx` (target)
- `src/components/shared/ConfirmDialog.tsx` (target)
- `src/components/shared/LoadingSkeleton.tsx` (target)
- `40-News.md`, `21-Calendar.md`, `50-Budget.md`, `20-Projects.md`, `22-Lists.md`

#### Definition of Done

- Shared component specs are in `01-Foundations.md`.
- At least the four listed component types are specified.
- All module specs reference these shared components for their loading/empty/error states.
- Each component specification includes props, variants, and motion tier assignment.

#### Acceptance Criteria

- Searching for "skeleton" or "empty state" in module specs returns references to the shared components.
- The shared component props cover all use cases described in the module specs.

#### Out of Scope

- Implementing the components (that is an implementation task).
- Building a full design system (only these four component types).

#### Dependencies

- TASK‑005 (`SanitizedHTML` component should be part of this library or alongside it).

#### Estimated Effort

2 hours

#### Testing Requirements

- Specification review: Verify all module empty/error/loading states map to a shared component variant.
- Implementation tests: Verify each component renders correctly with sample props.

#### Validation Steps

1. Review the shared component specifications for completeness.
2. Search module specs for custom empty state descriptions and verify they now reference the shared components.
3. Verify the props cover all described use cases.

#### Strict Rules

- The shared components must accept `className` for Tailwind overrides in consuming modules.
- All components must have accessible names and roles (e.g., `<EmptyState>` has `role="status"`).
- Skeletons must respect `prefers-reduced-motion`.

#### Existing Code Patterns

N/A — Specification only.

#### Advanced Code Patterns

Example specification for EmptyState:

```tsx
interface EmptyStateProps {
  icon: LucideIcon;
  title: string;
  description?: string;
  action?: { label: string; onClick: () => void };
  className?: string;
}
```

[VERIFY: LucideIcon is the correct icon type used in the project; if a different icon library is used, adjust]

#### Anti-Patterns

- ❌ Each module building its own skeleton component with different animation patterns.
- ❌ Using different terminology for the same concept (e.g., "no data" vs "empty" vs "nothing here").
- ❌ Not providing an action CTA in empty states.

---

### TASK-016: Create End-to-End Scenarios Specification

**Status**: 🟡 Pending  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-016

#### Subtasks

- [ ] **TASK-016-01**: Create `98-EndToEndScenarios.md` describing 5‑10 critical multi‑module user workflows:

  1. Dashboard → Chat → Canvas → Create Project
  2. Calendar → Create Event → Link to Project → Budget Forecast
  3. Email → Convert to Task → Project Task List → Complete
  4. Research → OCR Document → AI Q&A → Export Report
  5. Triage → Plan for Week → My Week View → Mark Complete
  [VERIFY: these workflows reflect the current feature set and module integration points; update if modules have changed or new flows are critical]
  **Target File**: `98-EndToEndScenarios.md`

- [ ] **TASK-016-02**: Each scenario must list the module task IDs involved, the expected sequence of user actions, and the expected system responses.  

  [VERIFY: task IDs referenced in scenarios are valid and up‑to‑date; re‑generate after TASK‑001 and TASK‑002]  
  **Target File**: `98-EndToEndScenarios.md`

- [ ] **TASK-016-03**: Add a note that these scenarios should be implemented as Playwright E2E tests in Phase 6.  

  **Target File**: `98-EndToEndScenarios.md`

- [ ] **TASK-016-04**: Update `99-Polish-Validation.md` POL‑002D to reference these scenarios as the minimum E2E test coverage.  

  [CONFIRM ID: POL‑002D exists and is the E2E test requirement]  
  **Target File**: `99-Polish-Validation.md`

#### Priority / Urgency

🟠 High. E2E tests validate that modules work together correctly. Without predefined scenarios, E2E testing will be ad‑hoc and miss critical integration bugs. The scenarios also serve as a validation checklist for the build sequence.

#### Research / Investigation

The `99-Polish-Validation.md` POL‑002D already mentions four E2E test cases but they are minimal. Expanding to 5‑10 scenarios covering the most important user journeys ensures that cross‑module dependencies are validated. Each scenario should be a self‑contained narrative that references specific task IDs and UI components.  
[VERIFY: the current POL‑002D text; incorporate its existing scenarios or note replacement]

#### Related Files

- `98-EndToEndScenarios.md` (new)
- `99-Polish-Validation.md` (POL‑002D)
- All module specs (for task ID references)

#### Definition of Done

- `98-EndToEndScenarios.md` exists with 5‑10 scenarios.
- Each scenario includes task IDs, user actions, and system responses.
- The `POL‑002D` checklist references this document.

#### Acceptance Criteria

- Scenarios cover Dashboard, Chat, Calendar, Email, Projects, Budget, Documents, Triage, and Research.
- Each scenario name is a descriptive title.
- Task ID references are correct and verifiable.

#### Out of Scope

- Writing the actual Playwright test code.
- Defining Playwright configuration for these tests.

#### Dependencies

- TASK‑001 (all task IDs must be correct).
- TASK‑002 (Plan must be aligned for sequence logic).

#### Estimated Effort

2 hours

#### Testing Requirements

- Specification review: Verify each scenario is logically coherent and references valid task IDs.
- Implementation: After modules are built, implement these as Playwright tests.

#### Validation Steps

1. Read each scenario and verify the sequence of actions is logical.
2. Check that all referenced task IDs exist in the task registry.
3. Verify scenarios cover at least 5 different modules.

#### Strict Rules

- Each scenario must involve at least two different modules.
- Module task IDs must be the canonical IDs from the task registry.
- System responses must be described concretely, not vaguely.

#### Existing Code Patterns

N/A — Specification only.

#### Advanced Code Patterns

N/A

#### Anti-Patterns

- ❌ Scenarios that test only one module in isolation.
- ❌ Vague system responses like "the UI updates."
- ❌ Referencing task IDs that don't exist.

---

### TASK-017: Add Cross-Module Cache Invalidation Map

**Status**: 🟡 Pending  
**Priority**: 🟡 Medium  
**Parent Task ID**: TASK-017

#### Subtasks

- [ ] **TASK-017-01**: Add a "Cross‑Module Invalidation Map" section to `01-Foundations.md` (under FND‑006) that lists which module's mutation should trigger invalidation of which other module's query keys.  

  [CONFIRM ID: FND‑006 is still the TanStack Query conventions task; if it has been refactored, adjust target]  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-017-02**: Define the initial invalidation mappings:

  - `useCreateTransaction` → invalidate `budgetKeys.dashboard()`, `budgetKeys.categories()`.
  - `useUpdateTask` (complete) → invalidate `projectKeys.detail(projectId)`, `budgetKeys.reports()` (if task has budget tracking).
  - `useCreateProject` → invalidate `budgetKeys.goals()` (if linked to budget goal).
  - `useStarEmail` → no cross‑module invalidation needed.
  [VERIFY: the mutation names and key factory method names match the actual codebase; adjust if conventions differ]  
  **Target File**: `01-Foundations.md`

- [ ] **TASK-017-03**: Update each affected mutation specification to include the cross‑module keys in its `onSettled` invalidation.  

  [VERIFY: which spec files contain those mutation tasks (BUDG‑001F, PROJ‑000H, EMAIL‑000G) and that they still exist]  
  **Target Files**: `50-Budget.md`, `20-Projects.md`, `30-Email.md`

#### Priority / Urgency

🟡 Medium. Without deliberate cross‑module invalidation, data will become stale when actions in one module affect another (e.g., completing a budget‑tracked task updates the project but the budget dashboard still shows old data). This causes UX confusion and potential data integrity issues.

#### Research / Investigation

TanStack Query supports invalidating multiple query keys in `onSettled`. The current specs only invalidate keys within the same module. The invalidation map formalizes which cross‑module dependencies exist, preventing stale caches. This is particularly important for the tight integration between Projects and Budget, Email and Calendar, and Chat and Research.  
[VERIFY: the key factory conventions (`budgetKeys.dashboard()`, etc.) are accurate; search the codebase for exact patterns]

#### Related Files

- `01-Foundations.md` (FND‑006)
- `50-Budget.md` (BUDG‑001F, BUDG‑006)
- `20-Projects.md` (PROJ‑000H)
- `30-Email.md` (EMAIL‑000G)

#### Definition of Done

- The invalidation map exists in `01-Foundations.md`.
- At least 5 cross‑module invalidation rules are documented.
- Affected mutation specs include the cross‑module keys.

#### Acceptance Criteria

- A developer reading the invalidation map can determine which caches will be refreshed after any mutation.
- Each rule includes the source mutation, target module, target query key(s), and rationale.

#### Out of Scope

- Implementing a generic cross‑module invalidation middleware (that is a future enhancement).
- Mapping every possible mutation (only high‑impact ones for MVP).

#### Dependencies

- TASK‑001 (task IDs must be correct).

#### Estimated Effort

1.5 hours

#### Testing Requirements

- Manual verification: After building, test that completing a budget‑tracked task refreshes the budget dashboard.
- Automated: Add integration tests that verify stale data is not shown after cross‑module mutations.

#### Validation Steps

1. Review the invalidation map for completeness.
2. Verify each listed source mutation has a corresponding `onSettled` calling `invalidateQueries` for the target keys.
3. Test manually after implementation.

#### Strict Rules

- Cross‑module invalidation must use the established key factories (e.g., `projectKeys.detail(id)`).
- Invalidations must be in `onSettled`, not `onSuccess`.
- Never invalidate `all` keys indiscriminately — be specific.

#### Existing Code Patterns

The existing modules already follow:

```typescript
onSettled: () => {
  queryClient.invalidateQueries({ queryKey: entityKeys.all });
}
```

Extend to:

```typescript
onSettled: () => {
  queryClient.invalidateQueries({ queryKey: entityKeys.all });
  // Cross-module invalidation:
  queryClient.invalidateQueries({ queryKey: budgetKeys.reports() });
}
```

[VERIFY: the key factory variable names (e.g., `entityKeys`, `budgetKeys`) match those used in the actual stores; adjust after codebase review]

#### Advanced Code Patterns

N/A

#### Anti-Patterns

- ❌ Invalidating `['budget']` (the entire module) instead of specific keys.
- ❌ Using `onSuccess` for cross‑module invalidation.
- ❌ Not documenting the cross‑module dependency, leading to forgotten invalidations.

---

## 📊 Task Dependency Graph

```
TASK-001 (Phantom IDs)
├── TASK-002 (Plan Alignment)
├── TASK-003 (Centralized Dexie)
├── TASK-004 (Shared Recurrence)
├── TASK-005 (SanitizedHTML)
├── TASK-006 (useOptimisticMutation)
├── TASK-007 (WCAG 2.5.7)
│   └── TASK-008 (Screen Reader Announcements)
├── TASK-009 (Auth Spec)
│   └── TASK-010 (Notification Center)
├── TASK-011 (Route Map)
├── TASK-012 (Seed Data)
├── TASK-013 (Code Splitting)
├── TASK-014 (SSE Testing)
├── TASK-015 (Shared UI Components)
├── TASK-016 (E2E Scenarios)
└── TASK-017 (Cache Invalidation Map)
```

[VERIFY: This dependency graph assumes tasks are independent as drawn; if during verification some dependency order must change, adjust links]

---

## 🏁 Completion Checklist

- [ ] **TASK-001**: Zero phantom task IDs remain. [VERIFY via grep and validate script]
- [ ] **TASK-002**: Plan phase lists match module specs exactly.
- [ ] **TASK-003**: Only one Dexie instance defined across all specs.
- [ ] **TASK-004**: Four modules reference shared RecurrenceEngine.
- [ ] **TASK-005**: Four modules reference shared SanitizedHTML.
- [ ] **TASK-006**: All mutations use the shared wrapper.
- [ ] **TASK-007**: All drag operations have WCAG 2.5.7 alternatives.
- [ ] **TASK-008**: All drag operations produce screen reader announcements.
- [ ] **TASK-009**: Auth module specification complete.
- [ ] **TASK-010**: Notification center specification complete.
- [ ] **TASK-011**: Global route map complete.
- [ ] **TASK-012**: Seed data specification complete.
- [ ] **TASK-013**: Code‑splitting strategy documented.
- [ ] **TASK-014**: SSE testing utilities specified.
- [ ] **TASK-015**: Shared UI component library specified.
- [ ] **TASK-016**: End‑to‑end scenarios documented.
- [ ] **TASK-017**: Cross‑module invalidation map documented.

```

*All placeholders are highlighted with **[VERIFY]**, **[CHECK PATH]**, **[CONFIRM ID]**, **[IMPLEMENT]**, or **[UPDATE IF]** tags. Resolve each one before executing its containing task.*

---

## See Also

- **Previous**: [TODO-Core.md](TODO-Core.md) - Phase 2: Shared Infrastructure Extraction
- **Previous**: [TODO-Critical.md](TODO-Critical.md) - Phase 1: Critical Cross-Document Corrections
- **Overview**: [TODO.md](TODO.md) - Main task index with all phases
