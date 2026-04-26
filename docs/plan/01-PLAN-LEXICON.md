---
file_name: 01-PLAN-LEXICON.md
steering: TO PARSE - READ INTRO
document_type: lexicon
tier: planning
status: stable
owner: Product Engineering
description: Lexicon, rules, versions, and milestones
last_updated: 2026-04-25
version: 4.0
dependencies: []
related_adrs: []
related_rules: []
complexity: low
risk_level: low
---

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
D|DRS=rschedule+@rschedule/temporal-date-adapter(replaces rrule.js FE)
D|DFG=FastGraphRAG(NLP entity extraction,10% cost)
D|DLG=LangGraph(Supervisor/Swarm/LangMem/Trustcall)
D|DDE=DeepEval(Pytest-native AI eval)
D|DSW=SimpleWebAuthn(MIT passkeys)
D|DGR=Grype(replaces Trivy scanning)
D|DPH=PostHog Group Analytics
D|DVF=Vercel Flags SDK(OpenFeature adapter)
D|DMB=Multi-burn-rate(1h+5m P0,6h P1,3d P2)
D|DDP3=DOMPurify profile(STRICT|RICH|EMAIL)
D|DCTXR=Contextual Retrieval(50K chunk threshold)
D|DSEK=Secret rotation log table(SOC2 audit)
D|DRGI=RAG index stats & performance logging
D|DSCH=Schemathesis contract testing gate
D|DPMC=MCP security gateway+SMCP L2
D|DNHS=OWASP Non-Human Identity management
D|DOCL=OKLCH token system+DSTOKEN hard rule enforcement
D|DPSY=PowerSync YAML rules per org+offline-first sync

#DICT
G1|85/35|±2% G2|80/30|±5% G3|82/32|±2% G4|80/40|±2% G5|90/45|±2%
G6|85/45|±2% G7|95/40|±2% G8|90/40|±2%
// Qual presets: temp/topP/~/~/~/~/guard|variance

#C Components

Components have been extracted into module-specific files for token optimization:

## Core Modules
- **Shell**: 04-COMP-SHELL.md (11 components)
- **Dashboard**: 04-COMP-DASHBOARD.md (8 components)  
- **Chat**: 04-COMP-CHAT.md (22 components)
- **Workflow**: 04-COMP-WORKFLOW.md (8 components)
- **Projects**: 04-COMP-PROJECTS.md (24 components)

## Feature Modules
- **Calendar**: 04-COMP-CALENDAR.md (11 components)
- **Email**: 04-COMP-EMAIL.md (12 components)
- **Contacts**: 04-COMP-CONTACTS.md (11 components)
- **Conference**: 04-COMP-CONFERENCE.md (7 components)
- **Translation**: 04-COMP-TRANSLATION.md (6 components)
- **News**: 04-COMP-NEWS.md (6 components)
- **Documents**: 04-COMP-DOCUMENTS.md (9 components)
- **Research**: 04-COMP-RESEARCH.md (6 components)
- **Media**: 04-COMP-MEDIA.md (6 components)
- **Budget**: 04-COMP-BUDGET.md (7 components)
- **Settings**: 04-COMP-SETTINGS.md (12 components)
- **Platform**: 04-COMP-PLATFORM.md (11 components)

## Cross-Cutting Services
- **XCT Services**: 05-XCT-SERVICES.md (17 components)

