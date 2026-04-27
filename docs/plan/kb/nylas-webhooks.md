---
title:-"-"
owner: "Backend Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---
title: "Nylas Webhooks"
owner: "Backend Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

Nylas two-tier failure model with 95% threshold, 72-hour backfill window, grant expiry handling, and async processing patterns. Critical limitation: message tracking events permanently lost if grant out of service >72 hours.

## Key Facts

### Webhook Reliability

**WEBHOOK_RELIABILITY**: Nylas two-tier failure model

- Failing state: 95% non-200 responses over 15min, continues delivery for 72h with exponential backoff, email notification sent
- Failed state: 95% non-200 over 72h, manual reactivation required via Dashboard/API, events missed during failed state lost unless manually retrieved
- 95% threshold validated from official Nylas docs - more conservative than industry standard (50% circuit breaker threshold) to reduce false positives from transient failures
- Add `@nylas.com` to email allowlist to prevent spam folder delivery
- Industry comparison: Hookdeck suggests 50% failure rate over 1-minute window or 5 of 10 requests failed for circuit breakers
- Nylas design choice prioritizes avoiding false positives over rapid failure detection

### Backfill Strategy

**BACKFILL_STRATEGY**: 72-hour backfill window

- If grant out of service <72h, Nylas sends backfill notifications for changes during outage
- If grant out of service >72h, Nylas does NOT send backfill notifications
- For >72h outages: Query Nylas APIs for objects that changed between grant.expired and grant.updated timestamps
- Critical limitation: Message tracking events (message.opened, message.link_clicked, thread.replied) cannot be backfilled if grant was out of service >72 hours - these events are permanently lost and must be accepted as data gap
- Support cannot replay webhooks - manual API retrieval is the only recovery mechanism
- 72-hour window is a hard limit set by Nylas infrastructure, not configurable

### Grant Expiry Handling

**NYLAS_GRANT_EXP**: When grant expires, all webhooks stop

- Re-auth <72h → backfill available
- Re-auth >72h → permanent data loss
- Handle grant.expired webhook immediately

### Webhook Best Practices

**Nylas_Webhook_BestPractices**: Async processing pattern

- Async processing (ack <10s)
- Idempotency via nylas_processed_events table
- DLQ after 3 retries
- Grant.expired handling (refresh attempt, 72h backfill window)
- Daily cron for expiring grants
- See runbook

## Why It Matters

- Webhook reliability impacts data synchronization integrity
- 72-hour backfill window is hard constraint - data loss beyond this point is permanent
- Message tracking events cannot be recovered after 72h gap - critical for analytics
- Async processing prevents timeout cascades
- Idempotency prevents duplicate processing on retries

## Sources

- Nylas official documentation on webhook reliability
- Nylas API documentation on grant lifecycle
- Industry webhook best practices (Hookdeck)
