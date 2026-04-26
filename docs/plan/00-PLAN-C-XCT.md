---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-C-XCT.md
document_type: component_specification
module: CrossCutting
tier: infrastructure
status: stable
owner: Platform Engineering
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
dependencies: [00-PLAN-1-INTRO.md, 00-PLAN-C-KNOWLEDGE.md]
related_adrs: [ADR_054, ADR_058, ADR_062, ADR_063, ADR_064, ADR_065, ADR_067, ADR_076, ADR_077, ADR_079, ADR_082]
related_rules: [XCT_01, XCT_02, XCT_03, XCT_04, XCT_05, XCT_06, FLOWC_01, FLOWC_02, APIC_01, APIC_02, EVNT_01, EVNT_02, TESTC_01, TESTC_02, TESTC_03, TESTC_04, TESTC_05, OPSR_01, OPSR_02, OPSR_03, FFLG_01, FFLG_02, COST_01, MIGR_01, OBSS_01, OBSS_02, SECM_01, SECM_02, SECM_03, PASS_01, GRDL_01, PRIV_01, STKB_01, COMP_01, YJS_01, NYLS_01, CRDB_01, RLMT_01, UPSC_01, RCLL_01]
complexity: high
risk_level: critical
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
