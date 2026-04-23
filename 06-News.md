# 06-News — Personal AI Command Center Frontend (Enhanced v3)

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.


## 🔬 Research Findings — News Module

| Finding | Source | Action Required |
|---------|--------|-----------------|
| **`useInfiniteQuery` v5 requires `initialPageParam`** (not optional). `getNextPageParam` returns the cursor for the next fetch; returning `undefined` signals end-of-feed. `data.pages.flatMap(p => p.articles)` derives the flat list — this must be `useMemo`-wrapped. | TanStack Query v5 docs | NEWS-003: set `initialPageParam: null`, `getNextPageParam` returns `lastPage.nextCursor ?? undefined` |
| **Sentinel div for IntersectionObserver must sit outside the `react-window` list container.** Placing it inside the VirtualList's scroll container means it's measured against the internal scroll root, not the viewport, causing premature triggers. | react-window GitHub, Magic UI 2025 | NEWS-003: render sentinel div below `<VariableSizeList>`, not inside it |
| **Guard `fetchNextPage` with `!isFetchingNextPage && hasNextPage`** — calling it while already fetching enqueues a duplicate request. | TanStack Query docs | NEWS-003: IO callback must check both flags |
| **`Set` does not serialize with Zustand `persist`** — `JSON.stringify(new Set([...]))` produces `{}`. Store saved/read IDs as `string[]` and derive the `Set` via `useMemo` where needed. | Zustand GitHub issues | NEWS-001: `savedArticleIds: string[]`, `readArticleIds: string[]` |
| **`useReducedMotion()` controls visual animation — it does not govern audio.** Gating TTS on `useReducedMotion` is a logical error and accessibility anti-pattern; users who prefer reduced motion may still want audio. | WCAG 2.2, MDN | NEWS-008: audio controlled by a dedicated `audioEnabled` user preference, not motion preference |
| **`@mozilla/readability` is the canonical library for in-app article extraction** — it powers Firefox Reader Mode, ZenRead, and Focus Reader. Pair with `DOMParser` for HTML input from fetched article HTML. | MDN, ZenRead, dev.to 2025 | NEWS-006: use `@mozilla/readability` for reader mode text extraction |
| **`useLiveQuery` from `dexie-react-hooks` provides reactive IndexedDB reads** — component re-renders whenever the observed table changes, without manual subscription wiring. | Dexie.js docs | NEWS-005: all bookmark/read-status reads use `useLiveQuery` |
| **Dexie bulk operations (`bulkAdd`, `bulkPut`) are significantly faster** than sequential `add` calls — they bypass per-operation `onsuccess` events internally. Use for batch article imports. | Dexie.js docs | NEWS-005: batch save operations use `db.articles.bulkPut(articles)` |
| **Mark-as-read should trigger on article open, not on impression.** Impression-based read tracking (visible in viewport for N seconds) is unreliable and a dark pattern—it marks articles as read that the user scrolled past. | News reader UX research, Feedly UX 2025 | NEWS-005: mark-as-read fires on article open (reader mode or external tab) |
| **Web Share API requires navigator.share check before calling.** On unsupported browsers (Firefox desktop), calling `navigator.share()` throws. The clipboard fallback must be explicit and tested separately. | MDN Web Share API | NEWS-004: `if (navigator.share) { ... } else { navigator.clipboard.writeText(url) }` |
| **Pause-feed + new article accumulation pattern:** when `isPaused`, new fetched articles go into a `pendingArticles` buffer; a sticky "N new articles — tap to load" banner triggers flushing. This matches WCAG 2.2 auto-update control. | WCAG 2.2, Twitter/X UX pattern | NEWS-003: implement pending buffer |
| **Trust tier badges and sentiment dots must have text labels**, not just color — color-alone is a WCAG 1.4.1 failure. | WCAG 1.4.1 | NEWS-004: badge reads "High trust", dot reads "Positive" (visually hidden label + `aria-label`) |
| **Card virtualization: `VariableSizeList` requires stable `itemSize` per index.** Cards with expandable summaries change height after render. Either fix card heights or switch to `AutoSizer` + dynamic `resetAfterIndex` on expand. | react-window docs | NEWS-003: call `listRef.current.resetAfterIndex(expandedIndex)` on expand/collapse |
| **Deduplication via URL normalization** (strip `utm_*` params, normalize protocol) is more reliable than raw URL equality for catching the same article from multiple sources. | dev.to 2026 | NEWS-003: normalize URLs in dedup logic |
| **`@tanstack/react-query` `staleTime` for news feed should be short (30–60 seconds)** for real-time topics, but the `gcTime` should remain longer (5–10 minutes) to preserve feed scroll position on tab switch. | TanStack Query best practices | NEWS-000: `staleTime: 30_000`, `gcTime: 600_000` |
| **Article search must highlight matched terms.** Plain filter-and-display without highlighting leaves users confused about why a result matched. Use `mark.js` or a simple regex-based highlighter. | Feedly, Inoreader UX 2025 | NEWS-007: matched terms wrapped in `<mark>` elements |


## 🧱 Cross-Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **NEWS-C01** | State Management | Zustand `newsSlice` for topics, sources, sort order, pause state, pending count, reader prefs. Arrays (not Sets) for serializable persistence. |
| **NEWS-C02** | Data Fetching | `useInfiniteQuery` with cursor pagination for feed. `staleTime: 30s`, `gcTime: 10min`. |
| **NEWS-C03** | Offline / Local Storage | Dexie for bookmarks + read status. `useLiveQuery` for reactive reads. Bulk ops for batch saves. |
| **NEWS-C04** | Auto-Update Control | When `isPaused`, new articles buffer in `pendingArticles`. Sticky banner shows count. Flush on user action. |
| **NEWS-C05** | Accessibility (Cards) | `role="article"`, trust tier and sentiment must have text labels (not color alone). Web Share fallback explicit. |
| **NEWS-C06** | Virtualization | `VariableSizeList` for feed. Sentinel for IO outside the list container. `resetAfterIndex` on height-changing card actions. |
| **NEWS-C07** | Reader Mode | `@mozilla/readability` for content extraction. Font, theme, line-height user prefs in Zustand. |
| **NEWS-C08** | Audio | Controlled by dedicated `audioEnabled` preference — never gated on `useReducedMotion`. |

### 🎯 Motion Tier Assignment

