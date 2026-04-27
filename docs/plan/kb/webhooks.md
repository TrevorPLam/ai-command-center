---
title: "Webhook Integration Patterns"
owner: "Backend Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

Svix for inbound webhooks with acknowledge-first pattern, Resend for transactional email with Svix delivery, queue selection based on volume and durability requirements.

## Key Facts

### Resend Inbound

**RESEND_INBOUND**: Svix delivery

- TASK INFORMATION INCORRECT: 3-day log retention insufficient - HIPAA requires 6 years, SOC 2 requires policies (no specific duration)
- Industry standards: HIPAA 6 years, SOX 7 years, NERC 6 months logs/3 years audit records, ISO 27001 12 months, PCI DSS 12 months
- React Email 5.0
- Inbound parse available

### Svix Integration

**SVIX_INTEGRATION**: Acknowledge-first pattern

#### Pattern

- Verify signature
- Validate structure
- Write to queue
- Return 200 immediately

#### Queue Selection

- Redis: moderate volume, simple/fast
- RabbitMQ/SQS: delivery guarantees, dead-letter queues
- Kafka: high volume/durability, replay capabilities

#### Key Requirements

- Durability
- At-least-once delivery
- Keep queue close to webhook endpoint to minimize latency
- Short timeouts protect providers from cascading failures

### Resend Primary

**Resend_Primary**: Resend is now primary transactional email

- Handle email.complained → unsubscribed:true
- Svix inbound webhooks

## Why It Matters

- Acknowledge-first pattern prevents webhook delivery timeouts
- Queue selection based on volume and durability requirements
- Log retention must comply with regulatory requirements (HIPAA 6 years)

## Sources

- Svix documentation
- Resend documentation
- HIPAA, SOC 2, SOX, NERC, ISO 27001, PCI DSS documentation
