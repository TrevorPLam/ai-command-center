# 42‑Research — Personal AI Command Center Frontend

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.

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

## 📐 Reasoning Memo: Research as a Dedicated Learning Space

The Research module is designed as a formal, educational workspace that transforms passive document consumption into active learning. Inspired by Google's NotebookLM and advanced research tools like Algor Education and MindMap AI, this module serves as a dedicated space for deep learning, knowledge synthesis, and academic research.

Unlike other modules that focus on task management or communication, Research is specifically engineered for:
- **Knowledge Synthesis**: Converting complex documents into understandable concepts
- **Active Learning**: Interactive tools like flashcards, quizzes, and mind maps
- **Visual Thinking**: Mind maps and knowledge graphs for spatial learners
- **AI-Powered Tutoring**: Personalized learning guidance and explanations
- **Multi-Modal Learning**: Audio overviews, visual summaries, and interactive content

---

## 🔬 Research Findings — Research Module

| Finding | Source | Action Required |
|---------|--------|-----------------|
| **NotebookLM's core features** include flashcards, quizzes, reports, Learning Guide, and Audio Overviews with multiple formats (Brief, Critique, Debate) | Google NotebookLM Blog | RES-007: Implement flashcard and quiz system; RES-008: Build Learning Guide; RES-009: Create Audio Overviews |
| **Visual mind mapping** is essential for spatial learners and complex concept relationships. Tools like Algor and MindMap AI show demand for interactive, editable mind maps | Algor Education, MindMap AI | RES-006: Build interactive mind maps with full editing capabilities |
| **Multi-format input support** (PDFs, audio, video, images, text) is standard for modern research tools | MindMap AI Features | RES-004: Support multiple document formats in Research workspace |
| **Second-order connections** and hidden relationship detection between concepts is a key differentiator | MindMap AI Research | RES-006: Implement concept relationship analysis |
| **Academic content integration** with trusted sources like OpenStax textbooks provides verified learning materials | Google-OpenStax Partnership | RES-011: Integrate with academic content sources |
| **Custom report generation** with multiple formats (blog posts, study guides, glossaries) adapts to user needs | NotebookLM Reports | RES-010: Build flexible report generation system |
| **Personalized tutoring** through AI chat that adapts explanations to user level and learning style | NotebookLM Learning Guide | RES-008: Implement adaptive AI tutoring system |
| **Collaborative learning** features for sharing notebooks and study materials | Modern EdTech Trends | RES-012: Add sharing and collaboration capabilities |

---

## 🧱 Cross-Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **RES-C01** | State Management | Zustand `researchSlice` for active notebook, documents, learning modes, and AI interactions. |
| **RES-C02** | Document Processing | Multi-format support: PDF, text, audio, video, images. OCR and speech-to-text for content extraction. |
| **RES-C03** | AI Integration | Local LLM integration for document analysis, summarization, and tutoring. Streaming responses for real-time interaction. HTML content rendered via shared `SanitizedHTML` component. |
| **RES-C04** | Visual Knowledge | Interactive mind maps with drag-and-drop, multiple layouts (mind map, concept map, tree). |
| **RES-C05** | Learning Tools | Flashcards, quizzes, spaced repetition, progress tracking. |
| **RES-C06** | Audio Processing | Text-to-speech for content narration, audio overview generation in multiple formats. |
| **RES-C07** | Content Sources | Integration with academic databases, trusted sources, and cross-module document access. |
| **RES-C08** | Collaboration | Shareable notebooks, collaborative annotations, study group features. |
| **RES-C09** | Accessibility | WCAG 2.2 AA compliance for all learning tools, screen reader support, keyboard navigation. |
| **RES-C10** | Performance | Lazy loading of large documents, virtualized content lists, efficient AI processing. |
| **RES-C11** | Motion | Alive tier for mind map interactions, Quiet tier for learning tool transitions. |
| **RES-C12** | Offline Support | Dexie for document caching, offline study mode, sync when reconnected. |

### 🎯 Motion Tier Assignment

| Component | Tier | Technique |
|-----------|------|--------------------|
| Mind map node creation | **Alive** | `scale: 0.95→1` with spring, glow effect on hover |
| Document upload processing | **Alive** | Progress bar with pulse, `scaleY: 0→1` animation |
| Flashcard flip animation | **Alive** | 3D rotation effect with `rotateY: 0→180deg` |
| Quiz answer reveal | **Quiet** | `opacity: 0→1` fade with 150ms duration |
| Audio overview playback | **Quiet** | Waveform visualization with subtle pulse |
| Report generation | **Alive** | Typewriter effect for content generation |
| Learning Guide chat | **Quiet** | Message slide-in with `y: 8→0` |
| Study progress indicators | **Alive** | Circular progress fill with `scaleX: 0→1` |
| Content search results | **Static** | Instant render for responsive search |
| Collaboration cursor | **Quiet** | Subtle pulse with user color |

---


## 🗂️ Task RES-000: Research Domain Model & Mock Data

**Priority:** 🔴 High
**Est. Effort:** 2 hours
**Depends On:** FND-004 (Testing), FND-006 (TanStack Query)

### Related Files
`src/domain/research/types.ts` · `src/schemas/researchSchema.ts` · `src/mocks/factories/research.ts` · `src/mocks/handlers/research.ts` · `src/queries/research.ts`

### Subtasks

