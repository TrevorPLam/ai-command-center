# 30‑Email — Personal AI Command Center Frontend

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

## 📐 Reasoning Memo: Email as a Core Command Center Module

Email remains the primary asynchronous communication protocol for professional work. Integrating external email accounts directly into the Command Center creates a unified workflow where users can manage AI agents, projects, calendar, and communications without context switching.

### Key Architectural Decisions

**Unified Inbox vs. Account Silos**: Modern email clients (Edison, Spark, Missive) lead with a unified inbox as the default view, with account filtering available as a secondary control. This matches the Command Center's "everything in one place" philosophy.

**Sync Strategy**: Email sync is complex. This module follows an "offline-first with smart sync" approach using a local cache (Dexie) with background synchronization, similar to the Budget and News modules.

**Security-First Design**: Email credentials and tokens must never be stored in localStorage. The module uses a secure token vault pattern with encrypted at-rest storage.

**Integration Points**: Email connects to other modules:
- **Projects**: Convert emails to tasks, link email threads to projects
- **Calendar**: Auto-detect meeting invites, add to calendar
- **Budget**: Receipt scanning, expense categorization from purchase emails
- **Chat**: Summarize long threads via AI, email-to-chat bridging

---

## 🔬 Research Findings — Email Module

| Finding | Source | Action Required |
|---------|--------|-----------------|
| **Unified inbox is the expected default** in modern clients (Spark, Edison, Missive). Users can toggle account-specific views when needed. | Edison Mail, Spark 2026 | EMAIL-001: Unified inbox as default view; account filtering as secondary |
| **Snooze is a core productivity feature** — temporarily remove emails from inbox until a specific time or condition. | Mailbird, Edison research | EMAIL-003: Snooze with custom times and smart suggestions (tomorrow morning, next week) |
| **Send Later (scheduled send)** allows composing now, delivering at optimal times. Critical for professional communication. | Mailbird 2026 | EMAIL-003: Built-in send later with timezone awareness |
| **Focused/Important inbox** uses AI/rules to surface priority emails vs. newsletters/promotions. | Spark, Gmail API | EMAIL-002: Focused inbox toggle with trainable importance scoring |
| **Conversation threading** is non-negotiable for modern email. Flat email lists cause significant productivity loss. | All modern clients | EMAIL-003: Threaded conversation view as default |
| **Undo Send** requires a brief delay (5-30 seconds) before actual transmission. | Gmail, Outlook patterns | EMAIL-003: Configurable undo window with visual countdown |
| **Smart Compose/Reply** using AI to suggest completions is standard in 2026. | Gmail Smart Compose, Superhuman | EMAIL-006: AI-powered compose suggestions via local LLM integration |
| **Keyboard shortcuts** (Gmail/Outlook compatible) are essential for power users. | Superhuman, Spark | EMAIL-007: Full keyboard shortcut system with help overlay |
| **Multiple account types** must be supported: Gmail (OAuth), Outlook (Graph API), Yahoo, IMAP/SMTP generic. | Edison, Thunderbird | EMAIL-000: OAuth + IMAP support in connection layer |
| **Offline support** requires local storage of recent emails with background sync when reconnected. | Service Worker patterns | EMAIL-000: Dexie-based offline cache with sync queue |
| **Attachment handling** needs preview for common formats, virus scanning indicator, cloud upload integration. | Security best practices | EMAIL-004: Attachment preview, size limits, security indicators |
| **Search** must be fast across all accounts with filters (from, to, date, has:attachment, is:unread). | Gmail search operators | EMAIL-005: Full-text search with Gmail-style operators |
| **Drag-and-drop** for organizing emails into folders, applying labels, and creating calendar events. | Modern web UX | EMAIL-002: dnd-kit integration for email organization |

---

## 🧱 Cross-Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **EMAIL-C01** | State Management | Zustand `emailSlice` for accounts, active view, filters, selected thread, compose state. Separate secure storage for OAuth tokens. |
| **EMAIL-C02** | Data Fetching | Background sync via service worker. Optimistic mutations for actions (archive, delete, mark read). `staleTime: 5min` for inbox, `gcTime: 1hour`. |
| **EMAIL-C03** | Offline Support | Dexie for email cache, pending actions queue, and attachment blobs. Full read capability offline; actions queue for retry. |
| **EMAIL-C04** | Security | Tokens in secure cookie-backed storage, never localStorage. XSS protection for HTML email rendering via DOMPurify. |
| **EMAIL-C05** | Virtualization | `useVirtualizer` for long email lists. Threaded view renders conversation with proper scroll handling. |
| **EMAIL-C06** | Accessibility | ARIA grid pattern for email list, proper labels for action buttons, keyboard navigation for all features. |
| **EMAIL-C07** | Integration | Link to Projects (create task from email), Calendar (detect invites), Chat (summarize thread), Budget (receipt extraction). |
| **EMAIL-C08** | Performance | Lazy load email content bodies. Thumbnail generation for attachments. Debounced search with `useDeferredValue`. |
| **EMAIL-C09** | Motion | Respect `prefers-reduced-motion`. Subtle transitions for thread expansion, compose slide-up. |
| **EMAIL-C10** | Error Handling | Offline indicators, sync failure banners, retry mechanisms for failed sends. |

### 🎯 Motion Tier Assignment

| Component | Tier | Technique |
|-----------|------|--------------------|
| Email list scroll | **Static** | No animation — virtualized rows |
| Thread expansion | **Quiet** | Height transition 150ms |
| Compose window open | **Alive** | Slide up from bottom, spring physics |
| Snooze toast | **Quiet** | Slide in from bottom, auto-dismiss |
| Undo send countdown | **Alive** | Progress bar with subtle pulse |
| Account switcher | **Quiet** | Opacity fade 150ms |
| Attachment upload | **Alive** | Progress bar with pulse |
| Focused inbox toggle | **Quiet** | Background color fade |

---


## 🗂️ Task EMAIL-000: Email Domain Model, Security & Mock Data

