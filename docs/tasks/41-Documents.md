Based on research into Google Drive, Proton Drive, Docspell, Seafile, OneDrive, Box, and 2026 document storage best practices, here is a complete prioritized task list for the Document Storage module with AI intelligence, following the format established in the existing specs.

---

# # 41‑Documents — Personal AI Command Center Frontend (Regenerated v2)
> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.  
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.  
> **Source Research**: Google Drive (AI Overviews, Ask Gemini), Proton Drive (E2E encryption, secure sharing), Seafile 13.0 (metadata, AI, views), Docspell (OCR, ML tagging, full-text search), OneDrive (OCR, intelligent search), Box (AI Q&A, content management) — April 2026.

---

## 📋 Frontend Context (Module‑Wide Assumptions)
> All tasks in this module implicitly rely on the shared infrastructure defined in `00‑Foundations.md`.

## 🔬 Research Findings — Document Storage 2026

| Finding | Source | Action Required |
|---------|--------|-----------------|
| **AI Overviews & Ask Gemini**: Google Drive now surfaces AI overviews from search queries and supports conversational Q&A about files ("Ask Gemini") — transforming Drive from passive storage into an active knowledge base. | Google Workspace Blog, Apr 2026 | DOC-010: Implement AI search with overview summaries; DOC-011: Add conversational Q&A over documents |
| **End-to-End Encryption by Default**: Proton Drive offers zero-knowledge architecture where even the provider cannot read files. This is increasingly expected in modern storage apps. | Cyberinsider, Apr 2026 | DOC-012: Implement encryption indicators and optional client-side encryption |
| **OCR & Full-Text Search**: Every major platform (Docspell, OneDrive, Seafile) now supports OCR for scanned documents and images, enabling full-text search across all content types. | Docspell, OneDrive updates 2026 | DOC-005: Implement OCR pipeline; DOC-006: Full-text search with OCR integration |
| **Automated Tagging & Metadata**: ML-powered auto-tagging, date extraction, and correspondent detection are standard (Docspell, PaperAI). Reduces manual filing burden. | Docspell, PaperAI 2026 | DOC-007: AI-powered auto-tagging and metadata extraction |
| **Multiview Layouts**: Seafile 13.0 introduced Table, Kanban, Gallery, Map, Card, and Statistics views for document libraries. | Seafile Blog, Jan 2026 | DOC-003: Multiple view modes (Grid, List, Gallery, Table, Kanban) |
| **Hierarchical Tagging**: Seafile 13.0 supports multi-level tag hierarchies with drag-and-drop parent-child relationships. | Seafile Blog | DOC-007: Hierarchical tag system |
| **Secure Sharing with Expiry & Password**: Dropbox, Proton Drive, and enterprise platforms all support expiring links, password protection, and access revocation. | Dropbox Help, 2026 | DOC-009: Secure sharing with password, expiry, and permissions |
| **Version History & Rollback**: Complete version history with rollback, diff visualization, and change attribution is a baseline requirement. | Folderit, FlowWright 2026 | DOC-008: Version control with history, diff, and rollback |
| **Trash/Recycle Bin with Retention**: Soft-delete with 30-day retention, restore capability, and auto-purge. | DocuWare, Rally 2026 | DOC-004: Trash system with restore and retention |
| **Thumbnail Generation**: Automatic thumbnails for images, PDFs, videos, and Office documents. | Seafile Thumbnail Server | DOC-003: Thumbnail generation pipeline |
| **Offline Access & Sync**: PWA with IndexedDB for offline access, background sync on reconnect. | OneDrive Web, PWA patterns 2026 | DOC-014: Offline support with Dexie and sync queue |
| **Bulk Operations**: Batch upload, download, delete, move, and metadata editing. | Document360, LogicalDOC 2026 | DOC-004: Bulk operations throughout |
| **Audit Trail & Compliance**: Immutable audit logs tracking access, modifications, sharing, and AI interactions. | FileOrbis, Kiteworks 2026 | DOC-008: Audit trail logging |
| **Recycle Bin & Soft Delete**: Auto-remove after fixed retention period (typically 30 days), full restore capability. | Multiple DMS platforms | DOC-004: Trash system |
| **File Preview**: In-app preview for PDF, images, video, Office documents, code files. | Multiple platforms | DOC-003: Preview components |
| **Metadata & Custom Properties**: Structured metadata fields (dates, correspondents, status, custom). | Seafile Metadata Server | DOC-007: Metadata extraction & custom fields |
| **Storage Quota & Analytics**: Storage usage monitoring, per-folder/file size analytics, quota warnings. | Google Drive, Proton Drive | DOC-013: Storage analytics |

---

## 🧱 Cross-Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **DOC-C01** | State Management | Zustand `documentsSlice` for view mode, filters, selection, navigation state. TanStack Query for server/backend state. |
| **DOC-C02** | Data Persistence | Centralised `CommandCenterDB` stores: `docs_metadata`, `docs_queue`, `docs_versions`. Offline metadata cache, pending mutations, and local-only documents. Backend API for persistent storage. |
| **DOC-C03** | Content Model | Unified `Document` type supporting files, folders, and shared items. Properties: metadata, tags, versions, permissions. |
| **DOC-C04** | Virtualization | `@tanstack/react-virtual` for file lists with thousands of items. Grid dynamically calculates items per row. |
| **DOC-C05** | Drag & Drop | dnd-kit with shared `useDndSensors` for file/folder drag, move, and upload drop zones. |
| **DOC-C06** | Accessibility | WCAG 2.2 AA. File lists use `role="treegrid"` or `role="listbox"`. All actions keyboard-accessible. |
| **DOC-C07** | Motion | Grid items: Quiet tier (fade). Upload progress: Alive tier (pulse). Modal open: Alive tier (spring). |
| **DOC-C08** | AI Integration | Mock AI endpoints for classification, summarization, OCR, Q&A. Real implementation would use local LLM or API. |
| **DOC-C09** | Security | Permissions enforced at UI level. Encryption indicators shown. Sensitive actions require confirmation. HTML content rendered via shared `SanitizedHTML` component. |
| **DOC-C10** | Testing | All mutations follow optimistic update pattern with rollback. MSW handlers for all endpoints. |