- [ ] **RES-000A**: Define core domain types in `src/domain/research/types.ts`:
  ```ts
  export type DocumentType = 'pdf' | 'text' | 'audio' | 'video' | 'image' | 'webpage'
  export type LearningMode = 'study' | 'review' | 'explore' | 'tutor'
  export type MindMapLayout = 'mindmap' | 'conceptmap' | 'tree' | 'doubletree' | 'compact'
  
  export interface ResearchDocument {
    id: string
    title: string
    type: DocumentType
    content: string  // Extracted text content
    originalUrl?: string
    fileSize: number
    pageCount?: number
    duration?: number  // For audio/video in seconds
    uploadedAt: string
    processedAt: string
    tags: string[]
    notebookId: string
  }
  
  export interface Notebook {
    id: string
    title: string
    description?: string
    documents: ResearchDocument[]
    mindMaps: MindMap[]
    flashcards: Flashcard[]
    quizzes: Quiz[]
    reports: Report[]
    audioOverviews: AudioOverview[]
    learningSessions: LearningSession[]
    sharedWith: string[]
    createdAt: string
    updatedAt: string
  }
  
  export interface MindMapNode {
    id: string
    content: string
    level: number
    parentId: string | null
    children: string[]
    position: { x: number; y: number }
    color: string
    notes?: string
    connections: Connection[]
  }
  
  export interface MindMap {
    id: string
    notebookId: string
    title: string
    layout: MindMapLayout
    nodes: MindMapNode[]
    centralNode: string
    createdAt: string
    updatedAt: string
  }
  
  export interface Flashcard {
    id: string
    notebookId: string
    front: string
    back: string
    difficulty: 'easy' | 'medium' | 'hard'
    nextReview: string
    reviewCount: number
    correctCount: number
    sourceDocumentId: string
    tags: string[]
  }
  
  export interface Quiz {
    id: string
    notebookId: string
    title: string
    questions: QuizQuestion[]
    difficulty: 'beginner' | 'intermediate' | 'advanced'
    timeLimit?: number
    sourceDocumentIds: string[]
  }
  
  export interface QuizQuestion {
    id: string
    question: string
    type: 'multiple-choice' | 'true-false' | 'short-answer' | 'essay'
    options?: string[]
    correctAnswer: string | number
    explanation?: string
  }
  
  export interface Report {
    id: string
    notebookId: string
    type: 'study-guide' | 'summary' | 'blog-post' | 'glossary' | 'analysis' | 'custom'
    title: string
    content: string
    format: 'markdown' | 'html'
    sourceDocumentIds: string[]
    generatedAt: string
  }
  
  export interface AudioOverview {
    id: string
    notebookId: string
    format: 'brief' | 'critique' | 'debate' | 'lecture'
    title: string
    audioUrl: string
    duration: number
    transcript: string
    generatedAt: string
  }
  ```

- [ ] **RES-000B**: Create Zod schemas in `src/schemas/researchSchema.ts`:
  - `ResearchDocumentSchema` with file validation
  - `NotebookSchema` with nested relationships
  - `MindMapNodeSchema` with position validation
  - `FlashcardSchema` with spaced repetition fields
  - `QuizSchema` with question validation
  - `ReportSchema` with content validation

- [ ] **RES-000C**: Create `src/mocks/factories/research.ts` with factories:
  - `createMockNotebook(overrides?)` — Generates notebook with varied documents
  - `createMockDocument(type, overrides?)` — Supports all document types
  - `createMockMindMap(layout, nodeCount)` — Interactive mind map structure
  - `createMockFlashcards(count, difficulty)` — Study cards with spaced repetition
  - `createMockQuiz(format, difficulty)` — Educational quizzes
  - `createMockAcademicNotebook()` — Pre-populated with research papers

- [ ] **RES-000D**: Create `src/mocks/handlers/research.ts` with MSW handlers:
  - `GET /api/research/notebooks` — List notebooks with metadata
  - `GET /api/research/notebooks/:id` — Full notebook with all content
  - `POST /api/research/notebooks` — Create new notebook
  - `PATCH /api/research/notebooks/:id` — Update notebook metadata
  - `POST /api/research/documents` — Upload and process documents
  - `POST /api/research/mindmaps` — Generate mind map from documents
  - `POST /api/research/flashcards` — Generate flashcards from content
  - `POST /api/research/quizzes` — Create quiz from documents
  - `POST /api/research/reports` — Generate custom report
  - `POST /api/research/audio-overviews` — Create audio overview
  - `POST /api/research/chat` — Learning Guide AI chat

- [ ] **RES-000E**: Create `src/queries/research.ts` with Query Key Factory:
  ```ts
  export const researchKeys = {
    all: ['research'] as const,
    notebooks: () => [...researchKeys.all, 'notebooks'] as const,
    notebook: (id: string) => [...researchKeys.all, 'notebook', id] as const,
    documents: (notebookId: string) => [...researchKeys.all, 'documents', notebookId] as const,
    mindmaps: (notebookId: string) => [...researchKeys.all, 'mindmaps', notebookId] as const,
    flashcards: (notebookId: string) => [...researchKeys.all, 'flashcards', notebookId] as const,
    quizzes: (notebookId: string) => [...researchKeys.all, 'quizzes', notebookId] as const,
    reports: (notebookId: string) => [...researchKeys.all, 'reports', notebookId] as const,
    audioOverviews: (notebookId: string) => [...researchKeys.all, 'audio', notebookId] as const,
  }
  ```