**Priority:** 🔴 High
**Est. Effort:** 2 hours
**Depends On:** FND-004 (Testing), FND-006 (TanStack Query)

### Related Files
`src/schemas/email.ts` · `src/mocks/factories/email.ts` · `src/mocks/handlers/email.ts` · `src/lib/emailSecurity.ts` · `src/queries/email.ts`

### Subtasks

**Schemas & Types:**
- [ ] **EMAIL-000A**: Create `src/schemas/email.ts` with Zod schemas:
  - `EmailAccount`: `{ id, provider: 'gmail'|'outlook'|'yahoo'|'imap', email, displayName, isConnected, lastSyncedAt, settings }`
  - `EmailMessage`: `{ id, threadId, accountId, from, to, cc, bcc, subject, bodyHtml, bodyText, date, isRead, isStarred, labels, attachments, importance }`
  - `EmailThread`: `{ id, accountId, subject, participants, messages[], lastMessageDate, isRead, isStarred, labels, hasAttachments }`
  - `EmailLabel`: `{ id, accountId, name, color, type: 'system'|'user' }`
  - `EmailAttachment`: `{ id, filename, mimeType, size, contentId, isInline }`
  - `ComposeDraft`: `{ id, accountId, to, cc, bcc, subject, body, attachments, sendAt?, createdAt }`
  - Derive TypeScript types via `z.infer`

**Security Layer:**
- [ ] **EMAIL-000B**: Create `src/lib/emailSecurity.ts`:
  - `SecureTokenVault` class for OAuth token storage
  - Use `SubtleCrypto` for at-rest encryption with user-derived key
  - `storeToken(accountId, token)`, `retrieveToken(accountId)`, `clearToken(accountId)`
  - Never expose tokens in Zustand (only connection status)

**Factories:**
- [ ] **EMAIL-000C**: Create `src/mocks/factories/email.ts`:
  - `createMockAccount(overrides?)`: Gmail, Outlook, Yahoo, IMAP samples
  - `createMockThread(overrides?)`: conversation with 1-5 messages
  - `createMockMessage(overrides?)`: with realistic headers, HTML body, attachments
  - `createMockLabel(overrides?)`: inbox, sent, drafts, custom labels
  - `createMockAttachment(overrides?)`: PDF, image, doc types
  - `createMockInbox(count: 50)`: varied mix of read/unread, starred, labeled

**MSW Handlers:**
- [ ] **EMAIL-000D**: Create `src/mocks/handlers/email.ts`:
  - `GET /api/email/accounts` → list connected accounts
  - `POST /api/email/accounts/connect` → OAuth flow stub (returns mock token)
  - `DELETE /api/email/accounts/:id` → disconnect
  - `GET /api/email/inbox` → unified inbox with account filter support
  - `GET /api/email/threads/:id` → full thread with messages
  - `GET /api/email/threads/:id/messages/:messageId/body` → message body (lazy loaded)
  - `POST /api/email/messages` → send email (returns mock sent message)
  - `POST /api/email/drafts` → save draft
  - `PATCH /api/email/messages/:id` → update (read, starred, labels)
  - `POST /api/email/messages/:id/snooze` → snooze until date
  - `DELETE /api/email/messages/:id` → trash
  - `POST /api/email/sync` → trigger sync

**Query Layer:**
- [ ] **EMAIL-000E**: Create `src/queries/email.ts` with Query Key Factory:
  ```ts
  export const emailKeys = {
    all: ['email'] as const,
    accounts: () => [...emailKeys.all, 'accounts'] as const,
    inbox: (filters: InboxFilters) => [...emailKeys.all, 'inbox', filters] as const,
    thread: (id: string) => [...emailKeys.all, 'thread', id] as const,
    drafts: () => [...emailKeys.all, 'drafts'] as const,
    labels: (accountId: string) => [...emailKeys.all, 'labels', accountId] as const,
    search: (query: string) => [...emailKeys.all, 'search', query] as const,
  }
  ```
- [ ] **EMAIL-000F**: Create query options with `staleTime: 5 * 60 * 1000` (5 min) for inbox, `gcTime: 60 * 60 * 1000` (1 hour)

**Mutation Hooks:**
- [ ] **EMAIL-000G**: Create optimistic mutation hooks:
  - `useSendEmail()`: optimistic append to sent, rollback on failure
  - `useMarkRead()`, `useStarEmail()`, `useArchiveEmail()`: immediate UI update, sync in background
  - `useSnoozeEmail()`: move to snoozed, restore at time
  - `useDeleteEmail()`: soft delete with undo window
  - **Critical**: All mutations MUST use the shared `useOptimisticMutation()` wrapper from `src/lib/useOptimisticMutation.ts` (see FND-006H in 01-Foundations.md). This wrapper enforces the canonical pattern: `cancelQueries → snapshot → setQueryData → rollback → onSettled invalidate`. Do not implement inline optimistic patterns.

**Tests:**
- [ ] **EMAIL-000H**: Tests for all schemas validating correctly
- [ ] **EMAIL-000I**: Tests for secure token vault (encrypt/decrypt roundtrip)
- [ ] **EMAIL-000J**: Tests for MSW handlers returning correct shapes
- [ ] **EMAIL-000K**: Tests for optimistic mutations and rollback behavior

### Definition of Done
- All email entities typed via Zod schemas
- Secure token storage implemented with SubtleCrypto
- Mock factories produce realistic email data with threads, attachments, labels
- MSW handlers cover all CRUD operations
- Query keys and mutation hooks with optimistic updates

### Anti-Patterns
- ❌ Storing OAuth tokens in localStorage or plain Zustand
- ❌ Inline email body in inbox list (causes massive payload)
- ❌ No optimistic updates for common actions (archive, star, read)
- ❌ Skipping `cancelQueries` in `onMutate` — creates race conditions when a background refetch overwrites the optimistic state

---

## 🔧 Task EMAIL-001: Email State Management & Route Configuration

**Priority:** 🔴 High
**Est. Effort:** 1.5 hours
**Depends On:** EMAIL-000, FND-005 (Zustand)

