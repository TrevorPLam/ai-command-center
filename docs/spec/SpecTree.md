## Top‑Level Layout

```
spec/
├── 00-INDEX.md                   # Master lexicon, global rules, module registry
├── foundation/                    # Shell, providers, state, routing
├── dashboard/                     # Dashboard ambient UI, agent fleet, activity feed
├── chat/                          # Real‑time AI chat, streaming, slash commands
├── workflows/                     # Visual workflow canvas, agent orchestration
├── projects/                      # Full project management suite
│   ├── core/                      # Project listing, detail, task management
│   ├── views/                     # Kanban, timeline, my‑week, workload
│   ├── triage/                    # Unified triage inbox
│   └── automation/                # Workflow automation, repeating work
├── calendar/                      # Calendar views, event management, recurrence
├── email/                         # Email client with AI features
├── contacts/                      # Contact management, relationship mapping
├── conference/                    # Video conferencing, roundtable layout
├── translation/                   # Real‑time multi‑speaker translation
├── news/                          # Intelligent news reader
├── documents/                     # Document storage with AI Q&A
├── research/                      # Learning hub with flashcards, mind maps, reports
├── media/                         # Media library with AI generation
├── budget/                        # Financial calendar, budgeting, investments
├── settings/                      # All application settings
├── platform/                      # Error boundaries, env validation, motion audit
├── crosscutting/                  # Architecture, auth, notifications, search, i18n
├── data/                          # Database schemas, vector store, caching strategies
├── ai/                            # AI/ML platform: models, RAG, agents, safety
├── frontend-clients/              # Web, desktop, mobile specifics
├── integrations/                  # Nylas, LiveKit, Stripe, external services
├── ops/                           # CI/CD, runbooks, monitoring, feature flags
├── security/                      # Encryption, audit, compliance, model security
├── testing/                       # Test strategy, coverage targets, tooling
├── product-design/                # Personas, wireframes, content strategy
├── business-legal/                # Pricing, licensing, GDPR, ToS
├── contracts/                     # Reusable definitions: patterns, motion, hard rules
├── docs/                          # Internal & external documentation plans
├── research-futures/              # Emerging tech, plugin ecosystem
└── scripts/                       # Source‑of‑truth validation & multi‑format generators
```

---

## Detailed Breakdown

### `00-INDEX.md`
Central nervous system:  
- Lexicon table (all abbreviations)  
- Global rule table (S1‑S21, B1‑B8, etc.)  
- Module manifest linking every `spec/` file to owner, status, dependencies  
- Version pins for all major packages  
Written in Plan3‑style tables; auto‑consulted by generation scripts.

### `foundation/`
The application shell, shared providers, and architectural backbone.

```
foundation/
├── app-shell.md              # Overall layout, skip‑link, focus management
├── providers.md              # QueryClient, Theme, Auth, LiveKit, Helmet providers
├── sidebar.md                # Glass sidebar, navigation items, org switcher
├── command-palette.md        # Cmd‑K menu, voice shell stubs
├── status-bar.md             # Fixed bottom bar, storage indicators
├── right-panel.md            # Contextual right panel, focus restore
├── state/                    # Zustand slices (one file per slice)
│   ├── ui-slice.md
│   ├── auth-slice.md
│   ├── org-slice.md
│   └── ...
├── router/                   # React Router v7 configuration
│   ├── routes.md
│   ├── lazy-loading.md
│   └── guard-components.md
├── query-client.md           # TanStack Query defaults, key factory patterns
├── motion-tokens.md          # Spring presets, duration tokens, useShouldAnimate
├── offline/                  # Dexie setup, storage quota, sync primitives
│   ├── command-center-db.md
│   ├── storage-quota.md
│   └── offline-sync.md
├── accessibility.md          # SkipLink, focus traps, live regions
└── performance.md            # LCP/INP/CLS budgets, lazy loading, image optimization
```

**Reasoning:** Every piece of foundational infrastructure is isolated so that changes to the sidebar, for example, don’t touch any other spec.

### `dashboard/`
Ambient awareness and AI agent monitoring.

```
dashboard/
├── ambient-status-banner.md  # Animated banner showing agent activity
├── agent-fleet-panel.md      # Grid of agent cards, layout morphing
├── agent-card.md             # Individual card with status pulses, hover effects
├── agent-detail-drawer.md    # Slide‑out detail with token usage, tasks
├── activity-feed.md          # Virtualized real‑time agent action log
├── activity-entry.md         # Single feed item, expandable
├── attention-queue.md        # Decision packets, triage integration
├── decision-packet.md        # Countdown timer, approve/reject defer
└── dashboard-skeleton.md     # Loading states for the dashboard
```

**Reasoning:** Each visual component is complex enough (animation contracts, role/ARIA, mock data, tests) to warrant its own specification.

### `chat/`
Real‑time AI communication, streaming, tool calls, collaboration.

```
chat/
├── chat-page.md              # Two‑column layout, responsive Sheet
├── chat-layout.md            # Resizable panels, mobile adaptation
├── thread-list.md            # Virtualized thread list, search, create
├── thread-list-item.md       # Hover prefetch, unread indicator
├── message-list.md           # Virtualized message log, scroll anchoring
├── message-bubble.md         # Streaming text, user/agent styling
├── typing-indicator.md       # Animated dots, reduced motion guard
├── chat-input.md             # Auto‑sizing textarea, LED border, shortcuts
├── slash-menu.md             # Slash command palette, built‑in + MCP tools
├── streaming/                # SSE transport, token accumulation
│   ├── use-sse-stream.md
│   └── streaming-cursor.md
├── thinking-trace-panel.md   # Collapsible chain‑of‑thought, tool calls
├── checkpoint-banner.md      # Optimistic approve/reject, ARIA assertive
├── collab-canvas.md          # Monaco editor, Y‑Sweet token, layout morph
├── artifact-sandbox.md       # Blob URL iframe, DOMPurify, CSP
├── gen-ui-renderer.md        # Agent‑driven UI from trusted catalog
├── memory-manager.md         # Tiered memory (episodic, semantic)
├── mcp-settings.md           # Tool discovery, approval, audit
├── agent-studio.md           # Browse/clone/import agent definitions
├── prompt-library.md         # Prompt versioning, history
├── a2a-flow-editor.md        # React Flow DAG, keyboard accessible
├── knowledge-base.md         # Client‑side RAG, embeddings, chunking
├── attachments.md            # File upload, image preview, resize
└── media-attachments.md      # (sub‑set of attachments) more specific
```

