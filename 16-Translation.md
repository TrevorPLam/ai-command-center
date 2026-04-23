# 16-Translation — Personal AI Command Center Frontend (Enhanced v1)

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.

---

## 📐 Reasoning Memo

### Task count: 6 tasks

The Translation module is designed around the core differentiator: **multi-speaker support**. Unlike standard translation apps that handle single-speaker conversations, this module enables real-time translation for meetings, interviews, and group conversations with automatic speaker identification and diarization.

The task structure follows the data flow:
1. **Contract Layer** (types, schemas, queryOptions) - defines the data model for speakers, translations, and sessions
2. **Mock Implementation** (factories, MSW handlers, hooks) - provides realistic test data with multiple speakers
3. **Page Layout** (route configuration, two-column layout) - sets up the translation interface
4. **Speaker Management** (add/remove speakers, speaker profiles) - the key differentiator feature
5. **Translation Display** (real-time transcript, split-screen view, speaker attribution) - shows translated content with speaker labels
6. **Session Controls** (start/stop recording, language selection, export) - manages translation sessions

### Key corrections from research incorporated

| Issue | Research Finding | Implementation |
|-------|------------------|----------------|
| **Speaker diarization** | Transync AI and Otter automatically distinguish speakers | Each translation segment must have `speakerId` and `speakerName` |
| **Language auto-detection** | Modern apps detect language without manual selection | Add `autoDetectLanguage` toggle with fallback to manual selection |
| **Split-screen display** | Transync shows original and translated text side-by-side | Implement dual-pane view with synchronized scrolling |
| **Voice cloning** | Palabra.ai preserves speaker voice in translation | Add `voiceProfile` to speaker settings (mock for MVP) |
| **Real-time streaming** | Low-latency is critical for meetings | Use SSE pattern similar to Chat module for streaming translations |
| **Meeting summaries** | Otter provides AI-generated meeting minutes | Add `generateSummary` mutation that creates session summary |

### Testing structure

Testing is embedded as subtasks within each component task. Infrastructure is assumed complete (FND-004).

---

## 🧱 Cross-Cutting Foundations for Translation

| ID | Requirement |
|----|-------------|
| **TRANS-C01** | Speaker SSOT | TanStack Query cache is the **only** source of truth for speakers and translations. No local `useState` arrays. |
| **TRANS-C02** | Real-time Streaming | SSE over `fetch` + `ReadableStream` for translation streaming (same pattern as Chat module). |
| **TRANS-C03** | Speaker Attribution | Every translation segment must have `speakerId` and display speaker name/color. |
| **TRANS-C04** | Language Pairs | Support bidirectional translation pairs (e.g., English ↔ Spanish) with auto-detection option. |
| **TRANS-C05** | Split-Screen View | Original text and translated text displayed side-by-side with synchronized scrolling. |
| **TRANS-C06** | Session State | Active translation session state (recording, paused, stopped) managed in Zustand `translationSlice`. |
| **TRANS-C07** | ARIA Live Regions | Transcript container: `role="log"` + `aria-live="polite"`. New translation segments announced. |
| **TRANS-C08** | Motion Guard | All animated components check `useReducedMotion()`. |
| **TRANS-C09** | Test Infrastructure | All network calls mocked via MSW handlers in `src/mocks/handlers/translation.ts`. |
| **TRANS-C10** | Export | Export translations as text, JSON, or SRT subtitle format. |

### Motion Tier Assignment

| Component | Tier | Technique |
|-----------|------|-----------|
| Speaker cards | **Quiet** | Opacity fade on mount, 150ms max |
| Translation segment (new) | **Alive** | `opacity: 0→1`, `y: 10→0`, spring `stiffness: 300 damping: 30` |
| Streaming text | **Alive** | Character reveal ~20ms/char; suppressed when `useReducedMotion()` |
| Split-screen scroll sync | **Static** | Instant scroll sync (no animation) |
| Session controls (record/stop) | **Alive** | LED border glow on active; pulse when recording |
| Language selector dropdown | **Quiet** | Opacity fade 100ms |
| Export progress bar | **Quiet** | Width transition (≤150ms) |

---

## 🗃️ Task TRANS-000: Domain Contract Layer — Types, Zod Schemas & queryOptions
**Priority:** 🔴 High | **Est. Effort:** 45 min | **Depends On:** FND-006 (TanStack Query)

> Types and schemas must exist before factories can be typed and before queryOptions can be written.

### Related Files
- `src/types/translation.ts` · `src/schemas/translation.ts` · `src/queries/translation.ts`

### Subtasks
- [ ] **TRANS-000A**: Define TypeScript interfaces in `src/types/translation.ts`:
  ```ts
  export type TranslationStatus = 'idle' | 'recording' | 'processing' | 'completed' | 'error'
  export type LanguageCode = 'en' | 'es' | 'fr' | 'de' | 'ja' | 'zh' | 'ko' | 'pt' | 'ru' | 'ar' | 'hi' | 'it' | 'nl' | 'sv' | 'pl'

  export interface Speaker {
    id: string
    name: string
    color: string // Hex color for visual identification
    voiceProfile?: string // Mock for voice cloning feature
    language: LanguageCode
  }

  export interface TranslationSegment {
    id: string
    sessionId: string
    speakerId: string
    speakerName: string
    originalText: string
    translatedText: string
    originalLanguage: LanguageCode
    targetLanguage: LanguageCode
    timestamp: string // ISO 8601
    confidence: number // 0-1
  }

  export interface TranslationSession {
    id: string
    name: string
    status: TranslationStatus
    sourceLanguage: LanguageCode
    targetLanguage: LanguageCode
    autoDetectLanguage: boolean
    speakers: Speaker[]
    segments: TranslationSegment[]
    startedAt: string
    endedAt?: string
    summary?: string
  }
  ```

