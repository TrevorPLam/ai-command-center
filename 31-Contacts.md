# 31‑Contacts — Personal AI Command Center Frontend

> **Status Indicators**: 🟡 Pending, 🟢 In Progress, ✅ Done.
> **Priority**: 🔴 High, 🟠 Medium, 🟢 Low.

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

<!-- ENDSECTION: Frontend Context -->

<!-- SECTION: Research Findings -->

## 🔬 Research Findings — Contacts Module

| Finding | Source | Action Required |
|---------|--------|-----------------|
| **Unified contact management is essential** — Modern apps integrate contacts across email, calendar, and communications. Users expect a single source of truth for contact information. | Google Contacts, Apple Contacts, HubSpot CRM | CONT-001: Implement unified contact model with multiple source integration. |
| **Smart contact enrichment** — AI-powered contact enrichment (social profiles, company info, recent interactions) is becoming standard in professional tools. | HubSpot Sales Hub, Clay, Notion AI | CONT-004: Implement AI-powered contact enrichment with social profile detection. |
| **Relationship mapping** — Visualizing connections between contacts (who introduced whom, shared projects, communication frequency) drives engagement. | Relationship mapping tools 2025 | CONT-005: Implement relationship graph and interaction history. |
| **Tag-based organization** — Flat contact lists become unmanageable; tags, groups, and smart lists are essential for scaling. | Notion databases, Airtable | CONT-002: Implement flexible tagging system with smart lists. |
| **Privacy-first design** — Contact data is sensitive; granular privacy controls and data portability are non-negotiable. | GDPR/CCPA compliance 2026 | CONT-008: Implement privacy controls and export functionality. |
| **Integration with existing modules** — Contacts should integrate with Calendar (events), Projects (team members), and Chat (mentions). | Integrated CRM patterns | CONT-006: Implement cross-module contact references and autocomplete. |
| **Mobile-first capture** — Quick contact capture from business cards, QR codes, and email signatures drives adoption. | Mobile UX patterns 2026 | CONT-003: Implement mobile-optimized Quick Add with OCR support. |
| **Communication tracking** — Users want to see recent emails, calls, and meetings with contacts in one place. | Communication hubs 2025 | CONT-007: Implement unified communication timeline per contact. |
| **Bulk operations essential** — Import/export, bulk tagging, and batch updates are power-user requirements. | CRM onboarding patterns | CONT-009: Implement comprehensive bulk operations. |
| **Offline access critical** — Contacts needed in poor connectivity; must sync when online. | PWA best practices | CONT-010: Implement Dexie-based offline storage with sync. |

<!-- ENDSECTION: Research Findings -->

<!-- SECTION: Cross-Cutting Foundations -->

## 🧱 Cross-Cutting Foundations

| ID | Area | Requirement |
|----|------|-------------|
| **CONT-C01** | State Management | Zustand `contactsSlice` for active contact, view mode, filters, and selection state. URL sync for shareable contact links. |
| **CONT-C02** | Data Persistence | Centralised `CommandCenterDB` stores: `contacts_records`, `contacts_interactions`. Offline contact storage; sync queue for pending mutations. Optimistic updates with rollback. |
| **CONT-C03** | Privacy & Security | Granular privacy controls per contact field; encryption for sensitive data; audit logging for access. |
| **CONT-C04** | Integration Points | Cross-module references: Calendar events, Project team members, Chat mentions, News sources. |
| **CONT-C05** | AI Enrichment | Async background enrichment for social profiles, company data, and relationship mapping. |
| **CONT-C06** | Tag System | Hierarchical tags with smart lists; bulk tag operations; tag-based filtering. |
| **CONT-C07** | Communication Timeline | Unified view of emails, calls, meetings, and chat messages per contact. |
| **CONT-C08** | Mobile Capture | QR code scanning, business card OCR, voice input for quick contact creation. |
| **CONT-C09** | Search & Discovery | Full-text search with phonetic matching; faceted search by tags, company, location. |
| **CONT-C10** | Import/Export | CSV/vCard import with field mapping; vCard/JSON export with privacy controls. |
| **CONT-C11** | Accessibility | WCAG 2.2 AA: keyboard navigation, ARIA labels, focus management, reduced-motion support. |
| **CONT-C12** | Motion | Alive tier for contact entry/exit, relationship animations; Quiet tier for tag toggles and updates. |

<!-- ENDSECTION: Cross-Cutting Foundations -->

<!-- SECTION: Motion Tier Assignment -->

### 🎯 Motion Tier Assignment

| Component | Tier | Technique |
|-----------|------|--------------------|
| New contact entry | **Alive** | `y: -8→0`, `opacity: 0→1`, spring `stiffness: 300, damping: 30` |
| Contact deletion | **Alive** | `x: 0→100%`, `opacity: 1→0`, `height: auto→0` with `AnimatePresence` |
| Relationship graph node | **Alive** | `scale: 1.02` + glow on hover; connection lines animate on load |
| Tag toggle | **Quiet** | Instant state change; subtle `scale: 0.95→1` spring on click |
| View switch | **Alive** | Cross-fade with `AnimatePresence`; `layoutId` for shared elements |
| Communication timeline | **Quiet** | Staggered fade-in for timeline items (≤150ms per item) |
| Search results | **Static** | Instant render; no animation to prevent jank during typing |
| Enrichment loading | **Quiet** | Pulse animation on contact card during AI processing |
| Bulk action bar | **Alive** | `y: 100%→0` slide-up with `AnimatePresence` |

<!-- ENDSECTION: Motion Tier Assignment -->

<!-- SECTION: Task CONT-000 -->

## 🗂️ Task CONT-000: Contacts Domain Model & Mock Data
**Priority:** 🔴 High
**Est. Effort:** 2 hours
**Depends On:** FND-004 (Testing), FND-006 (TanStack Query)

### Related Files
`src/domain/contacts/types.ts` · `src/schemas/contactSchema.ts` · `src/mocks/factories/contacts.ts` · `src/mocks/handlers/contacts.ts` · `src/queries/contacts.ts`

### Subtasks

- [ ] **CONT-000A**: Define core domain types in `src/domain/contacts/types.ts`:
  ```ts
  export type ContactSource = 'manual' | 'email' | 'calendar' | 'import' | 'enrichment'
  export type ContactPrivacy = 'public' | 'team' | 'private' | 'restricted'
  
  export interface ContactField {
    id: string
    type: 'email' | 'phone' | 'address' | 'website' | 'social' | 'custom'
    label: string  // e.g., "Work", "Mobile", "Home"
    value: string
    primary: boolean
    verified: boolean
    privacy: ContactPrivacy
  }
  
  export interface ContactInteraction {
    id: string
    type: 'email' | 'call' | 'meeting' | 'chat' | 'note'
    timestamp: string
    title: string
    summary?: string
    metadata: Record<string, unknown>
  }
  
  export interface ContactRelationship {
    id: string
    relatedContactId: string
    type: 'colleague' | 'friend' | 'family' | 'client' | 'vendor' | 'custom'
    strength: number  // 0-1, based on interaction frequency
    source: string  // How relationship was detected
  }
  
  export interface Contact {
    id: string
    firstName: string
    lastName: string
    company?: string
    title?: string
    avatar?: string
    fields: ContactField[]
    tags: string[]
    notes?: string
    source: ContactSource
    privacy: ContactPrivacy
    interactions: ContactInteraction[]
    relationships: ContactRelationship[]
    enrichmentData?: {
      socialProfiles: Record<string, string>
      companyInfo?: { size: string; industry: string; website: string }
      lastEnriched: string
    }
    createdAt: string
    updatedAt: string
  }
  ```

- [ ] **CONT-000B**: Create Zod schemas in `src/schemas/contactSchema.ts`:
  - `ContactFieldSchema` with validation for email/phone formats
  - `ContactInteractionSchema` with required fields
  - `ContactRelationshipSchema` with strength validation
  - `ContactSchema` with all fields and metadata validation

- [ ] **CONT-000C**: Create `src/mocks/factories/contacts.ts` with factories:
  - `createMockContact(overrides?)` — Generates realistic contact with varied fields
  - `createMockContactField(type, overrides?)` — Single field factory
  - `createMockProfessionalNetwork()` — 50+ professional contacts with companies
  - `createMockPersonalNetwork()` — Family and friends with relationships
  - `createMockVendorNetwork()` — Service providers and vendors
  - `createMockInteractionHistory(contactId, count)` — Generate interaction timeline

- [ ] **CONT-000D**: Create `src/mocks/handlers/contacts.ts` with MSW handlers:
  - `GET /api/contacts` — Paginated list with filters and search
  - `GET /api/contacts/:id` — Full contact with relationships and interactions
  - `POST /api/contacts` — Create new contact
  - `PATCH /api/contacts/:id` — Update contact metadata
  - `DELETE /api/contacts/:id` — Soft delete with privacy cleanup
  - `POST /api/contacts/:id/fields` — Add contact field
  - `PATCH /api/contacts/:id/fields/:fieldId` — Update field
  - `DELETE /api/contacts/:id/fields/:fieldId` — Remove field
  - `POST /api/contacts/:id/interactions` — Add interaction
  - `GET /api/contacts/search` — Full-text search with phonetic matching
  - `POST /api/contacts/enrich` — Trigger AI enrichment
  - `POST /api/contacts/import` — Bulk import with field mapping
  - `GET /api/contacts/export` — Export with privacy filters

- [ ] **CONT-000E**: Create `src/queries/contacts.ts` with Query Key Factory:
  ```ts
  export const contactKeys = {
    all: ['contacts'] as const,
    contacts: (filters: ContactFilters) => [...contactKeys.all, 'list', filters] as const,
    contact: (id: string) => [...contactKeys.all, 'detail', id] as const,
    search: (query: string) => [...contactKeys.all, 'search', query] as const,
    relationships: (id: string) => [...contactKeys.all, 'relationships', id] as const,
    interactions: (id: string) => [...contactKeys.all, 'interactions', id] as const,
  }
  ```

