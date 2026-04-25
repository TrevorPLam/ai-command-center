---
steering: TO PARSE - READ INTRO
document_type: zustand_slices
tier: infrastructure
description: Zustand store slice configurations with persistence settings
last_updated: 2026-04-25
version: 1.0
---

# ZV - Zustand Slices

slice|persist
authSlice|reset  uiSlice|cmdPaletteOpen  orgSlice|currentOrgId  dashboardSlice|agentFilter
chatSlice|activeThreadId  workflowSlice|reset  projectSlice|currentView,filters
calendarSlice|activeDate,sidebarCal  emailSlice|activeAccount,selectedFolder  contactsSlice|reset
conferenceSlice|reset  translationSlice|languages  newsSlice|feedFilter,pausedFeeds
documentsSlice|currentFolder  researchSlice|activeNotebook  mediaSlice|selectedAlbum
budgetSlice|selectedAccount,dateRange  settingsSlice|localStorage  mcpSlice|version,rehydrate
agentStore|version,rehydrate  promptStore|localStorage  canvasStore|reset
memoryStore|max50FIFO  triageSlice|reset  recurrenceStore|reset
notificationSlice|unreadCount  searchSlice|history max50,recentEntities max20
analyticsSlice|dateRange,selectedMetrics  costSlice|reset,fetched
specSlice|activeSpec,tierAssignments  xctSlice|motionPrefs,optimisticUndoWindow
flowcSlice|workflowSMs  apicSlice|openApiVersion,codegenConfig  evntSlice|eventSchemas,ICs
testcSlice|coverageTargets,gateThresholds  opsrSlice|incidentSeverity,roles
fflgSlice|flagStages,killSwitch  migSlice|strategy,EBCsteps  obsSlice|SLOs,EBs,BRs
secmSlice|controls,evidence  mcp2Slice|oauthConfig,schemaAllowlists
passSlice|passkeyEnrollments,recoveryCodes  taurSlice|capabilities,depAudit
mobnSlice|pushPermissions,deepLinkRoutes  grdlSlice|guardrailRules,auditLogs
ssrfSlice|allowlistRules,dnsValidation  privSlice|trainingOptOuts,privacySettings
stkbSlice|tokenMarkup,usageRecords  compSlice|evidence,controlMapping
yjsSlice|gcEnabled,undoStackSize,snapshotVersions  nylsSlice|webhookQueue,SyncPolicy
otelSlice|rootSpanProp,redactionRules  crdbSlice|tombstoneConfig,idStrategy
rlmtSlice|channelLimits,memThresholds  upscSlice|scanConfig,cvePinning
rcllSlice|recurrenceRules,dstConfig
