---
title: "Test Strategy"
owner: "QA Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

High-level testing strategy covering quality vision, test levels, automation, and release criteria. Deep dive benchmarks are in [70-TESTING-BENCHMARKS.md](70-TESTING-BENCHMARKS.md).

**Document version:** 1.0
**Last updated:** April 2026
**Owner:** QA (R1)
**Handoff roles:** TL, PM, FSE, MOB

---

## 1. Introduction & Quality Vision

### 1.1 Product Mission

The AI-integrated workspace platform provides a dashboard to monitor, interact with, and control AI agents; a feature-rich chat interface; and a suite of productivity applications (Calendar, Projects, Email, etc.) where both users and AI agents can create, read, update, and delete data. Its core innovation is cross-application, context-aware AI assistance that proactively surfaces conflicts and suggests actions.

### 1.2 Quality Pillars

All testing and quality assurance activities support four pillars:

- **Correctness & Accuracy** - The system behaves as specified; AI outputs are factual and relevant.
- **Reliability & Resilience** - The service is available, performant, and consistent, even under load or during offline operation.
- **Security & Privacy** - User data is protected, guardrails prevent misuse, and we comply with SOC 2, the EU AI Act, and NIS2.
- **Accessibility** - All user-facing interfaces meet WCAG 2.2 AA, with zero critical violations.

### 1.3 Roles & Responsibilities (RACI Matrix)

| Activity | QA (Lead) | Dev (TL) | PM | Security (FSE) | Mobile (MOB) |
|---|---|---|---|---|---|
| Test plan & strategy | A | C | I | C | C |
| Unit / component test design | R | A | I | I | I |
| Integration / E2E test execution | A | C | I | C | C |
| AI evaluation & quality gates | A | C | I | - | - |
| Security testing & guardrails | C | C | I | A | I |
| Performance & load testing | A | C | - | - | - |
| Offline sync testing | A | C | - | - | A |
| Compliance evidence collection | C | C | I | A | - |
| Release decision | A | R | C | C | C |

*R=Responsible, A=Accountable, C=Consulted, I=Informed*

### 1.4 Document Conventions

| Term | Definition |
|---|---|
| **BLOCK** | The CI pipeline stops deployment; human intervention required. |
| **WARN** | A notification is raised; deployment may continue with flag. |
| **Inconclusive (AgentAssay)** | Insufficient evidence to pass or fail; manual review triggered. |
| **Critical defect** | A bug that breaks a P0 user flow or causes data loss / security breach. |
| **Major defect** | A bug that disables a feature without a workaround. |
| **Minor defect** | Cosmetic or edge-case issue. |

Test cases follow the **QA_C / QA_E / QA_A** format (see Appendix A). Bug reports follow the template in Appendix B.

---

## 2. Test Scope & Strategy

### 2.1 Scope

All product modules and cross-cutting concerns are in scope. The list below shows the modules, their primary quality risks, and the test depth assigned.

**Core modules:** Foundation, Dashboard, Chat, Workflows, Projects
**Feature modules:** Calendar, Email, Contacts, Conference, Translation, News, Documents, Research, Media, Budget, Settings, Platform
**Cross-cutting:** Offline sync (PowerSync), guardrails, AI cost tracking, MCP security, accessibility

### 2.2 Risk-Based Testing Matrix

| Module | Technical Risk (complexity, AI reliance) | Business Impact | Test Depth |
|---|---|---|---|
| Foundation | High | Critical (shared core) | Deep: unit ≥95%, component ≥85%, integration ≥90% |
| Dashboard | Medium | Critical (agent fleet mgmt) | Deep |
| Chat | High (AI, real-time) | Critical (J002) | Deep + AI evaluation |
| Workflows | High (canvas, state machines) | High | Standard |
| Projects | Medium | High (J001 conflict detection) | Standard + integration |
| Calendar | Medium (recurrence, timezone) | High | Standard |
| Email | Medium (third-party integration) | High | Standard + integration |
| Contacts | Low | Medium | Standard |
| Conference | Medium (LiveKit) | Medium | Standard + integration |
| Translation | Medium (real-time AI) | Medium | Standard + AI evaluation |
| News | Low | Low | Minimal |
| Documents | Medium | High | Standard |
| Research | Medium | Medium | Standard |
| Media | Medium (upload security) | Medium | Standard + security |
| Budget | Medium | Medium | Standard |
| Settings | Low | High (configuration) | Standard |
| Platform | High (core services) | Critical | Deep |

