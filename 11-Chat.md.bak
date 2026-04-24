# 11‑Chat — Personal AI Command Center Frontend (Enhanced v3)

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.
>
> **Migration Note**: Earlier versions of this specification referenced `react-window` for virtualization. The corrected approach uses `@tanstack/react-virtual` (`useVirtualizer`) to align with the TanStack ecosystem already in use (Query, Table). The scroll anchoring contract and IntersectionObserver sentinel pattern remain intact.

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

## 🧱 Cross-Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **CHAT-C01** | Message Cache SSOT | TanStack Query cache is the **only** source of truth for messages. No local `useState` message arrays. |
| **CHAT-C02** | Optimistic Updates | User messages added via `queryClient.setQueryData` in `onMutate`. Rollback on error via snapshot. `onSettled` (not `onSuccess`) triggers invalidation so both success and error paths invalidate. |
| **CHAT-C03** | Stable React Keys | Optimistic messages use a `clientMsgId` generated with `crypto.randomUUID()` **once** at send time. This key is carried through to the server-confirmed message and used as the React `key` permanently — never replaced with the server ID — to prevent component remount and focus loss during the temp→real ID transition. |
| **CHAT-C04** | Streaming Transport | SSE over `fetch` + `ReadableStream`. Not `EventSource` (no custom headers). Not WebSockets (unidirectional). |
| **CHAT-C05** | Stream Lifecycle | `AbortController` stored in `useRef`. Abort on: (a) component unmount, (b) new message send while previous stream is active. Check `signal.aborted` in catch to suppress `AbortError` reporting. |
| **CHAT-C06** | Scroll Contract | Auto-scroll to bottom **only if** user is within 50px of bottom. Preserve position otherwise. Implemented with TanStack Virtual's `scrollToIndex` + scroll position tracking. |
| **CHAT-C07** | Cache Config | `staleTime: 0` + `gcTime: Infinity` for messages. Stale-immediately triggers refetch on focus; Infinity GC prevents eviction of in-progress threads from cache. |
| **CHAT-C08** | ARIA Live Regions | Message container: `role="log"` + `aria-live="polite"`. CheckpointBanner: `role="status"` + `aria-live="assertive"`. |
| **CHAT-C09** | Motion Guard | All animated components check `useReducedMotion()`. If true: skip character reveal (show full text), skip typing dots (show static "…"), skip spring transitions (instant). |
| **CHAT-C10** | Test Infrastructure | All network calls mocked via MSW handlers in `src/mocks/handlers/chat.ts`. TanStack Query wrapped in `createWrapper()` helper with fresh `QueryClient` per test. Hooks tested via `renderHook` from `@testing-library/react`. |

### Motion Tier Assignment

| Component | Tier | Technique |
|-----------|------|-----------|
| Thread list items | **Quiet** | `opacity` fade on mount, 150ms max, no stagger |
| MessageBubble (user) | **Static** | Instant render |
| MessageBubble (agent, new) | **Alive** | `opacity: 0→1`, `y: 10→0`, spring `stiffness: 300 damping: 30` |
| Streaming text | **Alive** | Character reveal ~20ms/char; blinking `\|` cursor; suppressed when `useReducedMotion()` |
| Typing indicator | **Alive** | Three-dot `keyframes` opacity `[0.3, 1, 0.3]`, staggered delays |
| LED input border | **Alive** | `boxShadow` glow on focus; 100ms brightness flash on keypress |
| ToolCallDisclosure chevron | **Alive** | `rotate: isOpen ? 180 : 0`, spring |
| CheckpointBanner | **Alive** | `y: -20→0` with `AnimatePresence` |
| Slash command menu | **Quiet** | Opacity fade 100ms |

---

## 🗂️ Task CHAT-002: Chat State Management — `useChatReducer`, Query Config & MSW Setup
**Priority:** 🔴 High
`src/pages/ChatPage.tsx` · `src/components/chat/ChatLayout.tsx` · `src/router/routes.ts`

### Subtasks

- [ ] **CHAT-001A**: Create `src/pages/ChatPage.tsx`:
  - Two-column layout: left thread list (240px fixed), right chat area (`flex-1`)
  - Composed of `<ChatLayout>` with slots for thread list and chat area
  - Wrap in `<motion.div>` page transition: `initial={{ opacity: 0, y: 8 }}` → `animate={{ opacity: 1, y: 0 }}` → `exit={{ opacity: 0, y: -8 }}`, 200ms
- [ ] **[TEST] CHAT-001A**: `ChatPage` renders both `ThreadList` and chat area within layout

- [ ] **CHAT-001B**: Responsive collapse: on `<768px`, thread list moves into a shadcn `Sheet` (overlay drawer) triggered by a hamburger/icon button. Chat area occupies full width on mobile.
- [ ] **[TEST] CHAT-001B**: At `767px` viewport, thread list is not visible in document flow; Sheet trigger is present

- [ ] **CHAT-001C**: Configure route in `src/router/routes.ts`:
  ```ts
  {
    path: 'chat',
    lazy: () => import('@/pages/ChatPage'),
    loader: () => queryClient.ensureQueryData(chatThreadsQueryOptions),
