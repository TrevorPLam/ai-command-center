---
steering: TO PARSE - READ INTRO
document_type: external_services
tier: infrastructure
description: Third-party service integrations with security and performance patterns
integration_count: 12
last_updated: 2026-04-25
version: 1.0
---

# EXT - External Service Integrations

// External Service Integrations (Updated Apr 2026)
Nylas|OAuth2,FastAPI proxy,webhook→EdgeFn,upsert-first,10s timeout,async queue,Sync Policy,burst auto-scale; grant.expired webhook mandatory,re-auth<72h
Resend|Fallback for transactional; React Email 5.0 templates; 3k/mo free tier; inbound webhooks via Svix (3-day retention)
LiveKit|token /v1/livekit/token,TTL6h,conference agent,RBAC scoped,AgentSession
AI_Providers|LLM proxy via LiteLLM>=1.83.7 (cosign),Vercel AI SDK v6 gateway fallback,Claude 4.6 default,no Haiku agentic; OpenAI Responses API migration by Aug26; Responses+Conversations; server-side compaction,hosted shell
YSweet|Self-host (Jamsocket shutdown); GC enabled,undo trunc last5,snapshot,50MB limit; offlineSupport provider
Storage|org buckets,StorageService,CA server-side(clamd>=1.5.2),chunked upload,S3 versioning
Search|Phase1 pg_trgm,Phase2 pgvector HNSW+RRF(k=60)+cross-encoder rerank,Phase3 Typesense,RAG; pgvectorscale 0.4.0 DiskANN for >500K vectors
DOMPurify|≥3.4.0,whitelist,FORBID script/style/iframe/object/embed,SVG_INLINE off; CVE-2025-15599,CVE-2026-0540,CVE-2026-41238,CVE-2026-41240,CVE-2025-25141 addressed
Stripe|metered billing via @stripe/ai-sdk and @stripe/agent-toolkit,30% markup,ai_cost_log→meters,reconcile job; dual-track LiteLLM + Vercel Gateway metering
Vanta/Oneleet|continuous SOC2 evidence,GH Actions pipeline,quarterly refresh
OTel|v1.40.0+ GenAI (experimental); DataPrepper root span prop,PII redact at collector; OTEL_SEMCONV_STABILITY_OPT_IN; Sentry,PostHog
PowerSync|Primary offline sync Phase 2; bidirectional SQLite/Postgres,SOC2/HIPAA; YAML sync rules
Tremor|Tailwind-native charts,35+ components,Apache2.0; actively maintained (Vercel-acquired)
VercelAI|ai v6: AI Gateway,streaming,tool calling,structured output,OpenTelemetry; @ai-sdk/react v2
Temporal|ES2026 API; @rrulenet/recurrence candidate Phase 2; Safari polyfill mandatory
MCP_Security|MCPSec L2 (Agent Passports, per-message signing); OWASP MCP Top10 audit; continuous SDK monitoring; OX April15 disclosure mandatory fix
OpenAI|Responses API + Conversations; migrate from Assistants/ChatCompletions by Aug26,2026
Prisma_Next|TypeScript-native ORM,Postgres GA June-July 2026; pgvector extension; Phase 3 evaluation
Edge_Functions|Vercel Edge no DB connections; use Serverless (300s) or Neon driver for DB tasks; Nylas webhooks→FastAPI or Vercel Serverless, not Edge
TypeScript|6.0 prod (erasableSyntaxOnly, isolatedDeclarations strict); 7.0 beta (tsgo 10x)
React|React20 GA March 2026, Compiler default; manual memoization deprecated; "use no memo" escape hatch
OWASP|OWASP MCP Top10; OWASP Agentic Top10 (ASI 2026); ASI01-ASI10 mapping required
