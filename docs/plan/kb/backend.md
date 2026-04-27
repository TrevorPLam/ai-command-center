---
title: "Backend Infrastructure"
owner: "Backend Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

JWT bridge with JWKS 1h cache, FastAPI rate limiting with Upstash Redis, CORS allowlist, health endpoint, SSRF blocking, DOMPurify sanitization ≥3.4.

## Key Facts

### JWT Bridge

**JWT_BRIDGE**: JWKS with 1h cache

- SET LOCAL claims: org_id + user_role
- custom_access_token_hook for RBAC

### Error Handling

**ERR_ENV**: Standardized error format

- Structure: {error: {code, message, retryAfter}}

### Rate Limiting

**RATE**: FastAPI-Limiter + Upstash Redis

- Per-user/org rate limiting
- 429 status with retry-after header

### CORS

**CORS**: Allowlist configuration

- Allowlist: localhost:8000, production
- Credentials: true

### Health Endpoint

**HEALTH**: GET /health endpoint

- Returns: {status, version, db, redis, litellm}

### SSRF Protection

**SSRF**: Server-Side Request Forgery blocking

- Blocked ranges: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 127.0.0.0/8, 169.254.0.0/16
- No redirects allowed
- IMDSv2 required

### DOMPurify

**DOMPURIFY**: HTML sanitization

- Version: ≥3.4
- Output: SanitizedHTML
- ALLOWED_TAGS whitelist
- FORBID: script, style, iframe, object, embed, svg, math
- SANITIZE_DOM: true

## Why It Matters

- JWKS caching reduces external API calls and improves performance
- Rate limiting prevents abuse and ensures fair resource allocation
- CORS allowlist restricts cross-origin access to trusted domains
- SSRF blocking prevents internal network scanning
- DOMPurify prevents XSS attacks via user-generated HTML

## Sources

- FastAPI documentation
- Upstash Redis documentation
- OWASP SSRF prevention guide
- DOMPurify documentation