### 🎯 Motion Tier Assignment

| Component | Tier | Technique |
|-----------|------|--------------------|
| File card/grid item entrance | **Quiet** | `opacity: 0→1`, 150ms fade, staggered by row |
| Upload progress bar | **Alive** | Pulsing gradient, spring width transition |
| Folder expand/collapse | **Quiet** | Height animation with `layout` prop |
| AI processing indicator | **Alive** | Animated gradient border, status pulse |
| Share dialog open | **Alive** | `scale: 0.95→1`, spring stiffness 400 damping 25 |
| Trash restore animation | **Alive** | Slide in from opacity 0, y: 8→0 |
| Search results | **Static** | Instant render |
| View mode switcher | **Quiet** | Active indicator slides via `layoutId` |

---

## 🗂️ Task DOC‑000: Document Domain Model, Schemas & Utilities
**Priority:** 🔴 High | **Est. Effort:** 1.5 hours | **Depends On:** FND‑001 (TypeScript Base)

### Related Files
- `src/domain/documents/types.ts` · `src/schemas/documents.ts` · `src/utils/documents.ts`

### Subtasks

- [ ] **DOC‑000A**: Define core types in `src/domain/documents/types.ts`:
  ```ts
  export type DocumentType = 'file' | 'folder'
  export type FileFormat = 'pdf' | 'image' | 'video' | 'audio' | 'document' | 'spreadsheet' | 'presentation' | 'code' | 'archive' | 'other'
  export type ViewMode = 'grid' | 'list' | 'gallery' | 'table' | 'kanban'
  export type SortField = 'name' | 'type' | 'size' | 'createdAt' | 'updatedAt' | 'owner'
  export type Permission = 'view' | 'comment' | 'edit' | 'owner'
  export type AIProcessingStatus = 'idle' | 'pending' | 'processing' | 'completed' | 'failed'

  export interface Document {
    id: string
    name: string
    type: DocumentType
    format?: FileFormat
    parentId: string | null       // null = root
    path: string[]                // breadcrumb of parent folder IDs
    size: number                  // bytes, 0 for folders
    mimeType: string
    thumbnailUrl?: string
    previewUrl?: string
    storageUrl: string            // actual file location
    createdAt: string
    updatedAt: string
    createdBy: string
    owner: string
    isStarred: boolean
    isTrashed: boolean
    trashedAt?: string
    autoPurgeAt?: string          // 30 days after trashed
    tags: string[]                // tag IDs
    metadata: DocumentMetadata
    permissions: DocumentPermission[]
    versions: DocumentVersion[]
    aiData?: AIDocumentData
    shareConfig?: ShareConfig
  }

  export interface DocumentMetadata {
    description?: string
    customProperties: Record<string, string | number | boolean | Date>
    extractedEntities?: Entity[]
    extractedDates?: Date[]
    extractedCorrespondents?: string[]
    language?: string
    pageCount?: number            // for PDFs/documents
    duration?: number             // seconds for audio/video
    dimensions?: { width: number; height: number }
  }

  export interface DocumentVersion {
    id: string
    versionNumber: number
    storageUrl: string
    size: number
    createdAt: string
    createdBy: string
    changeSummary?: string
  }

  export interface DocumentPermission {
    userId: string
    userName: string
    permission: Permission
    grantedAt: string
    grantedBy: string
  }

  export interface ShareConfig {
    isShared: boolean
    shareLink?: string
    linkPassword?: string
    linkExpiresAt?: string
    accessMode: 'public' | 'authenticated' | 'restricted'
    allowDownload: boolean
    viewCount: number
    lastAccessedAt?: string
  }

  export interface AIDocumentData {
    status: AIProcessingStatus
    summary?: string
    ocrText?: string
    suggestedTags?: string[]
    suggestedCategory?: string
    entities?: Entity[]
    qaHistory?: QAInteraction[]
    lastProcessedAt?: string
    processingError?: string
  }

  export interface Entity {
    text: string
    type: 'person' | 'organization' | 'location' | 'date' | 'money' | 'email' | 'phone' | 'url' | 'concept'
    confidence: number
  }

  export interface AuditLogEntry {
    id: string
    documentId: string
    action: 'created' | 'updated' | 'deleted' | 'viewed' | 'downloaded' | 'shared' | 'unshared' | 'restored' | 'permanently_deleted' | 'ai_processed' | 'comment_added'
    userId: string
    userName: string
    timestamp: string
    details?: Record<string, unknown>
    ipAddress?: string
  }
  ```

- [ ] **DOC‑000B**: Create Zod schemas in `src/schemas/documents.ts` mirroring all types with runtime validation.

- [ ] **DOC‑000C**: Create utilities in `src/utils/documents.ts`:
  - `formatFileSize(bytes: number): string` — "1.2 MB", "345 KB"
  - `formatDuration(seconds: number): string` — "2:34"
  - `getFileFormat(mimeType: string): FileFormat`
  - `getFileIcon(format: FileFormat): string` — Lucide icon name
  - `buildBreadcrumbPath(doc: Document, allDocs: Document[]): Document[]`
  - `canPerformAction(userId: string, doc: Document, action: string): boolean`
  - `sortDocuments(docs: Document[], field: SortField, order: 'asc' | 'desc'): Document[]`
  - `filterDocuments(docs: Document[], filters: DocumentFilters): Document[]`

