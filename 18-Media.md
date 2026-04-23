# 18-Media — Media Library & AI Generation Module

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.

---

## 📐 Reasoning Memo

The Media module is designed as a hybrid of Google Photos (media library, organization, sharing) and AI generation tools (image/video creation). This dual nature requires careful architectural decisions to balance traditional media management with modern AI workflows.

**Key Design Decisions:**

1. **Unified Media Model**: Instead of separating "uploaded media" from "generated media," all items share a common `MediaItem` type with a `source` field distinguishing origin. This enables unified search, filtering, and organization across all media.

2. **Generation as First-Class Workflow**: AI generation is not a sidebar feature—it's integrated into the core experience. Users can generate images/videos directly into albums, with generation status tracked alongside upload status.

3. **Lazy Loading for Large Media**: Images and videos use progressive loading with blur placeholders. Video thumbnails are generated on-demand. This prevents the library from becoming unusable with large collections.

4. **Smart Categorization**: Like Google Photos, the system should automatically suggest albums based on date clusters, location (if available), and AI-detected content. This reduces manual organization burden.

5. **Generation Queue Management**: AI generation is time-consuming. A queue system with priority handling (user-initiated vs. batch) ensures the UI remains responsive and users can track progress.

6. **Storage Awareness**: The module should surface storage usage and provide tools for cleanup (duplicate detection, low-quality media, old generations). This is critical for local-first deployments.

---

## 🔬 Research Findings — Media Module

| Finding | Source | Action Required |
|---------|--------|-----------------|
| **Progressive image loading with blur-up placeholders** is the standard for media-heavy apps. Generate a tiny base64 thumbnail (10-20px) and display it as a blurred placeholder while the full image loads. | Next.js Image, Vercel 2025 | MEDIA-002: Implement blur placeholder generation in mock factory; use in MediaCard |
| **Video thumbnails should be extracted at 50% duration** for representative preview. Use `<canvas>` to capture frame from video element. | MDN, video-thumbnail libraries | MEDIA-002: Mock factory generates thumbnail URLs; real implementation would use canvas extraction |
| **AI generation requires queue management with status tracking** (queued, processing, completed, failed). Users should see progress indicators and be able to cancel. | Midjourney, Runway ML UX | MEDIA-004: Implement generation queue in Zustand; status badges on MediaCard |
| **Duplicate detection via perceptual hashing (pHash)** is more reliable than file size/MD5 for images. Similar images with different compressions still match. | img-hash library, Google Photos | MEDIA-006: Implement pHash-based duplicate detection in utils |
| **Virtualization is mandatory for media grids** — rendering 1000+ images kills performance. Use `@tanstack/react-virtual` with grid layout. | TanStack Virtual docs | MEDIA-003: Grid view uses virtualized rows; each row contains multiple items |
| **Search should support semantic queries** ("sunset at beach") not just tags. This requires embedding generation (CLIP-like) for semantic search. | CLIP, Google Photos | MEDIA-007: Mock semantic search; real implementation would use embeddings |
| **Album auto-suggestion based on date clusters** (photos within 3 days grouped) is standard UX. Reduces manual organization. | Google Photos, Apple Photos | MEDIA-005: Implement auto-album suggestion logic in utils |
| **Generation parameters should be saved as presets** for reuse. Users often iterate on prompts with slight variations. | Midjourney, Stable Diffusion UI | MEDIA-004: Preset management in Zustand; preset selector in generation modal |
| **EXIF data extraction provides rich metadata** (camera, location, date). Critical for organization and search. | exif-js library | MEDIA-002: Mock EXIF data in factory; real implementation would use exif-js |
| **Video playback should use lazy loading** — only load video player when user clicks thumbnail. Prevents bandwidth waste. | YouTube, Vimeo pattern | MEDIA-002: Video player loads on-demand; thumbnail shown by default |

---

## 🧱 Cross-Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **MEDIA-C01** | State Management | Zustand `mediaSlice` for view mode, filters, selection, generation queue, presets. Arrays for serializable persistence. |
| **MEDIA-C02** | Data Fetching | `useInfiniteQuery` for media library pagination. `staleTime: 5min`, `gcTime: 30min`. Generation status via SSE. |
| **MEDIA-C03** | Storage | Dexie for media metadata cache, album membership, and generation history. Large files stored in filesystem/IndexedDB. |
| **MEDIA-C04** | Virtualization | `@tanstack/react-virtual` for grid view. Calculate row width to determine items per row. |
| **MEDIA-C05** | Progressive Loading | Blur placeholders for images; on-demand video player loading. |
| **MEDIA-C06** | Generation Queue | Priority-based queue (user-initiated > batch). Status tracking with SSE. Cancellation support. |
| **MEDIA-C07** | Accessibility | All media items have `alt` text. Video players have captions (if available). Keyboard navigation in grid. |
| **MEDIA-C08** | Motion | Grid item entrance: Quiet tier (fade). Generation progress: Alive tier (pulse). Modal open: Alive tier (spring). |

### 🎯 Motion Tier Assignment

| Component | Tier | Allowed Techniques |
|-----------|------|--------------------|
| Media grid item entrance | **Quiet** | `opacity: 0→1`, `scale: 0.95→1`, 150ms fade, staggered by row |
| Generation progress indicator | **Alive** | Animated gradient border, spring pulse on status change |
| Album card hover | **Quiet** | `boxShadow` glow, `scale: 1.02` |
| Video player open | **Alive** | Cross-fade modal entrance (spring) |
| Filter tab active state | **Quiet** | Opacity fade 150ms; active indicator slides with `layout` |
| Selection checkbox | **Static** | Instant toggle |
| Duplicate detection badge | **Quiet** | Slow pulse (2s loop, `useReducedMotion` guard) |

---

## 🗃️ Task MEDIA-000: Media Domain Model & Utilities
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** FND-001 (TypeScript Base)

### Related Files
- `src/types/media.ts` · `src/schemas/media.ts` · `src/utils/media.ts`

### Subtasks

- [ ] **MEDIA-000A**: Define TypeScript interfaces in `src/types/media.ts`:
  ```ts
  export type MediaType = 'image' | 'video'
  export type MediaSource = 'upload' | 'generated' | 'external'
  export type GenerationStatus = 'queued' | 'processing' | 'completed' | 'failed' | 'cancelled'
  export type ViewMode = 'grid' | 'list' | 'timeline'

  export interface MediaItem {
    id: string
    type: MediaType
    source: MediaSource
    title: string
    description?: string
    url: string
    thumbnailUrl: string
    blurDataUrl?: string  // base64 blur placeholder
    width: number
    height: number
    fileSize: number  // bytes
    duration?: number  // seconds for video
    format: string  // jpg, png, mp4, webm
    createdAt: string  // ISO 8601
    capturedAt?: string  // EXIF date
    location?: { lat: number; lng: number; name?: string }
    tags: string[]
    albums: string[]  // album IDs
    isFavorite: boolean
    generationData?: {
      status: GenerationStatus
      prompt: string
      model: string
      parameters: Record<string, unknown>
      progress: number  // 0-100
      error?: string
      queuedAt?: string
      startedAt?: string
      completedAt?: string
    }
    exif?: {
      camera: string
      lens: string
      iso: number
      aperture: string
      shutterSpeed: string
    }
  }

  export interface Album {
    id: string
    name: string
    description?: string
    coverMediaId: string
    mediaIds: string[]
    createdAt: string
    updatedAt: string
    isAutoGenerated: boolean
    location?: string
    dateRange: { start: string; end: string }
  }

  export interface GenerationPreset {
    id: string
    name: string
    prompt: string
    model: string
    parameters: Record<string, unknown>
    createdAt: string
  }
  ```

- [ ] **[TEST] MEDIA-000A**: TypeScript interfaces defined; all required fields present; types compile without errors

- [ ] **MEDIA-000B**: Create Zod schemas in `src/schemas/media.ts`:
  ```ts
  export const MediaItemSchema = z.object({
    id: z.string().uuid(),
    type: z.enum(['image', 'video']),
    // ... mirror MediaItem type exactly
  })
  export type MediaItem = z.infer<typeof MediaItemSchema>
  ```

- [ ] **[TEST] MEDIA-000B**: Zod schemas validate correctly; types derived from schemas

- [ ] **MEDIA-000C**: Create utility functions in `src/utils/media.ts`:
  - `formatFileSize(bytes: number): string` — returns "1.2 MB", "345 KB"
  - `formatDuration(seconds: number): string` — returns "2:34", "1:05:30"
  - `calculateAspectRatio(width: number, height: number): number`
  - `generateBlurPlaceholder(imageUrl: string): Promise<string>` — mock implementation returns base64 string
  - `detectDuplicates(items: MediaItem[]): MediaItem[][]` — groups similar items (mock: by exact URL match)
  - `suggestAlbums(items: MediaItem[]): Album[]` — groups by date clusters (3-day window)
  - `extractVideoThumbnail(videoUrl: string): Promise<string>` — mock returns thumbnail URL