- [ ] **CONT-000F**: Define query options and mutation hooks:
  - `contactsQueryOptions(filters)` — List with `staleTime: 60_000`
  - `contactDetailQueryOptions(id)` — Full contact with `staleTime: 30_000`
  - `useCreateContact()` — Optimistic create with field validation
  - `useUpdateContact()` — Optimistic metadata update
  - `useDeleteContact()` — Optimistic soft delete
  - `useAddContactField()` — Optimistic field addition
  - `useUpdateContactField()` — Optimistic field update
  - `useDeleteContactField()` — Optimistic field removal
  - `useEnrichContact()` — Async enrichment with loading state
  - `useImportContacts()` — Bulk import with progress tracking
  - **Critical**: All mutations MUST use the shared `useOptimisticMutation()` wrapper from `src/lib/useOptimisticMutation.ts` (see FND-006H in 01-Foundations.md). This wrapper enforces the canonical pattern: `cancelQueries → snapshot → setQueryData → rollback → onSettled invalidate`. Do not implement inline optimistic patterns.

### Tests
- [ ] Factory produces valid contacts with proper field validation
- [ ] MSW handlers maintain in-memory state; mutations persist within session
- [ ] `useEnrichContact` triggers background processing and updates contact
- [ ] Search query supports phonetic matching and faceted filters
- [ ] Import handler processes CSV/vCard with field mapping

### Definition of Done
- Full domain model with rich contact fields and relationships
- Mock factories for professional, personal, and vendor networks
- MSW handlers for all CRUD operations and enrichment
- Query key factory and mutation hooks with optimistic updates

### Anti-Patterns
- ❌ Storing contact fields as flat strings — loses type and validation information
- ❌ Missing privacy controls — violates data protection requirements
- ❌ Not supporting relationship mapping — loses network effect value
- ❌ Synchronous enrichment processing — blocks UI and feels slow
- ❌ Skipping `cancelQueries` in `onMutate` — creates race conditions when a background refetch overwrites the optimistic state

<!-- ENDSECTION: Task CONT-000 -->

<!-- SECTION: Task CONT-001 -->

## 🔧 Task CONT-001: Contacts State Management & Privacy Controls
**Priority:** 🔴 High
**Est. Effort:** 1.5 hours
**Depends On:** FND-005 (Zustand), CONT-000

### Related Files
`src/stores/slices/contactsSlice.ts` · `src/hooks/useContactPrivacy.ts`

### Subtasks

- [ ] **CONT-001A**: Create `src/stores/slices/contactsSlice.ts`:
  ```ts
  interface ContactsSlice {
    // Active state
    activeContactId: string | null
    activeViewMode: 'list' | 'grid' | 'relationships'
    selectedContactIds: Set<string>
    bulkMode: boolean
    
    // Filters
    searchQuery: string
    filterTags: string[]
    filterSource: ContactSource[] | 'all'
    filterPrivacy: ContactPrivacy[] | 'all'
    filterCompany: string | null
    
    // UI state
    quickAddOpen: boolean
    importDialogOpen: boolean
    exportDialogOpen: boolean
    enrichmentQueue: string[]  // Contact IDs pending enrichment
    
    // Privacy settings
    defaultPrivacy: ContactPrivacy
    sensitiveFieldsHidden: boolean
    auditLogging: boolean
    
    // Actions
    setActiveContact: (id: string | null) => void
    setViewMode: (mode: ContactsSlice['activeViewMode']) => void
    toggleContactSelected: (id: string) => void
    selectAllVisible: (ids: string[]) => void
    clearSelection: () => void
    setBulkMode: (enabled: boolean) => void
    setSearchQuery: (q: string) => void
    setFilters: (filters: Partial<Pick<ContactsSlice, 'filterTags' | 'filterSource' | 'filterPrivacy' | 'filterCompany'>>) => void
    clearFilters: () => void
    openQuickAdd: () => void
    closeQuickAdd: () => void
    openImportDialog: () => void
    closeImportDialog: () => void
    queueEnrichment: (contactId: string) => void
    setDefaultPrivacy: (privacy: ContactPrivacy) => void
    toggleSensitiveFields: () => void
    setAuditLogging: (enabled: boolean) => void
  }
  ```

- [ ] **CONT-001B**: Export atomic selectors:
  - `useActiveContact()`, `useViewMode()`, `useContactFilters()`, `useBulkSelection()`
  - `useContactPrivacy()`, `useEnrichmentQueue()`

- [ ] **CONT-001C**: Create `useContactPrivacy()` hook:
  - Returns privacy settings and field visibility based on user permissions
  - `canViewField(contactId, fieldType)` — Checks privacy permissions
  - `canEditContact(contactId)` — Checks edit permissions
  - `auditContactAccess(contactId, action)` — Logs access if audit enabled

- [ ] **CONT-001D**: Persist privacy settings to `localStorage`:
  - Use `partialize` to store only privacy preferences and default settings
  - Include migration strategy for privacy setting changes

### Tests
- [ ] State updates correctly for all actions
- [ ] Atomic selectors prevent unnecessary re-renders
- [ ] Privacy hook correctly restricts field access
- [ ] Audit logging captures access events when enabled
- [ ] Privacy settings persist across page reloads

### Definition of Done
- Complete contacts slice with filter, selection, and privacy state
- Privacy controls with field-level access restrictions
- Audit logging for sensitive contact access
- Privacy settings persistence

### Anti-Patterns
- ❌ Storing full contact data in Zustand — use Dexie for content, Zustand for UI state only
- ❌ Missing privacy controls — potential data protection violations
- ❌ Not using atomic selectors — causes re-renders on every contact change

<!-- ENDSECTION: Task CONT-001 -->

<!-- SECTION: Task CONT-002 -->

## 📱 Task CONT-002: Contacts Page Layout & Quick Capture
**Priority:** 🔴 High
**Est. Effort:** 2.5 hours
**Depends On:** FND-007 (Router), CONT-001

### Related Files
`src/pages/ContactsPage.tsx` · `src/components/contacts/ContactsLayout.tsx` · `src/components/contacts/QuickAddModal.tsx` · `src/components/contacts/ContactSidebar.tsx` · `src/router/routes.ts`

### Subtasks

- [ ] **CONT-002A**: Configure `/contacts` route in `src/router/routes.ts`:
  ```ts
  {
    path: 'contacts',
    lazy: () => import('@/pages/ContactsPage'),
    loader: () => queryClient.ensureQueryData(contactsQueryOptions({})),
  },
  {
    path: 'contacts/:contactId',
    lazy: () => import('@/pages/ContactsPage'),
    loader: ({ params }) => queryClient.ensureQueryData(contactDetailQueryOptions(params.contactId!)),
  }
  ```

- [ ] **CONT-002B**: Create `src/pages/ContactsPage.tsx` with three-column layout:
  - Left sidebar (280px): Contact navigation, search, filters, "New Contact" button
  - Center content (flex-1): Active contact with view switcher and contact details
  - Right panel (320px, collapsible): Interaction timeline, relationships, enrichment status

- [ ] **CONT-002C**: Implement global keyboard shortcut:
  - `⌘/Ctrl+Shift+C` opens Quick Add from anywhere in app
  - Uses command palette pattern from Dashboard

- [ ] **CONT-002D**: Build `QuickAddModal` component:
  - Minimal form: First Name, Last Name, Email (optional)
  - Smart field detection based on input patterns
  - One-tap submission with `Enter`
  - Auto-enrichment toggle for new contacts
  - Mobile-optimized with large touch targets

- [ ] **CONT-002E**: Build `ContactSidebar` component:
  - Search input with phonetic matching support
  - Filter panel: Tags, Source, Privacy, Company
  - Smart lists: "Recent", "Favorites", "No Company", "Needs Enrichment"
  - Contact count badges per section
  - Drag-to-reorder sections (dnd-kit)

- [ ] **CONT-002F**: Build mobile capture features:
  - QR code scanner for business cards (requires camera permission)
  - Voice input for contact creation ("Add John Smith from Acme")
  - Photo capture for business card OCR (mock implementation)

- [ ] **CONT-002G**: Add view mode switcher in contact header:
  - Three icon buttons: List, Grid, Relationships
  - Active state with `layoutId` animated indicator
  - Persisted per user in Zustand + localStorage

- [ ] **CONT-002H**: Implement `useSmartContactParsing()` hook:
  - Parses text for contact information patterns
  - Detects emails, phones, websites, social handles
  - Returns structured contact fields from natural language

### Tests
- [ ] Route renders with correct layout; contact ID from URL loads correct contact
- [ ] Keyboard shortcut opens Quick Add modal
- [ ] Smart parsing correctly extracts contact information from text
- [ ] Mobile capture features request appropriate permissions
- [ ] View mode switcher updates and persists

### Definition of Done
- Contacts page with three-column responsive layout
- Global Quick Add shortcut with smart parsing
- Mobile capture features (QR, voice, photo)
- View mode switcher (List/Grid/Relationships)
- Sidebar with search, filters, and smart lists

### Anti-Patterns
- ❌ Opening Quick Add via menu navigation only — requires keyboard shortcut for power users
- ❌ Not supporting mobile capture — misses essential mobile use cases
- ❌ Missing phonetic search — users can't find contacts with misspelled names

<!-- ENDSECTION: Task CONT-002 -->

<!-- SECTION: Task CONT-003 -->

## 👤 Task CONT-003: Contact Details & Field Management
**Priority:** 🔴 High
**Est. Effort:** 3 hours
**Depends On:** CONT-002, CONT-000

### Related Files
`src/components/contacts/ContactDetail.tsx` · `src/components/contacts/ContactField.tsx` · `src/components/contacts/FieldEditor.tsx` · `src/components/contacts/ContactAvatar.tsx`

### Subtasks

- [ ] **CONT-003A**: Build `ContactDetail` component:
  - Header: Avatar, name, title, company with privacy badges
  - Primary fields display with edit indicators
  - Tags section with add/remove functionality
  - Notes section with rich text support
  - Enrichment status indicator with "Refresh" button

- [ ] **CONT-003B**: Build `ContactField` component supporting all field types:
  - **Email**: Clickable mailto link, verification badge, primary indicator
  - **Phone**: Clickable tel link, type badge (Mobile/Work/Home)
  - **Address**: Google Maps integration, formatted display
  - **Website**: Link preview with favicon, title extraction
  - **Social**: Platform icons with profile links
  - **Custom**: Flexible label/value pairs

- [ ] **CONT-003C**: Implement field privacy controls:
  - Privacy indicator icon per field (public/team/private)
  - Click to change privacy with confirmation
  - Bulk privacy change via field type
  - Sensitive fields blur when privacy mode enabled