- [ ] **[TEST] DOC‑000D**: Unit tests for all types, schemas, and utilities.

### Definition of Done
- All entities typed with Zod schemas; utilities handle edge cases (0 bytes, null parent, etc.)

---

## 🗂️ Task DOC‑001: Mock Data Layer & Query Contracts
**Priority:** 🔴 High | **Est. Effort:** 2 hours | **Depends On:** DOC‑000, FND‑004 (Testing), FND‑006 (TanStack Query)

### Related Files
- `src/mocks/factories/documents.ts` · `src/mocks/handlers/documents.ts` · `src/queries/documents.ts`

### Subtasks

- [ ] **DOC‑001A**: Create `src/mocks/factories/documents.ts`:
  - `createMockDocument(overrides?)` — generates file or folder with realistic metadata
  - `createMockFolder(name, children, overrides?)` — folder with nested children
  - `createMockFileTree(depth, filesPerFolder)` — generates complete folder hierarchy
  - `createMockShareConfig(overrides?)` — sharing configuration
  - `createMockVersion(overrides?)` — version entry
  - `createMockAuditLog(documentId, count)` — audit entries
  - `createMockAIData(status, overrides?)` — AI processing data with summaries and tags
  - Factory must produce: 5-10 folders at root, 3-5 levels deep, 50-200 files total, varied formats

- [ ] **DOC‑001B**: Create `src/mocks/handlers/documents.ts` with MSW:
  - `GET /api/documents?parentId=&view=&sort=&filter=` — paginated list
  - `GET /api/documents/:id` — single document detail
  - `POST /api/documents` — create file or folder
  - `PATCH /api/documents/:id` — update metadata, rename, move
  - `DELETE /api/documents/:id` — soft delete (move to trash)
  - `POST /api/documents/:id/restore` — restore from trash
  - `DELETE /api/documents/:id/permanent` — permanent delete
  - `POST /api/documents/upload` — file upload with progress simulation
  - `GET /api/documents/:id/download` — file download
  - `GET /api/documents/:id/versions` — version history
  - `POST /api/documents/:id/versions/:versionId/restore` — rollback
  - `POST /api/documents/:id/share` — create/update share link
  - `DELETE /api/documents/:id/share` — revoke share
  - `POST /api/documents/:id/permissions` — add permission
  - `DELETE /api/documents/:id/permissions/:userId` — remove permission
  - `POST /api/documents/:id/star` / `DELETE /api/documents/:id/star`
  - `POST /api/documents/bulk` — bulk delete, move, download
  - `GET /api/documents/trash` — trash contents
  - `GET /api/documents/search?q=&type=&tags=&date=` — search
  - `POST /api/documents/:id/ai/ocr` — OCR processing
  - `POST /api/documents/:id/ai/summarize` — AI summarization
  - `POST /api/documents/:id/ai/classify` — auto-classification
  - `POST /api/documents/:id/ai/qa` — Q&A over document
  - `GET /api/documents/:id/audit-log` — audit trail
  - `GET /api/documents/storage/quota` — storage quota info

- [ ] **DOC‑001C**: Create `src/queries/documents.ts` with Query Key Factory:
  ```ts
  export const documentKeys = {
    all: ['documents'] as const,
    list: (parentId: string | null, filters?: DocumentFilters) => [...documentKeys.all, 'list', parentId, filters] as const,
    detail: (id: string) => [...documentKeys.all, 'detail', id] as const,
    trash: () => [...documentKeys.all, 'trash'] as const,
    search: (query: string, filters?: DocumentFilters) => [...documentKeys.all, 'search', query, filters] as const,
    versions: (id: string) => [...documentKeys.detail(id), 'versions'] as const,
    auditLog: (id: string) => [...documentKeys.detail(id), 'audit'] as const,
    storage: () => [...documentKeys.all, 'storage'] as const,
    recent: () => [...documentKeys.all, 'recent'] as const,
    starred: () => [...documentKeys.all, 'starred'] as const,
    shared: () => [...documentKeys.all, 'shared'] as const,
  }
  ```

- [ ] **DOC‑001D**: Create mutation hooks with full optimistic pattern:
  - `useCreateFolder()`, `useUploadFile()`, `useRenameDocument()`, `useMoveDocument()`
  - `useDeleteDocument()`, `useRestoreDocument()`, `usePermanentDelete()`
  - `useStarDocument()`, `useUnstarDocument()`
  - `useShareDocument()`, `useRevokeShare()`, `useUpdatePermissions()`
  - `useBulkDelete()`, `useBulkMove()`, `useBulkDownload()`
  - `useOCRDocument()`, `useSummarizeDocument()`, `useClassifyDocument()`, `useQADocument()`
  - **Critical**: All mutations must use the shared `useOptimisticMutation()` wrapper.

- [ ] **[TEST] DOC‑001E**: Tests for factories, MSW handlers, query keys, and all mutation hooks.

### Definition of Done
- Mock data powers full file tree with realistic content. All CRUD + AI endpoints covered. Optimistic mutations with rollback.

---

## 🗂️ Task DOC‑002: Document State Management (Zustand Slice)
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** DOC‑001, FND‑005 (Zustand)

### Related Files
- `src/stores/slices/documentsSlice.ts`

### Subtasks

