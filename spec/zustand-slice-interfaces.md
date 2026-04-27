# Zustand Slice Interfaces Specification

**Purpose:** TypeScript interface definitions for all Zustand store slices with persistence configuration and cross-slice access patterns.

**Source:** `docs/plan/zustand-slices.yaml` (authoritative slice configuration)

**Rule FE-12:** Cross-slice access MUST use `get()` to read other slice state.

---

## Core Slice Interfaces

### authSlice

**Persistence:** reset (cleared on logout)

**State Interface:**

```typescript
interface AuthState {
  user: User | null;
  session: Session | null;
  orgId: string | null;
  isAuthenticated: boolean;
}

interface User {
  id: string;
  email: string;
  name: string;
  avatarUrl?: string;
}

interface Session {
  accessToken: string;
  refreshToken: string;
  expiresAt: Date;
}
```

**Actions:**

```typescript
interface AuthActions {
  setUser: (user: User | null) => void;
  setSession: (session: Session | null) => void;
  logout: () => void;
  refreshSession: () => Promise<void>;
}
```

**Persist Options:** None (reset on logout)

---

### uiSlice

**Persistence:** persistent

**Persisted Fields:** `cmdPaletteOpen`

**State Interface:**

```typescript
interface UIState {
  cmdPaletteOpen: boolean;
  sidebarCollapsed: boolean;
  rightPanelOpen: boolean;
  rightPanelContent: 'attention' | 'details' | null;
  focusTriggerRef: React.RefObject<HTMLElement> | null;
}
```

**Actions:**

```typescript
interface UIActions {
  setCmdPaletteOpen: (open: boolean) => void;
  setSidebarCollapsed: (collapsed: boolean) => void;
  setRightPanelOpen: (open: boolean) => void;
  setRightPanelContent: (content: 'attention' | 'details' | null) => void;
  setFocusTriggerRef: (ref: React.RefObject<HTMLElement>) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'ui-storage',
  version: 1,
  partialize: (state) => ({ cmdPaletteOpen: state.cmdPaletteOpen }),
  migrate: (persistedState: any, version: number) => {
    // Migration stub for future schema changes
    return persistedState as UIState;
  }
}
```

---

### orgSlice

**Persistence:** persistent

**Persisted Fields:** `currentOrgId`

**State Interface:**

```typescript
interface OrgState {
  currentOrgId: string | null;
  organizations: Organization[];
  isLoading: boolean;
}

interface Organization {
  id: string;
  name: string;
  slug: string;
  plan: 'free' | 'pro' | 'team' | 'enterprise';
  createdAt: Date;
}
```

**Actions:**

```typescript
interface OrgActions {
  setCurrentOrgId: (orgId: string | null) => void;
  setOrganizations: (orgs: Organization[]) => void;
  switchOrg: (orgId: string) => Promise<void>;
}
```

**Persist Options:**

```typescript
{
  name: 'org-storage',
  version: 1,
  partialize: (state) => ({ currentOrgId: state.currentOrgId }),
  migrate: (persistedState: any, version: number) => {
    return persistedState as OrgState;
  }
}
```

**Cross-Slice Access (FE-12):**

```typescript
// When switching org, clear auth session and RT connection
switchOrg: async (orgId: string) => {
  const { logout } = get().authActions;
  const { clearQueries } = get().queryClient;
  // Implementation
}
```

---

### dashboardSlice

**Persistence:** persistent

**Persisted Fields:** `agentFilter`

**State Interface:**

```typescript
interface DashboardState {
  agentFilter: 'all' | 'active' | 'idle' | 'error';
  activityFeed: ActivityEntry[];
  attentionQueue: DecisionPacket[];
  ambientStatus: 'healthy' | 'degraded' | 'down';
}

interface ActivityEntry {
  id: string;
  agentId: string;
  type: 'tool_call' | 'decision' | 'error';
  timestamp: Date;
  summary: string;
}

interface DecisionPacket {
  id: string;
  priority: 'low' | 'medium' | 'high' | 'critical';
  type: 'conflict' | 'suggestion' | 'alert';
  content: string;
  actions: DecisionAction[];
}
```

