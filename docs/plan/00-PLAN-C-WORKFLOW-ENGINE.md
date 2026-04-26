---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-C-WORKFLOW-ENGINE.md
document_type: workflow_engine_spec
tier: infrastructure
status: stable
owner: AI/ML Engineering
description: LangGraph Supervisor mapping, LangMem, Trustcall, SM integration
last_updated: 2026-04-25
version: 1.0
dependencies: [00-PLAN-1-INTRO.md, 00-PLAN-C-KNOWLEDGE.md]
related_adrs: [ADR_032]
related_rules: [FLOWC_01, COST_03, OTEL_01, OTEL_02]
complexity: high
risk_level: critical
---

#WFE
LangGraph|Supervisor pattern maps to FLOWC01 SM; StateGraph edges for transitions
LangMem|cross-session summarisation; replaces FIFO memory; store in episodic memory
Trustcall|Tool call extraction; schema-validated
Swarm|Multi-agent orchestration; handoff protocol
OTel|gen_ai.* attributes on all nodes; root span via DataPrepper
Cost|All tool calls metered; sync budget check (COST03)