## Dependencies Analysis
See **05-XCT-DEPENDENCIES.md** for comprehensive cross-component dependency analysis and optimization opportunities.

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
// Additional HARD rules (Apr 2026 PART 4)
RRULEBAN|arch|H|rrule.js banned on FE; use rschedule+Temporal adapter
CLAUDEMIGRATION|ai|H|New agents after May 1 use claude-sonnet-4-6 or opus-4-7 only. Legacy IDs clean by June 1
TRIVYISOLATION|sec|H|Security scanners never have write access to CI credential store; pin scanners to SHA
GRYPEREPLACE|sec|H|Replace Trivy with Grype for Docker scanning in all CI jobs
AUTHHOOK|sec|H|supabase_auth_admin granted SELECT on userroles,orgmembers,rolepermissions; pgTAP verified
TSERASABLE|arch|H|tsc --erasableSyntaxOnly --noEmit CI gate; ban TypeScript enum
SENTRY01|sec|H|Four Sentry projects with beforeSend PII strip hook; maskAllText:true on Session Replay
DSNOKEYUI|ui|H|No hardcoded hex/RGB colours; reference OKLCH CSS custom properties only
MONACOLAZY|arch|H|Monaco never in initial bundle; React.lazy+Suspense+skeleton mandatory
APIC003|arch|H|Schemathesis CI gate on main; schema validation gate on PR
GRDL03|ai|H|All pgvector-retrieved chunks pass through GRDL input layer before context injection
NUQSBATCH|ui|H|>3 URL params must use useQueryStates, not multiple useQueryState
DNDOVERLAY|arch|H|All drag operations use DragOverlay; never drag original DOM node
COST03|arch|H|Budget enforcement synchronous pre-call (not post-call)
COMP03|comp|H|Every HARD security rule has corresponding Vanta test within 30 days
TESTC04b|sec|H|Any new table without pgTAP test file blocks merge
TESTC07|arch|H|MSW handlers generated from OAI3.1 spec via openapi-backend
FLYPRIVATE|ops|H|Y-Sweet token endpoint unreachable from public internet; private networking only
EVALCOST|ai|H|DeepEval LLM-as-judge calls routed through LiteLLM proxy
SECREC01|ops|H|Automated secret rotation failure → P1 incident; logged as SOC2 evidence
FFLG03|arch|H|Every flag must have explicit owner,defaultBehavior,reviewdate
ZUSTANDCIRCULAR|arch|H|Slices cannot import other slice files; cross-slice access via get() only
POWERSYNC01|data|H|PowerSync bucket YAML per orgId; sync rules scoped to JWT orgId claim
CONTEXTUALRETRIEVAL|ai|H|Activate Contextual Retrieval only when corpus >50K chunks AND precision>15% AND cache hit>60%
FASTGRAPHRAG|ai|H|Start FastGraphRAG (10% cost). LLM-based GraphRAG requires feature flag at 500K chunks
MULTIBURN|obs|H|Multi-burn-rate SLO: 1h+5m P0 page,6h P1,3d P2; burn>14.4→EB100% incident
OTEL02|obs|H|OTel GenAI conventions mandatory for all agents; OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai
SANITIZEDHTML|ui|H|All user-generated HTML passes SanitizedHTML component with profile(STRICT|RICH|EMAIL)
RESEND01|ops|H|Resend primary transactional email; email.complained→unsubscribed:true
SECRETROTATE|ops|H|Every secret must have rotation schedule in secretrotationlog; dynamic DB credentials per deploy
PQC2027|sec|H|Inventory long-lived keys+data for post-quantum readiness; hybrid classical+ML-KEM plan by 2027
AIBOM04|comp|H|AIBOM (CycloneDX) per model in CI; include training data provenance and safety evaluations
// S22-S28 explicit mapping (PART 11)
S22|sec|H|GRDL03: RAG content validation (pgvector chunks through GRDL input layer)
S23|sec|H|SECREC01: secret rotation failure→P1 incident; all rotations logged SOC2 evidence
S24|sec|H|GRYPEREPLACE: Grype not Trivy; scanners isolated from CI credentials
S25|sec|H|AUTHHOOK01: supabase_auth_admin SELECT grants verified by pgTAP after migration
S26|sec|H|SENTRY01: PII strip beforeSend; maskAllText:true Session Replay; four projects
S27|sec|H|CLAMAVPROD: v1.4.x sidecar; health check; freshclam hourly; no scan result caching
S28|sec|H|DPPROFILES: three DOMPurify profiles; no svg in STRICT/RICH; XSS test matrix
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
OTEL_01|obs|H|OTel1.40: gen_ai.system,model,usage.input_tokens,output_tokens,finish_reason,cost.usd
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
OBSS_03|obs|M|OTel1.40 GenAI; root span via DataPrepper; PII redact at collector
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
// MED rules (PART 4 subset - integrate with existing MED section)
OBSS04|obs|M|Multi-window burn rate:1h+5m P0 page;6h P1;3d P2
OBSS05|obs|M|SemanticCacheHitRate target≥70% chat,≥90% RAG; alert on breach
AUTHHOOK01|arch|M|Org switch triggers supabase.auth.refreshSession()+RT client clear
NYLASREAUTH|ops|M|grant.expired P1 incident;72h expiry grace; immediate revocation
RAGINDEXSTRAT|arch|M|<500K:HNSW m16 efc200;≥500K:DiskANN;hybrid:BM25+DiskANN RRF k60 cross-encoder
COMPILERAUDIT|arch|M|Q2 2026 Compiler audit; bundle size delta ≤5%
TEMPORALZDT|arch|M|Always use Temporal.ZonedDateTime not PlainDateTime for calendar events
PINCATALOG|arch|M|Security-pinned deps HARD-pinned; weekly pnpm audit
CTXRETRIEVAL|arch|M|Activate Contextual Retrieval when corpus >50K chunks/org tracked in ragindexstats
GRAPHRAG|arch|M|FastGraphRAG first; LLM-based gated at 500K chunks feature flag
FLYSCALE01|ops|M|WorkflowEngine scales 0→3 via fly-autoscaler on queue_depth >5
EXPOPINSDK|arch|M|Decision May 15,2026:SDK55 if before July;SDK56 after July
RESEND01-M|arch|M|Resend primary email; email.complained→unsubscribed:true
LANGGRAPH01|arch|M|LangGraph Supervisor maps to FLOWC01 SM;LangMem for cross-session summarisation