- [ ] **RES-000F**: Define query options and mutation hooks:
  - `notebooksQueryOptions()` — List with `staleTime: 60_000`
  - `notebookDetailQueryOptions(id)` — Full notebook with `staleTime: 30_000`
  - `useCreateNotebook()` — Optimistic create
  - `useUploadDocument()` — With progress tracking
  - `useGenerateMindMap()` — AI-powered generation
  - `useGenerateFlashcards()` — Batch generation
  - `useGenerateQuiz()` — Educational quiz creation
  - `useGenerateReport()` — Custom report generation
  - `useCreateAudioOverview()` — Multi-format audio generation

### Tests
- [ ] Factory produces valid notebooks with all content types
- [ ] MSW handlers simulate AI generation with realistic delays
- [ ] Query keys are structurally distinct per entity
- [ ] Mutations implement optimistic updates with rollback
- [ ] Document upload handles progress tracking correctly

### Definition of Done
- Complete domain model for research workspaces
- Mock factories for academic and general content
- MSW handlers for all AI generation endpoints
- Query key factory and mutation hooks with optimistic updates

### Anti-Patterns
- ❌ Storing raw document content in Zustand — use Dexie for large content
- ❌ Missing document type validation — causes processing errors
- ❌ Not supporting spaced repetition — reduces learning effectiveness
- ❌ Synchronous AI generation — blocks UI and feels slow

---

## 🔧 Task RES-001: Research State Management & Route Configuration

**Priority:** 🔴 High
**Est. Effort:** 1.5 hours
**Depends On:** FND-005 (Zustand), RES-000

### Related Files
`src/stores/slices/researchSlice.ts` · `src/pages/ResearchPage.tsx` · `src/router/routes.ts`

### Subtasks

- [ ] **RES-001A**: Create `src/stores/slices/researchSlice.ts`:
  ```ts
  interface ResearchSlice {
    // Active state
    activeNotebookId: string | null
    activeDocumentId: string | null
    activeView: 'workspace' | 'mindmap' | 'flashcards' | 'quiz' | 'reports'
    learningMode: LearningMode
    
    // UI state
    documentUploadOpen: boolean
    mindMapEditorOpen: boolean
    flashcardReviewerOpen: boolean
    quizTakerOpen: boolean
    reportGeneratorOpen: boolean
    audioPlayerOpen: boolean
    chatInterfaceOpen: boolean
    
    // Learning progress
    studyStreak: number
    lastStudyDate: string | null
    totalStudyTime: number  // in minutes
    masteredConcepts: Set<string>
    
    // AI interaction
    chatHistory: ChatMessage[]
    isProcessingAI: boolean
    activeAIFeature: 'mindmap' | 'flashcards' | 'quiz' | 'report' | 'audio' | null
    
    // Actions
    setActiveNotebook: (id: string | null) => void
    setActiveDocument: (id: string | null) => void
    setActiveView: (view: ResearchSlice['activeView']) => void
    setLearningMode: (mode: LearningMode) => void
    openDocumentUpload: () => void
    closeDocumentUpload: () => void
    openMindMapEditor: () => void
    closeMindMapEditor: () => void
    startAIFeature: (feature: NonNullable<ResearchSlice['activeAIFeature']>) => void
    stopAIFeature: () => void
    addChatMessage: (message: ChatMessage) => void
    updateStudyProgress: (session: StudySession) => void
  }
  ```

- [ ] **RES-001B**: Export atomic selectors:
  - `useActiveNotebook()`, `useActiveDocument()`, `useActiveView()`
  - `useLearningMode()`, `useStudyProgress()`, `useChatHistory()`
  - `useAIFeatureState()`

- [ ] **RES-001C**: Persist study progress to `localStorage`:
  - Store streak, last study date, total study time
  - Use `partialize` to exclude large content

- [ ] **RES-001D**: Configure `/research` route in `src/router/routes.ts`:
  ```ts
  {
    path: 'research',
    lazy: () => import('@/pages/ResearchPage'),
    loader: ({ context: { queryClient } }) => 
      queryClient.ensureQueryData(notebooksQueryOptions()),
  },
  {
    path: 'research/:notebookId',
    lazy: () => import('@/pages/ResearchPage'),
    loader: ({ params }) => 
      queryClient.ensureQueryData(notebookDetailQueryOptions(params.notebookId!)),
  }
  ```

### Tests
- [ ] State updates correctly for all actions
- [ ] Atomic selectors prevent unnecessary re-renders
- [ ] Study progress persists across page reloads
- [ ] Route loaders prefetch data correctly

### Definition of Done
- Complete research slice with learning state tracking
- Atomic selectors for performance optimization
- Study progress persistence
- Route configuration with data prefetching

### Anti-Patterns
- ❌ Storing large content in Zustand — use query cache
- ❌ Not tracking learning progress — misses gamification opportunities
- ❌ Missing atomic selectors — causes performance issues

---

## 📚 Task RES-002: Research Page Layout & Document Management

**Priority:** 🔴 High
**Est. Effort:** 2.5 hours
**Depends On:** FND-007 (Router), RES-001

### Related Files
`src/pages/ResearchPage.tsx` · `src/components/research/ResearchLayout.tsx` · `src/components/research/DocumentUpload.tsx` · `src/components/research/NotebookSidebar.tsx`

### Subtasks

