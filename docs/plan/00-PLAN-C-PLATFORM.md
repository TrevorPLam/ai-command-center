---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-C-PLATFORM.md
document_type: component_specification
module: Platform
tier: core
status: stable
owner: Platform Engineering
component_count: 11
dependencies:
- ~l/env.ts
- ~l/errorBoundary.ts
- ~p/AnalyticsPage
motion_requirements:
- @L (LiquidGlass)
- @AP (AnimatePresence)
accessibility:
- WCAG 2.2 AA compliance
- Keyboard navigation
- Screen reader support
performance:
- Error boundary optimization
- Agent analytics
last_updated: 2026-04-25
version: 1.0
dependencies: [00-PLAN-1-INTRO.md, 00-PLAN-C-SHELL.md]
related_adrs: []
related_rules: [g10]
complexity: medium
risk_level: medium
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Platform
EnvValidation|PL|Util|-|-|~l/env.ts|no mount invalid
ErrorBoundary|PL|Boundary|-|-|~l/errorBoundary.ts|logClientEvent
AnalyticsPage|PL|Page|@L,AP|-|~p/AnalyticsPage|AgentAnalytics
AuditLogPage|PL|Page|@L,@V,AP|-|-|-
PrivacyBanner|PL|Banner|-|-|-|-
LoginPage|PL|Page|@L,AP|-|-|-
SignupPage|PL|Page|@L,AP|-|-|-
OAuthCallbackPage|PL|Page|@L,AP|-|-|-
AgentStudioPage|PL|Page|@L,AP|-|-|agent lib,playground
AgentAnalyticsPage|PL|Page|@L,AP|-|-|per-agent metrics,cost
AgentPlaygroundPage|PL|Page|@L,@PLAY,AP|-|-|sandbox testing