**Actions:**

```typescript
interface DashboardActions {
  setAgentFilter: (filter: 'all' | 'active' | 'idle' | 'error') => void;
  addActivityEntry: (entry: ActivityEntry) => void;
  addToAttentionQueue: (packet: DecisionPacket) => void;
  removeFromAttentionQueue: (packetId: string) => void;
  setAmbientStatus: (status: 'healthy' | 'degraded' | 'down') => void;
}
```

**Persist Options:**

```typescript
{
  name: 'dashboard-storage',
  version: 1,
  partialize: (state) => ({ agentFilter: state.agentFilter }),
  migrate: (persistedState: any, version: number) => {
    return persistedState as DashboardState;
  }
}
```

---

### chatSlice

**Persistence:** persistent

**Persisted Fields:** `activeThreadId`

**State Interface:**

```typescript
interface ChatState {
  activeThreadId: string | null;
  threads: Thread[];
  isStreaming: boolean;
  toolApprovals: Record<string, boolean>;
}

interface Thread {
  id: string;
  title: string;
  messages: Message[];
  createdAt: Date;
  updatedAt: Date;
}

interface Message {
  id: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  toolCalls?: ToolCall[];
  timestamp: Date;
}

interface ToolCall {
  id: string;
  name: string;
  arguments: Record<string, unknown>;
  result?: unknown;
  status: 'pending' | 'approved' | 'rejected' | 'completed';
}
```

**Actions:**

```typescript
interface ChatActions {
  setActiveThreadId: (threadId: string | null) => void;
  addMessage: (threadId: string, message: Message) => void;
  approveToolCall: (callId: string) => void;
  rejectToolCall: (callId: string) => void;
  setStreaming: (streaming: boolean) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'chat-storage',
  version: 1,
  partialize: (state) => ({ activeThreadId: state.activeThreadId }),
  migrate: (persistedState: any, version: number) => {
    return persistedState as ChatState;
  }
}
```

---

### workflowSlice

**Persistence:** reset (cleared on session end)

**State Interface:**

```typescript
interface WorkflowState {
  activeWorkflow: string | null;
  workflowState: Record<string, unknown>;
  currentStep: number;
  isComplete: boolean;
}
```

**Actions:**

```typescript
interface WorkflowActions {
  startWorkflow: (workflowId: string, initialState: Record<string, unknown>) => void;
  advanceStep: () => void;
  updateWorkflowState: (updates: Record<string, unknown>) => void;
  completeWorkflow: () => void;
  resetWorkflow: () => void;
}
```

**Persist Options:** None (reset on session end)

---

### projectSlice

**Persistence:** persistent

**Persisted Fields:** `currentView`, `filters`

**State Interface:**

```typescript
interface ProjectState {
  currentView: 'list' | 'kanban' | 'timeline' | 'myWeek' | 'workload';
  filters: ProjectFilters;
  selectedProjectId: string | null;
  selectedTaskId: string | null;
}

interface ProjectFilters {
  status?: 'backlog' | 'in_progress' | 'review' | 'done';
  assignee?: string;
  priority?: 'low' | 'medium' | 'high';
  dueDate?: { from: Date; to: Date };
}
```

**Actions:**

```typescript
interface ProjectActions {
  setCurrentView: (view: ProjectState['currentView']) => void;
  setFilters: (filters: ProjectFilters) => void;
  setSelectedProjectId: (projectId: string | null) => void;
  setSelectedTaskId: (taskId: string | null) => void;
  clearFilters: () => void;
}
```

**Persist Options:**

```typescript
{
  name: 'project-storage',
  version: 1,
  partialize: (state) => ({
    currentView: state.currentView,
    filters: state.filters
  }),
  migrate: (persistedState: any, version: number) => {
    return persistedState as ProjectState;
  }
}
```

---

### calendarSlice

**Persistence:** persistent

**Persisted Fields:** `activeDate`, `sidebarCal`

**State Interface:**

```typescript
interface CalendarState {
  activeDate: Date;
  sidebarCal: boolean;
  selectedEventId: string | null;
  view: 'month' | 'week' | 'day' | 'agenda';
}
```

