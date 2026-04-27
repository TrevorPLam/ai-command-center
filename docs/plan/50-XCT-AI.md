---
title: "AI Services"
owner: "AI/ML Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

AI guardrails, cost tracking, observability, and MCP security.

---

## Services

### OpenTelemetry GenAI Instrumenter

#### OTelGenAIInstrumenter
- **Module**: OTEL (OpenTelemetry)
- **Type**: Service
- **Patterns**: `@OTelGenAI`
- **Rules**: SLO_02 (SLO rule 2)
- **Dependencies**: OpenTelemetry 1.40, DataPrepper
- **Purpose**: Instruments AI interactions for observability
- **Features**:
  - Root span propagation
  - PII redaction at collector level
  - GenAI-specific attributes and conventions
  - Cost and usage tracking

### AI Guardrails Engine

#### AIGuardrailsEngine
- **Module**: GRDL (Guardrails)
- **Type**: Service
- **Patterns**: `@AIGuardrails`
- **Rules**: EVAL_02 (Evaluation rule 2)
- **Dependencies**: Guardrails-AI, DeepEval
- **Purpose**: Enforces AI safety and compliance policies
- **Features**:
  - Three-layer protection (input, output, runtime)
  - Full audit logging
  - Configurable rule sets
  - Real-time decision making

### SSRF Prevention Middleware

#### SSRFPreventionMiddleware
- **Module**: SSRF (SSRF Prevention)
- **Type**: Middleware
- **Patterns**: `@SSRFPrevention`
- **Rules**: MCPG_02 (MCP Gateway rule 2)
- **Dependencies**: ipaddress library, DNS resolver
- **Purpose**: Prevents Server-Side Request Forgery attacks
- **Features**:
  - Domain allowlist enforcement
  - IP range validation
  - Redirect blocking
  - DNS validation

### Stripe Token Meter

#### StripeTokenMeter
- **Module**: STKB (Stripe Billing)
- **Type**: Service
- **Patterns**: `@StripeBilling`
- **Dependencies**: `@stripe/ai-sdk`, `@stripe/token-meter`
- **Purpose**: Tracks and bills AI token usage through Stripe
- **Features**:
  - LiteLLM cost log integration
  - 30% markup on base costs
  - Real-time usage tracking
  - Per-organization billing

---

## Observability

### Overview

The observability system provides comprehensive monitoring, tracing, logging, and analytics across the platform. It integrates OpenTelemetry for distributed tracing, Sentry for error tracking, PostHog for product analytics, and Loki for log aggregation.

### Components

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| OTelInstrumenter | OTEL | Service | - | OBSS_01, OBSS_02 | OTel v1.40, DataPrepper | GenAI traces, PII redaction |
| SentryErrorTracker | OTEL | Service | - | OBSS_01 | Sentry SDK | Session replays, 0.1 sample rate in prod |
| PostHogAnalytics | OTEL | Service | - | OBSS_01 | PostHog SDK | AI_CALL, FLAG_EVALUATED, COST_ALERT |
| LogAggregator | OTEL | Service | - | OBSS_01 | Loki | 90-day retention, org_id labels |

### Sentry Configuration

| DSN | Environment | Sample Rate | Session Replay | Traces Sample Rate |
|-----|-------------|-------------|----------------|---------------------|
| ${SENTRY_DSN} | production | 0.1 | Yes | 0.05 |
| ${SENTRY_DSN} | staging | 1.0 | Yes | 0.1 |
| ${SENTRY_DSN} | development | 1.0 | No | 1.0 |

### PostHog Configuration

| API Key | Environment | Capture | Training | Retention |
|---------|-------------|---------|----------|-----------|
| ${POSTHOG_API_KEY} | production | AI_CALL, FLAG_EVALUATED, COST_ALERT, GUARDRAIL_BLOCK | false | 90 days |
| ${POSTHOG_API_KEY} | staging | All events | true | 30 days |
| ${POSTHOG_API_KEY} | development | All events | true | 7 days |

### OpenTelemetry Configuration