- [ ] **RES-002A**: Create `src/pages/ResearchPage.tsx` with flexible layout:
  - Left sidebar (280px): Notebook navigation, document list, AI tools
  - Main content (flex-1): Active workspace with view switcher
  - Right panel (320px, collapsible): AI chat, learning progress, insights

- [ ] **RES-002B**: Build `NotebookSidebar` component:
  - Notebook list with cover images and progress indicators
  - Document list within active notebook
  - "New Notebook" and "Upload Document" buttons
  - Search across all notebooks and documents
  - Tags and filters for organization

- [ ] **RES-002C**: Implement `DocumentUpload` component:
  - Drag-and-drop zone for multiple file types
  - Progress indicators for large files
  - OCR for images and speech-to-text for audio/video
  - Automatic content extraction and categorization
  - Batch processing with queue management

- [ ] **RES-002D**: Build `DocumentViewer` component:
  - PDF viewer with annotation support
  - Audio/video player with transcript display
  - Image viewer with zoom and pan
  - Text editor for document editing
  - Unified navigation across document types

- [ ] **RES-002E**: Add view switcher in main content area:
  - Workspace: Document list + AI tools
  - Mind Map: Interactive knowledge visualization
  - Flashcards: Study card reviewer
  - Quiz: Quiz taking interface
  - Reports: Generated reports browser
  - Active state with `layoutId` animation

- [ ] **RES-002F**: Implement document organization:
  - Drag-and-drop to reorder documents
  - Tag assignment and management
  - Document linking and references
  - Bulk operations (delete, move, tag)

### Tests
- [ ] Layout adapts correctly to different screen sizes
- [ ] Document upload handles all supported formats
- [ ] View switcher transitions smoothly
- [ ] Document viewer displays content correctly
- [ ] Sidebar navigation works with keyboard

### Definition of Done
- Responsive three-column layout for research workspace
- Multi-format document upload with processing
- Unified document viewer for all content types
- Smooth view transitions with proper state management

### Anti-Patterns
- ❌ Fixed layout without responsiveness — breaks on mobile
- ❌ Not supporting multiple document formats — limits utility
- ❌ Missing keyboard navigation — accessibility failure

---

## 🤖 Task RES-003: AI-Powered Document Analysis & Summaries

**Priority:** 🔴 High
**Est. Effort:** 3 hours
**Depends On:** RES-002, RES-000

### Related Files
`src/components/research/DocumentAnalyzer.tsx` · `src/components/research/AISummary.tsx` · `src/services/researchAI.ts` · `src/hooks/useDocumentAnalysis.ts`

### Subtasks

- [ ] **RES-003A**: Create `src/services/researchAI.ts`:
  ```ts
  interface ResearchAIService {
    analyzeDocument(documentId: string): Promise<DocumentAnalysis>
    generateSummary(documentIds: string[], format: 'brief' | 'detailed' | 'key-points'): Promise<string>
    extractKeyConcepts(documentIds: string[]): Promise<Concept[]>
    generateQuestions(documentIds: string[], count: number): Promise<QuizQuestion[]>
    findConnections(documentIds: string[]): Promise<Connection[]>
  }
  ```

- [ ] **RES-003B**: Build `DocumentAnalyzer` component:
  - Shows document metadata and processing status
  - AI analysis results with key concepts and themes
  - Automatic tagging suggestions
  - Reading difficulty assessment
  - Content quality indicators

- [ ] **RES-003C**: Implement `AISummary` component:
  - Multiple summary formats (brief, detailed, key points)
  - Citations back to source documents
  - Export to markdown or copy to clipboard
  - Regenerate with different focus areas
  - Real-time generation with streaming display

- [ ] **RES-003D**: Create `useDocumentAnalysis()` hook:
  - Triggers AI analysis on document upload
  - Shows progress and status indicators
  - Caches analysis results for performance
  - Handles large document processing

- [ ] **RES-003E**: Implement concept extraction:
  - Automatic identification of key terms and concepts
  - Concept relationships and hierarchies
  - Visual concept cloud display
  - Click-to-explore concept details

- [ ] **RES-003F**: Add content quality analysis:
  - Reading level assessment (Flesch-Kincaid)
  - Information density scoring
  - Source credibility indicators
  - Fact-checking suggestions

### Tests
- [ ] Document analysis completes with realistic results
- [ ] Summary generation cites sources correctly
- [ ] Concept extraction identifies relevant terms
- [ ] Quality analysis provides useful metrics
- [ ] Large documents process without timeout

### Definition of Done
- AI-powered document analysis with multiple insights
- Flexible summary generation with citations
- Concept extraction and relationship mapping
- Content quality assessment tools

### Anti-Patterns
- ❌ Blocking UI during AI processing — use streaming
- ❌ Not citing sources — reduces credibility
- ❌ Missing error handling for AI failures — poor UX

---


## 🗂️ Task RES-004: Interactive Mind Maps & Visual Knowledge Graphs

**Priority:** 🔴 High
**Est. Effort:** 3.5 hours
**Depends On:** RES-003, RES-000

### Related Files
`src/components/research/MindMapEditor.tsx` · `src/components/research/MindMapNode.tsx` · `src/components/research/KnowledgeGraph.tsx` · `src/hooks/useMindMap.ts`

### Subtasks

- [ ] **RES-004A**: Build `MindMapEditor` component:
  - Interactive canvas with zoom and pan controls
  - Drag-and-drop node positioning
  - Multiple layout algorithms (force-directed, hierarchical, circular)
  - Real-time collaboration indicators
  - Export to multiple formats (PNG, SVG, PDF)

