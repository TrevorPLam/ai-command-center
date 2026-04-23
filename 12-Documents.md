# 11-Documents — Personal AI Command Center Frontend (Enhanced v1)

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.  
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.

---

## 🔬 Research Findings — Documents Module

| Finding | Source | Action Required |
|---------|--------|-----------------|
| **Obsidian's core value is bidirectional linking** — Users create knowledge networks by linking notes with `[[double brackets]]`. This creates a graph view that visualizes connections. | Obsidian UX Research 2025 | DOC-003: Implement bidirectional linking with auto-backlink discovery and graph visualization. |
| **OCR is essential for paper digitization** — Leading apps like Evernote, Notion, and Apple Notes use OCR to make scanned documents searchable. Tesseract.js is the standard browser OCR library. | Document Management Apps 2026 | DOC-004: Implement OCR processing pipeline using Tesseract.js with progress indicators. |
| **Semantic search enables intelligent discovery** — Vector embeddings allow finding documents by meaning, not just keywords. OpenAI embeddings + cosine similarity is the standard approach. | AI-Powered Search 2026 | DOC-005: Implement semantic search using vector embeddings and similarity scoring. |
| **Document extraction structures unstructured content** — AI can extract entities, topics, and summaries from documents. This enables automatic tagging and organization. | Document Intelligence 2026 | DOC-006: Implement AI-powered extraction for entities, topics, and summaries. |
| **Q&A over documents is a premium feature** — Users expect to ask questions about their document collection and get precise answers with citations. | RAG Systems 2026 | DOC-007: Implement question-answering with retrieval-augmented generation and source citations. |
| **Real-time collaboration is expected** — Multiple users editing documents simultaneously with live cursors and conflict resolution. | Collaborative Editing 2026 | DOC-008: Implement real-time collaboration with operational transforms. |
| **Version history is non-negotiable** — Users need to track changes, revert to previous versions, and see who made what changes. | Document Versioning 2026 | DOC-009: Implement document versioning with diff visualization. |
| **Offline-first is essential** — Documents must be accessible and editable without internet, with sync when reconnected. | PWA Document Apps 2026 | DOC-010: Implement offline storage with IndexedDB and sync queue. |
| **Rich content beyond text** — Images, PDFs, videos, and embedded content are standard expectations. | Rich Document Editors 2026 | DOC-011: Support multiple content types with inline previews. |
| **Template system accelerates creation** — Pre-built templates for meeting notes, project docs, research papers reduce blank-page anxiety. | Template UX Research 2026 | DOC-002: Create template library with 10+ document templates. |
| **Markdown is the lingua franca** — Most knowledge workers prefer Markdown for its simplicity and portability. | Markdown Editors 2026 | DOC-003: Use Markdown as primary format with rich preview. |
| **Tag-based organization scales** — Hierarchical folders break down; tags with auto-suggestion and faceted search scale better. | Information Architecture 2026 | DOC-005: Implement tag system with auto-suggestion and faceted search. |
| **Split view enhances productivity** - Viewing source and preview side-by-side, or multiple documents simultaneously, is a power-user feature. | Advanced Editors 2026 | DOC-012: Implement split view layouts. |

---

## 🧱 Cross-Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **DOC-C01** | State Management | Zustand `documentsSlice` for active document, view mode, search, and collaboration state. URL sync for shareable document links. |
| **DOC-C02** | Data Persistence | Centralized CommandCenterDB with module-prefixed stores (`documents_documents`, `documents_syncQueue`, `documents_embeddings`) for offline document storage; sync queue for pending mutations. Vector embeddings stored in IndexedDB for semantic search. |
| **DOC-C03** | Content Types | Unified content model supporting: Markdown, PDF, images, videos, audio recordings, and embedded content. |
| **DOC-C04** | Linking System | Bidirectional linking with `[[wikilink]]` syntax; auto-backlink discovery; graph visualization. |
| **DOC-C05** | Search Architecture | Hybrid search: full-text + semantic (vector embeddings) + metadata filters. Results ranked by relevance score. |
| **DOC-C06** | OCR Pipeline | Tesseract.js integration for image/PDF text extraction; progress indicators; error handling. |
| **DOC-C07** | AI Integration | OpenAI-compatible API for embeddings, extraction, and Q&A. Cost tracking and rate limiting. |
| **DOC-C08** | Collaboration | Yjs CRDT-based collaboration with y-indexeddb for offline persistence; automatic conflict resolution; presence indicators via awareness API. |
| **DOC-C09** | Version Control | Immutable document versions; diff visualization; rollback capability. |
| **DOC-C10** | Templates | 10+ built-in templates (Meeting Notes, Project Brief, Research Paper, etc.); custom template builder. |
| **DOC-C11** | View Modes | Edit mode (Markdown), Preview mode (rendered), Split view, Graph view, Timeline view. |
| **DOC-C12** | Accessibility | WCAG 2.2 AA: keyboard navigation, screen reader support for document content, focus management. |
| **DOC-C13** | Motion | Alive tier for document transitions, link creation, collaboration cursors; Quiet tier for search results. |

### 🎯 Motion Tier Assignment

| Component | Tier | Allowed Techniques |
|-----------|------|--------------------|
| Document open/close | **Alive** | `scale: 0.95→1`, `opacity: 0→1`, spring `stiffness: 300, damping: 30` |
| Link creation | **Alive** | Brief glow effect on linked text; graph node entrance |
| OCR processing | **Quiet** | Progress bar with smooth width transition |
| Search results | **Static** | Instant render; no animation during typing |
| Collaboration cursor | **Alive** | Smooth position interpolation; subtle pulse |
| Version diff | **Quiet** | Slide transition between versions |
| Template selection | **Quiet** | `scale: 0.98→1` on hover |
| Graph view navigation | **Alive** | Spring physics for node positioning |
| Split view resize | **Quiet** | Resize handle with live preview |

---

## 🗃️ Task DOC-000: Documents Domain Model & Mock Data

**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** FND-004 (Testing), FND-006 (TanStack Query)

### Related Files

`src/domain/documents/types.ts` · `src/schemas/documentSchema.ts` · `src/mocks/factories/documents.ts` · `src/mocks/handlers/documents.ts` · `src/queries/documents.ts`

### Subtasks

- [ ] **DOC-000A**: Define core domain types in `src/domain/documents/types.ts`:

  ```ts
  export type DocumentType = 'markdown' | 'pdf' | 'image' | 'audio' | 'video' | 'embedded'
  export type DocumentStatus = 'draft' | 'published' | 'archived'
  
  export interface Document {
    id: string
    title: string
    type: DocumentType
    status: DocumentStatus
    content: string // Markdown content or extracted text
    rawContent?: string // Original file content for binary types
    embeddings?: number[] // Vector embedding for semantic search
    metadata: DocumentMetadata
    links: DocumentLink[]
    backlinks: DocumentLink[]
    tags: string[]
    version: number
    createdAt: string
    updatedAt: string
    createdBy: string
    updatedBy: string
    templateId?: string
  }
  
  export interface DocumentMetadata {
    wordCount?: number
    readingTimeMinutes?: number
    extractedEntities?: Entity[]
    extractedTopics?: Topic[]
    summary?: string
    ocrText?: string // For scanned documents
    language?: string
    lastSyncAt?: string
  }
  
  export interface DocumentLink {
    id: string
    sourceId: string
    targetId: string
    linkText: string
    type: 'wikilink' | 'external' | 'attachment'
    position: { start: number; end: number }
  }
  
  export interface Entity {
    text: string
    type: 'person' | 'organization' | 'location' | 'date' | 'concept'
    confidence: number
    position: { start: number; end: number }
  }
  
  export interface Topic {
    name: string
    confidence: number
    keywords: string[]
  }
  ```

