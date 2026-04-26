---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-C-KNOWLEDGE.md
document_type: knowledge_base
tier: infrastructure
status: stable
owner: Platform Engineering
description: Core infrastructure patterns and architectural knowledge
last_updated: 2026-04-25
version: 1.0
dependencies: [00-PLAN-1-INTRO.md]
related_adrs: [ADR_001, ADR_002, ADR_003, ADR_004, ADR_005, ADR_006, ADR_007, ADR_011, ADR_012, ADR_014, ADR_016, ADR_017, ADR_018, ADR_019, ADR_020, ADR_021, ADR_022, ADR_023, ADR_024, ADR_025, ADR_027, ADR_028, ADR_030, ADR_031, ADR_032, ADR_033, ADR_034, ADR_035, ADR_036, ADR_054, ADR_058, ADR_062, ADR_063, ADR_064, ADR_065, ADR_067, ADR_076, ADR_077, ADR_079, ADR_082, ADR_083, ADR_084, ADR_085, ADR_086, ADR_087, ADR_088, ADR_089, ADR_090, ADR_091, ADR_092, ADR_093, ADR_094, ADR_095, ADR_096, ADR_097, ADR_098, ADR_099, ADR_100]
related_rules: [S1-S21, GRDL_01, GRDL_02, PRIV_01, STKB_01, YJS_01, NYLS_01, OTEL_01, OTEL_02]
complexity: high
risk_level: critical
---

# KV - Knowledge Base

// BACKEND
JWT_BRIDGE=JWKS 1h cache; SET LOCAL claims org_id+user_role; custom_access_token_hook for RBAC
ERR_ENV={error:{code,message,retryAfter}}
RATE=FastAPI-Limiter+Upstash Redis,per-user/org,429 retry-after
CORS=allow-list localhost:8000,prod; credentials true
HEALTH=GET /health→{status,version,db,redis,litellm}
SSRF=block 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,127.0.0.0/8,169.254.0.0/16; no redirects; IMDSv2
DOMPURIFY=≥3.4,SanitizedHTML,ALLOWED_TAGS whitelist,FORBID script/style/iframe/object/embed/svg/math,SANITIZE_DOM true

// SECURITY
Encryption|SB AES-256 at rest; PII encrypted at app layer(Vault keys); JWT signed+verified; httpOnly cookie
RBAC|user_roles+role_permissions; 5-role(Owner/Admin/Member/Viewer/External); authorize() fn; JWT hook
AuditLog|immutable append-only audit_logs; Prisma middleware+CDC; queryable admin; MCP/guardrail/privacy logged
Pentesting|annual Bugcrowd; quarterly SAST/DAST(Snyk,ZAP) in CI; MCP CVE scan(CVE-2025-49596,66416)
GDPR|cascade-delete pipeline+audit; anonymize logs; SSE progress export; training opt-out per CNIL
SOC2|VT continuous; aim TypeII 12mo; HARD rule→SOC2 TSC→evidence artifact mapping
RLS|ENABLE+FORCE RLS,org_id via JWT; PB automated; drift detection blocks deploys
MCPG|zero-trust: OAuth tool auth,schema allowlist,elicitation high-risk,policy eval deterministic,SSRF,sandbox,CI TrustKit
Passkeys|SB Auth MFA; cross-device QR; platform sync(iCloud/Google); recovery codes; phishing-resistant

// AI
MemArch|3-tier: Working(Zustand),Episodic(messages+pgvector,FIFO50,Ebbinghaus decay),Semantic(pgvector+facts,promotion)
EvalCI|Vitest+custom; gate: acc≥base-2%,lat≤base+10%,tok≤base+15%,tool≥90%,halluc≤2%
CtxWindow|LLM token counter+@CACHE; prefix caching static-first; RocketKV long contexts
SafetyGuard|Guardrails-AI+Pydantic; 3-layer: Input(PII/jailbreak/tox),Output(halluc/safety/schema),Runtime(tool/cost); all logged
CostAttrib|x-litellm-tags: org_id,user_id,feature; ai_cost_log TS hypertable; 15/5/0% alerts; 429 hard stop
PromptCache|Anthropic cache_control+OAI auto-prefix; monitor hit>70%chat/>90%RAG; static-first structure
Observability|OTel1.39 GenAI; DataPrepper root span prop; attrs: gen_ai.system/model/input_tokens/output_tokens/finish_reason/cost.usd; PII redact
Privacy|allow_training org flag; data segregation opted-out; ODP differential privacy(ε configurable); TEE for sensitive; annual PIA