- [ ] **RES-004B**: Implement `MindMapNode` component:
  - Editable content with inline editing
  - Color coding by concept type or importance
  - Expand/collapse for child nodes
  - Connection lines with relationship labels
  - Hover tooltips with additional information

- [ ] **RES-004C**: Create `KnowledgeGraph` visualization:
  - 3D-like network visualization of concepts
  - Second-order connections between distant concepts
  - Interactive filtering by concept type
  - Path-finding between related concepts
  - Animated relationship strength indicators

- [ ] **RES-004D**: Implement mind map generation:
  - AI-powered automatic layout from documents
  - Concept hierarchy detection
  - Relationship strength calculation
  - Multiple layout options (mind map, concept map, tree)
  - Manual refinement tools

- [ ] **RES-004E**: Add advanced editing features:
  - Node styling (color, shape, size)
  - Connection styling (line type, arrows, labels)
  - Grouping and clustering of nodes
  - Templates for common structures
  - Undo/redo with full history

- [ ] **RES-004F**: Implement `useMindMap()` hook:
  - Real-time collaboration support
  - Auto-save with conflict resolution
  - Version history and branching
  - Performance optimization for large maps

### Tests
- [ ] Mind map renders correctly with sample data
- [ ] Node editing updates content immediately
- [ ] Layout algorithms produce logical arrangements
- [ ] Knowledge graph shows concept relationships
- [ ] Large mind maps perform smoothly
- [ ] Collaboration features work correctly

### Definition of Done
- Fully interactive mind map editor with multiple layouts
- AI-powered generation from documents
- Knowledge graph visualization with concept relationships
- Advanced editing and styling capabilities
- Real-time collaboration support

### Anti-Patterns
- ❌ Static mind maps without editing — limits usefulness
- ❌ Poor performance with large maps — frustrating UX
- ❌ Missing collaboration features — reduces educational value

---

## 📇 Task RES-005: Flashcard & Quiz Generation System

**Priority:** 🟠 Medium
**Est. Effort:** 3 hours
**Depends On:** RES-003, RES-000

### Related Files
`src/components/research/FlashcardDeck.tsx` · `src/components/research/FlashcardReviewer.tsx` · `src/components/research/QuizTaker.tsx` · `src/hooks/useSpacedRepetition.ts`

### Subtasks

- [ ] **RES-005A**: Build `FlashcardDeck` component:
  - Grid display of flashcards with previews
  - Search and filter by tags, difficulty, source
  - Bulk operations (edit, delete, export)
  - Progress indicators for mastery levels
  - Sort options (newest, difficulty, last reviewed)

- [ ] **RES-005B**: Implement `FlashcardReviewer` with spaced repetition:
  - Card flip animation with 3D effect
  - Difficulty rating (easy, medium, hard, again)
  - Automatic scheduling based on performance
  - Study session progress tracking
  - Keyboard shortcuts for efficient reviewing

- [ ] **RES-005C**: Create `useSpacedRepetition()` hook:
  - Implements SM-2 algorithm for optimal scheduling
  - Tracks review history and performance
  - Calculates next review dates
  - Adapts difficulty based on user performance
  - Provides study statistics and insights

- [ ] **RES-005D**: Build `QuizTaker` component:
  - Multiple question types (multiple choice, true/false, short answer)
  - Timer and progress indicators
  - Immediate feedback with explanations
  - Score calculation and performance analysis
  - Question review mode for incorrect answers

- [ ] **RES-005E**: Implement quiz generation:
  - AI-powered question creation from documents
  - Difficulty adjustment based on user level
  - Question variety and format options
  - Automatic answer key generation
  - Custom quiz creation tools

- [ ] **RES-005F**: Add study analytics:
  - Learning curve visualization
  - Concept mastery tracking
  - Study time analytics
  - Performance trends over time
  - Personalized study recommendations

### Tests
- [ ] Flashcard reviewer implements spaced repetition correctly
- [ ] Quiz taker handles all question types
- [ ] Study analytics provide meaningful insights
- [ ] AI generation creates quality content
- [ ] Performance is smooth with large decks

### Definition of Done
- Complete flashcard system with spaced repetition
- Interactive quiz taking with immediate feedback
- AI-powered content generation
- Study analytics and progress tracking
- Keyboard shortcuts and accessibility support

### Anti-Patterns
- ❌ Missing spaced repetition — reduces learning effectiveness
- ❌ No immediate feedback — hinders learning
- ❌ Not tracking progress — misses motivation opportunities

---

## 🎓 Task RES-006: Learning Guide with Personalized Tutoring

**Priority:** 🟠 Medium
**Est. Effort:** 2.5 hours
**Depends On:** RES-003, RES-000

### Related Files
`src/components/research/LearningGuide.tsx` · `src/components/research/TutoringChat.tsx` · `src/services/learningGuide.ts` · `src/hooks/useLearningGuide.ts`

### Subtasks

- [ ] **RES-006A**: Create `src/services/learningGuide.ts`:
  ```ts
  interface LearningGuideService {
    startTutoringSession(notebookId: string): Promise<TutoringSession>
    askQuestion(sessionId: string, question: string): Promise<TutoringResponse>
    generateExplanation(concept: string, level: 'beginner' | 'intermediate' | 'advanced'): Promise<string>
    suggestNextSteps(sessionId: string, progress: LearningProgress): Promise<NextStep[]>
  }
  ```

