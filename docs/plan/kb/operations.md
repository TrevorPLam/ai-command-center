---
title:-"-"
owner: "DevOps"
status: "active"
updated: "2026-04-26"
canonical: ""
---
title: "Operations"
owner: "DevOps"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

Better Stack and PagerDuty for incident communication with auto status page, thumbs-up feedback loop for AI evaluation, Stripe webhook handling with idempotency and metered AI billing.

## Key Facts

### Incident Communication

**IncidentComm**: Incident management

- Better Stack, PagerDuty
- Auto status page on health failure
- On-call escalation

### Feedback Loop

**FeedbackLoop**: AI evaluation

- Thumbs-up/down on AI responses
- Eval datasets
- Automated sampling

### Billing

**Billing**: Stripe integration

- Stripe webhook (verified HMAC)
- Idempotency via processed_stripe_events table
- Handle invoice.paid, subscription.updated
- Stripe Portal
- Metered AI via ai_cost_log
- LicenseGate: 402 + CTA

## Why It Matters

- Incident communication ensures rapid response to outages
- Feedback loop enables continuous AI improvement
- Billing integration enables revenue operations

## Sources

- Better Stack documentation
- PagerDuty documentation
- Stripe documentation