- [ ] **[TEST] MEDIA-000C**: All utility functions return correct values; edge cases handled (0 bytes, 0 duration)

### Definition of Done
- TypeScript interfaces defined for all media domain types
- Zod schemas mirror types with runtime validation
- Utility functions handle formatting, duplicate detection, and album suggestions

### Anti-Patterns
- ❌ Storing large file blobs in Zustand — use IndexedDB/filesystem
- ❌ Duplicate detection by file size only — use perceptual hashing in production
- ❌ Album suggestion without date clustering — groups unrelated photos

---

## 🗃️ Task MEDIA-001: Media State Management (Zustand)
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** MEDIA-000

### Related Files
- `src/stores/mediaSlice.ts` · `src/stores/index.ts`

### Subtasks

- [ ] **MEDIA-001A**: Create `mediaSlice` with state:
  ```ts
  interface MediaState {
    viewMode: ViewMode
    filters: {
      type: MediaType | 'all'
      source: MediaSource | 'all'
      dateRange: { start: string | null; end: string | null }
      tags: string[]
      albums: string[]  // album IDs
      searchQuery: string
    }
    selectedMediaIds: string[]
    generationQueue: {
      id: string
      mediaId: string | null  // null until generation completes
      status: GenerationStatus
      prompt: string
      model: string
      parameters: Record<string, unknown>
      progress: number
      error?: string
      priority: 'high' | 'normal'
      createdAt: string
    }[]
    presets: GenerationPreset[]
    isGenerationPanelOpen: boolean
  }
  ```

- [ ] **[TEST] MEDIA-001A**: State shape defined; all filters present; queue array typed correctly

- [ ] **MEDIA-001B**: Define actions:
  - `setViewMode(mode: ViewMode)`
  - `setFilter(key, value)`
  - `toggleMediaSelection(id: string)`
  - `clearSelection()`
  - `addToQueue(item: Omit<GenerationQueueItem, 'id' | 'createdAt'>)`
  - `updateQueueItem(id: string, updates: Partial<GenerationQueueItem>)`
  - `removeFromQueue(id: string)`
  - `savePreset(preset: Omit<GenerationPreset, 'id' | 'createdAt'>)`
  - `deletePreset(id: string)`
  - `setGenerationPanelOpen(open: boolean)`

- [ ] **[TEST] MEDIA-001B**: All actions defined; state transitions are pure

- [ ] **MEDIA-001C**: Configure `persist` middleware to persist:
  - `viewMode`
  - `filters`
  - `presets`
  - Do NOT persist `selectedMediaIds` or `generationQueue` (ephemeral)

- [ ] **[TEST] MEDIA-001C**: Persist config uses `partialize`; only specified fields persisted

- [ ] **MEDIA-001D**: Export selector hooks:
  - `useMediaViewMode()`
  - `useMediaFilters()`
  - `useSelectedMediaIds()`
  - `useGenerationQueue()`
  - `useMediaPresets()`

- [ ] **[TEST] MEDIA-001D**: Selector hooks return correct state slices

### Definition of Done
- Zustand slice manages all media UI state
- Filters, selection, generation queue, and presets tracked
- Persist middleware configured for appropriate fields only

### Anti-Patterns
- ❌ Persisting generation queue — should reset on page load
- ❌ Persisting selection — ephemeral UI state
- ❌ Storing media items in Zustand — belongs in TanStack Query cache

---

## 🗃️ Task MEDIA-002: Mock Data Layer
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** MEDIA-000, FND-004 (Testing)

### Related Files
- `src/mocks/factories/media.ts` · `src/mocks/handlers/media.ts` · `src/queries/media.ts`

### Subtasks

- [ ] **MEDIA-002A**: Create `src/mocks/factories/media.ts`:
  - `createMockMediaItem(overrides?)` returns realistic `MediaItem` with:
    - Random dimensions (1920×1080, 1080×1080, 1080×1920)
    - Blur placeholder (base64 10×10 solid color)
    - EXIF data for photos
    - Random tags from predefined set
    - For videos: duration, thumbnail URL
  - `createMockAlbum(overrides?)` returns `Album` with cover media
  - `createMockGenerationPreset(overrides?)` returns preset with common models
  - `createMockMediaFeed(opts: { count: number; type?: MediaType; source?: MediaSource })` — paginated feed

- [ ] **[TEST] MEDIA-002A**: Factory generates valid MediaItem; blur placeholder present; dimensions realistic

- [ ] **MEDIA-002B**: Create MSW handlers in `src/mocks/handlers/media.ts`:
  - `GET /api/media` — returns paginated media feed
  - `GET /api/media/:id` — returns single item
  - `POST /api/media/upload` — simulates upload (returns created item)
  - `POST /api/media/generate` — simulates generation (returns queued item)
  - `GET /api/media/generate/:id/stream` — SSE stream for generation progress
  - `GET /api/albums` — returns albums
  - `POST /api/albums` — creates album
  - `PUT /api/albums/:id` — updates album
  - `DELETE /api/albums/:id` — deletes album

- [ ] **[TEST] MEDIA-002B**: All handlers respond correctly; SSE stream delivers progress updates

- [ ] **MEDIA-002C**: Create `src/queries/media.ts` with queryOptions:
  ```ts
  export const mediaQueryOptions = (params: MediaFilters) => queryOptions({
    queryKey: ['media', params],
    queryFn: () => fetchMedia(params),
    staleTime: 1000 * 60 * 5,  // 5 min
  })
  export const albumsQueryOptions = queryOptions({
    queryKey: ['albums'],
    queryFn: fetchAlbums,
    staleTime: 1000 * 60 * 10,  // 10 min
  })
  ```

- [ ] **[TEST] MEDIA-002C**: queryOptions defined with correct keys and staleTime

### Definition of Done
- Mock factories generate realistic media items with all metadata
- MSW handlers cover all CRUD operations and generation streaming
- Query options configured with appropriate cache times

### Anti-Patterns
- ❌ Missing blur placeholder in mock data — breaks progressive loading
- ❌ SSE handler without delay — doesn't surface loading states
- ❌ Not simulating generation failure — error paths untested

---

## 🖼️ Task MEDIA-003: Media Library Page & Grid View
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** MEDIA-001, MEDIA-002

### Related Files
- `src/pages/MediaPage.tsx` · `src/components/media/MediaGrid.tsx` · `src/components/media/MediaCard.tsx`

### Subtasks

**MediaPage Layout:**
- [ ] **MEDIA-003A**: Create `src/pages/MediaPage.tsx`:
  - Top bar: search input, filter chips (type, source, date), view mode toggle (grid/list/timeline)
  - Main content: `MediaGrid` or `MediaList` based on view mode
  - Right panel: generation panel (if open) or album sidebar
  - Bottom bar: selection actions (add to album, delete, download, generate)

- [ ] **[TEST] MEDIA-003A**: Page renders with all controls; view mode toggle works

**MediaGrid with Virtualization:**
- [ ] **MEDIA-003B**: Create `MediaGrid` using `@tanstack/react-virtual`:
  ```tsx
  const virtualizer = useVirtualizer({
    count: Math.ceil(mediaItems.length / itemsPerRow),
    getScrollElement: () => parentRef.current,
    estimateSize: () => rowHeight,  // calculated based on item size + gap
    overscan: 2,
  })
  ```
  - Each virtual row renders multiple `MediaCard` components
  - Calculate `itemsPerRow` based on container width and item size
  - Use `measureElement` for dynamic row heights if items vary

- [ ] **[TEST] MEDIA-003B**: Grid renders only visible rows; scroll performance smooth with 1000+ items

**MediaCard Component:**
- [ ] **MEDIA-003C**: Create `MediaCard`:
  - Image/video thumbnail with blur placeholder
  - Overlay on hover: title, duration (if video), favorite toggle, select checkbox
  - Generation status badge (if generated: "AI Generated" with model name)
  - Progress indicator for in-progress generation
  - Click to open detail view
  - Right-click context menu (open, download, add to album, delete, regenerate)

- [ ] **[TEST] MEDIA-003C**: Card renders thumbnail; hover overlay appears; status badge shows; context menu works

- [ ] **MEDIA-003D**: Implement progressive image loading:
  ```tsx
  <img
    src={blurDataUrl}
    srcSet={`${thumbnailUrl} 400w, ${url} 1200w`}
    loading="lazy"
    className="transition-all duration-300"
    onLoad={(e) => {
      e.currentTarget.src = url
      e.currentTarget.classList.remove('blur-sm')
    }}
  />
  ```

