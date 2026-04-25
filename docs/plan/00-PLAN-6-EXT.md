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

Nylas|OAuth2,FastAPI proxy,webhook→EdgeFn,upsert-first,10s timeout,async queue,Sync Policy,burst auto-scale
LiveKit|token /v1/livekit/token,TTL6h,conference agent,RBAC scoped
AI_Providers|LLM proxy,circuit breaker,fallback gpt-4o→claude,cost attribution x-litellm-tags
YSweet|collab token /v1/collab/token,Yjs,GC enabled,undo trunc last5,snapshot,50MB limit
Storage|org buckets,StorageService,CA server-side,chunked upload,S3 versioning
Search|Phase1 pg_trgm,Phase2 pgvector HNSW+RRF(k=60)+cross-encoder rerank,Phase3 Typesense,RAG
DOMPurify|≥3.4,whitelist,FORBID script/style/iframe/object/embed,SVG_INLINE off
Stripe|metered billing/@stripe/ai-sdk/@stripe/token-meter,30% markup,ai_cost_log→meters,reconcile job
Vanta/Oneleet|continuous SOC2 evidence,GH Actions pipeline,quarterly refresh
OTel|v1.39.0 GenAI,DataPrepper root span prop,PII redact at collector,Sentry,PostHog
