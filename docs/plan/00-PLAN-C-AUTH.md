---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-C-AUTH.md
document_type: auth_specification
tier: infrastructure
status: stable
owner: Security / GRC
description: Authentication flows, passkeys, OAuth, org switch, MFA
last_updated: 2026-04-25
version: 1.0
dependencies: [00-PLAN-1-INTRO.md, 00-PLAN-C-KNOWLEDGE.md]
related_adrs: [ADR_067]
related_rules: [S8, S13, PASS_01, AUTHHOOK01]
complexity: medium
risk_level: critical
---

#Auth
Login|Supabase Auth email/pw; custom_access_token_hook embeds org_id+role
MFA|TOTP (Spectrum); WebAuthn passkeys via SimpleWebAuthn (ADR107)
Passkeys|webauthn_challenges table; RPC flow; cross-device QR; recovery codes
OrgSwitch|supabase.auth.refreshSession()+qclient.clear()+RT reconnect; AUTHHOOK01
NylasAuth|OAuth2 grant; grant.expired→re-auth<72h; daily cron
Security|JWT not in localStorage; all tokens httpOnly; CSRF double-submit