- [ ] **[TEST] MEDIA-003D**: Blur placeholder shown initially; full image loads smoothly

- [ ] **MEDIA-003E**: Implement selection mode:
  - Checkbox on card toggles selection via Zustand
  - Multi-select with Shift+click (range selection)
  - Select all / deselect all buttons in bottom bar

- [ ] **[TEST] MEDIA-003E**: Checkbox toggles selection; Shift+click selects range; select all works

**MediaList View:**
- [ ] **MEDIA-003F**: Create `MediaList` as alternative view:
  - Table-like layout with columns: thumbnail, title, type, date, size, tags, actions
  - Virtualized using `@tanstack/react-virtual` for rows
  - Sortable by any column

- [ ] **[TEST] MEDIA-003F**: List view renders; sorting works; virtualization active

**Timeline View:**
- [ ] **MEDIA-003G**: Create `MediaTimeline`:
  - Group media by date (month/day clusters)
  - Horizontal scroll with date headers
  - Each cluster shows thumbnails in a row
  - Expandable to show all items in cluster

- [ ] **[TEST] MEDIA-003G**: Timeline groups by date; horizontal scroll works; clusters expandable

### Definition of Done
- Media library page with grid/list/timeline views
- Virtualized grid for performance with large collections
- Progressive image loading with blur placeholders
- Selection mode with multi-select support

### Anti-Patterns
- ❌ Rendering all items without virtualization — kills performance
- ❌ Fixed items-per-row calculation — must recalculate on resize
- ❌ Loading full-resolution images immediately — waste bandwidth
- ❌ Missing blur placeholder — jarring loading experience

---

## 🎨 Task MEDIA-004: AI Generation Panel & Queue
**Priority:** 🔴 High | **Est. Effort:** 3.5 hours | **Depends On:** MEDIA-001, MEDIA-002

### Related Files
- `src/components/media/GenerationPanel.tsx` · `src/components/media/GenerationForm.tsx` · `src/components/media/GenerationQueue.tsx`

### Subtasks

**GenerationPanel:**
- [ ] **MEDIA-004A**: Create `GenerationPanel` (right panel):
  - Toggle open/close via button in top bar
  - Contains: generation form, queue list, presets
  - Collapsible sections for each area
  - Animated gradient border when generation is active

- [ ] **[TEST] MEDIA-004A**: Panel toggles open/close; all sections render; border animates when active

**GenerationForm:**
- [ ] **MEDIA-004B**: Create `GenerationForm`:
  - Textarea for prompt (multi-line, character count)
  - Model selector (dropdown with model descriptions)
  - Parameter controls (aspect ratio, style, quality, seed)
  - Preset selector (dropdown + save current as preset button)
  - Generate button (shows spinner while processing)
  - Advanced options toggle (negative prompt, guidance scale, steps)

- [ ] **[TEST] MEDIA-004B**: Form renders all controls; preset selector works; generate button shows spinner

- [ ] **MEDIA-004C**: Implement form validation with Zod:
  - Prompt required (min 10 characters)
  - Model required
  - Aspect ratio required
  - Seed must be number if provided

- [ ] **[TEST] MEDIA-004C**: Validation errors show on invalid submit; valid submit succeeds

- [ ] **MEDIA-004D**: Wire form submission to Zustand queue:
  - On submit: call `addToQueue` with form data
  - Set priority to 'high' for user-initiated generations
  - Close form panel, show queue panel

- [ ] **[TEST] MEDIA-004D**: Submit adds item to queue with correct priority; panel switches to queue view

**GenerationQueue:**
- [ ] **MEDIA-004E**: Create `GenerationQueue`:
  - List of queued/in-progress items
  - Each item shows: prompt, model, status, progress bar, cancel button
  - Status badges: Queued (gray), Processing (blue with pulse), Completed (green), Failed (red)
  - Progress bar animated for processing items
  - Auto-scroll to latest in-progress item

- [ ] **[TEST] MEDIA-004E**: Queue renders all items; status badges correct; progress bar animates; cancel works

- [ ] **MEDIA-004F**: Implement SSE integration for real-time progress:
  ```tsx
  useEffect(() => {
    const eventSource = new EventSource(`/api/media/generate/${queueItemId}/stream`)
    eventSource.onmessage = (e) => {
      const data = JSON.parse(e.data)
      updateQueueItem(queueItemId, { progress: data.progress, status: data.status })
    }
    return () => eventSource.close()
  }, [queueItemId])
  ```

- [ ] **[TEST] MEDIA-004F**: SSE updates progress in real-time; connection closes on unmount

- [ ] **MEDIA-004G**: Handle generation completion:
  - When status = 'completed': create new `MediaItem` in cache
  - Add to library with `source: 'generated'`
  - Show success toast with link to new item
  - Remove from queue (or move to completed section)

- [ ] **[TEST] MEDIA-004G**: Completed generation creates MediaItem; toast shows; item appears in library

- [ ] **MEDIA-004H**: Handle generation failure:
  - When status = 'failed': show error message in queue item
  - Retry button to resubmit with same parameters
  - Delete button to remove from queue

- [ ] **[TEST] MEDIA-004H**: Failed items show error; retry resubmits; delete removes from queue

**Preset Management:**
- [ ] **MEDIA-004I**: Implement preset CRUD:
  - Save current form as preset (name prompt)
  - Load preset into form
  - Delete preset
  - Presets persisted in Zustand

- [ ] **[TEST] MEDIA-004I**: Save creates preset; load populates form; delete removes preset

### Definition of Done
- Generation panel with form, queue, and presets
- Real-time progress updates via SSE
- Queue management with cancel/retry/delete
- Preset system for saving common configurations

### Anti-Patterns
- ❌ Not using SSE for progress — polling is inefficient
- ❌ Blocking UI during generation — must be async with queue
- ❌ Not handling generation failure — users stuck with failed items
- ❌ Missing preset system — repetitive prompt entry

---

## 📁 Task MEDIA-005: Albums & Organization
**Priority:** 🟠 Medium | **Est. Effort:** 2.5 hours | **Depends On:** MEDIA-001, MEDIA-002

### Related Files
- `src/components/media/AlbumSidebar.tsx` · `src/components/media/AlbumCard.tsx` · `src/components/media/AlbumDetail.tsx`

### Subtasks

**AlbumSidebar:**
- [ ] **MEDIA-005A**: Create `AlbumSidebar` (left panel):
  - List of all albums
  - "Create Album" button
  - Auto-generated albums (read-only, marked with icon)
  - Album count badge
  - Search/filter albums
  - Collapse/expand

- [ ] **[TEST] MEDIA-005A**: Sidebar renders albums; create button works; auto-albums marked; search filters

**AlbumCard:**
- [ ] **MEDIA-005B**: Create `AlbumCard` (for grid view of albums):
  - Cover image (first media item or grid collage)
  - Album name
  - Item count
  - Date range (if applicable)
  - Location badge (if applicable)
  - Hover actions: open, edit, delete

- [ ] **[TEST] MEDIA-005B**: Card renders cover; metadata correct; hover actions work

**AlbumDetail:**
- [ ] **MEDIA-005C**: Create `AlbumDetail` (main view when album selected):
  - Album header: name, description, edit button, delete button
  - Media grid filtered to album items
  - "Add to Album" button (opens media selector modal)
  - "Remove from Album" button (for selected items)
  - Share button (generates shareable link)
  - Auto-generated albums: show "Suggested based on [criterion]" badge

- [ ] **[TEST] MEDIA-005C**: Detail view renders album header; grid shows album items; add/remove works

**Create/Edit Album Modal:**
- [ ] **MEDIA-005D**: Create `AlbumModal`:
  - Name input (required)
  - Description textarea (optional)
  - Cover image selector (grid of album items)
  - Location input (optional, with autocomplete)
  - Save/Cancel buttons

- [ ] **[TEST] MEDIA-005D**: Modal renders all fields; cover selector works; save creates album

**Auto-Album Suggestions:**
- [ ] **MEDIA-005E**: Implement auto-album generation:
  - Run `suggestAlbums()` utility on media library
  - Create albums with `isAutoGenerated: true`
  - Group by: date clusters (3-day window), location, AI-detected events
  - Show "New album suggestions" notification

- [ ] **[TEST] MEDIA-005E**: Auto-albums created based on date/location; notification shows

**Media Selector Modal:**
- [ ] **MEDIA-005F**: Create `MediaSelectorModal`:
  - Mini media grid with checkboxes
  - Filter by type, date, tags
  - Search by name
  - Select all / deselect all
  - Confirm adds selected items to album

- [ ] **[TEST] MEDIA-005F**: Modal renders grid; checkboxes work; filters work; confirm adds items

### Definition of Done
- Album management with create, edit, delete
- Auto-generated album suggestions
- Add/remove media from albums
- Shareable album links