| Component | Tier | Allowed Techniques |
|-----------|------|--------------------|
| Topic chip toggle | **Quiet** | `whileTap={{ scale: 0.95 }}` (spring ≤150ms) |
| Sentiment dot | **Quiet** | Slow opacity pulse (2s loop, `useReducedMotion` guard) |
| News card hover | **Quiet** | `boxShadow` glow (`oklch` electric blue) |
| "N new articles" banner | **Quiet** | Slide down from top (`y: -8→0`) |
| Card expand/collapse | **Quiet** | `height` animation via `motion.div` with `layout` |
| Feed article entrance | **Static** | No animation — prevents jank during rapid scroll |
| Sidebar preference toggles | **Static** | Instant |
| Reader mode open | **Alive** | Cross-fade panel entrance (spring) |


## 🗃️ Task NEWS-000: Mock Data Layer
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** FND-004 (Testing), FND-006 (TanStack Query)

### Related Files
`src/mocks/factories/news.ts` · `src/mocks/handlers.ts` · `src/queries/news.ts`

### Subtasks

- [ ] **NEWS-000A** Create `src/mocks/factories/news.ts`:
  - `createMockArticle(overrides?)` returns:
    ```ts
    {
      id: string
      title: string
      source: { id: string; name: string; logoUrl: string; trustTier: 'high' | 'medium' | 'low' }
      publishedAt: string  // ISO 8601 UTC
      summary: string      // 2–3 sentence abstract
      fullContent: string | null  // full HTML, null for most articles (fetched lazily)
      aiSummary: string    // AI-generated 1 sentence
      sentiment: number    // -1 to 1
      sentimentLabel: 'positive' | 'neutral' | 'negative'
      topics: string[]
      url: string
      imageUrl: string | null
      author: string | null
      wordCount: number    // for read-time estimate
      readTimeMinutes: number  // Math.ceil(wordCount / 200)
      isRead: boolean      // always false in factory; overridden by Dexie read-status
    }
    ```
  - `createMockFeed(opts: { count: number; topics?: string[]; cursor?: string })` — returns varied articles, cursor-paginated (20 per page), mixing sentiments and topics

- [ ] **NEWS-000B** Create supporting factories:
  - `createMockTopic(overrides?)` — `{ id, label, iconName }`; standard set: Technology, Business, World, Science, Health, Politics, Sports
  - `createMockSource(overrides?)` — `{ id, name, logoUrl, trustTier, rssUrl }`
  - `createMockPreferences()` — `{ activeTopics: string[], activeSources: string[], frequency, sortOrder }`

- [ ] **NEWS-000C** Update `src/mocks/handlers.ts`:
  ```ts
  // Paginated feed — cursor-based
  http.get('/api/news/feed', ({ request }) => {
    const url = new URL(request.url)
    const cursor = url.searchParams.get('cursor') ?? null
    const topics = url.searchParams.getAll('topics')
    const page = createMockFeed({ count: 20, topics, cursor })
    return HttpResponse.json({
      articles: page,
      nextCursor: page.length === 20 ? page.at(-1)!.id : null,
    })
  })
  http.get('/api/news/topics', () => HttpResponse.json(createMockTopics()))
  http.get('/api/news/sources', () => HttpResponse.json(createMockSources()))
  http.get('/api/news/preferences', () => HttpResponse.json(createMockPreferences()))
  http.put('/api/news/preferences', async ({ request }) =>
    HttpResponse.json(await request.json()))
  // Article fetch for reader mode
  http.get('/api/news/articles/:id', ({ params }) =>
    HttpResponse.json({ ...createMockArticle({ id: params.id as string }), fullContent: '<article>...</article>' }))
  ```

- [ ] **NEWS-000D** Create `src/queries/news.ts`:
  ```ts
  export const newsKeys = {
    all: ['news'] as const,
    feed: (filters: FeedFilters) => [...newsKeys.all, 'feed', filters] as const,
    topics: () => [...newsKeys.all, 'topics'] as const,
    sources: () => [...newsKeys.all, 'sources'] as const,
    preferences: () => [...newsKeys.all, 'preferences'] as const,
    article: (id: string) => [...newsKeys.all, 'article', id] as const,
  }

  export const feedInfiniteQueryOptions = (filters: FeedFilters) =>
    infiniteQueryOptions({
      queryKey: newsKeys.feed(filters),
      queryFn: ({ pageParam }) => fetchFeed({ ...filters, cursor: pageParam }),
      initialPageParam: null as string | null,
      getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
      staleTime: 30_000,
      gcTime: 600_000,
    })
  ```

- [ ] **NEWS-000E** Create `useSavePreferences()` mutation with optimistic update:
  - `onMutate`: snapshot + update `newsKeys.preferences()` cache
  - `onError`: rollback
  - `onSettled`: `invalidateQueries({ queryKey: newsKeys.preferences() })`

### Tests
- [ ] Factory produces articles with all required fields, correct `readTimeMinutes` derivation
- [ ] `createMockFeed` with `cursor` returns a different page than without cursor
- [ ] MSW handler returns `nextCursor: null` when fewer than 20 articles returned
- [ ] `feedInfiniteQueryOptions` has correct `staleTime` and `gcTime`
- [ ] `useSavePreferences` snapshots and rolls back on 500 response

### Definition of Done
- Full mock factories with all fields including `wordCount`, `fullContent`, `sentimentLabel`
- Paginated MSW handler with cursor support
- Query key factory covers feed, topics, sources, preferences, individual article
- `pnpm test` passes

### Anti-Patterns
- ❌ `useQuery` for feed — must be `useInfiniteQuery`
- ❌ `staleTime: 0` on feed — causes waterfall re-fetches on every tab focus; use 30s
- ❌ Hardcoding `pageSize` inside the factory without respecting `cursor` offset — breaks pagination tests


## 🔧 Task NEWS-001: State Management & Route
**Priority:** 🔴 High | **Est. Effort:** 45 min | **Depends On:** FND-005 (Zustand), NEWS-000

### Related Files
`src/stores/slices/newsSlice.ts` · `src/router/routes.ts` · `src/pages/NewsPage.tsx`

### Subtasks