**Test depth legend:**
- **Deep:** All test levels (unit, component, integration, E2E, security, AI eval)
- **Standard:** Unit ≥80%, component ≥85%, integration ≥70%, E2E for critical flows, basic AI eval where applicable
- **Minimal:** Unit and component coverage, integration where dependencies exist

### 2.3 Test Levels & Ownership

| Level | Tools | Primary Owner | Description |
|---|---|---|---|
| Unit | Vitest | Dev, QA | Individual functions, pure logic; fast, mocked dependencies |
| Component | Vitest, MSW, axe-core | QA, Dev | React components, state, accessibility |
| Integration | Vitest, Supertest, pgTAP | QA | API endpoints, database RLS, cross-module interactions |
| E2E critical flows | Playwright, AI agents | QA | 10-15 user journeys in production-like environment |
| AI evaluation | DeepEval + RAGAS, AgentAssay | QA + Data Science | Accuracy, hallucination, non-determinism |
| Security | Schemathesis, pgTAP, AgentProbe, manual | Security (FSE) + QA | API contract, RLS, adversarial testing |
| Performance & load | k6, OpenTelemetry | QA / DevOps | Throughput, latency, cost tracking |

---

## 3. AI-Specific Testing Approach

### 3.1 Non-Determinism & the AgentAssay Framework

Traditional binary pass/fail tests are inadequate for stochastic AI agents. We adopt the **AgentAssay** framework, which uses:

- **Three-valued verdicts:** Pass, Fail, Inconclusive (confidence interval straddles threshold)
- **Sequential Probability Ratio Test (SPRT):** reduces trials by 78% compared to fixed-n =100
- **Behavioral fingerprinting:** compresses tool sequences, state transitions, and decision patterns to detect regressions with 86% power (vs 0% for pass-rate tests)
- **Trace-first offline analysis:** uses production traces to achieve 98% detection power at zero additional token cost
- **Adaptive budget:** calibrates trial counts based on observed variance, capping at n_max =30 for CI

#### Statistical Guarantees

- Type I error control: ℙ[Pass | true pass rate < θ] ≤ α
- Pass verdict requires: lower bound of confidence interval ≥ θ (e.g., θ=0.85)
- Fail verdict: upper bound < θ
- Inconclusive: interval straddles θ

#### AgentAssay CI Gate Configuration

| Parameter | Value |
|---|---|
| Significance level (α) | 0.05 |
| Type II error bound (β) | 0.2 |
| Minimum regression δ | 0.15 |
| Pass rate threshold (θ) | 0.85 |
| Minimum coverage (C_min) | 1.0 (all scenarios) |
| Max trials per scenario (n_max) | 30 |
| Max wall-clock time (t_max) | 10 min |

Exit codes: 0=deploy, 1=block, 2=manual/inconclusive

Override procedures: inconclusive results require manual review with audit trail; exit code 2 may be treated as warning per team decision.

### 3.2 Evaluation Framework (DeepEval + RAGAS)

LLM-as-judge through LiteLLM proxy evaluates accuracy, relevancy, faithfulness, and hallucination. Metrics: FActScore, HallucinationRate, AnswerRelevancy, ToolPrecision, BLEU/ROUGE. Documented biases (NeurIPS 2024, IJCNLP 2025) mitigated through rubrics, position swapping, and multi-judge consensus.

See [70-TESTING-BENCHMARKS.md](70-TESTING-BENCHMARKS.md) for DeepEval vs RAGAS accuracy comparisons and LLM-as-judge bias validation details.

### 3.3 Golden Dataset Strategy

