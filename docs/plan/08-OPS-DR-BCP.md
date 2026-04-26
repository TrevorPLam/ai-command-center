---
steering: TO PARSE - READ INTRO
file_name: 08-OPS-DR-BCP.md
document_type: disaster_recovery
tier: infrastructure
status: stable
owner: Platform Engineering
description: Disaster recovery procedures and business continuity planning
last_updated: 2026-04-25
version: 1.0
dependencies: [01-PLAN-LEXICON.md, 02-ARCH-OVERVIEW.md]
related_adrs: []
related_rules: []
complexity: medium
risk_level: high
---

# DR/BCP

RTO:FastAPI 5min,DB 1h; RPO:FastAPI 0,DB 15min; monthly chaos tests; runbooks in ops/dr/; NIS2 audit trails; backup verification weekly.
