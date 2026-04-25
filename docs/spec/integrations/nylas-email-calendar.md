---
id: integration.nylas-email-calendar
title: Nylas (Email/Calendar)
type: integration
status: draft
version: 1.0.0
compressed: |
Purpose: Email sync,calendar sync,send email; Auth: OAuth2.0 via Nylas API; Grant Storage: encrypted grant_id in connected_accounts; API Access: all Nylas calls go through FastAPI(S3); Webhooks handled by Edge Functions; Rate Limiting: per-account enforced by FastAPI; Webhooks: Nylas webhooks→Supabase Edge Functions→Supabase Realtime(B3); Error Handling: NYLAS_ERROR with retryAfter
last_updated: 2026-04-24T23:22:41.116697+00:00
---

# Nylas (Email/Calendar)

Purpose: Email sync,calendar sync,send email; Auth: OAuth2.0 via Nylas API; Grant Storage: encrypted grant_id in connected_accounts; API Access: all Nylas calls go through FastAPI(S3); Webhooks handled by Edge Functions; Rate Limiting: per-account enforced by FastAPI; Webhooks: Nylas webhooks→Supabase Edge Functions→Supabase Realtime(B3); Error Handling: NYLAS_ERROR with retryAfter
