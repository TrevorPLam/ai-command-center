---
steering: TO PARSE - READ INTRO
document_type: knowledge_base
tier: infrastructure
description: Core infrastructure patterns and architectural knowledge
last_updated: 2026-04-25
version: 1.0
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