- [ ] **[TEST] TRANS-000A**: TypeScript interfaces defined; all required fields present; types compile without errors

- [ ] **TRANS-000B**: Create Zod schemas in `src/schemas/translation.ts`:
  ```ts
  export const SpeakerSchema = z.object({
    id: z.string().uuid(),
    name: z.string().min(1).max(50),
    color: z.string().regex(/^#[0-9A-Fa-f]{6}$/),
    voiceProfile: z.string().optional(),
    language: z.enum(['en', 'es', 'fr', 'de', 'ja', 'zh', 'ko', 'pt', 'ru', 'ar', 'hi', 'it', 'nl', 'sv', 'pl']),
  })

  export const TranslationSegmentSchema = z.object({
    id: z.string().uuid(),
    sessionId: z.string().uuid(),
    speakerId: z.string().uuid(),
    speakerName: z.string(),
    originalText: z.string(),
    translatedText: z.string(),
    originalLanguage: z.enum(['en', 'es', 'fr', 'de', 'ja', 'zh', 'ko', 'pt', 'ru', 'ar', 'hi', 'it', 'nl', 'sv', 'pl']),
    targetLanguage: z.enum(['en', 'es', 'fr', 'de', 'ja', 'zh', 'ko', 'pt', 'ru', 'ar', 'hi', 'it', 'nl', 'sv', 'pl']),
    timestamp: z.string().datetime(),
    confidence: z.number().min(0).max(1),
  })

  export const TranslationSessionSchema = z.object({
    id: z.string().uuid(),
    name: z.string().min(1).max(100),
    status: z.enum(['idle', 'recording', 'processing', 'completed', 'error']),
    sourceLanguage: z.enum(['en', 'es', 'fr', 'de', 'ja', 'zh', 'ko', 'pt', 'ru', 'ar', 'hi', 'it', 'nl', 'sv', 'pl']),
    targetLanguage: z.enum(['en', 'es', 'fr', 'de', 'ja', 'zh', 'ko', 'pt', 'ru', 'ar', 'hi', 'it', 'nl', 'sv', 'pl']),
    autoDetectLanguage: z.boolean(),
    speakers: z.array(SpeakerSchema),
    segments: z.array(TranslationSegmentSchema),
    startedAt: z.string().datetime(),
    endedAt: z.string().datetime().optional(),
    summary: z.string().optional(),
  })

  export type Speaker = z.infer<typeof SpeakerSchema>
  export type TranslationSegment = z.infer<typeof TranslationSegmentSchema>
  export type TranslationSession = z.infer<typeof TranslationSessionSchema>
  ```

- [ ] **[TEST] TRANS-000B**: Zod schemas validate correctly; types derived from schemas; runtime validation works

- [ ] **TRANS-000C**: Create `src/queries/translation.ts` with `queryOptions`:
  ```ts
  export const translationKeys = {
    all: ['translation'] as const,
    sessions: () => [...translationKeys.all, 'sessions'] as const,
    session: (id: string) => [...translationKeys.sessions(), id] as const,
    speakers: () => [...translationKeys.all, 'speakers'] as const,
  }

  export const sessionsQueryOptions = queryOptions({
    queryKey: translationKeys.sessions(),
    queryFn: () => fetchSessions().then(data => z.array(TranslationSessionSchema).parse(data)),
    staleTime: 1000 * 60 * 5, // 5 min
  })

  export const sessionQueryOptions = (id: string) => queryOptions({
    queryKey: translationKeys.session(id),
    queryFn: () => fetchSession(id).then(data => TranslationSessionSchema.parse(data)),
    staleTime: 0, // Real-time updates
    gcTime: Infinity,
  })

  export const speakersQueryOptions = queryOptions({
    queryKey: translationKeys.speakers(),
    queryFn: () => fetchSpeakers().then(data => z.array(SpeakerSchema).parse(data)),
    staleTime: 1000 * 60 * 10, // 10 min
  })
  ```

- [ ] **[TEST] TRANS-000C**: queryOptions defined for all domains; staleTime values correct; Zod parse at query boundary

- [ ] **TRANS-000D**: Create stub fetch functions in `src/api/translation.ts`:
  ```ts
  export const fetchSessions = () => fetch('/api/translation/sessions').then(r => r.json())
  export const fetchSession = (id: string) => fetch(`/api/translation/sessions/${id}`).then(r => r.json())
  export const fetchSpeakers = () => fetch('/api/translation/speakers').then(r => r.json())
  export const createSession = (data: CreateSessionDTO) => fetch('/api/translation/sessions', { method: 'POST', body: JSON.stringify(data) }).then(r => r.json())
  export const updateSession = (id: string, data: UpdateSessionDTO) => fetch(`/api/translation/sessions/${id}`, { method: 'PATCH', body: JSON.stringify(data) }).then(r => r.json())
  export const deleteSession = (id: string) => fetch(`/api/translation/sessions/${id}`, { method: 'DELETE' }).then(r => r.json())
  export const addSpeaker = (data: CreateSpeakerDTO) => fetch('/api/translation/speakers', { method: 'POST', body: JSON.stringify(data) }).then(r => r.json())
  export const removeSpeaker = (id: string) => fetch(`/api/translation/speakers/${id}`, { method: 'DELETE' }).then(r => r.json())
  export const generateSummary = (sessionId: string) => fetch(`/api/translation/sessions/${sessionId}/summary`, { method: 'POST' }).then(r => r.json())
  export const exportSession = (sessionId: string, format: 'json' | 'txt' | 'srt') => fetch(`/api/translation/sessions/${sessionId}/export?format=${format}`).then(r => r.blob())
  ```

