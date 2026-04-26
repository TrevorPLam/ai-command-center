# Component registry

This document consolidates all component specifications across all modules, providing a
comprehensive inventory of UI components, their patterns, rules, dependencies, and implementation
notes.

## Dashboard components

Components for the main dashboard interface including agent fleet management,
activity feeds, and attention queues.

| Component | Module | Type | Pattern Tags | Rules | Dependencies | Notes |
|-----------|--------|------|--------------|-------|--------------|-------|
| AmbientStatusBanner | Dashboard | Banner | `@MotionGuard`, `@AnimatePresence` | Liquid glass effect | useAgentStatus | Dismissal state persists in localStorage |
| AgentFleetPanel | Dashboard | Grid | `@MotionGuard`, `@StaggerChildren` | - | LayoutGroup | layoutId for morphing animations |
| AgentCard | Dashboard | Card | `@OptimisticMutation`, `@StaggerChildren` | Motion v12 tokens | - | role=button for accessibility |
| ActivityFeed | Dashboard | Feed | `@VirtualizeList` | - | - | role=log, aria-live=polite |
| ActivityEntry | Dashboard | Entry | `@MotionGuard`, `@StaggerChildren` | - | - | Individual feed item |
| AttentionQueue | Dashboard | Queue | `@PopLayout`, `@OptimisticMutation`, `@VirtualizeChildren`, `@AnimatePresence`, `@Stagger` | - | - | Injected into RightPanel |
| DecisionPacket | Dashboard | Packet | `@OptimisticMutation`, `@OpacityFade` | - | useMotionValue | skipInitialAnimation |
| AgentDetailDrawer | Dashboard | Drawer | `@MotionGuard`, `@AnimatePresence`, `@StaggerChildren` | Focus restoration in Zustand, FocusTrap, Zustand persist version+migrate+partialize | stores/uiSlice | layoutScroll container |

## Chat components

Core chat interface components including message rendering, input handling,
collaboration, and AI agent integration.

### Core chat components

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| ChatPage | Chat | Page | `@InfiniteScroll`, `@AnimatePresence` | None | ~/pages/ChatPage | Lazy loaded with hover prefetch for performance |
| ThinkingTracePanel | Chat | Panel | `@AnimatePresence`, `@Spring` | None | None | Collapsible dual-pane layout for AI reasoning traces |
| GenUIRenderer | Chat | Renderer | `@GenUI` | None | None | Renders agent-driven UI components safely |
| ThreadList | Chat | List | `@OpacityFade`, `@InfiniteScroll` | P2 (Performance rule 2) | None | Uses useTransition for smooth filtering |
| ThreadListItem | Chat | Item | None | None | None | 200ms hover prefetch for thread content |
| MessageList | Chat | List | `@VirtualizeList`, `@SSEStream` | None | None | role="log" with aria-live for screen readers |
| MessageBubble | Chat | Bubble | `@Spring`/AG, `@MotionGuard` | None | None | Client-side message ID for optimistic updates |
| TypingIndicator | Chat | Indicator | `@MotionGuard`, `@AnimatePresence` | None | None | Skips reduced motion for subtle animations |

### Input and interaction components

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| ChatInput | Chat | Input | `@MotionGuard`, `@KeyboardShortcuts` | g4 (Global rule 4) | Real-time audio (rta) | Cmd+Enter for sending messages |
| SlashMenu | Chat | Menu | `@MotionGuard`, `@KeyboardShortcuts`, `@DebounceAutoSave` | FT (Feature rule) | ~/data/slashCommands | Built-in commands plus MCP tool integration |
| ToolCallDisclosure | Chat | Disclosure | `@MotionGuard`, `@AnimatePresence` | None | None | Reverse-measure viewport for performance |
| CheckpointBanner | Chat | Banner | `@OptimisticMutation`, `@AnimatePresence` | None | None | aria-live="assertive" for important notifications |

### Collaboration and canvas components

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| CollabCanvas | Chat | Canvas | `@SandboxIframe`, `@OptimisticMutation`, `@SSEStream` | None | mco, yjs, yml, ymp, ~/stores/canvasStore | Y-Sweet token integration, layoutId for shared animations |
| ArtifactSandbox | Chat | Sandbox | `@SandboxIframe`, `@AnimatePresence` | g4+dp (Global rule 4 + DOMPurify) | None | BlobURL CSP handling with automatic revocation |

### Knowledge and memory components

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| KnowledgeBase | Chat | Panel | `@VirtualizeList` | None | FastAPI /v1/embed | Context injection for RAG operations |
| MemoryManager | Chat | Manager | `@TieredMemory` | B9 (Backend rule 9) | ~/stores/memoryStore | Episodic and semantic memory with FIFO eviction |