- [ ] **CONT-003D**: Build `FieldEditor` modal:
  - Type selector with appropriate validation
  - Label picker (Work/Mobile/Home/Custom)
  - Value input with format validation
  - Primary toggle for field type
  - Privacy selector with explanations

- [ ] **CONT-003E**: Build `ContactAvatar` component:
  - Upload functionality with crop/resize
  - Gravatar fallback based on email
  - Initials fallback with color coding
  - Privacy blur for restricted contacts

- [ ] **CONT-003F**: Implement inline editing:
  - Double-click or `Enter` on field enters edit mode
  - `Escape` cancels, `Enter` saves
  - Validation feedback with inline errors
  - Optimistic updates with rollback

- [ ] **CONT-003G**: Add field type suggestions:
  - "Add phone" detects phone number patterns
  - "Add email" detects email patterns
  - "Add social" detects social media handles
  - Smart suggestions based on contact context

### Tests
- [ ] All field types render correctly with sample data
- [ ] Privacy controls properly restrict field access
- [ ] Field editor validates all input formats
- [ ] Inline editing saves on Enter, cancels on Escape
- [ ] Avatar upload works with crop functionality
- [ ] Field suggestions correctly detect patterns

### Definition of Done
- Complete contact detail view with all field types
- Privacy controls with field-level restrictions
- Inline editing with validation
- Avatar management with fallbacks
- Smart field suggestions

### Anti-Patterns
- ❌ Not supporting field privacy — potential data exposure
- ❌ Missing validation for phone/email formats — poor data quality
- ❌ No inline editing — forces modal-heavy interaction
- ❌ Not handling avatar upload errors — confusing UX

<!-- ENDSECTION: Task CONT-003 -->

<!-- SECTION: Task CONT-004 -->

## 🌐 Task CONT-004: AI-Powered Contact Enrichment
**Priority:** 🟠 Medium
**Est. Effort:** 2.5 hours
**Depends On:** CONT-003, CONT-000

### Related Files
`src/components/contacts/EnrichmentPanel.tsx` · `src/hooks/useContactEnrichment.ts` · `src/services/enrichmentService.ts`

### Subtasks

- [ ] **CONT-004A**: Create `src/services/enrichmentService.ts`:
  ```ts
  interface EnrichmentService {
    enrichContact(contact: Contact): Promise<EnrichmentResult>
    findSocialProfiles(email: string, name: string): Promise<SocialProfile[]>
    lookupCompanyInfo(domain: string): Promise<CompanyInfo>
    detectRelationships(contactId: string): Promise<Relationship[]>
  }
  ```

- [ ] **CONT-004B**: Implement `useContactEnrichment()` hook:
  - Triggers background enrichment process
  - Shows progress indicator and status
  - Handles enrichment results and errors
  - Updates contact with new data

- [ ] **CONT-004C**: Build `EnrichmentPanel` component:
  - Shows enrichment status per contact
  - "Enrich now" button with loading state
  - Display of found social profiles with verification
  - Company information display with logo
  - Relationship suggestions with acceptance/rejection

- [ ] **CONT-004D**: Implement social profile detection:
  - LinkedIn profile lookup by name + company
  - Twitter/X profile detection by username patterns
  - GitHub profile for technical contacts
  - Other platforms based on email domain

- [ ] **CONT-004E**: Implement company information lookup:
  - Domain lookup for company website
  - Industry classification and size estimation
  - Logo and description extraction
  - Related company suggestions

- [ ] **CONT-004F**: Add relationship detection:
  - Email interaction analysis (if integrated)
  - Shared project detection from Projects module
  - Calendar event co-attendance
  - Manual relationship suggestions

- [ ] **CONT-004G**: Implement enrichment queue:
  - Batch processing for multiple contacts
  - Progress tracking for bulk enrichment
  - Rate limiting to avoid API abuse
  - Retry logic for failed enrichments

### Tests
- [ ] Enrichment service processes contact and returns structured data
- [ ] Social profile detection finds relevant profiles
- [ ] Company lookup returns accurate information
- [ ] Relationship detection suggests valid connections
- [ ] Bulk enrichment processes queue correctly
- [ ] Enrichment panel displays results with appropriate actions

### Definition of Done
- AI enrichment service with social, company, and relationship detection
- Enrichment panel with status and results display
- Bulk enrichment queue with progress tracking
- Privacy controls for enriched data

### Anti-Patterns
- ❌ Synchronous enrichment processing — blocks UI
- ❌ Not respecting privacy during enrichment — potential violations
- ❌ Missing rate limiting — API abuse potential
- ❌ Not providing user control over enrichment — feels invasive

<!-- ENDSECTION: Task CONT-004 -->

<!-- SECTION: Task CONT-005 -->

## 🕸️ Task CONT-005: Relationship Mapping & Network Visualization
**Priority:** 🟠 Medium
**Est. Effort:** 3 hours
**Depends On:** CONT-004, CONT-000

### Related Files
`src/components/contacts/RelationshipGraph.tsx` · `src/components/contacts/RelationshipList.tsx` · `src/hooks/useContactRelationships.ts`

### Subtasks

- [ ] **CONT-005A**: Build `RelationshipGraph` component:
  - Force-directed graph visualization using D3 or similar
  - Contact nodes with avatar/name
  - Connection lines weighted by relationship strength
  - Interactive: hover shows relationship details
  - Zoom and pan controls for large networks

- [ ] **CONT-005B**: Implement `useContactRelationships()` hook:
  - Calculates relationship strength based on interactions
  - Detects mutual connections
  - Suggests potential relationships
  - Updates graph data reactively

- [ ] **CONT-005C**: Build `RelationshipList` component:
  - Table view of all relationships
  - Columns: Contact, Type, Strength, Last Interaction, Actions
  - Sorting by strength or recent activity
  - Filter by relationship type

- [ ] **CONT-005D**: Add relationship management:
  - "Add relationship" modal with type selector
  - Manual strength adjustment
  - Relationship type customization
  - Bulk relationship operations

- [ ] **CONT-005E**: Implement network insights:
  - "Most connected" contacts identification
  - "Bridging" contacts that connect groups
  - "Isolated" contacts that need connection
  - Network density metrics

- [ ] **CONT-005F**: Add cross-module integration:
  - Project team member relationships
  - Calendar co-attendee connections
  - Chat mention frequency
  - News source author connections

### Tests
- [ ] Relationship graph renders with correct node positioning
- [ ] Hover interactions show relationship details
- [ ] Relationship list sorts and filters correctly
- [ ] Relationship management updates graph reactively
- [ ] Network insights provide meaningful metrics

### Definition of Done
- Interactive relationship graph visualization
- Relationship management with type and strength controls
- Network insights and analytics
- Cross-module relationship integration

### Anti-Patterns
- ❌ Static graph without interactivity — poor user experience
- ❌ Not handling large networks — performance issues
- ❌ Missing relationship management — incomplete feature set
- ❌ Not integrating with other modules — missed opportunities

<!-- ENDSECTION: Task CONT-005 -->

<!-- SECTION: Task CONT-006 -->

## 🔗 Task CONT-006: Cross-Module Integration & Autocomplete
**Priority:** 🔴 High
**Est. Effort:** 2 hours
**Depends On:** CONT-001, other modules

### Related Files
`src/components/contacts/ContactAutocomplete.tsx` · `src/hooks/useContactReferences.ts` · `src/integrations/calendarIntegration.ts` · `src/integrations/projectsIntegration.ts`

### Subtasks

- [ ] **CONT-006A**: Build `ContactAutocomplete` component:
  - Used across Calendar, Projects, Chat modules
  - Search by name, email, company, tags
  - Shows avatar and primary field
  - Keyboard navigation with Enter selection
  - Recent contacts prioritization

- [ ] **CONT-006B**: Implement Calendar integration:
  - Event attendees from Contacts module
  - Contact birthday events in Calendar
  - Meeting notes linked to contacts
  - Contact availability indicators

- [ ] **CONT-006C**: Implement Projects integration:
  - Team member selection from Contacts
  - Client contact linking to projects
  - Vendor management through Contacts
  - Project stakeholder mapping

- [ ] **CONT-006D**: Implement Chat integration:
  - @mention autocomplete from Contacts
  - Contact chat history integration
  - Contact presence indicators
  - Contact-based chat rooms

- [ ] **CONT-006E**: Create `useContactReferences()` hook:
  - Counts references across modules
  - Shows contact usage statistics
  - Identifies orphaned contacts
  - Suggests contact cleanup

- [ ] **CONT-006F**: Add contact linking UI:
  - "Link to project" in contact detail
  - "Link to event" in contact detail
  - Bidirectional relationship maintenance
  - Broken link detection and repair

### Tests
- [ ] Autocomplete works in all integrated modules
- [ ] Calendar events show contact attendees correctly
- [ ] Projects team members sync with contacts
- [ ] Chat @mentions resolve to contacts
- [ ] Contact references count accurately across modules

### Definition of Done
- Contact autocomplete working across all modules
- Calendar, Projects, and Chat integration complete
- Contact reference tracking and management
- Bidirectional linking between contacts and modules

### Anti-Patterns
- ❌ Module-specific contact storage — creates data duplication
- ❌ Not maintaining references — broken links over time
- ❌ Missing autocomplete in key modules — poor UX
- ❌ Not handling contact updates across modules — stale data

<!-- ENDSECTION: Task CONT-006 -->

<!-- SECTION: Task CONT-007 -->

## 📞 Task CONT-007: Communication Timeline & Interaction Tracking
**Priority:** 🟠 Medium
**Est. Effort:** 2.5 hours
**Depends On:** CONT-003, CONT-000

### Related Files
`src/components/contacts/CommunicationTimeline.tsx` · `src/components/contacts/InteractionItem.tsx` · `src/hooks/useContactInteractions.ts`

### Subtasks

- [ ] **CONT-007A**: Build `CommunicationTimeline` component:
  - Reverse-chronological list of interactions
  - Grouped by day/week/month with collapsible sections
  - Filter by interaction type (email, call, meeting, chat)
  - Search within interaction history
  - Export timeline functionality