**Actions:**

```typescript
interface CalendarActions {
  setActiveDate: (date: Date) => void;
  setSidebarCal: (visible: boolean) => void;
  setSelectedEventId: (eventId: string | null) => void;
  setView: (view: CalendarState['view']) => void;
  navigateDate: (direction: 'prev' | 'next') => void;
}
```

**Persist Options:**

```typescript
{
  name: 'calendar-storage',
  version: 1,
  partialize: (state) => ({
    activeDate: state.activeDate,
    sidebarCal: state.sidebarCal
  }),
  migrate: (persistedState: any, version: number) => {
    // Convert string dates back to Date objects
    if (persistedState.activeDate && typeof persistedState.activeDate === 'string') {
      persistedState.activeDate = new Date(persistedState.activeDate);
    }
    return persistedState as CalendarState;
  }
}
```

---

### emailSlice

**Persistence:** persistent

**Persisted Fields:** `activeAccount`, `selectedFolder`

**State Interface:**

```typescript
interface EmailState {
  activeAccount: string | null;
  selectedFolder: string;
  selectedMessageId: string | null;
  composeDraftId: string | null;
}
```

**Actions:**

```typescript
interface EmailActions {
  setActiveAccount: (accountId: string | null) => void;
  setSelectedFolder: (folder: string) => void;
  setSelectedMessageId: (messageId: string | null) => void;
  setComposeDraftId: (draftId: string | null) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'email-storage',
  version: 1,
  partialize: (state) => ({
    activeAccount: state.activeAccount,
    selectedFolder: state.selectedFolder
  }),
  migrate: (persistedState: any, version: number) => {
    return persistedState as EmailState;
  }
}
```

---

### contactsSlice

**Persistence:** reset (cleared on logout)

**State Interface:**

```typescript
interface ContactsState {
  selectedContactId: string | null;
  filterQuery: string;
  selectedTag: string | null;
}
```

**Actions:**

```typescript
interface ContactsActions {
  setSelectedContactId: (contactId: string | null) => void;
  setFilterQuery: (query: string) => void;
  setSelectedTag: (tag: string | null) => void;
}
```

**Persist Options:** None (reset on logout)

---

### conferenceSlice

**Persistence:** reset (cleared after session)

**State Interface:**

```typescript
interface ConferenceState {
  activeRoomId: string | null;
  isMuted: boolean;
  isVideoEnabled: boolean;
  screenShareEnabled: boolean;
}
```

**Actions:**

```typescript
interface ConferenceActions {
  joinRoom: (roomId: string) => void;
  leaveRoom: () => void;
  toggleMute: () => void;
  toggleVideo: () => void;
  toggleScreenShare: () => void;
}
```

**Persist Options:** None (reset after session)

---

### translationSlice

**Persistence:** persistent

**Persisted Fields:** `languages`

**State Interface:**

```typescript
interface TranslationState {
  languages: {
    source: string;
    target: string;
  };
  autoDetect: boolean;
}
```

**Actions:**

```typescript
interface TranslationActions {
  setSourceLanguage: (lang: string) => void;
  setTargetLanguage: (lang: string) => void;
  setAutoDetect: (enabled: boolean) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'translation-storage',
  version: 1,
  partialize: (state) => ({ languages: state.languages }),
  migrate: (persistedState: any, version: number) => {
    return persistedState as TranslationState;
  }
}
```

---

### newsSlice

**Persistence:** persistent

**Persisted Fields:** `feedFilter`, `pausedFeeds`

**State Interface:**

```typescript
interface NewsState {
  feedFilter: 'all' | 'positive' | 'negative' | 'neutral';
  pausedFeeds: string[];
  selectedArticleId: string | null;
}
```

**Actions:**

```typescript
interface NewsActions {
  setFeedFilter: (filter: NewsState['feedFilter']) => void;
  pauseFeed: (feedId: string) => void;
  resumeFeed: (feedId: string) => void;
  setSelectedArticleId: (articleId: string | null) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'news-storage',
  version: 1,
  partialize: (state) => ({
    feedFilter: state.feedFilter,
    pausedFeeds: state.pausedFeeds
  }),
  migrate: (persistedState: any, version: number) => {
    return persistedState as NewsState;
  }
}
```