// DATA
Redis|Upstash; rate limiting; semantic cache AI; hot settings; prefix caching; flag cohorts; IC storage
TimeSeries|TS hypertables: transactions,ai_cost_log,slo_metrics; continuous aggregates; cost forecast
ObjectStorage|SB Storage+S3 versioning; weekly sync; PITR manual sync; Yjs snapshot storage
VectorSearch|pgvector HNSW(m=16,ef_c=200,ef_s=40),pg_trgm,hybrid RRF(k=60)+cross-encoder rerank; RLS at DB
OfflineStore|IndexedDB outbox; tombstone(deleted_at nullable int ms); ULID; IC=actor_id+monotonic; LWW via uat
RealtimeChannels|SB Broadcast(ephemeral,256KB-3MB) vs PgChanges(durable WAL,1MB); org:{orgId}:{table}; mem alert@40MB; 100ch platform,20 self

// INFRA
Terraform|Vercel,Fly.io,SB,Upstash; state TF Cloud; PITR mgmt; SOC2 evidence pipeline
Docker|supabase start+FastAPI,Redis,minio; hot-reload; MCP sandbox; CA clamd daemon
Secrets|Doppler/Vault; no .env in images; JWT keys+ST keys+MCP OAuth secrets in Vault
ObsStack|Sentry,PostHog,OTel; Fly.io→Loki; metrics: AI tokens,cache hit,SLO BR; OTel1.39 GenAI
CI|GH Actions,pnpm,turbo; affected-only; remote cache; SC; PB RLS; AI eval gate
PrismaMig|EBC; migrate deploy prod; drift check CI; RLS versioning; 6-step ZDT rename