- [ ] **CONT-007B**: Build `InteractionItem` component:
  - **Email**: Subject, preview, timestamp, open in email client
  - **Call**: Phone number, duration, direction (in/out), recording link
  - **Meeting**: Title, attendees, duration, notes, calendar link
  - **Chat**: Message preview, platform, timestamp
  - **Note**: Manual note with rich text, tags

- [ ] **CONT-007C**: Implement `useContactInteractions()` hook:
  - Fetches interactions from multiple sources
  - Aggregates by contact
  - Supports pagination for long histories
  - Caches recent interactions

- [ ] **CONT-007D**: Add interaction logging:
  - Manual note addition from contact detail
  - Automatic logging when viewing contact (optional)
  - Bulk interaction import from email/calendar
  - Interaction deletion with confirmation

- [ ] **CONT-007E**: Implement interaction analytics:
  - Communication frequency chart (last 12 months)
  - Preferred communication method detection
  - Response time tracking
  - Interaction streaks and patterns

- [ ] **CONT-007F**: Add quick actions from timeline:
  - "Send email" opens default email client
  - "Schedule meeting" opens Calendar with contact pre-filled
  - "Start chat" opens Chat with contact
  - "Add note" opens note editor

### Tests
- [ ] Timeline renders interactions in correct order
- [ ] Interaction items display appropriate information per type
- [ ] Filtering and search work correctly
- [ ] Manual note addition updates timeline
- [ ] Analytics charts show meaningful data

### Definition of Done
- Complete communication timeline with all interaction types
- Manual and automatic interaction logging
- Interaction analytics and insights
- Quick actions for common communication tasks

### Anti-Patterns
- ❌ Not supporting all interaction types — incomplete picture
- ❌ Missing pagination — performance issues with long histories
- ❌ Not providing quick actions — inefficient workflows
- ❌ Not aggregating from multiple sources — fragmented view

<!-- ENDSECTION: Task CONT-007 -->

<!-- SECTION: Task CONT-008 -->

## 🏷️ Task CONT-008: Tag System & Smart Lists
**Priority:** 🟠 Medium
**Est. Effort:** 2 hours
**Depends On:** CONT-002, CONT-000

### Related Files
`src/components/contacts/TagManager.tsx` · `src/components/contacts/SmartLists.tsx` · `src/hooks/useContactTags.ts`

### Subtasks

- [ ] **CONT-008A**: Build `TagManager` component:
  - Tag creation with color and icon selection
  - Hierarchical tag structure (parent/child)
  - Tag search and filtering
  - Bulk tag operations (assign, remove, rename)
  - Tag usage statistics

- [ ] **CONT-008B**: Implement `useContactTags()` hook:
  - Fetches all tags with usage counts
  - Manages tag CRUD operations
  - Supports tag hierarchies
  - Provides tag suggestions

- [ ] **CONT-008C**: Build `SmartLists` component:
  - Predefined smart lists: "Recent", "Favorites", "No Company", "Needs Enrichment", "Birthdays This Month"
  - Custom smart list builder with rule engine
  - Rules based on tags, fields, interactions, dates
  - Smart list sharing and export

- [ ] **CONT-008D**: Implement tag-based filtering:
  - Multi-select tag filter in sidebar
  - "AND/OR" logic for tag combinations
  - Tag exclusion (show contacts WITHOUT tag)
  - Saved tag filter presets

- [ ] **CONT-008E**: Add tag automation:
  - Auto-tag based on email domain (company tags)
  - Auto-tag based on interaction patterns
  - Suggested tags when adding contacts
  - Tag cleanup for unused/similar tags

- [ ] **CONT-008F**: Implement tag analytics:
  - Tag usage distribution chart
  - Tag overlap analysis
  - Untagged contacts identification
  - Tag suggestion accuracy metrics

### Tests
- [ ] Tag manager creates and modifies tags correctly
- [ ] Hierarchical tags display parent/child relationships
- [ ] Smart lists filter contacts according to rules
- [ ] Tag automation applies appropriate tags
- [ ] Tag analytics provide meaningful insights

### Definition of Done
- Complete tag management system with hierarchies
- Smart lists with custom rule engine
- Tag-based filtering and automation
- Tag analytics and cleanup tools

### Anti-Patterns
- ❌ Flat tag structure — doesn't scale for large contact lists
- ❌ Missing smart lists — forces manual filtering
- ❌ Not supporting tag automation — tedious manual tagging
- ❌ No tag analytics — missed optimization opportunities

<!-- ENDSECTION: Task CONT-008 -->

<!-- SECTION: Task CONT-009 -->

## 📥📤 Task CONT-009: Import/Export & Data Portability
**Priority:** 🟢 Low
**Est. Effort:** 2 hours
**Depends On:** CONT-008, CONT-000

### Related Files
`src/components/contacts/ImportDialog.tsx` · `src/components/contacts/ExportDialog.tsx` · `src/utils/contactImportExport.ts`

### Subtasks

- [ ] **CONT-009A**: Create `src/utils/contactImportExport.ts`:
  ```ts
  interface ImportResult {
    imported: number
    updated: number
    skipped: number
    errors: ImportError[]
  }
  
  export function importContacts(file: File, mapping: FieldMapping): Promise<ImportResult>
  export function exportContacts(contacts: Contact[], format: 'vcard' | 'csv' | 'json'): Promise<Blob>
  export function detectFileFormat(file: File): 'vcard' | 'csv' | 'unknown'
  export function previewImport(file: File, mapping: FieldMapping): Promise<ContactPreview[]>
  ```

- [ ] **CONT-009B**: Build `ImportDialog` component:
  - File upload with drag-and-drop support
  - Format detection (vCard, CSV)
  - Field mapping interface with preview
  - Duplicate handling options (skip, update, merge)
  - Import progress with batch status
  - Privacy controls for imported data

- [ ] **CONT-009C**: Build `ExportDialog` component:
  - Format selection (vCard, CSV, JSON)
  - Field selection with privacy controls
  - Filter by tags, companies, or custom selection
  - Export preview with record count
  - Download with appropriate filename

- [ ] **CONT-009D**: Implement vCard support:
  - Parse vCard 2.1, 3.0, 4.0 formats
  - Handle vCard fields (FN, N, EMAIL, TEL, ADR, ORG, URL)
  - Support vCard photos and logos
  - Generate standards-compliant vCard exports

- [ ] **CONT-009E**: Implement CSV import with mapping:
  - Auto-detect common field patterns
  - Interactive field mapping interface
  - Column preview and validation
  - Handle escaped characters and special formats

- [ ] **CONT-009F**: Add data validation and cleanup:
  - Email format validation
  - Phone number normalization
  - Duplicate detection and merging
  - Missing field handling

### Tests
- [ ] Import correctly processes vCard and CSV files
- [ ] Field mapping preserves data accurately
- [ ] Export generates valid files in all formats
- [ ] Duplicate handling works as expected
- [ ] Privacy controls restrict sensitive data export

### Definition of Done
- Complete import/export functionality for vCard and CSV
- Interactive field mapping with preview
- Privacy controls for data portability
- Validation and cleanup for imported data

### Anti-Patterns
- ❌ Not supporting vCard format — industry standard missing
- ❌ Missing field mapping — poor import experience
- ❌ No privacy controls on export — potential data leakage
- ❌ Not handling duplicates — data quality issues

<!-- ENDSECTION: Task CONT-009 -->

<!-- SECTION: Task CONT-010 -->

## 📱 Task CONT-010: Offline Support & Data Sync
**Priority:** 🔴 High
**Est. Effort:** 2 hours
**Depends On:** CONT-000, CONT-001

### Related Files
`src/lib/db/contacts.ts` · `src/hooks/useOfflineContacts.ts` · `src/components/contacts/OfflineStatusBar.tsx`

### Subtasks

- [ ] **CONT-010A**: Use centralized CommandCenterDB for contacts data:
  ```ts
  // src/hooks/useOfflineContacts.ts
  import { db } from '@/lib/db'  // Centralized CommandCenterDB

  export function useOfflineContacts() {
    const contacts = useLiveQuery(() => db.contacts_records.toArray(), [])
    const interactions = useLiveQuery(() => db.contacts_interactions.toArray(), [])
    
    const saveContact = async (contact: Contact) => {
      await db.contacts_records.put(contact)
    }
    
    const saveInteraction = async (interaction: ContactInteraction) => {
      await db.contacts_interactions.put(interaction)
    }
    
    return { contacts, interactions, saveContact, saveInteraction }
  }
  ```

- [ ] **CONT-010B**: Implement `useOfflineContacts()` hook:
  - Reads contacts from Dexie when offline
  - Writes to Dexie immediately on all operations
  - Queues mutations in `pendingMutations` table
  - Syncs queue when connection restored

- [ ] **CONT-010C**: Create sync engine:
  - Process pending mutations in order (FIFO)
  - Handle conflicts (last-write-wins with timestamp check)
  - Retry failed mutations with exponential backoff
  - Sync enrichment queue when online

- [ ] **CONT-010D**: Build `OfflineStatusBar` component:
  - Shows offline state when `navigator.onLine === false`
  - Shows pending mutation count when online but queue not empty
  - "Sync now" button for manual sync
  - Enrichment queue status indicator

- [ ] **CONT-010E**: Implement offline-first interactions:
  - Add interactions immediately to local timeline
  - Queue interaction sync when online
  - Show "pending sync" indicators
  - Handle interaction conflicts on sync

- [ ] **CONT-010F**: Add conflict resolution UI:
  - Modal when server version differs from local on sync
  - Options: Keep mine, Keep theirs, Merge manually
  - Applies to contact data and interactions
  - Bulk conflict resolution for multiple items

### Tests
- [ ] Contacts load from Dexie when offline
- [ ] Mutations queued correctly when offline
- [ ] Sync processes queue when connection restored
- [ ] Conflict resolution modal appears on divergent sync
- [ ] Offline status bar shows correct state

### Definition of Done
- Full offline support with Dexie persistence
- Mutation queue with retry logic for contacts and interactions
- Automatic sync on reconnection
- Conflict resolution UI for data conflicts
- Visual indicators for sync status

### Anti-Patterns
- ❌ Not queueing mutations offline — loses user data
- ❌ Silent conflict resolution — may surprise users
- ❌ No visual indication of sync status — users unsure if changes saved
- ❌ Not handling enrichment queue offline — missed enrichment opportunities

<!-- ENDSECTION: Task CONT-010 -->