**Reasoning:** Chat is the most feature‑rich module. Each sub‑system (streaming, sandbox, canvas) has independent contracts, security considerations, and test strategies; splitting prevents specification fatigue.

### `workflows/`
Node‑based visual automation canvas, execution engine, human‑in‑the‑loop.

```
workflows/
├── workflow-canvas.md        # React Flow setup, custom nodes, snap‑to‑grid
├── node-palette.md           # Grouped node types, drag‑from‑palette
├── custom-node-types.md      # Trigger, agent, action, decision, approval, etc.
├── execution-engine.md       # Topological sort, parallel, retry, state machine
├── execution-viewer.md       # Real‑time pulse, step highlighting
├── approval-panel.md         # Human‑in‑the‑loop, escalation
├── manual-input-dialog.md    # Dynamic forms for work input
├── template-library.md       # Pre‑built patterns, parameter substitution
├── workflow-versioning.md    # Dev/staging/prod, rollback
├── workflow-security.md      # RBAC, audit logs, input validation
├── workflow-analytics.md     # Performance metrics, bottlenecks
└── workflow-testing.md       # Dedicated testing strategies
```

### `projects/`
The largest business domain; split into core project management, multiple view modes, triage, and automation.

```
projects/
├── core/
│   ├── domain-model.md           # Types, schemas, query keys
│   ├── project-state.md          # Zustand projectSlice
│   ├── project-list.md           # TanStack Table + Virtual
│   ├── project-list-columns.md   # Column definitions
│   ├── project-detail-page.md    # Header, tabs, inline editing
│   ├── project-detail-header.md  # Editable fields, filing deadlines
│   ├── task-list.md              # Sections, drag‑and‑drop reorder
│   ├── task-detail-drawer.md     # Checklist, comments, activity
│   ├── quick-peek-overlay.md     # Hover preview, quick actions
│   ├── project-templates.md      # Save as template, apply template
│   └── global-search.md          # Cross‑project search dialog
├── views/
│   ├── view-switcher.md          # Layout‑Id active pill
│   ├── filter-bar.md             # useTransition‑powered filters
│   ├── kanban/
│   │   ├── kanban-view.md        # dnd‑kit columns, optimistic moves
│   │   ├── kanban-card.md        # Drag overlay, WCAG alt
│   │   └── kanban-column.md      # Column header, capacity indicators
│   ├── timeline/
│   │   ├── timeline-view.md      # SVAR Gantt, zoom controls
│   │   └── timeline-bar.md       # CSS animation, drag‑to‑reschedule
│   ├── my-week/
│   │   ├── my-week-view.md       # Six swim lanes, cross‑lane drag
│   │   └── colleague-week.md     # Colleague dropdown, capacity
│   └── workload/
│       ├── workload-view.md      # Recharts bar chart, capacity line
│       └── utilization-panel.md  # Colleague summary table
├── triage/
│   ├── triage-page.md            # Unified stream, virtualized
│   ├── triage-item.md            # Color‑coded entry, keyboard shortcuts
│   ├── triage-action-tray.md     # Timeline, MyWeek, assignment
│   ├── triage-delegation.md      # Grant/revoke, view‑as colleague
│   └── triage-integration.md     # Agent outputs, decisions, mentions
├── automation/
│   ├── automation-rules.md       # Global & tasklist automators
│   ├── rule-builder.md           # Trigger → condition → action UI
│   └── recurring-work.md         # Recurrence dialog, schedule list
├── documents/
│   ├── document-panel.md         # Folder tree, upload, preview
│   └── document-uploader.md      # Drag‑and‑drop, size validation
├── time-budget/
│   ├── time-budget-panel.md      # Budget bars, member breakdown
│   ├── time-entry-form.md        # Clock in/out, timesheet
│   └── filing-deadlines.md       # Deadline badges, extension management
└── practice-intelligence/
    ├── practice-dashboard.md     # Portfolio performance, agent log
    └── fifo-queue.md             # FIFO visualization, reorder
```

**Reasoning:** The Projects module is a microcosm of the entire app. By giving each view and sub‑feature its own file, we allow parallel contributions, focused testing, and clear ownership.

### `calendar/`
Multi‑view calendar, event management, recurrence, timezones.

```
calendar/
├── calendar-page.md            # Responsive layout, mobile Sheet
├── calendar-state.md           # Zustand calendarSlice
├── sidebar/
│   ├── mini-calendar.md        # Month grid, event dots
│   ├── calendar-list.md        # Toggle calendars, add/delete
│   └── event-search.md         # Search panel, filters
├── views/
│   ├── month-view.md           # ARIA grid, right‑click menu
│   ├── week-day-view.md        # withDragAndDrop, current time line
│   ├── resource-week-view.md   # Multi‑calendar columns
│   └── agenda-view.md          # Virtualized list, bulk select
├── event-composer.md           # Modal, conflict detection, recurrence
├── event-detail-drawer.md      # Optimistic delete undo, RSVP
├── recurrence/
│   ├── recurring-edit-modal.md # 3‑mode edit, exception storage
│   └── recurrence-engine.md    # (references shared recurrence)
├── timezone-working-hours.md   # Timezone selector, secondary gutter
├── reminders/
│   ├── reminder-service.md     # Browser notifications, snooze
│   └── reminder-toast.md       # Toast UI
├── import-export/
│   ├── ics-export.md           # RFC 5545 compliance
│   └── ics-import.md           # Preview, conflict resolution
├── bulk-actions.md             # Shift‑click range, bulk bar
└── calendar-integrations/
    ├── external-calendars.md   # Google, Outlook OAuth mock
    └── webcal-subscriptions.md # Shareable feeds
```

