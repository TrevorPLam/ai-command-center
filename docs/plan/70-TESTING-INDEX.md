---
title: "Testing Documentation Index"
owner: "QA Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

Index for the split testing documentation. The original monolithic `70-TESTING.md` has been reorganized into focused files for better maintainability and on-demand loading.

**Document version:** 1.0
**Last updated:** April 2026
**Owner:** QA (R1)

---

## Documentation Files

### [70-TESTING-STRATEGY.md](70-TESTING-STRATEGY.md)

High-level testing strategy covering quality vision, test levels, automation, and release criteria.

**Contents:**
- Introduction & Quality Vision
- Test Scope & Strategy (risk-based testing matrix, test levels & ownership)
- AI-Specific Testing Approach (AgentAssay framework, evaluation framework, golden datasets, AI quality gates)
- Test Automation Strategy (tool-layer assignment, CI pipeline, Playwright AI agents, mock & service virtualization, automated blocking gates)
- Test Environment & Infrastructure (environment topology, test data management, contract testing, offline sync scenarios)
- Security & Compliance Testing (OWASP & ASI risk mapping, MCP security testing, grant & auth webhook testing, data sovereignty & privacy, compliance automation, AI Bill of Materials)
- Migration & Technology Transition Testing (OpenAI Responses API migration, TypeScript 6.0 & 7.0, React 20 Compiler, Claude 4.6 compatibility, Temporal Safari testing)
- Performance, Load & Observability (performance benchmarks, load testing profiles, AI cost observability, monitoring & rollback)
- Traceability, Reporting & Release Decisions (requirement-test traceability, defect triage & handoff workflow, release criteria checklist)
- Appendices (test case template, bug report template, live coverage dashboard, glossary)

**Load:** Always (core strategy document)

---

### [70-TESTING-BENCHMARKS.md](70-TESTING-BENCHMARKS.md)

Deep dive benchmark analyses for pgTAP effectiveness, Orval accuracy, Playwright agent costs, contract testing tool comparisons, and CVE mapping details.

**Contents:**
- DeepEval vs RAGAS Accuracy Comparison
- LLM-as-Judge Bias Validation via LiteLLM Proxy
- Cost Effectiveness of LLM-as-Judge vs Traditional Testing
- Playwright AI Agents (MCP) - Effectiveness Metrics
- Playwright AI Agents - Cost Optimization via LiteLLM Proxy
- Playwright AI Agents - CI Integration Patterns
- pgTAP RLS Test Coverage Patterns
- pg_prove Automation Effectiveness
- Drift Detection - Detailed Approaches
- Orval Code Generation Accuracy
- Orval Mock Generation (MSW Handlers)
- Orval Schema Validation Effectiveness
- CVE Mapping Details
- ASI Coverage Analysis
- Automated CVE Mapping Update Process

**Load:** On-demand (detailed reference material)

---

### [70-TESTING-SCHEDULE.md](70-TESTING-SCHEDULE.md)

Phased testing schedule and risk register for the AI-integrated workspace platform.

**Contents:**
- Phased Testing Schedule (Phase 1-5 with timelines and deliverables)
- Risk Register (identified risks with probability, impact, and mitigation strategies)

**Load:** On-demand (planning reference)

---

## Migration Notes

The original `70-TESTING.md` file has been split into three focused documents:

1. **Strategy** - High-level approach, always loaded for AI agents
2. **Benchmarks** - Deep dive analyses, loaded on-demand for detailed reference
3. **Schedule** - Phased timeline and risks, loaded on-demand for planning

This split reduces the token load for AI agents while maintaining all information in accessible, focused documents.

---

*End of document.*