#VER
// id|ver|notes
TS|6.0prod  React|19.2.5→20.0 eval Q2  Vite|8.0.0  Zustand|5.0.12
TanStackQuery|5.100.1  Motion|12.38.0|import from motion/react
TailwindCSS|4.2.2  Prisma|7.8.0|pgbouncer=true
dndkit|6.3.1|community standard; NO migration to PragmaticDnD
Node|24.15.0LTS Krypton  Python|3.12  FastAPI|0.136.1
rbc|^1.19.4React19  yjs|13.6.21  dompurify|≥3.4.0  nuqs|^2.5
reacthelmet|latest  livekitagents|>=2.0.0 ONLY
livekitserversdk|>=1.0.0  markmap|latest  reactresizable|^3.1.3
QueryClient|staleTime5min,retry2,noRefocus,429→RL,useSSE
// New entries
ai|^6.0  @ai-sdk/react|^2.0  @tremor/react|^3.18
@stripe/ai-sdk|latest  @stripe/agent-toolkit|latest
@powersync/web|latest  litellm|>=1.83.7 cosign+Grype not Trivy
orval|>=8.2.0  @anthropic/mcp-inspector|>=0.14.1 (devDep)
tsgo|7.0beta  temporal-polyfill|^0.3.2 ~20KB (Safari gap)
pgvectorscale|0.4.0 (DiskANN)  @xyflow/react|12.10.2
OTel|v1.40.0+experimental  prisma-next|GA June-July 2026 (Postgres)
// Additional new entries (Apr 2026)
rschedule|latest @rschedule/temporal-date-adapter
SimpleWebAuthn|latest
deepeval|latest
ragas|>=0.2
openapi-backend|latest
pg_textsearch|latest
basejump-supabase_test_helpers|latest
pyclamd|latest

// See 01-PLAN-ZUSTAND.md for Zustand slice configurations
// See 02-ARCH-DATABASE.md for database table schemas
// See 02-ARCH-ENDPOINTS.md for API endpoints  
// See 02-ARCH-EXTERNAL.md for external service integrations
// See 02-ARCH-FLOWS.md for critical user flows

#ROUTE
login|authlogin|authsignup|authcallback|authreset|authverify
dashboard|chat|chat/:thread(hoverPrefetch)|workflows|workflow/:id
projects|project/:id|triage|calendar|email|contacts
conference|translation|news|documents|research|media|budget
settings|settings/:section|analytics|auditlog
agentstudio|agentstudio/:agent|agentplayground

#KV
See **09-REF-KNOWLEDGE.md** for comprehensive infrastructure patterns and architectural knowledge.

#RUNBOOKS
See **08-OPS-RUNBOOKS.md** for operational procedures and incident response playbooks.

#TEST
See **07-TEST-STRATEGY.md** for comprehensive testing strategy and coverage targets.

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
Chunk_temporal_polyfill|20KB  Chunk_es2026_shim|5KB  EdgeFn_MaxCPU|50ms
// Additional bundle budgets (Apr 2026 PART 10)
Chunk_rschedule|15KB
Chunk_simplewebauthn|12KB (lazy, auth routes only)
Chunk_deepeval|0KB (CI/server-side)
Chunk_posthog|19KB (shared, feature flagged)
// Offline cache budget
Offline_Storage|50MB IndexedDB per org
Stripe_Markup|30%  Compliance_Refresh|quarterly  OTel_Version|1.39.0
Upload_CA_Version|≥1.4.x freshclam hourly  RBAC_Target|100% HARD rule→control  MCP_OAuth_Target|≥90%