// BACKEND CORE
FastAPI_Proj|app/main.py,routers/v1/*,services/*,dependencies.py,middleware/*; A2A,Saga,RAG,Cost,MCP,SSRF,Privacy
ServiceRepo|Route→Service→Repository(Prisma); DI FastAPI deps; compensation queue+DLQ; webhook async queue
WorkflowEngine|topo sort,SM; parallel,exp backoff,compensation,ICs; DLQ after 3 retries
RAG|LangChain,pgvector,EdgeFns; ingest→chunk(512tok,64overlap)→embed→HNSW→hybrid RRF→rerank→cache; RLS at DB
A2A|google-A2A; Agent Card discovery,task SM,SSE streaming,artifact handling; Agent Registry
MCP|policy eval(allow/deny/approve); OAuth auth; schema allowlist; elicitation; SSRF; sandbox; CI TrustKit; audit

// CLIENT
Tauri|v2; GH Actions build; Mac signing+notarization; auto-update tauri-plugin-updater; Capabilities per window; dep chain audit(Rust+npm)
Expo|SDK53/54; EAS Build; OTA critical-fixes only; native secrets EAS; CI on tag; expo-notifications dev build req Android; deep link matrix
DesignSystem|Tailwind v4 @theme; OKLCH tokens; 4px grid; motion tokens; useShouldAnimate; EmptyState required; skeleton<2s,spinner>2s
A11y|WCAG2.2 AA; contrast checks; reduced motion; kbd nav(Tab/Enter/Escape/Arrows all interactive); canvas alt; aria-live

// REPO
Monorepo|pnpm catalogs,Turborepo; strict: packages/ui no import from features; spec validation CI gate
Codegen|OR openapi-codegen,SB gen types; pnpm codegen→packages/types/api+database; MSW; SC tests
QueryClient|staleTime5min,retry2,noRefocus,429→RL,useSSE

// OPS
IncidentComm|Better Stack,PagerDuty; auto status page on health fail; on-call escalation
FeedbackLoop|thumbs on AI→eval_datasets; automated sampling
Billing|ST webhook(verified HMAC); idempotency processed_stripe_events; handle invoice.paid,subscription.updated; ST Portal; MeteredAI via ai_cost_log; LicenseGate 402+CTA

// Additional Knowledge (Apr 2026)
// Y-SWEET SELF-HOST
Y_SWEET_SELFHOST|Jamsocket shut March 2026; Y-Sweet must be self-hosted (Docker); offlineSupport provider; S3 persistence; monitor fork activity
// OFFLINE STRATEGY
OFFLINE_SYNC|MVP: tombstone+ULID+IC outbox; Phase 2: PowerSync bidirectional (SQLite/Postgres), SOC2/HIPAA, sync rules YAML; cr-sqlite unmaintained, Replicache maintenance mode
// DND STATUS
DND_STATUS|dnd-kit is community standard (18.9M/mo); PragmaticDnD is Atlassian-internal (~180K/wk); NO migration between them
// REACT COMPILER CAVEATS
COMPILER_CAVEATS|RHF: "use no memo" directive required; Zustand persist: conditional rendering not Suspense; Zustand core: compatible
// AI GATEWAY
AI_GATEWAY|Vercel AI SDK v6: provider routing, fallback chains, tool calling, structured output, streaming; wraps LiteLLM proxy; separate cost tracking
// MODEL TIERING
MODEL_TIERING|Default: claude-sonnet-4-6-20250324; Complex: claude-opus-4-6-20250324; Never agentic: claude-haiku-4-5 (no injection guard); Migrate before June 15, 2026
// LITELLM SECURITY
LITELLM_SEC|Supply chain attack March 24,2026 (v1.82.7-1.82.8), TeamPCP; pin >=1.83.7 with cosign SHA verification; CVE-2026-35029 (RCE), CVE-2026-35030 (auth bypass)
// ORVAL SECURITY
ORVAL_SEC|CVE-2026-24132,CVE-2026-23947,CVE-2026-25141 (JSFuck bypass) CVSS9.8; upgrade >=8.2.0; never run on untrusted OAS; reject patterns []()!+;
// MCP INSPECTOR SEC
MCP_INSPECTOR_SEC|CVE-2025-49596 CVSS9.4; pin devDep >=0.14.1; firewall dev network access
// MCP SECURITY CRISIS
MCP_SEC_CRISIS|April15,2026 OX Security disclosure: 7K exposed servers, 150M+ downloads, 10 CVEs; MCPSec L2 mandatory for prod
// MCPSec
MCPSEC|IETF draft: Agent Passports (ECDSA P-256), per-message signing, tool definition integrity, nonce+timestamp replay protection, trust levels L0-L4; backward-compatible envelope; median latency 8.3ms; reduces attack success 52.8%→12.4%
// OPENAI RESPONSES
OPENAI_RESPONSES|Assistants API + Chat Completions deprecated Aug26,2026; Responses API: server-side context compaction, hosted shell containers (Python/Node/Ruby with storage), reusable Skills, agentic execution loop; Vercel AI SDK v6 gateway support
// Nylas grant.expired
NYLAS_GRANT_EXP|When grant expires, all webhooks stop. Re-auth <72h → backfill; >72h → permanent data loss. Handle grant.expired webhook immediately.
// VERCEL EDGE
VERCEL_EDGE_NO_DB|Edge Functions run V8 isolates, no Node.js runtime, no direct TCP DB connections. Use Neon serverless driver (HTTP), Vercel Serverless (300s), or FastAPI proxy.
// REACT 20
REACT20|GA March 2026. Compiler built-in default, no opt-in. useMemo/useCallback/React.memo deprecated. "use no memo" still needed for RHF, Zustand persist. Concurrent Rendering 2.0
// TYPESCRIPT CASCADE
TYPESCRIPT_67|TS6.0 (March 23,2026): final JS release; erasableSyntaxOnly, isolatedDeclarations, strict defaults. TS7.0 Beta (April 2026): Go-native (tsgo) ~10x faster; CI-ready now.
// PRISMA NEXT
PRISMA_NEXT|TypeScript-native ORM, Postgres GA June-July 2026, schema in TS, pgvector extension, 12-month Prisma7 LTS; Phase 3 evaluation.
// OWASP AGENTIC
OWASP_ASI2026|Agentic Top10: ASI01 Goal Hijack, ASI02 Tool Misuse, ASI03 Identity Abuse, etc. Map to GRDL layers, SECM controls.
// PGVECTORSCALE
PGVECTORSCALE|0.4.0 DiskANN; 50M vectors: 471 QPS, 28ms p95, 11.4x Qdrant, 28x Pinecone latency, 75% cheaper. Threshold reduced to 500K vectors.
// ES2026
ES2026_MATCH|match expression (declarative pattern matching), using keyword (resource cleanup), Promise.try, Error.isError, Math.sumPrecise, Uint8Array base64/hex, Iterator helpers.
// TEMPORAL
TEMPORAL_SAFARI|Stage4 ES2026 (March 2026), Chrome144+, Firefox139+, Safari not yet. Polyfill mandatory (temporal-polyfill). Conditional import. Bundle impact 8KB.
// A2A V1
A2A_V1|Google Agent-to-Agent v1.0, Linux Foundation, 150+ organizations production. Stable .proto, three-layer architecture.
// DOMPURIFY CVES
DOMPURIFY_CVES|>=3.4.0 mitigates: CVE-2025-15599, CVE-2026-0540, CVE-2026-41238, CVE-2026-41240, CVE-2025-25141
// PRISMA SAVEPOINTS
PRISMA_SAVEPOINT|v7.8.0+ nested transaction savepoints; Saga rollback via savepoint release
// REACT ROUTER V7
RRV7|Imports from react-router (merged); nuqs adapter v7; library mode; no react-router-dom
// REACT FLOW V12
RF12|@xyflow/react import; node.measured replaces node.width/height for layout (dagre/elk)
// EXPO SDK55
EXPO55|New Architecture mandatory; expo-av removed; notifications config plugin required; Reanimated v4 incompatible with NativeWind→pin v3
// TAURI V2
TAURI_V2|v2.7.0 stable; capability audit CI; delta updates roadmap only; mobile for internal tools
// TEMPORAL API
TEMPORAL_API|ES2026; @rrulenet/recurrence candidate; Phase 2 evaluation
// CLAUDE 4.6
CLAUDE46|claude-sonnet-4-6-20250324 default; claude-opus-4-6-20250324 complex; claude-haiku-4-5 retired Apr 19 2026; no agentic Haiku
// Supabase Edge Functions
SB_EF|Deno runtime; npm: prefix; pre-bundled; cold start ~100ms; use for webhooks+async
// OTel GenAI details
OTEL_GENAI|v1.40.0 experimental (Feb 2026); gen_ai.* namespace; use OTEL_SEMCONV_STABILITY_OPT_IN; track gen_ai.conversation.id
// Resend inbound
RESEND_INBOUND|Svix delivery; 3-day log retention; React Email 5.0; inbound parse available
// PowerSync architecture
PWRSYNC_ARCH|SQLite client; Postgres server; YAML sync rules; 3 users free tier; SOC2/HIPAA confirmed
// Tauri capability security
TAURI_CAP|Fine-grained capability per window; XSS containment; CI manifest validation
// Tremor maintenance status
TREMOR_STATUS|Actively maintained by Tremor Labs (Vercel-acquired); v3.18.x stable; v4 preview; ~27K GitHub stars; safe ADR
// Additional KV (Apr 2026)
RRULE_DST_BUG|rrule.js TZID-parameterized DTSTART RFC5545 non-compliant; DST shifts 1h. Replace: FE→rschedule+@rschedule/temporal-date-adapter; BE unchanged.
REACT_COMPILER_STABLE|Includes existing useMemo/useCallback; skips some modules. Use eslint-plugin-react-compiler. Audit Q2'26.
PASSKEYS_SUPABASE_GAP|Supabase Auth lacks native WebAuthn. Use SimpleWebAuthn+RPC; table webauthn_challenges.
Nylas_Webhook_BestPractices|Async processing (ack<10s), idempotency via nylas_processed_events, DLQ after 3 retries, grant.expired handling (refresh attempt, 72h backfill window), daily cron for expiring grants. See runbook.
Resend_Primary|Resend is now primary transactional email. Handle email.complained→unsubscribed:true. Svix inbound webhooks.
LangGraph_Supervisor|Maps FLOWC01 SM; LangMem crossSessionSummaries; Trustcall for extraction.
FastGraphRAG|NLP-based, 10% cost; production first. LLM-based GraphRAG via feature flag at 500K chunks.
SanitizedHTML_Profiles|Three DOMPurify profiles: STRICT(no svg), RICH(allowed div/span), EMAIL(link+img). Component prop driven.
PowerSync_Bucket|YAML rules per orgId (JWT claim); 3 users free tier; conflict resolution LWW.
Temporal_ZD_Required|Always Temporal.ZonedDateTime for calendar events; never PlainDateTime.
