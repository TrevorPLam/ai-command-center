---
id: arch.backend-endpoints
title: Backend Endpoints
type: architecture
last_updated: '2026-04-25T01:34:38.871734+00:00'
---

# Backend Endpoints

## Endpoints

[['Method', 'Endpoint', 'Purpose', 'Notes'], ['POST', '/v1/livekit/token', 'LiveKit token', 'scoped, TTL 6h'], ['GET', '/v1/collab/token', 'Y-Sweet token for collab docs', 'org membership check'], ['GET', '/v1/search', 'Global search', 'pg_trgm+tsvector → vector'], ['POST', '/v1/email/send', 'Send email via Nylas', 'through FastAPI'], ['POST', '/v1/mcp/execute', 'Execute MCP tool', 'SSRF protection'], ['GET', '/v1/user/export', 'GDPR export (SSE, JSON)', 'ISO8601'], ['POST', '/v1/workflow/execute', 'Trigger workflow', 'topo sort, parallel'], ['GET', '/v1/workflow/:id/status', 'Workflow status', 'pending/running/waiting/completed'], ['POST', '/v1/workflow/:id/cancel', 'Cancel workflow', ''], ['DELETE', '/v1/organizations/:id', 'Cascade delete', 'Storage, docs, audit'], ['POST', '/v1/import/:entity', 'Bulk import', 'SSE progress'], ['GET/POST', '/v1/agent/definitions', 'CRUD agent definitions', ''], ['POST', '/v1/agent/eval', 'Run agent evals', 'returns scores'], ['GET', '/v1/agent/cost', 'Agent cost usage', 'per org'], ['GET', '/v1/realtime/channels', 'List active Realtime channels', '']]

## Architecture Details
| Aspect | Details |
|--------|----------|
| JWT Bridge | Verify JWKS from Supabase (cached 1h); `SET LOCAL request.jwt.claims` embeds org_id and user_role |
| Error Envelope | `{ error: { code, message, retryAfter } }` |
| Rate Limiting | FastAPI‑Limiter + Upstash Redis, per‑user/org, 429 with retry‑after |
| CORS | Allow‑list: localhost:8000, production domain; credentials true |
| Health Check | GET /health → `{ status:"ok", version, db:"connected", redis:"connected", litellm:"connected" }` |
| SSRF Protection | MCP tool execution validates URLs; blocks private IP ranges, localhost, file:// protocols |

## Error Codes
| Code | Meaning | Retry |
|------|---------|-------|
| `RATE_LIMITED` | Rate limit exceeded | Use `retryAfter` header |
| `AUTH_EXPIRED` | Token expired | Refresh token |
| `VALIDATION_ERROR` | Input validation failed | Fix request |
| `AI_PROVIDER_ERROR` | AI provider failure | Circuit breaker |
| `STORAGE_ERROR` | Storage operation failed | Retry with backoff |
| `NYLAS_ERROR` | Nylas API error | Retry with backoff |
