---
id: runbook.ai-outage
title: AI Provider Failure Runbook
type: runbook
last_updated: '2026-04-25T01:34:38.868869+00:00'
---

- If `AI_PROVIDER_ERROR` count > 5 in 60s → **activate circuit breaker**.
  - Display global banner: "AI features temporarily degraded".
  - Disable Chat input, show fallback message.
  - Fallback chain: gpt‑4o → claude‑3‑7 → local embedding.
  - Notify Sentry and on‑call engineer.
- Once primary provider is healthy → **deactivate circuit breaker**.