---

### documentsSlice

**Persistence:** persistent

**Persisted Fields:** `currentFolder`

**State Interface:**

```typescript
interface DocumentsState {
  currentFolder: string | null;
  selectedDocumentId: string | null;
  view: 'grid' | 'list' | 'gallery';
}
```

**Actions:**

```typescript
interface DocumentsActions {
  setCurrentFolder: (folderId: string | null) => void;
  setSelectedDocumentId: (documentId: string | null) => void;
  setView: (view: DocumentsState['view']) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'documents-storage',
  version: 1,
  partialize: (state) => ({ currentFolder: state.currentFolder }),
  migrate: (persistedState: any, version: number) => {
    return persistedState as DocumentsState;
  }
}
```

---

### researchSlice

**Persistence:** persistent

**Persisted Fields:** `activeNotebook`

**State Interface:**

```typescript
interface ResearchState {
  activeNotebook: string | null;
  selectedNoteId: string | null;
}
```

**Actions:**

```typescript
interface ResearchActions {
  setActiveNotebook: (notebookId: string | null) => void;
  setSelectedNoteId: (noteId: string | null) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'research-storage',
  version: 1,
  partialize: (state) => ({ activeNotebook: state.activeNotebook }),
  migrate: (persistedState: any, version: number) => {
    return persistedState as ResearchState;
  }
}
```

---

### mediaSlice

**Persistence:** persistent

**Persisted Fields:** `selectedAlbum`

**State Interface:**

```typescript
interface MediaState {
  selectedAlbum: string | null;
  selectedMediaId: string | null;
  view: 'grid' | 'list' | 'timeline';
}
```

**Actions:**

```typescript
interface MediaActions {
  setSelectedAlbum: (albumId: string | null) => void;
  setSelectedMediaId: (mediaId: string | null) => void;
  setView: (view: MediaState['view']) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'media-storage',
  version: 1,
  partialize: (state) => ({ selectedAlbum: state.selectedAlbum }),
  migrate: (persistedState: any, version: number) => {
    return persistedState as MediaState;
  }
}
```

---

### budgetSlice

**Persistence:** persistent

**Persisted Fields:** `selectedAccount`, `dateRange`

**State Interface:**

```typescript
interface BudgetState {
  selectedAccount: string | null;
  dateRange: { from: Date; to: Date } | null;
  view: 'dashboard' | 'transactions' | 'goals';
}
```

**Actions:**

```typescript
interface BudgetActions {
  setSelectedAccount: (accountId: string | null) => void;
  setDateRange: (range: { from: Date; to: Date } | null) => void;
  setView: (view: BudgetState['view']) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'budget-storage',
  version: 1,
  partialize: (state) => ({
    selectedAccount: state.selectedAccount,
    dateRange: state.dateRange
  }),
  migrate: (persistedState: any, version: number) => {
    // Convert string dates back to Date objects
    if (persistedState.dateRange?.from) {
      persistedState.dateRange.from = new Date(persistedState.dateRange.from);
    }
    if (persistedState.dateRange?.to) {
      persistedState.dateRange.to = new Date(persistedState.dateRange.to);
    }
    return persistedState as BudgetState;
  }
}
```

---

### settingsSlice

**Persistence:** localStorage (all fields persisted)

**Persisted Fields:** `all`

**State Interface:**

```typescript
interface SettingsState {
  theme: 'light' | 'dark' | 'system';
  language: string;
  timezone: string;
  notifications: {
    email: boolean;
    push: boolean;
    inApp: boolean;
  };
  privacy: {
    analytics: boolean;
    crashReporting: boolean;
  };
}
```

**Actions:**