- For modest features: 10-20 curated examples
- For complex use cases (e.g., conflict detection, chat): 100-200 examples
- Datasets are versioned, refreshed quarterly or after major model updates
- Stored alongside the test code, with provenance tracked in CycloneDX AIBOM

### 3.4 AI Quality Gates (Single Source of Truth)

| Metric | Pass Threshold | Warning | Block |
|---|---|---|---|
| Accuracy (vs baseline) | ≥ base − 2% | - | < base − 2% |
| Latency | ≤ base + 10% | > base + 10% | > base + 20% |
| Token usage | ≤ base + 15% | > base + 15% | - |
| Tool precision | ≥ 90% | - | < 85% |
| Hallucination rate | ≤ 2% | - | > 2% |

All gates are evaluated per scenario, averaged over 3 runs, and enforced in CI. Manual review required for any block before deployment.

### 3.5 AI Cost Tracking Tests

- Validate token-meter accuracy vs provider billing (expect <2% variance)
- Verify real-time cost dashboard updates
- Confirm alerts fire at organisation, team, and user budget thresholds (15%, 5%, 0%)
- Hard-limit enforcement: when budget is exhausted, AI calls are rejected

---

## 4. Test Automation Strategy

### 4.1 Tool-Layer Assignment

| Test Layer | Tool | Scope |
|---|---|---|
| Unit & Component | Vitest + MSW | All business logic, React components, accessibility |
| API Contract | Schemathesis | Generated from FastAPI OpenAPI schema |
| RLS isolation | pgTAP | Supabase table policies |
| E2E (critical flows) | Playwright + MCP AI agents | 10-15 journeys across web |
| AI evaluation | DeepEval + RAGAS + AgentAssay | Accuracy, hallucination, non-determinism |
| Load | k6 | Performance under sustained and peak load |
| Security scanning | AgentProbe, SecureMCP | Adversarial testing, MCP security posture |

### 4.2 CI Pipeline (Full Test Matrix)

The CI pipeline runs on every PR and merge to main:

1. **Type Check:** tsc 6.0 + tsgo 7.0
2. **Lint:** eslint
3. **Unit Tests:** test:unit (Vitest, coverage ≥80%)
4. **Component Tests:** test:component (Vitest, coverage ≥85%, axe-core checks)
5. **RLS Tests:** test:rls (pgTAP)
6. **E2E Tests:** test:e2e (Playwright)
7. **Prisma Drift Check:** prisma:drift
8. **Code Generation Check:** orval:codegen (integrity hash)
9. **Docker Build:** docker:build
10. **Contract Tests:** schemathesis (PR and main post-deploy)
11. **AI Evaluation:** deepeval + AgentAssay (nightly for main, blocking for release branches)

### 4.3 Playwright AI Agents (MCP)

Playwright's planner, generator, and healer agents are used to:
- Auto-generate test scenarios from user stories
- Self-heal locators based on accessibility tree snapshots
- Reduce maintenance effort

*See [70-TESTING-BENCHMARKS.md](70-TESTING-BENCHMARKS.md) for detailed effectiveness metrics, cost optimization, and CI integration patterns.*

### 4.4 Mock & Service Virtualization

- **MSW** handlers auto-generated from OpenAPI spec
- 429 rate-limit factory for resilience tests
- SSE mock pattern for streaming endpoints
- All external services (Nylas, Stripe, Supabase, LiteLLM) are mocked at integration level, connected only in E2E and staging

### 4.5 Automated Blocking Gates

| Gate | Purpose | Location in CI | Failure Action |
|---|---|---|---|
| Orval Integrity Hash | Prevent mismatched generated client | `orval:codegen` step | Fail PR |
| LiteLLM Provenance (cosign) | Verify Docker image signature | `docker:build` | Block deployment |
| MCP Inspector Exposure | CVE-2025-49596 mitigation | Security integration test | Block deployment |
| MCP Security Posture (L2) | Production MCP servers must be L2 compliant | CI step on release | Fail release |
| Grant Expiration Simulation | Ensure webhook triggers re-auth flow | Scheduled integration test | Alert, manual fix |
| RLS Policy Check | Mandatory for all new tables | `test:rls` (pgTAP) | Fail PR |