### Related Files
`src/stores/slices/emailSlice.ts` · `src/pages/EmailPage.tsx` · `src/router/routes.ts`

### Subtasks

**Zustand Slice:**
- [ ] **EMAIL-001A**: Create `src/stores/slices/emailSlice.ts`:
  ```ts
  interface EmailSlice {
    // Connected accounts
    accounts: EmailAccount[]
    activeAccountId: string | 'unified'  // 'unified' for all accounts
    
    // View state
    view: 'inbox' | 'starred' | 'sent' | 'drafts' | 'snoozed' | 'trash' | 'archive'
    focusedInboxEnabled: boolean
    
    // Filters
    searchQuery: string
    selectedLabelIds: string[]
    dateRange: { from?: Date; to?: Date }
    hasAttachments: boolean | null
    isUnreadOnly: boolean
    
    // Selection
    selectedThreadId: string | null
    selectedMessageIds: Set<string>
    bulkSelectMode: boolean
    
    // Compose
    composeOpen: boolean
    composeDraftId: string | null
    composeReplyTo: EmailMessage | null
    composeForwardOf: EmailMessage | null
    
    // Actions
    setActiveAccount: (id: string | 'unified') => void
    setView: (view: EmailSlice['view']) => void
    toggleFocusedInbox: () => void
    setSearchQuery: (q: string) => void
    selectThread: (id: string | null) => void
    toggleMessageSelection: (id: string) => void
    selectAllVisible: () => void
    clearSelection: () => void
    openCompose: (opts?: { draftId?, replyTo?, forwardOf? }) => void
    closeCompose: () => void
    addAccount: (account: EmailAccount) => void
    removeAccount: (id: string) => void
  }
  ```
- [ ] **EMAIL-001B**: Persist only `accounts` (without tokens), `activeAccountId`, `view`, `focusedInboxEnabled` to localStorage

**Route Configuration:**
- [ ] **EMAIL-001C**: Configure `/email` route in `src/router/routes.ts`:
  - `lazy: () => import('@/pages/EmailPage')`
  - `loader: ({ context: { queryClient } }) => queryClient.ensureQueryData(emailKeys.accounts())`
- [ ] **EMAIL-001D**: Add sub-routes for specific views: `/email/inbox`, `/email/starred`, `/email/sent` (all render EmailPage with initial state)

**Page Layout:**
- [ ] **EMAIL-001E**: Create `src/pages/EmailPage.tsx`:
  - Three-column layout on desktop: folder sidebar (200px), email list (flex-1), reading pane (40%)
  - Two-column on tablet: sidebar + list OR list + reading pane
  - Single-column on mobile: list view with slide-in reading pane
  - Use shadcn `Resizable` for draggable panel widths