- [ ] **DOC‑002A**: Create `documentsSlice`:
  ```ts
  interface DocumentsSlice {
    // Navigation
    currentFolderId: string | null
    breadcrumbs: { id: string; name: string }[]
    // View
    viewMode: ViewMode
    sortField: SortField
    sortOrder: 'asc' | 'desc'
    // Selection
    selectedDocumentIds: string[]
    isBulkMode: boolean
    // Upload
    uploadQueue: UploadTask[]
    // Filters
    searchQuery: string
    filterFormat: FileFormat | 'all'
    filterTags: string[]
    filterDateRange: { start: string | null; end: string | null }
    // Panels
    detailPanelOpen: boolean
    detailDocumentId: string | null
    shareDialogOpen: boolean
    aiPanelOpen: boolean
    trashViewOpen: boolean
    // Actions
    navigateToFolder(id: string | null): void
    navigateUp(): void
    setViewMode(mode: ViewMode): void
    setSortField(field: SortField): void
    toggleSortOrder(): void
    toggleSelection(id: string): void
    selectAll(ids: string[]): void
    clearSelection(): void
    addToUploadQueue(files: File[]): void
    updateUploadTask(id: string, updates: Partial<UploadTask>): void
    removeFromUploadQueue(id: string): void
    clearCompletedUploads(): void
    setFilter(key, value): void
    clearFilters(): void
    openDetailPanel(id: string): void
    closeDetailPanel(): void
    openShareDialog(id: string): void
    closeShareDialog(): void
    openAIPanel(id: string): void
    closeAIPanel(): void
    toggleTrashView(): void
  }
  ```

- [ ] **DOC‑002B**: Export atomic selector hooks.
- [ ] **DOC‑002C**: Persist `viewMode`, `sortField`, `sortOrder` to localStorage. Never persist selection or upload queue.
- [ ] **[TEST] DOC‑002D**: Tests for all actions and selectors.

---

## 🗂️ Task DOC‑003: Document Browser — Layout, Views & Thumbnails
**Priority:** 🔴 High | **Est. Effort:** 4 hours | **Depends On:** DOC‑002, FND‑007 (Router)

### Related Files
- `src/pages/DocumentsPage.tsx` · `src/components/documents/DocumentBrowser.tsx`
- `src/components/documents/DocumentGrid.tsx` · `src/components/documents/DocumentList.tsx`
- `src/components/documents/DocumentCard.tsx` · `src/components/documents/DocumentRow.tsx`
- `src/components/documents/FolderTree.tsx` · `src/components/documents/BreadcrumbNav.tsx`
- `src/components/documents/FilePreview.tsx` · `src/components/documents/ThumbnailRenderer.tsx`

### Subtasks

- [ ] **DOC‑003A**: Configure routes: `/documents`, `/documents/folder/:folderId`, `/documents/shared`, `/documents/starred`, `/documents/recent`, `/documents/trash`.
- [ ] **DOC‑003B**: Build `DocumentsPage` layout: left sidebar (folder tree), top bar (breadcrumbs, search, view switcher, upload button), main content (file browser), right panel (detail/AI/share).
- [ ] **DOC‑003C**: Build `FolderTree` with expandable hierarchy, drag-and-drop for move, context menu (new folder, rename, delete, share).
- [ ] **DOC‑003D**: Build `BreadcrumbNav` with clickable segments, "root" icon, current folder name.
- [ ] **DOC‑003E**: Build `DocumentGrid` with `@tanstack/react-virtual`, dynamic items-per-row, progressive image loading with blur placeholders.
- [ ] **DOC‑003F**: Build `DocumentList` as table with columns: name, type, size, modified, owner, actions. Sortable headers.
- [ ] **DOC‑003G**: Build `DocumentCard` with thumbnail, name, type icon, star toggle, select checkbox, hover actions. Right-click context menu.
- [ ] **DOC‑003H**: Build `DocumentRow` for list view with same actions inline.
- [ ] **DOC‑003I**: Build `ThumbnailRenderer` for PDF (first page), images, video (frame at 50%), documents, code files (syntax-highlighted).
- [ ] **DOC‑003J**: Build `FilePreview` modal with zoom, navigation, download button. Support PDF, images, video, audio, text/code.
- [ ] **DOC‑003K**: Implement Gallery view for images (masonry or uniform grid, lightbox).
- [ ] **DOC‑003L**: Implement drag-and-drop file upload zone with progress indicators.
- [ ] **DOC‑003M**: Add "New Folder" inline creation, rename with inline editing (PROJ‑C08 pattern).
- [ ] **[TEST] DOC‑003N**: Tests for all view modes, virtualization, preview, folder navigation.

### Definition of Done
- Multiple view modes with virtualization. Thumbnails render for all supported formats. Drag-and-drop upload works.

---

## 🗂️ Task DOC‑004: File Operations — Upload, Download, Move, Delete & Trash
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** DOC‑003

### Related Files
- `src/components/documents/UploadManager.tsx` · `src/components/documents/TrashView.tsx`
- `src/components/documents/MoveDialog.tsx` · `src/components/documents/RenameDialog.tsx`
- `src/hooks/useFileUpload.ts` · `src/hooks/useFileDownload.ts`

### Subtasks

- [ ] **DOC‑004A**: Build `UploadManager`: queue panel showing active/completed/failed uploads, progress bars, cancel, retry. Folder upload support. Size validation (max per file, max total).
- [ ] **DOC‑004B**: Implement `useFileUpload` with chunked upload simulation, progress tracking, error handling, and optimistic file listing update.
- [ ] **DOC‑004C**: Implement `useFileDownload` with progress, background download, ZIP bundling for multi-file download.
- [ ] **DOC‑004D**: Build `MoveDialog`: folder tree selector, breadcrumb navigation, "Move here" button. Optimistic move with rollback.
- [ ] **DOC‑004E**: Build `RenameDialog`: inline validation, name sanitization, conflict detection.
- [ ] **DOC‑004F**: Implement delete flow: single delete → confirmation toast with undo; bulk delete → confirmation dialog. Both move to trash (soft delete).
- [ ] **DOC‑004G**: Build `TrashView`: list of trashed items with "days remaining" indicator, restore button, permanent delete button, "Empty Trash" with confirmation.
- [ ] **DOC‑004H**: Implement auto-purge: items in trash > 30 days auto-permanently-deleted with notification.
- [ ] **DOC‑004I**: Implement bulk operations bar: when items selected, show "Move", "Download", "Delete", "Add Tags", "Change Permissions" actions.
- [ ] **DOC‑004J**: Star/unstar with optimistic toggle, synced to starred filter view.
- [ ] **[TEST] DOC‑004K**: Tests for upload, download, move, rename, delete, restore, bulk operations.

