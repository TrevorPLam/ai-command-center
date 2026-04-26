---
steering: TO PARSE - READ INTRO
file_name: 07-TEST-INFRA.md
document_type: testing_infrastructure
tier: infrastructure
status: stable
owner: Platform Engineering
description: Vitest, MSW, Playwright, pgTAP, contract testing, CI matrix
last_updated: 2026-04-25
version: 1.0
dependencies: [01-PLAN-LEXICON.md, 07-TEST-STRATEGY.md]
related_adrs: [ADR_058]
related_rules: [TESTC_01, TESTC_02, TESTC_03, TESTC_04, TESTC_05, TESTC04b, TESTC07]
complexity: high
risk_level: critical
---

#TestInfra
Vitest|Unit+component; global Setup file; coverage Istanbul
MSW|Server-side handlers auto-generated from OAI3.1 via openapi-backend (TESTC07); 429 rate-limit factory; SSE mock pattern
Playwright|E2E critical flows (10-15); per-environment config; AI agents (Planner/Generator/Healer) on CI
pgTAP|RLS isolation tests; auto-generation with supaShield; mandatory for new tables (TESTC04b)
Contract|Schemathesis in CI (APIC003); schema validation PR; main post-deploy contract test; ignore file for SSE/WS
AI Eval|DeepEval + RAGAS; thresholds in #TEST; LLM-as-judge through LiteLLM proxy
CI|Full matrix: typecheck (tsc 6.0 + tsgo 7.0), eslint, test:unit, test:component, test:rls, test:e2e, prisma:drift, orval:codegen, docker:build, schemathesis