**Tests:**
- [ ] **EMAIL-001F**: Tests for slice actions (account switching, view changes, selection)
- [ ] **EMAIL-001G**: Tests for persisted state (accounts survive reload, tokens don't persist)
- [ ] **EMAIL-001H**: Tests for route loader calling `ensureQueryData`

### Definition of Done
- Email slice manages accounts, views, filters, selection, compose state
- Responsive three-column layout with resizable panels
- Route prefetches accounts on navigation

### Anti-Patterns
- ❌ Storing OAuth tokens in persisted Zustand slice
- ❌ Full-page reload on account switch
- ❌ Not using resizable panels for email layout

---

## 📥 Task EMAIL-002: Account Management & Unified Inbox

**Priority:** 🔴 High
**Est. Effort:** 3 hours
**Depends On:** EMAIL-001, EMAIL-000

### Related Files
`src/components/email/AccountSidebar.tsx` · `src/components/email/AccountSwitcher.tsx` · `src/components/email/AddAccountModal.tsx` · `src/components/email/UnifiedInbox.tsx`

### Subtasks

**Account Sidebar:**
- [ ] **EMAIL-002A**: Build `AccountSidebar` (left panel):
  - Account switcher dropdown at top (Unified Inbox / individual accounts)
  - System folders: Inbox, Starred, Snoozed, Sent, Drafts, Trash, Archive
  - Custom labels section (collapsible)
  - "Add Account" button at bottom
  - Show unread count badges on Inbox
  - Drag-and-drop email to folder using dnd-kit

- [ ] **EMAIL-002B**: Build `AccountSwitcher` dropdown:
  - Unified Inbox option with combined unread count
  - Individual accounts with provider icon (Gmail, Outlook, Yahoo, custom)
  - Account status indicator (connected, syncing, error)
  - "Manage Accounts" link to settings

**Add Account Flow:**
- [ ] **EMAIL-002C**: Build `AddAccountModal`:
  - Provider selection: Gmail, Outlook, Yahoo, Other (IMAP)
  - OAuth flow stubs for Gmail/Outlook/Yahoo (mock success)
  - IMAP manual configuration form: server, port, username, password, security (SSL/TLS)
  - Connection test button (mock validation)
  - Success state with option to set display name

**Unified Inbox:**
- [ ] **EMAIL-002D**: Build `UnifiedInbox` component:
  - Merges emails from all accounts, sorted by date (newest first)
  - Shows account indicator on each email row (color/icon)
  - Respects `activeAccountId` filter from slice
  - Virtualized list using `useVirtualizer`
  - Empty state: "No emails" or "All caught up" illustration
  - Loading state: skeleton rows

**Folder Views:**
- [ ] **EMAIL-002E**: Implement folder-specific views:
  - Starred: all starred emails across accounts
  - Sent: sent emails from all accounts
  - Drafts: saved drafts
  - Snoozed: snoozed emails with wake time indicator
  - Trash/Archive: soft-deleted emails

**Tests:**
- [ ] **EMAIL-002F**: Tests for account switcher updating `activeAccountId`
- [ ] **EMAIL-002G**: Tests for unified inbox merging multiple accounts
- [ ] **EMAIL-002H**: Tests for add account modal OAuth flow stubs
- [ ] **EMAIL-002I**: Tests for folder navigation (view changes)
- [ ] **EMAIL-002J**: Tests for drag-and-drop email to folder

### Definition of Done
- Account sidebar with unified/individual account switching
- OAuth connection flow for major providers
- Unified inbox merging all accounts with virtualized list
- All standard folder views functional

### Anti-Patterns
- ❌ Fetching all email content for inbox preview (fetch headers only, lazy load bodies)
- ❌ Not showing account indicators in unified view
- ❌ Separate page per account (breaks unified workflow)

---

## 📧 Task EMAIL-003: Email List, Thread View & Compose

**Priority:** 🔴 High
**Est. Effort:** 4 hours
**Depends On:** EMAIL-002, EMAIL-000

### Related Files
`src/components/email/EmailList.tsx` · `src/components/email/EmailListItem.tsx` · `src/components/email/ThreadView.tsx` · `src/components/email/ComposeWindow.tsx`

### Subtasks

**Email List:**
- [ ] **EMAIL-003A**: Build `EmailList` (middle panel):
  - Virtualized list using `useVirtualizer` with `measureElement`
  - Header with search bar, filter chips (unread, attachments, date range)
  - Bulk select checkbox in header
  - Refresh button with last sync time
  - Focused Inbox toggle (switch between Focused/Other, like Gmail tabs)

- [ ] **EMAIL-003B**: Build `EmailListItem` row:
  - Sender avatar + name
  - Subject (bold if unread)
  - Snippet preview (1-2 lines)
  - Date (relative: "2h ago", "Yesterday", or date)
  - Attachment icon if present
  - Star button (toggle with optimistic update)
  - Checkbox for bulk selection (visible on hover or when in bulk mode)
  - Unread indicator (blue dot)
  - Account badge (when in unified view)
  - Click to open thread

**Thread View:**
- [ ] **EMAIL-003C**: Build `ThreadView` (right panel):
  - Thread header: subject, participants, action bar (archive, delete, snooze, star, label, more)
  - Conversation view: messages stacked vertically, newest at bottom
  - Collapsed older messages indicator ("3 older messages")
  - Individual message card:
    - Sender info (avatar, name, email, date)
    - To/CC expander
    - Body HTML rendered safely via DOMPurify
    - Attachment list with download/preview
    - Reply/Reply All/Forward buttons
  - Quick reply composer at bottom (inline)

**Compose Window:**
- [ ] **EMAIL-003D**: Build `ComposeWindow`:
  - Modal/slide-up design (like Superhuman)
  - To/CC/BCC fields with contact autocomplete
  - Subject field
  - Rich text editor (shadcn-based or lightweight)
  - Attachment drag-and-drop area
  - Send button with dropdown for "Send Later"
  - Discard/Save Draft buttons
  - Undo send countdown indicator after sending (5-30 sec configurable)

**Compose Features:**
- [ ] **EMAIL-003E**: Implement "Send Later":
  - Date/time picker
  - Presets: "Tomorrow morning", "Monday morning", "Custom"
  - Timezone aware
  - List of scheduled emails accessible from drafts

- [ ] **EMAIL-003F**: Implement "Undo Send":
  - Configurable delay (5, 10, 20, 30 seconds)
  - Countdown toast after sending
  - Cancel button in toast stops delivery
  - Email moves to drafts if cancelled

**Tests:**
- [ ] **EMAIL-003G**: Tests for email list rendering with virtualization
- [ ] **EMAIL-003H**: Tests for thread view displaying messages correctly
- [ ] **EMAIL-003I**: Tests for compose window sending email (mock)
- [ ] **EMAIL-003J**: Tests for send later scheduling
- [ ] **EMAIL-003K**: Tests for undo send countdown and cancellation

### Definition of Done
- Virtualized email list with search, filters, bulk selection
- Thread view with conversation display and safe HTML rendering
- Compose window with rich text, attachments, send later
- Undo send with configurable delay

### Anti-Patterns
- ❌ Rendering raw HTML without DOMPurify sanitization
- ❌ Loading full message bodies in email list (causes slow render)
- ❌ No undo for send (user errors are permanent)

---

## 📎 Task EMAIL-004: Attachments, Search & Advanced Features

**Priority:** 🟠 Medium
**Est. Effort:** 3 hours
**Depends On:** EMAIL-003, EMAIL-000

### Related Files
`src/components/email/AttachmentViewer.tsx` · `src/components/email/EmailSearch.tsx` · `src/components/email/SnoozeModal.tsx`

### Subtasks

**Attachment Handling:**
- [ ] **EMAIL-004A**: Build `AttachmentList` component:
  - File icon by MIME type (PDF, image, doc, zip, etc.)
  - Filename with truncation
  - File size (human readable: "2.4 MB")
  - Download button
  - Preview button for images/PDFs (opens modal)
  - Security indicator (scanned/clean vs. warning for executables)

- [ ] **EMAIL-004B**: Build `AttachmentViewer` modal:
  - Image viewer with zoom
  - PDF viewer (embedded or external link)
  - Generic file info for unsupported types
  - Download button

- [ ] **EMAIL-004C**: Implement attachment upload in compose:
  - Drag-and-drop zone
  - File picker
  - Upload progress indicator
  - Size validation (max 25MB per file typical)
  - Multiple file support

**Search:**
- [ ] **EMAIL-004D**: Build `EmailSearch` with advanced operators:
  - Full-text search across subject, body, from, to
  - Gmail-style operators: `from:`, `to:`, `subject:`, `has:attachment`, `is:unread`, `is:starred`, `after:`, `before:`, `label:`
  - Search suggestions dropdown
  - Recent searches
  - Search across all accounts or current account only
  - Debounced input with `useDeferredValue`

**Snooze:**
- [ ] **EMAIL-004E**: Build `SnoozeModal`:
  - Presets: Later today, Tomorrow, Next week, Pick date/time
  - Custom date/time picker
  - Recurring snooze options (daily, weekly)
  - Snoozed emails accessible from sidebar
  - Wake notification when snooze expires

**Email Actions:**
- [ ] **EMAIL-004F**: Implement bulk actions:
  - Archive, delete, mark read/unread, star/unstar for selected emails
  - Apply label to selection
  - Move to folder
  - Action bar appears when items selected (like Gmail)

**Tests:**
- [ ] **EMAIL-004G**: Tests for attachment list rendering
- [ ] **EMAIL-004H**: Tests for search with operators
- [ ] **EMAIL-004I**: Tests for snooze modal setting wake time
- [ ] **EMAIL-004J**: Tests for bulk actions applying to selection

### Definition of Done
- Attachment preview and download functional
- Advanced search with operators
- Snooze with presets and custom times
- Bulk actions for selected emails

### Anti-Patterns
- ❌ No file size limits (causes memory/performance issues)
- ❌ Inline search without debouncing (UI jank)
- ❌ Missing security indicators for attachments

---

## 🔗 Task EMAIL-005: Email Integration with Other Modules

**Priority:** 🟠 Medium
**Est. Effort:** 2.5 hours
**Depends On:** EMAIL-003, PROJ-002 (Projects), CAL-008 (Calendar Composer)

### Related Files
`src/components/email/CreateTaskFromEmail.tsx` · `src/components/email/EmailToEvent.tsx` · `src/components/email/EmailActionsMenu.tsx`

### Subtasks

**Projects Integration:**
- [ ] **EMAIL-005A**: Build "Create Task from Email" action:
  - Available in email actions menu (⋯)
  - Modal to select project and section
  - Pre-fills task title from email subject
  - Pre-fills description with email body link/summary
  - Attaches email thread URL to task
  - Uses `useCreateTask()` mutation from Projects module

- [ ] **EMAIL-005B**: Show linked tasks in thread view:
  - Indicator showing "Linked to Project X"
  - Click to navigate to project
  - Option to unlink

**Calendar Integration:**
- [ ] **EMAIL-005C**: Build "Create Event from Email" action:
  - Detects meeting invites automatically (ICS attachments, calendar invite patterns)
  - One-click "Add to Calendar" for detected invites
  - Manual create from any email: pre-fills event title, description, attendees from email
  - Opens calendar composer with pre-filled data

- [ ] **EMAIL-005D**: Build "Schedule Email" calendar view:
  - When scheduling send later, show calendar heatmap of scheduled emails
  - Avoid over-scheduling (visual indicators of busy times)

**Budget Integration:**
- [ ] **EMAIL-005E**: Build "Extract Receipt" action:
  - Detects purchase/receipt emails (Amazon, retail patterns)
  - Parses amount, merchant, date
  - One-click "Add to Budget" creates transaction
  - Attaches receipt PDF/image if present

**Chat Integration:**
- [ ] **EMAIL-005F**: Build "Summarize Thread" action:
  - Uses AI to generate bullet-point summary
  - Option to share summary to chat
  - Creates chat message with summary and link to full thread

**Tests:**
- [ ] **EMAIL-005G**: Tests for create task from email modal
- [ ] **EMAIL-005H**: Tests for calendar event detection and creation
- [ ] **EMAIL-005I**: Tests for receipt extraction
- [ ] **EMAIL-005J**: Tests for summarize thread action

### Definition of Done
- Create task from email functional
- Calendar event detection and creation
- Receipt extraction for budget
- Thread summarization

### Anti-Patterns
- ❌ Hard dependencies on other modules (use dynamic imports)
- ❌ No fallback when other modules not available
- ❌ Synchronous parsing blocking UI

---

## 🤖 Task EMAIL-006: AI-Powered Email Features

**Priority:** 🟢 Low
**Est. Effort:** 3 hours
**Depends On:** EMAIL-003, CHAT-002 (Chat State/AI)

### Related Files
`src/components/email/SmartCompose.tsx` · `src/components/email/EmailSummary.tsx` · `src/components/email/SuggestedReplies.tsx`

### Subtasks

**Smart Compose:**
- [ ] **EMAIL-006A**: Build `SmartCompose` integration:
  - As user types in compose, show ghost text suggestions
  - Press Tab to accept suggestion
  - Uses local LLM via Chat module's streaming infrastructure
  - Context-aware (considers email thread history)
  - Can be disabled in settings

**Suggested Replies:**
- [ ] **EMAIL-006B**: Build `SuggestedReplies`:
  - Quick reply chips below received emails (like Gmail mobile)
  - AI-generated based on email content
  - Examples: "Thanks, I'll review and get back to you", "Confirmed for Tuesday", "Can we reschedule?"
  - Click to populate quick reply composer

**Email Summary:**
- [ ] **EMAIL-006C**: Build `EmailSummary` panel:
  - Long thread summary (3-5 bullet points)
  - Key action items extracted
  - People mentioned and their roles
  - Timeline of decisions
  - Toggle to expand/collapse

**Focused Inbox AI:**
- [ ] **EMAIL-006D**: Implement importance scoring:
  - AI classifies emails: Important, Newsletter, Promotion, Social, Updates
  - Trainable: user corrections improve future classification
  - Focused Inbox toggle shows only Important
  - Badge counts per category

**Tests:**
- [ ] **EMAIL-006E**: Tests for smart compose suggestions appearing
- [ ] **EMAIL-006F**: Tests for suggested replies generation
- [ ] **EMAIL-006G**: Tests for email summary extraction
- [ ] **EMAIL-006H**: Tests for importance classification

### Definition of Done
- Smart compose ghost text suggestions
- Quick suggested replies
- Thread summarization panel
- Trainable importance scoring for focused inbox

### Anti-Patterns
- ❌ AI features that can't be disabled
- ❌ Suggestions that block typing (async ghost text only)
- ❌ No feedback loop for classification training

---

## 📝 Task EMAIL-007: Email Templates & Signatures

**Priority:** 🟠 Medium
**Est. Effort:** 2.5 hours
**Depends On:** EMAIL-003, EMAIL-000

### Related Files
`src/components/email/TemplateManager.tsx` · `src/components/email/SignatureEditor.tsx` · `src/components/email/TemplatePicker.tsx`

### Subtasks

**Email Templates:**
- [ ] **EMAIL-007A**: Build `TemplateManager`:
  - Create and save email templates (canned responses)
  - Rich text editor for template content
  - Template variables ({{name}}, {{company}}, etc.)
  - Category organization (Support, Sales, Internal, Custom)
  - Quick insert in compose window
  - Keyboard shortcut to insert template
  - Template usage analytics

- [ ] **EMAIL-007B**: Build `TemplatePicker` in compose:
  - Searchable template dropdown
  - Preview template before inserting
  - Auto-fill variables based on context
  - Recent templates section

**Email Signatures:**
- [ ] **EMAIL-007C**: Build `SignatureEditor`:
  - Rich text signature editor
  - Support for images (logos, headshots)
  - Add promotional banners
  - Legal disclaimers
  - Multiple signatures (default, reply, forward)
  - Per-account signature selection
  - HTML sanitization for security

- [ ] **EMAIL-007D**: Implement signature insertion:
  - Auto-insert on new compose
  - Different signatures for reply/forward
  - Option to disable signature per email
  - Signature placement (top/bottom)

**Tests:**
- [ ] **EMAIL-007E**: Tests for template creation and insertion
- [ ] **EMAIL-007F**: Tests for template variable substitution
- [ ] **EMAIL-007G**: Tests for signature creation and rendering
- [ ] **EMAIL-007H**: Tests for per-account signature selection

### Definition of Done
- Template system with variables and categories
- Rich text signature editor with images
- Per-account signature management
- Template picker in compose window

### Anti-Patterns
- ❌ No variable support in templates
- ❌ Storing signatures in plain text without sanitization
- ❌ No per-account signature selection

---

## 🔧 Task EMAIL-008: Email Rules, Filters & Automation

**Priority:** 🟠 Medium
**Est. Effort:** 3 hours
**Depends On:** EMAIL-002, EMAIL-000

### Related Files
`src/components/email/RuleBuilder.tsx` · `src/components/email/FilterManager.tsx` · `src/lib/emailRules.ts`

### Subtasks

**Rule Builder:**
- [ ] **EMAIL-008A**: Build `RuleBuilder`:
  - Visual rule condition builder (AND/OR logic)
  - Conditions: from, to, subject, body, has attachment, date range, size
  - Actions: label, archive, delete, mark read, star, forward, snooze
  - Rule priority ordering
  - Test rule on existing emails
  - Import/export rules

- [ ] **EMAIL-008B**: Implement rule execution:
  - Run rules on incoming emails
  - Run rules manually on selected emails
  - Rule execution log
  - Disable individual rules without deleting

**Filter Manager:**
- [ ] **EMAIL-008C**: Build `FilterManager`:
  - List all rules with enable/disable toggle
  - Edit existing rules
  - Duplicate rules
  - Rule usage statistics (how many emails matched)
  - Quick filters (show rules matching current email)

**Auto-Forwarding:**
- [ ] **EMAIL-008D**: Implement auto-forward:
  - Forward to single or multiple addresses
  - Keep copy or forward only
  - Forward with or without original attachments
  - Auto-forward confirmation for security

**Tests:**
- [ ] **EMAIL-008E**: Tests for rule creation and execution
- [ ] **EMAIL-008F**: Tests for rule priority ordering
- [ ] **EMAIL-008G**: Tests for auto-forward functionality
- [ ] **EMAIL-008H**: Tests for rule import/export

### Definition of Done
- Visual rule builder with conditions and actions
- Automatic rule execution on incoming emails
- Auto-forwarding with security confirmation
- Rule import/export functionality

### Anti-Patterns
- ❌ No rule execution log (hard to debug)
- ❌ No way to test rules before enabling
- ❌ Auto-forward without security confirmation

---

## 🔔 Task EMAIL-009: Notifications, Reminders & Auto-Replies

**Priority:** 🟠 Medium
**Est. Effort:** 2 hours
**Depends On:** EMAIL-003, EMAIL-000

### Related Files
`src/components/email/NotificationSettings.tsx` · `src/components/email/VacationResponder.tsx` · `src/components/email/FollowUpReminder.tsx`

### Subtasks

**Notification Settings:**
- [ ] **EMAIL-009A**: Build `NotificationSettings`:
  - Per-account notification preferences
  - Desktop notifications for new emails
  - Sound options (different sounds for VIP senders)
  - Notification filters (only notify for important emails)
  - Quiet hours (do not disturb)
  - Notification grouping

**Follow-up Reminders:**
- [ ] **EMAIL-009B**: Build `FollowUpReminder`:
  - Set reminder for sent emails (if no reply in X days)
  - Reminder for received emails (reply by date)
  - Reminder snooze options
  - Reminder notifications with quick actions
  - Reminder history

**Auto-Reply / Vacation Responder:**
- [ ] **EMAIL-009C**: Build `VacationResponder`:
  - Per-account auto-reply configuration
  - Date range for auto-reply
  - Rich text auto-reply message
  - Different reply for internal vs external
  - Limit auto-reply to once per sender
  - Auto-reply status indicator in sidebar

**Read Receipts:**
- [ ] **EMAIL-009D**: Implement read receipt tracking:
  - Request read receipt on send (optional)
  - Display read receipt status in sent folder
  - Read receipt notifications
  - Link tracking (optional, privacy warning)
  - Tracking dashboard

**Tests:**
- [ ] **EMAIL-009E**: Tests for notification preferences
- [ ] **EMAIL-009F**: Tests for follow-up reminder scheduling
- [ ] **EMAIL-009G**: Tests for vacation responder date ranges
- [ ] **EMAIL-009H**: Tests for read receipt tracking

### Definition of Done
- Granular notification settings per account
- Follow-up reminders for sent/received emails
- Vacation responder with date ranges
- Read receipt tracking with privacy controls

### Anti-Patterns
- ❌ No quiet hours (notifications at night)
- ❌ Auto-reply without date limits (infinite loop)
- ❌ Read receipts without user consent

---

## 👥 Task EMAIL-010: Contact Management & Groups

**Priority:** 🟠 Medium
**Est. Effort:** 2.5 hours
**Depends On:** EMAIL-003, EMAIL-000

### Related Files
`src/components/email/ContactManager.tsx` · `src/components/email/ContactPicker.tsx` · `src/components/email/ContactGroups.tsx`

### Subtasks

**Contact Manager:**
- [ ] **EMAIL-010A**: Build `ContactManager`:
  - Auto-extract contacts from emails
  - Contact details: name, email, phone, company, notes
  - Contact avatar (gravatar or uploaded)
  - Contact history (all emails from/to contact)
  - Star/VIP contacts
  - Search contacts
  - Import/export contacts (vCard)

**Contact Groups:**
- [ ] **EMAIL-010B**: Build `ContactGroups`:
  - Create contact groups (Team, Clients, Family)
  - Add/remove contacts from groups
  - Group colors/icons
  - Send to group in compose
  - Group management in sidebar

**Contact Picker:**
- [ ] **EMAIL-010C**: Build `ContactPicker` in compose:
  - Autocomplete contacts as you type
  - Show recent contacts first
  - Show contact groups
  - Show contact details on hover
  - Multiple selection

**Contact Integration:**
- [ ] **EMAIL-010D**: Integrate with other modules:
  - Link contacts to Projects module
  - Link contacts to Calendar (attendees)
  - Contact notes visible across modules

**Tests:**
- [ ] **EMAIL-010E**: Tests for contact extraction from emails
- [ ] **EMAIL-010F**: Tests for contact group creation and management
- [ ] **EMAIL-010G**: Tests for contact picker autocomplete
- [ ] **EMAIL-010H**: Tests for contact import/export

### Definition of Done
- Auto-extraction of contacts from emails
- Contact groups with send-to-group functionality
- Contact picker with autocomplete
- Contact history and notes

### Anti-Patterns
- ❌ No contact groups (hard to send to teams)
- ❌ No contact history (can't see past interactions)
- ❌ Manual contact entry only (no auto-extraction)

---

## 🔒 Task EMAIL-011: Email Security & Encryption

**Priority:** 🟠 Medium
**Est. Effort:** 2 hours
**Depends On:** EMAIL-003, EMAIL-000

### Related Files
`src/components/email/EncryptionManager.tsx` · `src/lib/emailEncryption.ts` · `src/components/email/PhishingWarning.tsx`

### Subtasks

**Phishing Detection:**
- [ ] **EMAIL-011A**: Build `PhishingWarning`:
  - Detect suspicious links (URL mismatch, known phishing domains)
  - Detect suspicious sender (spoofed domain)
  - Detect attachment threats (executables, macros)
  - Display warning banner in thread view
  - Option to report phishing
  - Block external images by default (privacy)

**Email Encryption:**
- [ ] **EMAIL-011B**: Build `EncryptionManager`:
  - PGP key management (generate, import, export)
  - S/MIME certificate support
  - Encrypt outgoing emails
  - Decrypt incoming encrypted emails
  - Key trust management
  - Encryption status indicator in compose

**Security Settings:**
- [ ] **EMAIL-011C**: Implement security preferences:
  - Toggle external image loading
  - Toggle link tracking protection
  - Toggle HTML email rendering (plain text fallback)
  - Attachment scanning indicators
  - Secure compose mode (no external resources)

**Tests:**
- [ ] **EMAIL-011D**: Tests for phishing detection rules
- [ ] **EMAIL-011E**: Tests for PGP key generation and import
- [ ] **EMAIL-011F**: Tests for email encryption/decryption
- [ ] **EMAIL-011G**: Tests for security preference toggles

### Definition of Done
- Phishing detection with warning banners
- PGP/S/MIME encryption support
- External image blocking by default
- Security settings for privacy protection

### Anti-Patterns
- ❌ Loading external images by default (privacy leak)
- ❌ No phishing warnings (security risk)
- ❌ Encryption without key trust management

---


## 🗂️ Task EMAIL-012: Email Analytics & Insights

**Priority:** 🟢 Low
**Est. Effort:** 2 hours
**Depends On:** EMAIL-003, EMAIL-000

### Related Files
`src/components/email/EmailAnalytics.tsx` · `src/components/email/ResponseTimeChart.tsx` · `src/components/email/EmailVolumeChart.tsx`

### Subtasks

**Analytics Dashboard:**
- [ ] **EMAIL-012A**: Build `EmailAnalytics`:
  - Email volume over time (daily/weekly/monthly)
  - Response time metrics (average, median)
  - Top senders/receivers
  - Email distribution by label/folder
  - Attachment statistics
  - Time-of-day sending patterns

**Response Time Chart:**
- [ ] **EMAIL-012B**: Build `ResponseTimeChart`:
  - Chart showing response times per contact
  - Identify slow responders
  - Track personal response time improvement
  - Filter by date range

**Email Volume Chart:**
- [ ] **EMAIL-012C**: Build `EmailVolumeChart`:
  - Incoming vs outgoing email volume
  - Breakdown by account
  - Peak email times
  - Trend analysis

**Insights:**
- [ ] **EMAIL-012D**: Generate insights:
  - "You respond 2x faster to VIP contacts"
  - "Most emails arrive between 9-11am"
  - "Your inbox grows by 15 emails/day average"
  - Suggestions for inbox management

**Tests:**
- [ ] **EMAIL-012E**: Tests for analytics data aggregation
- [ ] **EMAIL-012F**: Tests for chart rendering
- [ ] **EMAIL-012G**: Tests for insight generation

### Definition of Done
- Email analytics dashboard with key metrics
- Response time and volume charts
- Automated insights and suggestions
- Date range filtering

### Anti-Patterns
- ❌ No date range filtering (can't see trends)
- ❌ No actionable insights (just raw data)
- ❌ Charts without context (hard to interpret)

---

## ⌨️ Task EMAIL-013: Keyboard Shortcuts & Power User Features

**Priority:** 🟢 Low
**Est. Effort:** 2 hours
**Depends On:** EMAIL-003

### Related Files
`src/hooks/useEmailKeyboardShortcuts.ts` · `src/components/email/KeyboardShortcutsHelp.tsx`

### Subtasks

**Keyboard Shortcut System:**
- [ ] **EMAIL-013A**: Create `useEmailKeyboardShortcuts` hook:
  - Gmail-compatible shortcuts: `j/k` (next/prev), `o/Enter` (open), `u` (back to list), `e` (archive), `x` (select), `*` + `a/n/u/r/u` (select all/none/read/unread/starred)
  - Superhuman-style shortcuts: `Cmd+Enter` (send), `Cmd+Shift+C` (cc), `Cmd+Shift+B` (bcc), `Cmd+K` (link), `Cmd+Shift+A` (attachment)
  - Custom shortcuts for Command Center integration: `G then D` (go to dashboard), `G then P` (go to projects)
  - `?` opens shortcuts help modal

**Shortcut Help:**
- [ ] **EMAIL-013B**: Build `KeyboardShortcutsHelp` modal:
  - Searchable shortcut list
  - Categories: Navigation, Selection, Actions, Compose
  - Visual key indicators
  - Option to disable shortcuts

**Power Features:**
- [ ] **EMAIL-013C**: Implement "Split Pane" mode:
  - Vertical or horizontal reading pane layout
  - User preference stored in slice

- [ ] **EMAIL-013D**: Implement "Compact/Density" toggle:
  - Comfortable, Compact, Ultra-compact row heights
  - Affects virtualized list item heights

- [ ] **EMAIL-013E**: Implement "Preview Pane" auto-advance:
  - When archiving/deleting, auto-select next email
  - Configurable in settings

**Tests:**
- [ ] **EMAIL-013F**: Tests for keyboard shortcut handlers
- [ ] **EMAIL-013G**: Tests for shortcut help modal rendering
- [ ] **EMAIL-013H**: Tests for split pane layout toggle

### Definition of Done
- Gmail-compatible navigation and action shortcuts
- Superhuman-style compose shortcuts
- Shortcuts help modal with search
- Split pane and density preferences

### Anti-Patterns
- ❌ Hardcoded shortcuts without user customization
- ❌ Shortcuts that conflict with browser/OS defaults
- ❌ No way to disable shortcuts for accessibility

---

## 📊 Dependency Graph

```
EMAIL-000 (Domain Model, Security & Mock Data)
     │
EMAIL-001 (State Management & Route)
     │
     ├── EMAIL-002 (Account Management & Unified Inbox)
     │          │
     │          └── EMAIL-003 (Email List, Thread View & Compose)
     │                      │
     │                      ├── EMAIL-004 (Attachments, Search & Advanced)
     │                      │
     │                      ├── EMAIL-005 (Module Integration)
     │                      │
     │                      ├── EMAIL-006 (AI Features)
     │                      │
     │                      ├── EMAIL-007 (Templates & Signatures)
     │                      │
     │                      ├── EMAIL-008 (Rules, Filters & Automation)
     │                      │
     │                      ├── EMAIL-009 (Notifications, Reminders & Auto-Replies)
     │                      │
     │                      ├── EMAIL-010 (Contact Management & Groups)
     │                      │
     │                      ├── EMAIL-011 (Security & Encryption)
     │                      │
     │                      ├── EMAIL-012 (Analytics & Insights)
     │                      │
     │                      └── EMAIL-013 (Keyboard Shortcuts & Power User)
     │
     └── (Connections to other modules)
            ├── PROJ-002 (Create task from email)
            ├── CAL-008 (Create event from email)
            ├── BUDG-006 (Receipt extraction)
            └── CHAT-002 (Thread summarization)
```

---

## ✅ Module Completion Checklist

**Core Functionality:**
- [ ] Email account connection (OAuth + IMAP) working
- [ ] Unified inbox merging multiple accounts
- [ ] Threaded conversation view
- [ ] Compose with rich text and attachments
- [ ] Send later and undo send
- [ ] Snooze with custom times
- [ ] Star, archive, delete, label management
- [ ] Advanced search with operators

**Productivity Features:**
- [ ] Email templates with variables
- [ ] Rich text signatures with images
- [ ] Per-account signature management
- [ ] Email rules and filters
- [ ] Auto-forwarding with security confirmation
- [ ] Follow-up reminders
- [ ] Vacation responder with date ranges
- [ ] Read receipt tracking
- [ ] Contact management with auto-extraction
- [ ] Contact groups with send-to-group
- [ ] Contact picker with autocomplete

**Security & Performance:**
- [ ] OAuth tokens encrypted at rest
- [ ] HTML email sanitized via DOMPurify
- [ ] Phishing detection warnings
- [ ] PGP/S/MIME encryption support
- [ ] External image blocking by default
- [ ] Virtualized lists for performance
- [ ] Offline support with Dexie cache
- [ ] Optimistic mutations for responsiveness

**Integration:**
- [ ] Create task from email
- [ ] Detect and add calendar invites
- [ ] Extract receipts to budget
- [ ] Thread summarization

**AI Features:**
- [ ] Smart compose suggestions
- [ ] Suggested quick replies
- [ ] Thread summary panel
- [ ] Trainable focused inbox

**Analytics:**
- [ ] Email volume charts
- [ ] Response time metrics
- [ ] Top senders/receivers
- [ ] Automated insights

**Power User:**
- [ ] Keyboard shortcuts (Gmail + Superhuman style)
- [ ] Shortcuts help modal
- [ ] Split pane layouts
- [ ] Density preferences
- [ ] Preview pane auto-advance

**Quality:**
- [ ] All tests passing
- [ ] Accessibility: keyboard navigation, screen reader labels
- [ ] Motion preferences respected
- [ ] Responsive design (mobile, tablet, desktop)