<!-- SECTION: Task CONT-011 -->

## 🗂️ Task CONT-011: Quality Gates, Testing & Accessibility
**Priority:** 🔴 High
**Est. Effort:** 3 hours
**Depends On:** All CONT tasks

### Related Files
`src/tests/contacts/*.test.tsx` · `src/tests/contacts/accessibility.test.tsx` · `package.json` (scripts)

### Subtasks

- [ ] **CONT-011A**: Unit tests for domain utilities:
  - Contact field validation functions
  - Privacy control logic
  - Tag hierarchy operations
  - Import/export utilities

- [ ] **CONT-011B**: Component tests:
  - Contact detail rendering and interactions
  - Field editor validation and submission
  - Relationship graph visualization
  - Timeline filtering and search

- [ ] **CONT-011C**: Integration tests:
  - Contact CRUD operations with optimistic updates
  - Cross-module autocomplete functionality
  - Import/export workflows
  - Offline sync and conflict resolution

- [ ] **CONT-011D**: E2E tests for critical flows:
  - Create contact → add fields → enrich → verify
  - Import contacts → resolve duplicates → verify
  - Search contact → view timeline → add interaction
  - Relationship graph navigation and interaction

- [ ] **CONT-011E**: Accessibility tests:
  - Keyboard navigation through all contact interfaces
  - Screen reader compatibility for contact lists and details
  - Color contrast verification for privacy indicators
  - Focus management in modals and forms

- [ ] **CONT-011F**: Performance tests:
  - Contact list rendering with 1000+ contacts
  - Relationship graph performance with large networks
  - Search response time with full-text indexing
  - Memory usage for offline contact storage

### Definition of Done
- All contact module tests passing with 90%+ coverage
- Accessibility compliance verified with automated and manual tests
- Performance benchmarks met for large datasets
- E2E tests covering critical user workflows

### Anti-Patterns
- ❌ Skipping accessibility testing — excludes users
- ❌ Not testing with large datasets — performance issues in production
- ❌ Missing E2E tests — integration failures
- ❌ Not testing privacy controls — data protection risks

<!-- ENDSECTION: Task CONT-011 -->

<!-- SECTION: Task CONT-012 -->

## ⚙️ Task CONT-012: Workflow Automation & Follow-Up Reminders
**Priority:** 🟠 Medium
**Est. Effort:** 2.5 hours
**Depends On:** CONT-007, CONT-000

### Related Files
`src/components/contacts/WorkflowBuilder.tsx` · `src/components/contacts/ReminderPanel.tsx` · `src/hooks/useContactWorkflows.ts` · `src/services/workflowService.ts`

### Subtasks

- [ ] **CONT-012A**: Create `src/services/workflowService.ts`:
  ```ts
  interface WorkflowTrigger {
    type: 'interaction_added' | 'contact_created' | 'tag_added' | 'date_based' | 'manual'
    conditions: Record<string, unknown>
  }

  interface WorkflowAction {
    type: 'create_task' | 'send_email' | 'add_tag' | 'enrich_contact' | 'schedule_reminder'
    parameters: Record<string, unknown>
  }

  interface Workflow {
    id: string
    name: string
    description: string
    trigger: WorkflowTrigger
    actions: WorkflowAction[]
    enabled: boolean
  }
  ```

- [ ] **CONT-012B**: Build `WorkflowBuilder` component:
  - Visual workflow editor with trigger/action nodes
  - Pre-built workflow templates (e.g., "New lead follow-up", "Birthday reminder")
  - Condition builder for complex triggers
  - Workflow testing and preview mode
  - Workflow execution history

- [ ] **CONT-012C**: Build `ReminderPanel` component:
  - Contact-specific reminder list
  - Reminder types: follow-up, birthday, anniversary, custom
  - Recurring reminder support (daily, weekly, monthly, yearly)
  - Reminder snooze and complete actions
  - Integration with system notifications

- [ ] **CONT-012D**: Implement `useContactWorkflows()` hook:
  - Executes workflows based on triggers
  - Queues workflow actions for background processing
  - Tracks workflow execution status
  - Handles workflow errors and retries

- [ ] **CONT-012E**: Add automated follow-up sequences:
  - Time-based follow-up triggers (e.g., "3 days after meeting")
  - Interaction-based triggers (e.g., "after email opened")
  - Multi-step follow-up sequences
  - A/B testing for follow-up templates

- [ ] **CONT-012F**: Implement reminder scheduling:
  - Calendar integration for reminders
  - Smart reminder suggestions based on interaction patterns
  - Reminder escalation for overdue items
  - Bulk reminder operations

### Tests
- [ ] Workflows execute correctly on trigger events
- [ ] Workflow builder creates valid workflow configurations
- [ ] Reminders fire at scheduled times
- [ ] Follow-up sequences execute in correct order
- [ ] Workflow errors are handled gracefully

### Definition of Done
- Complete workflow automation system with visual builder
- Reminder system with recurring support
- Automated follow-up sequences
- Pre-built workflow templates
- Integration with Calendar and Tasks modules

### Anti-Patterns
- ❌ Blocking UI during workflow execution — use background processing
- ❌ Missing workflow error handling — silent failures
- ❌ Not supporting recurring reminders — limits usefulness
- ❌ No workflow testing capability — difficult to debug

<!-- ENDSECTION: Task CONT-012 -->

<!-- SECTION: Task CONT-013 -->

## 🗂️ Task CONT-013: Contact Analytics Dashboard
**Priority:** 🟠 Medium
**Est. Effort:** 2 hours
**Depends On:** CONT-005, CONT-007

### Related Files
`src/components/contacts/AnalyticsDashboard.tsx` · `src/components/contacts/NetworkInsights.tsx` · `src/hooks/useContactAnalytics.ts`

### Subtasks

- [ ] **CONT-013A**: Build `AnalyticsDashboard` component:
  - Bento grid layout with key metrics cards
  - Total contacts, new contacts this month, active contacts
  - Contact growth chart (last 12 months)
  - Tag distribution chart
  - Company breakdown visualization
  - Privacy level distribution

- [ ] **CONT-013B**: Build `NetworkInsights` component:
  - Network density metrics
  - Most connected contacts identification
  - Bridging contacts (connect different clusters)
  - Isolated contacts needing attention
  - Relationship strength distribution
  - Interaction frequency heatmap

- [ ] **CONT-013C**: Implement `useContactAnalytics()` hook:
  - Calculates contact growth metrics
  - Computes network statistics
  - Generates engagement insights
  - Identifies contact health issues
  - Provides actionable recommendations

- [ ] **CONT-013D**: Add communication analytics:
  - Communication frequency by type (email, call, meeting)
  - Response time tracking
  - Preferred communication method detection
  - Interaction streaks and patterns
  - Outreach effectiveness metrics

- [ ] **CONT-013E**: Implement enrichment analytics:
  - Enrichment success rate
  - Most valuable enrichment sources
  - Enrichment coverage by contact type
  - Social profile detection rate
  - Company lookup accuracy

- [ ] **CONT-013F**: Add data quality metrics:
  - Complete contact percentage
  - Duplicate contact count
  - Contacts needing enrichment
  - Contacts with missing critical fields
  - Data freshness indicators

### Tests
- [ ] Dashboard renders accurate metrics
- [ ] Network insights provide meaningful statistics
- [ ] Charts display correct data
- [ ] Analytics calculations are performant with large datasets
- [ ] Recommendations are actionable

### Definition of Done
- Comprehensive analytics dashboard with key metrics
- Network insights and relationship analytics
- Communication and enrichment analytics
- Data quality metrics and recommendations
- Responsive design with proper accessibility

### Anti-Patterns
- ❌ Overwhelming dashboard with too many metrics — focus on actionable insights
- ❌ Not handling large datasets — performance issues
- ❌ Missing context for metrics — numbers without meaning
- ❌ Not providing recommendations — data without action

<!-- ENDSECTION: Task CONT-013 -->

<!-- SECTION: Task CONT-014 -->

## 🔗 Task CONT-014: Social Media Integration
**Priority:** 🟢 Low
**Est. Effort:** 1.5 hours
**Depends On:** CONT-004, CONT-000

### Related Files
`src/components/contacts/SocialMediaPanel.tsx` · `src/services/socialMediaService.ts` · `src/hooks/useSocialMedia.ts`

### Subtasks

- [ ] **CONT-014A**: Create `src/services/socialMediaService.ts`:
  ```ts
  interface SocialProfile {
    platform: 'linkedin' | 'twitter' | 'github' | 'instagram' | 'facebook' | 'custom'
    username: string
    url: string
    verified: boolean
    followerCount?: number
    lastSynced: string
  }

  interface SocialInteraction {
    platform: string
    type: 'mention' | 'like' | 'comment' | 'share' | 'follow'
    timestamp: string
    content?: string
  }
  ```

- [ ] **CONT-014B**: Build `SocialMediaPanel` component:
  - Display linked social profiles per contact
  - Profile verification badges
  - Recent social interactions feed
  - "Connect profile" button for each platform
  - Social profile sync status

- [ ] **CONT-014C**: Implement `useSocialMedia()` hook:
  - Fetches social profile data
  - Syncs social interactions
  - Updates contact with social data
  - Handles social authentication (mock)

- [ ] **CONT-014D**: Add social profile linking:
  - Manual profile URL input
  - Username-based profile lookup
  - Profile verification process
  - Bulk profile linking operations

- [ ] **CONT-014E**: Implement social interaction tracking:
  - Monitor mentions and interactions
  - Link social interactions to contacts
  - Display social activity in communication timeline
  - Social engagement metrics

### Tests
- [ ] Social profiles display correctly
- [ ] Profile linking works with valid URLs
- [ ] Social interactions sync properly
- [ ] Social data integrates with timeline
- [ ] Authentication flow works (mock)

### Definition of Done
- Social media profile linking for major platforms
- Social interaction tracking and display
- Integration with communication timeline
- Social profile verification
- Privacy controls for social data

### Anti-Patterns
- ❌ Storing social credentials insecurely — security risk
- ❌ Not respecting social API rate limits — API abuse
- ❌ Missing privacy controls for social data — data protection risk
- ❌ Over-fetching social data — performance and privacy issues

<!-- ENDSECTION: Task CONT-014 -->

<!-- SECTION: Task CONT-015 -->