#MIL+TSK
// Revised Milestones for Phased Delivery

## Phase 0: Foundation + Single App (current)
- Auth / org creation
- Dashboard shell with notification list
- Calendar app (manual events)
- Basic Chat with MCP tool calling
- All data scoped to org_id with RLS

### Core tasks for Phase 0
in-progress|F001|Full-stack plumbing: Vite→FastAPI→Supabase (RLS verified)
pending|F002|Calendar month view with event CRUD
pending|F003|Chat page with agent tool use (create/modify calendar events)
pending|F004|Dashboard notification feed (static/polling)
pending|F005|Deploy on Fly.io + Vercel
pending|F006b|Ollama+llama.cpp integration: local serving stack,Docker Compose,OpenAI-compatible API proxy
pending|F006c|Download,quantize,register default local model(Gemma 4 E2B or Qwen3.5 4B). Model registry initial population
pending|F006d|Local model tool-calling verification: ensure default local model passes >90% of tool-calling test suite
pending|F011b|Intent Dispatcher local routing policy: route all free-tier agent calls to local models by default

## Phase 1: Conflict Agent MVP (next)
- Project board app (tasks, due dates)
- Conflict detection agent (calendar + projects)
- Dashboard notification with action buttons
- Stripe billing
- External calendar sync (read-only)
- Intent Dispatcher v1

### Core tasks for Phase 1
pending|C001|Project board with tasks
pending|C002|Conflict rule engine (deterministic overlap check)
pending|C003|Agent orchestration: detect conflict → notify → execute action
pending|C004|Chat integration: ask agent to find/resolve conflicts
pending|C005|Stripe subscription and metering
pending|C006|Google Calendar / Outlook read-only integration
pending|P116b|Verifier cascade: deploy Phi-4-mini-reasoning as local verifier; checks reasoning,schema,permission,cost
pending|P116c|Model capability registry: automated benchmarking of all registered models,tool-calling scores,latency profiles
pending|P116d|Loop controller(SLM-6 pattern): circuit breaker on orchestrator loops,configurable max iterations
pending|P116e|Model update and deprecation policy: version freeze,smooth migration,user notification schedule
pending|P210b|Fine-tuning pipeline: Unsloth/LoFT CLI for domain-specific local models; user-specific LoRA adapters(Phase 2 scope)

## Phase 2: Email + Proactive (future)
pending|E001|Nylas email integration
pending|E002|Auto-trigger conflict detection on incoming reschedule email
pending|E003|Configurable agent proactivity per plan

## Phase 3+: Full Suite Expansion (future)
// The original milestones (Workflows, Projects, Calendar, etc.) are preserved as future targets.

