---
steering: TO PARSE - READ INTRO
file_name: 02-ARCH-EXTERNAL.md
document_type: external_services
tier: infrastructure
status: stable
owner: Platform Engineering
description: Third-party service integrations with security and performance patterns
integration_count: 12
last_updated: 2026-04-25
version: 1.0
dependencies: [01-PLAN-LEXICON.md, 02-ARCH-OVERVIEW.md]
related_adrs: [ADR_004, ADR_005, ADR_006, ADR_007, ADR_017, ADR_019, ADR_020, ADR_027, ADR_035, ADR_058, ADR_063, ADR_067, ADR_076, ADR_077, ADR_083, ADR_084, ADR_086, ADR_087, ADR_088, ADR_089, ADR_090, ADR_091, ADR_092, ADR_093, ADR_094, ADR_095, ADR_096, ADR_097, ADR_098, ADR_099, ADR_100]
related_rules: [LITELLM_PIN, ORVAL_PIN, MCP_INSPECTOR_DEVSEC, Y_SWEET_SELFHOST, NO_CRSQLITE, NO_REPLICACHE, MCP_SDK_AUDIT, GRANT_EXPIRED_WEBHOOK, EDGE_NO_DB, OPENAI_RESPONSES_MIGRATE, TRIVYISOLATION, GRYPEREPLACE]
complexity: high
risk_level: critical
---

# EXT - External Service Integrations

// External Service Integrations (Updated Apr 2026)
Nylas|OAuth2,FastAPI proxy,webhook→Serverless(no Edge DB),upsert-first,10s timeout,async queue,idempotency via nylas_processed_events,grant.expired webhook→re-auth<72h; daily cron for expiring grants; DLQ after 3 retries; LWW via uat
Resend|Primary transactional email; React Email 5.0; 3k/mo free tier; inbound via Svix; email.complained→unsubscribed:true
LiveKit|token /v1/livekit/token,TTL6h,conference agent,RBAC scoped,AgentSession
AI_Providers|LLM proxy via LiteLLM>=1.83.7 (cosign),Vercel AI SDK v6 gateway fallback,Claude 4.6 default,no Haiku agentic; OpenAI Responses API migration by Aug26; Responses+Conversations; server-side compaction,hosted shell
YSweet|Self-host (Jamsocket shutdown); GC enabled,undo trunc last5,snapshot,50MB limit; offlineSupport provider
Storage|org buckets,StorageService,CA server-side(clamd v1.4.x),freshclam hourly,health check in /health,no scan result caching by hash; pyclamd integration,chunked upload,S3 versioning
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
Grype|Docker image vulnerability scanning (replaces Trivy); isolated from CI credential store; pin to SHA digest
OWASP|OWASP MCP Top10; OWASP Agentic Top10 (ASI 2026); ASI01-ASI10 mapping required
Ollama|Local model serving (≥0.5.0), OpenAI-compatible API, native tool calling. 52M+ monthly downloads. Docker Compose integration
llama.cpp|Backend inference engine (100K GitHub stars). GGUF quantization, CPU-optimized, speculative decoding. Used as Ollama's backend
Unsloth|Fine-tuning framework (53.9K GitHub stars). 2× faster, 70% less VRAM. QLoRA adapters. Phase 2
MLX‑LM|Apple Silicon fine-tuning (MLX framework). Local training on M2+ Macs. Phase 2
LoFT CLI|CPU-only fine-tuning for 1‑3B models, GGUF export. Phase 2
ModelCascade|Reference cascade router (MIT). Three‑tier: LOCAL→FAST→CAPABLE. 74% local handling, $3/night operating cost
Bifrost|Model gateway for multi‑model serving. Evaluated for Phase 2
Prima.cpp|Distributed inference (ICLR 2026). 30‑70B models on home clusters. Phase 3+
Mesh LLM|GPU capacity pooling, OpenAI-compatible API. Phase 3+