- [ ] **[TEST] TRANS-000D**: Stub fetch functions created; return promises; MSW can intercept

### Definition of Done
- All interfaces/types exported from Zod schemas
- Zod schemas parse without error for all shape variations
- `queryOptions` defined for sessions, session detail, and speakers
- Stub fetch functions created
- `tsc --noEmit` passes

### Anti-Patterns
- ❌ Defining types inline inside component files
- ❌ Using `any` as query function return type
- ❌ Duplicating type definitions across `types/` and `schemas/`

---

## 🏭 Task TRANS-001: Mock Data Factories, MSW Handlers & Custom Hooks
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** TRANS-000, FND-004 (Testing Infra)

### Related Files
- `src/mocks/factories/translation.ts` · `src/mocks/handlers/translation.ts` · `src/hooks/useTranslation.ts`

### Subtasks

**Factories:**
- [ ] **TRANS-001A**: Create `src/mocks/factories/translation.ts` using `@faker-js/faker`:
  ```ts
  import { faker } from '@faker-js/faker'

  const SPEAKER_COLORS = ['#0066ff', '#00ff99', '#ffaa00', '#ff4545', '#aa00ff', '#00aaff']
  const LANGUAGES = ['en', 'es', 'fr', 'de', 'ja', 'zh', 'ko', 'pt', 'ru', 'ar', 'hi', 'it', 'nl', 'sv', 'pl'] as const

  export const createSpeaker = (overrides: Partial<Speaker> = {}): Speaker => ({
    id: faker.string.uuid(),
    name: faker.person.fullName(),
    color: faker.helpers.arrayElement(SPEAKER_COLORS),
    voiceProfile: faker.datatype.boolean() ? `voice-${faker.string.alphanumeric(8)}` : undefined,
    language: faker.helpers.arrayElement(LANGUAGES),
    ...overrides,
  })

  export const createSpeakers = (count = 3): Speaker[] =>
    Array.from({ length: count }, (_, i) =>
      createSpeaker({ name: `Speaker ${i + 1}`, language: i === 0 ? 'en' : 'es' })
    )

  export const createTranslationSegment = (overrides: Partial<TranslationSegment> = {}): TranslationSegment => ({
    id: faker.string.uuid(),
    sessionId: faker.string.uuid(),
    speakerId: faker.string.uuid(),
    speakerName: faker.person.fullName(),
    originalText: faker.lorem.sentence(),
    translatedText: faker.lorem.sentence(),
    originalLanguage: faker.helpers.arrayElement(LANGUAGES),
    targetLanguage: faker.helpers.arrayElement(LANGUAGES),
    timestamp: faker.date.recent({ days: 1 }).toISOString(),
    confidence: faker.number.float({ min: 0.7, max: 1.0 }),
    ...overrides,
  })

  export const createTranslationSession = (overrides: Partial<TranslationSession> = {}): TranslationSession => {
    const speakers = createSpeakers(3)
    const segments = Array.from({ length: 20 }, () =>
      createTranslationSegment({
        sessionId: overrides.id || faker.string.uuid(),
        speakerId: faker.helpers.arrayElement(speakers.map(s => s.id)),
        speakerName: faker.helpers.arrayElement(speakers.map(s => s.name)),
      })
    )

    return {
      id: faker.string.uuid(),
      name: faker.lorem.words(3),
      status: faker.helpers.arrayElement(['idle', 'recording', 'processing', 'completed', 'error'] as const),
      sourceLanguage: 'en',
      targetLanguage: 'es',
      autoDetectLanguage: true,
      speakers,
      segments,
      startedAt: faker.date.recent({ days: 7 }).toISOString(),
      endedAt: faker.datatype.boolean() ? faker.date.recent({ days: 1 }).toISOString() : undefined,
      summary: faker.datatype.boolean() ? faker.lorem.paragraph() : undefined,
      ...overrides,
    }
  }

  export const createTranslationSessions = (count = 5): TranslationSession[] =>
    Array.from({ length: count }, () => createTranslationSession())
  ```

- [ ] **[TEST] TRANS-001A**: Factories produce valid data; faker seeded correctly; all factory functions work