// Existing #LEX, #DICT, #C, #RULES, #VER, #ROUTE, #KV, #RUNBOOKS, #TEST, #BUDG sections remain unchanged.
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
// Additional pending tasks P121-P155 (Apr 2026 PART 6 + Addendum)
pending|P121|rschedule migration+DST test cases
pending|P122|temporal-polyfill 0.3.2,bundle budget 20KB
pending|P123|AUTHHOOK pgTAP assertion(supabase_auth_admin grants)
pending|P124|SimpleWebAuthn passkeys; webauthn_challenges table
pending|P125|LangGraph Supervisor FLOWC01; LangMem crossSessionSummaries
pending|P126|pg_textsearch BM25; replace pgtrgm hybrid leg
pending|P127|React Compiler audit,bundle delta≤5%
pending|P128|LiveKit v2.0 only; VoicePipelineAgent v2 API
pending|P129|Four Sentry projects, PII strip, Session Replay, PostHog connect
pending|P130|Schemathesis CI PR+main jobs (@APIC002)
pending|P131|DeepEval adoption, RAGAS alongside
pending|P132|Vanta connect GH/Supabase/Vercel/Doppler/Fly; SOC2 Type I Q4
pending|P133|PostHog event taxonomy+Group Analytics
pending|P134|SLO multi-burn-rate(1h+5m,6h,3d); TTFT histogram
pending|P135|Upstash dynamic rate limits per plan+ cacheBlock audit
pending|P136|ClamAV v1.4.x sidecar; freshclam hourly; health check
pending|P137|SanitizedHTML component+3 profiles; XSS test cases
pending|P138|Zustand persistence versioning+migrate(); ESLint ZUSTANDCIRCULAR
pending|P139|OpenFeature+PostHog provider using Vercel Flags SDK
pending|P140|MSW openapi-backend codegen; 429 mock factory; SSE mock pattern
pending|P141|PowerSync bucket YAML per orgId, document 3-user free tier
pending|P142|Schemathesis ignore file for SSE+WS endpoints
pending|P143|Grype replace Trivy in CI; pin to SHA; isolate CI creds
pending|P144|Monaco spec: per-surface lang config; CSP sandbox; OKLCH theme
pending|P145|GraphRAG tables graphentities, graphrelationships stubs; migration path ADR106
pending|P146|Contextual Retrieval ragindexstats; 50K threshold; Phase1.5 eval Q1'27
pending|P147|Turborepo CI inputs(exclude *.test.ts), AI eval no cache; base=main
pending|P148|pnpm catalog tiers(default,react,python); security-pinned HARD; dependabot patch-only
pending|P149|Fly.io topology: Machine sizes, autostop, private net, autoscaler rule
pending|P150|Secret rotation: secretrotationlog table; Vault dynamic DB creds per deploy
pending|P151|React Router v7: library mode, no @react-router/dev, useViewTransitionState
pending|P152|nuqs canonical parsers; ESLint rule for >3 params→useQueryStates
pending|P153|pgTAP: PII tables first+supaShield auto-gen; pnpm test:rls task
pending|P154|Chat: canvas CSP per artifact; staleTime:Infinity AI gen; SSE ReadableStream consumer; VVirtualizeList
pending|P155|CI pipeline: full job matrix(typecheck,tsgo,lint,test:*,drift,codegen,build)
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
OBSS_002|OTel1.40 GenAI+root span via DataPrepper
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
ADR_065|SLO-Driven Observability+EB(TTFT≤2s p95,99.9%,BR alerts 2%/1h,OTel1.40)
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
// New ADRs (Apr 2026 PART 7)
ADR106|FastGraphRAG first; LLM-based gated at 500K chunk feature flag
ADR107|SimpleWebAuthn for passkeys; webauthn_challenges RPC pattern
ADR108|DeepEval as AI eval framework; RAGAS alongside for RAG
ADR109|rschedule+@rschedule/temporal-date-adapter replaces rrule.js FE
ADR110|OpenFeature with Vercel Flags SDK+PostHog provider
ADR111|Grype replaces Trivy for Docker scanning; no scanners with CI cred write access
ADR112|DOMPurify three profiles(STRICT/RICH/EMAIL) with SanitizedHTML component
ADR113|LangGraph Supervisor for FLOWC01 SM; LangMem for cross-session FIFO; Trustcall extraction
ADR114|Four Sentry projects; PII strip beforeSend; replaysOnErrorSampleRate:1.0
ADR115|LiveKit Agents v2.0 only; semantic turn detection mandatory
ADR116|pg_textsearch BM25 replaces pgtrgm in hybrid search
ADR117|ClamAV v1.4.x sidecar; freshclam hourly; health check integration
ADR118|Contextual Retrieval Phase 1.5 evaluation at 50K chunk threshold
ADR119|Vanta as SOC2 automation platform; Type I target Q4 2026
ADR120|Upstash dynamic rate limits for plan-tiers; semantic cache threshold 0.92
ADR121|Multi-burn-rate SLO alerting:1h+5m P0,6h P1,3d P2
ADR122|PowerSync confirmed primary offline sync; ElectricSQL documented as alternative
ADR123|Playwright AI Agents(Planner/Generator/Healer) in CI; cost via LiteLLM proxy
ADR124|Tailwind v4 OKLCH three-layer token system; HARD DSTOKEN rule
ADR125|Four-layer cost governance: synchronous pre-call budget check
ADR126|PostHog Group Analytics mandatory from day one for org-scoped events
// Updates (PART 7)
UPDATE ADR082|rschedule replaces rrule.js; Python dateutil unchanged; ZonedDateTime mandatory
UPDATE ADR088|Resend promoted from fallback to primary transactional email provider
UPDATE ADR019|LiveKit Agents v2.0 only; remove v1.0 reference
UPDATE ADR036|Contextual Retrieval cost model updated; Sonnet 4.6; 50K chunk threshold

EOF