### Configuration and agent components

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| MCPSettings | Chat | Settings | None | B10 (Backend rule 10) | ~/stores/mcpStore | MCP server configuration management |
| AgentStudio | Chat | Studio | `@OptimisticMutation` | B10 (Backend rule 10) | ~/stores/agentStore | Browse and clone agent configurations |
| A2AFlowEditor | Chat | Editor | `@A2AFlow`, `@AnimatePresence` | B11 (Backend rule 11) | DAG + React Flow | Keyboard accessibility support |
| PromptLibrary | Chat | Library | `@InfiniteScroll`, `@OptimisticMutation` | None | ~/stores/promptStore | Version history for prompt management |
| A2ATranscriptViewer | Chat | Viewer | `@A2AFlow` | None | None | View inter-agent message transcripts |
| AgentPlayground | Chat | Playground | `@PLAY`, `@AnimatePresence` | None | None | Live trace viewing in sandboxed environment |

## Projects components

Project management, task tracking, kanban boards, timeline views, and triage workflows.

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| ProjectsPage | Projects | Page | `@MotionGuard`, `@AnimatePresence` | B1 + P2 | projectSlice, ProjectsPage | ViewSwitcher with layoutId |
| ViewSwitcher | Projects | Switcher | `@MotionGuard`, `@DebounceAutoSave` | g9 | projectSlice | Active state via Zustand |
| FilterBar | Projects | Bar | P2 | - | projectSlice | Clear button, useTransition |
| ProjectListView | Projects | List | `@VirtualizeList`, `@InlineEdit`, `@HoverPrefetch` | B1 | - | 10-column layout |
| ProjectKanbanView | Projects | Kanban | `@OptimisticMutation`, `@StaggerChildren` | dnd + B3 | projectSlice | pointerWithin detection |
| ProjectTimelineView | Projects | Timeline | - | g4 + LCP | svg | Zoom: Day/Week/Month/Quarter |
| MyWeekView | Projects | View | `@OptimisticMutation` | dnd + B3 | projectSlice | Colleague week view |
| WorkloadView | Projects | View | P2 | - | - | Click bar to show task list |
| TriagePage | Projects | Page | `@VirtualizeList`, `@TriageColor`, `@TRIAGE` | - | triageSlice | Swipe gestures, kbd (E,A,P) |
| TriageActionTray | Projects | Tray | `@OptimisticMutation` | - | triageSlice | Comment blue/white |
| TriageIntegrationHub | Projects | Hub | - | - | useTriage | Type icons |
| ProjectDetailPage | Projects | Page | `@InlineEdit`, `@OptimisticMutation`, `@MotionGuard`, `@AnimatePresence` | FocusTrap | projectSlice | Tab nav URL (g27) |
| TaskList | Projects | List | `@VirtualizeList`, `@InlineEdit`, `@OptimisticMutation` | dnd + B3 | - | Subtask count display |
| TaskDetailDrawer | Projects | Drawer | `@MotionGuard`, `@InlineEdit`, `@OptimisticMutation`, `@DebounceAutoSave`, `@AnimatePresence` | B1 + FocusTrap | projectSlice | Tabs lazy, @mention, debounce 500ms |
| TaskChecklist | Projects | Checklist | `@OptimisticMutation`, `@StaggerChildren` | dnd + B3 | - | Live percentage in tab |
| TaskComments | Projects | Comments | `@OptimisticMutation` | DOMPurify + react-textarea-autosize | - | Internal/external comments |
| QuickPeekOverlay | Projects | Overlay | `@MotionGuard`, `@DebounceAutoSave` | FocusTrap aria-modal | projectSlice | Cached data |
| ProjectTemplateLibrary | Projects | Library | - | - | - | Save as template |
| RecurringWorkDialog | Projects | Dialog | `@Recurring` | zod | shared/recurrence | Preview next 5 occurrences |
| ClientTaskConfig | Projects | Config | `@InlineEdit` | - | - | Badge display |
| AutomationRulesPanel | Projects | Panel | `@OptimisticMutation` | - | projectSlice | Triggered = strikethrough |
| TimeBudgetPanel | Projects | Panel | `@OptimisticMutation` | - | projectSlice | Green <75%, amber <100%, red |
| PracticeIntelligence | Projects | Dashboard | - | - | - | Agent log |
| GlobalSearchDialog | Projects | Dialog | `@KeyboardShortcuts` | FocusTrap | - | type:, before:, after: filters |

## Calendar components

