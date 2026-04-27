---
title: "Test Schedule & Risks"
owner: "QA Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

Phased testing schedule and risk register for the AI-integrated workspace platform. See [70-TESTING-STRATEGY.md](70-TESTING-STRATEGY.md) for the full testing strategy.

**Document version:** 1.0
**Last updated:** April 2026
**Owner:** QA (R1)

---

## 1. Phased Testing Schedule

| Phase | Focus | Timeline | Key Deliverables |
|---|---|---|---|
| Phase 1 | Foundation, core modules | Q2 2026 | Unit/component coverage ramp-up, CI pipeline |
| Phase 2 | AI evaluation integration | Q2-Q3 2026 | AgentAssay, DeepEval gates |
| Phase 3 | Feature module testing, E2E, offline sync | Q3 2026 | 15 critical flows automated, sync tests |
| Phase 4 | Security & compliance hardening | Q3-Q4 2026 | MCP L2, ASI coverage, Vanta evidence |
| Phase 5 | Mobile & desktop (Expo, Tauri) | Q1 2027 | Mobile E2E, Tauri capability tests |

---

## 2. Risk Register

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| OpenAI API changes break tool calling | Medium | High | Contract & parity tests; migration buffer until Aug 26 |
| Model provider model drift (accuracy) | Medium | High | AI quality gates, golden dataset refresh, A/B testing |
| MCP server security vulnerability | Low | Critical | Regular SecureMCP audits, L2 CI gate |
| Offline sync data conflicts | Medium | Medium | PowerSync conflict resolution tests, deterministic rules |
| SOC2 / EU AI Act timeline miss | Low | Critical | Vanta automation, dedicated compliance sprint |

---

*End of document.*
