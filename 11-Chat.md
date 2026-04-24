# 11‑Chat — Personal AI Command Center Frontend (Enhanced v3)

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.
>
> **Migration Note**: Earlier versions of this specification referenced `react-window` for virtualization. The corrected approach uses `@tanstack/react-virtual` (`useVirtualizer`) to align with the TanStack ecosystem already in use (Query, Table). The scroll anchoring contract and IntersectionObserver sentinel pattern remain intact.

---

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


## 🗂️ Task CHAT-001: Chat Page Layout & Route Configuration
**Priority:** 🔴 High
**Est. Effort:** 0.75 hours
**Depends On:** FND-007 (Router), FND-008 (Provider Tree)

### Related Files
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
  }
  ```
  Route `loader` calls `ensureQueryData` so thread data is in cache before paint.
- [ ] **[TEST] CHAT-001C**: Navigating to `/chat` triggers thread prefetch; `ChatPage` is reachable via router

- [ ] **CHAT-001D**: Ensure `ChatPage` is wrapped by `AnimatePresence` at the router level (in root layout). Confirm `key={location.pathname}` on the motion wrapper so exit/enter animations fire on route change.
- [ ] **[TEST] CHAT-001D**: Navigating away from `/chat` triggers exit animation (opacity reaches 0)

### Definition of Done
- `/chat` renders two-column layout; thread list prefetched by loader
- Mobile: thread list in Sheet overlay
- Page transition fires on enter and exit

---


## 🗂️ Task CHAT-002: Chat State Management — `useChatReducer`, Query Config & MSW Setup
**Priority:** 🔴 High
**Est. Effort:** 2.5 hours
**Depends On:** FND-006 (TanStack Query)

### Related Files
`src/queries/chat.ts` · `src/hooks/useChatReducer.ts` · `src/hooks/useChatMessages.ts` · `src/mocks/handlers/chat.ts`

### Subtasks

**Query Layer:**

- [ ] **CHAT-002A**: Create `src/queries/chat.ts` with Query Key Factory:
  ```ts
  export const chatKeys = {
    all: ['chat'] as const,
    threads: () => [...chatKeys.all, 'threads'] as const,
    thread: (id: string) => [...chatKeys.threads(), id] as const,
    messages: (threadId: string) => [...chatKeys.thread(threadId), 'messages'] as const,
  }
  ```
- [ ] **[TEST] CHAT-002A**: Key factory produces stable, type-safe arrays; `messages('a')` is structurally distinct from `messages('b')`

- [ ] **CHAT-002B**: Define `messagesQueryOptions(threadId: string)`:
  ```ts
  queryOptions({
    queryKey: chatKeys.messages(threadId),
    queryFn: () => fetchMessages(threadId),
    staleTime: 0,       // Real-time: refetch on every focus/mount
    gcTime: Infinity,   // Never evict an active thread's messages
  })
  ```
- [ ] **[TEST] CHAT-002B**: `staleTime` is 0 and `gcTime` is `Infinity` on the options object

- [ ] **CHAT-002C**: Define `useSendMessage(threadId: string)` mutation:
  - `onMutate`: Cancel outgoing queries → snapshot previous cache → optimistically append user message with `clientMsgId: crypto.randomUUID()`, `status: 'sending'`
  - `onError`: Restore snapshot via `queryClient.setQueryData`
  - `onSettled`: Invalidate `chatKeys.messages(threadId)` (handles both success and error paths)
  - The `clientMsgId` is passed through as part of the mutation variables and echoed back by the server; used to replace the `status: 'sending'` message without changing its React `key`
- [ ] **[TEST] CHAT-002C**: Optimistic message appears immediately with `status: 'sending'`; on error, cache reverts; on success, status updates to `'sent'` without key change

- [ ] **CHAT-002D**: Define `useCreateThread()` and `useThreads()` for thread CRUD. Thread list uses `chatKeys.threads()` as cache key.
- [ ] **[TEST] CHAT-002D**: Creating a thread optimistically prepends it to thread list cache

**Reducer Layer:**

- [ ] **CHAT-002E**: Create `src/hooks/useChatReducer.ts`:

  State shape:
  ```ts
  type ChatState = {
    input: string
    isStreaming: boolean
    streamingMessageId: string | null
    showTypingIndicator: boolean
    selectedModel: string
    showSlashMenu: boolean
    slashQuery: string
  }
  ```

  Actions: `SET_INPUT` · `START_STREAMING` · `APPEND_TOKEN` · `END_STREAMING` · `SET_MODEL` · `OPEN_SLASH_MENU` · `CLOSE_SLASH_MENU` · `SET_SLASH_QUERY` · `RESET_INPUT`

  All state transitions must be pure; no side effects in reducer.
- [ ] **[TEST] CHAT-002E**: Each action produces the correct next state; reducer is a pure function (same input → same output)

- [ ] **CHAT-002F**: Create `src/hooks/useChatMessages.ts` — composite hook:
  - Calls `useQuery(messagesQueryOptions(threadId))`
  - Calls `useChatReducer()`
  - Calls `useSendMessage(threadId)` and wires send to dispatch `START_STREAMING`
  - Exposes: `{ messages, isLoading, sendMessage, input, dispatch, streamingState, selectedModel }`
- [ ] **[TEST] CHAT-002F**: `useChatMessages` composes correctly; calling `sendMessage` dispatches `START_STREAMING` and calls mutation

**Test Infrastructure:**

- [ ] **CHAT-002G**: Create `src/mocks/handlers/chat.ts` with MSW handlers for:
  - `GET /api/threads` → returns mock thread list
  - `GET /api/threads/:id/messages` → returns mock messages
  - `POST /api/threads/:id/messages` → echoes back with server ID + `clientMsgId`
  - `GET /api/threads/:id/stream` → simulates SSE token stream
- [ ] **CHAT-002H**: Create `src/test/utils/createWrapper.tsx` — `QueryClient` wrapper factory for `renderHook` tests:
  ```ts
  export function createWrapper() {
    const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
    return ({ children }) => <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  }
  ```

### Definition of Done
- `chatKeys` factory typed and stable
- `messagesQueryOptions` has `staleTime: 0` and `gcTime: Infinity`
- `useSendMessage` has optimistic insert → rollback → invalidate
- `useChatReducer` covers all UI state transitions as pure reducer
- `useChatMessages` composites both layers
- MSW handlers cover all chat endpoints
- `createWrapper` utility available for hook tests

### Anti-Patterns
- ❌ `onSuccess` for invalidation — use `onSettled` (fires on both success and error)
- ❌ `Date.now()` as temp ID — use `crypto.randomUUID()` (collision-safe, UUID-stable)
- ❌ Replacing React `key` when server ID arrives — carry `clientMsgId` as permanent key
- ❌ `gcTime` left at default with `staleTime: 0` — messages get GC'd from cache mid-conversation
- ❌ `useState` for streaming/model/slash menu state — use the reducer for predictable transitions

---

## 🧵 Task CHAT-003: Thread List
**Priority:** 🔴 High
**Est. Effort:** 1.5 hours
**Depends On:** CHAT-001, CHAT-002

### Related Files
`src/components/chat/ThreadList.tsx` · `src/components/chat/ThreadListItem.tsx`

### Subtasks

- [ ] **CHAT-003A**: Build `ThreadList` component:
  - Search input at top (controlled, immediate UI update)
  - "New Chat" button (electric blue, primary)
  - Scrollable list of `ThreadListItem`
  - Empty state: "No conversations yet. Start a new chat."
  - No virtualization needed (thread lists are typically ≤100 items; TanStack Virtual adds overhead without benefit at this scale)
- [ ] **[TEST] CHAT-003A**: Thread list renders mock threads; empty state shows when list is empty

- [ ] **CHAT-003B**: Implement search with `useTransition`:
  ```tsx
  const [search, setSearch] = useState('')
  const [isPending, startTransition] = useTransition()
  const [filteredThreads, setFilteredThreads] = useState(threads)

  const handleSearch = (value: string) => {
    setSearch(value)
    startTransition(() => {
      setFilteredThreads(threads.filter(t => t.title.toLowerCase().includes(value.toLowerCase())))
    })
  }
  ```
  `isPending` shows a subtle opacity on the list (0.6) to signal filtering without blocking the input.
- [ ] **[TEST] CHAT-003B**: Search input updates immediately; filtered list updates without UI jank; `isPending` reduces list opacity during transition

- [ ] **CHAT-003C**: Build `ThreadListItem`:
  - Displays: title (truncated), relative timestamp (`date-fns/formatDistanceToNow`), first-line preview (truncated), agent badge
  - Active thread: `border-l-2 border-[electric-blue] bg-white/5`
  - Click navigates to `/chat?threadId=...` (uses `useSearchParams`, not path param, so layout persists without remount)
- [ ] **[TEST] CHAT-003C**: Clicking thread updates URL search param; active thread has left border; inactive threads do not

- [ ] **CHAT-003D**: "New Chat": calls `useCreateThread()` mutation, which optimistically prepends a new thread to `chatKeys.threads()` cache, then navigates to the new thread's URL. On error, rollback and show toast.
- [ ] **[TEST] CHAT-003D**: "New Chat" button click adds thread optimistically; on error, thread disappears and error toast appears

### Definition of Done
- Thread list renders from cache; search filters non-blocking via `useTransition`
- Thread items show title, relative time, preview, agent badge
- Active thread visually distinguished; navigation uses search params
- "New Chat" creates optimistically with error rollback

### Anti-Patterns
- ❌ Virtualizing the thread list — unnecessary at ≤100 items; adds complexity without gain
- ❌ Path-param navigation for thread switching — causes page remount; use search params
- ❌ `setTimeout`-based debounce for search — use `useTransition` for non-blocking React 19+ pattern

---

## 💬 Task CHAT-004: Message Display — MessageBubble & MessageList
**Priority:** 🔴 High
**Est. Effort:** 2 hours
**Depends On:** CHAT-002

### Related Files
`src/components/chat/MessageList.tsx` · `src/components/chat/MessageBubble.tsx`

### Subtasks

**MessageBubble:**

- [ ] **CHAT-004A**: Build `MessageBubble` component, wrapped in `React.memo` with custom comparator:
  - Props: `message: Message`, `isStreaming: boolean`
  - User: right-aligned, `bg-[#1a1a1a]` charcoal, `rounded-[18px_18px_4px_18px]`
  - Agent: left-aligned, glass card `backdrop-blur-sm bg-white/5 border border-white/10`, `rounded-[4px_18px_18px_18px]`
  - `aria-label`: `"Your message"` / `"Assistant message"` · `role="article"`
  - Custom memo comparator: only re-render when `message.content`, `message.status`, or `isStreaming` changes — not on unrelated parent renders
- [ ] **[TEST] CHAT-004A**: User message right-aligned charcoal; agent message left-aligned glass; `React.memo` prevents re-render when irrelevant props change

- [ ] **CHAT-004B**: Streaming text reveal on agent messages:
  - Maintain `displayedContent` in local `useRef` updated by `useEffect`
  - Reveal characters at ~20ms/char using `setInterval` while `isStreaming`
  - Append blinking `|` cursor CSS class while streaming; remove when done
  - If `useReducedMotion()` is true: skip interval, set `displayedContent` to full `message.content` immediately
- [ ] **[TEST] CHAT-004B**: With `isStreaming=true`, content reveals incrementally; cursor present; `useReducedMotion=true` renders full content instantly

- [ ] **CHAT-004C**: New agent message entrance animation:
  - `<motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ type: 'spring', stiffness: 300, damping: 30 }}>`
  - Applied only when message role is `'assistant'` and the message is new (not loaded from history)
  - Skip animation when `useReducedMotion()` is true
- [ ] **[TEST] CHAT-004C**: New agent message has `y` and `opacity` animated; historical messages render without animation

- [ ] **CHAT-004D**: Message status indicator on user messages:
  - `status: 'sending'` → animated pulse dot (amber)
  - `status: 'sent'` → single checkmark (muted)
  - `status: 'error'` → red icon + "Retry" button that calls `sendMessage` with same content
- [ ] **[TEST] CHAT-004D**: Sending state shows pulse dot; error state shows retry button; clicking retry calls `sendMessage`

**MessageList:**

- [ ] **CHAT-004E**: Build `MessageList` component:
  - Consumes `messages` and `streamingState` from `useChatMessages`
  - Renders `MessageBubble` for each message (keyed by `clientMsgId`, not server ID)
  - Renders `TypingIndicator` when `showTypingIndicator` is true in reducer state
  - ARIA: `role="log"` + `aria-live="polite"` + `aria-label="Chat messages"` on scroll container
  - Date separators: group messages by day, render sticky date chip between groups
- [ ] **[TEST] CHAT-004E**: Message list renders all messages; typing indicator appears/disappears with state; date separators present between day groups

- [ ] **CHAT-004F**: Typing indicator:
  - Three dots using `<motion.span>` with `keyframes`: `animate={{ opacity: [0.3, 1, 0.3] }}`, `transition={{ repeat: Infinity, duration: 1.2, delay: index * 0.2 }}`
  - `useReducedMotion()` true → replace with static "…" text
- [ ] **[TEST] CHAT-004F**: Three spans rendered; each has staggered animation; reduced motion replaces with static text

### Definition of Done
- User and agent bubbles styled correctly; `React.memo` prevents unnecessary re-renders
- Streaming reveal works; cursor blinks; reduced motion respected
- New agent messages animate in; historical messages do not
- Message status (sending/sent/error) with retry
- Typing indicator with three animated dots
- ARIA live region and date separators present

### Anti-Patterns
- ❌ Keying messages by server-generated ID — causes remount when temp ID swaps; use `clientMsgId`
- ❌ `useState` for `displayedContent` inside streaming — causes extra renders; use `useRef` + direct DOM writes via `useEffect`
- ❌ Animating all messages including historical — entrance animation only for newly arriving messages
- ❌ Missing `React.memo` — parent re-renders (from reducer state) cascade into every bubble

---

## 📜 Task CHAT-005: Virtual Scroll & Scroll Behavior
**Priority:** 🔴 High
**Est. Effort:** 2 hours
**Depends On:** CHAT-004

### Related Files
`src/hooks/useChatScroll.ts` · `src/components/chat/MessageList.tsx` (integration)

> **Why dedicated task:** Virtual scrolling for a chat with potentially thousands of messages is not optional. TanStack Virtual with dynamic row heights (via `measureElement`) is the production-correct approach. The scroll anchoring contract (auto-scroll only if near bottom) is non-trivial to implement correctly and must be isolated.

### Subtasks

- [ ] **CHAT-005A**: Install `@tanstack/react-virtual`:
  ```sh
  pnpm add @tanstack/react-virtual@3.13.24
  ```

- [ ] **CHAT-005B**: Implement `useVirtualizer` in `MessageList`:
  ```ts
  const virtualizer = useVirtualizer({
    count: messages.length,
    getScrollElement: () => scrollRef.current,
    estimateSize: () => 80,           // Rough estimate; corrected by measureElement
    measureElement: (el) => el.getBoundingClientRect().height,
    overscan: 5,
    scrollMargin: scrollRef.current?.offsetTop ?? 0,
  })
  ```
  Render only `virtualizer.getVirtualItems()`. Use `virtualizer.measureElement` as `ref` on each message wrapper div so dynamic heights (long text, tool call disclosures, code blocks) are measured correctly.
- [ ] **[TEST] CHAT-005B**: Only visible items are in the DOM at any time; DOM node count stays constant as messages grow

- [ ] **CHAT-005C**: Create `src/hooks/useChatScroll.ts`:
  ```ts
  export function useChatScroll(virtualizer: Virtualizer, messages: Message[]) {
    const [userScrolled, setUserScrolled] = useState(false)
    const scrollRef = useRef<HTMLDivElement>(null)

    // Detect if user scrolled up
    const handleScroll = useCallback(() => {
      const el = scrollRef.current
      if (!el) return
      const distanceFromBottom = el.scrollHeight - el.scrollTop - el.clientHeight
      setUserScrolled(distanceFromBottom > 50)
    }, [])

    // Auto-scroll on new messages if user is at bottom
    useEffect(() => {
      if (!userScrolled && messages.length > 0) {
        virtualizer.scrollToIndex(messages.length - 1, { behavior: 'smooth' })
      }
    }, [messages.length, userScrolled])

    // Always scroll to bottom when user sends a message (regardless of scroll position)
    const scrollToBottom = useCallback(() => {
      setUserScrolled(false)
      virtualizer.scrollToIndex(messages.length - 1, { behavior: 'smooth' })
    }, [messages.length, virtualizer])

    return { scrollRef, handleScroll, scrollToBottom }
  }
  ```
- [ ] **[TEST] CHAT-005C**: Auto-scroll fires when user is within 50px of bottom; scroll position preserved when user is scrolled up; `scrollToBottom` resets `userScrolled` to false

- [ ] **CHAT-005D**: "Scroll to bottom" FAB: appears as a floating button (bottom-right of message area) when `userScrolled === true`. Click calls `scrollToBottom`. Animate in/out with `AnimatePresence`.
- [ ] **[TEST] CHAT-005D**: FAB appears when scrolled up; disappears when at bottom; click scrolls to bottom

- [ ] **CHAT-005E**: Load-more on scroll-to-top: when `virtualizer.range.startIndex === 0` and there is a previous page (from `useInfiniteQuery`), fetch next page. Show a loading spinner above oldest message during fetch. Implement scroll anchoring so fetching older messages does not jump the viewport.
- [ ] **[TEST] CHAT-005E**: Scrolling to top triggers older message fetch; viewport position is preserved after prepend

### Definition of Done
- TanStack Virtual renders only visible messages; dynamic row heights measured via `measureElement`
- Auto-scroll only when within 50px of bottom
- "Scroll to bottom" FAB visible when scrolled up
- Load-more on reaching top; scroll anchoring prevents viewport jump
- DOM node count is bounded regardless of conversation length

### Anti-Patterns
- ❌ `useEffect` + `scrollTop = scrollHeight` without virtual list — O(n) DOM nodes crash performance at 500+ messages
- ❌ `estimateSize` fixed too large — wastes whitespace; measure actual heights with `measureElement`
- ❌ `behavior: 'smooth'` on load-more prepend — causes visible jump; use instant scroll then restore position
- ❌ Forgetting `scrollMargin` — virtual items misalign when scroll container has offset from viewport top

---

## ⌨️ Task CHAT-006: ChatInput & LED Border
**Priority:** 🔴 High
**Est. Effort:** 1.5 hours
**Depends On:** CHAT-002

### Related Files
`src/components/chat/ChatInput.tsx`

### Subtasks

- [ ] **CHAT-006A**: Install `react-textarea-autosize`:
  ```sh
  pnpm add react-textarea-autosize
  ```

- [ ] **CHAT-006B**: Build `ChatInput` component:
  - `<TextareaAutosize minRows={1} maxRows={5} cacheMeasurements={true}>`
  - Controlled via `useChatReducer` `input` state; `SET_INPUT` on change
  - Send button (electric blue) — disabled when `input.trim() === ''` or `isStreaming`
  - Model selector dropdown (below input, left-aligned) — `selectedModel` from reducer, `SET_MODEL` on change. Mocked options: `['claude-sonnet', 'gpt-4o', 'gemini-pro']`
  - Attach file placeholder button (icon-only, right of textarea)
  - `aria-label="Message input"` on textarea
- [ ] **[TEST] CHAT-006B**: Textarea grows to max 5 rows; send button disabled when empty or streaming; model selector changes reducer state

- [ ] **CHAT-006C**: LED border effect:
  ```ts
  const [isFlashing, setIsFlashing] = useState(false)

  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key !== 'Enter') {
      setIsFlashing(true)
      setTimeout(() => setIsFlashing(false), 100)
    }
  }
  ```
  CSS:
  ```css
  .input-container {
    box-shadow: 0 0 0 1px oklch(62% 0.19 264 / 0.15);      /* resting */
    transition: box-shadow 80ms ease;
  }
  .input-container:focus-within {
    box-shadow: 0 0 0 2px oklch(62% 0.19 264 / 0.30);      /* focused */
  }
  .input-container.flashing {
    box-shadow: 0 0 0 2px oklch(62% 0.19 264 / 0.65);      /* keypress flash */
  }
  ```
- [ ] **[TEST] CHAT-006C**: Focus adds glow class; keypress adds flash class and removes it after 100ms

- [ ] **CHAT-006D**: Send behavior:
  - `Enter` (no modifier) → call `sendMessage(input)` → dispatch `RESET_INPUT` → call `scrollToBottom`
  - `Shift+Enter` → insert newline (default textarea behavior; do not prevent)
  - `Cmd/Ctrl+Enter` → also sends (power-user alias)
  - While streaming: Enter is blocked; send button is disabled; show "Stop" icon button that calls `abortStream()`
- [ ] **[TEST] CHAT-006D**: Enter sends and clears input; Shift+Enter inserts newline; Cmd+Enter sends; Enter blocked during streaming; Stop button visible during streaming

### Definition of Done
- Textarea auto-resizes 1–5 rows; `cacheMeasurements` enabled
- LED border glows on focus; flashes on keypress
- Enter sends; Shift+Enter newlines; Cmd+Enter sends; Stop button aborts stream
- Model selector and attach placeholder present

### Anti-Patterns
- ❌ Not using `cacheMeasurements` on `TextareaAutosize` — causes layout thrashing on every keystroke
- ❌ `onKeyPress` (deprecated) — use `onKeyDown`
- ❌ `setInterval` for flash timing — use `setTimeout` cleanup in state

---

## 📡 Task CHAT-007: Streaming — `useSSEStream` Hook
**Priority:** 🔴 High
**Est. Effort:** 2 hours
**Depends On:** CHAT-002, CHAT-006

### Related Files
`src/hooks/useSSEStream.ts`

> **Why dedicated task:** The streaming hook is the most complex and failure-prone piece of the chat system. It deserves isolation with full test coverage independently of UI components.

### Subtasks

- [ ] **CHAT-007A**: Create `src/hooks/useSSEStream.ts`:

  Signature:
  ```ts
  function useSSEStream(options: {
    threadId: string
    onToken: (token: string) => void
    onComplete: (usage: TokenUsage) => void
    onError: (err: Error) => void
  }): {
    startStream: (messageId: string) => void
    abortStream: () => void
    isStreaming: boolean
  }
  ```

  Internal contract:
  - `abortControllerRef = useRef<AbortController | null>(null)`
  - `startStream` creates a new `AbortController`, stores in ref, then calls `fetch('/api/threads/:id/stream', { signal })`
  - If called while stream is active, abort previous before starting new
  - Parse SSE lines: `data: {token}\n\n` → call `onToken`; `data: [DONE]\n\n` → call `onComplete`; `event: error` → call `onError`
  - Use `id:` field from SSE events; store as `lastEventIdRef`. Pass `Last-Event-ID` header on reconnect attempts
  - Reconnect: 3 attempts with exponential backoff (1s, 2s, 4s) on network error, not on deliberate abort
  - Cleanup: `useEffect(() => () => abortControllerRef.current?.abort(), [])` — abort on unmount
- [ ] **[TEST] CHAT-007A**: `startStream` fetches SSE endpoint; tokens call `onToken`; `[DONE]` calls `onComplete`; abort on unmount is called; reconnect fires on network error (not on abort)

- [ ] **CHAT-007B**: Parse streamed response with `ReadableStream` + `TextDecoder`:
  ```ts
  const reader = response.body!.getReader()
  const decoder = new TextDecoder()
  let buffer = ''

  while (true) {
    const { done, value } = await reader.read()
    if (done) break
    buffer += decoder.decode(value, { stream: true })
    const lines = buffer.split('\n')
    buffer = lines.pop() ?? ''  // Keep incomplete line in buffer
    for (const line of lines) {
      // Process SSE line
    }
  }
  ```
  Handle partial chunks (buffer incomplete lines); handle multi-line `data:` fields; handle `event:` prefix for named events.
- [ ] **[TEST] CHAT-007B**: Partial chunks reassemble correctly; multi-line data fields parsed; `AbortError` does not call `onError`

- [ ] **CHAT-007C**: Integrate with `useChatMessages` and `useChatReducer`:
  - On `sendMessage`: dispatch `START_STREAMING` (sets `isStreaming: true`, `streamingMessageId`)
  - Each `onToken`: use `queryClient.setQueryData` to append token to the streaming message's `content` in cache
  - `onComplete`: dispatch `END_STREAMING`; call `queryClient.invalidateQueries(chatKeys.messages(threadId))` to replace optimistic with server-confirmed message
  - `onError`: dispatch `END_STREAMING`; update message `status: 'error'`
- [ ] **[TEST] CHAT-007C**: Tokens accumulate in message cache; `END_STREAMING` fires on `[DONE]`; error state set on stream error; invalidation fires on complete

- [ ] **CHAT-007D**: Mock SSE handler in `src/mocks/handlers/chat.ts`:
  ```ts
  http.get('/api/threads/:id/stream', () => {
    const tokens = 'Hello from the assistant!'.split(' ')
    const stream = new ReadableStream({
      async start(controller) {
        for (const token of tokens) {
          controller.enqueue(`data: ${token}\n\n`)
          await delay(50)
        }
        controller.enqueue('data: [DONE]\n\n')
        controller.close()
      }
    })
    return new Response(stream, { headers: { 'Content-Type': 'text/event-stream' } })
  })
  ```
- [ ] **[TEST] CHAT-007D**: MSW stream handler delivers tokens at expected intervals; `[DONE]` triggers completion

### Definition of Done
- `useSSEStream` manages `AbortController` lifecycle; aborts on unmount and on new stream
- SSE chunks parsed correctly including partial chunks and named events
- `Last-Event-ID` header sent on reconnect; 3 retry attempts with backoff
- Tokens accumulate in TanStack Query cache; completion triggers invalidation
- MSW mock streams tokens reliably in test environment

### Anti-Patterns
- ❌ `EventSource` API — no support for custom headers (auth tokens); use `fetch` + `ReadableStream`
- ❌ Not aborting previous stream before starting new — concurrent streams corrupt message cache
- ❌ `AbortError` triggering `onError` — silently swallow abort, only report genuine failures
- ❌ Not buffering partial chunks — SSE lines fragmented across chunks will fail to parse

---

## 🔡 Task CHAT-008: Slash Command Menu
**Priority:** 🟠 Medium
**Est. Effort:** 1.5 hours
**Depends On:** CHAT-006

### Related Files
`src/components/chat/SlashMenu.tsx` · `src/data/slashCommands.ts`

### Subtasks

- [ ] **CHAT-008A**: Define `src/data/slashCommands.ts`:
  ```ts
  export const SLASH_COMMANDS = [
    { id: 'help',    label: '/help',    description: 'Show available commands' },
    { id: 'clear',   label: '/clear',   description: 'Clear current conversation' },
    { id: 'model',   label: '/model',   description: 'Switch AI model' },
    { id: 'export',  label: '/export',  description: 'Export conversation as Markdown' },
    { id: 'system',  label: '/system',  description: 'Set system prompt' },
  ]
  ```

- [ ] **CHAT-008B**: Build `SlashMenu` component:
  - `<AnimatePresence>` wraps menu; `initial={{ opacity: 0, y: 4 }}` → `animate={{ opacity: 1, y: 0 }}`, 100ms
  - Positioned `absolute bottom-full mb-1 left-0` relative to input container
  - Renders filtered `SLASH_COMMANDS` matching `slashQuery` from reducer
  - Highlighted index tracked in component state (not reducer — ephemeral UI state)
  - `role="listbox"` on container; `role="option"` + `aria-selected` on items
- [ ] **[TEST] CHAT-008B**: Menu renders with correct ARIA roles; filtering reduces visible options; animation present on mount

- [ ] **CHAT-008C**: Trigger logic in `ChatInput`:
  - `onKeyDown`: if key is `/` and `input === ''`, dispatch `OPEN_SLASH_MENU`, dispatch `SET_SLASH_QUERY('')`
  - On subsequent keystrokes while menu open, dispatch `SET_SLASH_QUERY(input.slice(1))`
  - `Escape` → dispatch `CLOSE_SLASH_MENU`
  - `ArrowUp` / `ArrowDown` → move highlighted index (wrap around)
  - `Enter` on highlighted item → execute command; dispatch `CLOSE_SLASH_MENU`; dispatch `RESET_INPUT`
- [ ] **[TEST] CHAT-008C**: `/` key in empty input opens menu; subsequent typing filters; Escape closes; ArrowDown highlights next; Enter selects command

- [ ] **CHAT-008D**: Close on outside click: `useEffect` adding `mousedown` listener on `document`; compare `event.target` against menu ref; close if outside. Cleanup on unmount.
- [ ] **[TEST] CHAT-008D**: Click outside menu closes it; click inside menu keeps it open

### Definition of Done
- Menu opens on `/` in empty input; filters on subsequent characters
- Keyboard navigation: arrows, Enter, Escape
- `AnimatePresence` fade in/out; correct ARIA roles
- Outside click closes menu

---

## 🔧 Task CHAT-009: ToolCallDisclosure
**Priority:** 🟠 Medium
**Est. Effort:** 1 hour
**Depends On:** CHAT-004

### Related Files
`src/components/chat/ToolCallDisclosure.tsx`

### Subtasks

- [ ] **CHAT-009A**: Build `ToolCallDisclosure` component:
  - Props: `toolCall: { name: string; input: Record<string, unknown>; output: unknown; durationMs?: number }`
  - Uses shadcn `Collapsible` for expand/collapse (headless, accessible)
  - Trigger: `[tool icon] {toolCall.name}` + `{durationMs}ms` badge (amber) + chevron
  - Collapsed: shows trigger only
  - Expanded: shows `input` JSON (syntax-highlighted, read-only `<pre>`), then `output` JSON
  - `role="group"` on container; `aria-label={Tool call: ${toolCall.name}}`
- [ ] **[TEST] CHAT-009A**: Disclosure renders tool name; click expands to show input/output JSON; click again collapses

- [ ] **CHAT-009B**: Chevron animation:
  ```tsx
  <motion.div
    animate={{ rotate: isOpen ? 180 : 0 }}
    transition={{ type: 'spring', stiffness: 300, damping: 30 }}
  >
    <ChevronDownIcon />
  </motion.div>
  ```
- [ ] **[TEST] CHAT-009B**: Chevron has `rotate: 180` when open; `rotate: 0` when closed; spring transition applied

- [ ] **CHAT-009C**: Render `ToolCallDisclosure` in `MessageBubble` for agent messages that have `message.toolCalls` array. Render each tool call sequentially below message text. Ensure the virtualizer's `measureElement` re-measures the bubble after disclosure expands (use `ResizeObserver` or trigger recheck on `isOpen` change).
- [ ] **[TEST] CHAT-009C**: Agent message with `toolCalls` renders disclosure(s); expanding disclosure does not clip content in virtual list

### Definition of Done
- Disclosure renders tool name, input/output JSON when expanded
- Chevron rotates with spring animation
- Multiple tool calls per message supported
- Virtual list re-measures row height on expand

---

## 🚩 Task CHAT-010: CheckpointBanner
**Priority:** 🟠 Medium
**Est. Effort:** 1 hour
**Depends On:** CHAT-002

### Related Files
`src/components/chat/CheckpointBanner.tsx`

### Subtasks

- [ ] **CHAT-010A**: Build `CheckpointBanner` component:
  - Props: `checkpoint: { id: string; description: string } | null`
  - Amber theme: `bg-amber-500/20 border border-amber-500/30 rounded-lg`
  - Content: warning icon, description text, "Approve" (primary) and "Reject" (secondary destructive) buttons
  - Positioned at top of chat area, above message list, below nav
  - `role="status"` + `aria-live="assertive"` + `aria-label="Agent requires approval"`
- [ ] **[TEST] CHAT-010A**: Banner renders when `checkpoint` is non-null; hidden when null; ARIA attributes present

- [ ] **CHAT-010B**: Entrance/exit animation with `AnimatePresence`:
  ```tsx
  <AnimatePresence>
    {checkpoint && (
      <motion.div
        key={checkpoint.id}
        initial={{ opacity: 0, y: -20, height: 0 }}
        animate={{ opacity: 1, y: 0, height: 'auto' }}
        exit={{ opacity: 0, y: -20, height: 0 }}
        transition={{ type: 'spring', stiffness: 300, damping: 30 }}
      >
        {/* banner content */}
      </motion.div>
    )}
  </AnimatePresence>
  ```
  `height: 0 → 'auto'` on enter prevents layout jump from banner pushing content down abruptly. Use `layout` prop on `MessageList` wrapper to animate the push.
- [ ] **[TEST] CHAT-010B**: Banner slides in on checkpoint appearance; slides out on resolution; `height` animates to prevent layout jump

- [ ] **CHAT-010C**: Approve → calls `useApproveCheckpoint(checkpoint.id)` mutation (optimistically clears banner); Reject → calls `useRejectCheckpoint(checkpoint.id)` mutation. Both trigger `queryClient.setQueryData` to null `checkpoint` in thread state immediately, with rollback on error.
- [ ] **[TEST] CHAT-010C**: Approve click immediately removes banner (optimistic); error restores it; Reject behaves identically

### Definition of Done
- Banner slides in/out with spring, including height animation
- Approve/Reject with optimistic dismiss and rollback
- `aria-live="assertive"` announces immediately to screen readers

### Anti-Patterns
- ❌ `aria-live="polite"` for checkpoint — approval is urgent; must use `assertive`
- ❌ Missing `height` animation — banner appearing/disappearing causes harsh layout reflow
- ❌ Missing `key={checkpoint.id}` on `motion.div` — `AnimatePresence` won't detect the element correctly across checkpoint changes

---

## 📊 Dependency Graph

```
CHAT-001 (Page Layout & Route)
     │
CHAT-002 (State, Query Config, MSW)
     │
     ├──────────────┬──────────────────────────────┐
     │              │                              │
CHAT-003       CHAT-004 (MessageBubble)       CHAT-010
(Thread List)       │                        (Checkpoint)
                    │
               CHAT-005 (Virtual Scroll)
                    │
               CHAT-006 (ChatInput)
                    │
               CHAT-007 (SSE Streaming)
                    │
        ┌───────────┴────────────┐
   CHAT-008                CHAT-009
 (SlashMenu)           (ToolCallDisclosure)
```

---

## 🏁 Chat Module Completion Checklist

**Layout & Routing:**
- [ ] `/chat` route renders two-column layout; thread list prefetched by loader
- [ ] Mobile: thread list in Sheet overlay
- [ ] Page transition fires on enter/exit with `AnimatePresence`

**State Management:**
- [ ] `chatKeys` factory typed and stable
- [ ] `messagesQueryOptions`: `staleTime: 0`, `gcTime: Infinity`
- [ ] `useSendMessage`: optimistic insert → error rollback → `onSettled` invalidation
- [ ] `crypto.randomUUID()` for `clientMsgId`; stable as React key across temp→server ID transition
- [ ] `useChatReducer`: all actions pure; covers all UI state transitions
- [ ] `useChatMessages`: composites query + reducer
- [ ] MSW handlers for all endpoints; `createWrapper` for hook tests

**Thread List:**
- [ ] Search non-blocking via `useTransition`
- [ ] Navigation via search params (not path params)
- [ ] "New Chat" optimistic with rollback; no virtualization

**Message Display:**
- [ ] User: charcoal right-aligned; Agent: glass left-aligned
- [ ] `React.memo` on `MessageBubble` with custom comparator
- [ ] Streaming reveal, blinking cursor, `useReducedMotion` respected
- [ ] New agent messages animate in; historical do not
- [ ] Message status: sending/sent/error with retry
- [ ] Date separators; typing indicator (three dots, reduced motion static fallback)
- [ ] `role="log"` + `aria-live="polite"` on container

**Virtual Scroll:**
- [ ] TanStack Virtual with `measureElement` for dynamic heights
- [ ] Auto-scroll only within 50px of bottom
- [ ] "Scroll to bottom" FAB with `AnimatePresence`
- [ ] Load-more on scroll-to-top with viewport scroll anchoring

**Chat Input:**
- [ ] `react-textarea-autosize` with `cacheMeasurements`
- [ ] LED border: glow on focus, 100ms flash on keypress
- [ ] Enter sends; Shift+Enter newlines; Cmd+Enter sends; Stop aborts during streaming
- [ ] Model selector; attach placeholder

**Streaming:**
- [ ] `useSSEStream` with `AbortController` in `useRef`
- [ ] Abort on unmount and on new stream
- [ ] Buffer partial chunks; parse named events; suppress `AbortError`
- [ ] `Last-Event-ID` on reconnect; 3 retries with backoff
- [ ] Tokens write to TanStack Query cache; completion invalidates

**Slash Commands:**
- [ ] Opens on `/` in empty input; filters on subsequent characters
- [ ] Arrow-key navigation; Enter selects; Escape closes
- [ ] Outside-click closes; `AnimatePresence` fade

**Tool Call Disclosure:**
- [ ] Collapsible with input/output JSON
- [ ] Chevron spring rotation
- [ ] Virtual list re-measures on expand

**Checkpoint Banner:**
- [ ] Spring slide-in/out including `height` animation
- [ ] Optimistic dismiss on Approve/Reject
- [ ] `aria-live="assertive"`

**Testing (global):**
- [ ] All custom hooks tested via `renderHook` + `createWrapper`
- [ ] All network calls intercepted by MSW handlers
- [ ] Each implementation subtask has a co-located `[TEST]` subtask covering its contract
- [ ] `pnpm test` passes for entire chat domain

# AI Command Center — Chat Module Enhanced Task List

**Researched & Strategically Organized — April 2026**

---

## Research Synthesis

Before presenting the enhanced task list, below is a consolidated summary of the research findings that inform every architectural and implementation decision in the tasks that follow.

### 1. Collaboration Canvas (Split-Pane Editing)

**Industry State:** ChatGPT Canvas uses a side-by-side paradigm where the left pane holds the chat conversation and the right pane is a "living document or codebase." The standout feature is **inline targeted editing** — users highlight specific text/code, and the AI revises *only that section* without regenerating the whole file. OpenAI's newer Interactive Code Blocks add a **diff-style split-screen view** showing exactly what lines are being added or removed before the user clicks "Apply."

**Claude Artifacts** takes a different approach: it renders structured outputs (HTML, SVG, React) in a live preview pane that updates in real-time. Artifacts regenerate the full artifact on each revision rather than tracking line-level edits.

**Key Technical Insight:** Canvas excels for document/code editing depth; Artifacts excels for interactive prototypes. Neither replaces full document collaboration tools like Google Docs. Both features are available only on paid plans (~$20/month).

**Implementation Guidance:**
- Use `@monaco-editor/react` + `vite-plugin-monaco-editor-esm` for Vite compatibility.
- For split-pane layout, use `react-resizable-panels` (by bvaughn, the same developer behind react-window) or `allotment` (built on the same codebase as VS Code's split view).
- For diff display: Monaco's built-in `createDiffEditor` for code; `react-diff-viewer` (supports split/unified view, word diff, line highlighting) for text.
- Apply pattern: generate diff → show preview → user clicks "Apply" → patch applied optimistically.

### 2. Live Artifacts (Sandboxed Rendering)

**Industry State:** Claude Artifacts run in a strictly sandboxed `<iframe>` hosted on a **separate origin** (`claudeusercontent.com`), preventing access to parent cookies, localStorage, or DOM. The sandbox uses `allow-scripts` but **disables `allow-same-origin`** to force a unique, unpredictable origin.

Claude employs a **Content Security Policy (CSP)** that blocks external CDN scripts, blocks `fetch()`/`XMLHttpRequest`, and only allows `data:`, `blob:`, or Anthropic-approved CDN resources for media.

**Security Architecture (from Huawei Cloud research):**
- **Principle of least privilege:** `sandbox="allow-scripts"` only — no `allow-same-origin`, no `allow-top-navigation`, no `allow-forms`
- **Dual defense:** CSP headers as second layer if sandbox is bypassed
- **Environment purification:** Freeze `Object.prototype`, proxy `window.open`, isolate global event listeners
- **Blob URL + iframe.src** is the recommended approach over `srcdoc` — Blob URLs have independent origin (`blob:` protocol), preventing access to parent page DOM or variables.

**For React rendering in-browser:** Use `@babel/standalone` to transpile JSX/TSX → JavaScript, then use `Blob` + `URL.createObjectURL` to create a module that the iframe loads. Import maps + `esm.sh` can provide React, ReactDOM, and other dependencies without a build step.

**Claude's pre-audited component stack:** React DOM (core engine), Tailwind CSS (styling), Radix Primitives (accessible UI), Lucide React (icons), DOMPurify (sanitization before render).

### 3. Version Snapshots & Checkpoints

**Industry State:** Claude Code's `/rewind` (or `/checkpoint`) command captures the file state before AI makes significant edits and allows restoring to any previous point. Checkpoints persist across sessions. They are designed for "fast, session-level recovery" and explicitly complement (not replace) Git for permanent version history.

**Implementation Pattern:**
- Zustand with `zeitstand` middleware: intercepts state changes, writes into a ring-buffer history, exposes `undo(steps?)` / `redo(steps?)`. ~1.6 KB min+gzip.
- Alternative: custom temporal middleware with deep cloning (`JSON.parse(JSON.stringify(state))`) for independent snapshots.
- Checkpoints should auto-create before each AI edit and allow manual creation with descriptions.

### 4. MCP Client Architecture

**Industry State:** MCP is the de facto standard for AI-tool connectivity, with 5,800+ available servers and 97M+ monthly SDK downloads. Adopted by Anthropic, OpenAI, Google, and Microsoft.

**Architecture:** Host → Client(s) → Server(s). Each client maintains a 1:1 stateful connection with a single MCP server. A host can spawn multiple clients.

**Four capability types exposed:** Resources (data the model reads), Tools (functions the model invokes), Prompts (reusable templates), Sampling (server-initiated LLM requests).

**For browser-based MCP clients:**
- `@hashangit/mcp-browser-client` — wraps official `@modelcontextprotocol/sdk` for browser use
- `mcp-lite` by Fiberplane — lightweight, works anywhere `Request`/`Response` are available
- **Important constraint:** The official `@modelcontextprotocol/sdk` requires Node.js ≥v18 — browser usage needs adaptation or wrapper libraries.
- **Production readiness:** MCP still has gaps being addressed (configuration portability, auth standardization, streaming transport). For MVP, mock the protocol layer and build the UI shell.

### 5. Client-Side RAG (Knowledge Base)

**Vector Database Options:**
- `client-vector-search` by shunnNet: plug-and-play, uses `@xenova/transformers` for embeddings (gte-small, ~30MB), stores vectors in IndexedDB, cosine similarity search.
- `@ruvector/rvlite`: full vector DB in WASM (~850KB), supports cosine/euclidean/dot product.
- PGlite + pgvector: WASM Postgres in browser with vector extension, stores in IndexedDB.

**Embedding Model:** `Xenova/all-MiniLM-L6-v2` is the standard choice — pre-trained sentence-transformers model converted to ONNX, runs efficiently in browser via WASM/WebGPU. Testing with 10,000 documents achieved query times of ~88ms.

**IndexedDB Storage:** Chrome allows up to 60% of free disk space (with user permission), Firefox ~2GB. Use `navigator.storage.estimate()` for quota monitoring. Chunk large files at 10MB for writes. Wrap with `localForage` or Dexie for simpler API.

**Security:** DOMPurify all user-provided text before storage and retrieval. Sanitize HTML content before rendering with `DOMPurify.sanitize()` + `html-react-parser` combo.

### 6. Agent-to-Agent (A2A) Flow Orchestrator

**Library:** `@xyflow/react` (React Flow v12+) — handles drag, connect, and all interactions. **Dagre** for automatic DAG layout positioning.

**Key patterns identified in research:**
- Each node type must export `<Handle>` components for edges to connect.
- Use Zustand for outside state accessible to nodes.
- When deleting nodes, ensure Dagre graph instance is also cleaned to prevent edge anomalies.
- Undo/redo with Zustand temporal middleware specifically for React Flow state.

---

## 🧱 Cross-Cutting Foundations (Apply to ALL Chat Tasks)

| ID | Area | Requirement |
|----|------|-------------|
| **CHAT-C01** | Message Cache SSOT | TanStack Query cache is the **only** source of truth for messages. No local `useState` message arrays. |
| **CHAT-C02** | Optimistic Updates | User messages added via `queryClient.setQueryData` in `onMutate`. Rollback on error via snapshot. `onSettled` (not `onSuccess`) triggers invalidation. |
| **CHAT-C03** | Stable React Keys | Optimistic messages use `clientMsgId` generated with `crypto.randomUUID()` **once** at send time. Never replaced with server ID. |
| **CHAT-C04** | Streaming Transport | SSE over `fetch` + `ReadableStream`. Not `EventSource` (no custom headers). Not WebSockets (unidirectional). |
| **CHAT-C05** | Stream Lifecycle | `AbortController` stored in `useRef`. Abort on unmount and on new message send. Suppress `AbortError` reporting. |
| **CHAT-C06** | Scroll Contract | Auto-scroll to bottom **only if** user is within 50px of bottom. Preserve position otherwise. |
| **CHAT-C07** | Cache Config | `staleTime: 0` + `gcTime: Infinity` for messages. |
| **CHAT-C08** | ARIA Live Regions | Message container: `role="log"` + `aria-live="polite"`. CheckpointBanner: `role="status"` + `aria-live="assertive"`. |
| **CHAT-C09** | Motion Guard | All animated components check `useReducedMotion()`. If true: skip character reveal, skip typing dots, skip spring transitions. |
| **CHAT-C10** | Test Infrastructure | All network calls mocked via MSW handlers. TanStack Query wrapped in `createWrapper()` helper. |

### Motion Tier Assignment

| Component | Tier | Technique |
|-----------|------|-----------|
| Thread list items | **Quiet** | `opacity` fade on mount, 150ms max, no stagger |
| MessageBubble (user) | **Static** | Instant render |
| MessageBubble (agent, new) | **Alive** | `opacity: 0→1`, `y: 10→0`, spring `stiffness: 300 damping: 30` |
| Streaming text | **Alive** | Character reveal ~20ms/char; blinking `|` cursor; suppressed when `useReducedMotion()` |
| Typing indicator | **Alive** | Three-dot `keyframes` opacity `[0.3, 1, 0.3]`, staggered delays |
| LED input border | **Alive** | `boxShadow` glow on focus; 100ms brightness flash on keypress |
| ToolCallDisclosure chevron | **Alive** | `rotate: isOpen ? 180 : 0`, spring |
| CheckpointBanner | **Alive** | `y: -20→0` with `AnimatePresence` |
| Slash command menu | **Quiet** | Opacity fade 100ms |
| Canvas pane resize handle | **Quiet** | `opacity` on hover, 150ms |
| Artifact iframe load | **Alive** | `opacity: 0→1`, `scale: 0.98→1`, spring |
| Snapshot list item | **Quiet** | Opacity fade 150ms |
| MCP tool status dot | **Alive** | Pulse keyframes (green=connected, amber=connecting, red=error) |
| Agent node drag overlay | **Alive** | Glowing, scaled card with spring follow |

---

## 📋 Strategic Task Organization

The 21 parent tasks below are organized into **six modules** reflecting the natural dependency chain and conceptual grouping:

| Module | Tasks | Description |
|--------|-------|-------------|
| **A: Chat Core** | CHAT-001 → CHAT-010 | Existing chat infrastructure (layout, state, messages, streaming, slash commands) |
| **B: Collaboration Canvas** | CHAT-011 → CHAT-013 | Split-pane editor, live artifact rendering, version snapshots |
| **C: Multimodal & MCP Foundation** | CHAT-014 → CHAT-017 | Media attachments, MCP settings UI, tool registry, terminal shell |
| **D: Knowledge & Memory** | CHAT-018 → CHAT-019 | Client-side RAG knowledge base, cross-conversation memory |
| **E: Agent Orchestration** | CHAT-020 → CHAT-021 | Agent studio builder, A2A DAG flow editor |

---

## 🗂️ Module A: Chat Core (CHAT-001 → CHAT-010)

> **Preserved verbatim from original spec.** These tasks remain unchanged and form the foundation for all new modules below. Refer to the existing `03-Chat` document for their full definitions.

---

## 🖊️ Module B: Collaboration Canvas

### Task CHAT-011: Collaboration Canvas — Split-Pane Editor, Diff Viewer & Inline Apply

**Priority:** 🔴 High
**Est. Effort:** 10 hours
**Depends On:** CHAT-001 (Chat Layout), CHAT-009 (ToolCallDisclosure)

**Why this matters:** ChatGPT Canvas and Claude Artifacts represent the state of the art in AI-human collaboration. Canvas focuses on inline editing with diff preview; Artifacts focuses on live rendering. This task implements the **Canvas pattern** (editor + diff + apply) that your command center currently lacks.

#### Research & Rationale

- ChatGPT Canvas opens a **side-by-side pane** where users highlight text and ask AI to revise specific sections without regenerating the whole file.
- OpenAI's newer Interactive Code Blocks add a **diff-style split-screen view** — the AI shows exactly what lines are added/removed before the user clicks "Apply."
- Claude Artifacts regenerates the full artifact on each revision; Canvas tracks line-level edits. Your implementation should support both patterns: full regeneration for new content, targeted diff+apply for edits.
- For the split-pane implementation, `react-resizable-panels` by bvaughn (same developer as react-window) provides accessible, flexible split-view layouts with min/max constraints. Alternative: `allotment`, built on VS Code's split view codebase.
- For diff display: Monaco Editor's built-in `createDiffEditor` for code files; `react-diff-viewer` for text/prose (supports split/unified view, word diff).
- Vite integration requires `vite-plugin-monaco-editor-esm` for worker resolution.

#### Related Files

`src/components/chat/CollaborationPane.tsx` · `src/components/chat/DiffPreview.tsx` · `src/components/chat/CanvasEditor.tsx` · `src/hooks/useCanvasState.ts` · `src/stores/canvasStore.ts`

#### Subtasks

- [ ] **CHAT-011A**: Install dependencies:
  ```sh
  pnpm add @monaco-editor/react react-resizable-panels react-diff-viewer vite-plugin-monaco-editor-esm
  ```
  Configure `vite-plugin-monaco-editor-esm` in `vite.config.ts`. Monaco workers must load correctly in Vite's ESM environment.

- [ ] **CHAT-011B**: Create `src/stores/canvasStore.ts` (Zustand):
  ```ts
  interface CanvasState {
    isOpen: boolean
    activeFileId: string | null
    files: Map<string, CanvasFile>  // keyed by fileId
    originalContent: string         // pre-edit snapshot
    currentContent: string
    diffView: 'split' | 'unified'
    mode: 'text' | 'code'
    language: string                // for syntax highlighting
  }
  ```
  Actions: `openCanvas`, `closeCanvas`, `setContent`, `applyEdit`, `rejectEdit`, `setMode`.

- [ ] **CHAT-011C**: Build `CollaborationPane.tsx`:
  - Wraps `react-resizable-panels` `<PanelGroup direction="horizontal">`
  - Left panel: existing ChatInterface (from CHAT-009)
  - Right panel: Canvas workspace (collapsible, default 50% width, min 320px)
  - Resize handle with `PanelResizeHandle` — subtle electric blue line, opacity on hover (Quiet tier)
  - Entrance animation: `<motion.div>` slides in from right, spring
  - Mobile (<768px): Canvas becomes a full-screen overlay (shadcn Sheet)

- [ ] **CHAT-011D**: Build `CanvasEditor.tsx`:
  - **Code mode:** `<MonacoEditor>` with language detection, minimap disabled (saves space), theme `vs-dark` matching your `#050507` background
  - **Text mode:** `<MonacoEditor language="markdown">` with word wrap enabled, or a simple `<TextareaAutosize>` with markdown preview toggle
  - Read-only by default. Double-click to enter edit mode (user edits). AI edits arrive as diffs.
  - "AI Edit" indicator: amber pulsing dot when AI is generating an edit

- [ ] **CHAT-011E**: Build `DiffPreview.tsx`:
  - Renders when `canvasStore` has `originalContent !== currentContent` (AI has proposed an edit)
  - **Code:** Monaco `DiffEditor` with `original` (left) and `modified` (right), `renderSideBySide: true`
  - **Text:** `react-diff-viewer` with `splitView={true}`, dark theme matching your palette, line highlighting
  - Action bar at bottom: "Apply" (primary, electric blue) and "Reject" (secondary, destructive) buttons
  - Apply → `queryClient.setQueryData` to overwrite file content optimistically
  - "Apply" button uses `whileHover` glow (Alive tier)

- [ ] **CHAT-011F**: Wire Canvas into ChatInterface:
  - Agent messages containing `message.type === 'canvas_edit'` or `message.canvasFileId` trigger Canvas open
  - When user highlights text in Canvas and sends a chat message, the selection context is included in the prompt
  - "Edit in Canvas" button on relevant agent messages opens the targeted file

- [ ] **CHAT-011G**: Error boundary:
  - Wrap Canvas in `react-error-boundary` `<ErrorBoundary FallbackComponent={CanvasErrorFallback}>`
  - On Monaco render error, show recovery UI with "Reload Editor" button. Never crash the entire chat page.
  - Store unsaved content in `canvasStore` before error boundary triggers so work is not lost.

- [ ] **[TEST] CHAT-011A-G**: Canvas opens on agent message with `canvas_edit` type; diff preview shows original vs modified; Apply updates content; Reject reverts; resize handle works; error boundary catches Monaco crash and shows recovery UI.

#### Definition of Done

- Split-pane layout renders Canvas alongside chat
- Monaco Editor integrated for code with syntax highlighting
- Diff preview shows side-by-side changes with line-level highlighting
- Apply/Reject mutations update content optimistically
- Canvas works on desktop; mobile gets full-screen Sheet fallback
- Error boundary prevents editor crashes from taking down the chat

#### Anti-Patterns

- ❌ Forgetting `vite-plugin-monaco-editor-esm` — Monaco workers fail silently in Vite
- ❌ Using `srcdoc` for rendered previews — use Blob URL + iframe.src for security isolation
- ❌ Not storing unsaved content before error boundary triggers — user loses work
- ❌ Rendering diff for every message — only when `originalContent !== currentContent`
- ❌ Using `allow-same-origin` on preview iframes — defeats sandbox isolation

---

### Task CHAT-012: Live Artifacts — Sandboxed React/SVG Rendering Engine

**Priority:** 🔴 High
**Est. Effort:** 10 hours
**Depends On:** CHAT-011 (Canvas)

**Why this matters:** Claude Artifacts renders HTML, React, and SVG in a live preview pane. This is what turns your command center from a text-display tool into a **visual creation studio**. Users can ask the AI to build dashboards, charts, interactive components, and see them rendered immediately.

#### Research & Rationale

- Claude Artifacts uses a **cross-origin iframe** hosted on a separate domain (`claudeusercontent.com`) with strict `sandbox="allow-scripts"` (no `allow-same-origin`).
- Security is the #1 concern. Research identifies four layers: (1) sandbox attributes, (2) CSP headers, (3) environment purification (freeze prototypes, proxy dangerous APIs), (4) DOMPurify sanitization.
- **Blob URL + iframe.src** is the recommended approach over `srcdoc`. Blob URLs create an independent origin (`blob:` protocol), preventing access to parent page DOM or variables.
- For React rendering: Claude pre-audits a component stack — React DOM, Tailwind CSS, Radix Primitives, Lucide React, DOMPurify. Model generates code using only these whitelisted libraries.
- `@babel/standalone` transpiles JSX/TSX to JavaScript in-browser. Import maps + `esm.sh` provide React dependencies without a build step.
- **Critical CSP restriction:** Block external `fetch()`, `XMLHttpRequest`, and external CDN scripts. Only allow `data:` URIs, `blob:` URIs, and approved CDN resources.

#### Related Files

`src/components/chat/ArtifactPreview.tsx` · `src/components/chat/ArtifactSandbox.tsx` · `src/lib/artifactCompiler.ts` · `src/lib/sandboxTemplate.ts`

#### Subtasks

- [ ] **CHAT-012A**: Create `src/lib/sandboxTemplate.ts`:
  - Generates a complete HTML document string for the iframe
  - Includes import map pointing to `esm.sh` for React, ReactDOM, Tailwind CSS (via CDN), Lucide React, Radix Primitives
  - Includes inline `<script type="module">` that imports and renders the user's component
  - Applies CSP via `<meta http-equiv="Content-Security-Policy">`:
    ```
    default-src 'self';
    script-src 'self' https://esm.sh https://cdn.jsdelivr.net;
    style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net;
    img-src data: blob: https:;
    connect-src 'none';
    frame-src 'none';
    ```
  - Environment purification script: freeze `Object.prototype`, proxy `window.open`, proxy `console.log` to `postMessage`

- [ ] **CHAT-012B**: Create `src/lib/artifactCompiler.ts`:
  - Accepts raw code string (JSX/TSX) and artifact type (`react`, `svg`, `html`, `markdown`)
  - For `react` type: uses `@babel/standalone` `transform(code, { presets: ['react', 'typescript'] })` to produce JavaScript
  - Extracts the default export component name
  - Wraps in `ReactDOM.createRoot(document.getElementById('root')).render(<Component />)`
  - Sanitizes output with DOMPurify before injecting
  - Returns the complete HTML document string

- [ ] **CHAT-012C**: Build `ArtifactSandbox.tsx`:
  - Creates an `<iframe>` with `sandbox="allow-scripts"` (no `allow-same-origin`, no `allow-forms`, no `allow-top-navigation`)
  - Uses `URL.createObjectURL(new Blob([htmlDoc], { type: 'text/html' }))` as `src` — NOT `srcdoc`
  - Revokes previous Blob URL on content change to prevent memory leaks
  - Listens for `postMessage` from sandbox for: console output, runtime errors, React render completion
  - Loading state: skeleton placeholder matching iframe dimensions
  - Error state: "Preview failed to render" with error details in collapsible section
  - Entrance animation: `opacity: 0→1`, `scale: 0.98→1`, spring (Alive tier)

- [ ] **CHAT-012D**: Build `ArtifactPreview.tsx`:
  - Integrates into CollaborationPane as a view mode toggle: "Editor" | "Preview" | "Split" (editor left, preview right)
  - "Split" mode uses nested `react-resizable-panels` within the Canvas panel
  - Toolbar above preview: refresh button, "Open in new tab" (opens Blob URL), copy code button, view source toggle
  - For `svg` and `markdown` types: renders directly (no sandbox needed) using `dangerouslySetInnerHTML` with DOMPurify

- [ ] **CHAT-012E**: Wire agent-generated artifacts:
  - When agent message contains `message.type === 'artifact'` or MIME type like `application/vnd.ant.react`, extract code and render in ArtifactPreview
  - Agent tool calls that produce code (`write_file`, `generate_component`) automatically trigger Artifact preview
  - Regenerate on each revision (Artifacts pattern), or target-edit specific sections (Canvas pattern) — user preference stored in `canvasStore`

- [ ] **CHAT-012F**: Security hardening:
  - DOMPurify ALL code before injection into sandbox template
  - Validate that generated code only imports from whitelisted packages (check import statements)
  - Monitor `navigator.storage.estimate()` to prevent Blob URL memory exhaustion
  - Add `X-Content-Type-Options: nosniff` to sandbox template headers (via meta tag)

- [ ] **[TEST] CHAT-012A-F**: ArtifactPreview renders React component in sandboxed iframe; `postMessage` captures console output; error state displays on broken code; Blob URL is revoked on content change; DOMPurify strips malicious scripts.

#### Definition of Done

- Sandboxed iframe renders AI-generated React components, SVG, HTML, and Markdown
- CSP and sandbox attributes provide defense-in-depth security
- `@babel/standalone` transpiles JSX in-browser
- Split view (Editor + Preview) works within Canvas
- Artifact preview auto-triggers on agent code generation
- All code sanitized via DOMPurify before injection

#### Anti-Patterns

- ❌ Using `srcdoc` attribute — inherits parent origin; use Blob URL + `src`
- ❌ Adding `allow-same-origin` to sandbox — defeats cross-origin isolation
- ❌ Forgetting `URL.revokeObjectURL()` — memory leak on every re-render
- ❌ Allowing external `fetch()` in CSP — data exfiltration vector
- ❌ Rendering without DOMPurify — XSS risk from AI-generated code

---

### Task CHAT-013: Canvas Version Snapshots & Rollback

**Priority:** 🟠 Medium
**Est. Effort:** 4 hours
**Depends On:** CHAT-011 (Canvas)

**Why this matters:** Claude Code's `/rewind` checkpoint feature auto-captures file state before every AI edit, allowing users to rewind to any point. This is a trust-building UX pattern — users experiment more freely when they know they can always undo.

#### Research & Rationale

- Claude Code checkpoints persist across sessions and are designed for "fast, session-level recovery." They explicitly complement Git rather than replace it.
- Zustand `zeitstand` middleware provides undo/redo with ring-buffer history (~1.6 KB min+gzip).
- Alternative: custom temporal middleware with `JSON.parse(JSON.stringify(state))` for deep-cloned snapshots.
- Auto-checkpoint before each AI edit + manual checkpoint creation.

#### Related Files

`src/stores/canvasStore.ts` (extend) · `src/components/chat/SnapshotList.tsx` · `src/hooks/useCanvasSnapshots.ts`

#### Subtasks

- [ ] **CHAT-013A**: Extend `src/stores/canvasStore.ts` with snapshot history:
  - Add `snapshots: CanvasSnapshot[]` array: `{ id, timestamp, description, content, fileId }`
  - `MAX_SNAPSHOTS = 50` (ring buffer: oldest evicted when limit reached)
  - Actions: `createSnapshot(description?)`, `restoreSnapshot(id)`, `clearSnapshots()`
  - Auto-create snapshot in `applyEdit` action before content is overwritten
  - Deep clone content with `structuredClone()` (modern, faster than JSON parse/stringify)

- [ ] **CHAT-013B**: Build `SnapshotList.tsx`:
  - Vertical timeline sidebar (collapsible, 200px) within Canvas
  - Each snapshot: relative timestamp, optional description, preview of first 80 chars
  - "Restore" button on hover (Quiet tier opacity fade)
  - Current active snapshot highlighted with electric blue left border (using `layoutId` for smooth pill animation)
  - Empty state: "No snapshots yet. Edits will be automatically saved."

- [ ] **CHAT-013C**: Restore flow:
  - Clicking "Restore" shows confirmation dialog: "This will replace current content. Unsaved changes will be lost."
  - On confirm: current content saved as a new snapshot first (so restore is itself undoable), then content replaced
  - Visual feedback: brief flash animation on restored content area (Alive tier)

- [ ] **CHAT-013D**: Integration with DiffPreview:
  - When a snapshot is restored, the diff view shows: snapshot content (left) vs current (right)
  - User can partially restore (cherry-pick changes) — future enhancement, not MVP

- [ ] **[TEST] CHAT-013A-D**: Snapshot auto-created on AI edit apply; restore reverts content correctly; snapshot list displays chronologically; restoring creates a new snapshot first (undoable).

#### Definition of Done

- Auto-snapshots created before each AI edit is applied
- Manual snapshot creation via button in Canvas toolbar
- Snapshot list shows chronological timeline with previews
- Restore replaces content and creates a new snapshot (undoable restore)
- Ring buffer limits to 50 snapshots

#### Anti-Patterns

- ❌ Not deep-cloning snapshots — mutations to current state corrupt history
- ❌ Using `JSON.parse(JSON.stringify())` for `structuredClone`-able objects — slower and loses `Date`, `undefined`, etc.
- ❌ Restoring without first saving current state — makes restore irreversible
- ❌ Unbounded snapshot array — memory leak

---

## 🎙️ Module C: Multimodal & MCP Foundation

### Task CHAT-014: Media Attachments — File Upload, Image Preview & In-Context Editing

**Priority:** 🟠 Medium
**Est. Effort:** 4 hours
**Depends On:** CHAT-006 (ChatInput)

**Why this matters:** ChatGPT has true multimodal input (images, audio, video). Claude excels at image/PDF understanding. Your command center currently has no attachment capability — users can only send text. This task closes that gap.

#### Research & Rationale

- `react-dropzone` is the standard React library for drag-and-drop file uploads (10K+ GitHub stars). Provides `useDropzone` hook with `onDrop` callback, file validation, and preview support.
- For image previews: use `URL.createObjectURL(file)` for local preview; revoke with `URL.revokeObjectURL()` on unmount.
- Client-side image resizing: **Jimp** (JavaScript Image Manipulation Program) runs entirely in-browser with no native dependencies. Supports resize, crop, rotate, and format conversion. Use `@jimp/plugin-resize` for `resize()` and `scale()` methods.
- File type validation: whitelist by MIME type and extension. Max file size configurable.
- For MVP: send files as base64 data URIs in message payload (mock). Real implementation will use multipart upload.

#### Related Files

`src/components/chat/AttachmentZone.tsx` · `src/components/chat/ImagePreview.tsx` · `src/hooks/useFileUpload.ts` · Extend `ChatInput.tsx`

#### Subtasks

- [ ] **CHAT-014A**: Install dependencies:
  ```sh
  pnpm add react-dropzone jimp
  ```

- [ ] **CHAT-014B**: Build `AttachmentZone.tsx`:
  - Wraps `useDropzone` with `accept` config: images (png, jpeg, gif, webp, svg), documents (pdf, txt, md), code files
  - Drag-over visual: dashed electric blue border, subtle background glow (Alive tier)
  - File validation: max 25MB per file, max 5 files per message
  - Error toast for rejected files with reason (size, type)
  - Click to open file picker as fallback

- [ ] **CHAT-014C**: Build `ImagePreview.tsx`:
  - Thumbnail grid below chat input when files are attached
  - Each thumbnail: image preview (via `URL.createObjectURL`), file name, size, remove button
  - Click thumbnail → lightbox modal with full-resolution preview
  - Remove button: revokes object URL, removes from attachment list

- [ ] **CHAT-014D**: Integrate into `ChatInput.tsx`:
  - Replace the "Attach file placeholder button" from CHAT-006B with functional `AttachmentZone`
  - Attach button opens dropzone dialog on click
  - Attached files appear as chips below the textarea before send
  - On send: files serialized as `{ name, type, size, dataUrl }` in message payload
  - File chips animate in with spring stagger (Alive tier)

- [ ] **CHAT-014E**: Image resizing (optional optimization):
  - If image > 2MB, auto-resize client-side using Jimp before encoding
  - Max dimensions: 2048px on longest edge
  - Show "Resizing..." indicator during processing
  - Preserve aspect ratio, use `RESIZE_BILINEAR` for quality

- [ ] **[TEST] CHAT-014A-E**: Drag-and-drop adds file to preview; invalid files rejected with toast; image preview renders; remove button clears file; attached files appear in message payload; Jimp resizes large images.

#### Definition of Done

- Drag-and-drop file upload working in ChatInput
- Image previews with remove capability
- File type and size validation
- Integration with message send pipeline
- Optional client-side image resizing

#### Anti-Patterns

- ❌ Not revoking `URL.createObjectURL` — memory leak
- ❌ Sending raw files without size limits — browser memory crash
- ❌ Blocking UI during image processing — use Web Worker or show progress
- ❌ Not sanitizing file names — path traversal risk

---

### Task CHAT-015: MCP Integration — Settings UI & Tool Registry

**Priority:** 🔴 High
**Est. Effort:** 6 hours
**Depends On:** CHAT-001 (Layout), TASK-005 (Hooks/Stores)

**Why this matters:** MCP is the "USB-C of AI integrations" — 5,800+ servers, 97M+ monthly SDK downloads, adopted by Anthropic, OpenAI, Google, and Microsoft. Without MCP, your command center cannot connect to Gmail, GitHub, Slack, or any external tool. This task builds the **frontend configuration shell**; the real protocol client will be wired in a future Agent Backend phase.

#### Research & Rationale

- MCP uses a **client-server architecture** with JSON-RPC 2.0. The **Host** is the application (your command center). The **Client** maintains a 1:1 connection with each MCP server. **Servers** expose Resources, Tools, and Prompts.
- For browser-based MCP: `@hashangit/mcp-browser-client` wraps the official `@modelcontextprotocol/sdk` for browser use. The official SDK requires Node.js ≥v18; browser usage needs adaptation.
- MCP is still evolving — streaming transport is being standardized, configuration portability and OAuth are active roadmap items. For MVP, build a **mocked UI shell** with clear "Out of Scope" markers for real connectivity.
- The Settings UI should show: connected servers, available tools per server, connection status, and test-connection capability.
- **Critical UX pattern from research:** MCP recommends **explicit user consent for tool invocations** — the host application must enforce this, as the protocol itself does not.

#### Related Files

`src/components/chat/MCPSettingsPanel.tsx` · `src/components/chat/MCPServerCard.tsx` · `src/components/chat/ToolRegistryList.tsx` · `src/stores/mcpStore.ts` · `src/hooks/useMCPTools.ts`

#### Subtasks

- [ ] **CHAT-015A**: Create `src/stores/mcpStore.ts` (Zustand):
  ```ts
  interface MCPState {
    servers: MCPServerConfig[]
    connectedTools: MCPTool[]
    isConnecting: boolean
    activeServerId: string | null
  }
  ```
  Actions: `addServer`, `removeServer`, `toggleServer`, `testConnection`, `refreshTools`

- [ ] **CHAT-015B**: Create `src/hooks/useMCPTools.ts` (mock):
  - Returns tools grouped by server: `{ serverId, serverName, tools: MCPTool[] }[]`
  - Mock data: GitHub (create_issue, list_prs, search_code), Slack (send_message, list_channels), Postgres (query_db), Filesystem (read_file, write_file, list_directory)
  - Each tool: `{ name, description, inputSchema: JSONSchema }` — matches MCP spec
  - Tools cached with `staleTime: 5 * 60 * 1000` (5 min) — tools don't change frequently

- [ ] **CHAT-015C**: Build `MCPServerCard.tsx`:
  - Server name, description, version, connection status indicator
  - Status dot: green pulsing (connected), amber (connecting), red (error/disconnected), gray (disabled) — Alive tier pulse animation
  - Tool count badge: "12 tools available"
  - Toggle switch for enable/disable
  - "Configure" button → opens modal with API key field (masked), transport type selector (stdio/SSE/streamable HTTP), server URL
  - "Test Connection" button → mock async call → success/failure toast
  - "Remove" button with confirmation

- [ ] **CHAT-015D**: Build `MCPSettingsPanel.tsx`:
  - Full-page or modal view accessible from Chat toolbar (⚙️ icon) and Settings page
  - "Add Server" button → modal with: name, transport type, URL/command, API key (optional), auto-connect toggle
  - Server list/grid of `MCPServerCard` components
  - Empty state: "No MCP servers connected. Add a server to give your agents access to external tools."
  - Pre-built server templates: "GitHub", "Linear", "Slack", "PostgreSQL", "Filesystem" — clicking pre-fills form

- [ ] **CHAT-015E**: Build `ToolRegistryList.tsx`:
  - Expandable list of all available tools across all connected servers
  - Grouped by server name
  - Each tool: name, description, input schema preview (first 3 params), "Test" button
  - Search/filter by tool name or description
  - "Test" button opens mini-playground: JSON editor for input, "Run" button, output display

- [ ] **CHAT-015F**: Wire MCP Tools into Chat:
  - Tool availability indicator in ChatInput: "12 tools available" badge
  - When user sends message, available tools are included in context (mock)
  - Tool call results displayed in existing `ToolCallDisclosure` component (from CHAT-009)

- [ ] **[TEST] CHAT-015A-F**: Server card shows correct status dot; toggle enables/disables; test connection shows toast; tool list filters; add server form validates; empty state renders when no servers.

#### Definition of Done

- MCP server CRUD UI with configuration modals
- Tool registry displaying all available tools grouped by server
- Connection status indicators with animated pulses
- Search/filter for tools
- Integration with existing Chat and ToolCallDisclosure
- All data mocked; real MCP connectivity deferred to Agent Backend phase

#### Out of Scope
- Real MCP protocol client (stdio spawning, JSON-RPC communication, transport layer)
- Actual tool execution — mock only
- OAuth 2.1 flow for MCP server authentication

#### Anti-Patterns

- ❌ Building real MCP client in the browser directly — stdio transport requires Node.js child processes
- ❌ Storing API keys in plain text in Zustand — mask in UI, encrypt in storage (future)
- ❌ Auto-executing tools without user consent — MCP spec recommends explicit approval for write operations
- ❌ Assuming all tools are safe — implement tool-level approval prompts (future)

---

### Task CHAT-016: Agent Terminal & Activity Replay (MCP Shell)

**Priority:** 🟠 Medium
**Est. Effort:** 5 hours
**Depends On:** CHAT-015 (MCP Settings)

**Why this matters:** Claude Code shows a terminal view of every command the AI executes, with ANSI-colored output and timestamps. ChatGPT's new "Computer Use" feature gives visual feedback when the agent is controlling the screen. Users need to **see what the AI is doing** to build trust in autonomous operations.

#### Research & Rationale

- Claude Code's terminal shows: command executed, stdout, stderr, exit code, duration, timestamp
- ChatGPT's Operator feature shows a visual replay of browser actions
- For MVP: a mocked terminal UI showing agent tool calls as if they were terminal commands
- ANSI color support: use a simple parser or render raw text with monospace font
- Activity replay: chronological log with expandable entries, filter by agent/server

#### Related Files

`src/components/chat/AgentTerminal.tsx` · `src/components/chat/TerminalEntry.tsx` · `src/hooks/useAgentActivity.ts`

#### Subtasks

- [ ] **CHAT-016A**: Build `AgentTerminal.tsx`:
  - Collapsible panel below chat or in RightPanel
  - Dark terminal aesthetic: `bg-[#0a0a0a]`, monospace font (JetBrains Mono or system monospace), green/white text
  - Header: "Agent Terminal" title, connection status, clear button, filter dropdown (All/Tool Calls/Errors/System)
  - Scrollable log area with auto-scroll to bottom (reuse scroll contract logic from CHAT-C06)
  - **Virtualisation required**: Use `react-window` for >50 entries
  - Entrance animation: slides up from bottom, spring (Alive tier)

- [ ] **CHAT-016B**: Build `TerminalEntry.tsx`:
  - Each entry: `[timestamp] [agent-icon] [server] $ {command/tool_name}`
  - Expandable: click to show full input JSON and output
  - Status indicators: ✓ (success, green), ✗ (error, red), ⏳ (running, amber pulse)
  - Duration badge: "2.3s" in muted text
  - Collapse animation: chevron rotation, spring (Alive tier, same as ToolCallDisclosure)

- [ ] **CHAT-016C**: Create `src/hooks/useAgentActivity.ts` (mock):
  - Returns chronological activity log
  - Each entry: `{ id, timestamp, agentId, serverId, toolName, input, output, status, duration }`
  - Mock data: 20-30 entries simulating a real agent session
  - Filter by agent, server, tool name, status

- [ ] **CHAT-016D**: Wire into existing Dashboard ActivityFeed:
  - AgentTerminal is a **more detailed** view of the ActivityFeed from DASH-006
  - "Open in Terminal" button on ActivityFeed entries opens AgentTerminal scrolled to that entry
  - Terminal entries share the same data source as ActivityFeed but render with more detail

- [ ] **[TEST] CHAT-016A-D**: Terminal renders mock activity entries; expand shows input/output; filter works; virtualisation handles 100+ entries; status indicators animate correctly.

#### Definition of Done

- Terminal panel with dark theme and monospace font
- Chronological log of agent tool calls with status indicators
- Expandable entries showing full input/output
- Filterable by type and status
- Virtualised for performance with large logs
- Integration with Dashboard ActivityFeed

#### Out of Scope
- Real process spawning and stdout capture
- Actual ANSI escape code parsing (plain text only for MVP)
- Remote agent monitoring (all data is local mock)

#### Anti-Patterns

- ❌ Not virtualising the log — 1000+ entries will crash the browser
- ❌ ANSI parsing without sanitization — injection risk
- ❌ Auto-scrolling when user is reading older entries — reuse scroll contract

---

### Task CHAT-017: Slash Command Toolbar — MCP Tool Discovery

**Priority:** 🟠 Medium
**Est. Effort:** 3 hours
**Depends On:** CHAT-008 (SlashMenu), CHAT-015 (MCP Settings)

**Why this matters:** When MCP servers are connected, users need to **discover** what tools are available. The slash command menu (typing `/` in empty input) is the natural discovery surface. Claude's UI shows available tools in a dropdown; your slash menu should do the same.

#### Research & Rationale

- Extends existing CHAT-008 SlashMenu pattern
- Tools from MCP servers populate the menu dynamically
- Grouped by server for clarity
- Claude shows tool descriptions inline; follow this pattern

#### Related Files

`src/components/chat/SlashMenu.tsx` (extend) · `src/data/slashCommands.ts` (extend) · `src/hooks/useMCPTools.ts` (consume)

#### Subtasks

- [ ] **CHAT-017A**: Extend `src/data/slashCommands.ts`:
  - Add `source: 'built-in' | 'mcp'` field to command objects
  - Built-in commands remain as defined in CHAT-008A
  - MCP tools are injected dynamically from `useMCPTools()` hook

- [ ] **CHAT-017B**: Extend `SlashMenu.tsx`:
  - Merge built-in commands + MCP tools into single filtered list
  - Group by source: "Commands" section (built-in), then per-server sections (e.g., "GitHub Tools", "Slack Tools")
  - Each MCP tool item shows: `/{tool.name}` label, tool description (truncated), server badge (small pill)
  - Server badge uses distinct color per server (auto-assigned from palette)
  - Keyboard navigation works across all groups seamlessly
  - Selected item highlighted with electric blue (same as existing)

- [ ] **CHAT-017C**: Tool execution on select:
  - Selecting an MCP tool inserts `/{tool.name} ` into input and shows the tool's input schema as a placeholder
  - Example: selecting `/github_create_issue` shows placeholder "repo: owner/name | title: ... | body: ..."
  - User fills in parameters in natural language; AI parses them before tool call
  - Showing input schema reduces errors and teaches the user the tool's interface

- [ ] **[TEST] CHAT-017A-C**: Slash menu shows built-in + MCP tools grouped by source; selecting MCP tool inserts command with placeholder; keyboard navigation works across groups; server badges render with distinct colors.

#### Definition of Done

- Slash menu dynamically includes MCP tools from connected servers
- Tools grouped by server with colored badges
- Selecting a tool shows input schema placeholder
- Keyboard navigation works across built-in and MCP groups

#### Anti-Patterns

- ❌ Duplicating the slash menu component — extend the existing one
- ❌ Not debouncing the tool list fetch — MCP tools change rarely, cache aggressively
- ❌ Showing all tools without grouping — becomes unusable with 50+ tools

---

## 🧠 Module D: Knowledge & Memory

### Task CHAT-018: Personal Knowledge Base — Client-Side RAG Engine

**Priority:** 🔴 High
**Est. Effort:** 14 hours
**Depends On:** TASK-003 (UI Components), TASK-005 (Hooks/Stores)

**Why this matters:** Claude Projects allows users to upload a 50MB knowledge library that gets ingested into a vector DB and referenced automatically in conversations. ChatGPT has cross-chat memory. Without a knowledge base, your AI only knows what's in the current conversation context. This task implements a **fully client-side RAG system** using in-browser embeddings and vector search — no server required.

#### Research & Rationale

- **Embedding model:** `Xenova/all-MiniLM-L6-v2` via `@xenova/transformers`. This is the standard choice — pre-trained sentence-transformers model converted to ONNX, runs efficiently in browser via WASM/WebGPU. Model size ~30MB.
- **Vector storage/search:** `client-vector-search` by shunnNet — production-tested, 10K documents at ~88ms query time, uses IndexedDB for persistence, cosine similarity.
- **IndexedDB wrapper:** `localForage` for simple key-value API with IndexedDB backend. Falls back to WebSQL/localStorage if IndexedDB unavailable. Alternative: Dexie for more powerful querying.
- **Storage quota:** Chrome ~60% of free disk (with permission), Firefox ~2GB default. Monitor with `navigator.storage.estimate()`.
- **Chunking:** Recursive text splitter pattern: split by paragraph → sentence → word, with overlap (10-15%) to preserve context across boundaries.
- **Security:** DOMPurify all user-provided text before embedding and storage. Sanitize retrieved content before display.
- **Production benchmark:** 10,000-document index with optimized in-browser vector search achieved query times of 88ms.

#### Related Files

`src/components/knowledge/KnowledgeBasePanel.tsx` · `src/components/knowledge/FileUploadZone.tsx` · `src/components/knowledge/DocumentList.tsx` · `src/lib/embeddingEngine.ts` · `src/lib/vectorStore.ts` · `src/lib/textChunker.ts` · `src/hooks/useKnowledgeBase.ts` · `src/stores/knowledgeStore.ts`

#### Subtasks

- [ ] **CHAT-018A**: Install dependencies:
  ```sh
  pnpm add @xenova/transformers client-vector-search localforage dompurify
  ```

- [ ] **CHAT-018B**: Create `src/lib/textChunker.ts`:
  - `chunkDocument(text: string, options?: { chunkSize?: number, overlap?: number }): string[]`
  - Default: `chunkSize = 512` characters, `overlap = 64` characters
  - Split strategy: recursive — split by `\n\n` → `\n` → `.` → ` ` until chunks fit
  - Preserve metadata: each chunk tracks `{ sourceFileName, chunkIndex, totalChunks }`
  - Handle edge cases: empty text, very short documents (single chunk), code files (split by function boundaries if possible)

- [ ] **CHAT-018C**: Create `src/lib/embeddingEngine.ts`:
  - `initializeModel(): Promise<void>` — lazy-loads `Xenova/all-MiniLM-L6-v2` via `@xenova/transformers pipeline('feature-extraction')`
  - Caches model in IndexedDB via `localForage` so it persists across sessions (model loading is ~2-5 seconds cold start)
  - `generateEmbedding(text: string): Promise<number[]>` — returns 384-dimension vector
  - `generateEmbeddings(texts: string[]): Promise<number[][]>` — batch embedding with progress callback
  - Handle model load failure gracefully: show error state, offer retry
  - **Performance:** First embedding ~3-5s (model load), subsequent ~50-100ms each

- [ ] **CHAT-018D**: Create `src/lib/vectorStore.ts`:
  - Wraps `client-vector-search` `EmbeddingIndex`
  - `addDocument(fileName: string, chunks: string[], embeddings: number[][]): Promise<void>`
  - `search(query: string, topK?: number): Promise<SearchResult[]>` — embeds query, runs cosine similarity, returns top matches
  - `removeDocument(fileName: string): Promise<void>`
  - `getDocumentCount(): Promise<number>`
  - `clearAll(): Promise<void>`
  - Persists index to IndexedDB: `await index.saveIndex('indexedDB')`
  - On app init: restore index from IndexedDB if exists

- [ ] **CHAT-018E**: Create `src/stores/knowledgeStore.ts` (Zustand):
  ```ts
  interface KnowledgeState {
    documents: KnowledgeDocument[]
    isIndexing: boolean
    indexingProgress: { current: number; total: number } | null
    isSearching: boolean
    lastSearchResults: SearchResult[] | null
    storageEstimate: { usage: number; quota: number } | null
  }
  ```

- [ ] **CHAT-018F**: Create `src/hooks/useKnowledgeBase.ts`:
  - Composes `knowledgeStore`, `embeddingEngine`, and `vectorStore`
  - `uploadFiles(files: File[]): Promise<void>` — reads files, chunks text, generates embeddings, adds to vector store
  - `search(query: string): Promise<SearchResult[]>` — embeds query, searches vector store
  - `deleteDocument(fileName: string): Promise<void>`
  - `getContextForPrompt(query: string, maxTokens?: number): Promise<string>` — retrieves top results, formats as context string for AI prompt injection
  - Monitors `navigator.storage.estimate()` and warns user when approaching quota (80% threshold)

- [ ] **CHAT-018G**: Build `FileUploadZone.tsx`:
  - Reuses `react-dropzone` pattern from CHAT-014
  - Accept: `.txt`, `.md`, `.pdf`, `.csv`, `.json`, `.html`
  - Max file size: 10MB per file, 50MB total library
  - Upload progress: file read → chunking → embedding (steps with checkmarks)
  - Queue system: process files sequentially to avoid memory pressure
  - Drag-and-drop zone with electric blue border on drag-over

- [ ] **CHAT-018H**: Build `DocumentList.tsx`:
  - List of uploaded documents with: file name, type icon, chunk count, upload date, size
  - Search within documents: filters list by file name
  - Delete button with confirmation: removes from vector store and file list
  - Empty state: "Upload documents to build your knowledge base. Supported formats: PDF, TXT, MD, CSV, JSON, HTML."

- [ ] **CHAT-018I**: Build `KnowledgeBasePanel.tsx`:
  - Accessible from Settings → Memory → Knowledge Base tab, or from Chat toolbar
  - Tabs: "Documents" (DocumentList), "Upload" (FileUploadZone), "Search Test" (test query input + results)
  - Stats bar: total documents, total chunks, storage used (% of quota), last indexed date
  - "Clear Knowledge Base" button in Danger Zone style (red border, confirmation)
  - Toggle: "Auto-inject knowledge into conversations" — when enabled, relevant documents are searched and included in AI context

- [ ] **CHAT-018J**: Wire into Chat:
  - When user sends a message and knowledge base has documents, optionally inject relevant context:
    ```
    [System: The following information from your knowledge base may be relevant]
    [From "project-spec.pdf", chunk 3]: ...
    [From "meeting-notes.md", chunk 7]: ...
    ```
  - Context injection toggle per-conversation (default: off — user opts in)
  - Show "📚 Searching knowledge base..." indicator during search (below 200ms, skip indicator)

- [ ] **[TEST] CHAT-018A-J**: File upload chunks text correctly; embeddings generated and stored; search returns relevant results; document deletion removes from store; quota monitoring warns at 80%; context injection toggles work.

#### Definition of Done

- Users can upload documents (txt, md, pdf, csv, json, html)
- Documents are chunked, embedded with all-MiniLM-L6-v2, and stored in IndexedDB
- Semantic search across knowledge base with cosine similarity
- Context injection into chat conversations with toggle
- Storage quota monitoring and warnings
- All processing happens client-side — no server required

#### Out of Scope
- PDF text extraction (use simple text/md for MVP; PDF.js can be added later)
- Image/document OCR
- Multi-user shared knowledge bases
- Server-side vector database

#### Anti-Patterns

- ❌ Running embedding model on main thread — `@xenova/transformers` uses Web Worker internally; verify
- ❌ Not monitoring IndexedDB quota — silent write failures when quota exceeded
- ❌ Embedding on every keystroke for search — debounce search input
- ❌ Injecting all knowledge into every conversation — must be opt-in per conversation
- ❌ Not sanitizing file content before embedding — XSS risk from malicious HTML files

---

### Task CHAT-019: Memory Manager — Cross-Conversation Context Summaries

**Priority:** 🟠 Medium
**Est. Effort:** 5 hours
**Depends On:** CHAT-018 (Knowledge Base), CHAT-002 (Chat State)

**Why this matters:** ChatGPT remembers user preferences, writing style, and project context across conversations. Claude Projects keeps document context persistent. Your command center needs a memory system that maintains continuity between sessions — otherwise every conversation starts from zero.

#### Research & Rationale

- ChatGPT's memory system: extracts key facts about the user (preferences, ongoing projects, team names) and injects them into future conversations
- Claude's Projects: persistent document library + custom instructions that live across conversations
- Implementation: periodically summarize conversations → store as memory entries → retrieve relevant memories for new conversations
- IndexedDB via `localForage` for persistent memory storage
- Memory retrieval: semantic search over memory entries (reuse embedding engine from CHAT-018) or simple keyword matching for MVP

#### Related Files

`src/components/memory/MemoryPanel.tsx` · `src/components/memory/MemoryEntryCard.tsx` · `src/hooks/useMemory.ts` · `src/stores/memoryStore.ts`

#### Subtasks

- [ ] **CHAT-019A**: Create `src/stores/memoryStore.ts` (Zustand):
  ```ts
  interface MemoryState {
    entries: MemoryEntry[]
    isSummarizing: boolean
    lastSummaryDate: string | null
    autoSummarize: boolean
    retentionDays: number  // how long to keep memories
  }
  ```

- [ ] **CHAT-019B**: Create `src/hooks/useMemory.ts`:
  - `summarizeConversation(threadId: string): Promise<void>` — calls AI (mock) to extract key facts, decisions, preferences from conversation
  - `getRelevantMemories(query: string, topK?: number): Promise<MemoryEntry[]>` — semantic search (reuse CHAT-018 embedding engine) or keyword match for MVP
  - `addManualMemory(text: string): Promise<void>` — user manually adds a memory entry
  - `deleteMemory(id: string): Promise<void>`
  - `clearAllMemories(): Promise<void>`
  - Auto-summarize: when conversation ends (user navigates away or starts new thread), trigger summary generation
  - Store memories in IndexedDB via `localForage`

- [ ] **CHAT-019C**: Build `MemoryPanel.tsx`:
  - Accessible from Settings → Memory tab
  - Toggle: "Auto-summarize conversations" — when enabled, each conversation is summarized after it ends
  - Retention slider: 7 / 30 / 90 / 365 days (auto-delete older memories)
  - Memory count badge: "47 memories stored"
  - Search bar: filter memory entries by text
  - "Add Memory" button: opens text input for manual memory entry
  - "Clear All Memories" button: Danger Zone style with confirmation

- [ ] **CHAT-019D**: Build `MemoryEntryCard.tsx`:
  - Memory text (truncated to 150 chars)
  - Source: "From conversation: Project planning (2 days ago)" or "Manually added"
  - Tags: auto-extracted or manually assigned
  - Edit / Delete buttons on hover (Quiet tier)
  - Expand to show full memory text

- [ ] **CHAT-019E**: Wire into Chat:
  - On new conversation start: retrieve relevant memories based on first message + thread title
  - Inject as system context (similar to CHAT-018J pattern):
    ```
    [Memory: User prefers TypeScript over JavaScript for all projects]
    [Memory: Currently working on AI Command Center - Phase 3]
    [Memory: Budget review meetings are every Friday at 10am]
    ```
  - Memory injection toggle per conversation (default: on for existing users, off for first-time)
  - Indicator: "🧠 3 memories loaded" badge in ChatInterface header

- [ ] **[TEST] CHAT-019A-E**: Conversation summary generates memory entries; relevant memories retrieved for new conversation; manual memory CRUD works; retention slider deletes old entries; memory injection toggle works.

#### Definition of Done

- Auto-summarization of conversations into memory entries
- Manual memory CRUD
- Semantic/keyword search for memory retrieval
- Memory injection into new conversations with toggle
- Retention policy with configurable duration
- All data stored client-side in IndexedDB

#### Anti-Patterns

- ❌ Auto-injecting memories without user awareness — always show what's being injected
- ❌ Summarizing every tiny conversation — set minimum message threshold (≥5 messages)
- ❌ Not encrypting or sanitizing stored memories — sensitive data risk
- ❌ Infinite memory growth — retention policy is mandatory

---

## 🤖 Module E: Agent Orchestration

### Task CHAT-020: Agent Studio — Custom Agent Builder

**Priority:** 🟠 Medium
**Est. Effort:** 6 hours
**Depends On:** DASH-006 (AgentFleetPanel), CHAT-018 (Knowledge Base)

**Why this matters:** ChatGPT's GPT Builder lets users create custom AI personas with specific system prompts, knowledge files, and tool access. Your current `AgentFleetPanel` displays hardcoded agents. The Agent Studio empowers users to create their own.

#### Research & Rationale

- GPT Builder pattern: name → description → system instructions (prompt) → knowledge files → capabilities (tools) → preview/test → publish
- Claude's approach: system prompts + Project knowledge base + tool access per project
- Combine both: agents have system prompts, attached knowledge bases (from CHAT-018), and tool access (from CHAT-015 MCP)
- Agent testing: a mini chat interface within the studio to test the agent's behavior before saving

#### Related Files

`src/components/agents/AgentStudio.tsx` · `src/components/agents/AgentBuilderForm.tsx` · `src/components/agents/AgentTestChat.tsx` · `src/stores/agentStore.ts` · `src/hooks/useAgents.ts` (extend)

#### Subtasks

- [ ] **CHAT-020A**: Extend `src/stores/agentStore.ts`:
  - Add custom agent support alongside built-in agents
  - Agent shape: `{ id, name, avatar, systemPrompt, knowledgeBaseIds, mcpServerIds, model, isBuiltIn, createdAt, updatedAt }`

- [ ] **CHAT-020B**: Build `AgentStudio.tsx`:
  - Route: `/agents/studio` or modal overlay from AgentFleetPanel "Create Agent" button
  - Left sidebar (200px): list of custom agents, "New Agent" button
  - Right content area: AgentBuilderForm for selected agent
  - Empty state: "Create your first custom agent. Custom agents have their own system prompts, knowledge, and tool access."

- [ ] **CHAT-020C**: Build `AgentBuilderForm.tsx`:
  - Fields:
    - **Name** (text input, required)
    - **Avatar** (initials auto-generated from name, optional image upload)
    - **System Prompt** (textarea, 4-8 rows, required) — with placeholder template: "You are a helpful assistant that specializes in..."
    - **Model** (select: GPT-4o, Claude Sonnet, Claude Opus, Gemini Pro — mocked)
    - **Knowledge Bases** (multi-select checkboxes from CHAT-018 knowledge base documents)
    - **MCP Tools** (multi-select checkboxes from CHAT-015 connected MCP servers/tools)
  - "Save" button → mutation → adds to agentStore
  - "Delete" button → confirmation modal → removes custom agent (built-in agents cannot be deleted)
  - Form uses `react-hook-form` with Zod validation

- [ ] **CHAT-020D**: Build `AgentTestChat.tsx`:
  - Mini chat interface within the studio to test agent behavior
  - Uses the agent's system prompt + knowledge base + tool access
  - Messages appear in compact bubbles (same styling as CHAT-004 but smaller)
  - "Clear Test Chat" button
  - Purpose: validate agent behavior before deploying to the fleet

- [ ] **CHAT-020E**: Wire into AgentFleetPanel:
  - Custom agents appear alongside built-in agents in the fleet grid
  - Custom agents have a "⚙️ Edit" button that opens AgentStudio
  - Built-in agents have a "📋 Duplicate" button that creates a custom copy (so users can customize built-in behaviors)
  - Agent cards show: custom badge if user-created, knowledge base count, tool count

- [ ] **[TEST] CHAT-020A-E**: AgentStudio opens; form saves new agent; test chat responds to custom system prompt; custom agent appears in fleet; duplicate creates editable copy; delete removes only custom agents.

#### Definition of Done

- Agent Studio accessible from AgentFleetPanel
- Form with name, avatar, system prompt, model, knowledge base, and tool access
- Test chat to validate agent behavior
- Custom agents appear in fleet alongside built-in agents
- Duplicate built-in agents to create custom variants
- All data stored in Zustand (mock persistence)

#### Anti-Patterns

- ❌ Storing agent configs without validation — empty system prompt produces useless agents
- ❌ Not showing which knowledge bases / tools are attached to an agent — discoverability
- ❌ Allowing deletion of built-in agents — only custom agents can be deleted
- ❌ Not providing prompt templates — users don't know what to write

---

### Task CHAT-021: Agent-to-Agent (A2A) Flow Orchestrator

**Priority:** 🔴 High
**Est. Effort:** 14 hours
**Depends On:** CHAT-020 (Agent Studio), DASH-006 (AgentFleetPanel)

**Why this matters:** This is your **strategic differentiator**. Neither ChatGPT nor Claude has a visual agent orchestration interface. ChatGPT runs agents in linear sequence; Claude's agent teams are implicit. A visual DAG editor where users connect agents (Researcher → Writer → Editor → QA) is a unique capability that positions your command center above both platforms.

#### Research & Rationale

- **React Flow (`@xyflow/react`)** is the standard library for node-based editors in React. It handles drag, connect, zoom, pan, and all interactions.
- **Dagre** is the recommended layout algorithm for DAGs — it automatically positions nodes in a readable hierarchy.
- **Critical pattern:** Every custom node must export `<Handle>` components for edges to connect.
- **State management:** Zustand for node/edge state + temporal middleware for undo/redo.
- **When deleting nodes:** ensure Dagre graph instance is also cleaned to prevent edge routing anomalies.
- **React Flow v12+** (rebranded as `@xyflow/react` in late 2025) is the latest stable version.

#### Related Files

`src/components/orchestrator/A2AFlowEditor.tsx` · `src/components/orchestrator/AgentNode.tsx` · `src/components/orchestrator/FlowToolbar.tsx` · `src/components/orchestrator/FlowRunPanel.tsx` · `src/stores/flowStore.ts` · `src/hooks/useAgentFlow.ts`

#### Subtasks

- [ ] **CHAT-021A**: Install dependencies:
  ```sh
  pnpm add @xyflow/react dagre @types/dagre
  ```

- [ ] **CHAT-021B**: Create `src/stores/flowStore.ts` (Zustand):
  - `nodes: Node<AgentNodeData>[]` — React Flow nodes representing agents
  - `edges: Edge[]` — connections between agents
  - `isRunning: boolean` — flow execution state
  - `runProgress: { currentNodeId: string; completed: string[] } | null`
  - Actions: `addNode`, `removeNode`, `updateNodeData`, `addEdge`, `removeEdge`, `autoLayout`, `startRun`, `updateProgress`, `endRun`
  - Apply `zeitstand` middleware for undo/redo on all node/edge mutations

- [ ] **CHAT-021C**: Build `AgentNode.tsx` (custom React Flow node):
  - Displays: agent avatar + initials, agent name, model badge
  - Input handle (left side, Top/Middle/Bottom positions for multiple inputs)
  - Output handle (right side)
  - Status indicator during run: idle (gray), running (amber pulse), completed (green), error (red)
  - Click → opens AgentStudio for that agent (or info panel if built-in)
  - Hover: subtle glow + tooltip with agent description (Quiet tier)
  - Drag overlay: glowing scaled card (Alive tier, spring physics)

- [ ] **CHAT-021D**: Build `A2AFlowEditor.tsx`:
  - Route: `/orchestrator` or `/flows`
  - `<ReactFlow>` component with:
    - `nodeTypes={{ agentNode: AgentNode }}`
    - `defaultEdgeOptions={{ animated: true, style: { stroke: '#0066ff', strokeWidth: 2 } }}`
    - Custom edge with arrow marker (electric blue)
  - Background: dot grid pattern (`#111111` with subtle dots)
  - Controls: zoom in/out, fit view, lock/unlock
  - MiniMap in bottom-right corner
  - Drag from AgentFleetPanel sidebar onto canvas to add agent nodes
  - Connect handles to create edges (data flow: output → input)
  - Edge labels: optional data type annotation (e.g., "text", "JSON", "code")

- [ ] **CHAT-021E**: Build `FlowToolbar.tsx`:
  - Positioned above the flow canvas
  - Buttons: "Auto Layout" (runs Dagre), "Undo", "Redo", "Fit View", "Clear Canvas"
  - Flow name (editable inline): "Q4 Budget Analysis Pipeline"
  - Save indicator: "Saved" / "Unsaved changes"
  - "Run Flow" button (primary, electric blue) — disabled if no start node or no edges
  - Zoom level indicator

- [ ] **CHAT-021F**: Auto-layout with Dagre:
  - `autoLayout()` action in `flowStore`:
    ```ts
    const dagreGraph = new dagre.graphlib.Graph()
    dagreGraph.setDefaultEdgeLabel(() => ({}))
    dagreGraph.setGraph({ rankdir: 'LR', nodesep: 80, ranksep: 150 })
    nodes.forEach(n => dagreGraph.setNode(n.id, { width: 180, height: 80 }))
    edges.forEach(e => dagreGraph.setEdge(e.source, e.target))
    dagre.layout(dagreGraph)
    // apply positions back to nodes
    ```
  - `rankdir: 'LR'` (left-to-right) for agent pipelines
  - Animation: nodes animate to new positions with spring (Alive tier)

- [ ] **CHAT-021G**: Build `FlowRunPanel.tsx`:
  - Slides in from bottom when flow is running
  - Shows: current executing agent (highlighted), completed agents (green check), pending agents (gray)
  - Progress bar: "3 of 7 agents completed"
  - Agent output preview: expandable section showing output from last completed agent
  - "Stop" button: aborts flow execution
  - "View Results" button: opens full output report
  - Flow execution is mocked: agents "execute" sequentially with artificial delays (1-3s each)

- [ ] **CHAT-021H**: Wire into existing system:
  - "Create Flow" button in AgentFleetPanel header
  - Saved flows appear in a "Flows" section below the agent grid
  - Flow can be triggered from Chat: `/run_flow "Q4 Budget Analysis Pipeline"`
  - Flow execution logs appear in AgentTerminal (CHAT-016)

- [ ] **[TEST] CHAT-021A-H**: Nodes draggable onto canvas; edges connectable; auto-layout positions nodes hierarchically; undo/redo works; run flow highlights agents sequentially; stop button aborts; flow can be triggered from slash command.

#### Definition of Done

- Visual DAG editor with drag-and-drop agent nodes
- Edge creation by connecting handles
- Dagre auto-layout for readable hierarchy
- Undo/redo on all editor operations
- Flow execution with progress visualization
- Flow triggering from slash commands and AgentFleetPanel
- Saved flows persist in Zustand (mock persistence)

#### Out of Scope
- Real agent-to-agent message passing (mock execution only)
- Conditional branching (if/else logic in edges)
- Parallel agent execution
- Flow templates library
- Flow version history

#### Anti-Patterns

- ❌ Using HTML5 drag-and-drop API — React Flow handles this internally
- ❌ Forgetting `<Handle>` components on custom nodes — edges won't render
- ❌ Not cleaning Dagre graph on node deletion — causes layout anomalies
- ❌ Deep cloning entire node/edge arrays on every undo snapshot — use `zeitstand` ring buffer
- ❌ Running flows on the main thread without visual feedback — users think it's frozen

---

## 📚 Task CHAT-022: Prompt Library — Management & Quick Insert

**Priority:** 🟠 Medium
**Est. Effort:** 3 hours
**Depends On:** CHAT-006 (ChatInput), CHAT-008 (SlashMenu)

**Why this matters:** A prompt library allows users to save, organize, and quickly reuse frequently used prompts. This is a productivity feature that reduces repetitive typing and ensures consistency in prompt engineering. Users can access their library while typing in the chat input.

#### Related Files

`src/pages/PromptLibraryPage.tsx` · `src/components/chat/PromptLibraryModal.tsx` · `src/components/chat/PromptCard.tsx` · `src/stores/promptStore.ts` · `src/lib/mockData/prompts.ts`

#### Subtasks

- [ ] **CHAT-022A**: Create `src/stores/promptStore.ts` (Zustand):
  ```ts
  interface Prompt {
    id: string
    title: string
    content: string
    category: string  // e.g., 'coding', 'writing', 'analysis', 'custom'
    tags: string[]
    createdAt: string
    updatedAt: string
    usageCount: number
  }

  interface PromptState {
    prompts: Prompt[]
    categories: string[]
    selectedCategory: string | null
    searchQuery: string
    isOpen: boolean
  }
  ```
  Actions: `addPrompt`, `updatePrompt`, `deletePrompt`, `setCategory`, `setSearchQuery`, `openLibrary`, `closeLibrary`, `incrementUsage`.
  Persist to localStorage with `persist` middleware.

- [ ] **CHAT-022B**: Create `src/lib/mockData/prompts.ts` with realistic starter prompts:
  ```ts
  export const DEFAULT_PROMPTS: Prompt[] = [
    {
      id: '1',
      title: 'Code Review',
      content: 'Review this code for bugs, performance issues, and best practices. Suggest improvements.',
      category: 'coding',
      tags: ['review', 'quality'],
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      usageCount: 0
    },
    // ... 8-10 more default prompts across categories
  ]
  ```

- [ ] **CHAT-022C**: Build `PromptLibraryPage.tsx`:
  - Route: `/prompts` (subpage, accessible via nav or chat)
  - Two-column layout: left category sidebar (200px), right prompt grid
  - Category sidebar: list of categories with counts (e.g., "Coding (5)", "Writing (3)")
  - Search bar at top (controlled, filters prompts by title/content/tags)
  - Prompt grid: bento-style layout using CSS Grid, `PromptCard` components
  - "New Prompt" button (primary, electric blue) opens create modal
  - Empty state: "No prompts yet. Create your first prompt to get started."
  - Page transition: `motion.div` with fade/slide (Alive tier)

- [ ] **CHAT-022D**: Build `PromptCard.tsx`:
  - Displays: title, truncated content preview (2 lines), category badge, tags (pill badges), usage count
  - Hover: subtle lift (`y: -2`) and border glow (electric blue)
  - Click: opens edit modal with full content
  - Three-dot menu: "Edit", "Duplicate", "Delete" (destructive)
  - Motion: entrance animation with stagger (Quiet tier)
  - `role="button"` + `aria-label={prompt.title}`

- [ ] **CHAT-022E**: Build `PromptLibraryModal.tsx` (create/edit):
  - Uses shadcn `Dialog` for modal (accessible, focus trap)
  - Form fields: title (text), content (textarea with auto-resize), category (select), tags (comma-separated input)
  - Validation: title required, content required
  - "Save" button (primary) calls `promptStore.addPrompt` or `updatePrompt`
  - "Cancel" button closes modal
  - Entrance/exit animation with `AnimatePresence` (Alive tier)
  - `role="dialog"` + `aria-modal="true"` + `aria-labelledby`

- [ ] **CHAT-022F**: Integrate with ChatInput:
  - Add "Prompt Library" button (icon-only, book icon) to input toolbar (left of attach button)
  - Click opens `PromptLibraryModal` in "quick insert" mode (compact view, no edit)
  - Quick insert mode: shows prompt list in dropdown-style menu (positioned above input)
  - Clicking a prompt inserts its content into the chat input (appends to existing text)
  - Keyboard shortcut: `Cmd/Ctrl+P` opens quick insert menu
  - Quick insert menu: search bar at top, filtered prompt list, hover preview of content
  - Motion: menu slides up from input (Quiet tier)

- [ ] **CHAT-022G**: Add slash command integration:
  - Add `/prompt` to `SLASH_COMMANDS` in `src/data/slashCommands.ts`
  - `/prompt` opens quick insert menu
  - `/prompt <search>` filters menu by search query
  - Example: `/prompt code` shows only coding-related prompts

- [ ] **CHAT-022H**: Implement prompt usage tracking:
  - When a prompt is inserted via quick insert, call `promptStore.incrementUsage(promptId)`
  - Sort prompts by usage count in "Most Used" category (auto-generated)
  - Show usage count on PromptCard with "Used X times" label

- [ ] **[TEST] CHAT-022A-H**: Prompt library page renders with categories and grid; search filters correctly; create/edit/delete mutations work; quick insert menu opens on button click and keyboard shortcut; prompt content inserts into chat input; `/prompt` slash command opens menu; usage count increments on insert.

#### Definition of Done

- Prompt library page at `/prompts` with category sidebar and prompt grid
- CRUD operations for prompts with localStorage persistence
- Default prompts provided on first load
- Quick insert accessible from ChatInput button and `Cmd/Ctrl+P`
- `/prompt` slash command integration
- Usage tracking and "Most Used" sorting
- All modals accessible with proper ARIA attributes
- Motion follows hierarchy (Alive for modals, Quiet for menus)

#### Anti-Patterns

- ❌ Not persisting to localStorage — prompts lost on refresh
- ❌ Using path params for prompt editing — causes page remount; use modal
- ❌ Forgetting `Cmd/Ctrl+P` keyboard shortcut — power users expect this
- ❌ Not validating prompt content — empty prompts cause confusion
- ❌ Missing category "All" option — users can't view all prompts at once

---

## 📊 Dependency Graph

```
CHAT-001 (Page Layout & Route)
     │
CHAT-002 (State, Query Config, MSW)
     │
     ├────────────────────────────────────────────────────┐
     │                                                    │
CHAT-003 (Thread List)                              CHAT-006 (ChatInput)
     │                                                    │
CHAT-004 (MessageBubble)                            CHAT-014 (Media Attachments)
     │                                                    │
CHAT-005 (Virtual Scroll)                           CHAT-008 (SlashMenu)
     │                                                    │
CHAT-009 (ToolCallDisclosure)                             │
     │                                                    │
CHAT-010 (CheckpointBanner)                               │
     │                                                    │
CHAT-007 (SSE Streaming)                                  │
     │                                                    │
     ├────────────────────────────────────────────────────┘
     │
CHAT-011 (Collaboration Canvas)
     │
     ├──────────────┐
     │              │
CHAT-012       CHAT-013
(Live Artifacts) (Snapshots)
                   
CHAT-015 (MCP Settings & Tool Registry)
     │
     ├──────────────┐
     │              │
CHAT-016       CHAT-017
(Agent Terminal) (Slash Toolbar)

CHAT-018 (Knowledge Base RAG)
     │
CHAT-019 (Memory Manager)

CHAT-020 (Agent Studio)
     │
CHAT-021 (A2A Flow Orchestrator)
```

---

## 🏁 Chat Module Completion Checklist (Full)

**Module A: Chat Core (Existing)**
- [ ] CHAT-001 → CHAT-010: All existing criteria preserved from original spec

**Module B: Collaboration Canvas**
- [ ] Split-pane layout with Monaco Editor (code) and Markdown editor (text)
- [ ] Diff preview (side-by-side) with Apply/Reject
- [ ] Sandboxed iframe renders AI-generated React, SVG, HTML, Markdown
- [ ] CSP + sandbox attributes provide defense-in-depth security
- [ ] `@babel/standalone` transpiles JSX in-browser
- [ ] Version snapshots auto-created before AI edits
- [ ] Snapshot list with restore and undoable-restore semantics

**Module C: Multimodal & MCP Foundation**
- [ ] Drag-and-drop file/image upload with preview and Jimp resizing
- [ ] MCP server CRUD UI with connection status and tool registry
- [ ] Agent terminal with virtualized ANSI-style log
- [ ] Slash menu dynamically populated with MCP tools

**Module D: Knowledge & Memory**
- [ ] Client-side RAG: chunk → embed (all-MiniLM-L6-v2) → store (IndexedDB) → search (cosine similarity)
- [ ] Context injection into conversations with toggle
- [ ] Cross-conversation memory summaries with retention policy

**Module E: Agent Orchestration**
- [ ] Agent Studio with custom system prompts, knowledge bases, and tool access
- [ ] Test chat within studio for agent validation
- [ ] A2A DAG flow editor with React Flow + Dagre auto-layout
- [ ] Undo/redo on all editor operations
- [ ] Flow execution with progress visualization

**Cross-Cutting (All Modules)**
- [ ] All animations follow Motion Hierarchy (Alive/Quiet/Static)
- [ ] `useReducedMotion()` checked in every animated component
- [ ] WCAG 2.2 AA: keyboard, focus, ARIA, color contrast
- [ ] Error boundaries on Canvas, Artifact sandbox, and Flow editor
- [ ] `DOMPurify` sanitization on all AI-generated content before rendering
- [ ] IndexedDB quota monitoring with user warnings
- [ ] All network calls mocked via MSW; hooks tested via `renderHook`
- [ ] No backend code; all data client-side (IndexedDB, Zustand, Blob URLs)