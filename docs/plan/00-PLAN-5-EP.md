---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-5-EP.md
document_type: api_endpoints
tier: infrastructure
status: stable
owner: Platform Engineering
description: FastAPI endpoint specifications with security and performance patterns
endpoint_count: 49
last_updated: 2026-04-25
version: 1.0
dependencies: [00-PLAN-1-INTRO.md, 00-PLAN-4-TBL.md, 00-PLAN-8-ARCH.md]
related_adrs: [ADR_011]
related_rules: [S9, S14, S15]
complexity: medium
risk_level: high
---

# EP - API Endpoints

POST /v1/livekit/token|scoped TTL6h
GET  /v1/collab/token|YS org check
GET  /v1/search|pg_trgm+tsvector+vector
POST /v1/email/send|NY via FastAPI
POST /v1/mcp/execute|SSRF protection
GET  /v1/user/export|GDPR SSE JSON
POST /v1/workflow/execute|topo sort,parallel
GET  /v1/workflow/status|pending/running/waiting/completed
POST /v1/workflow/cancel|-
POST /v1/workflow/compensate|admin trigger
DELETE /v1/organizations|cascade delete
POST /v1/import/entity|SSE progress
CRUD /v1/agent/definitions|-
POST /v1/agent/eval|returns scores
GET  /v1/agent/cost|per org
GET  /v1/agent-card/{agentId}|A2A discovery
POST /v1/collab/ai-peer|AI peer (internal)
GET  /v1/cost-forecast|per-org projected cost
POST /v1/rerank|{query,docs}→reranked
GET  /v1/realtime/channels|-
// Spec/XCT/Ops endpoints
POST /v1/spec/validate|yaml frontmatter+sections+tier
POST /v1/xct/auth/org-switch|invalidate caches,reconnect RT,redirect
GET  /v1/flowc/workflow/{id}/states|SM+transitions
POST /v1/apic/codegen|OR codegen→generated files
GET  /v1/apic/drift-check|SC drift vs impl
POST /v1/evnt/webhook/nylas|upsert-first+IC dedup+async queue
POST /v1/testc/security/run|PB RLS,CSP,DP,SSRF,LK tokens
POST /v1/testc/ai-eval/run|acc/lat/tok/tool/halluc thresholds
POST /v1/opsr/incident|P0-P3+roles+SOC2 log
POST /v1/fflg/flag/{id}/kill|<5min revert to 0%
GET  /v1/cost/forecast|{projected,CI,trend,action}
POST /v1/migr/expand-contract|ZDT migration step
GET  /v1/obs/slo/dashboard|TTFT,avail,EB,BR
GET  /v1/secm/control-matrix|S1-S21→controls+evidence
POST /v1/secm/mcp/gateway|OAuth+schema allowlist+elicitation
POST /v1/pass/enroll|SB Auth MFA+QR+recovery
POST /v1/grdl/input/check|PII/jailbreak/tox
POST /v1/grdl/output/check|halluc/safety/schema
POST /v1/grdl/runtime/enforce|tool auth/cost threshold
POST /v1/ssrf/validate|allowlist+DNS+IMDSv2
POST /v1/priv/opt-out|allow_training flag+segregation+diff privacy
POST /v1/stkb/meter|ST token billing recording
POST /v1/yjs/lifecycle/manage|GC,undo,snapshot
POST /v1/nyls/webhook/config|upsert-first,async,Sync Policy
POST /v1/rcll/recurrence/expand|RFC5545+DST+edit modes
