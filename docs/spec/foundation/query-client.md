---
id: foundation.query-client
title: Query Client Configuration
type: architecture
last_updated: '2026-04-24T23:37:09.419199+00:00'
---

# Query Client Configuration

| Param | Value |
|-------|-------|
| staleTime | 5min (chat:0,gcTime=∞) |
| retry | 2 |
| refetchOnWindowFocus | false |
| cache key pattern | [moduleKey,...] |
| error handling | network→retry→toast;401→refresh→redirect;403→toast+log;429→[RL];500→ErrorBoundary/toast |
| mutations | useOptimisticMutation wrapper |
| SSE | useSSE for AI streams,abortable,retry3 backoff |
| org switch | invalidate all queries,reconnect Realtime |
| SLICE | FIELDS |
| authSlice | currentUser,session,loading,error |
| uiSlice | cmdPaletteOpen,voiceShellOpen,rightPanelContent,focusTriggerRef,activeModal |
| orgSlice | currentOrgId,orgs[] |
| dashboardSlice | agentFilter,attentionQueue |
| chatSlice | activeThreadId,messageInputs,canvasState,knowledgeBaseActive |
| workflowSlice | canvasNodesEdges,executionState,selectedNode,executionLog |
| projectSlice | currentView,filters,selectedProjectId,taskOrder,triageState |
| calendarSlice | activeDate,selectedEventId,sidebarCalendars,recurrenceEditMode |
| emailSlice | activeAccount,selectedFolder,composeState,searchQuery |
| contactsSlice | selectedContactId,quickAddOpen,enrichmentQueue |
| conferenceSlice | roomState,participants,recordingState |
| translationSlice | sessionState,languages,segments |
| newsSlice | feedFilter,pausedFeeds,readingState |
| documentsSlice | currentFolder,selectedFile,uploadQueue |
| researchSlice | activeNotebook,currentDocument,quizState |
| mediaSlice | selectedAlbum,generationQueue |
| budgetSlice | selectedAccount,dateRange,transactionFilter |
| settingsSlice | activeSection |
| mcpSlice | toolRegistry |
| agentStore | agentDefinitions,outputCache,sharedDefinitions |
| promptStore | promptTemplates,promptVersions |
| canvasStore | roomId,connectionStatus,awareness |
| memoryStore | crossSessionSummaries,events |
| triageSlice | triageItems,actionTray |
| recurrenceStore | per-instance edit state |
| notificationSlice | toasts,inAppNotifications,unreadCount |
| searchSlice | globalQuery,searchHistory,recentEntities |
| analyticsSlice | dateRange,selectedMetrics,comparisonMode,agentMetrics,costMetrics |
| costSlice | monthlyUsage,budgetLimits,alerts |
| DIRECTIVE | VALUE |
| default-src | 'self' |
| script-src | 'self' 'nonce-{RANDOM}' 'strict-dynamic' |
| style-src | 'self' |
| style-src-attr | 'unsafe-inline' (required for programmatic transforms) |
| img-src | 'self' blob: data: https://*.supabase.co |
| connect-src | 'self' localhost:8000 https://*.supabase.co wss://*.supabase.co https://api.nylas.com https://<livekit-host> wss://<livekit-host> wss://<y-sweet-host> |
| frame-src | blob: |
| font-src | 'self' |
| object-src | 'none' |
| base-uri | 'self' |
| form-action | 'self' |
| worker-src | blob: |
| child-src | blob: |
| TABLE | KEY COLUMNS(PK/FK bold) |
| messages | **id** uuid,thread_id FK,role,content,metadata |
| threads | **id** uuid,user_id FK,title,created_at |
| projects | **id** uuid,**org_id** FK,name,status,priority |
| tasks | **id** uuid,**org_id** FK,project_id FK,title,status |
| events | **id** uuid,**org_id** FK,title,start,end,recurrence_id FK |
| emails | **id** uuid,**org_id** FK,nylas_message_id,subject,from |
| contacts | **id** uuid,**org_id** FK,name,email,phone |
| documents | **id** uuid,**org_id** FK,storage_path,title,mime_type |
| media | **id** uuid,**org_id** FK,storage_path,alt_text,blurhash |
| transactions | **id** uuid,**org_id** FK,amount,category,date |
| goals | **id** uuid,**org_id** FK,target,current,deadline |
| researchNotebooks | **id** uuid,**org_id** FK,title,content |
| flashcards | **id** uuid,**org_id** FK,notebook_id FK,front,back |
| conferenceRooms | **id** uuid,**org_id** FK,livekit_room_id,title |
| translationSessions | **id** uuid,**org_id** FK,source_lang,target_lang |
| newsArticles | **id** uuid,**org_id** FK,url,title,sentiment |
| workflowExecutions | **id** uuid,**org_id** FK,workflow_id FK,status |
| audit_logs | **id** uuid,user_id FK,action,entity_type,entity_id |
| notificationPreferences | **id** uuid,user_id FK,preferences jsonb |
| org_members | **id** uuid,**org_id** FK,user_id FK,role_id FK |
| connected_accounts | **id** uuid,user_id FK,**org_id** FK,grant_id enc,provider |
| organizations | **id** uuid,name,plan,created_at |
| feature_flags | **id** uuid,key,enabled,rollout_percentage |
| notifications | **id** uuid,user_id FK,type,data jsonb,read |
| user_roles | **id** uuid,role_name,description |
| role_permissions | **id** uuid,role_id FK,resource,action |
| agent_definitions | **id** uuid,**org_id** FK,name,system_prompt,tools jsonb,version |
| recurrence_rules | **id** uuid,entity_type,entity_id,rrule_string,exceptions jsonb |
| ai_cost_log | **id** uuid,tokens,model,user_id FK,org_id FK,timestamp |
| prompt_versions | **id** uuid,prompt_id FK,content,variables jsonb,metrics jsonb |
| eval_datasets | **id** uuid,name,test_cases jsonb |
| eval_runs | **id** uuid,dataset_id FK,agent_id FK,scores jsonb |
| collab_documents | **id** uuid,**org_id** FK,ydoc_name,permissions jsonb |
| METHOD | ENDPOINT |
| POST | /v1/agent/eval |
| GET | /v1/realtime/channels |
| DELETE | /v1/organizations/:id |
| GET/POST | /v1/agent/definitions |
| PATH | PAGE COMPONENT |
| /login | LoginPage |
| /auth/login | LoginPage |
| /auth/signup | SignupPage |
| /auth/callback | OAuthCallbackPage |
| /auth/reset | PasswordResetPage |
| /auth/verify | EmailVerificationPage |
| / | DashboardPage |
| /chat | ChatPage |
| /chat/:threadId | ChatPage |
| /workflows | WorkflowListPage |
| /workflows/:id | WorkflowCanvasPage |
| /projects | ProjectsPage |
| /projects/:id | ProjectDetailPage |
| /triage | TriagePage |
| /calendar | CalendarPage |
| /email | EmailPage |
| /contacts | ContactsPage |
| /conference | ConferencePage |
| /translation | TranslationPage |
| /news | NewsPage |
| /documents | DocumentsPage |
| /research | ResearchPage |
| /media | MediaPage |
| /budget | BudgetPage |
| /settings | SettingsPage |
| /settings/:section | SettingsPage |
| /analytics | AnalyticsPage |
| /audit-log | AuditLogPage |
| /agent-studio | AgentStudioPage |
| /agent-studio/:agentId | AgentStudioPage |
| /agent-playground | AgentPlaygroundPage |
| #SCHEMA: Mod | Component |
| F | LiveKitProvider |
| D | AgentDetailDrawer |
| C | AgentPlayground |
| W | PerformanceMetrics |
| P | GlobalSearchDialog |
| A | BulkActionBar |
| E | AgentEmailComposer |
| K | WorkflowAutomation |
| CF | LiveCaptionOverlay |
| T | StreamingHook |
| N | SearchPanel |
| DC | RealTimeCoEdit |
| R | ReportGenerator |
| M | StorageAnalytics |
| B | SpendingInsightsCard |
| S | MCPSettings |
| PL | AgentPlaygroundPage |
| Setting | Value |
| Version | >=3.4 |
| SanitizedHTML Component | Required |
| ALLOWED_TAGS | Whitelist only |
| ALLOWED_ATTR | Whitelist only |
| FORBID_TAGS | script,style,iframe,object,embed,svg,math |
| FORBID_ATTR | on*,javascript:,data: (except images) |
| SVG_INLINE | Disabled |
| ADD_ATTR | data-* |
| CUSTOM_ELEMENT_HANDLING | tagNameCheck:null,attributeNameCheck:null |
| SANITIZE_DOM | true |
| KEEP_CONTENT | true |
| RETURN_DOM | false |
| RETURN_DOM_FRAGMENT | false |
| FORCE_BODY | true |
| Errors:Sentry | GlitchTip,RUM:PostHog,Logs:structured,Web Vitals:LCP INP CLS,Custom metrics:AI token consumption,Nylas latency,Realtime lag,agent cost/latency |
| task001 [H | O] Implement login page → authSlice, supabase @bob 5 DoD1 |
| task002.1 [M | O] Configure GitHub Actions |
| task003 [H | P] Build chat real-time → task001,lkc,lkr @alice 13 DoD1 |