### 4.6 Database Testing (pgTAP)

**Coverage Requirements:**
- All tables in exposed schemas must have RLS enabled
- RLS policies tested with multiple user contexts (owner, member, anon, service_role)
- Policy logic verified for both allow and deny scenarios
- Cross-tenant isolation validated (no data leakage between tenants)

*See [70-TESTING-BENCHMARKS.md](70-TESTING-BENCHMARKS.md) for detailed RLS test coverage patterns and pg_prove automation effectiveness.*

### 4.7 Drift Detection

**Drift Detection Blocking Procedures:**
1. **Pre-deployment check:** Run drift detection as part of CI pipeline before deployment
2. **Exit code handling:** Use exit codes to block deployment when drift detected
3. **Issue tracking:** Create GitHub Issues for drift reports, close when resolved
4. **Scheduled checks:** Run drift detection weekly even when no code changes committed
5. **Severity-based blocking:** Block deployment for critical drift (tables, columns), warn for non-critical

*See [70-TESTING-BENCHMARKS.md](70-TESTING-BENCHMARKS.md) for detailed drift detection approaches and tool comparisons.*

### 4.8 OpenAPI Code Generation (Orval)

**Recommendations:**
- Validate OpenAPI specs with external tools (IBM OpenAPI Validator, spectral) before Orval codegen
- Consider `@hey-api/openapi-ts` for new projects if mock generation is not required
- If using Orval with Zod schemas in split mode, implement post-processing workarounds for known bugs
- Use Orval primarily for MSW mock generation where it remains strong

*See [70-TESTING-BENCHMARKS.md](70-TESTING-BENCHMARKS.md) for detailed Orval code generation accuracy, mock generation quality, and schema validation effectiveness.*

### 4.9 Gate Configuration (Threshold Calibration)

**Best Practices for Threshold Setting:**
- **Clear, realistic, enforceable:** Thresholds must be clearly defined, realistically achievable, and aligned with business needs. Document the rationale for each threshold.
- **Automated enforcement:** Automate quality gates so failed gates automatically block merges or deployments. This ensures discipline in maintaining standards.
- **Feedback loops:** When gates fail, developers should receive clear, actionable information about what went wrong and how to fix it. Poor observability makes troubleshooting gate failures difficult.

### 4.10 Override Controls (Abuse Prevention with Audit Logs)

**Audit Trail Best Practices:**
- **Immutable logs:** Store logs in write-once, read-many (WORM) storage to prevent tampering.
- **Timestamp synchronization:** Synchronize timestamps across all systems for accurate event correlation.
- **Unique identifiers:** Assign unique identifiers to every component (pipelines, agents, deployments) for traceability.
- **Retention periods:** Store logs securely for required retention periods (e.g., 1-7 years depending on compliance requirements).
- **Regular audit completeness testing:** Verify log completeness, sequence continuity, and timestamp consistency on a regular basis.
- **Compliance mapping:** Map logged events to compliance controls for regulatory requirements (SOC 2, HIPAA, ISO 27001).

### 4.11 Adoption (Adoption Metrics with Best Practices)

**Adoption Best Practices:**
- **Start small and scale gradually:** Begin with essential gates (e.g., passing tests, basic code coverage) and build upon them as the process progresses. Don't attempt to implement all gates at once.
- **Communicate and train:** Ensure developers understand the purpose and importance of each quality gate. Provide proper training and feedback when gates fail. Cultural resistance often stems from lack of understanding or involvement in implementation.
- **Balance speed and quality:** Gates should ensure quality without hindering progress. Overly strict gates can slow delivery and frustrate developers, creating bottlenecks that negate CI/CD velocity benefits.
- **Customize per project maturity:** Not all projects require the same gates or thresholds. Customize based on team maturity, compliance needs, and criticality. Very Small Entities (VSEs) face resource constraints and need simplified platforms adapted to their scale.
- **Automate everything:** Minimize manual checks whenever possible and automate quality gates for consistency and scalability.
- **Monitor and review:** Continuously track quality gates to ensure they serve their intended purpose. Update threshold limits as codebases, processes, and technologies evolve.
- **Connect metrics to business outcomes:** Share insights on CI metrics across development, QA, management, and leadership. Help teams understand how metrics contribute to business values like customer satisfaction and time to market.