| Version | Exporter | Endpoint | Headers | Protocol |
|---------|----------|----------|---------|----------|
| v1.40.0 | OTLP | ${OTEL_ENDPOINT} | X-Honeycomb-Team:${TEAM} | HTTP/protobuf |
| experimental | gen_ai | OTEL_SEMCONV_STABILITY_OPT_IN | N/A | N/A |

### GenAI Attributes

OpenTelemetry semantic conventions for GenAI monitoring:

| Attribute | Type | Description |
|-----------|------|-------------|
| gen_ai.system | string | AI provider (anthropic, openai, google) |
| gen_ai.model | string | Model ID (claude-opus-4-7, gpt-5.5, gemini-3.1-pro) |
| gen_ai.request.model | string | Requested model |
| gen_ai.response.model | string | Actual model used |
| gen_ai.usage.input_tokens | int | Input token count |
| gen_ai.usage.output_tokens | int | Output token count |
| gen_ai.usage.total_tokens | int | Total token count |
| gen_ai.response.finish_reason | string | stop, length, tool_calls, error |
| gen_ai.cost.usd | float | Cost in USD |
| gen_ai.user.id | string | User ID |
| gen_ai.org.id | string | Organization ID |
| gen_ai.tool.name | string | Tool name if tool call |
| gen_ai.tool.call.id | string | Tool call ID |

### PII Redaction

| Field | Method | Location | Pattern |
|-------|--------|----------|---------|
| gen_ai.request.messages | DataPrepper | Collector | redact_pii_processor |
| gen_ai.response.content | DataPrepper | Collector | redact_pii_processor |
| user.email | DataPrepper | Collector | email_pattern |
| user.phone | DataPrepper | Collector | phone_pattern |
| org.name | DataPrepper | Collector | name_pattern |

### Loki Log Aggregation

| Label | Retention | Index | Rate Limit |
|-------|-----------|-------|------------|
| org_id | 90 days | org_id, service, severity | 10MB/s |
| service | 90 days | org_id, service, severity | 10MB/s |
| severity | 90 days | org_id, service, severity | 10MB/s |

### Alerting Rules

| Metric | Threshold | Duration | Action | Channel |
|--------|-----------|----------|--------|---------|
| sentry_error_rate | >5% | 5min | Slack | #incidents |
| sentry_p50_latency | >2s | 5min | Slack | #incidents |
| posthog_event_drop | >1% | 5min | Slack | #incidents |
| otel_trace_failure | >1% | 5min | PagerDuty | Platform on-call |
| loki_error_rate | >10/min | 5min | Slack | #incidents |
| data_prepper_lag | >10s | 5min | Slack | #incidents |

### Dashboards

| Dashboard | Panels | Refresh | Audience |
|-----------|--------|---------|----------|
| SLO Dashboard | TTFT, Availability, EB, BR | 1min | All engineers |
| Error Dashboard | Error rate, p50 latency, top errors | 1min | All engineers |
| Cost Dashboard | Token cost, forecast, budget | 5min | Product + Platform |
| Guardrail Dashboard | Input/Output blocks, tool auth | 5min | AI + Security |
| Rate Limit Dashboard | 429 rate, per-user/org | 1min | Platform |

### Testing Scenarios

| Scenario | Expected | Test Method |
|----------|----------|-------------|
| sentry_capture | Error sent to Sentry | Integration test |
| posthog_event | Event captured | Integration test |
| otel_trace | Trace exported | Integration test |
| pii_redaction | PII redacted | Integration test |
| loki_log | Log aggregated | Integration test |

### Audit Schedule

| Check | Frequency | Owner | Action |
|-------|-----------|-------|--------|
| sentry_quota | Monthly | Platform | Review usage, adjust plan |
| posthog_quota | Monthly | Platform | Review usage, adjust plan |
| otel_cost | Monthly | Platform | Review OTel endpoint costs |
| loki_retention | Quarterly | Platform | Verify 90-day compliance |
| redaction_rules | Monthly | Security | Review PII patterns |
