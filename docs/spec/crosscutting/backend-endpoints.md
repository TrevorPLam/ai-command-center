---
id: arch.backend-endpoints
title: Backend Endpoints
type: architecture
status: draft
version: 1.0.0
compressed: |
GET|/v1/workflow/: id/status|Workflow status|pending/running/waiting/completed
POST|/v1/workflow/: id/cancel|Cancel workflow|
DELETE|/v1/organizations/: id|Cascade delete|Storage,docs,audit
POST|/v1/import/: entity|Bulk import|SSE progress
LiteLLM sidecar on litellm: 4000;FastAPI on separate port.
last_updated: '2026-04-24T23:37:09.417534+00:00'
---

# Backend Endpoints

| Method | Endpoint | Purpose | Notes |
|--------|----------|---------|-------|
| POST | /v1/livekit/token | LiveKit token | scoped,TTL6h |
| GET | /v1/collab/token | Y-Sweet token for collab docs | org membership check |
| GET | /v1/search | Global search | pg_trgm+tsvector→vector |
| POST | /v1/email/send | Send email via Nylas | through FastAPI |
| POST | /v1/mcp/execute | Execute MCP tool | SSRF protection |
| GET | /v1/user/export | GDPR export (SSE,JSON) | ISO8601 |
| POST | /v1/workflow/execute | Trigger workflow | topo sort,parallel |
| GET | /v1/workflow/:id/status | Workflow status | pending/running/waiting/completed |
| POST | /v1/workflow/:id/cancel | Cancel workflow |  |
| DELETE | /v1/organizations/:id | Cascade delete | Storage,docs,audit |
| POST | /v1/import/:entity | Bulk import | SSE progress |
| GET/POST | /v1/agent/definitions | CRUD agent definitions |  |
| POST | /v1/agent/eval | Run agent evals | returns scores |
| GET | /v1/agent/cost | Agent cost usage | per org |
| GET | /v1/realtime/channels | List active Realtime channels |  |