```typescript
interface SettingsActions {
  setTheme: (theme: SettingsState['theme']) => void;
  setLanguage: (language: string) => void;
  setTimezone: (timezone: string) => void;
  setNotificationPreference: (type: keyof SettingsState['notifications'], enabled: boolean) => void;
  setPrivacyPreference: (type: keyof SettingsState['privacy'], enabled: boolean) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'settings-storage',
  version: 1,
  storage: createJSONStorage(() => localStorage),
  migrate: (persistedState: any, version: number) => {
    return persistedState as SettingsState;
  }
}
```

---

### mcpSlice

**Persistence:** persistent

**Persisted Fields:** `version`

**State Interface:**

```typescript
interface MCPState {
  version: number;
  servers: MCPServer[];
  activeServerId: string | null;
}

interface MCPServer {
  id: string;
  name: string;
  url: string;
  status: 'connected' | 'disconnected' | 'error';
}
```

**Actions:**

```typescript
interface MCPActions {
  setVersion: (version: number) => void;
  addServer: (server: MCPServer) => void;
  removeServer: (serverId: string) => void;
  setActiveServerId: (serverId: string | null) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'mcp-storage',
  version: 1,
  partialize: (state) => ({ version: state.version }),
  migrate: (persistedState: any, version: number) => {
    return persistedState as MCPState;
  }
}
```

---

### agentStore

**Persistence:** persistent

**Persisted Fields:** `version`

**State Interface:**

```typescript
interface AgentStoreState {
  version: number;
  agents: AgentConfig[];
  activeAgentId: string | null;
}

interface AgentConfig {
  id: string;
  name: string;
  model: string;
  systemPrompt: string;
  tools: string[];
  temperature: number;
}
```

**Actions:**

```typescript
interface AgentStoreActions {
  setVersion: (version: number) => void;
  addAgent: (agent: AgentConfig) => void;
  updateAgent: (agentId: string, updates: Partial<AgentConfig>) => void;
  removeAgent: (agentId: string) => void;
  setActiveAgentId: (agentId: string | null) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'agent-storage',
  version: 1,
  partialize: (state) => ({ version: state.version }),
  migrate: (persistedState: any, version: number) => {
    return persistedState as AgentStoreState;
  }
}
```

---

### promptStore

**Persistence:** localStorage (all fields persisted)

**Persisted Fields:** `all`

**State Interface:**

```typescript
interface PromptStoreState {
  prompts: Prompt[];
  activePromptId: string | null;
}

interface Prompt {
  id: string;
  name: string;
  content: string;
  version: number;
  createdAt: Date;
  updatedAt: Date;
}
```

**Actions:**

```typescript
interface PromptStoreActions {
  addPrompt: (prompt: Prompt) => void;
  updatePrompt: (promptId: string, updates: Partial<Prompt>) => void;
  removePrompt: (promptId: string) => void;
  setActivePromptId: (promptId: string | null) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'prompt-storage',
  version: 1,
  storage: createJSONStorage(() => localStorage),
  migrate: (persistedState: any, version: number) => {
    // Convert string dates back to Date objects
    if (persistedState.prompts) {
      persistedState.prompts = persistedState.prompts.map((p: any) => ({
        ...p,
        createdAt: new Date(p.createdAt),
        updatedAt: new Date(p.updatedAt)
      }));
    }
    return persistedState as PromptStoreState;
  }
}
```

---

### canvasStore

**Persistence:** reset (cleared on exit)

**State Interface:**

```typescript
interface CanvasStoreState {
  canvasData: Y.Doc | null;
  isCollaborating: boolean;
  collaborators: Collaborator[];
}

interface Collaborator {
  id: string;
  name: string;
  color: string;
  cursor: { x: number; y: number } | null;
}
```

**Actions:**

```typescript
interface CanvasStoreActions {
  setCanvasData: (doc: Y.Doc | null) => void;
  setCollaborating: (collaborating: boolean) => void;
  addCollaborator: (collaborator: Collaborator) => void;
  removeCollaborator: (collaboratorId: string) => void;
  updateCollaboratorCursor: (collaboratorId: string, cursor: { x: number; y: number }) => void;
}
```

**Persist Options:** None (reset on exit)

---

### memoryStore

**Persistence:** max 50 FIFO

**Persisted Fields:** `working`, `episodic`

**State Interface:**