- [ ] **RES-006B**: Build `LearningGuide` component:
  - AI tutor avatar and personality
  - Conversation history with context
  - Adaptive difficulty adjustment
  - Progress tracking and recommendations
  - Break reminders and study tips

- [ ] **RES-006C**: Implement `TutoringChat` interface:
  - Natural language conversation with AI tutor
  - Context-aware responses based on documents
  - Step-by-step problem solving guidance
  - Socratic questioning techniques
  - Real-time streaming responses

- [ ] **RES-006D**: Create adaptive learning features:
  - Personalized learning paths based on performance
  - Concept difficulty assessment
  - Learning style adaptation (visual, auditory, kinesthetic)
  - Progress-based content recommendations
  - Motivational feedback and encouragement

- [ ] **RES-006E**: Add tutoring modes:
  - Study Guide: Walks through document content
  - Q&A Session: Answers questions about material
  - Problem Solving: Helps work through exercises
  - Review Mode: Reinforces learned concepts
  - Exploration: Encourages curiosity and discovery

- [ ] **RES-006F**: Implement `useLearningGuide()` hook:
  - Session management and persistence
  - Context tracking across conversations
  - Performance analytics and improvement
  - Integration with other learning tools

### Tests
- [ ] Learning Guide provides helpful, accurate responses
- [ ] Adaptive difficulty adjusts appropriately
- [ ] Conversation context is maintained
- [ ] Different tutoring modes work correctly
- [ ] Integration with other tools is seamless

### Definition of Done
- AI-powered learning guide with personalized tutoring
- Multiple tutoring modes for different learning needs
- Adaptive difficulty and learning paths
- Natural conversation interface with context awareness
- Comprehensive progress tracking and analytics

### Anti-Patterns
- ❌ Generic, non-personalized responses — reduces effectiveness
- ❌ Missing context awareness — confusing user experience
- ❌ No adaptation to learning level — inappropriate difficulty

---

## 🎧 Task RES-007: Audio Overviews with Multiple Formats

**Priority:** 🟠 Medium
**Est. Effort:** 2 hours
**Depends On:** RES-003, RES-000

### Related Files
`src/components/research/AudioOverview.tsx` · `src/components/research/AudioPlayer.tsx` · `src/services/audioGeneration.ts` · `src/hooks/useAudioOverview.ts`

### Subtasks

- [ ] **RES-007A**: Create `src/services/audioGeneration.ts`:
  ```ts
  interface AudioGenerationService {
    generateAudioOverview(notebookId: string, format: AudioFormat): Promise<AudioOverview>
    generateTextToSpeech(content: string, voice: VoiceSettings): Promise<string>
    processAudioFile(audioBlob: Blob): Promise<Transcript>
    generatePodcastStyle(content: string): Promise<AudioOverview>
  }
  ```

- [ ] **RES-007B**: Build `AudioOverview` component:
  - Format selection (Brief, Critique, Debate, Lecture)
  - Audio player with waveform visualization
  - Transcript display with highlighting
  - Download and sharing options
  - Playback speed controls

- [ ] **RES-007C**: Implement multiple audio formats:
  - **Brief**: Single AI host summarizes key points
  - **Critique**: Two AI hosts review and provide feedback
  - **Debate**: Two AI hosts discuss different perspectives
  - **Lecture**: Educational presentation style
  - **Podcast**: Conversational discussion format

- [ ] **RES-007D**: Create `AudioPlayer` with advanced features:
  - Waveform visualization with progress
  - Chapter/section navigation
  - Playback speed adjustment (0.5x - 2x)
  - Bookmarking and note-taking
  - Sleep timer and continuous play

- [ ] **RES-007E**: Add transcript features:
  - Real-time transcript highlighting
  - Search within transcript
  - Click-to-jump to audio position
  - Export transcript to text
  - Translation support for multiple languages

- [ ] **RES-007F**: Implement `useAudioOverview()` hook:
  - Audio generation progress tracking
  - Caching of generated audio
  - Background processing for long content
  - Error handling and retry logic

### Tests
- [ ] Audio generation works for all formats
- [ ] Audio player controls function correctly
- [ ] Transcript synchronization is accurate
- [ ] Background processing handles large content
- [ ] Error scenarios are handled gracefully

### Definition of Done
- Multi-format audio overview generation
- Advanced audio player with visualization
- Synchronized transcript display
- Multiple audio formats for different learning styles
- Robust background processing and caching

### Anti-Patterns
- ❌ Single audio format — limits learning preference options
- ❌ Missing transcript synchronization — reduces accessibility
- ❌ Blocking UI during generation — poor user experience

---

## 📝 Task RES-008: Report Generation with Custom Formats

**Priority:** 🟠 Medium
**Est. Effort:** 2 hours
**Depends On:** RES-003, RES-000

### Related Files
`src/components/research/ReportGenerator.tsx` · `src/components/research/ReportViewer.tsx` · `src/services/reportGeneration.ts` · `src/hooks/useReportGeneration.ts`

### Subtasks

- [ ] **RES-008A**: Create `src/services/reportGeneration.ts`:
  ```ts
  interface ReportGenerationService {
    generateReport(notebookId: string, type: ReportType, options: ReportOptions): Promise<Report>
    generateCustomReport(template: ReportTemplate, content: string): Promise<Report>
    suggestReportTypes(notebookId: string): Promise<ReportType[]>
    exportReport(reportId: string, format: ExportFormat): Promise<Blob>
  }
  ```