---

## 5. Test Environment & Infrastructure

### 5.1 Environment Topology

| Environment | Purpose | Key Services | Test Data |
|---|---|---|---|
| Local | Developer testing | Ollama, SQLite, Vitest, MSW | Synthetic, golden datasets |
| CI | Automated test suite | GitHub Actions runners, mocked services | Contract-driven mocks |
| Staging | Integration, E2E, load | Supabase, Fly.io (FastAPI), Vercel (web), LiveKit, Upstash, Nylas sandbox | Anonymised production snapshots |
| Production-like | Performance, DR | Mirrors production (active-passive) | Read-only anonymised copy |
| Production | Monitoring & trace-first AI analysis | Full stack | Production traffic (no test writes) |

### 5.2 Test Data Management

- Golden datasets stored in versioned, encrypted object storage.
- Anonymisation performed by a reviewed pipeline; no PII reaches non-production environments.
- Synthetic data generated for edge cases via faker-based scripts, integrated into MSW handlers.

### 5.3 Contract Testing

#### Schemathesis Limitations for Real-Time Protocols

- **Schemathesis only supports HTTP REST (OpenAPI) and GraphQL schemas** - it does NOT support WebSocket or Server-Sent Events (SSE) protocols
- Designed for synchronous, request-response APIs; OpenAPI Specification 3.0 excels at documenting synchronous APIs but was not designed with WebSockets in mind
- SSE/WebSocket endpoints must be listed in an ignore file for Schemathesis to skip them
- Testing challenges for real-time protocols: state management (persistent connections), event ordering (unpredictable sequences under load), connection lifecycle (establishment, exchange, error handling, disconnection), concurrency (race conditions with multiple clients)

#### Recommended Strategy

- Use **Schemathesis** for HTTP REST (OpenAPI) and GraphQL contract testing
- Use **Microcks** for WebSocket and SSE contract testing via AsyncAPI specifications
- SSE endpoints can be tested as HTTP streaming endpoints with Schemathesis if they follow standard HTTP patterns, but full SSE protocol validation requires AsyncAPI-based tools
- Contract test failures block PRs and trigger automatic API documentation updates

*See [70-TESTING-BENCHMARKS.md](70-TESTING-BENCHMARKS.md) for detailed alternative contract testing tools for real-time endpoints.*

### 5.4 Offline Sync Test Scenarios

The following scenarios are automated and run on PowerSync-enabled environments:
- **Create-while-offline:** Mobile (Expo) creates a calendar event offline; after sync, event appears on web.
- **Concurrent edit conflict:** Both devices modify the same project deadline offline; conflict resolution (timestamp-based) ensures convergence.
- **Tombstone replay:** Deleting an item offline and syncing correctly removes it from server.
- **Network interruption:** Repeated disconnection and reconnection does not duplicate data.

---

## 6. Security & Compliance Testing

### 6.1 OWASP & ASI Risk Mapping

The following ASI threat categories are mapped to test scenarios and guardrail layers:

| ASI Code | Threat | Mitigation | Test Approach |
|---|---|---|---|
| ASI01 | Goal Hijack | Input/output guardrails, intent capsule | Validation of refusal behaviour against jailbreak prompts |
| ASI02 | Tool Misuse | MCP OAuth, schema allowlist | Tool authorisation integration tests |
| ASI03 | Identity Abuse | Nylas Health Service, Agent Passports | Auth flow simulation, token replay tests |
| ASI04 | Poison | Input guardrails, vector DB quarantine | Content safety probes, alert verification |
| ... | ... | ... | ... |

Full OWASP Top 10 for LLM (2025) and MCP Top 10 mapping is maintained in the security runbook; every item is linked to at least one automated or manual test case.