## ⭐ Task CONT-015: Contact Scoring & Prioritization
**Priority:** 🟢 Low
**Est. Effort:** 1.5 hours
**Depends On:** CONT-007, CONT-000

### Related Files
`src/components/contacts/ContactScoring.tsx` · `src/services/scoringService.ts` · `src/hooks/useContactScoring.ts`

### Subtasks

- [ ] **CONT-015A**: Create `src/services/scoringService.ts`:
  ```ts
  interface ScoringRule {
    id: string
    name: string
    criteria: ScoringCriteria
    weight: number
  }

  interface ScoringCriteria {
    interactionFrequency: number
    recency: number
    enrichmentCompleteness: number
    relationshipStrength: number
    customCriteria: Record<string, number>
  }

  interface ContactScore {
    contactId: string
    totalScore: number
    breakdown: Record<string, number>
    lastCalculated: string
  }
  ```

- [ ] **CONT-015B**: Build `ContactScoring` component:
  - Score display in contact list (badge/indicator)
  - Score breakdown modal
  - Scoring rule editor
  - Score history chart
  - Top-scored contacts list

- [ ] **CONT-015C**: Implement `useContactScoring()` hook:
  - Calculates scores based on rules
  - Updates scores on contact changes
  - Provides score ranking
  - Suggests score improvements

- [ ] **CONT-015D**: Add scoring rule customization:
  - Pre-built scoring templates (e.g., "Sales lead", "VIP client")
  - Custom rule builder with weights
  - Rule testing and preview
  - Rule sharing and templates

- [ ] **CONT-015E**: Implement score-based prioritization:
  - Sort contacts by score
  - Filter by score ranges
  - Score-based smart lists
  - Score change notifications

### Tests
- [ ] Scoring calculations are accurate
- [ ] Score updates trigger correctly
- [ ] Custom rules work as expected
- [ ] Score-based sorting and filtering work
- [ ] Score suggestions are helpful

### Definition of Done
- Contact scoring system with customizable rules
- Score display and breakdown
- Scoring rule editor with templates
- Score-based prioritization features
- Integration with smart lists

### Anti-Patterns
- ❌ Opaque scoring algorithms — users can't understand scores
- ❌ Not allowing rule customization — inflexible system
- ❌ Over-weighting single criteria — skewed results
- ❌ Not updating scores regularly — stale prioritization

<!-- ENDSECTION: Task CONT-015 -->

<!-- SECTION: Task CONT-016 -->

## 🗂️ Task CONT-016: Custom Fields & Contact Templates
**Priority:** 🟠 Medium
**Est. Effort:** 2 hours
**Depends On:** CONT-003, CONT-000

### Related Files
`src/components/contacts/CustomFieldEditor.tsx` · `src/components/contacts/ContactTemplateManager.tsx` · `src/hooks/useCustomFields.ts`

### Subtasks

- [ ] **CONT-016A**: Extend domain model for custom fields:
  ```ts
  interface CustomField {
    id: string
    name: string
    type: 'text' | 'number' | 'date' | 'select' | 'multiselect' | 'boolean' | 'url'
    options?: string[]  // For select/multiselect
    required: boolean
    defaultValue?: unknown
    validation?: RegExp
  }

  interface ContactTemplate {
    id: string
    name: string
    description: string
    requiredFields: string[]
    customFields: CustomField[]
    defaultTags: string[]
    icon?: string
  }
  ```

- [ ] **CONT-016B**: Build `CustomFieldEditor` component:
  - Field type selector
  - Field configuration form
  - Validation rule builder
  - Field preview
  - Bulk field operations

- [ ] **CONT-016C**: Build `ContactTemplateManager` component:
  - Template library with pre-built templates
  - Template editor with field configuration
  - Template preview
  - Template sharing and export
  - "Apply template" action

- [ ] **CONT-016D**: Implement `useCustomFields()` hook:
  - Manages custom field CRUD
  - Validates custom field data
  - Applies templates to contacts
  - Handles field type conversions

- [ ] **CONT-016E**: Add pre-built templates:
  - "Client" template (company, industry, contract value)
  - "Vendor" template (service type, rate, contract terms)
  - "Lead" template (source, qualification status, deal value)
  - "Personal" template (birthday, anniversary, relationship type)

- [ ] **CONT-016F**: Implement custom field search:
  - Search by custom field values
  - Filter by custom field criteria
  - Custom field in autocomplete
  - Custom field in smart lists

### Tests
- [ ] Custom fields save and display correctly
- [ ] Field validation works as expected
- [ ] Templates apply correctly to contacts
- [ ] Custom field search and filtering work
- [ ] Field type conversions handle edge cases

### Definition of Done
- Custom field system with multiple field types
- Contact template manager with pre-built templates
- Custom field validation and search
- Template sharing and export
- Integration with existing contact features

### Anti-Patterns
- ❌ Too many custom field types — complexity for users
- ❌ Missing validation — poor data quality
- ❌ Not supporting field deletion — data bloat
- ❌ Not providing field type conversions — data loss

<!-- ENDSECTION: Task CONT-016 -->

<!-- SECTION: Task CONT-017 -->

## 📧 Task CONT-017: Email Sequences & Outreach Automation
**Priority:** 🟢 Low
**Est. Effort:** 2 hours
**Depends On:** CONT-012, CONT-000

### Related Files
`src/components/contacts/EmailSequenceBuilder.tsx` · `src/services/emailSequenceService.ts` · `src/hooks/useEmailSequences.ts`

### Subtasks

- [ ] **CONT-017A**: Create `src/services/emailSequenceService.ts`:
  ```ts
  interface EmailStep {
    id: string
    subject: string
    body: string
    delay: number  // Hours/days after previous step
    conditions?: Record<string, unknown>
  }

  interface EmailSequence {
    id: string
    name: string
    description: string
    steps: EmailStep[]
    trigger: SequenceTrigger
    enabled: boolean
  }

  interface SequenceTrigger {
    type: 'manual' | 'contact_created' | 'tag_added' | 'date_based'
    conditions: Record<string, unknown>
  }
  ```

- [ ] **CONT-017B**: Build `EmailSequenceBuilder` component:
  - Visual sequence editor with step cards
  - Rich text editor for email content
  - Variable insertion ({{firstName}}, {{company}}, etc.)
  - Delay configuration between steps
  - Sequence preview and testing
  - Pre-built sequence templates

- [ ] **CONT-017C**: Implement `useEmailSequences()` hook:
  - Manages sequence CRUD
  - Triggers sequences based on conditions
  - Tracks sequence progress per contact
  - Handles sequence errors and retries

- [ ] **CONT-017D**: Add sequence analytics:
  - Open rate tracking
  - Click rate tracking
  - Response rate tracking
  - Sequence completion rate
  - A/B testing for sequences

- [ ] **CONT-017E**: Implement sequence management:
  - Pause/resume sequences
  - Skip steps in sequence
  - Bulk sequence assignment
  - Sequence templates library
  - Sequence sharing

### Tests
- [ ] Sequences execute in correct order
- [ ] Delays work as configured
- [ ] Variable substitution works correctly
- [ ] Sequence analytics track accurately
- [ ] Bulk operations work efficiently

### Definition of Done
- Email sequence builder with rich text editor
- Variable substitution and personalization
- Sequence analytics and tracking
- Pre-built sequence templates
- Integration with email client (mock)

### Anti-Patterns
- ❌ Not respecting email sending limits — spam risk
- ❌ Missing unsubscribe mechanism — compliance issue
- ❌ Not tracking sequence errors — silent failures
- ❌ Too complex sequence builder — poor UX

<!-- ENDSECTION: Task CONT-017 -->

<!-- SECTION: Task CONT-018 -->

## 🗂️ Task CONT-018: Advanced Duplicate Management
**Priority:** 🟠 Medium
**Est. Effort:** 2 hours
**Depends On:** CONT-009, CONT-000

### Related Files
`src/components/contacts/DuplicateManager.tsx` · `src/services/duplicateService.ts` · `src/hooks/useDuplicateDetection.ts`

### Subtasks

- [ ] **CONT-018A**: Create `src/services/duplicateService.ts`:
  ```ts
  interface DuplicateGroup {
    id: string
    contactIds: string[]
    confidence: number  // 0-1, how likely these are duplicates
    matchReasons: string[]
    suggestedAction: 'merge' | 'keep_separate' | 'review'
  }

  interface MergeStrategy {
    field: string
    strategy: 'newest' | 'oldest' | 'most_complete' | 'manual'
  }
  ```

- [ ] **CONT-018B**: Build `DuplicateManager` component:
  - Duplicate detection dashboard
  - Duplicate group cards with match reasons
  - Side-by-side contact comparison
  - Merge strategy selector per field
  - Bulk merge operations
  - Duplicate review queue

- [ ] **CONT-018C**: Implement `useDuplicateDetection()` hook:
  - Runs duplicate detection algorithm
  - Groups potential duplicates
  - Calculates match confidence
  - Suggests merge strategies
  - Tracks merge history

- [ ] **CONT-018D**: Add duplicate detection rules:
  - Exact match (email, phone)
  - Fuzzy match (name similarity)
  - Company + title match
  - Custom match rules
  - Exclusion rules

- [ ] **CONT-018E**: Implement merge preview:
  - Show what will be merged
  - Highlight conflicts
  - Allow manual field selection
  - Preview merged contact
  - Undo merge capability

### Tests
- [ ] Duplicate detection finds true duplicates
- [ ] Match confidence is accurate
- [ ] Merge operations preserve correct data
- [ ] Undo merge restores original contacts
- [ ] Custom rules work as expected

### Definition of Done
- Advanced duplicate detection with fuzzy matching
- Visual duplicate manager with comparison
- Customizable merge strategies
- Merge preview and undo
- Bulk duplicate operations

### Anti-Patterns
- ❌ Aggressive auto-merge — data loss risk
- ❌ Not showing merge preview — surprises users
- ❌ Missing undo functionality — irreversible mistakes
- ❌ Not allowing custom rules — inflexible detection

<!-- ENDSECTION: Task CONT-018 -->

<!-- SECTION: Task CONT-019 -->

## 📜 Task CONT-019: Contact History & Audit Trail
**Priority:** 🟢 Low
**Est. Effort:** 1.5 hours
**Depends On:** CONT-003, CONT-000

