V|plan|2026-04-25T12:00Z|LEXICON=V4+OPT1
// OPT1: merged KV+EXT; removed DoD (derivable from Rules); collapsed g-rules; removed redundant ADR/SPEC inline; compressed table cols

#LEX
// Motion
@M|MotionGuard @AP|AnimatePresence(page) @AS|Spring(≥300,≥30) @AG|StaggerChildren(spring120,14;max3)
@Q|OpacityFade≤150ms @S|Static @P|PopLayout
// Data/State
@O|OptimisticMutation @V|VirtualizeList @C|ChatCache @E|InlineEdit @I|InfiniteScroll
@D|DebounceAutoSave @SS|SSEStream @MEM|TieredMemory @CACHE|PromptCaching
// UI
@T|TriageColor @Z|TimezoneAware @K|KeyboardShortcuts @H|HoverPrefetch
// Infra
@U|Upload @F|FileHandling @X|SandboxIframe @A|A2AFlow @W|WorkflowExecution @R|Recurring
// Spec/Arch
@SPEC|SpecTemplate @TIER|ComponentTiering(1=standalone,2=grouped,3=presentational)
@XCT|CrossCuttingSpec @FLOWC|FlowContract @APIC|APIContract @EVNT|EventContract
@TESTC|TestContract @OPSR|OpsRunbook @FFLG|FeatureFlag @COST|CostControl
@MIGR|MigrationStrategy @OBSS|Observability @SECM|SecurityMatrix @MCP2|MCPSecurity
@PASS|Passkeys @TAUR|TauriDesktop @MOBN|MobileNotif @GRDL|AIGuardrails
@SSRF|SSRFPrevention @PRIV|PrivacyAI @STKB|StripeBilling @COMP|ComplianceCode
@YJS|YjsLifecycle @NYLS|NylasV3 @OTEL|OTelGenAI @CRDB|OfflineFirst
@RLMT|RealtimeLimits @UPSC|UploadSecurity @RCLL|RecurrenceEngine
// Domain shortcuts (new)
D|ORG=org_id scoped+RLS
D|SWR=server-wins rollback
D|LWW=last-write-wins via uat
D|IC=idempotency key=actor_id+monotonic_counter
D|EBC=expand-contract pattern
D|ZDT=zero-downtime
D|EB=error budget
D|BR=burn rate
D|SB=Supabase
D|LK=LiveKit
D|LLM=LiteLLM proxy
D|PB=pgTAP
D|NY=Nylas v3
D|ST=Stripe
D|CA=ClamAV(clamd)
D|DP=DOMPurify≥3.4
D|OAI=OpenAPI3.1
D|OR=Orval
D|SC=Schemathesis
D|VT=Vanta/Oneleet
D|YS=Y-Sweet
D|ODP=OpenDP
D|RLS=Row Level Security via JWT claim
// Additional domain shortcuts (Apr 2026)
D|MCPS=MCPSecLayer (IETF draft, L0-L4)
D|OWASP_MCP=OWASP MCP Top10
D|OWASP_ASI=OWASP Agentic Top10 (ASI 2026)
D|A2A_V1=A2Av1.0 stable (Linux Foundation)
D|ESM=ES2026 (match, using, etc.)
D|TSG=TypeScript 7.0 Go-native (tsgo)
D|RESP=OpenAI Responses API (migrate by Aug26)
D|grantexp=Nylas grant.expired webhook
D|NOHAIKU=No Haiku in agentic contexts

#DICT
G1|85/35|±2% G2|80/30|±5% G3|82/32|±2% G4|80/40|±2% G5|90/45|±2%
G6|85/45|±2% G7|95/40|±2% G8|90/40|±2%
// Qual presets: temp/topP/~/~/~/~/guard|variance

#C Components

Components have been extracted into module-specific files for token optimization:

## Core Modules
- **Shell**: 00-PLAN-C-SHELL.md (11 components)
- **Dashboard**: 00-PLAN-C-DASHBOARD.md (8 components)  
- **Chat**: 00-PLAN-C-CHAT.md (22 components)
- **Workflow**: 00-PLAN-C-WORKFLOW.md (8 components)
- **Projects**: 00-PLAN-C-PROJECTS.md (24 components)