- [ ] **TRANS-001B**: Create `src/mocks/handlers/translation.ts` with stateful handlers:
  ```ts
  import { http, HttpResponse, delay } from 'msw'
  import { createTranslationSessions, createSpeakers, createTranslationSession } from '../factories/translation'

  let sessionsDb = createTranslationSessions(5)
  let speakersDb = createSpeakers(3)

  export const translationHandlers = [
    http.get('/api/translation/sessions', async () => {
      await delay(300)
      return HttpResponse.json(sessionsDb)
    }),
    http.get('/api/translation/sessions/:id', async ({ params }) => {
      await delay(200)
      const session = sessionsDb.find(s => s.id === params.id)
      if (!session) return new HttpResponse(null, { status: 404 })
      return HttpResponse.json(session)
    }),
    http.get('/api/translation/speakers', async () => {
      await delay(200)
      return HttpResponse.json(speakersDb)
    }),
    http.post('/api/translation/sessions', async ({ request }) => {
      await delay(400)
      const data = await request.json()
      const newSession = createTranslationSession({ ...data, id: faker.string.uuid(), status: 'recording' })
      sessionsDb.unshift(newSession)
      return HttpResponse.json(newSession)
    }),
    http.patch('/api/translation/sessions/:id', async ({ params, request }) => {
      await delay(300)
      const data = await request.json()
      sessionsDb = sessionsDb.map(s => s.id === params.id ? { ...s, ...data } : s)
      const updated = sessionsDb.find(s => s.id === params.id)
      return HttpResponse.json(updated)
    }),
    http.delete('/api/translation/sessions/:id', async ({ params }) => {
      await delay(200)
      sessionsDb = sessionsDb.filter(s => s.id !== params.id)
      return HttpResponse.json({ success: true })
    }),
    http.post('/api/translation/speakers', async ({ request }) => {
      await delay(300)
      const data = await request.json()
      const newSpeaker = createSpeaker(data)
      speakersDb.push(newSpeaker)
      return HttpResponse.json(newSpeaker)
    }),
    http.delete('/api/translation/speakers/:id', async ({ params }) => {
      await delay(200)
      speakersDb = speakersDb.filter(s => s.id !== params.id)
      return HttpResponse.json({ success: true })
    }),
    http.post('/api/translation/sessions/:id/summary', async ({ params }) => {
      await delay(1000)
      const session = sessionsDb.find(s => s.id === params.id)
      if (session) {
        session.summary = faker.lorem.paragraphs(2)
        session.status = 'completed'
      }
      return HttpResponse.json({ summary: session?.summary })
    }),
    http.get('/api/translation/sessions/:id/export', async ({ params, request }) => {
      await delay(500)
      const url = new URL(request.url)
      const format = url.searchParams.get('format') || 'json'
      const session = sessionsDb.find(s => s.id === params.id)
      if (!session) return new HttpResponse(null, { status: 404 })

      if (format === 'json') {
        return HttpResponse.json(session)
      } else if (format === 'txt') {
        const text = session.segments.map(s => `[${s.speakerName}]: ${s.translatedText}`).join('\n')
        return HttpResponse.json({ content: text })
      } else if (format === 'srt') {
        const srt = session.segments.map((s, i) => {
          const start = i * 3
          const end = start + 2
          return `${i + 1}\n00:00:${start.toFixed(2).padStart(5, '0')} --> 00:00:${end.toFixed(2).padStart(5, '0')}\n${s.translatedText}\n`
        }).join('\n')
        return HttpResponse.json({ content: srt })
      }
      return new HttpResponse(null, { status: 400 })
    }),
  ]
  ```

- [ ] **[TEST] TRANS-001B**: MSW handlers intercept requests; in-memory state persists; delay() works

- [ ] **TRANS-001C**: Add a `resetTranslationDb()` export for test isolation:
  ```ts
  export const resetTranslationDb = () => {
    faker.seed(12345)
    sessionsDb = createTranslationSessions(5)
    speakersDb = createSpeakers(3)
  }
  ```

- [ ] **[TEST] TRANS-001C**: resetTranslationDb() resets all state; faker.seed(12345) produces deterministic data