### Anti-Patterns
- ❌ Not distinguishing auto-generated albums — users might delete important suggestions
- ❌ Missing media selector modal — tedious to add items one by one
- ❌ Not showing album metadata (date range, location) — poor organization context

---

## 🔍 Task MEDIA-006: Search, Filters & Duplicate Detection
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** MEDIA-001, MEDIA-002

### Related Files
- `src/components/media/MediaFilters.tsx` · `src/components/media/MediaSearch.tsx` · `src/components/media/DuplicateDrawer.tsx`

### Subtasks

**MediaFilters:**
- [ ] **MEDIA-006A**: Create `MediaFilters` component:
  - Type filter: All / Images / Videos (chip selector)
  - Source filter: All / Uploaded / Generated / External (chip selector)
  - Date range picker (start date, end date)
  - Tag filter (multi-select from available tags)
  - Album filter (multi-select from albums)
  - Clear all filters button

- [ ] **[TEST] MEDIA-006A**: All filters render; filter combinations work; clear resets all

- [ ] **MEDIA-006B**: Wire filters to Zustand and query:
  - Each filter update calls `setFilter` in Zustand
  - Filter changes trigger query refetch with new params
  - URL sync for shareable filter states

- [ ] **[TEST] MEDIA-006B**: Filter updates Zustand; query refetches; URL updates

**MediaSearch:**
- [ ] **MEDIA-006C**: Create `MediaSearch`:
  - Search input with debounced query (300ms)
  - Search by: title, description, tags, location
  - Semantic search mock (accepts natural language queries)
  - Search history dropdown (recent searches)
  - Clear search button

- [ ] **[TEST] MEDIA-006C**: Search input works; debounce active; history shows; clear resets

- [ ] **MEDIA-006D**: Implement semantic search (mock):
  - For queries like "sunset at beach", return items with matching tags/descriptions
  - In production, would use CLIP embeddings
  - Show "Semantic search" badge when using natural language

- [ ] **[TEST] MEDIA-006D**: Semantic queries return relevant results; badge shows

**Duplicate Detection:**
- [ ] **MEDIA-006E**: Create `DuplicateDrawer`:
  - Triggered by "Find Duplicates" button in top bar
  - Shows groups of duplicate media items
  - Each group: thumbnails, similarity score, actions (keep all, keep oldest, keep highest quality, delete all but one)
  - Bulk actions: select all groups, resolve selected

- [ ] **[TEST] MEDIA-006E**: Drawer opens; duplicate groups shown; actions work; bulk actions work

- [ ] **MEDIA-006F**: Implement duplicate detection logic:
  - Use `detectDuplicates()` utility
  - Group items with similarity score > 0.9
  - Sort groups by similarity score (highest first)
  - Show count of total duplicates found

- [ ] **[TEST] MEDIA-006F**: Detection groups similar items; scores correct; count accurate

### Definition of Done
- Comprehensive filter system (type, source, date, tags, albums)
- Search with semantic query support
- Duplicate detection with resolution actions

### Anti-Patterns
- ❌ Not debouncing search — excessive API calls
- ❌ Missing semantic search — modern expectation for media libraries
- ❌ Not providing bulk duplicate resolution — tedious to handle one by one

---

## 🖼️ Task MEDIA-007: Media Detail View & Editor
**Priority:** 🟠 Medium | **Est. Effort:** 2.5 hours | **Depends On:** MEDIA-002

### Related Files
- `src/components/media/MediaDetailDrawer.tsx` · `src/components/media/MediaEditor.tsx`

### Subtasks

**MediaDetailDrawer:**
- [ ] **MEDIA-007A**: Create `MediaDetailDrawer`:
  - Full-screen or large modal overlay
  - Main content: full-resolution image or video player
  - Sidebar: metadata, actions, related items
  - Navigation: previous/next arrows (if in album or filtered view)
  - Close button (Escape key also closes)

- [ ] **[TEST] MEDIA-007A**: Drawer opens on media click; renders full media; navigation works; Escape closes

- [ ] **MEDIA-007B**: Implement metadata sidebar:
  - Title (editable)
  - Description (editable textarea)
  - Tags (editable multi-select)
  - Date/time (captured at, created at)
  - Location (if available, link to map)
  - EXIF data (camera, lens, settings)
  - File info: size, dimensions, format
  - Generation data (if applicable): prompt, model, parameters, regenerate button

- [ ] **[TEST] MEDIA-007B**: All metadata fields render; editable fields save; EXIF shows; generation data shows

- [ ] **MEDIA-007C**: Implement actions:
  - Favorite toggle
  - Add to album (dropdown selector)
  - Download (original resolution)
  - Share (copy link, open in new tab)
  - Delete (with confirmation)
  - Regenerate (if AI-generated, opens generation form with same prompt)
  - Edit (opens editor for images)

- [ ] **[TEST] MEDIA-007C**: All actions work; confirmations show; regenerate populates form

**MediaEditor:**
- [ ] **MEDIA-007D**: Create `MediaEditor` (basic image editing):
  - Crop tool (aspect ratio presets, freeform)
  - Rotate (90° increments)
  - Flip (horizontal/vertical)
  - Adjustments: brightness, contrast, saturation (sliders)
  - Filters: grayscale, sepia, blur (preset buttons)
  - Undo/redo history
  - Save as new / replace original

- [ ] **[TEST] MEDIA-007D**: All tools work; undo/redo functional; save options work

- [ ] **MEDIA-007E**: Implement video player controls:
  - Play/pause
  - Seek bar
  - Volume
   fullscreen
  - Playback speed (0.5x, 1x, 1.5x, 2x)
  - Picture-in-picture (if supported)

- [ ] **[TEST] MEDIA-007E**: All video controls work; playback speed changes; PiP opens

**Related Items:**
- [ ] **MEDIA-007F**: Show related items in detail view:
  - Same album (other items)
  - Same date (nearby in timeline)
  - Same tags (matching tags)
  - Similar generation (same model, similar prompt)

- [ ] **[TEST] MEDIA-007F**: Related items section shows correct groupings; clicking navigates

### Definition of Done
- Rich detail view with full media and metadata
- Basic image editing tools
- Full video player controls
- Related items for discovery

### Anti-Patterns
- ❌ Not supporting keyboard navigation (arrows, Escape) — poor accessibility
- ❌ Missing undo/redo in editor — destructive edits
- ❌ Not showing generation data in detail — users lose context for AI media

---

## 📊 Task MEDIA-008: Storage Management & Analytics
**Priority:** 🟢 Low | **Est. Effort:** 2 hours | **Depends On:** MEDIA-002

### Related Files
- `src/components/media/StorageAnalytics.tsx` · `src/components/media/StorageCleanup.tsx`

### Subtasks

**StorageAnalytics:**
- [ ] **MEDIA-008A**: Create `StorageAnalytics`:
  - Total storage used (with progress bar vs quota)
  - Breakdown by type: images, videos, generated media
  - Breakdown by album: largest albums
  - Growth chart (storage over time, last 30 days)
  - Average file size by type

- [ ] **[TEST] MEDIA-008A**: Analytics render; breakdowns accurate; chart shows

- [ ] **MEDIA-008B**: Implement storage calculation:
  - Sum file sizes of all media items
  - Group by type, album, date
  - Calculate growth from historical data
  - Format as human-readable (GB, MB)

- [ ] **[TEST] MEDIA-008B**: Calculations accurate; formatting correct

**StorageCleanup:**
- [ ] **MEDIA-008C**: Create `StorageCleanup`:
  - "Large files" section (files > 50MB, with delete option)
  - "Old generations" section (generated media > 30 days old, with delete option)
  - "Duplicates" section (link to duplicate drawer)
  - "Low quality" section (images < 720p, with delete option)
  - "Empty albums" section (albums with no media, with delete option)
  - Bulk delete with confirmation
  - Estimated space freed for each action

- [ ] **[TEST] MEDIA-008C**: All sections render; delete works; space estimate accurate

- [ ] **MEDIA-008D**: Implement cleanup actions:
  - Delete single item
  - Delete all in section
  - Confirm before delete (show count and space)
  - Update storage analytics after delete

- [ ] **[TEST] MEDIA-008D**: Delete actions work; confirmation shows; analytics update

### Definition of Done
- Storage analytics with breakdowns and growth chart
- Cleanup tools for large files, old generations, duplicates, low quality
- Bulk delete with space estimation

### Anti-Patterns
- ❌ Not showing space estimates before delete — users don't know impact
- ❌ Missing confirmation for bulk delete — accidental data loss
- ❌ Not updating analytics after cleanup — stale data

---

## 🚀 Task MEDIA-009: Route Configuration & Integration
**Priority:** 🔴 High | **Est. Effort:** 45 min | **Depends On:** FND-007 (Router), MEDIA-002