### `email/`
Full email client with AI, templates, rules, and offline support.

```
email/
├── email-domain-model.md     # Types, Zod schemas
├── email-security.md         # OAuth token vault, encryption
├── email-state.md            # Zustand emailSlice
├── email-page.md             # Three‑panel layout, resizable
├── account-management/
│   ├── account-sidebar.md    # Folder tree, drag to folder
│   ├── add-account-modal.md  # OAuth flow stubs
│   └── account-switcher.md   # Unified inbox vs single account
├── inbox/
│   ├── unified-inbox.md      # Merged virtual list, account colors
│   ├── email-list-item.md    # Bulk select, star, read status
│   └── focused-inbox.md      # AI importance scoring
├── thread-view/
│   ├── thread-view.md        # Conversation display, expand/collapse
│   └── message-body.md       # SanitizedHTML rendering
├── compose/
│   ├── compose-window.md     # Rich text, attachments, send later
│   ├── undo-send.md          # Countdown, cancellation
│   └── smart-compose.md      # AI ghost text, suggested replies
├── attachments/
│   ├── attachment-viewer.md  # Preview modal, security indicators
│   └── attachment-upload.md  # Drag‑and‑drop, progress
├── search-filters/
│   ├── email-search.md       # Advanced operators, debounce
│   └── filter-panel.md       # Date, has:attachment, labels
├── snooze.md                 # Snooze modal, presets, custom times
├── templates-signatures/
│   ├── template-manager.md   # Canned responses, variables
│   └── signature-editor.md   # Rich text, per‑account
├── rules-automation/
│   ├── rule-builder.md       # Condition → action, priorities
│   └── filter-manager.md     # List/enable rules
├── notifications/
│   ├── notification-settings.md  # Per‑account, quiet hours
│   ├── vacation-responder.md     # Auto‑reply, date ranges
│   └── follow-up-reminders.md    # Reminders for replies
├── contacts/
│   ├── contact-manager.md    # Auto‑extract, star/VIP
│   └── contact-picker.md     # Autocomplete in compose
├── integrations/
│   ├── create-task.md        # Link email to project task
│   ├── calendar-invite.md    # Detect meeting invites
│   └── receipt-extraction.md # Budget transaction creation
├── analytics/
│   ├── email-volume-chart.md
│   └── response-time-chart.md
├── security/
│   ├── phishing-warning.md   # Suspicious link/sender detection
│   └── encryption.md         # PGP/S/MIME stubs
└── keyboard-shortcuts.md     # Gmail‑style & Superhuman shortcuts
```

### `contacts/`
CRM‑like contact management with enrichment, relationship graphs, and sharing.

```
contacts/
├── domain-model.md             # Types, Zod schemas
├── state-management.md         # contactsSlice, privacy controls
├── contacts-page.md            # Three‑column layout
├── contact-detail.md           # Field display, inline editing
├── contact-field.md            # Multi‑type field component
├── field-editor.md             # Validation, privacy toggles
├── quick-add.md                # Mobile capture, smart parsing
├── enrichment/
│   ├── enrichment-panel.md     # AI suggestions, social profile
│   ├── enrichment-service.md   # Lookup logic (mock)
│   └── enrichment-queue.md     # Bulk processing
├── relationships/
│   ├── relationship-graph.md   # Force‑directed graph visualization
│   ├── relationship-list.md    # Table view, filters
│   └── relationship-manager.md # Add/edit relationships
├── communications/
│   ├── communication-timeline.md  # Unified interactions list
│   └── interaction-item.md     # Per‑type display
├── tags/
│   ├── tag-manager.md          # Hierarchical tags, smart lists
│   └── tag-suggestions.md      # Auto‑tag logic
├── import-export/
│   ├── import-dialog.md        # vCard/CSV with field mapping
│   └── export-dialog.md        # Privacy controls, format selection
├── workflows/
│   ├── workflow-builder.md     # Follow‑up sequences
│   └── reminder-panel.md       # Contact‑specific reminders
├── analytics/
│   ├── analytics-dashboard.md  # Bento grid, wealth metrics
│   └── network-insights.md     # Density, bridging contacts
├── sharing/
│   ├── share-dialog.md         # Permission levels, links
│   └── permission-service.md   # Enforcement, audit
├── custom-fields/
│   ├── custom-field-editor.md  # Field types, validation
│   └── contact-templates.md    # Pre‑defined field sets
├── duplicates/
│   ├── duplicate-manager.md    # Fuzzy detection, merge preview
│   └── duplicate-service.md    # Scoring algorithm
├── scoring/
│   ├── scoring-service.md      # Rule‑based contact scoring
│   └── scoring-dashboard.md    # Score breakdown, history
├── backup-restore/
│   ├── backup-manager.md       # Scheduled backups, encryption
│   └── restore-options.md      # Selective restore, merge
├── search/
│   ├── advanced-search.md      # Boolean operators, saved queries
│   └── saved-queries.md        # Library, sharing
├── groups/
│   ├── group-manager.md        # Smart groups, drag‑and‑drop
│   └── group-condition.md      # Rule evaluation
├── notes/
│   ├── rich-text-editor.md     # Attachments, @mentions
│   └── note-history.md         # Versioning
└── privacy/
    ├── privacy-controls.md     # Field‑level visibility
    └── audit-log.md            # Access logs
```