- [ ] **TRANS-001D**: Create `src/hooks/useTranslation.ts` with custom hooks:
  ```ts
  export function useSessions() { return useQuery(sessionsQueryOptions) }
  export function useSession(id: string) { return useQuery(sessionQueryOptions(id)) }
  export function useSpeakers() { return useQuery(speakersQueryOptions) }

  export function useCreateSession() {
    const queryClient = useQueryClient()
    return useMutation({
      mutationFn: createSession,
      onMutate: async (newSession) => {
        await queryClient.cancelQueries({ queryKey: translationKeys.sessions() })
        const previous = queryClient.getQueryData(TranslationSession[])(translationKeys.sessions())
        queryClient.setQueryData(TranslationSession[])(translationKeys.sessions(), old => [newSession, ...(old || [])])
        return { previous }
      },
      onError: (_err, _newSession, context) => {
        if (context?.previous) queryClient.setQueryData(translationKeys.sessions(), context.previous)
      },
      onSettled: () => queryClient.invalidateQueries({ queryKey: translationKeys.sessions() }),
    })
  }

  export function useUpdateSession() {
    const queryClient = useQueryClient()
    return useMutation({
      mutationFn: ({ id, data }: { id: string; data: UpdateSessionDTO }) => updateSession(id, data),
      onMutate: async ({ id, data }) => {
        await queryClient.cancelQueries({ queryKey: translationKeys.session(id) })
        const previous = queryClient.getQueryData(TranslationSession)(translationKeys.session(id))
        queryClient.setQueryData(TranslationSession)(translationKeys.session(id), old => old ? { ...old, ...data } : null)
        return { previous }
      },
      onError: (_err, _vars, context) => {
        if (context?.previous) queryClient.setQueryData(translationKeys.session(context.previous.id), context.previous)
      },
      onSettled: (_vars, _err, { id }) => queryClient.invalidateQueries({ queryKey: translationKeys.session(id) }),
    })
  }

  export function useDeleteSession() {
    const queryClient = useQueryClient()
    return useMutation({
      mutationFn: deleteSession,
      onMutate: async (id) => {
        await queryClient.cancelQueries({ queryKey: translationKeys.sessions() })
        const previous = queryClient.getQueryData(TranslationSession[])(translationKeys.sessions())
        queryClient.setQueryData(TranslationSession[])(translationKeys.sessions(), old => old?.filter(s => s.id !== id) ?? [])
        return { previous }
      },
      onError: (_err, _id, context) => {
        if (context?.previous) queryClient.setQueryData(translationKeys.sessions(), context.previous)
      },
      onSettled: () => queryClient.invalidateQueries({ queryKey: translationKeys.sessions() }),
    })
  }

  export function useAddSpeaker() {
    const queryClient = useQueryClient()
    return useMutation({
      mutationFn: addSpeaker,
      onMutate: async (newSpeaker) => {
        await queryClient.cancelQueries({ queryKey: translationKeys.speakers() })
        const previous = queryClient.getQueryData(Speaker[])(translationKeys.speakers())
        queryClient.setQueryData(Speaker[])(translationKeys.speakers(), old => [...(old || []), newSpeaker])
        return { previous }
      },
      onError: (_err, _newSpeaker, context) => {
        if (context?.previous) queryClient.setQueryData(translationKeys.speakers(), context.previous)
      },
      onSettled: () => queryClient.invalidateQueries({ queryKey: translationKeys.speakers() }),
    })
  }

  export function useRemoveSpeaker() {
    const queryClient = useQueryClient()
    return useMutation({
      mutationFn: removeSpeaker,
      onMutate: async (id) => {
        await queryClient.cancelQueries({ queryKey: translationKeys.speakers() })
        const previous = queryClient.getQueryData(Speaker[])(translationKeys.speakers())
        queryClient.setQueryData(Speaker[])(translationKeys.speakers(), old => old?.filter(s => s.id !== id) ?? [])
        return { previous }
      },
      onError: (_err, _id, context) => {
        if (context?.previous) queryClient.setQueryData(translationKeys.speakers(), context.previous)
      },
      onSettled: () => queryClient.invalidateQueries({ queryKey: translationKeys.speakers() }),
    })
  }

  export function useGenerateSummary() {
    const queryClient = useQueryClient()
    return useMutation({
      mutationFn: generateSummary,
      onSuccess: (data, sessionId) => {
        queryClient.setQueryData(TranslationSession)(translationKeys.session(sessionId), old => old ? { ...old, summary: data.summary, status: 'completed' } : null)
      },
    })
  }

  export function useExportSession() {
    return useMutation({
      mutationFn: ({ sessionId, format }: { sessionId: string; format: 'json' | 'txt' | 'srt' }) => exportSession(sessionId, format),
    })
  }
  ```

- [ ] **[TEST] TRANS-001D**: Custom hooks consume queryOptions; type inference works; optimistic updates implemented correctly

- [ ] **TRANS-001E**: Verify `pnpm test` passes — MSW intercepts factory data and hooks return typed values

- [ ] **[TEST] TRANS-001E**: Tests pass; MSW intercepts; hooks return typed values

### Definition of Done
- Factories use `@faker-js/faker` and produce schema-valid data
- `resetTranslationDb()` exported and works with `faker.seed(12345)`
- MSW handlers maintain in-memory state for mutations
- All handlers include `delay()` for realistic latency
- Custom hooks consume `queryOptions` with full type inference
- Optimistic updates use `onMutate` in `useMutation()` definition
- Cache updates use immutable spreads/filters

### Anti-Patterns
- ❌ Hand-written static mock objects
- ❌ `faker.seed()` called inside factory functions
- ❌ Stateless MSW mutation handlers
- ❌ `onMutate` defined inside `.mutate()` override
- ❌ `setQueryData` mutating cached array directly

---

## 🟢 Task TRANS-002: Translation Page Layout & Route Configuration
**Priority:** 🔴 High | **Est. Effort:** 30 min | **Depends On:** FND-007 (Router), FND-008 (Provider Tree)

### Related Files
- `src/pages/TranslationPage.tsx` · `src/router/routes.ts` · `src/layouts/AppShell.tsx`

### Subtasks

**Implementation:**
- [ ] **TRANS-002A**: Create `src/pages/TranslationPage.tsx`:
  - Two-column layout: left session list (280px fixed), right translation area (`flex-1`)
  - Left column: session list with "New Session" button, search/filter
  - Right column: split-screen view (original text | translated text) or session detail
  - Wrap in `<motion.div>` page transition: `initial={{ opacity: 0, y: 8 }}` → `animate={{ opacity: 1, y: 0 }}` → `exit={{ opacity: 0, y: -8 }}`, 200ms
- [ ] **[TEST] TRANS-002A**: `TranslationPage` renders both session list and translation area within layout

- [ ] **TRANS-002B**: Responsive collapse: on `<768px`, session list moves into a shadcn `Sheet` (overlay drawer). Translation area occupies full width on mobile.
- [ ] **[TEST] TRANS-002B**: At `767px` viewport, session list is not visible in document flow; Sheet trigger is present

- [ ] **TRANS-002C**: Configure route in `src/router/routes.ts`:
  ```ts
  {
    path: 'translation',
    lazy: () => import('@/pages/TranslationPage'),
    loader: () => queryClient.ensureQueryData(sessionsQueryOptions),
  }
  ```