### Related Files
- `src/router/routes.ts` · `src/pages/MediaPage.tsx`

### Subtasks

- [ ] **MEDIA-009A**: Configure route in `src/router/routes.ts`:
  ```ts
  {
    path: 'media',
    lazy: () => import('@/pages/MediaPage'),
    loader: () => queryClient.ensureQueryData(mediaQueryOptions(defaultFilters)),
  }
  ```

- [ ] **[TEST] MEDIA-009A**: `/media` route accessible; loader prefetches data

- [ ] **MEDIA-009B**: Add nested routes for detail view:
  ```ts
  {
    path: 'media/:id',
    lazy: () => import('@/pages/MediaPage'),
    loader: ({ params }) => queryClient.ensureQueryData(mediaItemQueryOptions(params.id)),
  }
  ```

- [ ] **[TEST] MEDIA-009B**: `/media/:id` opens detail view; loader prefetches item

- [ ] **MEDIA-009C**: Add sidebar navigation item for Media:
  - Icon: photo/video icon
  - Label: "Media"
  - Badge: count of items (optional)

- [ ] **[TEST] MEDIA-009C**: Sidebar item present; navigation works

### Definition of Done
- Media routes configured with data prefetching
- Sidebar navigation integrated
- Detail view accessible via URL

### Anti-Patterns
- ❌ Not prefetching data in loader — waterfall fetches
- ❌ Missing detail view route — can't share links to specific media

---

## 📝 Summary

The Media module provides a comprehensive media library with AI generation capabilities, following the established patterns from other modules:

- **Domain Model**: Unified `MediaItem` type supporting both uploaded and generated media
- **State Management**: Zustand for UI state, TanStack Query for server state
- **Virtualization**: `@tanstack/react-virtual` for performant grid views
- **Progressive Loading**: Blur placeholders and on-demand video loading
- **Generation Queue**: SSE-powered real-time progress tracking
- **Organization**: Albums with auto-suggestions, smart filters, semantic search
- **Storage**: Analytics and cleanup tools for managing large collections

The module balances traditional media management (Google Photos-style organization) with modern AI workflows (image/video generation with queue management and presets).

---

## 🔍 Additional Tasks Identified from Research

Based on research of Google Photos, Apple Photos, Adobe Lightroom, and Runway ML (2025-2026), the following additional tasks should be added to complete the Media module:

### 📋 Task MEDIA-010: People Detection & Facial Recognition
**Priority:** 🟠 Medium | **Est. Effort:** 3 hours | **Depends On:** MEDIA-000, MEDIA-002

**Rationale:** Apple Photos and Google Photos both feature People Albums with automatic facial recognition and grouping. This is a core organizational feature for personal media libraries.

**Related Files:**
- `src/components/media/PeopleAlbum.tsx` · `src/components/media/FaceCluster.tsx` · `src/utils/faceDetection.ts`

**Subtasks:**
- [ ] **MEDIA-010A**: Extend `MediaItem` type to include `faces: { id: string; boundingBox: { x, y, width, height }; confidence: number }[]`
- [ ] **MEDIA-010B**: Create `FaceCluster` component to display detected faces in grid
- [ ] **MEDIA-010C**: Implement `PeopleAlbum` sidebar showing detected people with thumbnail avatars
- [ ] **MEDIA-010D**: Add face grouping logic (mock: group by similar face IDs; production: use face embedding clustering)
- [ ] **MEDIA-010E**: Allow manual face naming and merging of duplicate face clusters
- [ ] **MEDIA-010F**: Add "People" filter to search by person name

**Definition of Done:**
- Faces detected and displayed in People Album
- Manual face naming and merging supported
- Search by person name functional

---

### 🎬 Task MEDIA-011: Slideshow & Video Creation
**Priority:** 🟠 Medium | **Est. Effort:** 3.5 hours | **Depends On:** MEDIA-002, MEDIA-003

**Rationale:** Apple Photos and Google Photos both offer advanced slideshow creation with music, transitions, and themes. This is a key feature for sharing memories.

**Related Files:**
- `src/components/media/SlideshowBuilder.tsx` · `src/components/media/SlideshowPlayer.tsx` · `src/types/slideshow.ts`

**Subtasks:**
- [ ] **MEDIA-011A**: Define `Slideshow` type with: id, name, mediaIds, duration, transitionType, musicTrack, theme
- [ ] **MEDIA-011B**: Create `SlideshowBuilder` with drag-and-drop media ordering
- [ ] **MEDIA-011C**: Implement transition options: fade, slide, zoom, dissolve, wipe
- [ ] **MEDIA-011D**: Add music selection (mock audio library or upload)
- [ ] **MEDIA-011E**: Create theme presets (cinematic, playful, minimal, vintage)
- [ ] **MEDIA-011F**: Build `SlideshowPlayer` with play/pause, seek, fullscreen
- [ ] **MEDIA-011G**: Export slideshow as video (mock: generate MP4; production: use FFmpeg.wasm)

**Definition of Done:**
- Slideshow builder with drag-and-drop ordering
- Multiple transition types and themes
- Music integration and video export

---

### 🖼️ Task MEDIA-012: Advanced AI Editing Tools
**Priority:** 🟠 Medium | **Est. Effort:** 4 hours | **Depends On:** MEDIA-002, MEDIA-004

**Rationale:** Adobe Lightroom (Generative Upscale, prompt-based editing) and Runway ML (object removal/addition) offer advanced AI editing capabilities beyond basic adjustments.

**Related Files:**
- `src/components/media/AIEditor.tsx` · `src/components/media/ObjectRemoval.tsx` · `src/components/media/UpscaleTool.tsx`

**Subtasks:**
- [ ] **MEDIA-012A**: Create `GenerativeUpscale` tool:
  - Upscale factor selector (2x, 4x)
  - Progress indicator for AI processing
  - Before/after comparison slider
- [ ] **MEDIA-012B**: Implement `ObjectRemoval` (Aleph-style):
  - Brush tool to select objects for removal
  - Prompt-based object addition
  - Inpainting preview
- [ ] **MEDIA-012C**: Add `PromptBasedEdit` (Firefly-style):
  - Text prompt input for edits
  - Natural language editing commands
  - Preview and apply changes
- [ ] **MEDIA-012D**: Create `StyleTransfer` tool:
  - Apply artistic styles via AI
  - Style strength slider
  - Custom style training (mock)
- [ ] **MEDIA-012E**: Integrate AI editing into generation queue with priority handling

**Definition of Done:**
- Generative upscale with before/after comparison
- Object removal and addition via brush/prompts
- Prompt-based natural language editing
- Style transfer with custom training

---

### 🎭 Task MEDIA-013: Live Photos Support
**Priority:** 🟢 Low | **Est. Effort:** 2 hours | **Depends On:** MEDIA-000, MEDIA-003

**Rationale:** Apple Photos' Live Photos capture motion and sound, providing a richer media experience. This requires special handling in the media model.

**Related Files:**
- `src/types/media.ts` · `src/components/media/LivePhotoCard.tsx` · `src/components/media/LivePhotoPlayer.tsx`

**Subtasks:**
- [ ] **MEDIA-013A**: Extend `MediaItem` type with `isLivePhoto: boolean`, `livePhotoVideoUrl?: string`, `livePhotoAudioUrl?: string`
- [ ] **MEDIA-013B**: Create `LivePhotoCard` with press-and-hold to play animation
- [ ] **MEDIA-013C**: Build `LivePhotoPlayer` with play/pause, loop control
- [ ] **MEDIA-013D**: Add "Live" badge indicator on cards
- [ ] **MEDIA-013E**: Support Live Photo conversion to still video

**Definition of Done:**
- Live Photo type supported in domain model
- Press-and-hold playback in grid
- Conversion to video option

---

### 📚 Task MEDIA-014: Memories & Auto-Curated Collections
**Priority:** 🟠 Medium | **Est. Effort:** 2.5 hours | **Depends On:** MEDIA-000, MEDIA-005

**Rationale:** Apple Photos' "Memories" and Google Photos' curated collections automatically group photos by events, dates, and themes, reducing manual organization.

**Related Files:**
- `src/components/media/MemoriesCarousel.tsx` · `src/utils/memoryGeneration.ts` · `src/types/memory.ts`

**Subtasks:**
- [ ] **MEDIA-014A**: Define `Memory` type with: id, title, mediaIds, theme, generatedAt, isAutoGenerated
- [ ] **MEDIA-014B**: Implement auto-memory generation logic:
  - Date clustering (events within 3 days)
  - Location-based grouping
  - AI-detected themes (beach, birthday, travel)
- [ ] **MEDIA-014C**: Create `MemoriesCarousel` at top of MediaPage
- [ ] **MEDIA-014D**: Add memory detail view with slideshow
- [ ] **MEDIA-014E**: Allow manual memory creation and editing
- [ ] **MEDIA-014F**: "For You" section showing suggested memories