### Definition of Done
- Full file lifecycle managed. Trash with 30-day retention. Undo delete. Bulk operations throughout.

---

## 🗂️ Task DOC‑005: OCR Processing Pipeline
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** DOC‑001, DOC‑003

### Related Files
- `src/components/documents/OCRPanel.tsx` · `src/lib/ocrEngine.ts` · `src/hooks/useOCR.ts`

### Subtasks

- [ ] **DOC‑005A**: Create `src/lib/ocrEngine.ts` with `processDocument(file)`, supporting PDF, images (JPG, PNG, TIFF), with language detection and multi-language support.
- [ ] **DOC‑005B**: Implement Tesseract.js integration (mock for MVP, real for production).
- [ ] **DOC‑005C**: Build `OCRPanel`: "Run OCR" button, language selector, progress indicator, extracted text preview with confidence highlighting, "Copy text" / "Add to metadata" actions.
- [ ] **DOC‑005D**: Implement `useOCR` hook with progress tracking and error handling.
- [ ] **DOC‑005E**: Auto-trigger OCR on upload for image/PDF files (configurable in settings).
- [ ] **DOC‑005F**: OCR results feed into full-text search index.
- [ ] **[TEST] DOC‑005G**: Tests for OCR pipeline, progress tracking, error handling.

### Definition of Done
- OCR available for all image/PDF documents. Results searchable. Progress visible to user.

---

## 🗂️ Task DOC‑006: Full-Text Search & Advanced Filtering
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** DOC‑003, DOC‑005

### Related Files
- `src/components/documents/SearchBar.tsx` · `src/components/documents/SearchResults.tsx`
- `src/components/documents/FilterPanel.tsx` · `src/hooks/useDocumentSearch.ts`

### Subtasks

- [ ] **DOC‑006A**: Build `SearchBar`: global search input (⌘K), debounced 300ms, search-as-you-type with suggestions dropdown.
- [ ] **DOC‑006B**: Implement `useDocumentSearch`: full-text search across name, content, OCR text, metadata, and tags. Fuzzy matching. Results ranked by relevance.
- [ ] **DOC‑006C**: Build `SearchResults`: grouped by type (files, folders), highlighted match terms with `<mark>`, breadcrumb context, "Open location" action.
- [ ] **DOC‑006D**: Build `FilterPanel`: format filter (chips), tag filter (multi-select), date range picker, size range filter, owner filter, "Clear all" button.
- [ ] **DOC‑006E**: Implement filter URL sync for shareable filtered views.
- [ ] **DOC‑006F**: Saved searches: save current filter/search as named view, list in sidebar.
- [ ] **DOC‑006G**: Recent searches stored in localStorage (last 10).
- [ ] **DOC‑006H**: Keyboard navigation in search results (ArrowUp/Down, Enter, Escape).
- [ ] **[TEST] DOC‑006I**: Tests for search accuracy, highlighting, filters, saved searches.

### Definition of Done
- Full-text search across all document content including OCR. Faceted filtering. Saved searches.

---

## 🗂️ Task DOC‑007: AI-Powered Auto-Tagging, Classification & Metadata Extraction
**Priority:** 🟠 Medium | **Est. Effort:** 3 hours | **Depends On:** DOC‑003, DOC‑005

### Related Files
- `src/components/documents/AIClassification.tsx` · `src/components/documents/TagManager.tsx`
- `src/components/documents/MetadataEditor.tsx` · `src/hooks/useAIClassification.ts`

### Subtasks

- [ ] **DOC‑007A**: Build `TagManager`: create/edit/delete tags, color assignment, hierarchical structure (parent-child drag), tag search, usage counts.
- [ ] **DOC‑007B**: Implement `useAIClassification` hook:
  - Auto-suggest tags based on document content and OCR text
  - Auto-detect document category (invoice, contract, report, receipt, etc.)
  - Extract entities: people, organizations, dates, amounts, emails, phones
  - Extract correspondents and document dates
  - Learning from user corrections
- [ ] **DOC‑007C**: Build `AIClassification` panel: show AI suggestions with confidence scores, accept/reject/edit tags, "Apply All" bulk action, reprocess button.
- [ ] **DOC‑007D**: Build `MetadataEditor`: view/edit custom properties, extracted entities, description, document date, correspondents.
- [ ] **DOC‑007E**: Auto-classify on upload (configurable per folder).
- [ ] **DOC‑007F**: Custom property templates: define metadata schemas per folder (e.g., "Invoices" folder has "Invoice #", "Amount", "Vendor" fields).
- [ ] **[TEST] DOC‑007G**: Tests for tag CRUD, AI suggestions, entity extraction, metadata editing.

### Definition of Done
- AI auto-tagging and classification with user feedback loop. Hierarchical tags. Custom metadata schemas per folder.

---

## 🗂️ Task DOC‑008: Version Control, Audit Trail & Document History
**Priority:** 🟠 Medium | **Est. Effort:** 2.5 hours | **Depends On:** DOC‑003