- [ ] **NEWS-001A** Create `src/stores/slices/newsSlice.ts`:
  ```ts
  interface NewsSlice {
    // Feed state
    activeTopics: string[]
    activeSources: string[]
    sortOrder: 'recency' | 'relevance' | 'trending'
    activeTab: string          // currently selected topic tab in feed header
    isPaused: boolean
    pendingArticleIds: string[] // buffered while paused
    pendingCount: number
    deduplicationEnabled: boolean
    // Local content state
    hiddenArticleIds: string[]  // articles dismissed in this session
    savedArticleIds: string[]   // mirrors Dexie bookmarks for quick lookup
    readArticleIds: string[]    // mirrors Dexie read-status for quick lookup
    // Reader preferences (persisted)
    readerPrefs: {
      fontSize: number          // 14–22px
      lineHeight: number        // 1.4–2.0
      fontFamily: 'sans' | 'serif' | 'mono'
      theme: 'light' | 'dark' | 'sepia'
    }
    audioEnabled: boolean
    // Search
    searchQuery: string
    // Actions
    toggleTopic: (id: string) => void
    toggleSource: (id: string) => void
    setSortOrder: (order: NewsSlice['sortOrder']) => void
    setActiveTab: (tab: string) => void
    togglePaused: () => void
    flushPendingArticles: () => void
    toggleDeduplication: () => void
    hideArticle: (id: string) => void
    markSaved: (id: string) => void
    markUnsaved: (id: string) => void
    markRead: (id: string) => void
    markAllRead: (ids: string[]) => void
    setReaderPrefs: (prefs: Partial<NewsSlice['readerPrefs']>) => void
    setAudioEnabled: (enabled: boolean) => void
    setSearchQuery: (q: string) => void
  }
  ```

- [ ] **NEWS-001B** Persist with `persist` middleware, partializing:
  ```ts
  partialize: (state) => ({
    activeTopics: state.activeTopics,
    activeSources: state.activeSources,
    sortOrder: state.sortOrder,
    deduplicationEnabled: state.deduplicationEnabled,
    readerPrefs: state.readerPrefs,
    audioEnabled: state.audioEnabled,
    // NOT persisted: isPaused, pendingArticleIds, pendingCount, hiddenArticleIds, searchQuery
  })
  ```
  Note: `savedArticleIds` and `readArticleIds` are not persisted here — they are the source of truth in Dexie; these fields are populated on app boot via `useLiveQuery`.

- [ ] **NEWS-001C** Export atomic selectors: `useNewsTopics()`, `useNewsPaused()`, `useReaderPrefs()`, `useNewsPendingCount()`

- [ ] **NEWS-001D** Configure `/news` route:
  ```ts
  {
    path: 'news',
    lazy: () => import('@/pages/NewsPage'),
    loader: ({ context: { queryClient } }) => {
      const { activeTopics, activeSources, sortOrder } = getNewsSlice()
      return queryClient.ensureQueryData(
        feedInfiniteQueryOptions({ topics: activeTopics, sources: activeSources, sort: sortOrder })
      )
    },
  }
  ```

- [ ] **NEWS-001E** `NewsPage` renders: `<NewsSidebar />` (left, collapsible) + main content area with `<FeedHeader />` + `<NewsFeed />` + `<ArticleReaderPanel />` (hidden by default, slides in)

### Tests
- [ ] `toggleTopic` adds to `activeTopics` if absent, removes if present
- [ ] `flushPendingArticles` clears `pendingArticleIds` and resets `pendingCount`
- [ ] `markAllRead` appends all provided IDs to `readArticleIds` without duplicates
- [ ] `savedArticleIds` and `readArticleIds` are NOT present in persisted localStorage value
- [ ] Route loader calls `ensureQueryData` with correct filter params from slice state

### Definition of Done
- Slice provides all feed, reader, and search state
- `savedArticleIds` / `readArticleIds` are NOT persisted (Dexie is source of truth)
- Route prefetches first feed page

### Anti-Patterns
- ❌ `savedArticles: Set<string>` in Zustand — Sets don't survive `JSON.stringify`; use `string[]`
- ❌ Persisting `isPaused` — should reset to false on page load
- ❌ Persisting `hiddenArticleIds` — session-only; a large persisted array of IDs bloats localStorage


## 🧭 Task NEWS-002: Page Layout & Sidebar
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** NEWS-001

### Related Files
`src/components/news/NewsSidebar.tsx` · `src/components/news/TopicSelector.tsx` · `src/components/news/SourceManager.tsx` · `src/components/news/FrequencySlider.tsx` · `src/components/news/PreferenceSync.tsx`

### Subtasks

**Sidebar Structure:**
- [ ] **NEWS-002A** Build `NewsSidebar` (280px, collapsible):
  - Sections: Topics, Sources, Feed Controls, Saved Articles count
  - Collapse toggle writes to Zustand (persisted)
  - On mobile: renders as a bottom sheet using shadcn `Sheet`

- [ ] **NEWS-002B** Build `TopicSelector`:
  - Available topics rendered as chips
  - Active: electric blue border + filled background
  - `whileTap={{ scale: 0.95 }}` (quiet tier)
  - Selecting all / deselecting all topics shows warning: "No topics selected — feed will be empty"

- [ ] **NEWS-002C** Build `SourceManager`:
  - List of sources with `trustTier` badge
  - Badge must include text: "High trust", "Medium trust", "Low trust" (visually styled, not just colored — WCAG 1.4.1)
  - Bulk actions: "Select all high trust", "Deselect all"
  - Toggle individual sources
  - Search input within source list (client-side filter by source name)

- [ ] **NEWS-002D** Build `FrequencySlider`:
  - Segmented control: Real-time / Hourly / Every 6h / Daily
  - Displays "Last updated: X minutes ago" (mocked)
  - Changing frequency triggers `useSavePreferences`

- [ ] **NEWS-002E** Add feed controls section:
  - **Pause Feed** toggle — sets `isPaused`; when on, shows "Feed paused" label with icon
  - **Deduplication** toggle — sets `deduplicationEnabled`
  - **Refresh Now** button — calls `queryClient.invalidateQueries({ queryKey: newsKeys.feed(...) })`; shows loading spinner during refetch

- [ ] **NEWS-002F** Add saved articles link:
  - Shows `useLiveQuery(() => db.articles.count())` count
  - Navigates to saved view (filtered feed)

- [ ] **NEWS-002G** Add "Mark all as read" button:
  - Confirms with `AlertDialog` ("Mark all visible articles as read?")
  - Calls `markAllRead(visibleArticleIds)`; writes to Dexie in batch

**Preference Sync:**
- [ ] **NEWS-002H** Debounced auto-save (1.5 seconds after last topic/source change):
  ```ts
  const debouncedSave = useDebouncedCallback(() => {
    savePreferences.mutate({ activeTopics, activeSources, frequency, sortOrder })
  }, 1500)
  ```

- [ ] **NEWS-002I** "Reset to Defaults" button: resets slice to initial state + triggers save

### Tests
- [ ] TopicSelector: toggling a chip updates `activeTopics` in slice
- [ ] TopicSelector: deselecting all chips shows warning banner
- [ ] SourceManager: "Select all high trust" selects only high-trust source IDs
- [ ] SourceManager: trust tier badges include text (not just color) — snapshot test
- [ ] Pause toggle: `isPaused` becomes `true`; feed stops showing new articles
- [ ] Refresh Now: calls `invalidateQueries` on the feed key
- [ ] Debounced save: fires once after 1.5s of inactivity, not on every toggle
- [ ] Reset to Defaults: resets slice and triggers save mutation