**Reasoning:** Contacts is now a full CRM. Each feature (enrichment, relationship graph, scoring) is complex enough to deserve isolation.

### `conference/`
Video conferencing with roundtable layout, breakout rooms, scenarios.

```
conference/
├── conference-page.md          # Dashboard + active session layout
├── roundtable-grid.md          # 4–16 participant video tiles
├── participant-tile.md         # Video, avatar, role, quality
├── roles-permissions.md        # Moderator, participant, observer, recorder
├── role-badge.md               # Visual indicators
├── recording-controls.md       # Pulsing red dot, multi‑format export
├── engagement-tools/
│   ├── chat-panel.md           # Real‑time chat, role‑based styling
│   ├── qa-panel.md             # Upvoting, moderation
│   ├── poll-panel.md           # Live polls, real‑time results
│   └── whiteboard.md           # Collaborative canvas
├── scenario-templates/
│   ├── scenario-library.md     # Advisory board, brainstorming, etc.
│   └── scenario-player.md      # Step‑by‑step, timer
├── breakout-rooms/
│   ├── breakout-manager.md     # Create/assign rooms
│   └── breakout-room.md        # Sub‑conference instance
├── analytics/
│   ├── analytics-dashboard.md  # Participation, speaking time
│   └── session-report.md       # Exportable summary
├── device-settings.md          # Camera, microphone, bandwidth
└── mock-data.md                # WebRTC simulation, test feeds
```

### `translation/`
Real‑time multi‑speaker translation with speaker diarization.

```
translation/
├── domain-contract.md        # Types, Zod schemas, queryOptions
├── mock-data.md              # Factories, MSW, hooks
├── translation-page.md       # Two‑column layout, Sheet mobile
├── speaker-manager.md        # Add/remove speakers, colors
├── speaker-card.md           # Individual card, hover effects
├── translation-display.md    # Split‑screen view, synced scrolling
├── translation-segment.md    # Speaker attribution, streaming text
├── session-controls.md       # Recording, LED border, export
├── streaming-hook.md         # SSE for live translation
└── export-dialog.md          # JSON, TXT, SRT formats
```

### `news/`
AI‑powered news reader with offline support.

```
news/
├── domain-model.md           # Types, schemas, newsKeys
├── state-management.md       # newsSlice, persist
├── news-page.md              # Layout, route, skeleton
├── feed/
│   ├── use-news-feed.md      # Infinite query, dedup, pause buffer
│   ├── news-feed.md           # Virtualized card list
│   ├── news-card.md           # Sentiment, trust, expand/collapse
│   └── infinite-scroll.md     # IntersectionObserver sentinel
├── sidebar/
│   ├── topic-selector.md      # Chip toggles
│   ├── source-manager.md      # Trust tiers, bulk select
│   └── frequency-slider.md    # Pause, dedup, refresh
├── search/
│   ├── search-panel.md        # Highlighted results, keyboard nav
│   └── advanced-filters.md    # Date, sentiment, reading time
├── reader-mode/
│   ├── article-reader.md      # Readability + DOMPurify
│   └── reader-controls.md     # Font, theme, line height
├── bookmarks-read-status/
│   ├── use-bookmarks.md       # Dexie useLiveQuery
│   ├── use-read-status.md     # Bulk mark‑read
│   └── saved-view.md          # Saved articles grid
├── audio/
│   ├── use-audio-summary.md   # Web Speech API, speed control
│   └── audio-player.md        # Floating widget
└── offline/
    ├── offline-sync.md        # PWA, cache‑first
    └── quota-handling.md      # QuotaExceededError toast
```

### `documents/`
Document storage with AI search, OCR, versioning, secure sharing.

```
documents/
├── domain-model-utilities.md     # Types, Zod, formatSize, etc.
├── mock-data-queries.md          # Factories, MSW, queryKeys
├── state-management.md           # documentsSlice
├── browser-views/
│   ├── document-browser.md       # Main layout, folder tree
│   ├── document-grid.md          # Virtualized grid with thumbnails
│   ├── document-list.md          # Table view
│   ├── document-card.md          # Card with thumbnail, actions
│   └── file-preview.md           # Modal for images/PDFs/video
├── file-operations/
│   ├── upload-manager.md         # Queue, progress, cancel
│   ├── move-dialog.md            # Folder tree selector
│   ├── rename-dialog.md          # Inline validation
│   ├── trash-view.md             # 30‑day retention, restore
│   └── download-service.md       # ZIP bundling, progress
├── ocr/
│   ├── ocr-pipeline.md           # Tesseract.js stubs
│   └── ocr-panel.md              # Language selector, progress
├── search/
│   ├── full-text-search.md       # Fuzzy, OCR integration, highlighting
│   ├── filter-panel.md           # Format, tags, date, size
│   └── saved-searches.md         # Named views
├── ai/
│   ├── ai-panel.md               # Summary, Q&A, classification
│   ├── document-qa.md            # Chat interface with citations
│   ├── auto-tagging.md           # AI classification, entity extraction
│   └── metadata-editor.md        # Custom properties, templates
├── version-control/
│   ├── version-history.md        # List, restore, download
│   └── diff-viewer.md            # Text diff, metadata comparison
├── sharing/
│   ├── share-dialog.md           # Password, expiry, permissions
│   └── permissions-panel.md      # User list, inherited permissions
├── collaboration/
│   ├── comment-panel.md          # Threading, @mentions
│   ├── annotations.md            # Tied to document selections
│   └── real-time-collab.md       # Yjs integration, cursor awareness
├── encryption/
│   ├── encryption-badge.md       # Status indicator
│   └── client-encryption.md      # Web Crypto stubs
├── storage-analytics/
│   ├── storage-quota.md          # Progress bar, cleanup suggestions
│   └── duplicate-detection.md    # pHash groups
├── import-export/
│   ├── export-service.md         # ZIP with metadata
│   └── import-service.md         # Folder preservation, conflict
├── offline/
│   ├── offline-status-bar.md
│   └── sync-engine.md
└── route-config.md               # /documents routes, sidebar nav
```