### Related Files
- `src/components/documents/VersionHistory.tsx` · `src/components/documents/AuditLog.tsx`
- `src/components/documents/DiffViewer.tsx` · `src/hooks/useVersionControl.ts`

### Subtasks

- [ ] **DOC‑008A**: Build `VersionHistory`: timeline of versions with version number, date, user, size, change summary. "Restore this version" action, "Download this version" action.
- [ ] **DOC‑008B**: Build `DiffViewer`: side-by-side text diff for text/code files, metadata comparison for other types.
- [ ] **DOC‑008C**: Implement automatic version creation on file upload/replace edits.
- [ ] **DOC‑008D**: Version retention: keep last 100 versions, configurable limit.
- [ ] **DOC‑008E**: Build `AuditLog`: filterable log (action type, user, date range), export (CSV/JSON), real-time updates. Actions tracked: created, updated, deleted, viewed, downloaded, shared, unshared, restored, permanently deleted, AI processed, comment added.
- [ ] **[TEST] DOC‑008F**: Tests for version restore, diff rendering, audit log filtering.

### Definition of Done
- Complete version history with restore. Comprehensive audit trail. Diff visualization for text files.

---

## 🗂️ Task DOC‑009: Secure Sharing & Permissions
**Priority:** 🔴 High | **Est. Effort:** 3 hours | **Depends On:** DOC‑003

### Related Files
- `src/components/documents/ShareDialog.tsx` · `src/components/documents/PermissionsPanel.tsx`
- `src/hooks/useDocumentSharing.ts`

### Subtasks

- [ ] **DOC‑009A**: Build `ShareDialog`: generate share link, copy to clipboard, access mode selector (public, authenticated, restricted), password protection toggle + input, expiration date picker, "Allow download" toggle, view count display, revoke button.
- [ ] **DOC‑009B**: Build `PermissionsPanel`: list of users with access + permission level, add user (email input + permission dropdown), change permission, remove access, inherited permissions indicator (from parent folder).
- [ ] **DOC‑009C**: Implement `useDocumentSharing` hook with optimistic mutations.
- [ ] **DOC‑009D**: Share link validation: if link expired or revoked, show "Link expired" page instead of content.
- [ ] **DOC‑009E**: "Shared with me" filter view showing all documents shared with current user.
- [ ] **DOC‑009F**: Notification on share: toast "Link copied" or "Invitation sent to user@email.com".
- [ ] **DOC‑009G**: Inherited permissions from parent folders (optional, can be overridden).
- [ ] **[TEST] DOC‑009H**: Tests for share creation, password enforcement, expiration, permissions management, revocation.

### Definition of Done
- Secure sharing with password, expiry, and granular permissions. Shared-with-me view. Link access lifecycle management.

---

## 🗂️ Task DOC‑010: AI-Powered Document Q&A & Summarization
**Priority:** 🟠 Medium | **Est. Effort:** 3 hours | **Depends On:** DOC‑003, DOC‑005

### Related Files
- `src/components/documents/AIPanel.tsx` · `src/components/documents/DocumentQA.tsx`
- `src/components/documents/DocumentSummary.tsx` · `src/hooks/useDocumentAI.ts`

### Subtasks

- [ ] **DOC‑010A**: Build `AIPanel` (right panel): tabs for Summary, Q&A, Classification.
- [ ] **DOC‑010B**: Build `DocumentSummary`: generate summary button, summary display (3-5 sentences), key points list, regenerate with different length (brief/detailed).
- [ ] **DOC‑010C**: Build `DocumentQA`: chat interface, question input, streaming answers, source citations ("From page 3, paragraph 2"), suggested questions, conversation history.
- [ ] **DOC‑010D**: Implement "Ask Gemini"-style global search Q&A: ask natural language questions across all documents, get AI-generated answer with linked source documents.
- [ ] **DOC‑010E**: AI Overviews for search results: when searching, show AI-generated summary at top of results.
- [ ] **DOC‑010F**: Implement `useDocumentAI` hook with SSE streaming for Q&A.
- [ ] **DOC‑010G**: Citation linking: clicking a citation opens the source document at the referenced location.
- [ ] **[TEST] DOC‑010H**: Tests for summarization, Q&A streaming, citation accuracy, AI search overviews.

### Definition of Done
- Conversational Q&A over documents. AI summaries. Global AI search overviews. Streaming responses.

---

## 🗂️ Task DOC‑011: Real-Time Collaboration (Comments & Annotations)
**Priority:** 🟢 Low | **Est. Effort:** 1.5 hours | **Depends On:** DOC‑003

### Related Files
- `src/components/documents/CommentPanel.tsx` · `src/components/documents/CommentThread.tsx`
- `src/hooks/useDocumentComments.ts` · `src/lib/collaborativeDocument.ts`

### Subtasks

- [ ] **DOC‑011A**: Build `CommentPanel`: thread list, new comment input, @mention autocomplete, reply support, resolve/reopen, delete.
- [ ] **DOC‑011B**: Build `CommentThread`: nested replies, timestamps, user avatars, edit own comments.
- [ ] **DOC‑011C**: Implement `useDocumentComments` hook with optimistic add/edit/delete.
- [ ] **DOC‑011D**: Comment notifications: email/in-app notification when mentioned.
- [ ] **DOC‑011E**: Document-level annotations: highlight text, attach comment to selection using Yjs `Y.Text` for collaborative text editing.
- [ ] **DOC‑011F**: Comment activity in audit log.
- [ ] **DOC‑011G**: Implement collaborative document editing with Yjs:
  - Use `Y.Text` for shared document content with real-time synchronization
  - Integrate `y-indexeddb` for local persistence and offline support
  - Add cursor awareness overlay showing other users' cursor positions and selections
  - Implement conflict-free editing using CRDT-based approach
