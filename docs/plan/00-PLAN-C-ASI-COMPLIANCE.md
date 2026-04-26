---
steering: TO PARSE - READ INTRO
document_type: asicompliance
tier: compliance
description: OWASP Agentic AI Top10 2026 gap analysis, controls
last_updated: 2026-04-25
version: 1.0
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
