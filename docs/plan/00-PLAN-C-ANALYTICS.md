---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-C-ANALYTICS.md
document_type: analytics_spec
tier: business
status: stable
owner: Product / GTM
description: PostHog event taxonomy, Group Analytics, OpenFeature integration
last_updated: 2026-04-25
version: 1.0
dependencies: [00-PLAN-1-INTRO.md, 00-PLAN-C-OBSERVABILITY.md]
related_adrs: [ADR_062]
related_rules: []
complexity: low
risk_level: medium
---

#Analytics
Events|Canonical list: agent_invoked, workflow_started, workflow_completed, feature_adopted, ai_cost_threshold_hit, auth_passkey_enrolled, sync_offline_queue, mcp_tool_call, rate_limit_triggered
Properties|orgId,userId,timestamp,sessionId mandatory; Group Analytics enabled
Enforcement|PR approval required for new events; CI validates schema
OpenFeature|Vercel Flags SDK+PostHog provider; flagging for analytics sampling