Event management, scheduling, and recurring event support.

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| CalendarPage | Calendar | Page | `@MotionGuard`, `@TimezoneAware`, `@AnimatePresence` | g10 | calendarSlice | Sheet on mobile |
| MonthView | Calendar | View | `@MotionGuard`, `@TimezoneAware` | g10 | react-big-calendar | ARIA grid, keyboard navigation |
| WeekDayView | Calendar | View | `@OptimisticMutation`, `@AnimatePresence` | dnd + B3 | react-big-calendar | Ctrl+Shift+Arrow navigation |
| ResourceWeekView | Calendar | View | `@MotionGuard` | - | react-big-calendar | - |
| AgendaView | Calendar | View | `@VirtualizeList` | - | react-big-calendar | role=list for accessibility |
| EventComposer | Calendar | Composer | `@MotionGuard`, `@Recurring`, `@OptimisticMutation`, `@DebounceAutoSave` | - | - | Optimistic create |
| EventDetailDrawer | Calendar | Drawer | `@OptimisticMutation`, `@DebounceAutoSave` | - | - | Optimistic delete with undo |
| RecurringEditModal | Calendar | Modal | `@Recurring`, `@OptimisticMutation` | - | shared/recurrence | Exception storage |
| TimezoneSelector | Calendar | Selector | `@TimezoneAware` | - | - | Working hours configuration |
| ReminderToast | Calendar | Toast | `@MotionGuard`, `@AnimatePresence` | - | - | Browser notifications |
| ImportExportDialog | Calendar | Dialog | - | - | - | ICS format, partial import |
| BulkActionBar | Calendar | Bar | `@OptimisticMutation` | - | - | Shift-click range selection |

**React 19 compatibility assessment (April 26, 2026):**

