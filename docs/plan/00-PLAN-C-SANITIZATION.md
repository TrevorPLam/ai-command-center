---
steering: TO PARSE - READ INTRO
document_type: sanitization_spec
tier: security
description: DOMPurify profiles, ClamAV, Zod sanitisation, SSRF+XSS test matrix
last_updated: 2026-04-25
version: 1.0
---

#San
DOMPurify|≥3.4.0; SanitizedHTML component with profile prop:
  STRICT: no svg, no style, minimal tags
  RICH: div, span, strong, em, ul/li, no svg
  EMAIL: a, img, p, br; force rel=noopener
ClamAV|v1.4.x sidecar, freshclam hourly; health check on /health; no scan caching
Zod|URL params validated with Zod schemas; output sanitised
MCP SSRF|middleware blocks all private IPs; allowlist validation; no redirects
Test|XSS payload matrix (10 cases) in TESTC04; CSP violation checks