- [ ] **DOC-000B**: Create Zod schemas in `src/schemas/documentSchema.ts`:
  - `DocumentSchema` with validation for all fields
  - `DocumentMetadataSchema` with optional fields
  - `DocumentLinkSchema` with position validation
  - `EntitySchema` and `TopicSchema` for AI extraction results

- [ ] **DOC-000C**: Create `src/mocks/factories/documents.ts` with factories:
  - `createMockDocument(type, overrides?)` — Generates realistic documents
  - `createMockMarkdownDocument(overrides?)` — Markdown with links and tags
  - `createMockPDFDocument(overrides?)` — PDF with OCR text
  - `createMockMeetingNotes()` — Pre-populated meeting notes template
  - `createMockProjectBrief()` — Project brief with sections and links
  - `createMockResearchPaper()` — Academic paper with citations

- [ ] **DOC-000D**: Create `src/mocks/handlers/documents.ts` with MSW handlers:
  - `GET /api/documents` — Paginated document list with filters
  - `GET /api/documents/:id` — Full document with content and metadata
  - `POST /api/documents` — Create new document (supports templateId)
  - `PATCH /api/documents/:id` — Update document content/metadata
  - `DELETE /api/documents/:id` — Soft delete (sets status: 'archived')
  - `POST /api/documents/:id/ocr` — Process OCR for uploaded images/PDFs
  - `POST /api/documents/search` — Hybrid search (text + semantic)
  - `POST /api/documents/embeddings` — Generate embeddings for document
  - `POST /api/documents/extract` — AI extraction of entities/topics
  - `POST /api/documents/qa` — Question-answering over documents
  - `GET /api/documents/:id/versions` — Document version history
  - `GET /api/documents/graph` — Link graph data for visualization

- [ ] **DOC-000E**: Create `src/queries/documents.ts` with Query Key Factory:
  ```ts
  export const documentKeys = {
    all: ['documents'] as const,
    documents: (filters: DocumentFilters) => [...documentKeys.all, 'list', filters] as const,
    document: (id: string) => [...documentKeys.all, 'detail', id] as const,
    search: (query: string, filters: DocumentFilters) => [...documentKeys.all, 'search', query, filters] as const,
    graph: () => [...documentKeys.all, 'graph'] as const,
    templates: () => [...documentKeys.all, 'templates'] as const,
    versions: (id: string) => [...documentKeys.document(id), 'versions'] as const,
  }
  ```

- [ ] **DOC-000F**: Define query options and mutation hooks:
  - `documentsQueryOptions(filters)` — Overview with `staleTime: 60_000`
  - `documentDetailQueryOptions(id)` — Full document with `staleTime: 30_000`
  - `useCreateDocument()` — Optimistic create with template support
  - `useUpdateDocument()` — Optimistic update with version increment
  - `useDeleteDocument()` — Optimistic archive
  - `useSearchDocuments()` — Hybrid search with debouncing
  - `useProcessOCR()` — OCR processing with progress tracking
  - `useGenerateEmbeddings()` — Vector embedding generation
  - `useExtractContent()` — AI extraction with optimistic updates
  - `useQuestionAnswer()` — Q&A with source citations
  - **Critical**: All mutations MUST use the shared `useOptimisticMutation()` wrapper from `src/lib/useOptimisticMutation.ts` (see FND-006H in 01-Foundations.md). This wrapper enforces the canonical pattern: `cancelQueries → snapshot → setQueryData → rollback → onSettled invalidate`. Do not implement inline optimistic patterns.

### Tests

- [ ] Factory produces valid documents with all metadata fields
- [ ] MSW handlers maintain in-memory state; mutations persist within session
- [ ] `useSearchDocuments` returns relevant results with proper ranking
- [ ] OCR processing mock returns realistic extracted text
- [ ] Embedding generation mock returns vector arrays
- [ ] Query keys are structurally distinct per entity

### Definition of Done

- Full domain model with document types, metadata, and linking
- Mock factories for common document types (meeting notes, project briefs, research papers)
- MSW handlers for all CRUD operations and AI features
- Query key factory and mutation hooks with optimistic updates

### Anti-Patterns
- ❌ Storing binary content directly in document model — use separate storage
- ❌ Not validating link positions — may cause invalid backlink detection
- ❌ Missing version tracking — prevents proper change history
- ❌ Not handling OCR errors gracefully — user needs feedback
- ❌ Skipping `cancelQueries` in `onMutate` — creates race conditions when a background refetch overwrites the optimistic state

---

## 🔧 Task DOC-001: Documents State Management & Templates
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** FND-005 (Zustand), DOC-000

### Related Files
`src/stores/slices/documentsSlice.ts` · `src/data/documentTemplates.ts` · `src/hooks/useDocumentTemplates.ts`

### Subtasks

- [ ] **DOC-001A**: Create `src/stores/slices/documentsSlice.ts`:
  ```ts
  interface DocumentsSlice {
    // Active state
    activeDocumentId: string | null
    activeViewMode: 'edit' | 'preview' | 'split' | 'graph' | 'timeline'
    selectedDocumentIds: Set<string>
    searchQuery: string
    searchFilters: DocumentFilters
    
    // Editor state
    editorContent: string
    editorCursorPosition: number
    editorSelection: { start: number; end: number } | null
    
    // Linking state
    linkingMode: boolean
    suggestedLinks: DocumentSuggestion[]
    
    // Collaboration state
    collaborationUsers: CollaborationUser[]
    myCursor: CursorPosition | null
    
    // UI state
    sidebarOpen: boolean
    templateDrawerOpen: boolean
    shareDialogOpen: boolean
    versionHistoryOpen: boolean
    
    // Actions
    setActiveDocument: (id: string | null) => void
    setViewMode: (mode: DocumentsSlice['activeViewMode']) => void
    toggleDocumentSelected: (id: string) => void
    selectAllDocuments: () => void
    clearSelection: () => void
    setSearchQuery: (q: string) => void
    setSearchFilters: (filters: Partial<DocumentFilters>) => void
    setEditorContent: (content: string) => void
    setCursorPosition: (position: number) => void
    setSelection: (selection: { start: number; end: number } | null) => void
    toggleLinkingMode: () => void
    setSuggestedLinks: (links: DocumentSuggestion[]) => void
    updateCollaborationUsers: (users: CollaborationUser[]) => void
    setMyCursor: (cursor: CursorPosition | null) => void
    toggleSidebar: () => void
    openTemplateDrawer: () => void
    closeTemplateDrawer: () => void
    openShareDialog: () => void
    closeShareDialog: () => void
    openVersionHistory: () => void
    closeVersionHistory: () => void
  }
  ```

- [ ] **DOC-001B**: Export atomic selectors:
  - `useActiveDocument()`, `useViewMode()`, `useDocumentSearch()`, `useEditorState()`, `useLinkingState()`, `useCollaborationState()`

