---
id: security.csp
title: Content Security Policy
type: security
last_updated: '2026-04-24T23:37:09.420843+00:00'
---

# Content Security Policy

| Directive | Value |
|-----------|-------|
| default-src | 'self' |
| script-src | 'self' 'nonce-{RANDOM}' 'strict-dynamic' |
| style-src | 'self' |
| style-src-attr | 'unsafe-inline' (required for programmatic transforms) |
| img-src | 'self' blob: data: https://*.supabase.co |
| connect-src | 'self' localhost:8000 https://*.supabase.co wss://*.supabase.co https://api.nylas.com https://<livekit-host> wss://<livekit-host> wss://<y-sweet-host> |
| frame-src | blob: |
| font-src | 'self' |
| object-src | 'none' |
| base-uri | 'self' |
| form-action | 'self' |
| worker-src | blob: |
| child-src | blob: |

