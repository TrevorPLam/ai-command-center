---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-C-ASI-COMPLIANCE.md
document_type: asicompliance
tier: compliance
status: stable
owner: Security / GRC
description: OWASP Agentic AI Top10 2026 gap analysis, controls
last_updated: 2026-04-25
version: 1.0
dependencies: [00-PLAN-1-INTRO.md, 00-PLAN-C-AI.md, 00-PLAN-C-TESTING.md]
related_adrs: [ADR_067]
related_rules: [GRDL_01, GRDL_02, SECM_01, SECM_02, SECM_03]
complexity: high
risk_level: critical
---

#ASI
Gap mappings|ASI01-ASI10 ↔ GRDL layers, SECM controls. See matrix below.
ASI01 Goal Hijack|GRDL input+output; Intent Capsule validation
ASI02 Tool Misuse|MCP OAuth+schema allowlist; runtime tool auth
ASI03 Identity Abuse|NHS; MCPsec L2 Agent Passports
ASI04 Poison|Input guardrails; vector DB quarantine
... (etc)
AIBOM|CycloneDX per model; training data provenance; safety eval (AIBOM04)
EU AI Act|Stand-alone high-risk deadline Dec 2,2027; embedded Aug 2,2028
Singapore Framework|Align with draft; documented decision log