### Definition of Done
- Sidebar renders all sections with functional controls
- WCAG 1.4.1: trust tiers and sentiment use text labels, not color alone
- Debounced preference sync to backend
- Mark-all-read bulk action functional

### Anti-Patterns
- ❌ Saving preferences on every single toggle — debounce to avoid mutation spam
- ❌ Trust tier as color-only — WCAG 1.4.1 failure
- ❌ `invalidateQueries` called inside a `useEffect` on filter change — use explicit user action or debounce


## 📰 Task NEWS-003: Feed Infrastructure
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** NEWS-001, NEWS-002

### Related Files
`src/components/news/NewsFeed.tsx` · `src/hooks/useNewsFeed.ts` · `src/hooks/useInfiniteScroll.ts`

### Subtasks

**`useNewsFeed` Hook:**
- [ ] **NEWS-003A** Create `src/hooks/useNewsFeed.ts`:
  ```ts
  export function useNewsFeed() {
    const { activeTopics, activeSources, sortOrder, isPaused, deduplicationEnabled, hiddenArticleIds } = useNewsSlice()
    const query = useInfiniteQuery(
      feedInfiniteQueryOptions({ topics: activeTopics, sources: activeSources, sort: sortOrder })
    )

    const allArticles = useMemo(
      () => query.data?.pages.flatMap(p => p.articles) ?? [],
      [query.data?.pages]
    )

    const visibleArticles = useMemo(() => {
      let items = allArticles.filter(a => !hiddenArticleIds.includes(a.id))
      if (deduplicationEnabled) {
        const seen = new Set<string>()
        items = items.filter(a => {
          const key = normalizeUrl(a.url)
          if (seen.has(key)) return false
          seen.add(key)
          return true
        })
      }
      return items
    }, [allArticles, hiddenArticleIds, deduplicationEnabled])

    return { ...query, visibleArticles }
  }
  ```

- [ ] **NEWS-003B** Implement `normalizeUrl(url: string): string`:
  - Strip `utm_*`, `fbclid`, `gclid` query params
  - Normalize protocol (`http://` → `https://`)
  - Remove trailing slash
  - Lowercase hostname

**Pause / Pending Buffer:**
- [ ] **NEWS-003C** When `isPaused` and `useInfiniteQuery` fires a background refresh:
  - New articles (IDs not in current `allArticles`) go into `pendingArticleIds` via `setPendingArticles`
  - Do NOT prepend them to the visible list
  - Detect new articles by comparing fresh `data.pages[0].articles[0].id` against the last-known top ID

- [ ] **NEWS-003D** Build `NewArticlesBanner`:
  - Sticky at top of feed (below filter tabs)
  - Shows "↑ 12 new articles" when `pendingCount > 0`
  - Slide-down entrance animation (`y: -8 → 0`, quiet tier)
  - Click: `flushPendingArticles()` → invalidates query to trigger refetch with new articles prepended

**Feed Rendering:**
- [ ] **NEWS-003E** Build `NewsFeed` component:
  ```tsx
  const { visibleArticles, fetchNextPage, hasNextPage, isFetchingNextPage, isError, isPending } = useNewsFeed()

  // During initial load: show skeleton cards
  if (isPending) return <FeedSkeleton count={5} />
  if (isError) return <FeedError onRetry={() => refetch()} />
  if (visibleArticles.length === 0) return <FeedEmptyState />

  return (
    <>
      <NewArticlesBanner />
      <AutoSizer>
        {({ height, width }) => (
          <VariableSizeList
            ref={listRef}
            height={height}
            width={width}
            itemCount={visibleArticles.length}
            itemSize={getItemSize}  // memoized lookup by index
            overscanCount={3}
          >
            {({ index, style }) => (
              <div style={style}>
                <NewsCard article={visibleArticles[index]} onHeightChange={() => listRef.current?.resetAfterIndex(index)} />
              </div>
            )}
          </VariableSizeList>
        )}
      </AutoSizer>
      {/* Sentinel: OUTSIDE the VariableSizeList container */}
      <div ref={sentinelRef} style={{ height: 1 }} />
      {isFetchingNextPage && <FeedLoadingRow />}
    </>
  )
  ```

- [ ] **NEWS-003F** Create `src/hooks/useInfiniteScroll.ts`:
  ```ts
  export function useInfiniteScroll(callback: () => void, enabled: boolean) {
    const sentinelRef = useRef<HTMLDivElement>(null)
    useEffect(() => {
      if (!enabled) return
      const observer = new IntersectionObserver(
        (entries) => { if (entries[0]?.isIntersecting) callback() },
        { rootMargin: '200px' }  // trigger 200px before end of visible list
      )
      if (sentinelRef.current) observer.observe(sentinelRef.current)
      return () => observer.disconnect()
    }, [callback, enabled])
    return sentinelRef
  }
  ```
  Usage: `const sentinelRef = useInfiniteScroll(fetchNextPage, hasNextPage && !isFetchingNextPage)`

- [ ] **NEWS-003G** Build `FeedSkeleton` (count prop): renders N pulse-animated card skeletons at correct heights

- [ ] **NEWS-003H** Build `FeedEmptyState`: "No articles match your filters" with "Edit Topics" CTA

- [ ] **NEWS-003I** Build filter tabs (above feed, below top bar):
  - One tab per active topic + "All" tab
  - Tab click: `setActiveTab(topic)` → client-side filter of `visibleArticles`
  - Scrollable horizontally on mobile

- [ ] **NEWS-003J** Sort toggle (top right of feed): Recency / Relevance / Trending — calls `setSortOrder` → triggers refetch via key change

### Tests
- [ ] `useNewsFeed` flattens pages via `useMemo` — reference is stable when pages unchanged
- [ ] `normalizeUrl` strips `utm_source`, `fbclid`, normalizes protocol and trailing slash
- [ ] Dedup: two articles with same normalized URL → only first shown
- [ ] Hidden articles are excluded from `visibleArticles`
- [ ] When `isPaused`, new articles from refetch appear in `pendingArticleIds`, not in feed
- [ ] `NewArticlesBanner` renders when `pendingCount > 0`; flush click resets count
- [ ] `useInfiniteScroll`: `fetchNextPage` not called when `isFetchingNextPage` is true
- [ ] Sentinel div is rendered outside `VariableSizeList` container (DOM test)
- [ ] `FeedSkeleton` renders correct count of skeleton elements
- [ ] `FeedEmptyState` renders when `visibleArticles.length === 0`
- [ ] Sort toggle changes `sortOrder` and the infinite query key changes

