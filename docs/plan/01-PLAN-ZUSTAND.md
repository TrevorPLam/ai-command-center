# Zustand Store Configuration

All Zustand slices with persistence configuration and persisted fields.

## Slice Configuration

| Slice | Persistence | Persisted Fields | Notes |
|---|---|---|---|
| authSlice | reset | - | Cleared on logout |
| uiSlice | persistent | cmdPaletteOpen | Command palette visibility |
| orgSlice | persistent | currentOrgId | Current organization selection |
| dashboardSlice | persistent | agentFilter | Active agent filter |
| chatSlice | persistent | activeThreadId | Currently selected chat thread |
| workflowSlice | reset | - | Cleared on session end |
| projectSlice | persistent | currentView, filters | Project view preferences |
| calendarSlice | persistent | activeDate, sidebarCal | Calendar navigation state |
| emailSlice | persistent | activeAccount, selectedFolder | Email client state |
| contactsSlice | reset | - | Cleared on logout |
| conferenceSlice | reset | - | Meeting state cleared after session |
| translationSlice | persistent | languages | Preferred translation languages |
| newsSlice | persistent | feedFilter, pausedFeeds | News feed preferences |
| documentsSlice | persistent | currentFolder | Document browser location |
| researchSlice | persistent | activeNotebook | Current research notebook |
| mediaSlice | persistent | selectedAlbum | Media gallery selection |
| budgetSlice | persistent | selectedAccount, dateRange | Budget view preferences |
| settingsSlice | localStorage | all | User settings persisted to localStorage |
| mcpSlice | persistent | version | Version for rehydration handling |
| agentStore | persistent | version | Version for rehydration handling |
| promptStore | localStorage | all | Prompt history in localStorage |
| canvasStore | reset | - | Canvas state cleared on exit |
| memoryStore | max 50 FIFO | working, episodic | FIFO eviction at 50 items |
| triageSlice | reset | - | Triage state cleared after action |
| recurrenceStore | reset | - | Recurrence form state |
| notificationSlice | persistent | unreadCount | Notification badge count |
| searchSlice | persistent | history (max 50), recentEntities (max 20) | Search history with limits |
| analyticsSlice | persistent | dateRange, selectedMetrics | Analytics view preferences |
| costSlice | persistent | reset, fetched | Cost tracking state |
| specSlice | persistent | activeSpec, tierAssignments | Active specification tracking |
| xctSlice | persistent | motionPrefs, optimisticUndoWindow | Cross-cutting service preferences |
| flowcSlice | persistent | workflowSMs | Workflow state machines |
| apicSlice | persistent | openApiVersion, codegenConfig | API client configuration |
| evntSlice | persistent | eventSchemas, ICs | Event contract schemas |
| testcSlice | persistent | coverageTargets, gateThresholds | Testing coverage thresholds |
| opsrSlice | persistent | incidentSeverity, roles | Ops runbook configuration |
| fflgSlice | persistent | flagStages, killSwitch | Feature flag states |
| migSlice | persistent | strategy, EBCsteps | Migration strategy settings |
| obsSlice | persistent | SLOs, EBs, BRs | Observability thresholds |
| secmSlice | persistent | controls, evidence | Security matrix data |
| mcp2Slice | persistent | oauthConfig, schemaAllowlists | MCP security configuration |
| passSlice | persistent | passkeyEnrollments, recoveryCodes | Passkey authentication state |
| taurSlice | persistent | capabilities, depAudit | Tauri desktop capabilities |
| mobnSlice | persistent | pushPermissions, deepLinkRoutes | Mobile notification settings |
| grdlSlice | persistent | guardrailRules, auditLogs | AI guardrails configuration |
| ssrfSlice | persistent | allowlistRules, dnsValidation | SSRF prevention rules |
| privSlice | persistent | trainingOptOuts, privacySettings | Privacy preference settings |
| stkbSlice | persistent | tokenMarkup, usageRecords | Stripe billing configuration |
| compSlice | persistent | evidence, controlMapping | Compliance tracking data |
| yjsSlice | persistent | gcEnabled, undoStackSize, snapshotVersions | Yjs collaboration settings |
| nylsSlice | persistent | webhookQueue, SyncPolicy | Nylas integration state |
| otelSlice | persistent | rootSpanProp, redactionRules | OpenTelemetry configuration |
| crdbSlice | persistent | tombstoneConfig, idStrategy | Offline-first data strategy |
| rlmtSlice | persistent | channelLimits, memThresholds | Realtime limits configuration |
| upscSlice | persistent | scanConfig, cvePinning | Upload security settings |
| rcllSlice | persistent | recurrenceRules, dstConfig | Recurrence engine settings |

## Persistence Types

| Type | Description |
|---|---|
| **reset** | Slice is cleared on logout/session end |
| **persistent** | Slice persists to configured storage (localStorage with version+migrate+partialize) |
| **localStorage** | All slice data stored in localStorage |
| **max 50 FIFO** | FIFO eviction when 50 item limit reached |