*See [70-TESTING-BENCHMARKS.md](70-TESTING-BENCHMARKS.md) for detailed CVE mapping, ASI coverage analysis, and automated CVE mapping update processes.*

### 6.2 MCP Security Testing

- **MCPSec L2 compliance** verified for all production servers (CI gate).
- **MCP Inspector exposure** prevented (integration test for 0.0.0.0 binding).
- **Adversarial testing** with AgentProbe (134 attack vectors) on every MCP server release.
- **SecureMCP** audits: OAuth token leakage, prompt injection, rogue server detection.

### 6.3 Grant & Auth Webhook Testing

- Simulate Nylas grant expiration; confirm webhook fires, re-auth UI appears, and sync resumes without data loss.
- Test with revoked tokens at various stages of an active workflow.

### 6.4 Data Sovereignty & Privacy

- **Local Ollama processing:** Integration test confirms that during local-first mode, no data leaves the device (network inspection).
- **RLS isolation:** Mandatory pgTAP tests for every table; no data cross-tenant leakage.

### 6.5 Compliance Automation (Vanta)

- Vanta monitors cloud, identity, and code repos for SOC 2 controls.
- Automated evidence collection: test pass/fail logs, coverage reports, AI evaluation results.
- EU AI Act readiness tracker (deadlines: stand-alone high-risk 2 Dec 2027, embedded 2 Aug 2028).
- Singapore AI framework: decision log maintained.

### 6.6 AI Bill of Materials (AIBOM)

- CycloneDX for each model, including training data provenance, safety evaluation reference (AIBOM04), and model lineage.
- AIBOM updated on model change; checked in CI as part of security gate.

---

## 7. Migration & Technology Transition Testing

### 7.1 OpenAI Responses API Migration (ADR_103)

**Deadline:** 26 Aug 2026 (Assistants API shutdown)
**Target migration:** July 2026

#### Scope

- Migrate from Assistants API to Responses API + Conversations API.
- Mapping: Assistants → Prompts, Threads → Conversations, Runs → Responses, Run steps → Items.

#### Testing Requirements

- Feature parity: all existing AI flows (chat, conflict detection, agent actions) must pass with ≤5% divergence in accuracy, latency, and token usage.
- Tool calling compatibility: custom functions, MCP tools, web search, code interpreter.
- Multimodal support (text + images) and stateful context (`store: true`).
- Backfill script: validate thread-to-conversation transformation, role mapping, image URL handling.
- Strict mode behavior change verification.

#### Pre-Migration Gate

- All critical AI flows documented and passing.
- Backfill script tested on sample data.
- Feature parity checklist completed.

#### Post-Migration Gate

- All AI flows pass with Responses API.
- No regression beyond defined thresholds (acc ≥base-2%, latency ≤base+10% warn, ≤base+20% block).
- Historical threads backfilled successfully.

### 7.2 TypeScript 6.0 & 7.0

- CI upgrade to TypeScript 6.0; enforce `erasableSyntaxOnly`.
- tsgo 7.0 evaluated in parallel; break on configuration drift.
- No regression in build or type-check performance.

### 7.3 React 20 Compiler

- Component tests run with React 20 Compiler enabled.
- Verify "use no memo" directives remain effective; performance benchmarks show no regression.

### 7.4 Claude 4.6 Compatibility

- Run all test prompts through Claude 4.6; compare output parity with previous model (max 5% divergence in accuracy score).
- Latency and token usage compared against baseline.

### 7.5 Temporal Safari Testing

- E2E test specifically on Safari, confirming Temporal polyfill activates and wall-clock handling is correct.

---

## 8. Performance, Load & Observability

### 8.1 Performance Benchmarks

| Metric | Threshold |
|---|---|
| TTFT (Time to First Token) | ≤ 2 s p95 |
| Availability | ≥ 99.9% |
| LCP (Largest Contentful Paint) | ≤ 800 ms p75 |
| INP (Interaction to Next Paint) | ≤ 200 ms |
| Error rate | < 0.1% of requests |

### 8.2 Load Testing Profiles