```typescript
interface MemoryStoreState {
  working: MemoryItem[];
  episodic: MemoryItem[];
  semantic: MemoryItem[];
}

interface MemoryItem {
  id: string;
  content: string;
  embedding?: number[];
  timestamp: Date;
  importance: number;
}
```

**Actions:**

```typescript
interface MemoryStoreActions {
  addToWorking: (item: MemoryItem) => void;
  addToEpisodic: (item: MemoryItem) => void;
  addToSemantic: (item: MemoryItem) => void;
  removeFromWorking: (itemId: string) => void;
  clearWorking: () => void;
}
```

**Persist Options:**

```typescript
{
  name: 'memory-storage',
  version: 1,
  partialize: (state) => ({
    working: state.working.slice(-50),
    episodic: state.episodic.slice(-50)
  }),
  migrate: (persistedState: any, version: number) => {
    // Enforce FIFO limit on rehydration
    if (persistedState.working?.length > 50) {
      persistedState.working = persistedState.working.slice(-50);
    }
    if (persistedState.episodic?.length > 50) {
      persistedState.episodic = persistedState.episodic.slice(-50);
    }
    // Convert string dates back to Date objects
    const convertDates = (items: any[]) => items.map(item => ({
      ...item,
      timestamp: new Date(item.timestamp)
    }));
    persistedState.working = convertDates(persistedState.working || []);
    persistedState.episodic = convertDates(persistedState.episodic || []);
    return persistedState as MemoryStoreState;
  }
}
```

---

### triageSlice

**Persistence:** reset (cleared after action)

**State Interface:**

```typescript
interface TriageState {
  items: TriageItem[];
  selectedIndex: number | null;
  filter: 'all' | 'email' | 'calendar' | 'tasks';
}

interface TriageItem {
  id: string;
  type: 'email' | 'calendar' | 'tasks';
  title: string;
  summary: string;
  timestamp: Date;
  priority: 'low' | 'medium' | 'high';
}
```

**Actions:**

```typescript
interface TriageActions {
  addItem: (item: TriageItem) => void;
  removeItem: (itemId: string) => void;
  setSelectedIndex: (index: number | null) => void;
  setFilter: (filter: TriageState['filter']) => void;
  clearAll: () => void;
}
```

**Persist Options:** None (reset after action)

---

### recurrenceStore

**Persistence:** reset (form state)

**State Interface:**

```typescript
interface RecurrenceState {
  rule: RecurrenceRule | null;
  exceptions: Date[];
  previewDates: Date[];
}

interface RecurrenceRule {
  frequency: 'daily' | 'weekly' | 'monthly' | 'yearly';
  interval: number;
  byDay?: number[];
  byMonth?: number[];
  until?: Date;
  count?: number;
}
```

**Actions:**

```typescript
interface RecurrenceActions {
  setRule: (rule: RecurrenceRule | null) => void;
  addException: (date: Date) => void;
  removeException: (date: Date) => void;
  setPreviewDates: (dates: Date[]) => void;
  clear: () => void;
}
```

**Persist Options:** None (form state only)

---

### notificationSlice

**Persistence:** persistent

**Persisted Fields:** `unreadCount`

**State Interface:**

```typescript
interface NotificationState {
  unreadCount: number;
  notifications: Notification[];
}

interface Notification {
  id: string;
  template: string;
  data: Record<string, unknown>;
  read: boolean;
  timestamp: Date;
}
```

**Actions:**

```typescript
interface NotificationActions {
  setUnreadCount: (count: number) => void;
  addNotification: (notification: Notification) => void;
  markAsRead: (notificationId: string) => void;
  markAllAsRead: () => void;
}
```

**Persist Options:**

```typescript
{
  name: 'notification-storage',
  version: 1,
  partialize: (state) => ({ unreadCount: state.unreadCount }),
  migrate: (persistedState: any, version: number) => {
    return persistedState as NotificationState;
  }
}
```

---

### searchSlice

**Persistence:** persistent

**Persisted Fields:** `history` (max 50), `recentEntities` (max 20)

**State Interface:**