### Definition of Done
- `useNewsFeed` with memoized flat article list, dedup, and hidden-article filter
- Sentinel-outside-list pattern for IO trigger
- Pause/pending buffer with banner
- Skeleton, error, and empty states for all cases

### Anti-Patterns
- ❌ Sentinel inside `VariableSizeList` scroll container — triggers against wrong root
- ❌ Calling `fetchNextPage` without `!isFetchingNextPage` guard — queues duplicate requests
- ❌ `data.pages.flatMap(p => p.articles)` inline in render — must be `useMemo`
- ❌ URL dedup on raw URL strings — normalize first (strip UTM params)


## 🃏 Task NEWS-004: NewsCard Component
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** NEWS-003

### Related Files
`src/components/news/NewsCard.tsx` · `src/components/news/SentimentDot.tsx` · `src/components/news/TrustBadge.tsx`

### Subtasks

**Card Layout:**
- [ ] **NEWS-004A** Build `NewsCard`:
  ```tsx
  interface NewsCardProps {
    article: Article
    onHeightChange: () => void  // called after expand/collapse so VirtualList can resize
  }
  ```
  Layout (top to bottom):
  - Row 1: Source logo (24×24) + source name + trust badge + bullet + relative timestamp + read-time
  - Row 2: Headline (2-line clamp, `font-semibold`)
  - Row 3: Image (if present, `aspect-video`, lazy-loaded)
  - Row 4: AI summary (italic, 2-line clamp by default)
  - Row 5: Topic tags + sentiment dot
  - Row 6: Actions row (Bookmark, Share, Open, Hide, Expand)

- [ ] **NEWS-004B** Implement read state visual treatment:
  - If `readArticleIds.includes(article.id)`: apply `opacity-60` to headline + image, `line-through` on title is too aggressive — use muted color instead
  - Card border: subtle left accent bar (colored per topic)
  - Unread articles: normal opacity

- [ ] **NEWS-004C** Build `SentimentDot`:
  - Positive: green dot + `aria-label="Sentiment: Positive"`
  - Neutral: yellow dot + `aria-label="Sentiment: Neutral"`
  - Negative: red dot + `aria-label="Sentiment: Negative"`
  - Slow pulse animation (`opacity` keyframes, `useReducedMotion` guard)
  - Tooltip showing sentiment score on hover

- [ ] **NEWS-004D** Build `TrustBadge`:
  - High: green chip with text "High trust"
  - Medium: yellow chip with text "Medium trust"
  - Low: red chip with text "Low trust"
  - `aria-label="Source trust level: High"` (full label on the element)
  - Never color-only — text is visible, not just `sr-only`

- [ ] **NEWS-004E** Implement card expand/collapse:
  - "Expand" button below AI summary shows full summary text
  - Use `motion.div` with `layout` prop for height animation
  - After transition: call `props.onHeightChange()` → triggers `listRef.current.resetAfterIndex(index)`

- [ ] **NEWS-004F** Actions:
  - **Bookmark**: `markSaved(article.id)` in Zustand + `db.articles.put(article)` in Dexie; toggled state reflected instantly
  - **Share**: `if (navigator.share) { navigator.share({ title, url }) } else { navigator.clipboard.writeText(url); toast('Link copied') }`
  - **Open**: opens `article.url` in new tab; calls `markRead(article.id)` on click
  - **Hide**: calls `hideArticle(article.id)` (local session state); card disappears from feed

- [ ] **NEWS-004G** Keyboard accessibility:
  - All action buttons keyboard-reachable via `Tab`
  - Min 44×44px touch targets on mobile (WCAG 2.5.8)
  - `role="article"`, `aria-label={article.title}`

- [ ] **NEWS-004H** Reading time display:
  - `"${article.readTimeMinutes} min read"` beside timestamp
  - For articles where `wordCount` is null: omit display

### Tests
- [ ] Read articles render with muted opacity; unread are normal
- [ ] `SentimentDot` has correct color AND `aria-label` text (not color-only)
- [ ] `TrustBadge` text is visible (not `sr-only`) — snapshot test
- [ ] Expand/collapse calls `onHeightChange` after animation
- [ ] Bookmark: sets Zustand `savedArticleIds` + writes to Dexie (integration test with mock Dexie)
- [ ] Open article: calls `markRead` with article ID
- [ ] Hide: removes article from `hiddenArticleIds` — confirms article absent from feed after hide
- [ ] Share: on unsupported browser, falls back to `navigator.clipboard.writeText` + toast
- [ ] All action buttons meet 44px target on mobile viewport (visual regression)

### Definition of Done
- Card displays all fields with read-state visual treatment
- All actions functional with correct side effects
- `SentimentDot` and `TrustBadge` are not color-only (WCAG 1.4.1)
- Expand/collapse correctly resizes VirtualList row

### Anti-Patterns
- ❌ `navigator.share()` without capability check — throws on Firefox desktop
- ❌ Sentiment dot or trust badge as color-only — WCAG 1.4.1 failure
- ❌ `line-through` for read articles — too aggressive; use opacity/muted color
- ❌ Not calling `resetAfterIndex` after card expand — VirtualList renders with wrong row heights


## 📖 Task NEWS-005: Bookmarks, Read Status & Offline
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** NEWS-004

### Related Files
`src/lib/db.ts` · `src/hooks/useBookmarks.ts` · `src/hooks/useReadStatus.ts` · `src/components/news/SavedView.tsx`

### Subtasks

- [ ] **NEWS-005A** Install dependencies:
  ```bash
  pnpm add dexie dexie-react-hooks
  ```

- [ ] **NEWS-005B** Create `src/lib/db.ts`:
  ```ts
  import Dexie, { type Table } from 'dexie'

  interface SavedArticle extends Article {
    savedAt: number  // Date.now() timestamp
  }

  interface ReadRecord {
    id: string        // article ID
    readAt: number    // timestamp
    url: string       // for dedup across sessions
  }

  class NewsDB extends Dexie {
    articles!: Table<SavedArticle, string>
    readStatus!: Table<ReadRecord, string>

    constructor() {
      super('NewsDB')
      this.version(1).stores({
        articles: 'id, savedAt, *topics',   // * = multi-value index for topic queries
        readStatus: 'id, readAt, url',
      })
    }
  }

  export const db = new NewsDB()
  ```