### `research/`
Dedicated learning and research workspace.

```
research/
├── domain-model.md             # Notebooks, documents, mind maps, etc.
├── mock-data.md                # Factories, MSW
├── state-management.md         # researchSlice, study progress
├── research-page.md            # Multi‑pane layout, view switcher
├── document-management/
│   ├── document-upload.md      # Multi‑format, OCR, STT
│   └── document-viewer.md      # Unified viewer for all formats
├── ai-analysis/
│   ├── document-analyzer.md    # Key concepts, difficulty
│   └── ai-summary.md           # Brief/detailed, streaming
├── mind-maps/
│   ├── mind-map-editor.md      # Interactive canvas, drag‑and‑drop
│   ├── mind-map-node.md        # Styling, connections
│   └── knowledge-graph.md      # Network visualization
├── flashcards/
│   ├── flashcard-deck.md       # Grid, search, bulk ops
│   ├── flashcard-reviewer.md   # 3D flip, spaced repetition
│   └── spaced-repetition.md    # SM‑2 algorithm
├── quizzes/
│   ├── quiz-taker.md           # Multiple question types, timer
│   └── quiz-generator.md       # AI‑powered question creation
├── learning-guide/
│   ├── tutoring-chat.md        # Socratic questioning
│   └── adaptive-learning.md    # Difficulty adjustment
├── audio-overviews/
│   ├── audio-generator.md      # Brief, critique, debate formats
│   └── audio-player.md         # Waveform, transcript sync
├── reports/
│   ├── report-generator.md     # Custom types, templates
│   └── report-viewer.md        # Rich text, export
├── collaboration/
│   ├── share-dialog.md         # Permissions, links
│   └── study-groups.md         # Group notebooks, chat
└── cross-module-integration/
    ├── unified-search.md       # Search across all modules
    └── budget-projects-link.md # Research → task, financial insights
```

### `media/`
AI‑enhanced media library with generation.

```
media/
├── domain-model.md             # MediaItem, Album, GenerationPreset
├── state-management.md         # mediaSlice, queue
├── mock-data.md                # Factories, MSW handlers
├── media-page.md               # Grid/list/timeline views, filters
├── media-grid.md               # Virtualized grid, progressive loading
├── media-card.md               # Blur placeholder, context menu
├── media-detail-drawer.md      # Full metadata, editing
├── media-editor.md             # Crop, adjust, filters, undo/redo
├── generation/
│   ├── generation-panel.md     # Prompt form, model selector
│   ├── generation-queue.md     # Progress via SSE, cancel
│   └── generation-presets.md   # Save/load configurations
├── albums/
│   ├── album-sidebar.md        # List, auto‑suggested
│   ├── album-detail.md         # Grid filtered to album
│   └── album-modal.md          # Create/edit
├── ai-tools/
│   ├── people-detection.md     # Face clustering, naming
│   ├── object-removal.md       # AI inpainting
│   ├── upscale-tool.md         # Generative upscale
│   └── scene-enhance.md        # Landscape adjustments
├── search-filters/
│   ├── media-search.md         # Semantic mock, history
│   └── duplicate-drawer.md     # pHash grouping, resolution
├── slideshows/
│   ├── slideshow-builder.md    # Transitions, music, themes
│   └── slideshow-player.md     # Fullscreen, export
├── memories/
│   ├── memories-carousel.md    # Auto‑generated collections
│   └── memory-detail.md        # Slideshow, editing
├── privacy/
│   ├── privacy-panel.md        # Hide/sensitive toggle
│   └── shared-albums.md        # Invitations, permissions
└── storage/
    ├── storage-analytics.md    # Quota, breakdown
    └── storage-cleanup.md      # Large files, old generations
```

### `budget/`
Financial calendar with comprehensive planning.

```
budget/
├── domain-model.md             # Types, Zod, derivations
├── mock-data.md                # Factories, MSW, query keys
├── budget-state.md             # budgetSlice, URL sync
├── budget-page.md              # Route shell, Suspend/Error boundaries
├── overview/
│   ├── budget-dashboard.md     # Net worth, cash flow, charts
│   ├── net-worth-card.md       # Sparkline, breakdown
│   └── cash-flow-summary.md    # Income, expenses, savings rate
├── planner/
│   ├── budget-planner.md       # Category allocation grid
│   └── category-editor.md      # RHF + Zod modal
├── transactions/
│   ├── transaction-list.md     # Virtualized, infinite scroll
│   ├── transaction-calendar.md # react‑big‑calendar, drag‑and‑drop
│   ├── transaction-detail.md   # Drawer, split editor
│   └── transaction-rules.md    # Auto‑categorization, actions
├── goals/
│   ├── goal-card.md            # Progress, feasibility score
│   └── add-goal-modal.md       # RHF + Zod, plan‑it feature
├── accounts/
│   ├── accounts-page.md        # Grouped by type, sync status
│   └── reconciliation.md       # Unmatched, duplicates
├── recurring/
│   ├── recurring-page.md       # Bills & subscriptions, calendar
│   ├── recurring-item-row.md   # Edit toggle, series editing
│   └── cash-flow-forecast.md   # Projected balance, shortfalls
├── investments/
│   ├── investments-page.md     # Portfolio, holdings table
│   └── performance-chart.md    # Time‑range toggle
├── reports/
│   ├── reports-page.md         # Pre‑built and custom reports
│   └── report-data-table.md    # Accessible tabular view
├── import-export/
│   ├── import-modal.md         # CSV mapping, preview
│   └── export-service.md       # CSV generation, progress toast
├── offline/
│   ├── offline-status-bar.md   # Pending changes, sync
│   └── sync-engine.md          # Dexie queue, background sync
├── financial-planning/
│   ├── financial-home.md       # 7‑day timeline, goals, budgets
│   └── home-cash-flow.md       # Daily net totals, bills
└── ai-insights/
    ├── spending-insights.md    # Anomaly detection, call‑to‑action
    └── insights-card.md        # Display component
```