## Feature Modules
- **Calendar**: 00-PLAN-C-CALENDAR.md (11 components)
- **Email**: 00-PLAN-C-EMAIL.md (12 components)
- **Contacts**: 00-PLAN-C-CONTACTS.md (11 components)
- **Conference**: 00-PLAN-C-CONFERENCE.md (7 components)
- **Translation**: 00-PLAN-C-TRANSLATION.md (6 components)
- **News**: 00-PLAN-C-NEWS.md (6 components)
- **Documents**: 00-PLAN-C-DOCUMENTS.md (9 components)
- **Research**: 00-PLAN-C-RESEARCH.md (6 components)
- **Media**: 00-PLAN-C-MEDIA.md (6 components)
- **Budget**: 00-PLAN-C-BUDGET.md (7 components)
- **Settings**: 00-PLAN-C-SETTINGS.md (12 components)
- **Platform**: 00-PLAN-C-PLATFORM.md (11 components)

## Cross-Cutting Services
- **XCT Services**: 00-PLAN-C-XCT.md (17 components)

## Dependencies Analysis
See **00-PLAN-C-DEPENDENCIES.md** for comprehensive cross-component dependency analysis and optimization opportunities.

#RULES|id|scope|sev|desc
// HARD UI/State
ZIndexStack|ui|H|toast60>cmdPalette50>modal40>drawer30>sheet20
ZustandSelectors|state|H|useShallow on object selectors
GlobalUIState|state|H|no useState for global UI→Zustand slices
DragAndDrop|arch|H|only via ~l/dnd.ts
DOMPurifyGlobal|sec|H|no dangerouslySetInnerHTML; DP≥3.4
SupabaseStorageWrapper|arch|H|StorageService wrapper only
NylasAPIAccess|arch|H|NY→FastAPI only
PrismaClientBoundary|arch|H|no Prisma in browser
AICallsProxy|arch|H|all AI→LLM proxy only
DragKeyboardAlt|a11y|H|kbd alt for drag(WCAG2.5.7)
localStorageQuota|storage|H|≤3MB,eviction priority
CanvasAlternative|a11y|H|canvas/visual→text alternative
AIMediaAltText|a11y|H|auto alt text,never empty
InAppNotifications|ux|H|template+deeplink
@COMPILER|state|H|React Compiler globally; no manual memo
// Additional rules (Apr 2026)
COMPILER_CARVEOUT|state|H|RHF components: "use no memo"; Zustand persist: conditional not Suspense; Zustand core: exempt
NO_HAIKU_AGENTIC|ai|H|Haiku 4.5 excluded from agentic deployments with untrusted input
LITELLM_PIN|sec|H|litellm>=1.83.7 with cosign/SHA verification
ORVAL_PIN|sec|H|orval>=8.2.0, never run on untrusted specs
MCP_INSPECTOR_DEVSEC|sec|H|pin >=0.14.1; firewall block dev access
Y_SWEET_SELFHOST|ops|H|Jamsocket shutdown March 2026; Y-Sweet self-host mandatory
NO_CRSQLITE|arch|H|cr-sqlite unmaintained; remove from offline eval
NO_REPLICACHE|arch|H|Replicache in maintenance; replace with PowerSync or Zero
MCP_SDK_AUDIT|sec|H|audit MCP SDKs for OX Security Apr15 2026 vuln; MCPSec L2 mandatory for prod
GRANT_EXPIRED_WEBHOOK|sec|H|handle grant.expired; re-auth <72h or data loss
EDGE_NO_DB|arch|H|Vercel Edge Functions cannot connect DB; route webhooks via Serverless/FastAPI
OPENAI_RESPONSES_MIGRATE|ai|H|migrate from Assistants/ChatCompletions to Responses API by Aug26
GRDL_01|ai|H|3-layer: Input(PII/jailbreak/tox),Output(halluc/safety/schema),Runtime(tool auth/cost); all logged; map to ASI01-ASI10
// HARD Security S1-S21 (canonical list; impl mechanisms in #KV SECURITY)
S1|sec|H|no dangerouslySetInnerHTML
S2|sec|H|SB Storage→StorageService
S3|sec|H|NY→FastAPI only
S4|sec|H|FE supabase-js,no Prisma
S5|sec|H|Prisma changes→RLS impact check
S6|sec|H|Global CSP enforced prod
S7|sec|H|unsafe-eval scoped Monaco/Babel nonce
S8|sec|H|JWT not in Zustand/localStorage
S9|sec|H|/v1/* via api.ts
S10|sec|H|DP audit,CVE CI
S11|sec|H|nonce CSP,strict-dynamic
S12|sec|H|LK tokens scoped,RBAC
S13|sec|H|role-based access,no ad-hoc
S14|sec|H|rate limits
S15|sec|H|Org delete cascade,notify 7d prior
S16|sec|H|Agent UI trusted catalog only
S17|sec|H|Yjs collab opt-in,separate doc types
S18|sec|H|AI cost hard cap LLM,frontend budget
S19|sec|H|MCP tools admin approval,logged
S20|sec|H|AI cost thresholds,RATE_LIMITED
S21|sec|H|OAI contract,TS types gen
// HARD Spec/Arch
SPEC_01|tooling|H|no async/optimistic/streaming comp reaches DoD1 without dedicated spec or linked parent spec
TIER_01|arch|H|Tier1 comps require standalone spec
XCT_01|ui|H|anim: transform/opacity only; prefers-reduced-motion; stagger≤3
XCT_02|ui|H|optimistic: pending=opacity0.5+italic+pulse; undo5s for delete
XCT_03|arch|H|SSE: Last-Event-ID persist; hb15-20s; token batching via rAF
XCT_05|arch|H|search: type:/before:/after:/assigned:/status:; debounce300ms; nuqs sync
XCT_06|sec|H|auth: JWT via custom_access_token_hook; org switch→qclient.clear()+RT reconnect
FLOWC_01|arch|H|workflow SM: IDLE→PENDING→RUNNING→WAITING→COMPLETED/FAILED/CANCELLED; COMPENSATING reverse
FLOWC_02|arch|H|optimistic SM: IDLE→PENDING→CONFIRMED/FAILED→ROLLED_BACK; all4 testable
APIC_01|arch|H|OAI3.1 source of truth; OR codegen; SC CI gate blocks drift
EVNT_01|arch|H|SSE: event/msg/id/data; Realtime: org:{orgId}:{table}; Webhook: idempotency via provider ID
EVNT_02|arch|H|every async op: actor ID+monotonic counter; dedup via UNIQUE
TESTC_01|test|H|unit: RFC5545 33 examples; DST; Zod boundary
TESTC_02|test|H|component: kbd nav; aria-live; reduced motion; optimistic rollback
TESTC_03|test|H|integration: MSW match OAI; optimistic rollback on 500; webhook→RT; org switch
TESTC_04|sec|H|PB RLS isolation; CSP unsafe-inline blocked; DP CVE audit; SSRF priv IP block; LK token scope
TESTC_05|ai|H|AI eval: acc≥base-2%;lat≤base+10%;tok≤base+15%;tool precision≥90%;halluc≤2%
OPSR_01|ops|H|P0-P3→SLOs; P0 immediate,15min updates; SOC2 annual testing
FFLG_01|release|H|flag: off→internal(2d)→beta(3d)→5/20/50%(2d ea)→100%; kill<5min
COST_01|sec|H|multi-level: org/team/user/model; LLM middleware 429; 15/5/0% alerts
MIGR_01|arch|H|EBC for schema changes; 6-step ZDT rename; CONCURRENTLY indexes
OBSS_01|perf|H|TTFT≤2s p95; avail 99.9%; RAG≤500ms p95; LCP≤800ms p75
OBSS_02|obs|H|EB actions: 50%→notify;80%→freeze;100%→incident; BR alerts(2%/1h page)
SECM_01|sec|H|every S1-S21 mapped: control,mechanism,test,owner,evidence
SECM_02|sec|H|MCP: OAuth tool auth; schemas as allowlist; elicitation for high-risk
SECM_03|sec|H|SSRF: allowlist>blocklist; DNS+private IP validation; redirect off; IMDSv2
GRDL_01|ai|H|3-layer: Input(PII/jailbreak/tox),Output(halluc/safety/schema),Runtime(tool auth/cost); all logged
PRIV_01|sec|H|allow_training flag; data segregation opted-out; diff privacy for aggregates
YJS_01|arch|H|Yjs GC enabled(doc.gc=true); undo trunc last5; version via snapshots
NYLS_01|arch|H|NY v3: upsert-first; 10s timeout; async queue; Sync Policy
OTEL_01|obs|H|OTel1.39: gen_ai.system,model,usage.input_tokens,output_tokens,finish_reason,cost.usd
CRDB_01|arch|H|offline: tombstone(deleted_at nullable int ms); ULID; IC=actor_id+monotonic
RLMT_01|arch|H|SB Realtime: 100ch/conn; self 20; payload caps(Broadcast256KB-3MB,PgChanges1MB)
UPSC_01|sec|H|CA server-side(clamd,not WASM); CVE pin≥3.4; chunked validation
RCLL_01|arch|H|@martinhipp/rrule(FE);rrule Python(BE);DST via TZID;3 edit modes(single/following/all)
// MED rules (grouped by category)
// Perf
P1|perf|M|animate only transform/opacity
P2|perf|M|filter updates useTransition
// Storage/State
B1|ui|M|zustand persist version+migrate+partialize
B5|storage|M|localStorage ≤3MB,eviction
B6|state|M|crossSessionSummaries max50 FIFO
B7|state|M|agentDef/toolReg version only,rehydrate
// Arch
B2|arc|M|AI→LLM proxy only
B3|arc|M|NY webhooks→Edge Functions
B4|arc|M|MCP configs in SB
P3|db|M|org_id required,RLS joins
P4|arch|M|no @dnd-kit/react<1.0,centralized façade
// g-rules (legacy pattern enforcement; new code uses XCT/S/B rules above)
// Format: id|desc
g2|motion v12  g5|noise-overlay glass  g6|reduce→instant  g7|AP page transitions
g8|FocusRestore store  g9|kbd shortcuts in kbd  g10|WCAG2.2 AA  g11|userEvent.setup() per test
g12|imports from 'react-router'  g13|motion tokens  g15|SanitizedHTML  g16|NO dangerouslySetInnerHTML
g19|useOptimisticMutation wrapper  g20|VoiceShell+CmdPalette Zustand  g21|useRef+useCallback intervals
g22|useShallow Zustand object selectors  g24|Web Speech fallback  g25|Route lazy+ensureQueryData
g26|LCP≤800ms  g27|URL state sync via nuqs  g28|z-index stack  g29|toast pos,max3,undo
g30|loading states pattern  g31|empty states pattern  g32|error states pattern  g33|debounce values
g34|image loading  g35|responsive breakpoints  g36|kbd focus order  g37|SB Realtime lifecycle
g38|Monaco lazy load  g39|DP pinned≥3.4,CI audit  g40|react-helmet-async  g41|Monaco/Babel sandbox
g42|CSP Report-Only pre-prod  g43|Realtime ch: org:{orgId}:{table},private  g44|CA WASM upload scan
g45|EmptyState component  g46|document all env vars  g47|flag rollout 1%→100%,24h dwell
g48|prompt versioning,eval gate  g49|triage unified E,A,P  g50|in-app notifications template+deeplink
// Spec/Test rules (MED)
SPEC_02|tooling|M|yaml frontmatter+9 sections(Purpose,UXStates,Transitions,Data,Edge,Acceptance,A11y,Test,Risks)
TIER_02|arch|M|Tier2 grouped by module; Tier3 design system only
XCT_04|arch|M|offline: tombstone(deleted_at nullable); ULID; IC per op
FLOWC_03|ui|M|Loading:skeleton/shimmer; EmptyState required; error≠empty
APIC_02|arch|M|JSON Schema: $ref+allOf DRY; oneOf+discriminator poly; additionalProperties:false
TESTC_rule(all MED)|test|M|→see #TEST section for coverage targets
OPSR_02|ops|M|lifecycle: Detect(0-5m)→Assess(5-15m)→Comm(15-30m)→Mitigate→Resolve→Postmortem(48h)
OPSR_03|ops|M|roles: Lead(focus),Fixer(investigate),Comms(stakeholder),Note(log)
FFLG_02|arch|M|OpenFeature abstraction; default ON during flag outage
COST_02|arch|M|ai_cost_log TimescaleDB; continuous aggregates; GET /v1/cost-forecast
MIGR_02|ops|M|Prisma: EBC; migrate deploy prod; drift check CI; RLS versioning
OBSS_03|obs|M|OTel1.39 GenAI; root span via DataPrepper; PII redact at collector
SECM_rule_PASS|sec|M|passkeys: SB Auth MFA; cross-device QR; recovery codes; platform sync
SECM_rule_TAUR|sec|M|Tauri v2 Capabilities per window; dep chain audit; auto-update signing
SECM_rule_MOBN|arch|M|expo-notifications SDK53; dev build req Android; deep link matrix; OTA:critical only
GRDL_02|ai|M|all guardrail decisions logged; deterministic validators(not LLM-interpreted)
PRIV_02|ops|M|annual PIA; GDPR opt-out; TEE for sensitive analytics
STKB_01|arch|M|@stripe/ai-sdk(Vercel); @stripe/token-meter(native); 30% markup automation
STKB_02|arch|M|usage: ai_cost_log→ST meters; reconciliation job; budget enforcement
COMP_01|ops|M|VT evidence pipeline; GH Actions→Vanta→audit; SOC2 TSC mapping per HARD rule
COMP_02|ops|M|quarterly automated evidence refresh; HARD rule→SOC2 TSC→evidence artifact
YJS_02|arch|M|Yjs: max50MB; compaction@30MB; disconnect cleanup(ch unsub+flush)
NYLS_02|arch|M|burst: load-balanced processors; auto-scale; 72h failure threshold
OTEL_02|obs|M|root span: DataPrepper otel_trace_genai; attr normalization multi-vendor
CRDB_02|arch|M|sync: outbox MVP; eval cr-sqlite/ElectricSQL/Replicache Phase2
RLMT_02|obs|M|Realtime mem: alert@40MB/ch; max20 subs/user
UPSC_02|sec|M|server-side only; version pin; CVE CI; size/type pre-scan
RCLL_02|test|M|all 33 RFC5545; DST matrix(spring-fwd/fall-back/cross-tz/COUNT-span); exception O(1)

#VER
// id|ver|notes
TS|6.0prod  React|19.2.5→20.0 eval Q2  Vite|8.0.0  Zustand|5.0.12
TanStackQuery|5.100.1  Motion|12.38.0|import from motion/react
TailwindCSS|4.2.2  Prisma|7.8.0|pgbouncer=true
dndkit|6.3.1|community standard; NO migration to PragmaticDnD
Node|24.15.0LTS Krypton  Python|3.12  FastAPI|0.136.1
rbc|^1.19.4React19  yjs|13.6.21  dompurify|≥3.4.0  nuqs|^2.5
reacthelmet|latest  livekitagents|>=1.0.0,<2.0.0
livekitserversdk|>=1.0.0  markmap|latest  reactresizable|^3.1.3
QueryClient|staleTime5min,retry2,noRefocus,429→RL,useSSE
// New entries
ai|^6.0  @ai-sdk/react|^2.0  @tremor/react|^3.18
@stripe/ai-sdk|latest  @stripe/agent-toolkit|latest
@powersync/web|latest  litellm|>=1.83.7 (SHA verify)
orval|>=8.2.0  @anthropic/mcp-inspector|>=0.14.1 (devDep)
tsgo|7.0beta  temporal-polyfill|^0.3.0 (Safari gap)
pgvectorscale|0.4.0 (DiskANN)  @xyflow/react|12.10.2
OTel|v1.40.0+experimental  prisma-next|GA June-July 2026 (Postgres)

// See 00-PLAN-2-ZV.md for Zustand slice configurations
// See 00-PLAN-4-TBL.md for database table schemas
// See 00-PLAN-5-EP.md for API endpoints  
// See 00-PLAN-6-EXT.md for external service integrations
// See 00-PLAN-7-FLOWS.md for critical user flows

#ROUTE
login|authlogin|authsignup|authcallback|authreset|authverify
dashboard|chat|chat/:thread(hoverPrefetch)|workflows|workflow/:id
projects|project/:id|triage|calendar|email|contacts
conference|translation|news|documents|research|media|budget
settings|settings/:section|analytics|auditlog
agentstudio|agentstudio/:agent|agentplayground

#KV
See **00-PLAN-C-KNOWLEDGE.md** for comprehensive infrastructure patterns and architectural knowledge.

#RUNBOOKS
See **00-PLAN-C-RUNBOOKS.md** for operational procedures and incident response playbooks.

#TEST
See **00-PLAN-C-TESTING.md** for comprehensive testing strategy and coverage targets.

#BUDG
LCP|≤800ms p75  INP|≤200ms  CLS|≤0.1  TTFT|≤2s p95
Chunk_initial|150KB  Chunk_lazy|800KB  Chunk_monaco|2MB
Chunk_reactflow|200KB  Chunk_rbc|150KB  Chunk_yjs|300KB
// Key thresholds
Search_Debounce|300ms  HoverPrefetch|200ms  SSE_Heartbeat|15-20s
SSE_Reconnect|1s,2s,4s,8s,max30s(max3retry)  OrgSwitch_Cache|<2s
Undo_Window|5s(delete)  Stagger_Max|3 children  Spring|≥300 stiff,≥30 damp
NY_Ack|10s  NY_Failure_Threshold|95%/72h→auto-disable
RT_Platform|100ch  RT_Self|20ch  RT_Mem_Alert|40MB/ch
Incident_P0_Response|immediate  Incident_P0_Cadence|15min  Postmortem|48h
Flag_Dwell|internal:2d,beta:3d,5/20/50%:2d  Flag_Kill|<5min
Cost_Alerts|15%→admin,5%→admin+eng,0%→429  Cost_Forecast_Accuracy|±10%
SLO_TTFT|≤2s p95  SLO_Avail|99.9%  SLO_RAG|≤500ms p95  SLO_LCP|≤800ms p75
EB_50pct|notify  EB_80pct|feature freeze  EB_100pct|incident
BR_Critical|2%/1h→page  BR_Warning|5%/6h→Slack
Yjs_Limit|50MB; compaction@30MB; undo last5
// Additional bundle budgets (Apr 2026)
Chunk_tremor|15KB  Chunk_ai_sdk|10KB  Chunk_powersync|50KB
Chunk_temporal_polyfill|8KB  Chunk_es2026_shim|5KB (match/using)  EdgeFn_MaxCPU|50ms
// Offline cache budget
Offline_Storage|50MB IndexedDB per org
Stripe_Markup|30%  Compliance_Refresh|quarterly  OTel_Version|1.39.0
Upload_CA_Version|≥1.0.4  RBAC_Target|100% HARD rule→control  MCP_OAuth_Target|≥90%

#MIL+TSK
// Milestones
Foundation|Jan-Apr2026  Dashboard|Apr-Jun2026  Chat|Jun-Aug2026(Canvas active)
Workflows|Aug-Sep2026  Projects|Oct-Dec2026  Calendar|Jan-Feb2027
Phase2|H2 2027: ContextualRetrieval,AgentCard ecosystem,GraphRAG,PragmaticDnD,ReactCompiler opt
Spec_Framework|Q32026: frontmatter parser,tier classifier,9-section validator
CrossCutting_P1|Q32026: motion,optimistic,realtime-streaming,search specs
CrossCutting_P2|Q42026: offline-sync,auth-org,uploads,sandbox-csp,recurrence specs
FlowContracts|Q42026: workflow SM,optimistic transitions,Loading/Error/Empty
APIContracts|Q42026: OAI3.1 source of truth,OR codegen,SC CI gate
EventContracts|Q42026: SSE/RT/Webhook validators,IC strategy
TestPlans|Q12027: unit/component/integration/security/AI eval generators+CI gates
Ops_P1|Q32026: incident response,AI failure runbook,SB outage runbook
Ops_P2|Q42026: feature flags+kill switch,cost control,migrations,observability
Sec_P1|Q32026: MCP security(OWASP Top10+MS AGT),SSRF prevention
Sec_P2|Q42026: passkeys/WebAuthn,desktop(Tauri),mobile notif,AI guardrails,privacy-AI
Intg_P1|Q42026: NY v3 upsert-first+Sync Policy,ST token billing(@stripe/ai-sdk)
Intg_P2|Q12027: offline-first sync eval(cr-sqlite/ElectricSQL),OTel GenAI root span
Data_P1|Q42026: Yjs lifecycle(GC+undo+snapshots),RT limits monitoring,CA server-side
Data_P2|Q12027: recurrence DST testing,compliance-as-code evidence pipeline
// Tasks (status|id|notes)
in-progress|C078|ArtifactSandbox CSP revoke
in-progress|W012|ExecutionViewer blue pulse
pending|C081|CollabCanvas YS token integration
pending|P101|Bulk create projects from template
pending|B015|Recurring Calendar shared engine
pending|A030|WeekDay keyboard reschedule
pending|E050|Snooze modal recurring rules
// Additional pending tasks (Apr 2026)
pending|P099|dnd-kit core lock verification (no migration)
pending|P100|LiteLLM upgrade to >=1.83.7 + cosign
pending|P101|Orval upgrade to >=8.2.0
pending|P102|Y-Sweet self-host migration runbook
pending|P103|PowerSync offline sync architecture (Phase 2 primary)
pending|P104|Claude 4.6 model migration before June 15, 2026
pending|P105|AI Gateway model fallback using Vercel AI SDK v6
pending|P106|Tremor charting integration Budget/Dashboard
pending|P107|Resend email fallback integration
pending|P108|Tauri capability audit CI
pending|P109|Desktop app update channel spec
pending|P110|MCP SDK security audit (OX Apr15 disclosure); implement MCPSec L2
pending|P111|Nylas grant.expired webhook + proactive re-auth flow
pending|P112|Verify Edge Function DB usage → reroute to Serverless/FastAPI
pending|P113|TypeScript 6.0 production upgrade (config audit)
pending|P114|TypeScript 7.0 (tsgo) CI evaluation & ESLint impact
pending|P115|OpenAI Responses API migration (deadline Aug26)
pending|P116|React 20 Compiler-default compatibility (RHF/Zustand carveouts)
pending|P117|Temporal polyfill integration + Safari gate
pending|P118|pgvectorscale adoption threshold lowered to 500K vectors
pending|P119|OWASP Agentic Top10 (ASI 2026) compliance mapping
pending|P120|ES2026 match expression evaluation
// Spec/XCT tasks (all pending unless noted)
XCT_001|in-progress|motion spec: transform/opacity,reduced motion,stagger≤3
XCT_002|optimistic-ui: React19 useOptimistic,pending styling,5s undo
XCT_003|realtime-streaming: SSE Last-Event-ID,hb,SB channel auth
FLOWC_001|workflow SM visualizer+transition guard
APIC_001|OAI3.1→OR codegen pipeline
APIC_002|SC CI gate+drift detection
EVNT_003|NY v3 webhook: upsert-first+10s ack+async queue+IC
OPSR_001|incident creation+severity routing+SOC2 log
FFLG_001|flag stage progression+dwell validation
FFLG_002|kill switch: <5min revert
COST_001|multi-level budget enforcement: org/team/user/model+15/5/0%
MIGR_001|EBC migration orchestrator+6-step ZDT rename
OBSS_001|SLO dashboard: TTFT,avail,EB,BR
OBSS_002|OTel1.39 GenAI+root span via DataPrepper
SECM_001|Security Control Matrix: S1-S21 control mapping+evidence
SECM_002|MCP security gateway: OAuth+schema allowlist+elicitation
SECM_003|SSRF prevention middleware: allowlist+DNS+IMDSv2
PASS_001|passkey enrollment: SB Auth MFA+QR+recovery codes
GRDL_001|AI guardrails: input/output/runtime 3-layer+audit
PRIV_001|privacy AI: allow_training+segregation+diff privacy
STKB_001|ST token billing: @stripe/ai-sdk/@stripe/token-meter+30% markup
COMP_001|compliance-as-code: VT pipeline+SOC2 TSC mapping
YJS_001|Yjs lifecycle: GC+undo trunc+snapshot+50MB limit
NYLS_001|NY v3 webhook: upsert-first+10s+Sync Policy+burst
CRDB_001|offline-first: tombstone+ULID+IC+outbox replay
RLMT_001|RT chan/mem monitoring: 100/20 limit,40MB alert
RCLL_001|recurrence: @martinhipp/rrule+DST+3 edit modes+DST test matrix

#PRIORITY
P0|Orval upgrade to >=8.2.0|LiteLLM cosign verification|Y-Sweet self-host|MCP SDK audit (MCPSec L2)|MCP Inspector firewall|Nylas grant.expired webhook|Edge Function DB reroute
P1|React Compiler carveout enforcement|PowerSync offline eval|Claude 4.6 migration|AI Gateway fallback|Passkey enrollment (P1 now)|pgvectorscale threshold 500K|TypeScript 6.0 upgrade|React 20 Compiler eval|OpenAI Responses migration audit|OWASP ASI 2026 mapping|Temporal polyfill|ES2026 match eval
P2|A2A acceleration|GraphRAG spec|Contextual Retrieval cost model|Temporal recurrence eval|Resend integration|TypeScript 7.0 CI eval|Prisma Next horizon

#ADR_KEY
// Unique architectural decisions (rule-restatements omitted; see #RULES)
ADR_001|Vite SPA over Next.js
ADR_002|Prisma schema+migrations,SB runtime
ADR_003|Zustand v5
ADR_004|LiteLLM proxy
ADR_005|Y-Sweet+Yjs
ADR_006|LiveKit
ADR_007|Edge Functions for webhooks
ADR_008|markmap for MindMapEditor
ADR_011|FastAPI JWT bridge
ADR_012|Embeddings backend only
ADR_014|rbc ^1.19.4 React19 compat
ADR_016|react-helmet-async for meta tags
ADR_017|DP≥3.4,transitive CI audit
ADR_018|dnd-kit core lock+centralized façade
ADR_019|LK Agents v1 pin
ADR_020|YS token endpoint+CSP integration
ADR_021|style-src-attr unsafe-inline for animation
ADR_022|Monaco sandbox with separate CSP
ADR_023|Custom access token hook for RBAC+org switch
ADR_024|Agent sharing and versioning
ADR_025|GenUI trusted component catalog
ADR_027|CA WASM→corrected to clamd server-side(Rule UPSC_01)
ADR_028|Agent evals CI gate
ADR_030|Hybrid Retrieval RRF+Cross-Encoder rerank
ADR_031|Agent Card Registry+A2A Discovery
ADR_032|Saga Compensation Pattern(workflows)
ADR_033|PB RLS Automated Testing
ADR_034|React Compiler Enablement(babel plugin globally)
ADR_035|AI Peer for Yjs Collab
ADR_036|Contextual Retrieval(Phase2)
ADR_054|Spec Template Standard(yaml+9 sections+tiered governance)
ADR_058|OAI3.1 single source of truth(FastAPI→OR→TS+hooks+MSW+SC CI gate)
ADR_062|Feature Flag progressive rollout+kill switch(<5min,OpenFeature)
ADR_063|Multi-Level AI Cost Governance(org/team/user/model,LLM middleware,TS forecasting)
ADR_064|EBC ZDT Migrations(6-step rename,CONCURRENTLY indexes,Prisma drift CI)
ADR_065|SLO-Driven Observability+EB(TTFT≤2s p95,99.9%,BR alerts 2%/1h,OTel1.39)
ADR_067|MCP Security Model(OWASP MCP Top10,MS AGT,OAuth auth,schema allowlist,elicitation)
ADR_076|Yjs Lifecycle(GC on,undo last5,snapshot VH,50MB limit)
ADR_077|NY v3 Webhook(upsert-first,10s timeout,async queue,Sync Policy,burst)
ADR_079|Offline-First Tombstone(deleted_at nullable int ms,ULID,IC,outbox replay)
ADR_082|Recurrence DST(@martinhipp/rrule FE,rrule Python BE,TZID,3 modes,DST test matrix)
// Additional ADRs (Apr 2026)
ADR_083|Y-Sweet self-host mandatory (Jamsocket shutdown)
ADR_084|PowerSync as primary offline sync (vs Zero, cr-sqlite unmaintained)
ADR_085|dnd-kit remains primary DnD library; NO migration to PragmaticDnD
ADR_086|Vercel AI SDK v6 for streaming, tool calling, AI Gateway
ADR_087|Tremor charts for Tailwind-native dashboards (active, Vercel-acquired)
ADR_088|Resend as transactional email fallback
ADR_089|No Haiku in agentic deployments
ADR_090|MCP Inspector dev network isolation (CVE-2025-49596)
ADR_091|LiteLLM cosign verification post supply chain attack
ADR_092|Orval >=8.2.0 (CVE-2026-24132, CVE-2026-23947, CVE-2026-25141)
ADR_093|Claude 4.6 model IDs (hard migrate by June 15, 2026)
ADR_094|React Compiler carveout: RHF "use no memo"; Zustand persist no Suspense; Zustand core exempt
ADR_095|Temporal API polyfill mandatory until Safari native
ADR_096|MCPSec L2 mandatory for all MCP servers (IETF draft + OWASP MCP Top10)
ADR_097|React 20 adoption timeline (Q2 eval, Q3 migration)
ADR_098|TypeScript 7.0 Go-native readiness (tsgo CI, tooling impact)
ADR_099|Vercel Serverless (not Edge) for DB-dependent webhooks
ADR_100|Nylas grant.expired proactive re-auth (<72h)
ADR_101|OWASP Agentic Top 10 (ASI 2026) compliance mapping for guardrails
ADR_102|Prisma Next evaluation (Phase 3, Postgres GA July 2026+)
ADR_103|OpenAI Responses API migration path (deadline Aug 26, 2026)
ADR_104|pgvectorscale threshold reduction (500K vectors)
ADR_105|Tremor v3.18.x actively maintained; charting standard

EOF