- [ ] **NEWS-005C** Create `src/hooks/useBookmarks.ts`:
  ```ts
  export function useBookmarks() {
    const articles = useLiveQuery(() =>
      db.articles.orderBy('savedAt').reverse().toArray(), []
    )
    const save = async (article: Article) => {
      await db.articles.put({ ...article, savedAt: Date.now() })
      markSaved(article.id)  // Zustand sync
    }
    const remove = async (id: string) => {
      await db.articles.delete(id)
      markUnsaved(id)  // Zustand sync
    }
    return { articles: articles ?? [], save, remove }
  }
  ```

- [ ] **NEWS-005D** Create `src/hooks/useReadStatus.ts`:
  ```ts
  export function useReadStatus() {
    const readRecords = useLiveQuery(() => db.readStatus.toArray(), [])
    const readIds = useMemo(
      () => new Set(readRecords?.map(r => r.id) ?? []),
      [readRecords]
    )
    const markRead = async (article: Article) => {
      await db.readStatus.put({ id: article.id, readAt: Date.now(), url: article.url })
      markReadInSlice(article.id)  // Zustand sync
    }
    const markAllRead = async (articles: Article[]) => {
      const records = articles.map(a => ({ id: a.id, readAt: Date.now(), url: a.url }))
      await db.readStatus.bulkPut(records)  // batch — much faster than sequential put
      markAllReadInSlice(articles.map(a => a.id))
    }
    return { readIds, markRead, markAllRead }
  }
  ```

- [ ] **NEWS-005E** On app boot, sync Dexie → Zustand:
  ```ts
  // In NewsPage or app init
  useEffect(() => {
    Promise.all([
      db.articles.toCollection().primaryKeys(),
      db.readStatus.toCollection().primaryKeys(),
    ]).then(([savedIds, readIds]) => {
      setInitialSavedRead(savedIds, readIds)  // single Zustand action
    })
  }, [])
  ```

- [ ] **NEWS-005F** Build `SavedView` component:
  - Reads from `db.articles` via `useLiveQuery`
  - Renders a `VariableSizeList` of saved articles (same `NewsCard` component)
  - Sort options: By saved date (default), By title, By source
  - Search input: client-side filter by title/source
  - Empty state: "No saved articles yet — bookmark articles to read later"
  - Each card has "Remove from saved" button (replaces "Bookmark" action)

- [ ] **NEWS-005G** Handle IndexedDB quota:
  - On any Dexie write, catch `QuotaExceededError`
  - Show toast: "Storage almost full — remove some saved articles to continue saving"

- [ ] **NEWS-005H** (Optional stretch) PWA offline via `vite-plugin-pwa`:
  - Cache-first strategy for saved article content
  - Network-first for feed API

### Tests
- [ ] `useLiveQuery` from `useBookmarks` re-renders when `db.articles` changes
- [ ] `save()` writes to Dexie AND updates Zustand `savedArticleIds`
- [ ] `remove()` deletes from Dexie AND removes from Zustand `savedArticleIds`
- [ ] `markAllRead` uses `bulkPut` (not sequential `put`) — spy on `db.readStatus.bulkPut`
- [ ] Boot sync: Dexie primary keys are loaded into Zustand on mount
- [ ] `SavedView` renders saved articles sorted by `savedAt` descending by default
- [ ] `QuotaExceededError` from Dexie write triggers toast, does not crash

### Definition of Done
- Dexie schema with `articles` and `readStatus` tables
- `useLiveQuery` for reactive reads in both hooks
- `bulkPut` for mark-all-read batch operation
- Boot sync from Dexie to Zustand
- Saved view with sort and search

### Anti-Patterns
- ❌ Sequential `db.readStatus.put()` in a loop for mark-all-read — use `bulkPut`
- ❌ `useLiveQuery` with no initial value — always provide `[]` as fallback to prevent hydration flash
- ❌ Calling Dexie operations inside `useEffect` without error handling — always `try/catch` for `QuotaExceededError`
- ❌ Treating Zustand as source of truth for saved/read state — Dexie is authoritative; Zustand is a quick-lookup mirror


## 📖 Task NEWS-006: In-App Article Reader Mode
**Priority:** 🟠 Medium | **Est. Effort:** 2.5 hours | **Depends On:** NEWS-005

### Related Files
`src/components/news/ArticleReaderPanel.tsx` · `src/hooks/useArticleContent.ts` · `src/components/news/ReaderControls.tsx`

### Subtasks

- [ ] **NEWS-006A** Install `@mozilla/readability`:
  ```bash
  pnpm add @mozilla/readability
  ```

- [ ] **NEWS-006B** Create `src/hooks/useArticleContent.ts`:
  ```ts
  export function useArticleContent(articleId: string | null) {
    return useQuery({
      queryKey: newsKeys.article(articleId!),
      queryFn: async () => {
        const raw = await fetchArticleHtml(articleId!)  // hits /api/news/articles/:id
        const doc = new DOMParser().parseFromString(raw.fullContent, 'text/html')
        const reader = new Readability(doc)
        const parsed = reader.parse()
        if (!parsed) throw new Error('Could not parse article content')
        return parsed  // { title, content, byline, length, excerpt }
      },
      enabled: articleId !== null,
      staleTime: Infinity,  // article content doesn't change
    })
  }
  ```

- [ ] **NEWS-006C** Build `ArticleReaderPanel` as a slide-in side panel (full-height, 600px wide on desktop; full-screen on mobile):
  - Opens when user clicks "Read in app" from a card's action row
  - Entrance: cross-fade spring animation (Alive tier, `useReducedMotion` guard)
  - Close: `Escape` key or ×  button; restores focus to triggering card

- [ ] **NEWS-006D** Panel layout:
  - Header: source logo + publication name + original `Open in browser` link
  - Byline: `parsed.byline` (author + date)
  - Reading time + reading progress bar (scrollY-based `%` calculation)
  - Article body: `parsed.content` rendered via `dangerouslySetInnerHTML` with strict content sanitization (DOMPurify — see NEWS-006E)
  - Footer: Bookmark + Share actions

- [ ] **NEWS-006E** Sanitize extracted HTML:
  ```bash
  pnpm add dompurify @types/dompurify
  ```
  ```ts
  const clean = DOMPurify.sanitize(parsed.content, {
    ALLOWED_TAGS: ['p', 'h1', 'h2', 'h3', 'h4', 'blockquote', 'ul', 'ol', 'li', 'strong', 'em', 'a', 'img', 'figure', 'figcaption', 'pre', 'code'],
    ALLOWED_ATTR: ['href', 'src', 'alt', 'target', 'rel'],
  })
  ```
  All external links get `target="_blank" rel="noopener noreferrer"` added automatically