**Definition of Done:**
- Auto-generated memories based on date/location/theme
- Memories carousel with slideshow playback
- Manual memory creation and editing

---

### 🎨 Task MEDIA-015: Mood Boards & Creative Collections
**Priority:** 🟢 Low | **Est. Effort:** 2 hours | **Depends On:** MEDIA-000, MEDIA-005

**Rationale:** Adobe Lightroom's Firefly boards integration allows creating mood boards for creative projects. This is valuable for designers and content creators.

**Related Files:**
- `src/components/media/MoodBoard.tsx` · `src/types/moodBoard.ts` · `src/components/media/MoodBoardGrid.tsx`

**Subtasks:**
- [ ] **MEDIA-015A**: Define `MoodBoard` type with: id, name, mediaIds, layout, notes, createdAt
- [ ] **MEDIA-015B**: Create `MoodBoard` with free-form canvas layout
- [ ] **MEDIA-015C**: Implement drag-and-drop positioning of media items
- [ ] **MEDIA-015D**: Add text notes and annotations
- [ ] **MEDIA-015E**: Export mood board as image (mock)
- [ ] **MEDIA-015F**: Mood board sidebar with create/edit/delete

**Definition of Done:**
- Free-form mood board canvas
- Drag-and-drop media positioning
- Text notes and export capability

---

### 🎤 Task MEDIA-016: Voice Cloning & Audio for Videos
**Priority:** 🟢 Low | **Est. Effort:** 2 hours | **Depends On:** MEDIA-004

**Rationale:** Runway ML's custom voice cloning enables adding narration to AI-generated videos. This enhances video creation workflows.

**Related Files:**
- `src/components/media/VoiceCloning.tsx` · `src/types/voice.ts` · `src/components/media/AudioTimeline.tsx`

**Subtasks:**
- [ ] **MEDIA-016A**: Define `VoiceProfile` type with: id, name, sampleAudioUrl, createdAt
- [ ] **MEDIA-016B**: Create `VoiceCloning` component:
  - Record voice sample (mock)
  - Text-to-speech input
  - Voice selection dropdown
- [ ] **MEDIA-016C**: Add audio timeline to video editor
- [ ] **MEDIA-016D**: Implement audio overlay on generated videos
- [ ] **MEDIA-016E**: Add volume and timing controls

**Definition of Done:**
- Voice profile creation and management
- Text-to-speech with custom voice
- Audio timeline overlay on videos

---

### 🎞️ Task MEDIA-017: Character Animation & Lip Sync
**Priority:** 🟢 Low | **Est. Effort:** 2.5 hours | **Depends On:** MEDIA-004

**Rationale:** Runway ML's Act-Two model enables performance-driven character animation with pose and lip sync. This is advanced video generation capability.

**Related Files:**
- `src/components/media/CharacterAnimation.tsx` · `src/types/animation.ts` · `src/components/media/PoseEditor.tsx`

**Subtasks:**
- [ ] **MEDIA-017A**: Define `CharacterAnimation` type with: id, sourceMediaId, poseData, lipSyncData, outputVideoUrl
- [ ] **MEDIA-017B**: Create `CharacterAnimation` component:
  - Source video/image upload
  - Pose selection (dropdown or manual)
  - Lip sync text input
- [ ] **MEDIA-017C**: Build `PoseEditor` for manual pose adjustment
- [ ] **MEDIA-017D**: Add animation preview and generation queue integration
- [ ] **MEDIA-017E**: Support character consistency across generations

**Definition of Done:**
- Character animation with pose control
- Lip sync with text input
- Manual pose editor and preview

---

### 🖨️ Task MEDIA-018: Photo Books & Printing Integration
**Priority:** 🟢 Low | **Est. Effort:** 2 hours | **Depends On:** MEDIA-005

**Rationale:** Apple Photos and Google Photos both offer photo book creation and printing services. This is a valuable export/print feature.

**Related Files:**
- `src/components/media/PhotoBookBuilder.tsx` · `src/types/photoBook.ts` · `src/components/media/BookPreview.tsx`

**Subtasks:**
- [ ] **MEDIA-018A**: Define `PhotoBook` type with: id, name, mediaIds, layout, coverImage, size, paperType
- [ ] **MEDIA-018B**: Create `PhotoBookBuilder` with page-by-page layout
- [ ] **MEDIA-018C**: Implement layout templates (grid, full-page, collage)
- [ ] **MEDIA-018D**: Add cover image selection and customization
- [ ] **MEDIA-018E**: Build `BookPreview` with page flip animation
- [ ] **MEDIA-018F**: Export/print integration (mock: generate PDF; production: print service API)

**Definition of Done:**
- Photo book builder with page layouts
- Cover customization and preview
- Export to PDF for printing

---

### 🔒 Task MEDIA-019: Privacy & Access Controls
**Priority:** 🟠 Medium | **Est. Effort:** 1.5 hours | **Depends On:** MEDIA-000, MEDIA-005

**Rationale:** Apple Photos includes privacy features like hiding photos and access control for shared albums. This is essential for personal media libraries.

**Related Files:**
- `src/components/media/PrivacySettings.tsx` · `src/stores/mediaSlice.ts` · `src/types/media.ts`

**Subtasks:**
- [ ] **MEDIA-019A**: Extend `MediaItem` with `isHidden: boolean`, `isSensitive: boolean`
- [ ] **MEDIA-019B**: Extend `Album` with `accessControl: 'private' | 'shared' | 'public'`, `sharedWith: string[]`
- [ ] **MEDIA-019C**: Create `PrivacySettings` panel:
  - Hide/unhide individual items
  - Mark as sensitive (blur by default)
  - Hidden album (access via authentication)
- [ ] **MEDIA-019D**: Implement shared album access control:
  - Invite by email
  - Permission levels (view, contribute, edit)
  - Revoke access
- [ ] **MEDIA-019E**: Add privacy filters (show/hide hidden items)

**Definition of Done:**
- Hide/unhide media items
- Sensitive content marking
- Shared album access control with permissions

---

### 🎨 Task MEDIA-020: Advanced Presets & Filters
**Priority:** 🟢 Low | **Est. Effort:** 1.5 hours | **Depends On:** MEDIA-007

**Rationale:** Adobe Lightroom offers film-inspired presets and adaptive profiles. Enhancing the basic editor with professional presets improves editing capabilities.

**Related Files:**
- `src/components/media/PresetsPanel.tsx` · `src/types/preset.ts` · `src/utils/presets.ts`

**Subtasks:**
- [ ] **MEDIA-020A**: Define `EditPreset` type with: id, name, adjustments, thumbnailUrl, category
- [ ] **MEDIA-020B**: Create preset library with categories:
  - Film-inspired (Kodak, Fujifilm, Polaroid)
  - Color grading (cinematic, vintage, modern)
  - Light/temperature (warm, cool, neutral)
- [ ] **MEDIA-020C**: Build `PresetsPanel` with preview thumbnails
- [ ] **MEDIA-020D**: Implement custom preset creation from current edits
- [ ] **MEDIA-020E**: Add preset intensity slider
- [ ] **MEDIA-020F**: Adaptive presets based on image content (mock)

**Definition of Done:**
- Preset library with categories
- Custom preset creation
- Preset intensity and adaptive presets

---

### 📱 Task MEDIA-021: QR Code Sharing & Mobile Features
**Priority:** 🟢 Low | **Est. Effort:** 1 hour | **Depends On:** MEDIA-005

**Rationale:** Adobe Lightroom shares albums via QR code for easy mobile access. This improves sharing workflows.

**Related Files:**
- `src/components/media/QRShare.tsx` · `src/utils/qrCode.ts`

**Subtasks:**
- [ ] **MEDIA-021A**: Create `QRShare` component for albums and individual media
- [ ] **MEDIA-021B**: Generate QR code from shareable URL (use qrcode library)
- [ ] **MEDIA-021C**: Add download QR code as image
- [ ] **MEDIA-021D**: Set QR code expiration (optional)
- [ ] **MEDIA-021E**: Mobile-optimized share page (responsive design)

**Definition of Done:**
- QR code generation for albums/media
- Downloadable QR code images
- Expiration settings

---

### 🔌 Task MEDIA-022: Third-Party Extensions
**Priority:** 🟢 Low | **Est. Effort:** 2 hours | **Depends On:** MEDIA-007

**Rationale:** Apple Photos supports third-party editing extensions. This allows integrating external editing tools.

**Related Files:**
- `src/components/media/ExtensionsGallery.tsx` · `src/types/extension.ts` · `src/utils/extensions.ts`