- [ ] **[TEST] DOC‑011H**: Tests for comment CRUD, @mentions, threading, and Yjs collaborative editing.

### Definition of Done
- Comment system with threading and @mentions. Annotations linked to document selections. Real-time collaborative document editing using Yjs Y.Text with y-indexeddb persistence and cursor awareness.

---

## 🗂️ Task DOC‑012: Encryption & Security Indicators
**Priority:** 🟠 Medium | **Est. Effort:** 1.5 hours | **Depends On:** DOC‑003

### Related Files
- `src/components/documents/EncryptionBadge.tsx` · `src/components/documents/SecurityInfo.tsx`
- `src/lib/encryption.ts`

### Subtasks

- [ ] **DOC‑012A**: Build `EncryptionBadge`: lock icon + "End-to-End Encrypted" / "Encrypted at Rest" / "Not Encrypted" indicator on file detail.
- [ ] **DOC‑012B**: Build `SecurityInfo` panel: encryption type, key management info, last security audit date.
- [ ] **DOC‑012C**: Create `src/lib/encryption.ts` with mock client-side encryption/decryption using Web Crypto API (SubtleCrypto).
- [ ] **DOC‑012D**: Encryption toggle in settings: "Enable client-side encryption for sensitive documents".
- [ ] **DOC‑012E**: Encrypted file download flow: decrypt in browser before download.
- [ ] **[TEST] DOC‑012F**: Tests for encryption indicators, mock encrypt/decrypt roundtrip.

### Definition of Done
- Encryption status visible on all documents. Mock client-side encryption available for sensitive files.

---

## 🗂️ Task DOC‑013: Storage Analytics & Quota Management
**Priority:** 🟢 Low | **Est. Effort:** 2 hours | **Depends On:** DOC‑003

### Related Files
- `src/components/documents/StorageAnalytics.tsx` · `src/components/documents/StorageQuota.tsx`

### Subtasks

- [ ] **DOC‑013A**: Build `StorageQuota`: progress bar showing used vs total, breakdown by file type (chart), "Upgrade storage" CTA (mock), quota warning at 80%/90%/100%.
- [ ] **DOC‑013B**: Build `StorageAnalytics`: largest files list, most active folders, storage growth over time chart, duplicate file detection, "Clean up" suggestions.
- [ ] **DOC‑013C**: Per-folder storage usage in folder properties.
- [ ] **DOC‑013D**: Duplicate file detection: find files with same name + size, suggest cleanup.
- [ ] **[TEST] DOC‑013E**: Tests for quota calculation, analytics accuracy, duplicate detection.

### Definition of Done
- Storage monitoring with quota warnings. Analytics dashboard. Duplicate detection.

---

## 🗂️ Task DOC‑014: Offline Support & Sync Engine
**Priority:** 🟠 Medium | **Est. Effort:** 2.5 hours | **Depends On:** DOC‑001, DOC‑004

### Related Files
- `src/lib/db/documents.ts` · `src/hooks/useOfflineDocuments.ts` · `src/components/documents/OfflineStatusBar.tsx`

### Subtasks

- [ ] **DOC‑014A**: Use centralized CommandCenterDB for documents data:
  ```ts
  // src/hooks/useOfflineDocuments.ts
  import { db } from '@/lib/db'  // Centralized CommandCenterDB

  export function useOfflineDocuments() {
    const metadata = useLiveQuery(() => db.docs_metadata.toArray(), [])
    const queue = useLiveQuery(() => db.docs_queue.toArray(), [])
    const versions = useLiveQuery(() => db.docs_versions.toArray(), [])
    
    const saveMetadata = async (doc: DocumentMetadata) => {
      await db.docs_metadata.put(doc)
    }
    
    const queueAction = async (action: QueuedDocumentAction) => {
      await db.docs_queue.put(action)
    }
    
    const saveVersion = async (version: DocumentVersion) => {
      await db.docs_versions.put(version)
    }
    
    return { metadata, queue, versions, saveMetadata, queueAction, saveVersion }
  }
  ```
- [ ] **DOC‑014B**: Implement `useOfflineDocuments`: read from Dexie when offline, queue mutations, sync on reconnect.
- [ ] **DOC‑014C**: Sync engine: process pending mutations FIFO, conflict resolution (last-write-wins), retry with exponential backoff.
- [ ] **DOC‑014D**: Build `OfflineStatusBar`: connection indicator, pending mutation count, manual sync button, last sync timestamp.
- [ ] **DOC‑014E**: Offline file access: mark files as "available offline", download and store locally, serve from IndexedDB when offline.
- [ ] **DOC‑014F**: PWA service worker for caching UI shell and recently accessed metadata.
- [ ] **[TEST] DOC‑014G**: Tests for offline read/write, sync queue, conflict resolution, reconnection.

### Definition of Done
- Documents accessible offline. Mutations queue and sync. Offline status visible.

---

## 🗂️ Task DOC‑015: Import, Export & Data Portability
**Priority:** 🟢 Low | **Est. Effort:** 1.5 hours | **Depends On:** DOC‑004

### Related Files
- `src/components/documents/ImportExport.tsx`

### Subtasks

- [ ] **DOC‑015A**: Export: select items or entire folder, ZIP download with progress, format selection (original, PDF, CSV for metadata).
- [ ] **DOC‑015B**: Import: batch file upload with folder structure preservation, CSV import for metadata, conflict resolution (skip, rename, overwrite).
- [ ] **DOC‑015C**: Data portability: "Download all my data" button (GDPR), generates complete export including metadata, versions, audit log.
- [ ] **DOC‑015D**: Export as archive with metadata JSON file alongside original files.
- [ ] **[TEST] DOC‑015E**: Tests for export ZIP generation, import with conflict handling.

