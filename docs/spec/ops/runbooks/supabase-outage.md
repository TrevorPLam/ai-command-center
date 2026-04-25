---
id: runbook.supabase-outage
title: Supabase Outage Runbook
type: runbook
last_updated: '2026-04-25T01:34:38.870794+00:00'
---

- Monitor `/health` endpoint.
- If DB unreachable > 2 min:
  - Activate read‑only mode (via feature flag `read‑only‑mode`).
  - Show status banner.
  - Realtime fallbacks disabled.
- On restore:
  - Disable read‑only mode.
  - Clear banner.
  - Verify Realtime connection.