- [ ] **[TEST] TRANS-002C**: Navigating to `/translation` triggers session prefetch; `TranslationPage` is reachable via router

- [ ] **TRANS-002D**: Ensure `TranslationPage` is wrapped by `AnimatePresence` at the router level. Confirm `key={location.pathname}` on the motion wrapper.
- [ ] **[TEST] TRANS-002D**: Navigating away from `/translation` triggers exit animation

- [ ] **TRANS-002E**: Add `<Suspense fallback={<TranslationSkeleton />}>` around lazy-loaded page content
- [ ] **[TEST] TRANS-002E**: `TranslationSkeleton` renders during lazy load

### Definition of Done
- `/translation` renders two-column layout; sessions prefetched by loader
- Mobile: session list in Sheet overlay
- Page transition fires on enter and exit

### Anti-Patterns
- ❌ Missing `key` on page transition `motion.div`
- ❌ Fetching data in `useEffect` instead of route `loader`

---

## 🎤 Task TRANS-003: Speaker Management
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** TRANS-001, TRANS-002

### Related Files
- `src/components/translation/SpeakerManager.tsx` · `src/components/translation/SpeakerCard.tsx` · `src/components/translation/AddSpeakerDialog.tsx`

### Subtasks

**SpeakerCard:**
- [ ] **TRANS-003A**: Build `SpeakerCard` component:
  - Displays: speaker name, color indicator (circle), language badge, voice profile status
  - Actions: Edit (icon), Remove (icon)
  - Color indicator uses speaker's assigned color for visual identification
  - Language badge shows language code (e.g., "EN", "ES")
- [ ] **[TEST] TRANS-003A**: Speaker card renders with name, color, language, and actions

- [ ] **TRANS-003B**: Hover effect: `whileHover={{ y: -2 }}` with spring transition
- [ ] **[TEST] TRANS-003B**: Hover lifts card by 2px with spring animation

**SpeakerManager:**
- [ ] **TRANS-003C**: Build `SpeakerManager` component:
  - Consumes `useSpeakers()`, `useAddSpeaker()`, `useRemoveSpeaker()`
  - Grid layout: `grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4`
  - "Add Speaker" button (electric blue, primary)
  - Empty state: "No speakers added. Add speakers to enable multi-speaker translation."
  - Loading skeleton: 3 skeleton cards while `isLoading`
- [ ] **[TEST] TRANS-003C**: Speaker manager renders cards; empty state shows when no speakers; loading skeleton renders

- [ ] **TRANS-003D**: Staggered entrance with `LayoutGroup`:
  ```tsx
  <LayoutGroup id="speaker-manager">
    <motion.div variants={containerVariants} initial="hidden" animate="visible">
      {speakers.map(speaker => <SpeakerCard key={speaker.id} speaker={speaker} />)}
    </motion.div>
  </LayoutGroup>
  ```
- [ ] **[TEST] TRANS-003D**: Cards stagger in with animation; `LayoutGroup` prevents namespace collision

**AddSpeakerDialog:**
- [ ] **TRANS-003E**: Build `AddSpeakerDialog` using shadcn `Dialog`:
  - Fields: name (text input), language (select), color (color picker), voice profile (optional toggle)
  - Validation via RHF + Zod using `SpeakerSchema`
  - "Add" button calls `useAddSpeaker()` mutation
  - On success: close dialog, show toast
- [ ] **[TEST] TRANS-003E**: Dialog opens on button click; form validates; add creates speaker optimistically

- [ ] **TRANS-003F**: Color picker provides preset colors matching `SPEAKER_COLORS` from factory
- [ ] **[TEST] TRANS-003F**: Color picker shows preset colors; selection updates form state

### Definition of Done
- Speaker cards render with color, name, language
- Speaker manager with grid layout and staggered entrance
- Add speaker dialog with validation and optimistic update
- Empty state and loading skeleton handled

### Anti-Patterns
- ❌ No `LayoutGroup` — causes `layoutId` collision if component renders twice
- ❌ Missing validation on speaker form
- ❌ Not using optimistic updates for add/remove

---

## 💬 Task TRANS-004: Translation Display & Split-Screen View
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** TRANS-001, TRANS-002

### Related Files
- `src/components/translation/TranslationDisplay.tsx` · `src/components/translation/TranslationSegment.tsx` · `src/components/translation/SplitScreenView.tsx`

### Subtasks

**TranslationSegment:**
- [ ] **TRANS-004A**: Build `TranslationSegment` component:
  - Displays: speaker name (with color indicator), original text, translated text, timestamp, confidence badge
  - Speaker name uses speaker's assigned color
  - Confidence badge: green (>0.9), amber (0.7-0.9), red (<0.7)
  - Props: `segment`, `isStreaming`
  - Wrapped in `React.memo` with custom comparator
- [ ] **[TEST] TRANS-004A**: Segment renders with speaker name, original/translated text, confidence badge

- [ ] **TRANS-004B**: Streaming text reveal (similar to Chat module):
  - Maintain `displayedContent` in `useRef` updated by `useEffect`
  - Reveal characters at ~20ms/char while `isStreaming`
  - If `useReducedMotion()` is true: show full content immediately
- [ ] **[TEST] TRANS-004B**: With `isStreaming=true`, content reveals incrementally; reduced motion renders full content instantly

