---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-API-VERSIONING.md
document_type: api_versioning
tier: infrastructure
status: stable
owner: Platform Engineering
description: API versioning strategy with deprecation and sunset policies
last_updated: 2026-04-25
version: 1.0
dependencies: [00-PLAN-5-EP.md]
related_adrs: []
related_rules: []
complexity: low
risk_level: medium
---

# API Versioning

URL path (/v1/); deprecation 12mo; Sunset header; OpenAPI discriminator; lifecycle draft→beta→stable→deprecated→sunset; migration guides required.
