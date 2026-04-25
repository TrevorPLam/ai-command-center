---
id: arch.backend-arch
title: BACKEND_ARCH
type: architecture
status: draft
version: 1.0.0
compressed: |
JWT Bridge: verify JWKS from Supabase(cached 1h);SET LOCAL request.jwt.claims embeds org_id and user_role;custom access token hook adds org_id,user_role;roles:admin,manager,member,viewer,external;401 triggers refreshSession→retry
Error Envelope: {error:{code,message,retryAfter}}; codes:RATE_LIMITED(Rate limit exceeded),AUTH_EXPIRED(Token expired),VALIDATION_ERROR(Input validation failed),AI_PROVIDER_ERROR(AI provider failure),STORAGE_ERROR(Storage operation failed),NYLAS_ERROR(Nylas API error)
Rate Limiting: FastAPI-Limiter+Upstash Redis,per-user and per-org limits,429 response includes retry-after header,frontend handles via [RL] pattern(toast+backoff)
CORS: Allow-list localhost:8000,production domain,Credentials true,Methods GET,POST,PUT,DELETE,PATCH,OPTIONS,Headers Authorization,Content-Type
Health Check: GET /health→{status:"ok",version,db:"connected",redis:"connected",litellm:"connected"}
SSRF Protection: MCP tool execution validates URLs against allow-list;block private IP ranges(10.0.0.0/8,172.16.0.0/12,192.168.0.0/16);block localhost and file:// protocols;DNS rebinding protection
last_updated: 2026-04-24T23:22:41.113489+00:00
---

# BACKEND_ARCH

JWT Bridge: verify JWKS from Supabase(cached 1h);SET LOCAL request.jwt.claims embeds org_id and user_role;custom access token hook adds org_id,user_role;roles:admin,manager,member,viewer,external;401 triggers refreshSession→retry
Error Envelope: {error:{code,message,retryAfter}}; codes:RATE_LIMITED(Rate limit exceeded),AUTH_EXPIRED(Token expired),VALIDATION_ERROR(Input validation failed),AI_PROVIDER_ERROR(AI provider failure),STORAGE_ERROR(Storage operation failed),NYLAS_ERROR(Nylas API error)
Rate Limiting: FastAPI-Limiter+Upstash Redis,per-user and per-org limits,429 response includes retry-after header,frontend handles via [RL] pattern(toast+backoff)
CORS: Allow-list localhost:8000,production domain,Credentials true,Methods GET,POST,PUT,DELETE,PATCH,OPTIONS,Headers Authorization,Content-Type
Health Check: GET /health→{status:"ok",version,db:"connected",redis:"connected",litellm:"connected"}
SSRF Protection: MCP tool execution validates URLs against allow-list;block private IP ranges(10.0.0.0/8,172.16.0.0/12,192.168.0.0/16);block localhost and file:// protocols;DNS rebinding protection
