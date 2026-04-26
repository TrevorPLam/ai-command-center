---
steering: TO PARSE - READ INTRO
file_name: 02-ARCH-OVERVIEW.md
document_type: architecture_specification
tier: strategic
status: stable
owner: Platform Engineering
description: C4 architecture diagrams, deployment maps, data flow visualizations
last_updated: 2026-04-25
version: 1.0
dependencies: [01-PLAN-LEXICON.md, 02-ARCH-DATABASE.md, 02-ARCH-ENDPOINTS.md, 02-ARCH-EXTERNAL.md]
related_adrs: [ADR_001, ADR_002, ADR_003, ADR_004, ADR_005, ADR_006, ADR_007, ADR_008, ADR_011, ADR_012, ADR_014, ADR_016, ADR_017, ADR_018, ADR_019, ADR_020, ADR_021, ADR_022, ADR_023, ADR_024, ADR_025, ADR_027, ADR_028, ADR_030, ADR_031, ADR_032, ADR_033, ADR_034, ADR_035, ADR_036, ADR_054, ADR_058, ADR_062, ADR_063, ADR_064, ADR_065, ADR_067, ADR_076, ADR_077, ADR_079, ADR_082, ADR_083, ADR_084, ADR_085, ADR_086, ADR_087, ADR_088, ADR_089, ADR_090, ADR_091, ADR_092, ADR_093, ADR_094, ADR_095, ADR_096, ADR_097, ADR_098, ADR_099, ADR_100]
related_rules: [L1, L2, L3, L4, L5, L6, L7, L8, L9, L10, L11, L12]
complexity: high
risk_level: critical
---

# ARCH - Architecture

#C4|level|diagram|description
C1|Context|System Context|Users,Browser,Mobile,External APIs,LLM Providers,Stripe,Nylas,Supabase
C2|Container|Web App|Vite SPA,FastAPI Backend,Supabase DB,TimescaleDB,Redis,LiveKit
C3|Component|Frontend|Shell,Dashboard,Chat,Projects,Calendar,Settings,Agent Studio
C4|Code|Service|AI Gateway,MCP Security,Guardrails,Auth Service,Cost Tracker,Sync Engine

#DEPLOY|env|provider|service|config|scaling
PROD|Fly.io|FastAPI|Machines v2,Python 3.12,2 shared-cpu-1x HA,auto-scale 1-10|Zero-downtime rolling
PROD|Vercel|Web App|Vite SPA,Edge Functions,CDN,Edge Middleware|Global CDN
PROD|Supabase|Database|Postgres 15,RLS,pgBouncer,PgBouncer=true|Managed HA
PROD|Supabase|Realtime|WebSockets,100ch/conn,self 20,40MB alert|Auto-scale
PROD|TimescaleDB|Time-Series|Continuous aggregates,materialized_only=false|Managed
PROD|Upstash|Redis|Rate limiting,semantic cache,session store|Managed
PROD|LiveKit|RTC|STT/LLM/TTS pipeline,WebRTC,turn detection|Managed
PROD|HashiCorp Vault|Secrets|JWT 90d,Stripe 180d,MCP OAuth 90d,LLM keys 30d|Managed
PROD|Doppler|Env Vars|Per environment,dev/staging/prod,GH Actions integration|Managed
STAGING|Fly.io|FastAPI|1 shared-cpu-1x,no auto-scale|Manual
STAGING|Vercel|Web App|Preview deployments,branch-based|Automatic
STAGING|Supabase|Database|Separate project,RLS test data|Managed
DEV|Local|All|Docker Compose,local Supabase,Mock LLM|N/A