### Related Files
`src/components/contacts/ContactHistory.tsx` · `src/services/auditService.ts` · `src/hooks/useContactHistory.ts`

### Subtasks

- [ ] **CONT-019A**: Create `src/services/auditService.ts`:
  ```ts
  interface AuditEntry {
    id: string
    contactId: string
    action: 'created' | 'updated' | 'deleted' | 'merged' | 'field_changed'
    field?: string
    oldValue?: unknown
    newValue?: unknown
    userId: string
    timestamp: string
    ipAddress?: string
  }
  ```

- [ ] **CONT-019B**: Build `ContactHistory` component:
  - Reverse-chronological audit log
  - Filter by action type, user, date range
  - Diff view for field changes
  - Export audit log
  - Restore from history point

- [ ] **CONT-019C**: Implement `useContactHistory()` hook:
  - Fetches audit log for contact
  - Filters and paginates entries
  - Provides diff between versions
  - Handles restore operations

- [ ] **CONT-019D**: Add audit logging:
  - Log all contact mutations
  - Log field-level changes
  - Log merge operations
  - Log access events (if audit enabled)

- [ ] **CONT-019E**: Implement history restore:
  - Restore contact to previous state
  - Restore specific fields
  - Bulk restore operations
  - Restore confirmation with preview

### Tests
- [ ] All mutations are logged
- [ ] Audit log displays correctly
- [ ] Diff view shows accurate changes
- [ ] Restore operations work correctly
- [ ] Filtering and search work

### Definition of Done
- Complete audit trail for all contact changes
- Visual history component with diff view
- Restore functionality with preview
- Exportable audit logs
- Privacy controls for audit data

### Anti-Patterns
- ❌ Not logging field-level changes — incomplete history
- ❌ Missing restore functionality — read-only audit
- ❌ Not protecting audit logs — tampering risk
- ❌ Storing sensitive data in audit — privacy risk

<!-- ENDSECTION: Task CONT-019 -->

<!-- SECTION: Task CONT-020 -->

## ⭐ Task CONT-020: Contact Favorites & Quick Access
**Priority:** 🟢 Low
**Est. Effort:** 1 hour
**Depends On:** CONT-002, CONT-001

### Related Files
`src/components/contacts/FavoritesPanel.tsx` · `src/hooks/useContactFavorites.ts`

### Subtasks

- [ ] **CONT-020A**: Extend domain model:
  ```ts
  interface Contact {
    // ... existing fields
    isFavorite: boolean
    favoriteCategory?: 'frequent' | 'important' | 'vip' | 'custom'
    lastContacted: string
  }
  ```

- [ ] **CONT-020B**: Build `FavoritesPanel` component:
  - Star/favorite toggle in contact list
  - Favorites section in sidebar
  - Favorite categories with icons
  - Quick access to recently contacted
  - Drag to reorder favorites

- [ ] **CONT-020C**: Implement `useContactFavorites()` hook:
  - Toggles favorite status
  - Manages favorite categories
  - Tracks recently contacted
  - Provides favorite statistics

- [ ] **CONT-020D**: Add favorite smart lists:
  - "Favorites" smart list
  - "Recently contacted" smart list
  - "Frequently contacted" smart list
  - Custom favorite categories

- [ ] **CONT-020E**: Implement quick actions:
  - Keyboard shortcut to favorite (⌘+F)
  - Favorite from autocomplete
  - Bulk favorite operations
  - Favorite sharing

### Tests
- [ ] Favorite toggle works correctly
- [ ] Favorites display in sidebar
- [ ] Recently contacted updates accurately
- [ ] Keyboard shortcut works
- [ ] Bulk operations work

### Definition of Done
- Favorite system with categories
- Quick access to important contacts
- Recently contacted tracking
- Favorite smart lists
- Keyboard shortcuts for favorites

### Anti-Patterns
- ❌ No organization of favorites — becomes cluttered
- ❌ Not syncing favorites across devices — inconsistent experience
- ❌ Too many favorite categories — decision paralysis
- ❌ Missing bulk operations — tedious for power users

<!-- ENDSECTION: Task CONT-020 -->

<!-- SECTION: Task CONT-021 -->

## 🔍 Task CONT-021: Advanced Search & Saved Queries
**Priority:** 🟠 Medium
**Est. Effort:** 1.5 hours
**Depends On:** CONT-002, CONT-000

### Related Files
`src/components/contacts/AdvancedSearch.tsx` · `src/components/contacts/SavedQueries.tsx` · `src/hooks/useContactSearch.ts`

### Subtasks

- [ ] **CONT-021A**: Build `AdvancedSearch` component:
  - Multi-field search builder
  - Boolean operators (AND, OR, NOT)
  - Field-specific operators (contains, equals, greater than, etc.)
  - Search preview with result count
  - Save search as query
  - Recent searches history

- [ ] **CONT-021B**: Build `SavedQueries` component:
  - Saved query library
  - Query naming and organization
  - Query sharing and export
  - Query execution with one click
  - Query editing and deletion

- [ ] **CONT-021C**: Implement `useContactSearch()` hook:
  - Executes advanced search queries
  - Manages saved queries
  - Provides search suggestions
  - Caches search results

- [ ] **CONT-021D**: Add search operators:
  - Text operators: contains, starts with, ends with, equals
  - Number operators: =, ≠, >, <, ≥, ≤
  - Date operators: before, after, between
  - Boolean operators: AND, OR, NOT
  - Field-specific operators (e.g., "phone matches pattern")

- [ ] **CONT-021E**: Implement search analytics:
  - Most used searches
  - Zero-result searches
  - Search performance metrics
  - Search suggestion accuracy

### Tests
- [ ] Advanced search returns correct results
- [ ] Boolean operators work as expected
- [ ] Saved queries execute correctly
- [ ] Search preview is accurate
- [ ] Search analytics track correctly

### Definition of Done
- Advanced search with multi-field queries
- Boolean operators and field-specific operators
- Saved query library with sharing
- Search preview and suggestions
- Search analytics

### Anti-Patterns
- ❌ Too complex search UI — poor usability
- ❌ Not providing search preview — users don't know what they'll get
- ❌ Missing boolean operators — limited search power
- ❌ Not caching search results — performance issues

<!-- ENDSECTION: Task CONT-021 -->

<!-- SECTION: Task CONT-022 -->

## 📁 Task CONT-022: Contact Groups & Collections
**Priority:** 🟢 Low
**Est. Effort:** 1.5 hours
**Depends On:** CONT-008, CONT-000

### Related Files
`src/components/contacts/GroupManager.tsx` · `src/hooks/useContactGroups.ts`

### Subtasks

- [ ] **CONT-022A**: Extend domain model:
  ```ts
  interface ContactGroup {
    id: string
    name: string
    description?: string
    color: string
    icon?: string
    contactIds: string[]
    isSmart: boolean
    smartRules?: SmartGroupRules
    createdAt: string
    updatedAt: string
  }

  interface SmartGroupRules {
    conditions: GroupCondition[]
    operator: 'AND' | 'OR'
  }

  interface GroupCondition {
    field: string
    operator: string
    value: unknown
  }
  ```

- [ ] **CONT-022B**: Build `GroupManager` component:
  - Group list with color coding
  - Drag contacts to groups
  - Group creation and editing
  - Smart group builder
  - Group statistics (contact count, etc.)
  - Group sharing

- [ ] **CONT-022C**: Implement `useContactGroups()` hook:
  - Manages group CRUD
  - Handles drag-and-drop operations
  - Evaluates smart group rules
  - Provides group statistics

- [ ] **CONT-022D**: Add group features:
  - Nested groups (parent/child)
  - Group-specific notes
  - Group-based bulk operations
  - Group export
  - Group templates

- [ ] **CONT-022E**: Implement smart groups:
  - Auto-populate based on rules
  - Real-time rule evaluation
  - Rule testing and preview
  - Smart group suggestions

### Tests
- [ ] Groups create and display correctly
- [ ] Drag-and-drop works
- [ ] Smart groups evaluate rules correctly
- [ ] Nested groups work as expected
- [ ] Group statistics are accurate

### Definition of Done
- Contact groups with drag-and-drop
- Smart groups with rule engine
- Nested group support
- Group-based bulk operations
- Group sharing and export

### Anti-Patterns
- ❌ Too many nesting levels — confusing hierarchy
- ❌ Smart groups not updating in real-time — stale data
- ❌ Missing group statistics — no visibility
- ❌ Not supporting group operations — manual work

<!-- ENDSECTION: Task CONT-022 -->

<!-- SECTION: Task CONT-023 -->

## 📝 Task CONT-023: Rich Text Notes & Attachments
**Priority:** 🟢 Low
**Est. Effort:** 1.5 hours
**Depends On:** CONT-003, CONT-000

### Related Files
`src/components/contacts/RichTextNoteEditor.tsx` · `src/hooks/useContactNotes.ts`

### Subtasks

- [ ] **CONT-023A**: Extend domain model:
  ```ts
  interface ContactNote {
    id: string
    contactId: string
    content: string  // Rich text HTML
    attachments: Attachment[]
    createdAt: string
    updatedAt: string
    createdBy: string
  }

  interface Attachment {
    id: string
    name: string
    type: string
    size: number
    url: string
  }
  ```

- [ ] **CONT-023B**: Build `RichTextNoteEditor` component:
  - Rich text editor (bold, italic, lists, links)
  - Markdown support
  - Attachment upload (drag-and-drop)
  - Note history/versions
  - Note sharing
  - @mention contacts in notes

- [ ] **CONT-023C**: Implement `useContactNotes()` hook:
  - Manages note CRUD
  - Handles attachment uploads
  - Tracks note versions
  - Provides note search

- [ ] **CONT-023D**: Add note features:
  - Note templates
  - Note pinning
  - Note reminders
  - Note export (Markdown, PDF)
  - Collaborative notes (mock)

### Tests
- [ ] Rich text editor saves correctly
- [ ] Attachments upload and display
- [ ] Note history works
- [ ] @mentions resolve correctly
- [ ] Note export works

### Definition of Done
- Rich text note editor with formatting
- Attachment support for notes
- Note history and versions
- Note templates and pinning
- @mention support in notes

### Anti-Patterns
- ❌ Too complex rich text editor — bloated UI
- ❌ Not handling attachment errors — confusing UX
- ❌ Missing note history — can't revert changes
- ❌ Not supporting @mentions — poor collaboration