| Profile | Target | Duration | Goal |
|---|---|---|---|
| Baseline | 200 req/s | 10 min | Measure steady-state performance |
| Sustained load | 1000 req/s | 1 hour | Validate system under expected peak |
| Stress | 200% of sustained (2000 req/s) | 2 hours | Identify breaking points and recovery |
| Soak | 800 req/s | 24 hours | Detect memory leaks and resource exhaustion |

Endpoints stressed: conflict detection API, chat completion, offline sync operations, and notification fan-out.

### 8.3 AI Cost Observability Tests

- Token counts from provider APIs are compared with internal tracking (within 2%).
- Alert thresholds: at 15%, 5%, and 0% of budget, alerts are triggered in all channels.
- Hard limit: when budget reaches 0%, API calls are rejected; test verifies graceful degradation.

### 8.4 Monitoring & Rollback

- OpenTelemetry traces for all critical transactions.
- Sentry for error tracking, PostHog for product analytics.
- Automated rollback if error rate exceeds 1% or AI quality gates drop below pass threshold for 5 continuous minutes.

---

## 9. Traceability, Reporting & Release Decisions

### 9.1 Requirement-Test Traceability

A traceability matrix connects each feature (J001, J002, etc.) to its test cases (QA_C). This is maintained in the test management tool (to be integrated). Placeholder:

| Feature ID | Feature | Test Case IDs | Status |
|---|---|---|---|
| J001 | Cross-app conflict detection | QA_C-001 to QA_C-005 | Automated |
| J002 | Unified chat assistant | QA_C-010 to QA_C-020 | Automated |
| ... | ... | ... | ... |

### 9.2 Defect Triage & Handoff Workflow

1. **Automated gate block** → CI fails, links to failing test and evidence.
2. **QA reviews** → classifies as defect or environment flake.
3. **If defect:** severity assigned, bug report filed (Appendix B), handoff to responsible team (TL/PM/FSE/MOB as per RACI).
4. **AgentAssay Inconclusive:** manual review with human evaluation; if pass, override recorded in audit log; if fail, follow defect flow.
5. **Release decision:** all BLOCK gates must pass; WARN gates reviewed; inconclusives must have documented justification.

### 9.3 Release Criteria Checklist

- [ ] All CI jobs green (unit, component, integration, RLS, E2E, contract, codegen, Docker)
- [ ] AI quality gates pass (or inconclusive with approved override)
- [ ] Performance benchmarks within thresholds
- [ ] Security scans clean (OWASP, MCP posture, AgentProbe)
- [ ] Accessibility: zero critical violations
- [ ] Compliance evidence synced to Vanta
- [ ] Cost tracking alerts functional
- [ ] Offline sync scenarios pass

---

## Appendices

### A. Test Case Template (QA_C / QA_E / QA_A)

```
QA_C: [Scenario] - [Brief description]
QA_E: [Expected behaviour, with specific outputs or states]
QA_A: [To be filled during execution]
conf: [H/M/L]  (confidence in requirement stability)
handoff: [TL, PM, FSE, MOB]
```

### B. Bug Report Template

```
Title: [Component] - Concise summary
Severity: Blocker / Critical / Major / Minor
Environment: [e.g., web Vite Spa, Chrome 130]
Reproduction steps:
1. ...
2. ...
Actual result: ...
Expected result: ...
Attachments: [screenshots, HAR, video]
AI-specific data: model version, prompt, token counts
Conf: H | QA_A: Failed
Handoff: [role]
```

### C. Live Coverage Dashboard

Current per-module coverage percentages are maintained in the dynamic test status dashboard (link to Grafana or internal tool), not in this static plan. The dashboard is refreshed on every CI run.

### D. Glossary

- **ASI:** AI Security Incident (08-10 threat categories)
- **MCP:** Model Context Protocol
- **SPRT:** Sequential Probability Ratio Test
- **RAGAS:** Retrieval Augmented Generation Assessment
- **AIBOM:** AI Bill of Materials
- **TTFT:** Time to First Token

---

*End of document.*