- [ ] **NEWS-006F** Build `ReaderControls` panel (toggle button in reader header):
  - Font size slider: 14px → 22px (maps to Tailwind `text-sm` → `text-xl`)
  - Font family selector: Sans / Serif / Mono
  - Line height slider: 1.4 → 2.0
  - Theme toggle: Light / Sepia / Dark
  - All controls write to `newsSlice.readerPrefs` (persisted)

- [ ] **NEWS-006G** Reading progress bar:
  - Thin bar at top of panel (4px, accent color)
  - Width = `(scrollTop / (scrollHeight - clientHeight)) * 100`%
  - Updates on scroll via `onScroll` handler on panel container

- [ ] **NEWS-006H** On reader open: call `markRead(article)` — marks article as read in Dexie

### Tests
- [ ] `useArticleContent` calls Readability with parsed DOM; returns `{ title, content, byline }`
- [ ] Readability parse failure throws, query enters error state
- [ ] Panel opens with spring animation; closes on `Escape`; focus returns to card
- [ ] `DOMPurify` strips `<script>` tags and `onclick` attributes from article content
- [ ] All external links in sanitized content have `rel="noopener noreferrer"`
- [ ] Reading progress bar updates correctly at 0%, 50%, and 100% scroll
- [ ] `ReaderControls` font-size change applies immediately to article body
- [ ] Opening reader calls `markRead` (integration test with Dexie mock)

### Definition of Done
- Article content extracted via `@mozilla/readability` + sanitized via DOMPurify
- Reader panel with font, theme, and line-height controls
- Reading progress bar
- Marks article as read on open

### Anti-Patterns
- ❌ Rendering `parsed.content` without DOMPurify sanitization — XSS vulnerability
- ❌ `staleTime: 0` for article content — article text doesn't change; use `Infinity`
- ❌ `dangerouslySetInnerHTML={{ __html: raw }}` without parsing through Readability first — raw HTML has ads/navigation
- ❌ Opening external links without `rel="noopener noreferrer"` — security vulnerability


## 🔎 Task NEWS-007: Article Search & Advanced Filtering
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** NEWS-003, NEWS-004

### Related Files
`src/components/news/SearchPanel.tsx` · `src/hooks/useArticleSearch.ts` · `src/components/news/AdvancedFilters.tsx`

### Subtasks

- [ ] **NEWS-007A** Build `SearchPanel` triggered by search icon in top bar:
  - Slides down below top bar (replaces filter tabs while open)
  - Debounced input (300ms): writes to `newsSlice.searchQuery`
  - Close: `Escape` key or clicking outside; restores focus to search icon

- [ ] **NEWS-007B** Create `src/hooks/useArticleSearch.ts`:
  ```ts
  export function useArticleSearch(query: string, articles: Article[]) {
    return useMemo(() => {
      if (query.trim().length < 2) return []
      const lower = query.toLowerCase()
      return articles
        .filter(a =>
          a.title.toLowerCase().includes(lower) ||
          a.summary.toLowerCase().includes(lower) ||
          a.aiSummary.toLowerCase().includes(lower) ||
          a.source.name.toLowerCase().includes(lower)
        )
        .slice(0, 30)  // cap results to prevent render overload
    }, [query, articles])
  }
  ```

- [ ] **NEWS-007C** Render search results in `SearchPanel`:
  - Results grouped: first 5 are "Best matches", rest under "More results"
  - Each result: source logo + title with matched terms highlighted in `<mark>`
  - Term highlighting:
    ```ts
    function highlightTerms(text: string, query: string): ReactNode {
      const regex = new RegExp(`(${escapeRegex(query)})`, 'gi')
      const parts = text.split(regex)
      return parts.map((part, i) =>
        regex.test(part) ? <mark key={i} className="bg-yellow-300/30 text-inherit">{part}</mark> : part
      )
    }
    ```
  - Click result: closes search panel, scrolls feed to article, opens reader

- [ ] **NEWS-007D** Keyboard navigation within results:
  - `ArrowUp/Down`: move focus between result items
  - `Enter`: open focused result
  - Announce result count via `aria-live="polite"` region: "12 results for 'AI'"

- [ ] **NEWS-007E** Recent searches:
  - Store last 5 queries in `localStorage` (keyed separately, not in Zustand)
  - Show below empty input as "Recent: [query chips]"
  - Click chip: populate input and search

- [ ] **NEWS-007F** Build `AdvancedFilters` panel (accessible from "Filters" button next to search):
  - Date range: Today / This week / This month / Custom
  - Sentiment filter: Positive only / Neutral only / Negative only / All
  - Source filter: multi-select (same sources as sidebar)
  - Min/max reading time slider
  - All filters apply to `visibleArticles` via `useArticleSearch` or a separate `applyAdvancedFilters` utility

### Tests
- [ ] `useArticleSearch`: query of length < 2 returns empty array
- [ ] Results include articles matching title, summary, aiSummary, and source name
- [ ] Results capped at 30 items
- [ ] Matched terms are wrapped in `<mark>` elements with correct text
- [ ] `escapeRegex` correctly escapes special regex characters in query
- [ ] Keyboard: `ArrowDown` moves focus to first result from input
- [ ] `aria-live` region announces result count
- [ ] Recent searches: last 5 queries persist to localStorage after search

### Definition of Done
- Search panel with debounced input, highlighted results, keyboard navigation
- `aria-live` result count announcement
- Recent searches from localStorage
- Advanced filters (date range, sentiment, reading time)

### Anti-Patterns
- ❌ Unescaped user input in `RegExp` constructor — throws for special characters like `(`, `[`
- ❌ Searching API on every keystroke — client-side filter of cached articles only; debounce for UX
- ❌ Rendering 100+ highlighted results at once — cap at 30; add "Show more" if needed


## 🔊 Task NEWS-008: Audio Summaries
**Priority:** 🟢 Low | **Est. Effort:** 1 hour | **Depends On:** NEWS-004

### Related Files
`src/hooks/useAudioSummary.ts` · `src/components/news/AudioPlayer.tsx`

### Subtasks

