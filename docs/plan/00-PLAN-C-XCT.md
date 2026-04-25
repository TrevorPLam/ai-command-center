---
steering: TO PARSE - READ INTRO
document_type: component_specification
module: CrossCutting

tier: infrastructure
component_count: 17
dependencies:
- ~h/useShouldAnimate
- useOptimistic
- ~h/useUndo
- SB Realtime
- SSE
motion_requirements:
- @M (MotionGuard)
- @O (OptimisticMutation)
- @SS (SSEStream)
- @RLMT (RealtimeLimits)
accessibility:
- WCAG 2.2 AA compliance
- Keyboard navigation
- Screen reader support
performance:
- Transform/opacity only
- Channel memory monitoring
last_updated: 2026-04-25
version: 1.0
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Spec/XCT Services (impl components)
CrossCuttingMotion|XCT|Service|@M|P1,P2|~h/useShouldAnimate|transform/opacity only
CrossCuttingOptimistic|XCT|Service|@O|g19|useOptimistic,~h/useUndo|pending,rollback,undo5s
CrossCuttingRealtime|XCT|Service|@SS,@RLMT|g37,g43|SB Realtime,SSE|chan auth,mem mon,hb15s
CrossCuttingSearch|XCT|Service|-|g33|nuqs,useInfiniteQuery|debounce300ms,hoverPrefetch200ms
CrossCuttingOffline|XCT|Service|@CRDB|B5|IndexedDB,ULID|outbox,IC,conflict res
CrossCuttingAuthOrg|XCT|Service|@PASS|S8|SB Auth,JWT hook|org switch→qclient.clear()+RT reconnect
APIContractGen|APIC|Util|-|OAPI_01|FastAPI,OR,SC|OAI→TS+hooks+MSW,CI drift gate
NylasWebhookHandler|NYLS|Service|@NYLS|S3|NY v3,queue|upsert-first,10s ack,Sync Policy
OTelGenAIInstrumenter|OTEL|Service|@OTEL|SLO_02|OTel1.39,DataPrepper|root span prop,PII redact
OfflineSyncEngine|CRDB|Service|@CRDB|B5|cr-sqlite vs outbox|tombstone,ULID,conflict res
RealtimeChannelMonitor|RLMT|Service|@RLMT|g37,g43|SB Realtime|100ch ceil,20rec,payload caps
UploadSecurityScanner|UPSC|Service|-|S10|CA clamd|server-side,chunked,CVE mon
RecurrenceEngineService|RCLL|Service|@RCLL|B-015|@martinhipp/rrule,Temporal|DST wall-clock,3 edit modes
AIGuardrailsEngine|GRDL|Service|@GRDL|EVAL_02|Guardrails-AI,DeepEval|input+output+runtime,audit
SSRFPreventionMiddleware|SSRF|Middleware|@SSRF|MCPG_02|ipaddress,DNS resolver|allowlist,redirect block
StripeTokenMeter|STKB|Service|@STKB|@stripe/ai-sdk,@stripe/token-meter|LiteLLM cost log|30% markup
YjsLifecycleManager|YJS|Service|@YJS|YSW_01,YSW_02|Yjs,YS|GC on,undo trunc,snapshot,50MB