**Subtasks:**
- [ ] **MEDIA-022A**: Define `Extension` type with: id, name, icon, type, capabilities
- [ ] **MEDIA-022B**: Create `ExtensionsGallery` showing available extensions
- [ ] **MEDIA-022C**: Implement extension integration points:
  - Edit in external tool button
  - Extension settings panel
- [ ] **MEDIA-022D**: Mock extension system (production: use web extensions API)
- [ ] **MEDIA-022E**: Add extension marketplace (mock)

**Definition of Done:**
- Extensions gallery with integration points
- Mock extension system
- Extension settings and marketplace

---

## 📊 Task Priority Summary

**High Priority (Core Features):**
- MEDIA-010: People Detection & Facial Recognition
- MEDIA-011: Slideshow & Video Creation
- MEDIA-012: Advanced AI Editing Tools
- MEDIA-014: Memories & Auto-Curated Collections
- MEDIA-019: Privacy & Access Controls

**Medium Priority (Enhanced Features):**
- MEDIA-013: Live Photos Support
- MEDIA-015: Mood Boards & Creative Collections
- MEDIA-020: Advanced Presets & Filters

**Low Priority (Specialized Features):**
- MEDIA-016: Voice Cloning & Audio for Videos
- MEDIA-017: Character Animation & Lip Sync
- MEDIA-018: Photo Books & Printing Integration
- MEDIA-021: QR Code Sharing & Mobile Features
- MEDIA-022: Third-Party Extensions

**Total Additional Effort:** ~27 hours across 13 new tasks

---

## 🔍 Additional Tasks from 2025-2026 Research (New)

Based on research of Apple Photos iOS 26, Adobe Lightroom 2025, Google Photos 2026, and Runway Gen-4/Gen-4.5, the following additional features should be added:

### 🎬 Task MEDIA-023: Spatial Photos & 3D Depth Effects
**Priority:** 🟢 Low | **Est. Effort:** 2 hours | **Depends On:** MEDIA-000, MEDIA-003

**Rationale:** Apple Photos iOS 26 introduced "Spatialize photos" allowing users to view photos with depth and pan around different dimensions. This creates immersive viewing experiences.

**Related Files:**
- `src/types/media.ts` · `src/components/media/SpatialPhotoViewer.tsx` · `src/utils/spatialProcessing.ts`

**Subtasks:**
- [ ] **MEDIA-023A**: Extend `MediaItem` with `isSpatial: boolean`, `depthMapUrl?: string`, `spatialPreviewUrl?: string`
- [ ] **MEDIA-023B**: Create `SpatialPhotoViewer` with pan/rotate controls
- [ ] **MEDIA-023C**: Implement depth map generation (mock: return depth data URL; production: use AI depth estimation)
- [ ] **MEDIA-023D**: Add "Spatial" badge indicator on cards
- [ ] **MEDIA-023E**: Support spatial photo export as 3D format (mock)

**Definition of Done:**
- Spatial photo type supported in domain model
- Interactive 3D viewer with pan/rotate
- Depth map generation and export

---

### 🎫 Task MEDIA-024: Event Details & Metadata Integration
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** MEDIA-000, MEDIA-005

**Rationale:** Apple Photos iOS 26 shows event details for concerts and sports (venue, scores, artist songs). This enriches media context and discovery.

**Related Files:**
- `src/types/media.ts` · `src/components/media/EventDetailsPanel.tsx` · `src/utils/eventDetection.ts`

**Subtasks:**
- [ ] **MEDIA-024A**: Extend `MediaItem` with `eventData?: { type: 'concert' | 'sports' | 'other'; venue?: string; date?: string; metadata?: Record<string, unknown> }`
- [ ] **MEDIA-024B**: Create `EventDetailsPanel` showing venue, scores, artist info
- [ ] **MEDIA-024C**: Implement event detection logic (mock: by tags/location; production: use AI event recognition)
- [ ] **MEDIA-024D**: Add "Event Details" link in detail view swipe-up
- [ ] **MEDIA-024E**: Integrate with external APIs for event data (mock)

**Definition of Done:**
- Event metadata in domain model
- Event details panel with rich information
- Event detection and API integration

---

### 🤖 Task MEDIA-025: AI-Assisted Culling & Best Shot Selection
**Priority:** 🟠 Medium | **Est. Effort:** 2.5 hours | **Depends On:** MEDIA-000, MEDIA-002

**Rationale:** Adobe Lightroom 2025 introduced "Assisted Culling" to select best photos from large albums using AI. This is critical for photographers handling thousands of shots.

**Related Files:**
- `src/components/media/AssistedCulling.tsx` · `src/utils/cullingAI.ts` · `src/types/culling.ts`

**Subtasks:**
- [ ] **MEDIA-025A**: Define `CullingSession` type with: id, albumId, selectedIds, rejectedIds, criteria, createdAt
- [ ] **MEDIA-025B**: Create `AssistedCulling` component:
  - Side-by-side comparison view
  - AI quality scores (sharpness, exposure, composition)
  - Group by similar shots
  - Batch select/reject
- [ ] **MEDIA-025C**: Implement culling criteria:
  - Blur detection
  - Duplicate detection
  - Exposure analysis
  - Face detection (keep shots with faces)
  - Eyes open/closed detection
- [ ] **MEDIA-025D**: Add culling workflow to album context menu
- [ ] **MEDIA-025E**: Export culling results (keep/reject lists)

**Definition of Done:**
- AI-powered culling with quality scoring
- Side-by-side comparison and batch actions
- Multiple culling criteria (blur, duplicates, exposure)

---

### 🧹 Task MEDIA-026: AI Dust Spot & Defect Removal
**Priority:** 🟢 Low | **Est. Effort:** 1.5 hours | **Depends On:** MEDIA-007, MEDIA-012

**Rationale:** Adobe Lightroom 2025 added dust spot detection and removal for sensor/lens dust. This is essential for photographers with DSLR/mirrorless cameras.

**Related Files:**
- `src/components/media/DustRemoval.tsx` · `src/utils/defectDetection.ts`

**Subtasks:**
- [ ] **MEDIA-026A**: Create `DustRemoval` tool:
  - Auto-detect dust spots
  - Manual brush for dust selection
  - Preview before/after
  - Intensity slider
- [ ] **MEDIA-026B**: Implement dust detection logic (mock: random spots; production: use AI defect detection)
- [ ] **MEDIA-026C**: Add to MediaEditor tools panel
- [ ] **MEDIA-026D**: Support batch dust removal across multiple photos

**Definition of Done:**
- Dust spot detection and removal tool
- Manual brush and auto-detection
- Batch processing support

---

### 🎨 Task MEDIA-027: Color Labels & Advanced Organization
**Priority:** 🟠 Medium | **Est. Effort:** 1.5 hours | **Depends On:** MEDIA-000, MEDIA-005

**Rationale:** Adobe Lightroom 2025 added color labels for organization, search, and filtering. This provides visual categorization beyond albums.

**Related Files:**
- `src/types/media.ts` · `src/components/media/ColorLabelPicker.tsx` · `src/stores/mediaSlice.ts`

**Subtasks:**
- [ ] **MEDIA-027A**: Extend `MediaItem` with `colorLabel?: 'red' | 'yellow' | 'green' | 'blue' | 'purple'`
- [ ] **MEDIA-027B**: Create `ColorLabelPicker` component with 5 color options
- [ ] **MEDIA-027C**: Add color label filter to MediaFilters
- [ ] **MEDIA-027D**: Implement color label keyboard shortcuts (1-5 keys)
- [ ] **MEDIA-027E**: Add color label to MediaCard overlay
- [ ] **MEDIA-027F**: Batch assign color labels to selected items

**Definition of Done:**
- Color label system with 5 colors
- Filter and search by color label
- Keyboard shortcuts and batch assignment

---

### 📝 Task MEDIA-028: Batch File Renaming
**Priority:** 🟢 Low | **Est. Effort:** 1 hour | **Depends On:** MEDIA-003

**Rationale:** Adobe Lightroom 2025 added batch file renaming with custom templates. This is essential for professional photo organization.

**Related Files:**
- `src/components/media/BatchRename.tsx` · `src/utils/fileNaming.ts`

**Subtasks:**
- [ ] **MEDIA-028A**: Create `BatchRename` modal:
  - Template input with variables (date, sequence, custom text)
  - Preview of new names
  - Conflict detection
  - Apply to selected items
- [ ] **MEDIA-028B**: Implement template parser:
  - `{date}` - capture date
  - `{seq}` - sequence number
  - `{custom}` - custom text
  - `{album}` - album name
- [ ] **MEDIA-028C**: Add batch rename to selection actions
- [ ] **MEDIA-028D**: Support undo for batch rename

**Definition of Done:**
- Batch rename modal with template system
- Variable substitution and preview
- Conflict detection and undo support

---