- [ ] **RES-008B**: Build `ReportGenerator` component:
  - Report type selection with descriptions
  - Custom template builder
  - Content focus areas selection
  - Format and style options
  - Preview and generation controls

- [ ] **RES-008C**: Implement built-in report types:
  - **Study Guide**: Comprehensive learning summary
  - **Executive Summary**: Key points for quick review
  - **Blog Post**: Engaging article format
  - **Glossary**: Key terms and definitions
  - **Analysis**: Deep dive into specific topics
  - **Presentation**: Slide deck format

- [ ] **RES-008D**: Create `ReportViewer` component:
  - Rich text display with formatting
  - Interactive table of contents
  - Citation popups for sources
  - Export options (PDF, Word, Markdown)
  - Print-friendly layout

- [ ] **RES-008E**: Add custom report builder:
  - Drag-and-drop section arrangement
  - Custom templates with variables
  - Branding and style customization
  - Save and reuse templates
  - Template sharing with others

- [ ] **RES-008F**: Implement `useReportGeneration()` hook:
  - Real-time generation with streaming
  - Template management
  - Generation history and versions
  - Performance optimization for large reports

### Tests
- [ ] All report types generate correctly
- [ ] Custom templates work as expected
- [ ] Report viewer displays content properly
- [ ] Export functions produce correct formats
- [ ] Large reports generate without timeout

### Definition of Done
- Multiple report formats for different needs
- Custom report builder with templates
- Rich report viewer with interactivity
- Export capabilities in multiple formats
- Template management and sharing

### Anti-Patterns
- ❌ Limited report formats — reduces utility
- ❌ Missing customization options — limits flexibility
- ❌ Poor export quality — unprofessional results

---

## 🔗 Task RES-009: Cross-Module Integration & Search

**Priority:** 🟠 Medium
**Est. Effort:** 2 hours
**Depends On:** RES-001, other modules

### Related Files
`src/components/research/ResearchSearch.tsx` · `src/hooks/useResearchIntegration.ts` · `src/integrations/budgetIntegration.ts` · `src/integrations/projectsIntegration.ts`

### Subtasks

- [ ] **RES-009A**: Build unified search across all modules:
  - Search documents from Research, Budget, Projects
  - Filter by content type, date, tags
  - Semantic search with concept matching
  - Search history and saved searches
  - Advanced search operators

- [ ] **RES-009B**: Implement Budget module integration:
  - Import financial documents for research
  - Create research reports from budget data
  - Link research findings to budget categories
  - Generate insights from financial patterns

- [ ] **RES-009C**: Add Projects module integration:
  - Research project documentation and references
  - Generate project reports and summaries
  - Link research concepts to project tasks
  - Create learning materials for project teams

- [ ] **RES-009D**: Implement content sharing:
  - Export research to other modules
  - Import documents from other modules
  - Cross-reference content between modules
  - Unified tagging system

- [ ] **RES-009E**: Create `useResearchIntegration()` hook:
  - Manages cross-module data flow
  - Handles content synchronization
  - Provides unified search interface
  - Tracks content relationships

### Tests
- [ ] Unified search returns relevant results from all modules
- [ ] Budget integration works correctly
- [ ] Projects integration functions properly
- [ ] Content sharing maintains data integrity
- [ ] Cross-references are accurate and up-to-date

### Definition of Done
- Unified search across all application modules
- Seamless integration with Budget and Projects
- Content sharing and cross-referencing
- Unified tagging and organization system

### Anti-Patterns
- ❌ Siloed search within Research module only
- ❌ Missing integration with other modules
- ❌ Inconsistent data across modules

---

## 👥 Task RES-010: Collaboration & Sharing Features

**Priority:** 🟢 Low
**Est. Effort:** 2 hours
**Depends On:** RES-006, RES-000

### Related Files
`src/components/research/CollaborationPanel.tsx` · `src/components/research/ShareDialog.tsx` · `src/hooks/useResearchCollaboration.ts`

### Subtasks

- [ ] **RES-010A**: Build `CollaborationPanel` component:
  - Active collaborators list with avatars
  - Real-time presence indicators
  - Activity feed showing changes
  - Comment and annotation tools
  - Version history viewer

- [ ] **RES-010B**: Implement `ShareDialog` component:
  - Share link generation with permissions
  - Permission levels (view, comment, edit)
  - Password protection option
  - Expiration date settings
  - Email invitation system

- [ ] **RES-010C**: Create collaboration features:
  - Real-time co-editing for mind maps
  - Shared flashcard decks
  - Collaborative quiz creation
  - Group study sessions
  - Peer review system

- [ ] **RES-010D**: Add study group features:
  - Create and join study groups
  - Group notebooks and materials
  - Group chat and discussion
  - Shared progress tracking
  - Group challenges and competitions

- [ ] **RES-010E**: Implement `useResearchCollaboration()` hook:
  - Real-time collaboration management
  - Permission system enforcement
  - Activity tracking and notifications
  - Conflict resolution for edits

### Tests
- [ ] Real-time collaboration works smoothly
- [ ] Permission system is secure and functional
- [ ] Share links work with correct access levels
- [ ] Study group features function properly
- [ ] Activity tracking is accurate