- [ ] **DOC-001C**: Create `src/data/documentTemplates.ts` with built-in templates:
  ```ts
  export const BUILT_IN_TEMPLATES = [
    { id: 'meeting-notes', name: 'Meeting Notes', icon: 'Users', type: 'markdown', template: '# Meeting Notes\n\n## Date: {{date}}\n## Attendees:\n- \n## Agenda:\n1. \n## Notes:\n\n## Action Items:\n- [ ] ' },
    { id: 'project-brief', name: 'Project Brief', icon: 'Briefcase', type: 'markdown', template: '# Project Brief\n\n## Overview\n\n## Objectives\n\n## Timeline\n\n## Resources\n\n## Risks' },
    { id: 'research-paper', name: 'Research Paper', icon: 'BookOpen', type: 'markdown', template: '# {{title}}\n\n## Abstract\n\n## Introduction\n\n## Methodology\n\n## Results\n\n## Conclusion\n\n## References' },
    { id: 'personal-journal', name: 'Personal Journal', icon: 'Heart', type: 'markdown', template: '# {{date}}\n\n## Gratitude\n\n## Reflections\n\n## Learnings\n\n## Tomorrow' },
    { id: 'product-spec', name: 'Product Spec', icon: 'Package', type: 'markdown', template: '# Product Specification\n\n## Problem Statement\n\n## Solution\n\n## Features\n\n## Technical Requirements\n\n## Success Metrics' },
    { id: 'meeting-agenda', name: 'Meeting Agenda', icon: 'Calendar', type: 'markdown', template: '# Meeting Agenda\n\n## Date: {{date}}\n## Duration: {{duration}}\n\n## Topics\n1. \n2. \n3. \n\n## Pre-reading\n\n## Decisions Needed' },
    { id: 'book-summary', name: 'Book Summary', icon: 'Book', type: 'markdown', template: '# {{title}}\n\n## Author: {{author}}\n\n## Key Takeaways\n\n## Notes\n\n## Quotes\n\n## Action Items' },
    { id: 'decision-log', name: 'Decision Log', icon: 'CheckSquare', type: 'markdown', template: '# Decision Log\n\n## Date: {{date}}\n## Decision:\n\n## Context:\n\n## Options:\n1. \n2. \n3. \n\n## Rationale:\n\n## Outcome:' },
    { id: 'travel-plan', name: 'Travel Plan', icon: 'MapPin', type: 'markdown', template: '# {{destination}} Trip\n\n## Dates: {{dates}}\n\n## Budget: {{budget}}\n\n## Itinerary\n\n### Day 1\n- \n\n## Packing List\n\n## Documents Needed' },
    { id: 'weekly-review', name: 'Weekly Review', icon: 'RotateCcw', type: 'markdown', template: '# Weekly Review - {{week}}\n\n## Wins\n\n## Challenges\n\n## Learnings\n\n## Next Week Focus\n\n## Metrics' }
  ] as const
  ```

- [ ] **DOC-001D**: Create `useDocumentTemplates()` hook:
  - Returns built-in + user-created templates
  - `createCustomTemplate(document)` mutation
  - `deleteCustomTemplate(id)` mutation
  - `applyTemplate(templateId, documentId)` mutation

- [ ] **DOC-001E**: Persist view preferences to `localStorage`:
  - Each document remembers user's preferred view mode
  - Store sidebar state, editor preferences
  - Use `partialize` to store only UI preferences

### Tests
- [ ] State updates correctly for all actions
- [ ] Atomic selectors prevent unnecessary re-renders
- [ ] Template data loads and creates documents with correct content
- [ ] View mode persists across page reloads
- [ ] Linking mode toggles correctly with UI updates

### Definition of Done
- Complete documents slice with editor, search, and collaboration state
- 10 built-in templates with realistic content
- Custom template creation supported
- View mode and UI preferences persisted

### Anti-Patterns
- ❌ Persisting full document content to Zustand — use Dexie for content, Zustand for UI state only
- ❌ Not using atomic selectors — causes re-renders on every document change
- ❌ Hardcoding templates without user customization

---

## 📝 Task DOC-002: Documents Page Layout & Editor
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** FND-007 (Router), DOC-001

### Related Files
`src/pages/DocumentsPage.tsx` · `src/components/documents/DocumentsLayout.tsx` · `src/components/documents/DocumentEditor.tsx` · `src/components/documents/DocumentPreview.tsx` · `src/components/documents/DocumentSidebar.tsx` · `src/router/routes.ts`

### Subtasks

- [ ] **DOC-002A**: Configure `/documents` route in `src/router/routes.ts`:
  ```ts
  {
    path: 'documents',
    lazy: () => import('@/pages/DocumentsPage'),
    loader: () => queryClient.ensureQueryData(documentsQueryOptions({})),
  },
  {
    path: 'documents/:documentId',
    lazy: () => import('@/pages/DocumentsPage'),
    loader: ({ params }) => queryClient.ensureQueryData(documentDetailQueryOptions(params.documentId!)),
  }
  ```

- [ ] **DOC-002B**: Create `src/pages/DocumentsPage.tsx` with flexible layout:
  - Left sidebar (280px): Document list, search, tags, "New Document" button
  - Main content (flex-1): Active document with view switcher
  - Right panel (320px, collapsible): Document details, links, backlinks, versions
  - Responsive: Stack on mobile, sidebar collapses to icons

- [ ] **DOC-002C**: Build `DocumentEditor` component:
  - Markdown editor with syntax highlighting (using `@uiw/react-md-editor` or similar)
  - Real-time preview toggle
  - Auto-save every 30 seconds or on blur
  - Link creation on `[[` autocomplete
  - Tag suggestion with `#` prefix
  - Toolbar with formatting buttons (bold, italic, link, image, code)
  - Word count and reading time display

- [ ] **DOC-002D**: Build `DocumentPreview` component:
  - Rendered Markdown with proper styling
  - Clickable links (both internal and external)
  - Image preview with lightbox
  - Code block syntax highlighting
  - Table of contents for long documents
  - Print-friendly view
  - Note: If any HTML content is rendered (e.g., from document imports), use shared `SanitizedHTML` component (see 01-Foundations.md)

- [ ] **DOC-002E**: Implement split view mode:
  - Side-by-side editor and preview
  - Synchronized scrolling
  - Resizable divider
  - Mobile: toggle between editor and preview

- [ ] **DOC-002F**: Build `DocumentSidebar` component:
  - Search input with real-time filtering
  - Document list with title, type icon, tags, last modified
  - Tag cloud with click-to-filter
  - "New Document" button opens template drawer
  - Document status filter (draft/published/archived)
  - Sort options (title, modified, created)

- [ ] **DOC-002G**: Add view mode switcher in document header:
  - Edit, Preview, Split, Graph, Timeline views
  - Active state with `layoutId` animated indicator
  - Keyboard shortcuts: `Cmd/Ctrl+E` (edit), `Cmd/Ctrl+R` (preview), `Cmd/Ctrl+S` (split)

- [ ] **DOC-002H**: Implement auto-save and conflict detection:
  - Debounced save (2 seconds after last change)
  - Conflict detection when multiple users edit
  - "Document changed by others" notification with merge options

### Tests
- [ ] Route renders with correct layout; document ID from URL loads correct document
- [ ] Editor renders Markdown with syntax highlighting
- [ ] Preview renders with clickable links and images
- [ ] Split view synchronizes scrolling correctly
- [ ] Auto-save triggers after inactivity
- [ ] Search filters document list in real-time

### Definition of Done
- Documents page with responsive three-column layout
- Full-featured Markdown editor with toolbar
- Live preview with rendered Markdown
- Split view with synchronized scrolling
- Document sidebar with search and filtering
- Auto-save with conflict detection

### Anti-Patterns
- ❌ Not implementing auto-save — users lose work
- ❌ Using textarea without syntax highlighting — poor editing experience
- ❌ Not handling large documents efficiently — causes performance issues
- ❌ Missing keyboard shortcuts — power users expect them

---

## 🔗 Task DOC-003: Bidirectional Linking & Graph Visualization
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** DOC-002, DOC-000