### `settings/`
Centralized settings with strict validation and security.

```
settings/
├── state-persistence.md       # settingsSlice, persist, migration
├── schemas.md                 # All Zod schemas derived from
├── page-layout.md             # Shell, sidebar, navigation
├── core/
│   ├── general-settings.md    # Display name, timezone, language
│   ├── appearance-settings.md # Theme, accent, font size, motion
│   ├── notification-settings.md # Channels, frequency, quiet hours
│   └── analytics-settings.md  # Tracking, retention, download
├── api-keys.md                # Add, reveal, mask, delete
├── memory-integrations/
│   ├── memory-settings.md     # Retention, auto‑summarize, clear
│   └── integrations.md        # Connect/disconnect, sync states
├── export-import.md           # Full data export/import UX
├── danger-zone.md             # Delete data, reset, delete account
└── team-workspace.md          # Members, roles, invitations
```

### `platform/`
Global application‑level utilities and quality gates.

```
platform/
├── env-validation.md          # Zod env schema, fail‑fast
├── error-boundary.md          # Global and route‑level boundaries
├── skip-link.md               # Accessibility cornerstone
├── privacy-banner.md          # Consent banner, telemetry opt‑out
├── accessibility-pass.md      # Automated and manual checklists
├── motion-audit.md            # CI gate for stagger≤3, reduced‑motion
├── performance-budgets.md     # LCP, INP, CLS, bundle size
└── security-headers.md        # CSP documentation, nonce strategy
```

### `crosscutting/`
Systems that span multiple feature modules.

```
crosscutting/
├── architecture/
│   ├── high-level.md          # Monorepo vs polyrepo, event backbone
│   ├── api-strategy.md        # REST/GraphQL, versioning, gateway
│   ├── multi-tenancy.md       # Data isolation, org switching
│   └── service-mesh.md        # Load balancing, inter‑process
├── auth/
│   ├── authentication.md      # Supabase Auth, custom claims, JWT
│   ├── authorization.md       # RBAC, permissions matrix
│   └── session-management.md  # Token refresh, org switching
├── notifications/
│   ├── notification-service.md       # Push, email, in‑app
│   ├── notification-templates.md     # Data model, trigger system
│   └── in-app-notification-ui.md     # Bell icon, feed, preferences
├── search/
│   ├── search-strategy.md     # pg_trgm → pgvector → Typesense phases
│   ├── global-search-api.md   # /v1/search endpoint contract
│   └── search-ui.md           # GlobalSearchDialog component
├── i18n/
│   ├── localization.md        # react‑i18next setup, dynamic load
│   ├── rtl-support.md         # Logical properties, dir attr
│   └── locale-files.md        # Structure of JSON files
├── feature-flags/
│   ├── flag-lifecycle.md      # off→internal→beta→on, 2d dwell
│   └── flag-inventory.md      # Per‑flag hypothesis, owner, ADR
└── billing/
    ├── subscription-model.md  # Tiers, usage‑based billing (Phase2)
    └── stripe-integration.md   # Webhooks, invoicing (Phase2)
```

### `data/`
Databases, caching, and data management strategies.

```
data/
├── database-strategy.md       # PostgreSQL + pgvector, RLS policies
├── schema/                    # One file per table or domain
│   ├── messages.md
│   ├── threads.md
│   ├── projects.md
│   ├── tasks.md
│   ├── events.md
│   ├── ...
│   └── collab-documents.md
├── vector-db.md               # pgvector HNSW config, embedding pipeline
├── time-series.md             # Budget trends, usage metrics
├── caching/
│   ├── redis-strategy.md      # Session store, rate limiting, prefix cache
│   └── client-cache.md        # TanStack Query staleTime/gcTime defaults
├── data-warehouse.md          # Long‑term analytics, aggregated reporting
├── backup-recovery.md         # RPO/RTO, PITR, quarterly restore tests
└── migration-strategy.md      # Nullable→backfill→NOT NULL, Prisma migration
```

### `ai/`
Machine learning platform, model management, safety.

```
ai/
├── model-inventory.md         # gpt-4o, claude-3-7, embeddings, etc.
├── prompt-management/
│   ├── prompt-versioning.md   # Prompt template storage, eval gating
│   ├── prompt-library.md      # UI for browsing/editing prompts
│   └── prompt-testing.md      # A/B testing, side‑by‑side comparison
├── llm-serving/
│   ├── lite-llm-proxy.md      # Configuration, fallback chains
│   └── circuit-breaker.md     # 5 failures/60s → fallback
├── rag/
│   ├── chunking-strategy.md   # Recursive split, overlap
│   ├── embedding-pipeline.md  # text‑embedding-3-small, pgvector
│   └── retrieval-logic.md     # Re‑ranking, metadata filtering
├── agents/
│   ├── agent-framework.md     # Memory, planning, tool use
│   ├── a2a-messaging.md       # Agent‑to‑agent protocol
│   └── agent-studio.md        # Builder, test chat (aliased to chat module)
├── evals/
│   ├── eval-datasets.md       # Schema, creation, curation
│   ├── eval-runs.md           # Batch testing, scoring criteria
│   ├── ci-gate.md             # Promotion blocked if scores degrade
│   └── eval-ui.md             # Dashboard for reviewing eval results
├── safety-guardrails/
│   ├── content-filtering.md   # Prohibited categories, PII redaction
│   ├── hallucination-control.md # Grounding, citation requirements
│   └── adversarial-testing.md # Red‑teaming, injection detection
├── context-management/
│   ├── memory-tiered.md       # Working, episodic, semantic
│   └── context-compression.md # Prefix caching, token optimizations
├── cost-tracking/
│   ├── cost-log-schema.md     # ai_cost_log table
│   ├── cost-dashboard.md      # Per‑org, per‑model budgets
│   └── hard-cap-enforcement.md # LiteLLM rate limiting
└── fine-tuning/
    ├── user-adapters.md       # LoRA per‑user plans (Phase2)
    └── data-flywheel.md       # Feedback collection, annotation
```