### Definition of Done
- Import/export with progress. GDPR data portability. Folder structure preservation.

---

## 🗂️ Task DOC‑016: Route Configuration, Page Shell & Integration
**Priority:** 🔴 High | **Est. Effort:** 1 hour | **Depends On:** DOC‑002, FND‑007

### Related Files
- `src/pages/DocumentsPage.tsx` · `src/router/routes.ts` · `src/layouts/AppShell.tsx`

### Subtasks

- [ ] **DOC‑016A**: Configure all routes with lazy loading, loader prefetching.
- [ ] **DOC‑016B**: Add sidebar nav item for Documents with storage usage badge.
- [ ] **DOC‑016C**: Add global keyboard shortcut: `⌘Shift+D` opens Documents.
- [ ] **DOC‑016D**: Wrap page in Suspense with skeleton loader and ErrorBoundary.
- [ ] **[TEST] DOC‑016E**: Route rendering, navigation, keyboard shortcut.

---

## 🗂️ Task DOC‑017: Quality Gates, Testing & Accessibility
**Priority:** 🔴 High | **Est. Effort:** 2.5 hours | **Depends On:** All DOC tasks

### Subtasks

- [ ] **DOC‑017A**: Unit tests for all domain utilities, schemas, selectors.
- [ ] **DOC‑017B**: Component tests for all views, dialogs, panels.
- [ ] **DOC‑017C**: Integration tests for full CRUD flows, sharing, AI features.
- [ ] **DOC‑017D**: E2E tests: upload file → navigate folder → search → share → trash → restore.
- [ ] **DOC‑017E**: Accessibility audit: keyboard navigation, screen reader, focus management, color contrast.
- [ ] **DOC‑017F**: Performance: virtualized grid with 10,000+ files, search response < 500ms.
- [ ] **DOC‑017G**: Verify all motion respects `useReducedMotion()`.
- [ ] **DOC‑017H**: Zero axe violations across all views.

### Definition of Done
- Full test coverage. WCAG 2.2 AA compliance. Performance targets met.

---

## 📊 Dependency Graph

```
DOC‑000 (Domain Model & Utilities)
     │
DOC‑001 (Mock Data & Queries)
     │
DOC‑002 (State Management)
     │
DOC‑003 (Document Browser)
     │
     ├── DOC‑004 (File Operations & Trash)
     │
     ├── DOC‑005 (OCR Pipeline)
     │       │
     │       └── DOC‑006 (Full-Text Search)
     │
     ├── DOC‑007 (AI Auto-Tagging & Metadata)
     │
     ├── DOC‑008 (Version Control & Audit)
     │
     ├── DOC‑009 (Secure Sharing & Permissions)
     │
     ├── DOC‑010 (AI Q&A & Summarization)
     │
     ├── DOC‑011 (Comments & Collaboration)
     │
     ├── DOC‑012 (Encryption & Security)
     │
     ├── DOC‑013 (Storage Analytics)
     │
     ├── DOC‑014 (Offline Support)
     │
     ├── DOC‑015 (Import/Export)
     │
     └── DOC‑016 (Route & Integration)

DOC‑017 (Quality Gates) — depends on ALL
```

---

## 🏁 Document Storage Module Completion Checklist

**Foundation:**
- [ ] Domain model with document, folder, version, permissions, audit, AI types
- [ ] Mock data with full file tree, realistic formats, sharing, and AI data
- [ ] MSW handlers for all CRUD + AI + sharing + search + trash endpoints
- [ ] Query key factory and optimistic mutation hooks
- [ ] Zustand slice with navigation, selection, upload queue, filters

**Browser & Views:**
- [ ] Grid, list, gallery, table views with virtualization
- [ ] Thumbnails for PDF, images, video, documents
- [ ] File preview modal with zoom and navigation
- [ ] Folder tree with drag-and-drop and context menus
- [ ] Breadcrumb navigation

**File Operations:**
- [ ] Upload with progress, folder upload, drag-and-drop
- [ ] Download with progress, ZIP bundling
- [ ] Move, rename with optimistic updates
- [ ] Delete to trash with undo, permanent delete, auto-purge after 30 days
- [ ] Bulk operations (move, delete, download, tag)
- [ ] Star/unstar

**AI Intelligence:**
- [ ] OCR for images and PDFs with progress and results
- [ ] AI auto-tagging and classification
- [ ] Entity and metadata extraction
- [ ] Document summarization
- [ ] Conversational Q&A over documents with citations
- [ ] AI search overviews

**Organization:**
- [ ] Full-text search across names, content, OCR text, metadata
- [ ] Advanced filters (format, tags, date, size, owner)
- [ ] Hierarchical tags
- [ ] Custom metadata schemas per folder
- [ ] Saved searches

**Sharing & Collaboration:**
- [ ] Share links with password, expiration, access mode
- [ ] Granular permissions (view, comment, edit, owner)
- [ ] "Shared with me" filter view
- [ ] Comments with threading and @mentions
- [ ] Document annotations

**Security & Compliance:**
- [ ] Encryption indicators (E2E, at rest)
- [ ] Version history with restore and diff
- [ ] Audit trail with filtering and export
- [ ] Permission enforcement

**Storage & Offline:**
- [ ] Storage quota monitoring with analytics
- [ ] Duplicate detection and cleanup suggestions
- [ ] Offline access with Dexie
- [ ] Sync engine with conflict resolution
- [ ] PWA service worker

**Import/Export:**
- [ ] Export to ZIP with metadata
- [ ] Import with folder structure preservation
- [ ] GDPR data portability

**Quality:**
- [ ] All tests passing
- [ ] WCAG 2.2 AA accessibility
- [ ] Performance targets met
- [ ] Motion preferences respected