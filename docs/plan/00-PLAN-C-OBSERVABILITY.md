---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-C-OBSERVABILITY.md
document_type: component_specification
module: CrossCutting
tier: infrastructure
status: stable
owner: Platform Engineering
component_count: 1
dependencies:
- Sentry SDK
- PostHog
- OTel v1.40.0
- DataPrepper
motion_requirements:
- None
accessibility:
- Error messages accessible
performance:
- <5% overhead
last_updated: 2026-04-25
version: 1.0
dependencies: [00-PLAN-1-INTRO.md, 00-PLAN-C-KNOWLEDGE.md]
related_adrs: [ADR_065]
related_rules: [OBSS_01, OBSS_02]
complexity: high
risk_level: critical
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Observability
OTelInstrumenter|OTEL|Service|-|OBSS_01,OBSS_02|OTel v1.40,DataPrepper|GenAI traces,PII redaction
SentryErrorTracker|OTEL|Service|-|OBSS_01|Sentry SDK|Session replays,sample-rate 0.1 prod
PostHogAnalytics|OTEL|Service|-|OBSS_01|PostHog SDK|AI_CALL,FLAG_EVALUATED,COST_ALERT
LogAggregator|OTEL|Service|-|OBSS_01|Loki|90-day retention,org_id labels

#SENTRY|dsn|env|sample_rate|session_replay|traces_sample_rate
production|${SENTRY_DSN}|production|0.1|Yes|0.05
staging|${SENTRY_DSN}|staging|1.0|Yes|0.1
development|${SENTRY_DSN}|development|1.0|No|1.0

#POSTHOG|api_key|env|capture|allow_training|retention
production|${POSTHOG_API_KEY}|production|AI_CALL,FLAG_EVALUATED,COST_ALERT,GUARDRAIL_BLOCK|false|90 days
staging|${POSTHOG_API_KEY}|staging|All events|true|30 days
development|${POSTHOG_API_KEY}|development|All events|true|7 days

#OTEL|version|exporter|endpoint|headers|protocol
v1.40.0|OTLP|${OTEL_ENDPOINT}|X-Honeycomb-Team:${TEAM}|HTTP/protobuf
experimental|gen_ai|OTEL_SEMCONV_STABILITY_OPT_IN|N/A|N/A

#GENAI_ATTRS|attribute|type|description
gen_ai.system|string|AI provider (anthropic,openai,google)
gen_ai.model|string|Model ID (claude-opus-4-7,gpt-5.5,gemini-3.1-pro)
gen_ai.request.model|string|Requested model
gen_ai.response.model|string|Actual model used
gen_ai.usage.input_tokens|int|Input token count
gen_ai.usage.output_tokens|int|Output token count
gen_ai.usage.total_tokens|int|Total token count
gen_ai.response.finish_reason|string|stop,length,tool_calls,error
gen_ai.cost.usd|float|Cost in USD
gen_ai.user.id|string|User ID
gen_ai.org.id|string|Organization ID
gen_ai.tool.name|string|Tool name if tool call
gen_ai.tool.call.id|string|Tool call ID

#PII_REDACTION|field|method|location|pattern
gen_ai.request.messages|DataPrepper|Collector|redact_pii_processor
gen_ai.response.content|DataPrepper|Collector|redact_pii_processor
user.email|DataPrepper|Collector|email_pattern
user.phone|DataPrepper|Collector|phone_pattern
org.name|DataPrepper|Collector|name_pattern

#LOKI|labels|retention|index|rate_limit
org_id|90 days|org_id,service,severity|10MB/s
service|90 days|org_id,service,severity|10MB/s
severity|90 days|org_id,service,severity|10MB/s

#ALERTS|metric|threshold|duration|action|channel
sentry_error_rate|>5%|5min|Slack|#incidents
sentry_p50_latency|>2s|5min|Slack|#incidents
posthog_event_drop|>1%|5min|Slack|#incidents
otel_trace_failure|>1%|5min|PagerDuty|Platform on-call
loki_error_rate|>10/min|5min|Slack|#incidents
data_prepper_lag|>10s|5min|Slack|#incidents

#DASHBOARDS|dashboard|panels|refresh|audience
SLO Dashboard|TTFT,Availability,EB,BR|1min|All engineers
Error Dashboard|Error rate,p50 latency,top errors|1min|All engineers
Cost Dashboard|Token cost,forecast,budget|5min|Product+Platform
Guardrail Dashboard|Input/Output blocks,tool auth|5min|AI+Security
Rate Limit Dashboard|429 rate,per-user/org|1min|Platform

#TESTING|scenario|expected|test_method
sentry_capture|Error sent|Trigger error,verify Sentry|Integration test
posthog_event|Event captured|Trigger event,verify PostHog|Integration test
otel_trace|Trace exported|Trigger request,verify OTel|Integration test
pii_redaction|PII redacted|Send PII,verify redaction|Integration test
loki_log|Log aggregated|Write log,verify Loki|Integration test

#AUDIT|check|frequency|owner|action
sentry_quota|Monthly|Platform|Review usage,adjust plan
posthog_quota|Monthly|Platform|Review usage,adjust plan
otel_cost|Monthly|Platform|Review OTel endpoint costs
loki_retention|Quarterly|Platform|Verify 90-day compliance
redaction_rules|Monthly|Security|Review PII patterns

EOF