| Library | React 19 Support | Maintenance Status | Last Release | Recommendation |
|---------|------------------|-------------------|--------------|----------------|
| react-big-calendar | Partial - JSX transform warning (Issue #2785) | Slow - No commits since June 2025 | v1.19.4 (Jun 16, 2025) | Use with caution, monitor for updates |
| react-calendar | Full support (v6.0.0+) | Active | v6.0.1+ | Alternative for date selection only |
| `@fullcalendar`/react | Full support | Active (commercial backing) | v6.1.20 (Dec 23, 2025) | Best alternative for event calendars |
| react-day-picker | Incompatible with React 19 | Active (but compatibility issues) | Latest | Not recommended until React 19 support |
| Shadcn/UI calendar | Incompatible (depends on react-day-picker) | Active | Latest | Not recommended until react-day-picker fix |

**Known React 19 issues with react-big-calendar:**

- **Issue #2785** (Jan 15, 2026): Outdated JSX transform causes runtime warning in React 18/19
  - Warning: "Your app (or one of your dependencies) is using an outdated JSX transform"
  - Occurs with modern JSX runtime ("jsx": "react-jsx")
  - Confirmed with React 19.2.0, Next.js 16.0.1, react-big-calendar 1.19.4
  - Package shipped using classic JSX transform instead of modern automatic JSX runtime (React 17+)
  - Workaround: Suppress warning or wait for library update to modern JSX transform

- **Issue #2701**: Feature request for React 19 support (not a bug report)
  - Request to update peer dependencies and test core functionalities with React 19
  - No implementation timeline provided
  - Alternative: Partial support with documentation on known issues

**Migration path considerations:**

1. **Stay with react-big-calendar**: Pin to v1.19.4, accept JSX transform warning, monitor for React 19 updates
2. **Migrate to FullCalendar**: More actively maintained, commercial backing, React 19 compatible, but licensing costs for premium features
3. **Migrate to react-calendar**: React 19 compatible, but designed for date selection (not event management)
4. **Custom implementation**: Build calendar components using react-calendar primitives or from scratch (high effort, full control)

**Decision**: Stay with react-big-calendar v1.19.4 for now (ADR_014), monitor for React 19 updates, evaluate FullCalendar migration if maintenance continues to stall.

## Budget components

Financial tracking, transaction management, and forecasting capabilities.

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| BudgetPage | Budget | Page | `@MotionGuard`, `@TimezoneAware`, `@AnimatePresence` | g10 | budgetSlice | URL sync via nuqs |
| BudgetDashboard | Budget | Dashboard | `@VirtualizeList` | LCP | - | Chart and table views |
| TransactionList | Budget | List | `@VirtualizeList`, `@InfiniteScroll` | - | - | Past, scheduled, and planned transactions |
| TransactionCalendarView | Budget | Calendar | `@OptimisticMutation`, `@AnimatePresence` | dnd + B3 | react-big-calendar | Future editable events |
| GoalCard | Budget | Card | `@OptimisticMutation` | - | - | Feasibility indicators |
| RecurringCalendar | Budget | Calendar | `@Recurring`, `@OptimisticMutation`, `@AnimatePresence` | - | shared/recurrence | Shared recurrence engine |
| CashFlowForecast | Budget | Forecast | - | LCP | - | LCP-optimized loading |

## Email components

Unified inbox management, email composition, and account synchronization via Nylas.

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| EmailPage | Email | Page | `@MotionGuard`, `@AnimatePresence` | - | emailSlice, react-resizable-panels | Resizable panels |
| UnifiedInbox | Email | List | `@VirtualizeList` | - | - | Account color coding |
| EmailListItem | Email | Item | `@OptimisticMutation` | - | - | Bulk selection support |
| ThreadView | Email | View | `@MotionGuard` | DOMPurify + g15 | - | Expand/collapse older messages |
| ComposeWindow | Email | Window | `@MotionGuard`, `@DebounceAutoSave` | FocusTrap | react-textarea-autosize, DOMPurify | Scheduled send, undo |
| AccountSidebar | Email | Sidebar | `@KeyboardShortcuts` | dnd + B3 | - | Drag-to-folder functionality |
| SnoozeModal | Email | Modal | `@Recurring` | - | - | Snoozed folder management |
| AttachmentViewer | Email | Viewer | - | DOMPurify | - | Size limit validation |
| EmailRules | Email | Rules | - | - | - | Import/export rules |
| TemplatesSignatures | Email | Templates | `@OptimisticMutation` | - | - | Canned responses |
| VacationResponder | Email | Responder | - | - | - | Once-per-sender limit |
| AgentEmailComposer | Email | Composer | - | - | - | POST /v1/email/send endpoint |

## Contacts components

Contact management, relationship mapping, and communication history.

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| ContactsPage | Contacts | Page | `@MotionGuard`, `@AnimatePresence` | - | contactsSlice | Quick add functionality |
| ContactDetail | Contacts | Detail | `@InlineEdit`, `@OptimisticMutation` | - | - | Privacy badges |
| ContactField | Contacts | Field | `@InlineEdit` | - | - | Field-level privacy controls |
| QuickAddModal | Contacts | Modal | `@MotionGuard`, `@DebounceAutoSave` | - | - | Auto-enrichment on create |
| ContactAutocomplete | Contacts | Autocomplete | `@KeyboardShortcuts` | - | - | Recent contacts first |
| EnrichmentPanel | Contacts | Panel | `@OpacityFade` | - | - | Bulk enrichment |
| RelationshipGraph | Contacts | Graph | `@MotionGuard`, `@AnimatePresence` | - | - | Zoom, pan, WCAG alt text |
| RelationshipGraphTableView | Contacts | Table | - | - | - | WCAG B11 compliance |
| CommunicationTimeline | Contacts | Timeline | `@VirtualizeList` | - | - | Quick actions per entry |
| TagManager | Contacts | Manager | - | - | - | Auto-tagging support |
| ImportExportDialog | Contacts | Dialog | `@Upload` | - | - | Duplicate handling |
| WorkflowAutomation | Contacts | Workflow | `@WorkflowExecution` | - | - | Pre-built templates |

## Documents components

Document management, file uploads, previews, and real-time collaborative editing.

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| DocumentsPage | Documents | Page | `@LazyMotion`, `@AnimatePresence` | - | documentsSlice | Grid/list/gallery views |
| DocumentCard | Documents | Card | `@OptimisticMutation`, `@DebounceAutoSave` | - | - | Progressive loading |
| DocumentGrid | Documents | Grid | `@VirtualizeList` | - | - | Drag-and-drop upload |
| UploadManager | Documents | Manager | `@Upload` | - | - | Size validation |
| FilePreview | Documents | Preview | `@MotionGuard`, `@AnimatePresence` | - | - | Keyboard navigation |
| ShareDialog | Documents | Dialog | `@MotionGuard`, `@DebounceAutoSave` | - | - | Sharing controls |
| AIPanel | Documents | Panel | `@SSEStream` | - | - | Streaming AI responses |
| VersionHistory | Documents | History | - | - | - | Document versions |
| RealTimeCoEdit | Documents | CoEdit | `@ChatCache` | - | yjs, y-sweet | Opt-in collaboration |

## Media components

Media gallery management, AI image generation, and storage analytics.

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| MediaPage | Media | Page | `@LazyMotion`, `@AnimatePresence` | - | mediaSlice | Grid/list/timeline views |
| MediaCard | Media | Card | `@OptimisticMutation`, `@DebounceAutoSave` | - | - | Progressive loading, alt text |
| MediaGrid | Media | Grid | `@VirtualizeList` | - | - | Infinite scroll |
| GenerationPanel | Media | Panel | `@OpacityFade`, `@SSEStream`, `@AnimatePresence` | - | - | Cancel/retry controls |
| MediaDetailDrawer | Media | Drawer | `@MotionGuard`, `@DebounceAutoSave` | - | - | Image editor |
| StorageAnalytics | Media | Analytics | - | - | - | Quota warnings |

## News components

News aggregation, feed management, article reading, and audio playback.

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| NewsPage | News | Page | `@LazyMotion`, `@AnimatePresence` | - | newsSlice | Pause/dedup feeds |
| NewsFeed | News | Feed | `@VirtualizeList`, `@InfiniteScroll` | - | - | Filter tabs |
| NewsCard | News | Card | `@OptimisticMutation`, `@HoverPrefetch` | - | - | Expand/collapse, WebShare |
| SentimentDot | News | Dot | `@MotionGuard`, `@DebounceAutoSave` | - | - | WCAG 1.4.1 compliant |
| ArticleReaderPanel | News | Panel | `@MotionGuard`, `@AnimatePresence` | - | - | Progress bar |
| AudioPlayer | News | Player | `@MotionGuard`, `@AnimatePresence` | - | - | Voice selector |

## Platform components

Platform-level components providing foundational services including authentication, analytics, agent management, and error handling.

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| EnvValidation | Platform | Util | - | - | lib/env.ts | No mount if invalid |
| ErrorBoundary | Platform | Boundary | - | - | lib/errorBoundary.ts | logClientEvent |
| AnalyticsPage | Platform | Page | `@LazyMotion`, `@AnimatePresence` | - | AnalyticsPage | Agent analytics |
| AuditLogPage | Platform | Page | `@LazyMotion`, `@VirtualizeList`, `@AnimatePresence` | - | - | Audit trail viewing |
| PrivacyBanner | Platform | Banner | - | - | - | Privacy notice |
| LoginPage | Platform | Page | `@LazyMotion`, `@AnimatePresence` | - | - | Authentication |
| SignupPage | Platform | Page | `@LazyMotion`, `@AnimatePresence` | - | - | User registration |
| OAuthCallbackPage | Platform | Page | `@LazyMotion`, `@AnimatePresence` | - | - | OAuth callback |
| AgentStudioPage | Platform | Page | `@LazyMotion`, `@AnimatePresence` | - | - | Agent library, playground |
| AgentAnalyticsPage | Platform | Page | `@LazyMotion`, `@AnimatePresence` | - | - | Per-agent metrics, cost |
| AgentPlaygroundPage | Platform | Page | `@LazyMotion`, `@PLAY`, `@AnimatePresence` | - | - | Sandbox testing |

## Conference components

Video conferencing, voice AI, and real-time collaboration via LiveKit.

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| ConferencePage | Conference | Page | `@LazyMotion`, `@AnimatePresence` | - | livekit-client, livekit-react | LiveKit Provider wrapper |
| RoundtableGrid | Conference | Grid | `@MotionGuard`, `@AnimatePresence` | - | - | 4-16 participant layout |
| ParticipantTile | Conference | Tile | `@MotionGuard` | - | - | Quality indicator overlay |
| RecordingControls | Conference | Controls | `@MotionGuard`, `@AnimatePresence` | - | - | Pulsing red indicator |
| EngagementTools | Conference | Tools | - | - | - | LiveKit DataChannels |
| ScenarioTemplates | Conference | Templates | - | - | - | Role assignment |
| BreakoutRooms | Conference | Rooms | `@WorkflowExecution` | - | - | Auto-return to main room |

## LiveKit components

Voice AI pipeline components including STT, LLM, TTS integration, and real-time audio processing.

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| VoicePipeline | LiveKit | Pipeline | `@Streaming`, `@InterruptHandling` | - | livekit-agents, STT/LLM/TTS providers | Sequential pipeline with VAD→STT→LLM→TTS→Audio |
| STTProcessor | LiveKit | Processor | `@Streaming` | - | Deepgram Nova, OpenAI Whisper | Emits partial transcripts <100ms |
| LLMOrchestrator | LiveKit | Orchestrator | `@Streaming`, `@TokenGeneration` | - | Claude, GPT, Gemini | 300-800ms first token, streaming output |
| TTSSynthesizer | LiveKit | Synthesizer | `@Streaming` | - | Modern TTS providers | 100-200ms first audio chunk |
| BargeInHandler | LiveKit | Handler | `@InterruptDetection` | - | VAD integration | Cancels TTS on user speech, flushes audio |
| ChatContextManager | LiveKit | Manager | `@StateManagement` | - | - | Accumulates turns, passes on handoffs |
| AgentWorkerPool | LiveKit | Pool | `@HorizontalScaling` | - | - | Stateful per-session workers, load-based scheduling |

**STT/LLM/TTS Integration Patterns:**

- **Flexible Ecosystem**: Mix and match STT, LLM, TTS, and Realtime API providers
- **Streaming Interfaces**: Each stage boundary is streaming (not blocking handoffs)
- **Session State**: Each active session holds WebRTC connection, STT stream, LLM context window, TTS stream
- **Horizontal Scaling**: Worker pools with load-based scheduling (CPU, memory, network conditions)
- **Hosted vs Self-Hosted**: Hosted Voice Agents handles orchestration automatically; self-hosted via LiveKit Agents SDK for strict data residency
- **Concurrency Planning**: Account for all four resources (connection, STT, LLM, TTS) when planning capacity

## Research components

Mind mapping, flashcard learning, study guides, and research report generation.

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| ResearchPage | Research | Page | `@LazyMotion`, `@AnimatePresence` | - | researchSlice | Multi-format support |
| MindMapEditor | Research | Editor | `@MotionGuard`, `@AnimatePresence` | - | markmap, yjs | Collaborative, WCAG alt text |
| FlashcardDeck | Research | Deck | `@MotionGuard`, `@StaggerChildren` | - | - | FSRS spaced repetition |
| LearningGuide | Research | Guide | `@SSEStream` | - | - | Streaming content |
| AudioOverview | Research | Overview | `@MotionGuard`, `@AnimatePresence` | - | - | Waveform visualization |
| ReportGenerator | Research | Generator | `@OptimisticMutation` | - | - | PDF/Markdown export |

## Settings components

User preferences, appearance settings, notifications, API keys, memory management, integrations, and data export/import.

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| SettingsPage | Settings | Page | `@MotionGuard`, `@AnimatePresence` | - | settingsSlice | Keyboard navigation |
| GeneralSettings | Settings | Form | `@InlineEdit` | - | react-hook-form, react-helmet, zod | - |
| AppearanceSettings | Settings | Form | `@MotionGuard` | - | - | Live preview |
| NotificationSettings | Settings | Form | - | - | - | Zod refinement |
| ApiKeysSettings | Settings | Form | - | - | - | Security controls |
| MemorySettings | Settings | Form | `@TieredMemory` | - | - | Memory management |
| IntegrationsSettings | Settings | Form | `@OptimisticMutation` | - | - | Third-party integrations |
| ExportImportPage | Settings | Page | `@Upload` | - | - | GDPR notice |
| DangerZone | Settings | Zone | - | - | - | Typed confirmation |
| StorageQuotaIndicator | Settings | Indicator | - | - | useStorageQuota | Quota display |
| CostDashboard | Settings | Dashboard | - | - | - | Budget and alerts |
| MCPSettings | Settings | Settings | `@MCPSecurity` | - | - | Discover, test, approve |

## Shell components

Application shell components that form the structural foundation of the UI.

| Component | Module | Type | Pattern Tags | Rules | Dependencies | Notes |
|-----------|--------|------|--------------|-------|--------------|-------|
| AppShell | Foundation | Layout | `@MotionGuard`, `@AnimatePresence` | Focus restoration, VoiceShell + CommandPalette Zustand, useRef + useCallback intervals | lib/*, providers/* | SkipLink, AnimatePresence for page transitions |
| Sidebar | Foundation | Navigation | `@MotionGuard`, `@AnimatePresence`, `@StaggerChildren` | Noise-overlay glass, keyboard shortcuts in kbd tags, WCAG 2.2 AA, Zustand persist version+migrate+partialize | stores/orgSlice | layoutId for active pill animation |
| OrgSwitcher | Foundation | Control | - | - | stores/orgSlice | refreshSession on switch |
| StatusBar | Foundation | Info | `@MotionGuard` | useRef + useCallback intervals | - | Fixed bottom position |
| RightPanel | Foundation | Panel | `@MotionGuard`, `@OpacityFade` | Focus restoration stored in Zustand, FocusTrap | stores/uiSlice | close returns focus to trigger |
| CommandPalette | Foundation | Overlay | `@MotionGuard`, `@StaggerChildren` | Focus restoration, keyboard shortcuts in kbd tags, VoiceShell + CommandPalette Zustand, FocusTrap | useIntentHandler + cmdk | Portal rendered, role=combobox |
| VoiceShell | Foundation | Input | `@MotionGuard`, `@StaggerChildren` | keyboard shortcuts, WCAG 2.2 AA, VoiceShell + CommandPalette Zustand, Web Speech fallback, FocusTrap | useWebSpeech | Ctrl+Space shortcut |
| Toaster | Foundation | Feedback | - | - | sonner + g29 | sonner max 3 toasts |
| MetaTitle | Foundation | Meta | - | - | HelmetProvider + react-helmet-async | Per-route meta titles |
| NuqsAdapter | Foundation | Util | - | - | Router | URL state management |
| LiveKitProvider | Foundation | Provider | - | - | - | Wraps conference routes |

## Translation components

Real-time translation, speaker management, and streaming translation services.

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| TranslationPage | Translation | Page | `@LazyMotion`, `@AnimatePresence` | - | translationSlice | Mobile Sheet view |
| SpeakerManager | Translation | Manager | `@MotionGuard`, `@OptimisticMutation`, `@DebounceAutoSave` | - | - | Staggered speaker list |
| SplitScreenView | Translation | View | `@Static` | - | - | Language badges |
| TranslationSegment | Translation | Segment | `@MotionGuard`, `@StaggerChildren` | - | - | Streaming translation |
| SessionControls | Translation | Controls | `@OptimisticMutation`, `@AnimatePresence` | - | - | Optimistic status updates |
| StreamingHook | Translation | Hook | `@SSEStream`, `@AnimatePresence` | - | useStreaming | Retry 3 times |

## Workflow components

Visual workflow design, execution monitoring, and approval management.

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| WorkflowCanvas | Workflow | Canvas | `@A2AFlow`, `@MotionGuard`, `@AnimatePresence` | FocusTrap + B3 | react-flow, workflowSlice | Snap-to-grid layout |
| NodePalette | Workflow | Palette | - | B3 | react-flow | Grouped node categories |
| ExecutionViewer | Workflow | Viewer | `@MotionGuard`, `@AnimatePresence` | - | useMotionValue, workflowSlice | Blue pulse animation |
| ExecutionLog | Workflow | Log | `@VirtualizeList` | - | - | Filterable execution history |
| ApprovalPanel | Workflow | Panel | `@OptimisticMutation` | - | workflowSlice | Escalation workflows |
| ManualInputDialog | Workflow | Dialog | `@MotionGuard`, `@DebounceAutoSave` | FocusTrap + zod | - | Zod schema validation |
| TemplateLibrary | Workflow | Library | - | - | - | Parameter substitution |
| PerformanceMetrics | Workflow | Metrics | - | g26 | - | Mock metrics display |

---

## Pattern tag reference

### Animation patterns

- **`@MotionGuard`**: Animates only transform and opacity, respects prefers-reduced-motion
- **`@AnimatePresence`**: Page-level enter/exit transitions
- **`@StaggerChildren`**: Staggered animation for child elements (max 3 children)
- **`@OpacityFade`**: Opacity fade ≤150ms
- **`@Spring`**: Spring physics animation for primary interactions
- **`@LazyMotion`**: Lazy loading of motion features for code splitting
- **`@PopLayout`**: Pop-in layout animation for new elements

### Data patterns

- **`@VirtualizeList`**: Virtualized rendering for large lists
- **`@InfiniteScroll`**: Infinite scroll / load-more pattern
- **`@OptimisticMutation`**: Immediate UI update with revert on failure; pending state styling
- **`@InlineEdit`**: Inline editing triggered by click, with debounced auto-save
- **`@DebounceAutoSave`**: 300ms debounce, auto-save on edits
- **`@HoverPrefetch`**: Hover triggers data prefetch (200ms debounce)
- **`@SSEStream`**: Server-Sent Events for real-time data streaming
- **`@ChatCache`**: AI responses cached indefinitely (staleTime:Infinity)

### Specialized patterns

- **`@GenUI`**: Agent-driven UI component rendering
- **`@SandboxIframe`**: Sandboxed iframe for external content
- **`@Recurring`**: Recurring event logic (rschedule + Temporal adapter)
- **`@TimezoneAware`**: All times displayed in user's timezone
- **`@TieredMemory`**: Memory management with retention tiers (working, episodic, semantic)
- **`@WorkflowExecution`**: Workflow execution display and state machine
- **`@A2AFlow`**: Agent-to-agent communication flow
- **`@KeyboardShortcuts`**: Keyboard shortcuts for accessibility and power users
- **`@Upload`**: File upload logic
- **`@MCPSecurity`**: MCP security enforcement
- **`@Static`**: No animation (static element)
- **`@TriageColor`**: Color-coded triage indicators
- **`@PLAY`**: Playground/sandbox environment

## Rule reference

### Global rules (g)

- **g4**: Liquid glass effect
- **g5**: Noise-overlay glass effect
- **g8**: Focus restoration via Zustand store
- **g9**: Keyboard shortcuts displayed in kbd tags
- **g10**: WCAG 2.2 AA compliance
- **g15**: SanitizedHTML component with DOMPurify profiles
- **g20**: VoiceShell + CommandPalette integrated with Zustand
- **g21**: useRef + useCallback for intervals
- **g24**: Web Speech API fallback
- **g26**: LCP ≤ 800ms
- **g27**: URL state sync via nuqs
- **g29**: Sonner toast configuration

### Backend rules (B)

- **B1**: Zustand persist with version, migrate, and partialize
- **B3**: Drag-and-drop keyboard alternatives (WCAG 2.5.7)
- **B9**: Memory tier configuration
- **B10**: MCP server configuration
- **B11**: userEvent.setup() per test

### Performance rules (P)

- **P2**: Filter updates useTransition

### Feature rules (FT)

- **FT**: FocusTrap for modals/drawers

### Other rules

- **dp**: DOMPurify ≥3.4.0 sanitization
- **dnd**: Drag-and-drop via centralized dnd-kit façade
- **LCP**: Largest Contentful Paint optimization
- **rta**: react-textarea-autosize

---

## Tremor charting library

Tremor is used for dashboard charts and data visualization across multiple modules.

**Current Status**: v3.18.x (stable), v4.0.0-beta-tremor-v4.4 (early beta, NOT production-ready)

**Tremor v4 Migration Status**: TASK INFORMATION INCORRECT/PREMATURE - Tremor v4 is in early beta with no official migration guide. Breaking changes mentioned in changelog but not comprehensively documented. v4 beta uses Tailwind CSS 4.0.0-beta.6 (itself in beta) and React 19.0.0. No GA timeline or production readiness information found. Migration planning should wait until v4 reaches stable release with official migration documentation.

**Known Breaking Changes (v4 beta from changelog snippets)**:
- Toggle component removed - replace with TabList variant="solid"
- Tabs component redesigned with new API (now has "line" and "solid" variants)
- Dropdown component removed - use new Select component
- DateRangePicker API changed significantly

**Note**: This is not a comprehensive breaking changes list as no official documentation exists for v4 beta.

## Sanitization

DOMPurify profile effectiveness against XSS attack vectors.

| Profile | Configuration | Attack Vectors Mitigated | Known Limitations | Recommended Use |
|---------|--------------|-------------------------|-------------------|-----------------|
| STRICT | USE_PROFILES: { html: true }, FORBID_TAGS: ['svg', 'mathml', 'style', 'script', 'iframe', 'object', 'embed'], FORBID_ATTR: ['onload', 'onclick', 'onerror'] | Reflected XSS, stored XSS, mXSS (with ≥3.4.0), DOM clobbering | No SVG/MathML support, no CSS styling | Plain text content, user comments |
| RICH | USE_PROFILES: { html: true }, ALLOWED_TAGS: ['div', 'span', 'p', 'br', 'b', 'i', 'u', 'strong', 'em', 'ul', 'ol', 'li', 'a', 'img'], ALLOWED_ATTR: ['href', 'src', 'alt', 'title'], FORBID_TAGS: ['svg', 'mathml', 'script', 'style', 'iframe', 'object', 'embed'] | Reflected XSS, stored XSS, mXSS (with ≥3.4.0), CSS exfiltration (style tags blocked) | Limited formatting, no SVG/MathML, data-* attributes allowed by default (set ALLOW_DATA_ATTR: false) | Rich text editors, formatted user content |
| EMAIL | USE_PROFILES: { html: true }, ALLOWED_TAGS: ['div', 'span', 'p', 'br', 'a', 'img', 'table', 'tr', 'td', 'th'], ALLOWED_ATTR: ['href', 'src', 'alt', 'title', 'width', 'height'], FORBID_TAGS: ['svg', 'mathml', 'script', 'style', 'iframe', 'object', 'embed', 'form'], FORBID_ATTR: ['onload', 'onclick', 'onerror', 'formaction'], ALLOW_DATA_ATTR: false | Reflected XSS, stored XSS, mXSS (with ≥3.4.0), CSRF (form tags blocked), CSS exfiltration | Limited HTML subset, no JavaScript event handlers, no data-* attributes | Email templates, HTML email content |

**Security notes:**

- **Version Requirement**: DOMPurify ≥3.4.0 required to mitigate CVE-2025-26791, CVE-2024-47875, CVE-2024-45801, CVE-2024-6780
- **SAFE_FOR_TEMPLATES**: Do not use unless absolutely necessary (CVE-2025-26791 vulnerability, CVE-2026-41239 bypass in RETURN_DOM mode)
- **SAFE_FOR_XML**: Keep default (true) to prevent mXSS via SVG/MathML namespace confusion
- **Default Configuration Risks**: Default allows <style> (CSS exfiltration risk) and <form> (CSRF risk) - explicit profiles recommended
- **Data Attributes**: Set ALLOW_DATA_ATTR: false and ALLOW_ARIA_ATTR: false if not needed to prevent ujs-based XSS
- **Hooks**: Avoid using uponSanitizeAttribute with forceKeepAttr: true (mXSS bypass risk)
- **RETURN_DOM**: Use RETURN_DOM_FRAGMENT instead of RETURN_DOM to avoid SAFE_FOR_TEMPLATES bypass

**Recent CVEs (2024-2025):**

- CVE-2025-26791: XSS in DOMPurify <3.2.4 with SAFE_FOR_TEMPLATES (template literal regex issue)
- CVE-2024-47875: Nested node mXSS bypass in DOMPurify >3.0.0,<3.1.3 and <2.5.0 (fixed with MAX_NESTING_DEPTH)
- CVE-2024-45801: XSS bypass vulnerability (tag filtering logic short-circuit)
- CVE-2024-6780: Security bypass (medium severity)
- CVE-2026-41239: SAFE_FOR_TEMPLATES bypass in RETURN_DOM mode (future CVE)

**Historical mXSS Bypasses:**

- PortSwigger (Oct 2020): mXSS bypass using comments and CDATA tags in Chrome/Firefox
- Securitum: Mutation XSS via MathML mutation (DOMPurify 2.0.17 bypass)

---

*Last updated: 2026-04-26*
*Status: Complete - All 17 component modules consolidated*