- [ ] **NEWS-008A** Create `src/hooks/useAudioSummary.ts`:
  ```ts
  export function useAudioSummary() {
    const [activeArticleId, setActiveArticleId] = useState<string | null>(null)
    const utteranceRef = useRef<SpeechSynthesisUtterance | null>(null)

    const play = (article: Article) => {
      if (!('speechSynthesis' in window)) return
      window.speechSynthesis.cancel()  // stop any in-progress playback
      const utterance = new SpeechSynthesisUtterance(article.aiSummary)
      utterance.rate = playbackRate  // from newsSlice.readerPrefs
      utterance.onend = () => setActiveArticleId(null)
      utteranceRef.current = utterance
      setActiveArticleId(article.id)
      window.speechSynthesis.speak(utterance)
    }

    const pause = () => window.speechSynthesis.pause()
    const resume = () => window.speechSynthesis.resume()
    const stop = () => {
      window.speechSynthesis.cancel()
      setActiveArticleId(null)
    }

    // Cleanup on unmount
    useEffect(() => () => { window.speechSynthesis.cancel() }, [])

    return { play, pause, resume, stop, activeArticleId }
  }
  ```
  Note: **never gate on `useReducedMotion`** — audio has no connection to motion preference.

- [ ] **NEWS-008B** Build `AudioPlayer` floating widget (bottom of screen when active):
  - Shows current article title + source
  - Controls: Play/Pause, Stop, speed selector (0.75×, 1×, 1.25×, 1.5×, 2×)
  - `aria-live="polite"` for playback state changes

- [ ] **NEWS-008C** "Read Aloud" button on card (visible when `audioEnabled` is true in `newsSlice`):
  - Clicking: `play(article)` → starts playback, shows `AudioPlayer` widget
  - If another article is playing: stops it, starts the new one

- [ ] **NEWS-008D** Voice selector (if `speechSynthesis.getVoices().length > 1`):
  - Show dropdown in `AudioPlayer` widget
  - Persist selected voice name to `newsSlice.readerPrefs`

- [ ] **NEWS-008E** Capability check gate:
  - If `!('speechSynthesis' in window)`: hide "Read Aloud" button entirely
  - Show no error — silent graceful degradation

### Tests
- [ ] `play()` calls `window.speechSynthesis.speak` with correct text
- [ ] `stop()` calls `window.speechSynthesis.cancel()` and clears `activeArticleId`
- [ ] Starting a second article stops first (via `cancel()` before `speak()`)
- [ ] `useReducedMotion` is NOT checked — audio enabled state is `newsSlice.audioEnabled` only
- [ ] AudioPlayer renders when `activeArticleId` is set; disappears after `stop()`
- [ ] Read aloud button hidden when `speechSynthesis` not in `window` (mock `window`)

### Definition of Done
- Audio playback of AI summaries via Web Speech API
- Floating `AudioPlayer` widget with speed control
- Graceful degradation on unsupported browsers
- Audio gated only on `audioEnabled` preference — not motion preference

### Anti-Patterns
- ❌ `useReducedMotion()` to disable audio — motion preference has no bearing on TTS
- ❌ Not calling `window.speechSynthesis.cancel()` before starting new utterance — overlapping speech
- ❌ Showing error when `speechSynthesis` unsupported — silently hide the button


## 📊 Dependency Graph

```
NEWS-000 (Mock Data + Queries)
    │
NEWS-001 (State Slice + Route)
    │
    ├── NEWS-002 (Page Layout + Sidebar + Pref Sync)
    │
    ├── NEWS-003 (Feed Infrastructure: pagination, dedup, pause/buffer)
    │        │
    │    NEWS-004 (NewsCard: read state, actions, virtualization resize)
    │        │
    │        ├── NEWS-005 (Bookmarks + Read Status + Dexie)
    │        │        │
    │        │    NEWS-006 (Reader Mode: Readability + DOMPurify + prefs)
    │        │
    │        └── NEWS-007 (Search + Advanced Filters)
    │
    └── NEWS-008 (Audio Summaries — optional, Low priority)
```


## 🏁 Module Completion Checklist

**Foundation:**
- [ ] Mock factories: article (all fields including `wordCount`, `sentimentLabel`, `fullContent`), topic, source, preferences
- [ ] `newsKeys` factory covers feed (with filters), article, topics, sources, preferences
- [ ] `feedInfiniteQueryOptions` with `staleTime: 30s`, `gcTime: 10min`
- [ ] `newsSlice`: `string[]` (not `Set`) for saved/read IDs; `audioEnabled` not gated on motion

**Feed & Cards:**
- [ ] `useNewsFeed`: memoized flat list, dedup (with URL normalization), hidden-article filter
- [ ] Sentinel div for IO trigger is OUTSIDE `VariableSizeList` container
- [ ] `fetchNextPage` guarded with `!isFetchingNextPage && hasNextPage`
- [ ] Pause + pending buffer + "N new articles" banner + flush action
- [ ] Skeleton, error state with retry, empty state for feed
- [ ] `NewsCard` with read-state visual treatment (opacity, not strikethrough)
- [ ] `SentimentDot` and `TrustBadge` include visible text, not color-only (WCAG 1.4.1)
- [ ] Card expand/collapse calls `listRef.resetAfterIndex` after height change
- [ ] Web Share API with explicit clipboard fallback

**Offline & Storage:**
- [ ] Dexie schema: `articles` + `readStatus` tables with appropriate indexes
- [ ] `useLiveQuery` for reactive bookmark and read-status reads
- [ ] `bulkPut` for mark-all-read batch
- [ ] Boot sync from Dexie to Zustand on first mount
- [ ] IndexedDB quota error handling

**Reader Mode:**
- [ ] `@mozilla/readability` for content extraction
- [ ] `DOMPurify` sanitization with strict allowlist
- [ ] External links get `rel="noopener noreferrer"`
- [ ] Reading progress bar, font/theme/line-height controls
- [ ] Reader open triggers mark-as-read

**Search:**
- [ ] Debounced search panel with term highlighting via `<mark>`
- [ ] `escapeRegex` utility for safe user input in RegExp
- [ ] `aria-live` result count announcement
- [ ] Recent searches from localStorage
- [ ] Advanced filters: date range, sentiment, reading time

**Audio:**
- [ ] Web Speech API with `cancel()` before new utterance
- [ ] Audio gated on `audioEnabled` preference only (never `useReducedMotion`)
- [ ] Silent degradation on unsupported browsers

**Accessibility:**
- [ ] WCAG 1.4.1: all color indicators (sentiment, trust) have text labels
- [ ] WCAG 2.2 auto-update: pause/buffer/flush pattern for feed
- [ ] WCAG 2.5.8: 44px touch targets on all card actions
- [ ] `role="article"`, `aria-label` on all cards
- [ ] `aria-live` for search count and audio state

**Testing:**
- [ ] All tasks have passing tests per their `### Tests` sections
- [ ] `pnpm test` passes for news domain
- [ ] Dexie operations tested with in-memory mock (`fake-indexeddb`)
- [ ] Web Share API tested with `navigator.share` mock