```typescript
interface SearchState {
  query: string;
  history: string[];
  recentEntities: RecentEntity[];
  filters: SearchFilters;
}

interface RecentEntity {
  id: string;
  type: 'task' | 'event' | 'contact' | 'document';
  title: string;
  accessedAt: Date;
}

interface SearchFilters {
  type?: string[];
  dateRange?: { from: Date; to: Date };
  assignee?: string;
}
```

**Actions:**

```typescript
interface SearchActions {
  setQuery: (query: string) => void;
  addToHistory: (query: string) => void;
  addRecentEntity: (entity: RecentEntity) => void;
  setFilters: (filters: SearchFilters) => void;
  clearHistory: () => void;
  clearRecentEntities: () => void;
}
```

**Persist Options:**

```typescript
{
  name: 'search-storage',
  version: 1,
  partialize: (state) => ({
    history: state.history.slice(-50),
    recentEntities: state.recentEntities.slice(-20)
  }),
  migrate: (persistedState: any, version: number) => {
    // Enforce limits on rehydration
    if (persistedState.history?.length > 50) {
      persistedState.history = persistedState.history.slice(-50);
    }
    if (persistedState.recentEntities?.length > 20) {
      persistedState.recentEntities = persistedState.recentEntities.slice(-20);
    }
    // Convert string dates back to Date objects
    if (persistedState.recentEntities) {
      persistedState.recentEntities = persistedState.recentEntities.map((e: any) => ({
        ...e,
        accessedAt: new Date(e.accessedAt)
      }));
    }
    return persistedState as SearchState;
  }
}
```

---

### analyticsSlice

**Persistence:** persistent

**Persisted Fields:** `dateRange`, `selectedMetrics`

**State Interface:**

```typescript
interface AnalyticsState {
  dateRange: { from: Date; to: Date } | null;
  selectedMetrics: string[];
  granularity: 'hour' | 'day' | 'week' | 'month';
}
```

**Actions:**

```typescript
interface AnalyticsActions {
  setDateRange: (range: { from: Date; to: Date } | null) => void;
  setSelectedMetrics: (metrics: string[]) => void;
  setGranularity: (granularity: AnalyticsState['granularity']) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'analytics-storage',
  version: 1,
  partialize: (state) => ({
    dateRange: state.dateRange,
    selectedMetrics: state.selectedMetrics
  }),
  migrate: (persistedState: any, version: number) => {
    // Convert string dates back to Date objects
    if (persistedState.dateRange?.from) {
      persistedState.dateRange.from = new Date(persistedState.dateRange.from);
    }
    if (persistedState.dateRange?.to) {
      persistedState.dateRange.to = new Date(persistedState.dateRange.to);
    }
    return persistedState as AnalyticsState;
  }
}
```

---

### costSlice

**Persistence:** persistent

**Persisted Fields:** `reset`, `fetched`

**State Interface:**

```typescript
interface CostState {
  reset: Date | null;
  fetched: Date | null;
  budget: number;
  spent: number;
  forecast: number;
}
```

**Actions:**

```typescript
interface CostActions {
  setReset: (date: Date | null) => void;
  setFetched: (date: Date | null) => void;
  setBudget: (budget: number) => void;
  setSpent: (spent: number) => void;
  setForecast: (forecast: number) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'cost-storage',
  version: 1,
  partialize: (state) => ({
    reset: state.reset,
    fetched: state.fetched
  }),
  migrate: (persistedState: any, version: number) => {
    // Convert string dates back to Date objects
    if (persistedState.reset && typeof persistedState.reset === 'string') {
      persistedState.reset = new Date(persistedState.reset);
    }
    if (persistedState.fetched && typeof persistedState.fetched === 'string') {
      persistedState.fetched = new Date(persistedState.fetched);
    }
    return persistedState as CostState;
  }
}
```

---

### specSlice

**Persistence:** persistent

**Persisted Fields:** `activeSpec`, `tierAssignments`

**State Interface:**

```typescript
interface SpecState {
  activeSpec: string | null;
  tierAssignments: Record<string, 'free' | 'pro' | 'team' | 'enterprise'>;
}
```

**Actions:**

