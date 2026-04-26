---
steering: TO PARSE - READ INTRO
document_type: workflow_engine_spec
tier: infrastructure
description: LangGraph Supervisor mapping, LangMem, Trustcall, SM integration
last_updated: 2026-04-25
version: 1.0
---

#WFE
LangGraph|Supervisor pattern maps to FLOWC01 SM; StateGraph edges for transitions
LangMem|cross-session summarisation; replaces FIFO memory; store in episodic memory
Trustcall|Tool call extraction; schema-validated
Swarm|Multi-agent orchestration; handoff protocol
OTel|gen_ai.* attributes on all nodes; root span via DataPrepper
Cost|All tool calls metered; sync budget check (COST03)
