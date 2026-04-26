---
steering: TO PARSE - READ INTRO
file_name: 08-OPS-LOAD-TESTING.md
document_type: load_testing
tier: infrastructure
status: stable
owner: Platform Engineering
description: Load testing strategy with k6 and Artillery
last_updated: 2026-04-25
version: 1.0
dependencies: [01-PLAN-LEXICON.md, 02-ARCH-OVERVIEW.md]
related_adrs: []
related_rules: [OBSS_01]
complexity: medium
risk_level: medium
---

# Load Testing

k6+Artillery; global 1000req/s; per-user chat 200/min; start 4-6 weeks pre-launch; stress test 200% peak 2h; soak 80% 8h; fail if p95>2x baseline or timeout>5s.