### Definition of Done
- Real-time collaboration tools
- Flexible sharing with permissions
- Study group management features
- Activity tracking and notifications
- Secure permission system

### Anti-Patterns
- ❌ Missing permission controls — security risk
- ❌ No real-time collaboration — limits usefulness
- ❌ Complex sharing process — reduces adoption

---

## 🧪 Task RES-011: Comprehensive Testing & Quality Gates

**Priority:** 🔴 High
**Est. Effort:** 3 hours
**Depends On:** All RES tasks

### Related Files
`src/tests/research/*.test.tsx` · `vitest.config.ts` · `src/tests/research/accessibility.test.tsx`

### Subtasks

- [ ] **RES-011A**: Unit tests for core functionality:
  - Document processing and analysis
  - Mind map generation and editing
  - Flashcard spaced repetition algorithm
  - Quiz generation and scoring
  - Report generation templates

- [ ] **RES-011B**: Component tests for UI elements:
  - Research page layout and navigation
  - Document upload and viewer
  - Mind map editor interactions
  - Flashcard reviewer behavior
  - Audio player functionality

- [ ] **RES-011C**: Integration tests for workflows:
  - End-to-end document processing
  - AI feature integration
  - Cross-module data flow
  - Collaboration scenarios
  - Offline/online synchronization

- [ ] **RES-011D**: Accessibility testing:
  - WCAG 2.2 AA compliance verification
  - Keyboard navigation testing
  - Screen reader compatibility
  - Color contrast validation
  - Motion preference respect

- [ ] **RES-011E**: Performance testing:
  - Large document processing performance
  - Mind map rendering with many nodes
  - Audio generation speed
  - Memory usage optimization
  - Bundle size analysis

- [ ] **RES-011F**: User acceptance testing:
  - Learning effectiveness validation
  - User interface usability testing
  - Feature completeness verification
  - Error handling robustness
  - Cross-browser compatibility

### Tests
- [ ] All unit tests pass with >90% coverage
- [ ] Component tests cover all user interactions
- [ ] Integration tests validate complete workflows
- [ ] Accessibility tests meet WCAG 2.2 AA standards
- [ ] Performance meets Core Web Vitals targets

### Definition of Done
- Comprehensive test suite with high coverage
- Accessibility compliance verified
- Performance targets met
- User acceptance validated
- Quality gates established for ongoing development

### Anti-Patterns
- ❌ Missing accessibility testing — excludes users
- ❌ No performance testing — poor user experience
- ❌ Incomplete test coverage — hidden bugs

---

## 📊 Dependency Graph

```
RES-000 (Domain Model & Mock Data)
     │
RES-001 (State Management & Route)
     │
     ├── RES-002 (Page Layout & Document Management)
     │
     ├── RES-003 (AI Document Analysis)
     │
     ├── RES-004 (Mind Maps & Knowledge Graphs)
     │
     ├── RES-005 (Flashcards & Quizzes)
     │
     ├── RES-006 (Learning Guide)
     │
     ├── RES-007 (Audio Overviews)
     │
     ├── RES-008 (Report Generation)
     │
     ├── RES-009 (Cross-Module Integration)
     │
     ├── RES-010 (Collaboration & Sharing)
     │
     └── RES-011 (Testing & Quality Gates)
```

---

## ✅ Module Completion Checklist

**Core Functionality:**
- [ ] Notebook creation and management
- [ ] Multi-format document upload and processing
- [ ] AI-powered document analysis and summarization
- [ ] Interactive mind map generation and editing
- [ ] Flashcard system with spaced repetition
- [ ] Quiz generation and taking
- [ ] Learning Guide with personalized tutoring
- [ ] Audio overview generation in multiple formats
- [ ] Custom report generation
- [ ] Cross-module integration and unified search

**AI Features:**
- [ ] Document analysis and concept extraction
- [ ] Automatic mind map generation
- [ ] Personalized learning recommendations
- [ ] Adaptive difficulty adjustment
- [ ] Natural language tutoring interface
- [ ] Multi-format audio generation
- [ ] Intelligent report creation

**Learning Tools:**
- [ ] Spaced repetition algorithm implementation
- [ ] Progress tracking and analytics
- [ ] Study session management
- [ ] Performance insights and recommendations
- [ ] Mastery level assessment
- [ ] Learning streak gamification

**Collaboration:**
- [ ] Real-time co-editing
- [ ] Shareable notebooks with permissions
- [ ] Study group management
- [ ] Activity tracking and notifications
- [ ] Peer review system

**Quality:**
- [ ] All tests passing with high coverage
- [ ] WCAG 2.2 AA accessibility compliance
- [ ] Performance meeting Core Web Vitals
- [ ] Cross-browser compatibility
- [ ] User acceptance validated

---

## 🎯 Success Metrics

**Engagement Metrics:**
- Daily active users in Research module
- Average session duration
- Document upload and processing volume
- AI feature utilization rates

**Learning Effectiveness:**
- Quiz completion rates and scores
- Flashcard mastery progression
- Concept retention measurements
- Learning streak consistency

**Technical Performance:**
- Document processing speed (<30 seconds for typical documents)
- Mind map rendering performance (smooth with 100+ nodes)
- Audio generation time (<2 minutes for standard content)
- Search response time (<500ms)

**User Satisfaction:**
- Net Promoter Score for Research module
- Feature satisfaction ratings
- Ease of use scores
- Learning effectiveness feedback