- [ ] **TRANS-004C**: New segment entrance animation:
  - `<motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ type: 'spring', stiffness: 300, damping: 30 }}>`
  - Applied only when segment is new (not loaded from history)
- [ ] **[TEST] TRANS-004C**: New segment has `y` and `opacity` animated; historical segments render without animation

**SplitScreenView:**
- [ ] **TRANS-004D**: Build `SplitScreenView` component:
  - Two-pane layout: left (original text), right (translated text)
  - Each pane: scrollable with synchronized scrolling
  - Use `useSyncScroll` hook (custom) to sync scroll positions
  - Headers: "Original" / "Translated" with language badges
- [ ] **[TEST] TRANS-004D**: Split-screen renders two panes; scrolling one pane syncs the other

- [ ] **TRANS-004E**: Synchronized scrolling implementation:
  ```ts
  export function useSyncScroll() {
    const leftRef = useRef<HTMLDivElement>(null)
    const rightRef = useRef<HTMLDivElement>(null)

    const handleLeftScroll = useCallback(() => {
      if (leftRef.current && rightRef.current) {
        rightRef.current.scrollTop = leftRef.current.scrollTop
      }
    }, [])

    const handleRightScroll = useCallback(() => {
      if (rightRef.current && leftRef.current) {
        leftRef.current.scrollTop = rightRef.current.scrollTop
      }
    }, [])

    return { leftRef, rightRef, handleLeftScroll, handleRightScroll }
  }
  ```
- [ ] **[TEST] TRANS-004E**: Scrolling left pane updates right pane position and vice versa

**TranslationDisplay:**
- [ ] **TRANS-004F**: Build `TranslationDisplay` component:
  - Consumes `useSession(sessionId)` for segments
  - Renders `SplitScreenView` with `TranslationSegment` items
  - ARIA: `role="log"` + `aria-live="polite"` on container
  - Virtualization with `@tanstack/react-virtual` for sessions with 50+ segments
- [ ] **[TEST] TRANS-004F**: Display renders segments in split-screen; ARIA attributes present; virtualization active for large lists

- [ ] **TRANS-004G**: Virtualization implementation:
  ```ts
  const virtualizer = useVirtualizer({
    count: segments.length,
    getScrollElement: () => scrollRef.current,
    estimateSize: () => 120,
    measureElement: (el) => el.getBoundingClientRect().height,
    overscan: 5,
  })
  ```
- [ ] **[TEST] TRANS-004G**: Only visible segments in DOM; DOM node count bounded

### Definition of Done
- Translation segments render with speaker attribution and confidence
- Streaming text reveal works; reduced motion respected
- Split-screen view with synchronized scrolling
- Virtualization for large segment lists
- ARIA live region present

### Anti-Patterns
- ❌ Not using `React.memo` on `TranslationSegment` — causes unnecessary re-renders
- ❌ Missing synchronized scrolling in split-screen view
- ❌ Not virtualizing large segment lists — performance degradation
- ❌ Animating historical segments — only new segments should animate

---

## 🎛️ Task TRANS-005: Session Controls & Export
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** TRANS-001, TRANS-002

### Related Files
- `src/components/translation/SessionControls.tsx` · `src/components/translation/ExportDialog.tsx`

### Subtasks

**SessionControls:**
- [ ] **TRANS-005A**: Build `SessionControls` component:
  - Displays: session name (editable), status badge, language pair, speaker count
  - Controls: Start/Stop recording (toggle button), Generate Summary (button), Export (button)
  - Status badge colors: recording (red pulse), processing (amber), completed (green), error (red)
  - Language pair display: "EN → ES" format
- [ ] **[TEST] TRANS-005A**: Controls render with session info; status badge shows correct color

- [ ] **TRANS-005B**: LED border effect on recording (similar to Chat input):
  - When `status === 'recording'`, add animated border glow
  - Use `@property` conic-gradient animation from FND-000
- [ ] **[TEST] TRANS-005B**: Recording state shows animated border; idle state shows static border

- [ ] **TRANS-005C**: Start/Stop recording:
  - Calls `useUpdateSession()` mutation to toggle status between 'idle' and 'recording'
  - Optimistic update: status changes immediately, rolls back on error
  - Toast notification on success
- [ ] **[TEST] TRANS-005C**: Start/Stop toggles status optimistically; error rolls back; toast shows

- [ ] **TRANS-005D**: Generate Summary:
  - Calls `useGenerateSummary()` mutation
  - Shows loading spinner while generating
  - On success: displays summary in expandable section below controls
- [ ] **[TEST] TRANS-005D**: Generate Summary calls mutation; loading spinner shows; summary displays on success

**ExportDialog:**
- [ ] **TRANS-005E**: Build `ExportDialog` using shadcn `Dialog`:
  - Format selection: JSON, TXT, SRT (radio buttons)
  - Preview: shows first 3 lines of export content
  - "Export" button calls `useExportSession()` mutation
  - Progress bar during export (simulated)
  - Download button appears after export completes
- [ ] **[TEST] TRANS-005E**: Dialog opens; format selection works; export shows progress; download appears after completion

- [ ] **TRANS-005F**: Export format handling:
  - JSON: full session object
  - TXT: plain text with speaker labels
  - SRT: subtitle format with timestamps
- [ ] **[TEST] TRANS-005F**: Each format produces correct output structure