### `frontend-clients/`
Specifications for each client platform beyond the main web SPA.

```
frontend-clients/
├── web-app/
│   ├── vite-config.md         # Plugins, build targets, CSP
│   ├── bundle-strategy.md     # manualChunks, size‑limit budgets
│   └── pwa-strategy.md        # Service workers, offline (not MVP)
├── desktop/
│   ├── electron.md            # Auto‑update, offline, native menus
│   └── tauri.md               # Lighter alternative (Phase2)
├── mobile/
│   ├── react-native.md        # Shared code, navigation
│   └── native-features.md     # Camera, push, location
└── design-system/
    ├── tailwind-config.md     # Theme tokens, oklch() palette
    ├── shadcn-theme.md        # Component overrides, dark mode
    ├── ui-kit.md              # Shared component library
    └── accessibility-tokens.md # Contrast ratios, focus indicators
```

### `integrations/`
Third‑party services and external APIs.

```
integrations/
├── nylas/
│   ├── email-sync.md          # OAuth, webhook, grant management
│   ├── calendar-sync.md
│   └── edge-functions.md      # nylas_webhook, HMAC verification
├── livekit/
│   ├── token-endpoint.md      # /v1/livekit/token scoping
│   ├── room-management.md     # conferenceRooms table
│   └── engagement-tools.md    # DataChannels for chat, polls
├── stripe/
│   ├── subscription.md        # Webhook handling, tier management
│   └── billing-portal.md      # Customer portal (Phase2)
├── supabase/
│   ├── auth-bridge.md         # Custom access token hook, JWT claims
│   ├── storage-service.md     # Upload, transform, malware scan
│   ├── realtime.md            # Channel topics, private channels
│   └── edge-functions.md      # purge, blurhash, scan_upload
├── external-calendars/
│   ├── google-calendar.md     # OAuth, two‑way sync
│   └── outlook-calendar.md    # Graph API integration
├── resend.md                  # Transactional email (notifications)
├── social-sign-on.md          # Google, Apple, GitHub OAuth
└── zapier.md                  # Public API for user automations
```

### `ops/`
DevOps, infrastructure, runbooks, and deployment.

```
ops/
├── ci-cd/
│   ├── github-actions.md      # Workflows for frontend, backend, supabase
│   ├── deploy-frontend.md     # Vercel with Edge CSP
│   ├── deploy-backend.md      # Fly.io, Docker, Gunicorn
│   └── db-migrations.md       # Prisma migrate deploy, schema alignment
├── infrastructure/
│   ├── terraform.md           # IaC for Vercel, Fly, Supabase, Upstash
│   ├── kubernetes.md          # (if extracting backend services)
│   └── docker-compose.md      # Local dev environment
├── runbooks/
│   ├── supabase-outage.md     # Status banner, read‑only mode
│   ├── ai-outage.md           # LiteLLM fallback, user notification
│   ├── data-breach.md         # GDPR 72h notification, forensic steps
│   └── full-outage.md         # Maintenance page, communication plan
├── monitoring/
│   ├── sentry.md              # Error tracking, alert rules
│   ├── posthog.md             # RUM, feature flags, analytics
│   ├── datadog.md             # Infrastructure metrics (optional)
│   ├── slo-dashboards.md      # Availability, LCP, error rate targets
│   └── cost-monitoring.md     # AI token consumption, per‑org attribution
└── feature-flags/
    ├── flag-providers.md      # PostHog + Supabase table
    └── rollout-strategy.md    # Phased rollout, automatic cleanup
```

### `security/`
Comprehensive security, compliance, and privacy.

```
security/
├── encryption/
│   ├── data-at-rest.md        # AES‑256, field‑level encryption
│   ├── data-in-transit.md     # TLS, certificate pinning
│   └── e2e-encryption.md      # Proton Drive‑style client‑side encryption (future)
├── api-security/
│   ├── rate-limiting.md       # FastAPI‑Limiter, Upstash Redis
│   ├── owasp-top10.md         # Mitigation checklist
│   └── input-validation.md    # Zod schemas at API boundary
├── tenant-isolation/
│   ├── rls-policies.md        # Per‑table policy definitions
│   ├── cross-tenant-tests.md  # Automated policy testing
│   └── data-leakage-prevention.md
├── audit-logging/
│   ├── audit-schema.md        # Immutable logs table
│   └── audit-retention.md     # Retention periods, anonymization
├── compliance/
│   ├── soc2.md                # Controls mapping
│   ├── iso27001.md            # ISMS alignment
│   ├── gdpr.md                # Data export, deletion, consent
│   └── ccpa.md                # California requirements
├── pen-testing/
│   ├── external-pentest.md    # Schedule, scope, findings tracking
│   └── bug-bounty.md          # Program management
└── model-security/
    ├── prompt-injection.md    # Detection, sandboxing
    ├── jailbreak-prevention.md # Input filtering, output monitoring
    └── weight-protection.md   # Model access controls (if self‑hosted)
```

### `testing/`
All testing strategies, tools, and coverage targets.