#DATAFLOW|source|destination|protocol|security|notes
Browser|FastAPI|HTTPS|JWT auth,org_id claim|/v1/* endpoints
FastAPI|Supabase|TCP|Internal network,RLS enforced|Prisma client
FastAPI|LiteLLM|HTTPS|API key rotation,cosign verified|Claude/GPT/Gemini routing
FastAPI|MCP Server|HTTP|MCPSec L2,OAuth tool auth|SSRF allowlist,nonce replay
FastAPI|Stripe|HTTPS|API key 180d rotation|@stripe/ai-sdk metering
FastAPI|Nylas|HTTPS|OAuth2,grant.expired webhook|Upsert-first,10s ack
FastAPI|LiveKit|WebSocket|Token TTL 6h,RBAC scoped|STT/LLM/TTS pipeline
Supabase|Browser|WebSocket|JWT auth,org:{orgId}:{table}|Realtime CDC
FastAPI|TimescaleDB|TCP|Internal network|ai_cost_log hypertable
FastAPI|Upstash|Redis|TLS|Rate limiting,semantic cache
FastAPI|Sentry|HTTPS|DSN env var|Error tracking,session replays
FastAPI|PostHog|HTTPS|API key|Product analytics,allow_training flag
FastAPI|OTel Collector|HTTPS|OTLP|GenAI traces,PII redaction at collector

#SECURITY|layer|control|mechanism|test|owner|evidence
L1|Network|VPC isolation|Fly.io private network,Supabase peer|Port scan|Platform|Network diagram
L2|Application|CSP headers|Nonce strategy,strict-dynamic,worker-src|CSP Report-Only|Security|CSP policy doc
L3|API|Rate limiting|FastAPI-Limiter,Upstash Redis,per-user/org|Load test 1000 req/s|Platform|Rate limit logs
L4|Auth|JWT validation|Custom access token hook,org_id claim,90d rotation|Token expiry test|Security|Auth audit logs
L5|Data|RLS policies|Row Level Security,org_id required,role-based|pgTAP 33 test cases|Data|pg_prove output
L6|Supply Chain|Package pinning|LiteLLM≥1.83.7 cosign,Orval≥8.2.0,DOMPurify≥3.4.0|Schemathesis CVE scan|Security|CI gate logs
L7|MCP|MCPSec L2|Agent Passports ECDSA P-256,signed envelopes,nonce replay|OWASP MCP Top10 audit|AI|MCPSec test suite
L8|AI|Guardrails|Input PII/jailbreak/tox,Output halluc/safety/schema,Runtime tool auth|DeepEval test suite|AI|Guardrail audit logs
L9|Secrets|Vault rotation|JWT 90d,Stripe 180d,MCP OAuth 90d,LLM keys 30d|Rotation script test|Platform|Vault audit trail
L10|Compliance|SOC2|VT evidence pipeline,quarterly refresh,TSC mapping|Vanta audit|GRC|SOC2 report
L11|Privacy|GDPR|allow_training flag,data segregation,diff privacy,PIA quarterly|Data deletion test|GRC|PIA document
L12|Audit|WORM logs|Immutable audit_logs table,hash chaining,forensic analysis|Log integrity check|Security|Audit trail export

#INFRA|component|provider|sla|backup|dr|monitoring
FastAPI|Fly.io|99.9%|Daily pg_dump,Hourly WAL|Region failover|Sentry+Loki
Web App|Vercel|99.9%|Git versioning|Global CDN|Vercel Analytics
Supabase DB|Supabase|99.9%|Point-in-time recovery,7-day retention|Cross-region replica|Supabase Dashboard
TimescaleDB|Supabase|99.9%|Continuous aggregates backup|Read replica|Supabase Dashboard
Redis|Upstash|99.9%|Persistence enabled,AOF|Multi-AZ|Upstash Dashboard
LiveKit|LiveKit|99.9%|Recording retention|Region failover|LiveKit Dashboard
Vault|HashiCorp|99.9%|Auto-unseal,RAID storage|Disaster recovery|Vault UI
Doppler|Doppler|99.9%|Secret versioning|Geo-redundant|Doppler Dashboard

#INTEGRATION|service|protocol|auth|rate_limit|retry|timeout|circuit_breaker
LiteLLM|HTTP|API key|100 req/min|Exponential backoff 3x|30s|Open after 5 failures
Nylas|HTTP|OAuth2|100 req/min|Linear backoff 1s|10s|Open after 3 failures
Stripe|HTTP|API key|100 req/min|Exponential backoff 2x|30s|Open after 5 failures
LiveKit|WebSocket|Token TTL 6h|N/A|N/A|N/A|N/A
Supabase Realtime|WebSocket|JWT|100 ch/conn|Reconnect 1s,2s,4s,8s,max30s|N/A|N/A
Upstash Redis|TCP|TLS|10000 ops/sec|N/A|5s|Open after 10 failures
OTel Collector|HTTPS|OTLP|N/A|Exponential backoff 2x|10s|Open after 3 failures
Sentry|HTTPS|DSN|N/A|N/A|5s|Open after 5 failures
PostHog|HTTPS|API key|1000 events/min|Linear backoff 500ms|10s|Open after 3 failures

#SCALING|service|metric|threshold|scale_up|scale_down|max|min
FastAPI|CPU|70%|Add 1 VM|Remove 1 VM|10|1
FastAPI|Memory|80%|Add 1 VM|Remove 1 VM|10|1
Supabase DB|Connections|80%|Read replica|N/A|N/A|N/A
Supabase Realtime|Channels|100ch/conn|Add capacity|N/A|N/A|N/A
Upstash Redis|Memory|70%|Scale cluster|N/A|N/A|N/A
LiveKit|Participants|1000|Add SFU|Remove SFU|N/A|N/A

#HA|component|strategy|rto|rpo|test_frequency
FastAPI|Multi-region active-passive|5min|0|Monthly
Supabase DB|Cross-region replica|1h|0|Quarterly
TimescaleDB|Continuous aggregates backup|1h|15min|Monthly
Redis|Multi-AZ with persistence|1min|0|Monthly
Vault|Raft cluster with auto-unseal|5min|0|Quarterly
Doppler|Geo-redundant storage|1min|0|Monthly

// Infrastructure additions (Apr 2026)
PowerSync|Managed (SOC2/HIPAA)|YAML sync rules, per-org bucket|Phase 2
Y-Sweet|Docker self-host (Fly.io private network only)|OFFLINE support provider; 50MB limit
Grype|CI Docker scanner|Replaces Trivy, isolated from CI creds
LangGraph|AI orchestration|Supervisor/Swarm; LangMem; OTel gen_ai traces
FastGraphRAG|RAG augmentation|NLP entities, direct production; graph DB future
Vanta|SOC2 automation|Evidence pipeline, TSC mapping