- [ ] **TRANS-005G**: Download functionality:
  - Create `Blob` from export content
  - Create `URL.createObjectURL(blob)`
  - Trigger download via hidden `<a>` tag
  - Cleanup URL after download
- [ ] **[TEST] TRANS-005G**: Download triggers browser download; file has correct content

### Definition of Done
- Session controls with recording toggle, summary generation, export
- LED border glow on recording state
- Export dialog with format selection and download
- Summary display after generation
- Optimistic updates on status changes

### Anti-Patterns
- ❌ Not using optimistic updates for status changes
- ❌ Missing error handling on export
- ❌ Not cleaning up object URLs after download
- ❌ Export progress not shown to user

---

## 📊 Task TRANS-006: Streaming Translation (SSE)
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** TRANS-001, TRANS-004

### Related Files
- `src/hooks/useTranslationStream.ts` · `src/mocks/handlers/translation.ts` (SSE handler)

### Subtasks

- [ ] **TRANS-006A**: Create `src/hooks/useTranslationStream.ts`:
  ```ts
  function useTranslationStream(options: {
    sessionId: string
    onSegment: (segment: TranslationSegment) => void
    onComplete: () => void
    onError: (err: Error) => void
  }): {
    startStream: () => void
    abortStream: () => void
    isStreaming: boolean
  }
  ```

  Internal contract:
  - `abortControllerRef = useRef<AbortController | null>(null)`
  - `startStream` creates new `AbortController`, stores in ref, calls `fetch('/api/translation/sessions/:id/stream', { signal })`
  - Parse SSE lines: `data: {segment}\n\n` → call `onSegment`; `data: [DONE]\n\n` → call `onComplete`
  - Cleanup: abort on unmount
- [ ] **[TEST] TRANS-006A**: `startStream` fetches SSE endpoint; segments call `onSegment`; `[DONE]` calls `onComplete`; abort on unmount

- [ ] **TRANS-006B**: Parse streamed response with `ReadableStream` + `TextDecoder` (same pattern as Chat module)
- [ ] **[TEST] TRANS-006B**: Partial chunks reassemble correctly; `AbortError` does not call `onError`

- [ ] **TRANS-006C**: Integrate with `useSession` and `useUpdateSession`:
  - On stream start: update session status to 'recording'
  - Each `onSegment`: use `queryClient.setQueryData` to append segment to session's segments array
  - `onComplete`: update session status to 'completed'
  - `onError`: update session status to 'error'
- [ ] **[TEST] TRANS-006C**: Segments accumulate in session cache; status updates on complete/error

- [ ] **TRANS-006D**: Mock SSE handler in `src/mocks/handlers/translation.ts`:
  ```ts
  http.get('/api/translation/sessions/:id/stream', () => {
    const segments = createTranslationSegments(10)
    const stream = new ReadableStream({
      async start(controller) {
        for (const segment of segments) {
          controller.enqueue(`data: ${JSON.stringify(segment)}\n\n`)
          await delay(100)
        }
        controller.enqueue('data: [DONE]\n\n')
        controller.close()
      }
    })
    return new Response(stream, { headers: { 'Content-Type': 'text/event-stream' } })
  })
  ```
- [ ] **[TEST] TRANS-006D**: MSW stream handler delivers segments at expected intervals; `[DONE]` triggers completion

### Definition of Done
- `useTranslationStream` manages `AbortController` lifecycle
- SSE chunks parsed correctly including partial chunks
- Segments accumulate in TanStack Query cache
- Status updates on complete/error
- MSW mock streams segments reliably

### Anti-Patterns
- ❌ `EventSource` API — no support for custom headers
- ❌ Not aborting previous stream before starting new
- ❌ `AbortError` triggering `onError`
- ❌ Not buffering partial chunks

---

## 📊 Dependency Graph
```
TRANS-000 (Domain Contract Layer)
     │
TRANS-001 (Mock Data, MSW, Hooks)
     │
TRANS-002 (Page Layout & Route)
     │
     ├── TRANS-003 (Speaker Management)
     │
     ├── TRANS-004 (Translation Display)
     │
     ├── TRANS-005 (Session Controls & Export)
     │
     └── TRANS-006 (Streaming Translation)
```

## 🏁 Translation Module Completion Checklist
**Contract Layer:**
- [ ] Types and Zod schemas defined for Speaker, TranslationSegment, TranslationSession
- [ ] queryOptions defined for sessions, session detail, and speakers
- [ ] Stub fetch functions created

**Mock Implementation:**
- [ ] Factories produce valid data with `@faker-js/faker`
- [ ] MSW handlers maintain in-memory state
- [ ] Custom hooks with optimistic updates

**Page Layout:**
- [ ] Two-column layout with session list and translation area
- [ ] Responsive collapse on mobile
- [ ] Route configured with prefetch

**Speaker Management:**
- [ ] Speaker cards with color, name, language
- [ ] Add/remove speaker with optimistic updates
- [ ] Speaker dialog with validation

**Translation Display:**
- [ ] Split-screen view with synchronized scrolling
- [ ] Translation segments with speaker attribution
- [ ] Streaming text reveal
- [ ] Virtualization for large lists

**Session Controls:**
- [ ] Start/stop recording with LED border
- [ ] Generate summary
- [ ] Export with format selection (JSON/TXT/SRT)

**Streaming:**
- [ ] SSE streaming hook with AbortController
- [ ] Segment accumulation in cache
- [ ] Status updates on complete/error