### 🌄 Task MEDIA-029: Landscape Enhancement & Scene Editing
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** MEDIA-007, MEDIA-012

**Rationale:** Adobe Lightroom 2025 added Scene Enhance to edit landscape elements (mountains, water, ground, sky) and snow detection. This provides targeted landscape editing.

**Related Files:**
- `src/components/media/SceneEnhance.tsx` · `src/utils/sceneDetection.ts`

**Subtasks:**
- [ ] **MEDIA-029A**: Create `SceneEnhance` tool:
  - Landscape element detection (sky, mountains, water, ground)
  - Individual element adjustment sliders
  - Snow detection and enhancement
  - Landscape adaptive presets
- [ ] **MEDIA-029B**: Implement scene detection logic (mock: random detection; production: use AI scene segmentation)
- [ ] **MEDIA-029C**: Add landscape presets (golden hour, blue hour, dramatic sky)
- [ ] **MEDIA-029D**: Integrate with MediaEditor

**Definition of Done:**
- Scene detection and element isolation
- Individual element adjustments
- Landscape presets and snow enhancement

---

### 👤 Task MEDIA-030: People Removal & Reflection Removal
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** MEDIA-007, MEDIA-012

**Rationale:** Adobe Lightroom 2025 added People Removal (remove extra people) and Reflections Removal (remove window/glass reflections). These are common photo cleanup needs.

**Related Files:**
- `src/components/media/PeopleRemoval.tsx` · `src/components/media/ReflectionRemoval.tsx`

**Subtasks:**
- [ ] **MEDIA-030A**: Create `PeopleRemoval` tool:
  - Auto-detect people in photo
  - Select people to remove
  - Inpainting preview
  - Brush for manual selection
- [ ] **MEDIA-030B**: Create `ReflectionRemoval` tool:
  - Auto-detect reflections (windows, glass, water)
  - Select reflection areas
  - Remove and inpaint
- [ ] **MEDIA-030C**: Implement detection logic (mock: random detection; production: use AI segmentation)
- [ ] **MEDIA-030D**: Add both tools to MediaEditor
- [ ] **MEDIA-030E**: Batch processing support

**Definition of Done:**
- People removal with auto-detection
- Reflection removal for glass/water
- Manual brush selection and inpainting

---

### ✨ Task MEDIA-031: AI Portrait Editing & Facial Retouching
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** MEDIA-007, MEDIA-010

**Rationale:** Google Photos 2026 added AI-powered portrait editing (skin smoothing, eye brightening, teeth whitening) with intensity sliders. This is a mainstream consumer feature.

**Related Files:**
- `src/components/media/PortraitEditor.tsx` · `src/utils/faceAnalysis.ts`

**Subtasks:**
- [ ] **MEDIA-031A**: Create `PortraitEditor` tool:
  - Skin smoothing slider
  - Eye brightening slider
  - Teeth whitening slider
  - Under-eye adjustment
  - Iris enhancement
  - Eyebrow/lip adjustment
- [ ] **MEDIA-031B**: Implement facial feature detection (mock: face regions; production: use face landmark detection)
- [ ] **MEDIA-031C**: Add intensity slider for all adjustments (0-100)
- [ ] **MEDIA-031D**: Before/after comparison view
- [ ] **MEDIA-031E**: Add "subtle" preset for natural look

**Definition of Done:**
- Portrait editing with facial feature detection
- Multiple adjustment sliders with intensity control
- Before/after comparison and natural presets

---

### 🎥 Task MEDIA-032: Advanced Video Generation Controls
**Priority:** 🟠 Medium | **Est. Effort:** 3 hours | **Depends On:** MEDIA-004

**Rationale:** Runway Gen-4/Gen-4.5 offers Video to Video, Keyframes, and Image to Video workflows with advanced control modes. These are essential for professional video generation.

**Related Files:**
- `src/components/media/VideoToVideo.tsx` · `src/components/media/KeyframesEditor.tsx` · `src/types/videoGeneration.ts`

**Subtasks:**
- [ ] **MEDIA-032A**: Extend generation form with mode selector:
  - Text to Video
  - Image to Video
  - Video to Video
  - Keyframes
- [ ] **MEDIA-032B**: Create `VideoToVideo` component:
  - Source video upload
  - Style transfer prompt
  - Duration control
  - Output settings
- [ ] **MEDIA-032C**: Create `KeyframesEditor`:
  - Timeline view with keyframe markers
  - Frame-by-frame control
  - Interpolation settings
  - Camera guidance controls
- [ ] **MEDIA-032D**: Integrate with generation queue
- [ ] **MEDIA-032E**: Add preview for keyframe sequences

**Definition of Done:**
- Multiple video generation modes
- Video to Video with style transfer
- Keyframes editor with timeline control

---

### 🔊 Task MEDIA-033: Native Audio Generation for Videos
**Priority:** 🟢 Low | **Est. Effort:** 1.5 hours | **Depends On:** MEDIA-004, MEDIA-016

**Rationale:** Runway Gen-4.5 added native audio generation integrated with video. This enables soundtracks and sound effects for AI-generated videos.

**Related Files:**
- `src/components/media/AudioGeneration.tsx` · `src/types/audio.ts`

**Subtasks:**
- [ ] **MEDIA-033A**: Extend `MediaItem` for videos with `generatedAudioUrl?: string`, `audioPrompt?: string`
- [ ] **MEDIA-033B**: Create `AudioGeneration` component:
  - Text-to-audio prompt input
  - Audio style selector (ambient, music, sfx)
  - Duration control
  - Volume and fade controls
- [ ] **MEDIA-033C**: Implement audio generation queue integration
- [ ] **MEDIA-033D**: Add audio timeline to video editor
- [ ] **MEDIA-033E**: Support audio-only generation (standalone)

**Definition of Done:**
- Text-to-audio generation for videos
- Audio style selection and controls
- Audio timeline integration

---

### 🎨 Task MEDIA-034: Color Variance & Consistency Tools
**Priority:** 🟢 Low | **Est. Effort:** 1 hour | **Depends On:** MEDIA-007

**Rationale:** Adobe Lightroom 2025 added Color Variance slider to adjust tone and color for consistent look across photos. This is valuable for series and albums.

**Related Files:**
- `src/components/media/ColorVariance.tsx` · `src/utils/colorAnalysis.ts`

**Subtasks:**
- [ ] **MEDIA-034A**: Create `ColorVariance` tool:
  - Variance slider for tone adjustment
  - Variance slider for color adjustment
  - Preview across selected photos
  - Apply to album/selection
- [ ] **MEDIA-034B**: Implement color consistency analysis (mock: average color; production: use color histogram analysis)
- [ ] **MEDIA-034C**: Add to MediaEditor
- [ ] **MEDIA-034D**: Batch apply variance to multiple photos

**Definition of Done:**
- Color variance sliders for tone and color
- Consistency analysis across photos
- Batch application support

---

## 📊 Updated Task Priority Summary

**High Priority (Core Features):**
- MEDIA-010: People Detection & Facial Recognition
- MEDIA-011: Slideshow & Video Creation
- MEDIA-012: Advanced AI Editing Tools
- MEDIA-014: Memories & Auto-Curated Collections
- MEDIA-019: Privacy & Access Controls
- **MEDIA-025: AI-Assisted Culling & Best Shot Selection** (NEW)

**Medium Priority (Enhanced Features):**
- MEDIA-013: Live Photos Support
- MEDIA-015: Mood Boards & Creative Collections
- MEDIA-020: Advanced Presets & Filters
- **MEDIA-024: Event Details & Metadata Integration** (NEW)
- **MEDIA-027: Color Labels & Advanced Organization** (NEW)
- **MEDIA-029: Landscape Enhancement & Scene Editing** (NEW)
- **MEDIA-030: People Removal & Reflection Removal** (NEW)
- **MEDIA-031: AI Portrait Editing & Facial Retouching** (NEW)
- **MEDIA-032: Advanced Video Generation Controls** (NEW)

**Low Priority (Specialized Features):**
- MEDIA-016: Voice Cloning & Audio for Videos
- MEDIA-017: Character Animation & Lip Sync
- MEDIA-018: Photo Books & Printing Integration
- MEDIA-021: QR Code Sharing & Mobile Features
- MEDIA-022: Third-Party Extensions
- **MEDIA-023: Spatial Photos & 3D Depth Effects** (NEW)
- **MEDIA-026: AI Dust Spot & Defect Removal** (NEW)
- **MEDIA-028: Batch File Renaming** (NEW)
- **MEDIA-033: Native Audio Generation for Videos** (NEW)
- **MEDIA-034: Color Variance & Consistency Tools** (NEW)

**Total Additional Effort:** ~27 hours (original) + ~20 hours (new 12 tasks) = **~47 hours across 25 additional tasks**