```
testing/
├── strategy.md                # Pyramid, test types, ownership
├── unit-tests/
│   ├── utilities.md           # Pure functions, Zod schemas
│   └── store-selectors.md     # Zustand slice tests
├── component-tests/
│   ├── ui-components.md       # RTL + userEvent patterns
│   └── accessibility-tests.md # axe‑core integration
├── integration-tests/
│   ├── api-contracts.md       # MSW handlers, TanStack Query
│   └── module-flows.md        # Authenticated workflows
├── e2e-tests/
│   ├── playwright-config.md   # Optional critical flows
│   └── critical-paths.md      # Auth, chat, task CRUD, calendar
├── performance-tests/
│   ├── load-testing.md        # k6 for API endpoints
│   └── bundle-analysis.md     # Lighthouse CI, size‑limit
├── security-tests/
│   ├── sast-dast.md           # Static & dynamic analysis
│   └── dependency-scanning.md # npm audit, Snyk
├── ai-specific/
│   ├── eval-pipelines.md      # Accuracy, latency, tool selection
│   ├── adversarial-prompts.md # Safety test suites
│   └── rag-accuracy.md        # Retrieval recall/precision
└── chaos-engineering/
    ├── service-failures.md    # Circuit breaker testing
    └── network-latency.md     # Throttled connections
```

### `product-design/`
User experience, personas, onboarding, and content.

```
product-design/
├── personas.md                # User archetypes, goals
├── journey-maps.md            # Key workflows across modules
├── wireframes.md              # Link to Figma / design files
├── onboarding.md              # Progressive disclosure, tooltips
├── feedback-loops.md          # In‑app surveys, NPS, analytics
├── content-strategy/
│   ├── microcopy.md           # Button labels, error messages
│   ├── help-articles.md       # Knowledge base structure
│   └── ai-explanations.md     # Transparency in AI decisions
├── accessibility-design.md    # Design‑level a11y requirements
└── motion-design.md           # Animation principles, tier assignments
```

### `business-legal/`
Subscription, licensing, and legal documents.

```
business-legal/
├── pricing-model.md           # Freemium, per‑seat, AI token add‑ons
├── billing-system.md          # Stripe integration, invoicing, dunning
├── license-management.md      # Feature access per plan
├── terms-of-service.md        # AI usage disclosure, data ownership
├── privacy-policy.md          # GDPR/CCPA compliance, model training opt‑out
├── data-processing-agreement.md # DPA for enterprise customers
├── gdpr-deletion.md           # Automated user data export & deletion
└── third-party-agreements.md  # API terms for external integrations
```

### `contracts/`
Reusable, cross‑spec definitions that drive validation and generation.

```
contracts/
├── global-rules.yaml          # S1‑S21, B1‑B8, P1‑P4 (machine‑readable)
├── patterns.yaml              # @O → full description, parameters
├── motion-tiers.yaml          # AP, AS, AG, Q, S definitions
├── design-tokens.yaml         # Z‑index stack, debounce values, breakpoints
├── animation-contracts.yaml   # useShouldAnimate, performance budgets
└── test-contracts.yaml        # Coverage thresholds, MSW patterns
```

### `docs/`
Plans for documentation surfaces, both internal and external.

```
docs/
├── internal/
│   ├── architecture-decision-records.md  # Index of ADRs
│   ├── api-docs.md                       # OpenAPI source location
│   ├── runbooks.md                       # Index of ops runbooks
│   └── onboarding-guide.md               # New developer setup
├── external/
│   ├── api-reference.md      # Public API documentation strategy
│   ├── sdk-docs.md           # Client SDK generation (openapi‑typescript)
│   ├── user-guides.md        # Per‑module help center articles
│   └── video-tutorials.md    # Content plan
└── legal/
    ├── dpa.md                # Data Processing Agreement text
    ├── soc2-report.md        # Placeholder for audit report
    └── privacy-faq.md        # Customer‑facing privacy questions
```

### `research-futures/`
Parking lot for emerging technologies and future roadmap items.

```
research-futures/
├── multimodal-ai.md          # Image generation, voice cloning
├── on-device-inference.md    # WebGPU, small models
├── plugin-ecosystem.md       # Third‑party AI tools marketplace
├── homomorphic-encryption.md # E2E encrypted AI (long‑term)
├── token-optimization.md     # SuperBPE, RocketKV, prefix caching
├── people-album.md           # Phase 2 with explicit consent
└── offline-pwa.md            # Full offline support, install prompts
```

### `scripts/`
The generation and validation pipeline that keeps all formats in sync.

```
scripts/
├── validate-spec.py          # Cross‑references, lexicon completeness, DAG
├── generate-plan3.py         # Compiles spec/ → Plan3.md
├── generate-plan2.py         # Expands abbreviations into full prose
├── generate-plan-md.py       # Ultra‑compressed §‑blocks format
└── scaffold-module.py        # Creates a new module file with YAML template
```

---

## Why This Structure Achieves “Modular AF”

- **Single file per concept**: no more debating where to add a new rule about a specific Kanban interaction – it goes in `projects/views/kanban/kanban-card.md`.  
- **No duplication**: shared contracts live in `contracts/`; every module references them via YAML frontmatter `contracts_used: [pattern.yaml]`.  
- **LLM‑editable**: each file is short (< 300 lines), follows a strict template, and has explicit tests – ideal for AI‑assisted spec maintenance.  
- **Generates all formats**: the `scripts/` directory reads the entire `spec/` tree and produces Plan.md, Plan2, Plan3 on demand.  
- **Parallel contribution**: multiple teams can work on `chat/`, `projects/`, and `budget/` simultaneously without merge conflicts.  
- **Auditable**: validation script catches broken references, stale abbreviations, and cyclic dependencies before they reach production.

This tree will support indefinite scaling – adding a new module (say, “CRM‑Automations”) is just creating a new directory under `spec/crm-automations/` with its own files and appending a row to `00-INDEX.md`.