---
steering: TO PARSE - READ INTRO
file_name: 05-XCT-SANITIZATION.md
document_type: sanitization_spec
tier: security
status: stable
owner: Security / GRC
description: DOMPurify profiles, ClamAV, Zod sanitisation, SSRF+XSS test matrix
last_updated: 2026-04-25
version: 1.0
dependencies: [01-PLAN-LEXICON.md, 09-REF-KNOWLEDGE.md]
related_adrs: [ADR_017, ADR_027]
related_rules: [S10, S16, SECM_03, UPSC_01]
complexity: high
risk_level: critical
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
