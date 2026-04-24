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
  }
  ```
**Priority:** 🔴 High
**Est. Effort:** 0.75 hours
**Depends On:** FND-007 (Router), FND-008 (Provider Tree)
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

- [ ] **CHAT-002C**: Define `useSendMessage(threadId: string)` mutation using the shared `useOptimisticMutation()` wrapper:
  - **Critical**: MUST use `useOptimisticMutation()` from `src/lib/useOptimisticMutation.ts` (see FND-006H). Do not implement inline `onMutate/onError/onSettled` patterns.
  - Config: `mutationFn: sendMessage`, `queryKey: chatKeys.messages(threadId)`
  - `optimisticUpdate`: Append user message with `clientMsgId: crypto.randomUUID()`, `status: 'sending'`
  - `onSettled`: Invalidate `chatKeys.messages(threadId)` (handles both success and error paths)
  - The `clientMsgId` is passed through as part of the mutation variables and echoed back by the server; used to replace the `status: 'sending'` message without changing its React `key`
- [ ] **[TEST] CHAT-002C**: Optimistic message appears immediately with `status: 'sending'`; on error, cache reverts via wrapper rollback; on success, status updates to `'sent'` without key change

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
    const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false, cacheTime: 0 } } })
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
- ❌ `Date.now()` as temp ID — use `crypto.randomUUID()` (collision-safe, UUID-stable)
- ❌ Replacing React `key` when server ID arrives — carry `clientMsgId` as permanent key
- ❌ `gcTime` left at default with `staleTime: 0` — messages get GC'd from cache mid-conversation
- ❌ `useState` for streaming/model/slash menu state — use a reducer for predictable transitions
- ❌ Using `setTimeout` for debouncing search input — use `useTransition` for non-blocking React 19+ pattern

<!-- ENDSECTION: Chat State Management -->

---

<!-- SECTION: Thread List -->

## 🧵 Task CHAT-003: Thread List
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
- ❌ Virtualizing thread list — unnecessary at ≤100 items; adds complexity without gain
- ❌ Path-param navigation for thread switching — causes page remount; use search params
- ❌ `setTimeout`-based debounce for search — use `useTransition` for non-blocking React 19+ pattern
- ❌ Using `Date.now()` as temp ID — use `crypto.randomUUID()` (collision-safe, UUID-stable)

---

<!-- SECTION: Message Display -->

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
  - While streaming: Enter is blocked; send button is disabled; show "Stop" icon button that calls `abortStream()` and dispatches `END_STREAMING`
  - [ ] **[TEST] CHAT-006D**: Enter sends and clears input; Shift+Enter newlines; Cmd+Enter sends; Enter blocked during streaming; Stop button visible during streaming

### Definition of Done
- Textarea auto-resizes 1–5 rows; `cacheMeasurements` enabled
- LED border glows on focus; flashes on keypress
- Enter sends; Shift+Enter newlines; Cmd+Enter sends; Stop button aborts stream
- Model selector and attach placeholder present

### Anti-Patterns

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

---

**See Also:**
- [11-Chat-Research.md](11-Chat-Research.md) - Research synthesis and architectural foundations
- [11-Chat-Modules.md](11-Chat-Modules.md) - Extended module tasks (CHAT-011 through CHAT-022)
