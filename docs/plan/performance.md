# Performance budgets & thresholds

These are concrete numbers that must be respected in every build.

> **Canonical source**: SLA targets and infrastructure thresholds are defined in [02-ARCH-OVERVIEW.md](02-ARCH-OVERVIEW.md). This file specifies the concrete budgets derived from those targets.

---

## Core Web Vitals

- LCP (Largest Contentful Paint): ≤800 ms (p75)
- INP (Interaction to Next Paint): ≤200 ms
- CLS (Cumulative Layout Shift): ≤0.1

---

## JavaScript bundle budgets (initial / lazy)

- Initial chunk: ≤150 KB
- Lazy chunk: ≤800 KB
- Monaco editor chunk: ≤2 MB
- React Flow chunk: ≤200 KB
- react‑big‑calendar chunk: ≤150 KB
- Yjs chunk: ≤300 KB
- Tremor chunk: ≤15 KB
- AI SDK chunk: ≤10 KB
- PowerSync chunk: ≤50 KB
- Temporal polyfill chunk: ≤20 KB (conditional, Safari only)
- rschedule chunk: ≤15 KB
- SimpleWebAuthn chunk: ≤12 KB (lazy, auth routes only)
- PostHog chunk: ≤19 KB (shared, feature flagged)

---

## Caching & timing

- Search debounce: 300 ms
- Hover prefetch delay: 200 ms
- SSE heartbeat: 15–20 seconds
- SSE reconnect: 1s, 2s, 4s, 8s, max 30s (max 3 retries)
- Org switch cache clear + reconnect: <2 seconds
- Undo window for deletes: 5 seconds
- Stagger animation: max 3 children
- Spring stiffness ≥300, damping ≥30

---

## Cost & rate limits

- AI cost alerts: at 15% remaining → admin; 5% → admin+engineers; 0% → hard stop with 429.
- Cost forecast accuracy target: ±10%
- Stripe markup: 30%
- Platform rate limit: 1000 req/min per org
- Nylas webhook ACK timeout: 10 seconds
- Nylas auto‑disable: after 95% failure rate over 72 hours

---

## Operational thresholds

- P0 incident response: immediate
- P0 update cadence: every 15 minutes
- Postmortem due: 48 hours
- Feature flag rollout: off → internal(2d) → beta(3d) → 5/20/50%(2d each) → 100%
- Kill switch: revert to 0% in under 5 minutes
- Secret rotation failure: P1 incident, manual rotation within 1 hour