<!-- ENDSECTION: Task CONT-023 -->

<!-- SECTION: Task CONT-024 -->

## 👥 Task CONT-024: Contact Sharing & Permissions
**Priority:** 🟢 Low
**Est. Effort:** 2 hours
**Depends On:** CONT-001, CONT-000

### Related Files
`src/components/contacts/ShareDialog.tsx` · `src/services/permissionService.ts` · `src/hooks/useContactSharing.ts`

### Subtasks

- [ ] **CONT-024A**: Create `src/services/permissionService.ts`:
  ```ts
  interface Permission {
    userId: string
    level: 'view' | 'edit' | 'admin' | 'owner'
  }

  interface SharedContact {
    contactId: string
    permissions: Permission[]
    sharedBy: string
    sharedAt: string
    expiresAt?: string
  }
  ```

- [ ] **CONT-024B**: Build `ShareDialog` component:
  - User/team selector for sharing
  - Permission level selector
  - Expiration date option
  - Share link generation
  - Shared users list
  - Permission management

- [ ] **CONT-024C**: Implement `useContactSharing()` hook:
  - Manages share operations
  - Handles permission changes
  - Revokes access
  - Tracks sharing history

- [ ] **CONT-024D**: Add sharing features:
  - Share individual contacts
  - Share contact groups
  - Share with teams
  - Share link with password
  - Sharing notifications

- [ ] **CONT-024E**: Implement permission enforcement:
  - Enforce view/edit permissions
  - Show permission indicators
  - Handle permission errors
  - Audit sharing activity

### Tests
- [ ] Sharing works correctly
- [ ] Permissions are enforced
- [ ] Share links work
- [ ] Permission changes apply immediately
- [ ] Sharing audit logs correctly

### Definition of Done
- Contact sharing with users and teams
- Granular permission levels
- Share link generation
- Permission enforcement
- Sharing audit trail

### Anti-Patterns
- ❌ Over-sharing by default — privacy risk
- ❌ Not enforcing permissions — data leakage
- ❌ Missing sharing audit — compliance risk
- ❌ No expiration on shares — permanent access

<!-- ENDSECTION: Task CONT-024 -->

<!-- SECTION: Task CONT-025 -->

## 🌡️ Task CONT-025: Activity Heatmaps & Engagement Patterns
**Priority:** 🟢 Low
**Est. Effort:** 1.5 hours
**Depends On:** CONT-007, CONT-013

### Related Files
`src/components/contacts/ActivityHeatmap.tsx` · `src/hooks/useActivityHeatmap.ts`

### Subtasks

- [ ] **CONT-025A**: Build `ActivityHeatmap` component:
  - Calendar-style heatmap (GitHub contribution style)
  - Color intensity based on interaction count
  - Hover shows interaction details
  - Filter by interaction type
  - Date range selector
  - Export heatmap image

- [ ] **CONT-025B**: Implement `useActivityHeatmap()` hook:
  - Calculates interaction density
  - Generates heatmap data
  - Identifies engagement patterns
  - Provides insights

- [ ] **CONT-025C**: Add pattern detection:
  - Weekly engagement patterns
  - Seasonal trends
  - Dormancy periods
  - Peak activity times
  - Streak detection

- [ ] **CONT-025D**: Implement heatmap interactions:
  - Click date to see interactions
  - Filter heatmap by contact
  - Compare multiple contacts
  - Heatmap for groups

### Tests
- [ ] Heatmap displays correctly
- [ ] Color intensity matches interaction count
- [ ] Hover shows accurate details
- [ ] Pattern detection works
- [ ] Filtering works correctly

### Definition of Done
- Activity heatmap visualization
- Engagement pattern detection
- Interactive heatmap with drill-down
- Multi-contact comparison
- Export functionality

### Anti-Patterns
- ❌ Too many color levels — confusing visualization
- ❌ Not handling zero-activity periods — misleading
- ❌ Missing context for patterns — data without meaning
- ❌ Not responsive on mobile — poor UX

<!-- ENDSECTION: Task CONT-025 -->

<!-- SECTION: Task CONT-026 -->

## 🗂️ Task CONT-026: Contact Validation & Data Quality
**Priority:** 🟠 Medium
**Est. Effort:** 1.5 hours
**Depends On:** CONT-003, CONT-000

### Related Files
`src/components/contacts/DataQualityPanel.tsx` · `src/services/validationService.ts` · `src/hooks/useContactValidation.ts`

### Subtasks

- [ ] **CONT-026A**: Create `src/services/validationService.ts`:
  ```ts
  interface ValidationRule {
    id: string
    name: string
    field: string
    validator: (value: unknown) => ValidationResult
    severity: 'error' | 'warning' | 'info'
  }

  interface ValidationResult {
    valid: boolean
    message?: string
    suggestions?: string[]
  }

  interface DataQualityReport {
    contactId: string
    score: number  // 0-100
    issues: ValidationIssue[]
    lastChecked: string
  }
  ```

- [ ] **CONT-026B**: Build `DataQualityPanel` component:
  - Overall data quality score
  - Issue list with severity
  - Fix suggestions with one-click apply
  - Validation rule editor
  - Bulk validation
  - Quality trends chart

- [ ] **CONT-026C**: Implement `useContactValidation()` hook:
  - Runs validation rules
  - Calculates quality scores
  - Provides fix suggestions
  - Tracks quality over time

- [ ] **CONT-026D**: Add validation rules:
  - Email format validation
  - Phone number format validation
  - Required field checks
  - Duplicate field detection
  - Outdated data detection
  - Custom validation rules

- [ ] **CONT-026E**: Implement automated fixes:
  - Format phone numbers
  - Normalize email addresses
  - Remove duplicates
  - Fill missing defaults
  - Bulk fix operations

### Tests
- [ ] Validation rules work correctly
- [ ] Quality scores are accurate
- [ ] Fix suggestions are helpful
- [ ] Automated fixes work safely
- [ ] Bulk validation performs well

### Definition of Done
- Contact validation with custom rules
- Data quality scoring
- One-click fix suggestions
- Automated fix operations
- Quality tracking over time

### Anti-Patterns
- ❌ Over-aggressive auto-fixes — data corruption risk
- ❌ Not allowing rule customization — inflexible validation
- ❌ Missing severity levels — can't prioritize issues
- ❌ Not providing fix suggestions — manual work required

<!-- ENDSECTION: Task CONT-026 -->

<!-- SECTION: Task CONT-027 -->

## 💾 Task CONT-027: Backup & Restore
**Priority:** 🟢 Low
**Est. Effort:** 1.5 hours
**Depends On:** CONT-009, CONT-010

### Related Files
`src/components/contacts/BackupManager.tsx` · `src/services/backupService.ts` · `src/hooks/useContactBackup.ts`

### Subtasks

- [ ] **CONT-027A**: Create `src/services/backupService.ts`:
  ```ts
  interface Backup {
    id: string
    name: string
    createdAt: string
    size: number
    contactCount: number
    includes: string[]  // contacts, interactions, relationships, etc.
    encrypted: boolean
  }

  interface RestoreOptions {
    overwrite: boolean
    mergeStrategy: 'merge' | 'replace' | 'skip'
    selectedItems?: string[]
  }
  ```

- [ ] **CONT-027B**: Build `BackupManager` component:
  - Backup creation with options
  - Backup list with details
  - Restore with preview
  - Scheduled backups
  - Backup encryption
  - Backup export/import

- [ ] **CONT-027C**: Implement `useContactBackup()` hook:
  - Creates backups
  - Lists available backups
  - Restores from backup
  - Manages scheduled backups
  - Handles backup encryption

- [ ] **CONT-027D**: Add backup features:
  - Automatic scheduled backups
  - Incremental backups
  - Backup compression
  - Backup validation
  - Backup to cloud (mock)
  - Backup retention policy

- [ ] **CONT-027E**: Implement restore options:
  - Full restore
  - Selective restore (by contact, group, date)
  - Merge vs replace options
  - Restore preview with diff
  - Restore rollback

### Tests
- [ ] Backups create correctly
- [ ] Restore operations work
- [ ] Scheduled backups run
- [ ] Encryption works
- [ ] Restore preview is accurate

### Definition of Done
- Manual and scheduled backups
- Restore with preview and options
- Backup encryption
- Incremental backups
- Backup retention policy

### Anti-Patterns
- ❌ Not validating backups — corrupt restores
- ❌ No restore preview — surprises users
- ❌ Missing encryption — security risk
- ❌ No retention policy — storage bloat

**Core Features:**
- [ ] Contact detail view with all field types and privacy controls
- [ ] Quick Add with smart parsing and mobile capture
- [ ] AI-powered enrichment with social profiles and company data
- [ ] Relationship mapping and network visualization
- [ ] Communication timeline with interaction tracking
- [ ] Tag system with smart lists and automation
- [ ] Import/export for vCard and CSV formats

**Advanced Features:**
- [ ] Workflow automation with visual builder and follow-up reminders
- [ ] Contact analytics dashboard with network insights
- [ ] Social media integration and interaction tracking
- [ ] Contact scoring and prioritization system
- [ ] Custom fields and contact templates
- [ ] Email sequences and outreach automation
- [ ] Advanced duplicate management with fuzzy matching
- [ ] Contact history and audit trail
- [ ] Contact favorites and quick access
- [ ] Advanced search with saved queries
- [ ] Contact groups and smart collections
- [ ] Rich text notes with attachments
- [ ] Contact sharing and permissions
- [ ] Activity heatmaps and engagement patterns
- [ ] Contact validation and data quality
- [ ] Backup and restore functionality

**Integration:**
- [ ] Cross-module autocomplete in Calendar, Projects, and Chat
- [ ] Contact references and linking across modules
- [ ] Bidirectional data synchronization
- [ ] Module-specific contact features (attendees, team members, mentions)

**Quality & Polish:**
- [ ] Offline support with Dexie persistence and sync queue
- [ ] Privacy controls with field-level restrictions
- [ ] Accessibility compliance (WCAG 2.2 AA)
- [ ] Performance optimization for large contact lists
- [ ] Comprehensive testing coverage
- [ ] Error handling and conflict resolution

<!-- ENDSECTION: Task CONT-027 -->