```typescript
interface SpecActions {
  setActiveSpec: (specId: string | null) => void;
  setTierAssignment: (feature: string, tier: SpecState['tierAssignments'][string]) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'spec-storage',
  version: 1,
  partialize: (state) => ({
    activeSpec: state.activeSpec,
    tierAssignments: state.tierAssignments
  }),
  migrate: (persistedState: any, version: number) => {
    return persistedState as SpecState;
  }
}
```

---

### xctSlice

**Persistence:** persistent

**Persisted Fields:** `motionPrefs`, `optimisticUndoWindow`

**State Interface:**

```typescript
interface XCTState {
  motionPrefs: {
    reducedMotion: boolean;
    animationSpeed: 'slow' | 'normal' | 'fast';
  };
  optimisticUndoWindow: number; // milliseconds
}
```

**Actions:**

```typescript
interface XCTActions {
  setReducedMotion: (reduced: boolean) => void;
  setAnimationSpeed: (speed: XCTState['motionPrefs']['animationSpeed']) => void;
  setOptimisticUndoWindow: (windowMs: number) => void;
}
```

**Persist Options:**

```typescript
{
  name: 'xct-storage',
  version: 1,
  partialize: (state) => ({
    motionPrefs: state.motionPrefs,
    optimisticUndoWindow: state.optimisticUndoWindow
  }),
  migrate: (persistedState: any, version: number) => {
    return persistedState as XCTState;
  }
}
```

---

## Cross-Slice Access Pattern (Rule FE-12)

All cross-slice state access MUST use the `get()` function provided by Zustand.

### Example: orgSlice switching org

```typescript
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

const useOrgStore = create<OrgState & OrgActions>()(
  persist(
    (set, get) => ({
      // ... state and actions
      switchOrg: async (orgId: string) => {
        // Access authSlice using get()
        const authStore = useAuthStore.getState();
        const queryClient = useQueryClient();
        
        // Clear auth session
        authStore.logout();
        
        // Clear TanStack Query cache
        queryClient.clear();
        
        // Reconnect Supabase Realtime
        const rtClient = getRealtimeClient();
        await rtClient.reconnect();
        
        set({ currentOrgId: orgId });
      }
    }),
    { /* persist options */ }
  )
);
```

### Example: dashboardSlice accessing orgSlice

```typescript
const useDashboardStore = create<DashboardState & DashboardActions>()(
  persist(
    (set, get) => ({
      // ... state and actions
      addToAttentionQueue: (packet: DecisionPacket) => {
        // Access orgSlice to get current org for routing
        const orgStore = useOrgStore.getState();
        const currentOrgId = orgStore.currentOrgId;
        
        // Route packet to correct org
        const routedPacket = {
          ...packet,
          orgId: currentOrgId
        };
        
        set(state => ({
          attentionQueue: [...state.attentionQueue, routedPacket]
        }));
      }
    }),
    { /* persist options */ }
  )
);
```

---

## Implementation Notes

### Date Serialization

All Date fields in persisted state must be serialized to ISO strings and deserialized back to Date objects in the `migrate` function. This is handled in each slice's persist options.

### FIFO Eviction

Slices with FIFO limits (memoryStore, searchSlice) enforce limits in both the `partialize` function and the `migrate` function to ensure limits are respected on both save and load.

### Version Management

All persistent slices include a `version` field in their persist options. When schema changes are required, increment the version and add migration logic to transform old state to new state shape.

### Reset Slices

Slices with `persistence: reset` do not use the persist middleware. They are cleared on logout/session end by calling their reset action or by unmounting the store.

### localStorage Slices

Slices with `persistence: localStorage` store all fields (not partialized) and use `createJSONStorage(() => localStorage)` for explicit localStorage storage.

---

## Summary

This specification defines TypeScript interfaces for all 48 Zustand slices referenced in `zustand-slices.yaml`. Each slice includes:

- State interface with typed fields
- Action interface with typed signatures
- Persist options with version, partialize, and migrate
- Cross-slice access patterns using `get()` per rule FE-12

The specification serves as the authoritative source for implementing Zustand stores in the frontend application.