### Related Files
`src/components/documents/LinkingSystem.tsx` · `src/components/documents/DocumentGraph.tsx` · `src/components/documents/BacklinksPanel.tsx` · `src/hooks/useDocumentLinks.ts`

### Subtasks

- [ ] **DOC-003A**: Implement wikilink parsing and creation:
  - Parse `[[document title]]` syntax in Markdown
  - Auto-complete suggestions when typing `[[`
  - Create links on selection or explicit action
  - Handle link text: `[[document title|display text]]`
  - Validate links (warn if target doesn't exist)

- [ ] **DOC-003B**: Build `LinkingSystem` component:
  - Link creation modal with document search
  - Link type selection (wikilink, external, attachment)
  - Preview of linked content
  - Bulk link creation from selected text
  - Link editing and removal

- [ ] **DOC-003C**: Implement backlink discovery:
  - Scan all documents for links to current document
  - Update backlinks when documents are modified
  - Index backlinks for fast lookup
  - Show backlink count in document header

- [ ] **DOC-003D**: Build `BacklinksPanel` component:
  - List of all documents linking to current document
  - Show context around each link (surrounding text)
  - Click to navigate to linking document
  - Filter by date or document type
  - Export backlinks as report

- [ ] **DOC-003E**: Create `DocumentGraph` visualization:
  - Force-directed graph using `d3-force` or `vis-network`
  - Nodes represent documents, edges represent links
  - Node size based on link count or importance
  - Color coding by document type or tags
  - Interactive: click nodes to open documents, drag to reposition
  - Zoom and pan controls
  - Cluster detection for related document groups

- [ ] **DOC-003F**: Implement graph interactions:
  - Hover shows document preview tooltip
  - Double-click opens document in new tab
  - Right-click context menu (open, edit, delete link)
  - Search within graph (highlight matching nodes)
  - Filter graph by tags or date range
  - Export graph as image or data

- [ ] **DOC-003G**: Create `useDocumentLinks()` hook:
  - `useLinks(documentId)` — outgoing links
  - `useBacklinks(documentId)` — incoming links
  - `useLinkGraph()` — full graph data
  - `createLink(sourceId, targetId, linkText)` mutation
  - `deleteLink(linkId)` mutation
  - `updateLink(linkId, updates)` mutation

- [ ] **DOC-003H**: Implement link analytics:
  - Link density metrics
  - Orphaned documents (no links)
  - Hub documents (many outgoing links)
  - Bridge documents (connecting clusters)
  - Link strength based on frequency

### Tests
- [ ] Wikilink parsing correctly identifies all links
- [ ] Auto-complete suggests relevant documents
- [ ] Backlinks update when documents are modified
- [ ] Graph visualization renders with correct nodes and edges
- [ ] Graph interactions (zoom, pan, click) work smoothly
- [ ] Link creation updates both forward and backward references

### Definition of Done
- Full wikilink system with auto-complete
- Automatic backlink discovery and display
- Interactive graph visualization of document network
- Link analytics and insights
- Graph filtering and export capabilities

### Anti-Patterns
- ❌ Not updating backlinks dynamically — stale link data
- ❌ Using heavy graph library without optimization — causes performance issues
- ❌ Missing link validation — broken links frustrate users
- ❌ Not handling orphaned documents — users lose track of content

---

## 📸 Task DOC-004: OCR Processing & Document Import
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** DOC-000

### Related Files
`src/components/documents/OCRProcessor.tsx` · `src/components/documents/DocumentImport.tsx` · `src/lib/ocr.ts` · `src/hooks/useOCRProcessing.ts`

### Subtasks

- [ ] **DOC-004A**: Install and configure Tesseract.js:
  ```bash
  pnpm add tesseract.js
  ```

- [ ] **DOC-004B**: Create `src/lib/ocr.ts` with OCR processing:
  ```ts
  export class OCRProcessor {
    async processImage(imageFile: File, language?: string): Promise<OCRResult>
    async processPDF(pdfFile: File): Promise<OCRResult>
    async processBatch(files: File[]): Promise<OCRResult[]>
    private createWorker(language: string): Promise<Tesseract.Worker>
  }
  
  interface OCRResult {
    text: string
    confidence: number
    words: OCRWord[]
    blocks: OCRBlock[]
    processingTime: number
  }
  ```

- [ ] **DOC-004C**: Build `DocumentImport` component:
  - Drag-and-drop zone for files
  - Support for: PDF, images (JPG, PNG), text files, Markdown
  - Multiple file selection with batch processing
  - File preview before import
  - Import options: OCR processing, auto-tagging, template assignment

- [ ] **DOC-004D**: Build `OCRProcessor` component:
  - Progress bar for processing status
  - Real-time confidence score display
  - Text preview with highlighted low-confidence regions
  - Language selection (auto-detect or manual)
  - Retry failed processing
  - Batch processing queue

- [ ] **DOC-004E**: Implement `useOCRProcessing()` hook:
  - `processFile(file, options)` mutation with progress tracking
  - `processBatch(files, options)` for multiple files
  - `getOCRStatus(fileId)` for checking processing status
  - Cancel processing functionality
  - Error handling and retry logic

- [ ] **DOC-004F**: Create document from OCR results:
  - Extract text and create new document
  - Preserve original file as attachment
  - Auto-generate title from first line or filename
  - Add OCR metadata (confidence, processing time)
  - Suggest tags based on content analysis

- [ ] **DOC-004G**: Implement OCR quality improvements:
  - Image preprocessing (contrast, rotation, deskew)
  - Multi-language support
  - Table detection and extraction
  - Handwriting recognition (if supported)
  - PDF text layer extraction (fallback)

- [ ] **DOC-004H**: Add OCR to existing documents:
  - Upload images/PDFs to existing documents
  - Append OCR text to document content
  - Link original file as attachment
  - Update document metadata with OCR info

### Tests
- [ ] OCR processing extracts text from images with reasonable accuracy
- [ ] PDF processing handles both text and scanned PDFs
- [ ] Batch processing processes multiple files sequentially
- [ ] Progress indicators update correctly during processing
- [ ] Error handling works for corrupted files
- [ ] Language selection improves OCR accuracy

### Definition of Done
- Full OCR pipeline using Tesseract.js
- Support for image and PDF processing
- Batch import with drag-and-drop
- Progress tracking and error handling
- Document creation from OCR results
- Quality improvements and preprocessing

### Anti-Patterns
- ❌ Processing large files on main thread — blocks UI
- ❌ Not providing progress feedback — users think it's broken
- ❌ Ignoring OCR confidence scores — may accept poor results
- ❌ Not handling file size limits — causes memory issues

---

## 🔍 Task DOC-005: Semantic Search & Vector Embeddings
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** DOC-000, DOC-004

### Related Files
`src/components/documents/SearchInterface.tsx` · `src/lib/vectorSearch.ts` · `src/hooks/useSemanticSearch.ts` · `src/components/documents/SearchResults.tsx`

### Subtasks

- [ ] **DOC-005A**: Create vector embedding system:
  ```ts
  // src/lib/vectorSearch.ts
  export class VectorSearchEngine {
    private embeddings: Map<string, number[]> = new Map()
    
    async generateEmbedding(text: string): Promise<number[]>
    async search(query: string, topK: number = 10): Promise<SearchResult[]>
    async addDocument(id: string, text: string): Promise<void>
    async removeDocument(id: string): Promise<void>
    async updateDocument(id: string, text: string): Promise<void>
    private cosineSimilarity(a: number[], b: number[]): number
  }
  
  interface SearchResult {
    documentId: string
    score: number
    highlights: string[]
    metadata: SearchResultMetadata
  }
  ```

- [ ] **DOC-005B**: Implement embedding generation:
  - Use OpenAI-compatible API for text embeddings
  - Chunk long documents (500-1000 token chunks)
  - Cache embeddings in IndexedDB for offline use
  - Batch processing for efficiency
  - Fallback to mock embeddings for development

- [ ] **DOC-005C**: Build `SearchInterface` component:
  - Unified search bar with real-time suggestions
  - Search modes: Full-text, Semantic, Hybrid
  - Advanced filters: tags, date range, document type, author
  - Search history and saved searches
  - Keyboard shortcut: `Cmd/Ctrl+K`

- [ ] **DOC-005D**: Implement hybrid search algorithm:
  - Combine full-text search (BM25) with semantic similarity
  - Weighted scoring (tunable per user preference)
  - Re-rank results using machine learning (optional)
  - Personalization based on user interaction history

- [ ] **DOC-005E**: Build `SearchResults` component:
  - Result list with relevance scores
  - Highlighted matching text
  - Document preview with matched sections
  - Faceted search sidebar (tags, types, dates)
  - Sort options (relevance, date, title)
  - Export results

- [ ] **DOC-005F**: Create `useSemanticSearch()` hook:
  - `searchDocuments(query, filters)` with debouncing
  - `generateEmbeddings(documentIds)` for batch processing
  - `updateSearchIndex()` when documents change
  - `getSearchSuggestions(partialQuery)` for autocomplete

- [ ] **DOC-005G**: Implement search analytics:
  - Track search queries and click-through rates
  - Identify failed searches (no results)
  - Suggest query improvements
  - Popular searches and trending topics

- [ ] **DOC-005H**: Add advanced search features:
  - Natural language queries ("find documents about machine learning")
  - Boolean operators (AND, OR, NOT)
  - Phrase searches with quotes
  - Proximity searches (words within N tokens)
  - Regular expression support

### Tests
- [ ] Vector embeddings generate consistently for same text
- [ ] Semantic search returns relevant documents
- [ ] Hybrid search combines text and semantic results correctly
- [ ] Search filters work as expected
- [ ] Search performance is acceptable (<500ms for 1000 documents)
- [ ] Search suggestions improve user experience

### Definition of Done
- Complete vector search engine with embeddings
- Hybrid search combining text and semantic methods
- Advanced search interface with filters
- Search analytics and suggestions
- Performance optimized for large document collections

### Anti-Patterns
- ❌ Not caching embeddings — expensive to regenerate
- ❌ Using semantic search for everything — sometimes simple text search is better
- ❌ Not providing search feedback — users don't know why results match
- ❌ Ignoring search performance — slow search frustrates users

---

## 🤖 Task DOC-006: AI-Powered Content Extraction
**Priority:** 🟠 Medium | **Est. Effort:** 2.5 hours | **Depends On:** DOC-004, DOC-005

### Related Files
`src/components/documents/ExtractionPanel.tsx` · `src/lib/contentExtractor.ts` · `src/hooks/useContentExtraction.ts` · `src/components/documents/EntityHighlight.tsx`

### Subtasks

- [ ] **DOC-006A**: Create AI extraction service:
  ```ts
  // src/lib/contentExtractor.ts
  export class ContentExtractor {
    async extractEntities(text: string): Promise<Entity[]>
    async extractTopics(text: string): Promise<Topic[]>
    async generateSummary(text: string): Promise<string>
    async extractKeywords(text: string): Promise<string[]>
    async extractDates(text: string): Promise<Date[]>
    async extractPeople(text: string): Promise<Person[]>
    async extractOrganizations(text: string): Promise<Organization[]>
  }
  ```

- [ ] **DOC-006B**: Implement entity extraction:
  - Named Entity Recognition (NER) for people, organizations, locations
  - Custom entity types (projects, products, concepts)
  - Confidence scoring for each entity
  - Entity linking to existing knowledge base
  - Bulk entity extraction for document collections

- [ ] **DOC-006C**: Build `ExtractionPanel` component:
  - Toggle for different extraction types
  - Entity list with confidence scores
  - Topic modeling with hierarchical topics
  - Summary generation with length control
  - Keyword extraction with relevance scores
  - Export extraction results

- [ ] **DOC-006D**: Create `EntityHighlight` component:
  - Highlight entities in document text
  - Hover tooltips with entity details
  - Click to search for similar entities
  - Color coding by entity type
  - Entity editing and correction

- [ ] **DOC-006E**: Implement topic modeling:
  - Latent Dirichlet Allocation (LDA) or similar
  - Hierarchical topic discovery
  - Topic evolution over time
  - Topic-based document clustering
  - Topic strength visualization

- [ ] **DOC-006F**: Add automatic tagging:
  - Suggest tags based on extracted entities and topics
  - Learn from user tag corrections
  - Tag hierarchy and relationships
  - Auto-tag new documents based on content
  - Tag cleanup and deduplication

- [ ] **DOC-006G**: Create `useContentExtraction()` hook:
  - `extractContent(documentId, types)` mutation
  - `getExtractionResults(documentId)` query
  - `updateEntity(entityId, corrections)` mutation
  - `approveExtraction(documentId)` mutation

- [ ] **DOC-006H**: Implement extraction workflows:
  - Automatic extraction on document import
  - Scheduled re-extraction for updated documents
  - Manual extraction trigger
  - Extraction quality metrics
  - Human-in-the-loop correction interface

### Tests
- [ ] Entity extraction identifies relevant entities with good accuracy
- [ ] Topic modeling produces coherent topics
- [ ] Summary generation captures key points
- [ ] Entity highlighting works correctly in documents
- [ ] Auto-tagging suggests relevant tags
- [ ] Extraction workflows run efficiently

### Definition of Done
- AI-powered entity, topic, and keyword extraction
- Automatic document summarization
- Entity highlighting and interaction
- Topic modeling and visualization
- Automatic tagging with user feedback
- Extraction workflows and quality metrics

### Anti-Patterns
- ❌ Not providing extraction confidence — users can't trust results
- ❌ Extracting everything indiscriminately — information overload
- ❌ Not allowing user correction — extraction quality doesn't improve
- ❌ Running extraction on every keystroke — performance issues

---

## ❓ Task DOC-007: Question-Answering over Documents
**Priority:** 🟠 Medium | **Est. Effort:** 3 hours | **Depends On:** DOC-005, DOC-006

### Related Files
`src/components/documents/QAInterface.tsx` · `src/lib/qaEngine.ts` · `src/hooks/useQuestionAnswering.ts` · `src/components/documents/AnswerPanel.tsx`

### Subtasks

- [ ] **DOC-007A**: Create RAG (Retrieval-Augmented Generation) system:
  ```ts
  // src/lib/qaEngine.ts
  export class QAEngine {
    async askQuestion(
      question: string, 
      documentIds?: string[],
      context?: string
    ): Promise<QAResult>
    
    private async retrieveDocuments(question: string): Promise<RetrievedDocument[]>
    private async generateAnswer(
      question: string, 
      contexts: string[]
    ): Promise<GeneratedAnswer>
    private async formatAnswer(
      answer: GeneratedAnswer,
      sources: RetrievedDocument[]
    ): Promise<QAResult>
  }
  
  interface QAResult {
    answer: string
    confidence: number
    sources: SourceReference[]
    followUpQuestions: string[]
    relatedDocuments: string[]
  }
  ```

- [ ] **DOC-007B**: Implement document retrieval:
  - Semantic search for relevant document chunks
  - Hybrid retrieval (semantic + keyword)
  - Reranking based on question relevance
  - Context window management
  - Source attribution and citation

- [ ] **DOC-007C**: Build `QAInterface` component:
  - Question input with auto-complete
  - Question history and suggestions
  - Document scope selection (all vs specific documents)
  - Question templates and examples
  - Voice input support (Web Speech API)

- [ ] **DOC-007D**: Create `AnswerPanel` component:
  - Formatted answer with markdown rendering
  - Source citations with clickable links
  - Confidence score visualization
  - Follow-up question suggestions
  - Related documents list
  - Answer feedback (helpful/not helpful)

- [ ] **DOC-007E**: Implement conversation context:
  - Maintain conversation history
  - Context-aware follow-up questions
  - Reference previous answers in current response
  - Conversation summarization for long sessions

- [ ] **DOC-007F**: Add advanced QA features:
  - Multi-document question answering
  - Comparative analysis ("compare documents about X")
  - Synthesis questions ("summarize all documents about Y")
  - Temporal questions ("what happened between date A and date B")
  - Hypothetical questions based on document content

- [ ] **DOC-007G**: Create `useQuestionAnswering()` hook:
  - `askQuestion(question, options)` mutation
  - `getConversationHistory()` query
  - `rateAnswer(answerId, rating)` mutation
  - `getQuestionSuggestions(partialQuestion)` query

- [ ] **DOC-007H**: Implement QA analytics:
  - Track question types and patterns
  - Monitor answer quality and feedback
  - Identify difficult questions (low confidence)
  - Popular questions and topics
  - User satisfaction metrics

### Tests
- [ ] QA system returns relevant answers with citations
- [ ] Source attribution is accurate and clickable
- [ ] Follow-up questions are contextually relevant
- [ ] Multi-document questions synthesize information correctly
- [ ] Conversation context maintains coherence
- [ ] Answer feedback improves system quality

### Definition of Done
- Full RAG-based question-answering system
- Accurate source attribution and citations
- Conversation context and history
- Advanced question types (comparative, temporal, hypothetical)
- Answer quality feedback and analytics
- Voice input support

### Anti-Patterns
- ❌ Not providing source citations — users can't verify answers
- ❌ Answering questions outside document scope — hallucination
- ❌ Not maintaining conversation context — repetitive answers
- ❌ Ignoring answer quality feedback — system doesn't improve

---

## 👥 Task DOC-008: Real-Time Collaboration
**Priority:** 🟠 Medium | **Est. Effort:** 1.5 hours | **Depends On:** DOC-002

### Related Files
`src/components/documents/CollaborationPanel.tsx` · `src/lib/yjsDocument.ts` · `src/hooks/useRealTimeSync.ts` · `src/components/documents/CursorOverlay.tsx`

### Subtasks

- [ ] **DOC-008A**: Implement Yjs document management:
  ```ts
  // src/lib/yjsDocument.ts
  import * as Y from 'yjs'
  import { IndexeddbPersistence } from 'y-indexeddb'
  
  export class YjsDocumentManager {
    private ydoc: Y.Doc
    private ytext: Y.Text
    private persistence: IndexeddbPersistence
    
    constructor(documentId: string) {
      this.ydoc = new Y.Doc()
      this.ytext = this.ydoc.getText('content')
      this.persistence = new IndexeddbPersistence(`doc-${documentId}`, this.ydoc)
    }
    
    getText(): Y.Text {
      return this.ytext
    }
    
    getDoc(): Y.Doc {
      return this.ydoc
    }
    
    destroy(): void {
      this.ydoc.destroy()
    }
  }
  ```

- [ ] **DOC-008B**: Configure Yjs network provider:
  - Use `y-websocket` or `y-webrtc` provider for real-time sync
  - Room-based collaboration (document-specific rooms)
  - User presence and status via provider.awareness
  - Yjs handles message queuing and ordering automatically
  - CRDT-based conflict resolution (no manual protocols needed)

- [ ] **DOC-008C**: Build `CollaborationPanel` component:
  - Active users list with avatars and status
  - User permissions (view, edit, comment, admin)
  - Share link generation and management
  - Activity feed (recent changes, comments)
  - Collaboration settings

- [ ] **DOC-008D**: Create `CursorOverlay` component using Yjs awareness:
  - Use `provider.awareness.getStates()` to get all user cursors
  - Use `provider.awareness.setLocalStateField('cursor', position)` to broadcast cursor
  - User labels with custom colors from awareness state
  - Selection highlighting from awareness state
  - Hover tooltips with user info from awareness state
  - Smooth cursor animations (Alive-tier motion)

- [ ] **DOC-008E**: Implement real-time features:
  - Live document editing with Yjs Y.Text (automatic CRDT sync)
  - Comment system with threading
  - @mention notifications
  - Document locking for concurrent editing prevention (optional, Yjs handles conflicts)
  - Change tracking with user attribution via awareness

- [ ] **DOC-008F**: Add collaboration UI elements:
  - User avatars in document header
  - "X people editing" indicator
  - Conflict resolution dialog
  - Share button with permission settings
  - Version comparison with user changes

- [ ] **DOC-008G**: Create `useRealTimeSync()` hook:
  - `joinDocument(documentId)` — initialize Yjs provider and persistence
  - `sendOperation(operation)` — Yjs handles automatically via Y.Text mutations
  - `receiveOperations()` — observe Y.Text changes with `ytext.observe()`
  - `updateCursor(position)` — use `awareness.setLocalStateField('cursor', position)`
  - `addComment(comment)` mutation

- [ ] **DOC-008H**: Implement offline collaboration with y-indexeddb:
  - y-indexeddb automatically queues operations when offline
  - Sync when reconnected (handled by IndexeddbPersistence)
  - CRDT-based conflict resolution for concurrent edits (automatic)
  - Offline indicator and status (listen to `persistence.on('synced')`)

### Tests
- [ ] Yjs Y.Text handles concurrent edits correctly
- [ ] Real-time cursors update smoothly via awareness
- [ ] Comment system works with threading
- [ ] CRDT conflict resolution preserves user intent
- [ ] y-indexeddb persists and syncs operations properly
- [ ] User permissions are enforced correctly

### Definition of Done
- Full real-time collaboration with Yjs CRDT
- Live cursors and user presence via awareness
- Comment system with @mentions
- Document sharing with permissions
- Automatic conflict resolution and change tracking
- Offline collaboration support via y-indexeddb

### Anti-Patterns
- ❌ Implementing custom operational transforms — Yjs handles this automatically
- ❌ Not using y-indexeddb for offline — users lose work
- ❌ Not showing other users' presence — confusing experience
- ❌ Manual conflict resolution logic — Yjs CRDT handles this

---

## 📚 Task DOC-009: Version Control & Document History
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** DOC-002

### Related Files
`src/components/documents/VersionHistory.tsx` · `src/components/documents/DiffViewer.tsx` · `src/lib/versionControl.ts` · `src/hooks/useVersionControl.ts`

### Subtasks

- [ ] **DOC-009A**: Create version control system:
  ```ts
  // src/lib/versionControl.ts
  export class VersionControl {
    async createVersion(documentId: string, content: string): Promise<Version>
    async getVersions(documentId: string): Promise<Version[]>
    async getVersion(documentId: string, versionId: string): Promise<Version>
    async revertToVersion(documentId: string, versionId: string): Promise<void>
    async compareVersions(v1: string, v2: string): Promise<DiffResult>
  }
  
  interface Version {
    id: string
    documentId: string
    content: string
    timestamp: string
    author: string
    message: string
    changes: Change[]
  }
  ```

- [ ] **DOC-009B**: Implement diff algorithm:
  - Line-based diff for text content
  - Character-level diff for fine-grained changes
  - Semantic diff (understand Markdown structure)
  - Change summarization
  - Visual diff rendering

- [ ] **DOC-009C**: Build `VersionHistory` component:
  - Timeline view of all versions
  - Version metadata (author, timestamp, message)
  - Quick preview of version content
  - Compare any two versions
  - Revert to previous version
  - Branch and merge support (advanced)

- [ ] **DOC-009D**: Create `DiffViewer` component:
  - Side-by-side diff view
  - Unified diff view
  - Syntax highlighting in diff
  - Change statistics (additions, deletions, modifications)
  - Navigate between changes
  - Export diff as patch

- [ ] **DOC-009E**: Implement automatic versioning:
  - Create version on significant changes
  - Auto-save versions at intervals
  - Version cleanup and retention policies
  - Version compression for storage efficiency
  - Version tagging and milestones

- [ ] **DOC-009F**: Add version collaboration features:
  - Branch creation for experimental changes
  - Pull request-style merge requests
  - Code review style comments on changes
  - Conflict resolution for merge
  - Version approval workflows

- [ ] **DOC-009G**: Create `useVersionControl()` hook:
  - `getVersions(documentId)` query
  - `createVersion(documentId, message)` mutation
  - `revertToVersion(documentId, versionId)` mutation
  - `compareVersions(documentId, v1, v2)` query

- [ ] **DOC-009H**: Implement version analytics:
  - Change frequency analysis
  - Contributor statistics
  - Document evolution visualization
  - Version quality metrics
  - Rollback patterns analysis

### Tests
- [ ] Version creation stores correct content and metadata
- [ ] Diff algorithm accurately identifies changes
- [ ] Version revert restores document correctly
- [ ] Version comparison shows meaningful differences
- [ ] Automatic versioning works as configured
- [ ] Merge conflict resolution preserves intended changes

### Definition of Done
- Complete version control system with diff visualization
- Automatic versioning with configurable policies
- Version history timeline with metadata
- Branch and merge capabilities
- Version collaboration features
- Version analytics and insights

### Anti-Patterns
- ❌ Storing full document content for every version — storage inefficiency
- ❌ Not providing meaningful diff visualization — hard to understand changes
- ❌ Missing version metadata — can't track who changed what
- ❌ Not handling merge conflicts — data corruption

---

## 📱 Task DOC-010: Offline Support & Data Sync
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** DOC-000, DOC-001

### Related Files
`src/lib/db/documents.ts` · `src/hooks/useOfflineDocuments.ts` · `src/components/documents/OfflineStatusBar.tsx` · `src/lib/yjsDocument.ts`

### Subtasks

- [ ] **DOC-010A**: Import centralized Dexie schema from `@/lib/db/commandCenterDB` with module-prefixed stores: `documents_documents`, `documents_syncQueue`, `documents_embeddings`. For collaborative documents, y-indexeddb handles persistence automatically via `IndexeddbPersistence` (see DOC-008A).

- [ ] **DOC-010B**: Implement `useOfflineDocuments()` hook:
  - Read documents from Dexie when offline
  - Write to Dexie immediately on all operations
  - Queue mutations in `pendingMutations` table
  - Sync queue when connection restored
  - Handle sync conflicts with resolution strategies
  - For collaborative documents, y-indexeddb automatically handles offline persistence and sync

- [ ] **DOC-010C**: Create sync engine for non-collaborative documents:
  ```ts
  // src/lib/syncEngine.ts
  export class SyncEngine {
    async syncPendingMutations(): Promise<SyncResult>
    async handleConflict(local: any, remote: any): Promise<ConflictResolution>
    async retryFailedMutations(): Promise<void>
    async cleanupOldMutations(): Promise<void>
    private async applyMutation(mutation: PendingMutation): Promise<void>
  }
  ```
  Note: Collaborative documents use Yjs CRDT + y-indexeddb for automatic sync (no custom sync engine needed).

- [ ] **DOC-010D**: Build `OfflineStatusBar` component:
  - Connection status indicator
  - Pending mutations count
  - Last sync timestamp
  - Manual sync button
  - Sync progress indicator
  - Error notifications with retry options

- [ ] **DOC-010E**: Implement conflict resolution:
  - Last-write-wins for simple conflicts
  - Manual resolution for complex conflicts
  - Three-way merge for text content
  - Conflict preview and selection
  - Conflict history and analytics
  - For collaborative documents, Yjs CRDT automatically resolves conflicts (no manual resolution needed)

- [ ] **DOC-010F**: Add offline features:
  - Offline document creation and editing
  - Cached search results
  - Offline OCR processing (limited)
  - Offline graph visualization (cached)
  - Export documents for backup

- [ ] **DOC-010G**: Implement incremental sync:
  - Sync only changed documents
  - Delta sync for large documents
  - Background sync with throttling
  - Sync prioritization (active documents first)
  - Bandwidth usage monitoring

- [ ] **DOC-010H**: Create sync analytics:
  - Sync success/failure rates
  - Conflict frequency and types
  - Network usage patterns
  - Offline usage statistics
  - Performance metrics

### Tests
- [ ] Documents load from Dexie when offline
- [ ] Mutations queue correctly when offline
- [ ] Sync processes queue when connection restored
- [ ] Conflict resolution preserves user data
- [ ] Incremental sync reduces bandwidth usage
- [ ] Offline status bar shows correct information
- [ ] y-indexeddb persists collaborative documents and syncs on reconnect

### Definition of Done
- Full offline support with IndexedDB storage
- Robust sync engine with conflict resolution (for non-collaborative docs)
- y-indexeddb for collaborative document persistence (automatic)
- Offline status indicators and controls
- Incremental sync with bandwidth optimization
- Comprehensive sync analytics
- Offline feature parity (where possible)

### Anti-Patterns
- ❌ Not queueing mutations offline — data loss
- ❌ Silent sync failures — users unaware of problems
- ❌ Not handling conflicts properly — data corruption
- ❌ Full sync every time — bandwidth waste
- ❌ Not using y-indexeddb for collaborative documents — unnecessary complexity

---

## 🎨 Task DOC-011: Rich Content & Media Support
**Priority:** 🟠 Medium | **Est. Effort:** 2 hours | **Depends On:** DOC-002

### Related Files
`src/components/documents/MediaEmbed.tsx` · `src/components/documents/MediaGallery.tsx` · `src/lib/mediaProcessor.ts` · `src/hooks/useMediaContent.ts`

### Subtasks

- [ ] **DOC-011A**: Create media processing system:
  ```ts
  // src/lib/mediaProcessor.ts
  export class MediaProcessor {
    async processImage(file: File): Promise<ProcessedMedia>
    async processVideo(file: File): Promise<ProcessedMedia>
    async processAudio(file: File): Promise<ProcessedMedia>
    async generateThumbnail(file: File): Promise<string>
    async extractMetadata(file: File): Promise<MediaMetadata>
  }
  
  interface ProcessedMedia {
    id: string
    type: 'image' | 'video' | 'audio'
    originalUrl: string
    thumbnailUrl?: string
    metadata: MediaMetadata
    size: number
    duration?: number
  }
  ```

- [ ] **DOC-011B**: Build `MediaEmbed` component:
  - Image viewer with zoom and pan
  - Video player with custom controls
  - Audio player with waveform visualization
  - PDF viewer with page navigation
  - Code block with syntax highlighting and copy
  - Embedded content (tweets, maps, charts)

- [ ] **DOC-011C**: Create `MediaGallery` component:
  - Grid view of all media in document
  - Filter by media type
  - Search within media captions
  - Bulk operations (delete, move, tag)
  - Slideshow mode
  - Export media

- [ ] **DOC-011D**: Implement media uploads:
  - Drag-and-drop media upload
  - Progress indicators for large files
  - Multiple file selection
  - File type validation and conversion
  - Cloud storage integration (mock)
  - Local storage fallback

- [ ] **DOC-011E**: Add media annotations:
  - Image annotation with shapes and text
  - Video timestamp comments
  - Audio transcription with highlights
  - PDF annotations and bookmarks
  - Collaborative annotation layers

- [ ] **DOC-011F**: Create media optimization:
  - Image compression and resizing
  - Video transcoding for web
  - Audio compression
  - Thumbnail generation
  - Lazy loading for performance

- [ ] **DOC-011G**: Build `useMediaContent()` hook:
  - `uploadMedia(file, documentId)` mutation
  - `getMedia(documentId)` query
  - `deleteMedia(mediaId)` mutation
  - `updateMedia(mediaId, updates)` mutation

- [ ] **DOC-011H**: Implement media search:
  - Search within image OCR text
  - Video transcript search
  - Audio transcript search
  - Media metadata search
  - Content-based image retrieval

### Tests
- [ ] Media uploads work for all supported types
- [ ] Media viewers render correctly with controls
- [ ] Image annotations save and display properly
- [ ] Video transcoding produces web-compatible formats
- [ ] Media search returns relevant results
- [ ] Lazy loading improves performance

### Definition of Done
- Support for images, videos, audio, PDFs, and code
- Media viewers with full controls and features
- Media upload with progress tracking
- Annotation system for all media types
- Media optimization and compression
- Media search and organization

### Anti-Patterns
- ❌ Not optimizing media for web — slow loading
- ❌ Missing media controls — poor user experience
- ❌ Not handling large files — memory issues
- ❌ Not providing media search — hard to find content

---

## 📊 Task DOC-012: Split View & Advanced Layouts
**Priority:** 🟢 Low | **Est. Effort:** 2 hours | **Depends On:** DOC-002

### Related Files
`src/components/documents/SplitView.tsx` · `src/components/documents/LayoutManager.tsx` · `src/hooks/useDocumentLayout.ts`

### Subtasks

- [ ] **DOC-012A**: Create flexible layout system:
  ```ts
  // src/hooks/useDocumentLayout.ts
  interface LayoutConfig {
    type: 'single' | 'split-horizontal' | 'split-vertical' | 'grid'
    panels: PanelConfig[]
    resizable: boolean
    persistLayout: boolean
  }
  
  interface PanelConfig {
    id: string
    type: 'editor' | 'preview' | 'graph' | 'outline' | 'references'
    size: number | 'auto'
    minSize?: number
    maxSize?: number
    collapsible: boolean
  }
  ```

- [ ] **DOC-012B**: Build `SplitView` component:
  - Horizontal and vertical split layouts
  - Resizable panels with drag handles
  - Panel collapse and expand
  - Layout presets (editor-focused, preview-focused, balanced)
  - Keyboard shortcuts for layout switching

- [ ] **DOC-012C**: Create `LayoutManager` component:
  - Layout template selector
  - Custom layout builder
  - Layout persistence per document
  - Layout sharing between documents
  - Responsive layout adaptation

- [ ] **DOC-012D**: Implement advanced layouts:
  - Three-way split (editor, preview, references)
  - Quad view (editor, preview, graph, outline)
  - Tabbed panels within split areas
  - Floating panels for tools
  - Full-screen modes

- [ ] **DOC-012E**: Add layout interactions:
  - Drag to reorder panels
  - Drop zones for panel types
  - Context menu for panel options
  - Keyboard navigation between panels
  - Focus management

- [ ] **DOC-012F**: Create layout persistence:
  - Save layout preferences to localStorage
  - Per-document layout memory
  - Layout templates library
  - Import/export layout configurations
  - Reset to default layouts

- [ ] **DOC-012G**: Build `useDocumentLayout()` hook:
  - `setLayout(config)` mutation
  - `getLayout(documentId)` query
  - `saveLayoutTemplate(name, config)` mutation
  - `applyLayoutTemplate(templateId)` mutation

- [ ] **DOC-012H**: Implement layout analytics:
  - Layout usage statistics
  - Panel interaction tracking
  - Layout efficiency metrics
  - User preference patterns
  - Layout recommendation engine

### Tests
- [ ] Split views resize smoothly with proper constraints
- [ ] Layout persistence works across sessions
- [ ] Panel reordering updates layout correctly
- [ ] Responsive adaptation works on different screen sizes
- [ ] Layout templates apply correctly
- [ ] Keyboard navigation works between panels

### Definition of Done
- Flexible split view system with multiple layouts
- Resizable and collapsible panels
- Layout persistence and templates
- Advanced multi-panel layouts
- Comprehensive layout interactions
- Layout analytics and recommendations

### Anti-Patterns
- ❌ Fixed panel sizes — not adaptable to content
- ❌ Not persisting layouts — users lose preferences
- ❌ Missing responsive behavior — poor mobile experience
- ❌ Complex layout without presets — confusing for users

---

## 📊 Dependency Graph (Documents Module)

```
DOC-000 (Domain Model & Mock Data)
     │
DOC-001 (State Management & Templates)
     │
     ├── DOC-002 (Page Layout & Editor)
     │       │
     │       ├── DOC-003 (Bidirectional Linking & Graph)
     │       ├── DOC-004 (OCR Processing & Import)
     │       ├── DOC-005 (Semantic Search & Embeddings)
     │       ├── DOC-006 (AI Content Extraction)
     │       ├── DOC-007 (Question-Answering)
     │       ├── DOC-008 (Real-Time Collaboration)
     │       ├── DOC-009 (Version Control & History)
     │       ├── DOC-010 (Offline Support & Sync)
     │       ├── DOC-011 (Rich Content & Media)
     │       └── DOC-012 (Split View & Advanced Layouts)
```

---

## 🏁 Documents Module Completion Checklist

**Core Infrastructure:**
- [ ] Domain model with document types, metadata, and linking
- [ ] Mock factories and MSW handlers for all operations
- [ ] Zustand state management with atomic selectors
- [ ] Template library with 10+ built-in templates
- [ ] Query keys and mutation hooks with optimistic updates

**Editor & Viewing:**
- [ ] Markdown editor with syntax highlighting and toolbar
- [ ] Live preview with rendered Markdown and clickable links
- [ ] Split view with synchronized scrolling
- [ ] Document sidebar with search and filtering
- [ ] Auto-save with conflict detection

**Intelligence Features:**
- [ ] OCR processing for images and PDFs
- [ ] Semantic search with vector embeddings
- [ ] AI-powered entity, topic, and keyword extraction
- [ ] Question-answering with source citations
- [ ] Automatic tagging and categorization

**Collaboration & Organization:**
- [ ] Bidirectional linking with backlink discovery
- [ ] Graph visualization of document network
- [ ] Real-time collaboration with operational transforms
- [ ] Version control with diff visualization
- [ ] Offline support with sync engine

**Rich Content & Layouts:**
- [ ] Media support for images, videos, audio, PDFs
- [ ] Media annotations and optimization
- [ ] Flexible split view layouts
- [ ] Layout persistence and templates
- [ ] Advanced multi-panel configurations

**Quality & Performance:**
- [ ] All components follow WCAG 2.2 AA accessibility
- [ ] Motion respects reduced-motion preferences
- [ ] Search performance <500ms for 1000 documents
- [ ] Offline mode provides full functionality
- [ ] Comprehensive error handling and user feedback
