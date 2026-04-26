Below is the complete, unabridged **Master Test & Quality Plan** for the AI-integrated workspace platform. It reorganises all your existing content into the structure we aligned on, fills the identified gaps, and presents everything in the formats most useful for your cross‑functional team.

---

# AI Workspace Platform — Master Test & Quality Plan

**Document version:** 1.0  
**Last updated:** April 2026  
**Owner:** QA (R1)  
**Handoff roles:** TL, PM, FSE, MOB

---

## 1. Introduction & Quality Vision

### 1.1 Product Mission
The AI‑integrated workspace platform provides a dashboard to monitor, interact with, and control AI agents; a feature‑rich chat interface; and a suite of productivity applications (Calendar, Projects, Email, etc.) where both users and AI agents can create, read, update, and delete data. Its core innovation is cross‑application, context‑aware AI assistance that proactively surfaces conflicts and suggests actions.

### 1.2 Quality Pillars
All testing and quality assurance activities support four pillars:

- **Correctness & Accuracy** – The system behaves as specified; AI outputs are factual and relevant.
- **Reliability & Resilience** – The service is available, performant, and consistent, even under load or during offline operation.
- **Security & Privacy** – User data is protected, guardrails prevent misuse, and we comply with SOC 2, the EU AI Act, and NIS2.
- **Accessibility** – All user‑facing interfaces meet WCAG 2.2 AA, with zero critical violations.

### 1.3 Roles & Responsibilities (RACI Matrix)

| Activity | QA (Lead) | Dev (TL) | PM | Security (FSE) | Mobile (MOB) |
|---|---|---|---|---|---|
| Test plan & strategy | A | C | I | C | C |
| Unit / component test design | R | A | I | I | I |
| Integration / E2E test execution | A | C | I | C | C |
| AI evaluation & quality gates | A | C | I | – | – |
| Security testing & guardrails | C | C | I | A | I |
| Performance & load testing | A | C | – | – | – |
| Offline sync testing | A | C | – | – | A |
| Compliance evidence collection | C | C | I | A | – |
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
| **Minor defect** | Cosmetic or edge‑case issue. |

Test cases follow the **QA_C / QA_E / QA_A** format (see Appendix A). Bug reports follow the template in Appendix B.

---

## 2. Test Scope & Strategy

### 2.1 Scope
All product modules and cross‑cutting concerns are in scope. The list below shows the modules, their primary quality risks, and the test depth assigned.

**Core modules:** Foundation, Dashboard, Chat, Workflows, Projects  
**Feature modules:** Calendar, Email, Contacts, Conference, Translation, News, Documents, Research, Media, Budget, Settings, Platform  
**Cross‑cutting:** Offline sync (PowerSync), guardrails, AI cost tracking, MCP security, accessibility

### 2.2 Risk‑Based Testing Matrix

| Module | Technical Risk (complexity, AI reliance) | Business Impact | Test Depth |
|---|---|---|---|
| Foundation | High | Critical (shared core) | Deep: unit ≥95%, component ≥85%, integration ≥90% |
| Dashboard | Medium | Critical (agent fleet mgmt) | Deep |
| Chat | High (AI, real‑time) | Critical (J002) | Deep + AI evaluation |
| Workflows | High (canvas, state machines) | High | Standard |
| Projects | Medium | High (J001 conflict detection) | Standard + integration |
| Calendar | Medium (recurrence, timezone) | High | Standard |
| Email | Medium (third‑party integration) | High | Standard + integration |
| Contacts | Low | Medium | Standard |
| Conference | Medium (LiveKit) | Medium | Standard + integration |
| Translation | Medium (real‑time AI) | Medium | Standard + AI evaluation |
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
| Component | Vitest, MSW, axe‑core | QA, Dev | React components, state, accessibility |
| Integration | Vitest, Supertest, pgTAP | QA | API endpoints, database RLS, cross‑module interactions |
| E2E critical flows | Playwright, AI agents | QA | 10–15 user journeys in production‑like environment |
| AI evaluation | DeepEval + RAGAS, AgentAssay | QA + Data Science | Accuracy, hallucination, non‑determinism |
| Security | Schemathesis, pgTAP, AgentProbe, manual | Security (FSE) + QA | API contract, RLS, adversarial testing |
| Performance & load | k6, OpenTelemetry | QA / DevOps | Throughput, latency, cost tracking |

---

## 3. AI‑Specific Testing Approach

### 3.1 Non‑Determinism & the AgentAssay Framework
Traditional binary pass/fail tests are inadequate for stochastic AI agents. We adopt the **AgentAssay** framework, which uses:

- **Three‑valued verdicts:** Pass, Fail, Inconclusive (confidence interval straddles threshold)
- **Sequential Probability Ratio Test (SPRT):** reduces trials by 78% compared to fixed‑n =100
- **Behavioral fingerprinting:** compresses tool sequences, state transitions, and decision patterns to detect regressions with 86% power (vs 0% for pass‑rate tests)
- **Trace‑first offline analysis:** uses production traces to achieve 98% detection power at zero additional token cost
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
| Max wall‑clock time (t_max) | 10 min |

Exit codes: 0=deploy, 1=block, 2=manual/inconclusive

Override procedures: inconclusive results require manual review with audit trail; exit code 2 may be treated as warning per team decision.

### 3.2 Evaluation Framework (DeepEval + RAGAS)
- **LLM‑as‑judge** through LiteLLM proxy, evaluating accuracy, relevancy, faithfulness, and hallucination.
- **Metrics tracked:**
  - FActScore (factual precision)
  - HallucinationRate
  - AnswerRelevancy
  - ToolPrecision
  - BLEU/ROUGE for translation tasks
- **LLM‑as‑judge best practices:**
  - Use pairwise comparison when possible
  - Pointwise scoring with grading rubrics and few‑shot examples
  - Chain‑of‑thought prompting
  - Low temperature (0.1) for determinism
  - Combine with code‑based judges and human spot‑checks
- **Documented biases** (NeurIPS 2024, IJCNLP 2025) are mitigated through rubrics, position swapping, and multi‑judge consensus on critical evaluations.

#### DeepEval vs RAGAS Accuracy Comparison (Dec 2025 Benchmark)

**Source:** AIMMultiple RAG Evaluation Tools Benchmark (Dec 2025), 1,010 samples (HaluEval 480 + HotPotQA 530), GPT-4o as judge with temperature=0

**Key Findings:**
- **Top-1 Accuracy:** WandB (94.5%), TruLens, and Ragas are statistically tied with 95% CI overlapping between 94.0% and 98.0%
- **DeepEval limitation:** Under-scores golden contexts at mean 0.46 vs 0.82-0.91 for other tools, making it unreliable for identifying the single best context
- **Ragas advantage:** Dual-judge averaging with 5 possible output values (0.0, 0.25, 0.5, 0.75, 1.0) provides built-in resistance to prompt sensitivity
- **DeepEval approach:** Statement decomposition (G-Eval) produces continuous scores but is strict, penalizing contexts with off-topic sentences

**Scoring Method Comparison:**
- **WandB:** Binary LLM prompt (0 or 1) - highest Top-1 accuracy but cannot express degrees of relevance
- **TruLens:** 4-point Likert scale (0.0, 0.33, 0.67, 1.0) - highest NDCG@5 (0.932) and Spearman ρ (0.750)
- **Ragas:** Dual-judge averaging - two independent judges with different phrasing, averaged for 5 output values
- **DeepEval:** Statement decomposition - continuous 0.0-1.0 score based on relevant statement ratio

**Recommendation:** Use Ragas for RAG evaluation due to dual-judge bias resistance and competitive accuracy. DeepEval's strict scoring makes it less suitable for single-best-context identification tasks.

#### LLM-as-Judge Bias Validation via LiteLLM Proxy

**Research Finding:** TASK INFORMATION INCORRECT. LiteLLM proxy does NOT provide built-in bias detection or validation capabilities for LLM-as-judge systems.

**LiteLLM Capabilities:**
- **Model Compare Playground UI:** Side-by-side comparison of up to 3 models with metrics (latency, token usage, cost)
- **A/B Testing:** Traffic mirroring to secondary (silent) model for evaluation purposes
- **Budget Control:** Per-key, per-user, per-team budgets with `max_budget` and `budget_duration`
- **Rate Limiting:** TPM, RPM, and max parallel request limits
- **Spend Tracking:** Response header `x-litellm-response-cost`, `LiteLLM_SpendLogs` table

**What LiteLLM Does NOT Provide:**
- No built-in bias detection algorithms
- No position bias validation (A,B vs B,A ordering)
- No verbosity bias mitigation
- No self-enhancement bias detection
- No multi-judge consensus mechanisms

**Actual Bias Mitigation Strategies (External to LiteLLM):**
- **Position bias (~40% GPT-4 inconsistency):** Evaluate both (A,B) and (B,A) orderings; only count consistent wins
- **Verbosity bias (~15% inflation):** Use 1-4 scales, reward conciseness explicitly
- **Self-enhancement bias (5-7% boost):** Use different model families as judges
- **LLM jury approach:** Run 3-5 models (GPT-4, Claude, Llama-3) with majority vote for critical evaluations, reduces biases 30-40% but costs 3-5x more

**Updated Documentation:** LiteLLM proxy is used for cost tracking, budgeting, and model comparison, but bias validation requires external implementation using the strategies above. The task assumption that LiteLLM can validate LLM-as-judge bias is incorrect.

#### Cost Effectiveness of LLM-as-Judge vs Traditional Testing

**Source:** Label Your Data (2026), Evidently AI (2026), industry benchmarks

**Cost Comparison:**
- **LLM-as-judge:** $0.03-0.10 per evaluation
- **Human review:** $5-15 per evaluation (varies by domain expertise)
- **At 10,000 monthly evaluations:** LLM judges save $50,000-100,000 vs. human review while maintaining 80% agreement

**Cost-Benefit Analysis:**
- **Scale advantage:** Evaluating 1000+ outputs regularly where human review is cost-prohibitive
- **Speed advantage:** Rapid iteration cycles (80% agreement acceptable vs. perfect human review)
- **Semantic assessment:** Tone, helpfulness, paraphrases that traditional metrics miss

**When to Use LLM Judges:**
- Scale: evaluating 1000+ outputs regularly
- Semantic assessment: tone, helpfulness, paraphrases
- Speed: rapid iteration cycles

**When to Keep Humans in Loop:**
- High-stakes domains (legal, medical, safety-critical)
- Specialized expertise requirements where judges hallucinate
- Frontier model evaluation (judging models at/beyond judge capability)
- Bias measurement (judge's own biases skew results)

**When to Use Simpler Approaches:**
- Deterministic checks (format validation, keyword presence)
- Exact matching tasks (calculations, schema validation)
- Real-time requirements <50ms (use specialized classifiers)

**Recommendation:** Use LLM-as-judge for large-scale semantic evaluation where 80% human agreement is acceptable. Reserve human review for high-stakes decisions and bias measurement. Use deterministic code-based checks for simple validation tasks.

### 3.3 Golden Dataset Strategy
- For modest features: 10‑20 curated examples
- For complex use cases (e.g., conflict detection, chat): 100‑200 examples
- Datasets are versioned, refreshed quarterly or after major model updates
- Stored alongside the test code, with provenance tracked in CycloneDX AIBOM

### 3.4 AI Quality Gates (Single Source of Truth)

| Metric | Pass Threshold | Warning | Block |
|---|---|---|---|
| Accuracy (vs baseline) | ≥ base − 2% | – | < base − 2% |
| Latency | ≤ base + 10% | > base + 10% | > base + 20% |
| Token usage | ≤ base + 15% | > base + 15% | – |
| Tool precision | ≥ 90% | – | < 85% |
| Hallucination rate | ≤ 2% | – | > 2% |

All gates are evaluated per scenario, averaged over 3 runs, and enforced in CI. Manual review required for any block before deployment.

### 3.5 AI Cost Tracking Tests
- Validate token‑meter accuracy vs provider billing (expect <2% variance)
- Verify real‑time cost dashboard updates
- Confirm alerts fire at organisation, team, and user budget thresholds (15%, 5%, 0%)
- Hard‑limit enforcement: when budget is exhausted, AI calls are rejected

---

## 4. Test Automation Strategy

### 4.1 Tool‑Layer Assignment

| Test Layer | Tool | Scope |
|---|---|---|
| Unit & Component | Vitest + MSW | All business logic, React components, accessibility |
| API Contract | Schemathesis | Generated from FastAPI OpenAPI schema |
| RLS isolation | pgTAP | Supabase table policies |
| E2E (critical flows) | Playwright + MCP AI agents | 10–15 journeys across web |
| AI evaluation | DeepEval + RAGAS + AgentAssay | Accuracy, hallucination, non‑determinism |
| Load | k6 | Performance under sustained and peak load |
| Security scanning | AgentProbe, SecureMCP | Adversarial testing, MCP security posture |

### 4.2 CI Pipeline (Full Test Matrix)

The CI pipeline runs on every PR and merge to main:

1. **Type Check:** tsc 6.0 + tsgo 7.0
2. **Lint:** eslint
3. **Unit Tests:** test:unit (Vitest, coverage ≥80%)
4. **Component Tests:** test:component (Vitest, coverage ≥85%, axe‑core checks)
5. **RLS Tests:** test:rls (pgTAP)
6. **E2E Tests:** test:e2e (Playwright)
7. **Prisma Drift Check:** prisma:drift
8. **Code Generation Check:** orval:codegen (integrity hash)
9. **Docker Build:** docker:build
10. **Contract Tests:** schemathesis (PR and main post‑deploy)
11. **AI Evaluation:** deepeval + AgentAssay (nightly for main, blocking for release branches)

### 4.3 Playwright AI Agents (MCP)
Playwright’s planner, generator, and healer agents are used to:
- Auto‑generate test scenarios from user stories
- Self‑heal locators based on accessibility tree snapshots
- Reduce maintenance effort

#### Effectiveness Metrics
- **Token efficiency**: Playwright CLI uses ~27K tokens per task vs ~114K tokens with MCP (4x reduction). CLI saves snapshots to disk instead of streaming full accessibility tree in tool responses.
- **Agent workflow**: Planner explores app and creates structured markdown test plans; Generator converts plans to executable Playwright tests with production-grade locators; Healer diagnoses and fixes failing tests by replaying in debug mode, inspecting console logs/network/page snapshots.
- **Success factors**: Agents use Model Context Protocol (MCP) to connect LLM with real browser, making decisions based on live DOM state rather than guessing from screenshots.
- **Limitations**: Context window limits on long flows (50+ steps can exceed LLM capacity), model variance (identical requests produce different assertion styles/variable names), TypeScript/JavaScript only (no Python support yet), selectors aren't always right (text locators break when copy changes), complex UI changes need human intervention, business logic gaps (healer handles selector failures but struggles with backend changes/API contract shifts/feature flags).
- **Cost per action**: Rough token costs per agent action vary by model. For a team running 200 PRs/week with healing on every run: $10-20/week in LLM costs. Smart approach: use agents for new feature coverage and initial test generation; use traditional test authoring for business-critical paths; run healer on weekly schedule rather than every PR.

#### Cost Optimization via LiteLLM Proxy
- **Budget control**: LiteLLM proxy supports per-key, per-user, per-team, and per-customer budgets with `max_budget` and `budget_duration` (e.g., "30s", "30m", "30d"). Budgets reset automatically; default check interval is 10 minutes (configurable via `proxy_budget_rescheduler_min_time` and `proxy_budget_rescheduler_max_time`).
- **Rate limiting**: TPM (tokens per minute), RPM (requests per minute), and max parallel request limits can be set per key or team. Budget/rate limit tiers can be created and assigned to keys for structured access control.
- **Spend tracking**: LiteLLM tracks spend per user/team with response header `x-litellm-response-cost` and stores logs in `LiteLLM_SpendLogs` table. Enterprise features include spend reports, daily breakdown API, and custom tags for granular tracking.
- **Cost tracking integration**: Playwright agent LLM calls routed through LiteLLM proxy with user/team tags. Cost alerts at 15%, 5%, and 0% of budget thresholds. Hard limit enforcement when budget exhausted (API calls rejected).
- **Optimization strategies**: Use Playwright CLI instead of MCP when agent has filesystem access (4x token savings). Use `includeSnapshot: false` to reduce token consumption. Run headless in CI. Minimize navigation steps. Batch agent runs (healer only on failing tests, not entire suite).

#### CI Integration Patterns for Planner/Generator/Healer
- **Standard CI workflow**: Agents themselves are interactive tools for VS Code Copilot/Claude Code/OpenCode, but generated tests are standard Playwright tests that run in CI like any other suite. GitHub Actions workflow: checkout → setup-node → npm ci → playwright install --with-deps → playwright test → upload artifact (with `if: always()` to save failed test reports).
- **Multi-agent orchestration**: 2026 pattern runs specialized agents in parallel (Functional Agent for happy path, Security Agent for XSS/auth bypass, Accessibility Agent for WCAG, Performance Agent for Core Web Vitals). Uses Observer-Driver pattern: Driver Agents own write-actions/state transitions (only one per flow to prevent conflicts); Observer Agents run asynchronously to perform specialized audits without disrupting execution.
- **Agent orchestration in CI**: Dedicated CI workers for agent operations to avoid impacting test speed. Planner/Generator run during development or on feature branches; Healer runs on failed tests during nightly builds or on-demand. Agent traces logged for debugging and compliance (EU AI Act requires audit trail of agent reasoning).
- **Integration with ADR_123**: Playwright agents configured with LiteLLM proxy for cost tracking. Agent definitions stored in `.github/` and regenerated when Playwright is updated. CI gate validates agent-generated test stability before merging.

Token consumption is monitored; agents are used on dedicated CI workers to avoid impacting test speed.

### 4.4 Mock & Service Virtualization
- **MSW** handlers auto‑generated from OpenAPI spec
- 429 rate‑limit factory for resilience tests
- SSE mock pattern for streaming endpoints
- All external services (Nylas, Stripe, Supabase, LiteLLM) are mocked at integration level, connected only in E2E and staging

### 4.5 Automated Blocking Gates

| Gate | Purpose | Location in CI | Failure Action |
|---|---|---|---|
| Orval Integrity Hash | Prevent mismatched generated client | `orval:codegen` step | Fail PR |
| LiteLLM Provenance (cosign) | Verify Docker image signature | `docker:build` | Block deployment |
| MCP Inspector Exposure | CVE‑2025‑49596 mitigation | Security integration test | Block deployment |
| MCP Security Posture (L2) | Production MCP servers must be L2 compliant | CI step on release | Fail release |
| Grant Expiration Simulation | Ensure webhook triggers re‑auth flow | Scheduled integration test | Alert, manual fix |
| RLS Policy Check | Mandatory for all new tables | `test:rls` (pgTAP) | Fail PR |

### 4.6 Database Testing (pgTAP)

#### RLS Test Coverage Patterns

**Source:** supabase-test-helpers (usebasejump/supabase-test-helpers), PostgreSQL documentation, industry best practices

**Key Findings:**
- **supabase-test-helpers library** provides comprehensive pgTAP functions for RLS testing
- `tests.rls_enabled(testing_schema text)` - pgTAP function to check if RLS is enabled on all tables in a provided schema
- `tests.rls_enabled(testing_schema text, testing_table text)` - pgTAP function to check if RLS is enabled on a specific table
- **Authentication helpers** for testing RLS policies with different user contexts:
  - `tests.create_supabase_user(identifier text, email text, phone text)` - Creates test users in auth.users table
  - `tests.authenticate_as(identifier text)` - Authenticates as a specific test user
  - `tests.authenticate_as_service_role()` - Authenticates as service role (bypasses RLS)
  - `tests.clear_authentication()` - Clears authentication and sets role to anon
  - `tests.get_supabase_user(identifier text)` - Returns user info for test users
  - `tests.get_supabase_uid(identifier text)` - Returns user UUID for test users

**Test Pattern Example:**
```sql
BEGIN;
SELECT plan(1);
-- Check RLS is enabled on all tables in public schema
SELECT tests.rls_enabled('public');
SELECT * FROM finish();
ROLLBACK;
```

**Authentication Context Testing:**
```sql
-- Create test user and authenticate as them
SELECT tests.create_supabase_user('test_owner');
SELECT tests.authenticate_as('test_owner');
-- Run RLS policy tests
SELECT tests.clear_authentication();
```

**Coverage Requirements:**
- All tables in exposed schemas must have RLS enabled
- RLS policies tested with multiple user contexts (owner, member, anon, service_role)
- Policy logic verified for both allow and deny scenarios
- Cross-tenant isolation validated (no data leakage between tenants)

### 4.7 Automation (pg_prove)

**Source:** pgTAP documentation (pgtap.org), Capital One engineering blog, End Point Dev blog

**Key Findings:**
- **pg_prove** is the command-line tool for running pgTAP tests in bulk with a single command
- Processes TAP output using TAP::Harness to summarize test results
- **Highly effective for automation** with CI/CD integration capabilities
- Supports two test formats:
  - **SQL scripts**: Files containing TAP-emitting SQL statements
  - **xUnit Test Functions**: Database functions that return SETOF TEXT with pgTAP function results

**Automation Effectiveness:**
- **Capital One production use**: pgTAP tests ensure database validation, proactively identifying formatting issues and edge cases
- **Simple, readable code**: pgTAP tests are easy to understand and maintain compared to traditional Perl-based database testing
- **CI/CD integration**: pg_prove simplifies automation of testing, making tests repeatable and reliable
- **Batch execution**: Can run large numbers of tests from a directory with single command
- **Exit codes**: Returns appropriate exit codes for CI gate integration (0=success, non-zero=failure)

**Usage Pattern:**
```bash
# Run all tests in a directory
pg_prove -d mydatabase tests/

# Run specific test file
pg_prove -d mydatabase tests/00-test.sql

# Run xUnit test functions
pg_prove --dbname mydb --schema test --match 'test$' --runtests
```

**CI Integration:**
- Integrates with build processes and continuous integration pipelines
- Provides test counts, success/failure rates, and diagnostic messages
- Output format suitable for CI log parsing and reporting
- Can be combined with other TAP-emitting tests using `prove` command

**Performance:**
- Fast execution: Tests run within transactions, rolled back after completion
- Minimal overhead: Direct database connection, no external dependencies
- Scalable: Handles hundreds of tests efficiently (example: 216 tests in 1 wallclock second)

### 4.8 Drift Detection

**Source:** Liquibase documentation, Atlas monitoring docs, SchemaSmith guide, Firefly CI/CD implementation

**Key Findings:**
- **Drift detection** is critical for preventing schema mismatches between environments
- Multiple approaches exist for automated drift detection with CI/CD blocking

**Liquibase Pro Approach:**
- `liquibase diff --format=json` provides structured list of differences between database schemas
- JSON output can be used to:
  - Count differences and prioritize fixes
  - Halt CI/CD process if critical table/column is in drift report
  - Trigger notifications to team
- **Drift Detection Reports** compare current database state to previous snapshot or target environment
- Integrated into CI/CD pipeline for continuous monitoring

**Atlas Approach:**
- GitHub Actions integration for schema monitoring
- Agent deployment in database VPC or GitHub Action for tracking schema changes
- **Features:**
  - Live visibility with automated ER diagrams
  - Changelog of all schema changes
  - Webhooks or Slack notifications for drift alerts
- Quickstart guides available for GitHub Actions, GitLab CI/CD, BitBucket Pipelines

**SchemaSmith Approach:**
- **State-based drift detection**: Compare live database against declared source of truth (metadata definition in version control)
- Detects drift AND provides path to resolution (tool knows correct state)
- **Detection methods:**
  - Manual comparison (time-consuming, easy to skip)
  - Automated schema comparison (CI-triggered diffs between live databases)
  - State-based detection (against source of truth in version control)
  - Audit trails (DDL triggers, database audit logs)

**Firefly/Terraform Approach:**
- GitHub Actions workflow for Terraform drift detection
- **Exit codes indicate drift status:**
  - Exit code 0 → No changes, everything in sync
  - Exit code 1 → Terraform encountered an error
  - Exit code 2 → Drift detected
- Workflow captures exit code and determines if drift occurred
- **When drift detected (exit code 2):**
  - Create GitHub Issue automatically
  - Alert team for investigation
  - Block deployment until resolved
- **When no drift (exit code 0):**
  - Close previously created GitHub Issues
  - Allow deployment to proceed

**Drift Detection Blocking Procedures:**
1. **Pre-deployment check**: Run drift detection as part of CI pipeline before deployment
2. **Exit code handling**: Use exit codes to block deployment when drift detected
3. **Issue tracking**: Create GitHub Issues for drift reports, close when resolved
4. **Scheduled checks**: Run drift detection weekly even when no code changes committed
5. **Severity-based blocking**: Block deployment for critical drift (tables, columns), warn for non-critical

**Best Practices:**
- Integrate drift detection into CI/CD so every infrastructure update is verified against actual state
- Use state-based detection (compare against version control) rather than just environment-to-environment comparison
- Implement scheduled drift checks (e.g., weekly) to catch changes made outside normal deployment process
- Use structured output (JSON) for programmatic handling of drift reports
- Maintain audit trails for compliance and troubleshooting

### 4.9 OpenAPI Code Generation (Orval)

#### Code Generation Accuracy

**Sources:** GitHub issues #2933, #1537, #1602; Sascha Becker blog (2026); Ackee blog (2024); Orval documentation

**Key Findings:**

**Known Codegen Bugs (as of Dec 2025):**
- **GitHub Issue #2933 (Orval 8.2.0):** Multiple Zod schema generation bugs when using `client: 'angular'`, `schemas.type: 'zod'`, and `mode: 'split'`
  - Bug 1: Broken constraint placement - generates `export const X = export const yMin = 0;` instead of proper ordering
  - Bug 2: `@type` property name sanitized to `_type` - breaks JSON-LD/HAL responses (property names starting with @ are incorrectly sanitized)
  - Bug 3: Empty `strictObject({})` for generic Object types - infers to `Record<string, never>` which rejects all properties instead of allowing any
  - Bug 4: Near-identical schema names produce broken `.zod.ts files with dangling references (lines starting with `d.`)
  - Workaround: Post-processing scripts with regex replacements required in production

**OpenAPI Validation Limitations:**
- **GitHub Issue #1537 (Jul 2024):** OpenAPI validation (`validation: true`) appears ineffective - Orval generated invalid TypeScript code even when validation was enabled
  - Example: Empty `oneOf` array with discriminator mapping produced `whiteBalanceSettingsLeft: ;` (missing type)
  - IBM OpenAPI Validator detected the error and additional issues (wrong parameter name casing) that Orval missed
  - Recommendation: Validate OpenAPI specs with external tools (IBM OpenAPI Validator, spectral) before running Orval

**OpenAPI Spec Parsing Issues:**
- **GitHub Issue #1602 (Aug 2024):** Orval fails to complete generation on certain valid OpenAPI 3.0.1 specs
  - Issue occurs with path parameters and query parameters using schema references
  - No workaround documented; spec restructuring may be required

**Ecosystem Shift (2026):**
- **Sascha Becker blog (Jan 2026):** The ecosystem has moved away from hook generation to options-based generation
  - `@hey-api/openapi-ts` is now the recommended frontrunner for OpenAPI-to-TypeScript generation
  - Orval still generates custom hooks by default (`useListPets()`, `useGetPetById()`), which is now considered outdated
  - Orval remains a solid choice if you need mock generation (MSW handlers)
  - Ackee (Jul 2024) chose Orval over Zodios due to Zodios's runtime library overhead and harder-to-debug conventions

**Accuracy Assessment:**
- **TypeScript type generation:** Generally accurate for standard OpenAPI patterns, but edge cases (empty oneOf, discriminator mapping) can produce invalid code
- **Zod schema generation:** Has known bugs in split mode with Angular client; requires post-processing workarounds
- **OpenAPI validation:** Not reliable for catching spec errors; external validation tools recommended
- **Hook generation pattern:** Outdated compared to options-based approach (TanStack Query v5 pattern)

**Recommendations:**
- Validate OpenAPI specs with external tools (IBM OpenAPI Validator, spectral) before Orval codegen
- Consider `@hey-api/openapi-ts` for new projects if mock generation is not required
- If using Orval with Zod schemas in split mode, implement post-processing workarounds for known bugs
- Use Orval primarily for MSW mock generation where it remains strong

#### Mock Generation (MSW Handlers)

**Sources:** Orval MSW documentation; Medium articles on MSW + Faker.js

**Key Findings:**

**MSW Handler Generation Quality:**
- Orval generates high-quality MSW handlers using the recommended `HttpResponse` class from MSW
- Three types of generated functions:
  1. **Mock Data Generators:** Functions returning mocked values using Faker.js (`getShowPetByIdResponseMock()`)
  2. **Request Handlers:** Functions binding mock data to MSW `http.*` handlers with `HttpResponse` class
  3. **Aggregated Handlers:** Functions combining all handlers for easy setup (`getPetsMock()`)

**Content Type Support:**
- Orval automatically selects the correct `HttpResponse` helper based on OpenAPI spec content type:
  - `application/json` → `HttpResponse.json()`
  - `application/xml` → `HttpResponse.xml()`
  - `text/html` → `HttpResponse.html()`
  - `text/*` → `HttpResponse.text()`
  - `application/octet-stream`, `image/*` → `HttpResponse.arrayBuffer()`
- Configuration option `mock.preferredContentType` allows preferring specific content type when multiple are defined

**Mock Data Generation:**
- Faker.js integration provides realistic mock data (names, numbers, strings)
- Override pattern: `getShowPetByIdResponseMock({ name: 'Buddy' })` for custom values
- Dynamic responses: Pass async function for request-based data generation
- Example: `getShowPetByIdMockHandler(async (info) => { const petId = info.params.petId; return { id: Number(petId), name: `Pet ${petId}` }; })`

**MSW Best Practices Integration:**
- Orval follows MSW best practice for network behavior overrides using `server.use()`
- Allows test-specific overrides while keeping default happy-path handlers
- Supports `RequestHandlerOptions` (e.g., `{ once: true }`) for one-time handlers
- Integration with Vitest for testing: mock functions can track calls and assert on parameters

**Quality Assessment:**
- **Handler generation:** High quality - uses modern `HttpResponse` class, follows MSW best practices
- **Content type handling:** Excellent - automatic helper selection with manual override capability
- **Mock data realism:** Good - Faker.js provides realistic data, override pattern flexible
- **Test integration:** Strong - supports server.use() pattern, RequestHandlerOptions, Vitest integration

**Known Limitations:**
- **GitHub Issue #2934:** Same `@type` → `_type` sanitization bug affects MSW mock generation (breaks JSON-LD/HAL)
- No built-in validation that generated mocks match OpenAPI spec (external validation required)

**Recommendations:**
- Use Orval for MSW handler generation - quality is high and integration is excellent
- Implement post-processing to fix `@type` sanitization if using JSON-LD/HAL responses
- Validate generated mocks against OpenAPI spec using external tools if contract compliance is critical

#### Schema Validation Effectiveness

**Sources:** Orval DeepWiki (Zod Schema Validation); Orval v8 documentation

**Key Findings:**

**Zod Integration Architecture:**
- Two-phase generation architecture:
  1. **Phase 1:** Intermediate Representation (IR) - transforms OpenAPI schemas to internal representation
  2. **Phase 2:** Code String Generation - converts IR to Zod validation code strings
- Benefits: Separation of concerns, easier maintenance, consistent type mapping

**Validation Coverage:**
- Orval generates up to five Zod validation schemas per API endpoint:
  1. URL Parameters (`{operationName}Params`)
  2. Query Parameters (`{operationName}QueryParams`)
  3. Headers (`{operationName}Header`)
  4. Request Body (`{operationName}Body`)
  5. Response Body (`{operationName}Response`)

**Type Mapping Accuracy:**
- OpenAPI types mapped to Zod validation methods:
  - `string` → `zod.string()`
  - `number`, `integer` → `zod.number()`
  - `boolean` → `zod.boolean()`
  - `array` → `zod.array()`
  - `object` → `zod.object()`
  - `string` with `format: date` → `zod.date()`
  - `string` with `format: email` → `zod.string().email()`
  - `string` with `format: uri` → `zod.string().url()`
  - `string` with `format: uuid` → `zod.string().uuid()`

**Advanced Schema Support:**
- **Composition schemas:** Supports `allOf`, `oneOf`, `anyOf` with proper Zod composition
- **Enum handling:** Converts OpenAPI enums to Zod `zod.enum()`
- **Default values:** Preserves default values from OpenAPI in generated schemas
- **Discriminated unions:** Supports discriminated unions for type-safe variant handling
- **Tuple support:** Handles OpenAPI tuple schemas with `zod.tuple()`
- **Multi-type schemas:** Supports OpenAPI 3.1 multi-type schemas
- **File type handling:** Special handling for file uploads with form data validation

**Configuration Options:**
- **Strict mode:** Configurable strict mode for request/response/query/param/header/body validation
- **Type coercion:** Optional type coercion for string-to-number conversions
- **Custom preprocessing:** Preprocessing functions for data transformation before validation
- **DateTime options:** Configurable date/time format validation with version-specific handling
- **Selective schema generation:** Can generate only specific validation schemas (e.g., body only)

**Zod Version Compatibility:**
- Automatic detection of Zod version (v3 vs v4)
- API differences handled transparently
- Compatibility functions for version-specific features
- String format patterns supported in v4 only

**Validation Effectiveness Assessment:**
- **Runtime validation:** Excellent - provides comprehensive runtime type checking complementing TypeScript compile-time types
- **Type mapping accuracy:** High - standard OpenAPI types mapped correctly to Zod validators
- **Advanced schema support:** Strong - supports complex compositions (allOf, oneOf, anyOf), discriminated unions, tuples
- **Configuration flexibility:** Excellent - granular control over strict mode, coercion, preprocessing
- **Version compatibility:** Good - automatic Zod version detection with compatibility layer

**Known Limitations:**
- **GitHub Issue #2933:** Zod schema generation has known bugs in split mode (see Code Generation section)
- **Performance:** Runtime validation adds overhead; use only at system boundaries where data trust is required
- **Complex schemas:** Very complex nested schemas may require manual tuning for optimal validation

**Recommendations:**
- Use Orval's Zod validation for runtime type checking at API boundaries (requests/responses)
- Enable strict mode for production to catch data contract violations
- Use selective schema generation if full validation overhead is unnecessary
- Implement post-processing workarounds if using split mode with Angular client (see known bugs)
- Consider using external OpenAPI validation tools (IBM OpenAPI Validator) in addition to Orval's validation

### 4.10 Gate Configuration (Threshold Calibration with Historical Data)

**Sources:** testRigor (2026), Testkube (2026), SonarQube Documentation (2025), CD Foundation State of CI/CD Report 2024, industry best practices

**Key Findings:**

**Threshold Calibration with Historical Data:**
- **Start with realistic baseline thresholds:** Begin with achievable targets (e.g., 70% code coverage, 85% test pass rate) and gradually raise them as codebases mature. Starting with overly ambitious targets (e.g., 100% coverage) can frustrate developers and slow delivery.
- **Use differential values:** Quality gate conditions should measure changes from baseline rather than absolute values. For example, track "new code coverage" or "coverage increase from previous build" rather than total coverage percentage. This allows gates to remain effective as codebases grow.
- **Regular review and refinement:** Continuously monitor and review threshold limits as codebases, processes, and technologies evolve. Update thresholds based on actual performance data, team maturity, and changing business requirements. For example, start with 70% coverage and progressively raise to 90% as the team demonstrates capability.
- **Customize gates per project:** Not all projects require the same gates or thresholds. Customize based on team maturity, compliance needs, and application criticality. For instance, internal frameworks may require stronger requirements than experimental features.
- **Align with business-critical metrics:** Define gates aligned with what truly matters for application success and user experience, not just test pass/fail rates. Include metrics like response time, defect density, and security vulnerability counts alongside traditional test metrics.

**Historical Data-Driven Calibration:**
- **Establish performance baselines:** Collect 4-8 weeks of historical data on key metrics (build success rate, test pass rate, coverage, deployment frequency) to establish realistic baseline targets.
- **Use percentile-based thresholds:** Set thresholds based on historical performance percentiles (e.g., 75th percentile of historical build times) to ensure gates reflect actual capability rather than arbitrary targets.
- **Monitor threshold effectiveness:** Track gate pass/fail rates and false positive frequency. If gates fail too frequently (>30% of builds), thresholds may be too strict. If gates rarely fail (<5%), thresholds may be too lenient.
- **Seasonal and context-aware adjustment:** Recognize that threshold effectiveness may vary by project phase (initial development vs. maintenance), team composition changes, and technology stack updates.

**Best Practices for Threshold Setting:**
- **Clear, realistic, enforceable:** Thresholds must be clearly defined, realistically achievable, and aligned with business needs. Document the rationale for each threshold.
- **Automated enforcement:** Automate quality gates so failed gates automatically block merges or deployments. This ensures discipline in maintaining standards.
- **Feedback loops:** When gates fail, developers should receive clear, actionable information about what went wrong and how to fix it. Poor observability makes troubleshooting gate failures difficult.

### 4.11 Override Controls (Abuse Prevention with Audit Logs)

**Sources:** Prefactor (2025), Orca Security (2026), Linfordco (2025), SonarQube Documentation (2025), industry security best practices

**Key Findings:**

**Comprehensive Audit Trail Requirements:**
- **Log all pipeline runs and changes:** Every pipeline run must be fully documented with unique pipeline/run ID, commit hash, branch name, triggering event, environment, UTC timestamp, initiator/approver details, CI/CD tool or service account used, and executed stages with start/end times.
- **Track deployments and access changes:** Log environment and target infrastructure, deployment strategy, artifacts deployed, links to originating pipeline run, and change requests. Record all promotion gates passed (tests, security scans, manual approvals) with pass/fail statuses, approver identities, and timestamps.
- **Emergency override logging:** Emergency overrides and manual changes require special attention. Log these as `emergency_override` with details including reason, risk level, authorization path, executor/approver identities, bypassed checks, and impact scope. Flag these logs for heightened review with fields like `requires_postmortem: true` and link to follow-up tickets or post-incident reports.
- **Access-related events:** Log identity lifecycle events (role assignments/revocations, group membership changes, API key/service account creation or rotation), RBAC or policy binding updates, and resource access changes. Include actor identity, subject identity, old/new roles/permissions, approval paths, and timestamps.

**Abuse Prevention Measures:**
- **Role-Based Access Control (RBAC):** Implement strict access controls ensuring only authorized personnel can make changes to pipelines, access sensitive data, and deploy applications. Assign roles based on principle of least privilege.
- **Multi-factor authentication (MFA):** Add extra layer of security for accessing CI/CD tools and infrastructure.
- **Branch protection rules:** Enforce policies that prevent direct commits to critical branches (main/master). Changes must go through pull requests with thorough review and testing before merging.
- **Approval workflows:** Require approval from multiple team members, including at least one senior developer or security expert, for critical changes.
- **Centralized logging:** Collect and analyze logs from various pipeline stages to correlate events and identify suspicious activities. Use normalized JSON records with consistent keys for event correlation and querying.
- **Real-time monitoring:** Implement real-time monitoring of CI/CD pipeline to detect anomalies like unexpected changes or access patterns that could indicate security breaches.
- **Alerting mechanisms:** Set up alerting to notify appropriate personnel when potential security issues are detected for prompt response.

**Audit Trail Best Practices:**
- **Immutable logs:** Store logs in write-once, read-many (WORM) storage to prevent tampering.
- **Timestamp synchronization:** Synchronize timestamps across all systems for accurate event correlation.
- **Unique identifiers:** Assign unique identifiers to every component (pipelines, agents, deployments) for traceability.
- **Retention periods:** Store logs securely for required retention periods (e.g., 1-7 years depending on compliance requirements).
- **Regular audit completeness testing:** Verify log completeness, sequence continuity, and timestamp consistency on a regular basis.
- **Compliance mapping:** Map logged events to compliance controls for regulatory requirements (SOC 2, HIPAA, ISO 27001).

### 4.12 Adoption (Adoption Metrics with Best Practices)

**Sources:** CD Foundation State of CI/CD Report 2024, arXiv (2024) "Adoption and Adaptation of CI/CD Practices in VSEs", TestRail (2026), change management research, industry adoption studies

**Key Findings:**

**Adoption Metrics:**
- **DevOps involvement:** 83% of developers report being involved in DevOps-related activities (CD Foundation 2024).
- **Technology-performance correlation:** Strong correlation between number of DevOps technologies used and likelihood of being a top performer. CI/CD tools usage is associated with better deployment performance across all DORA metrics.
- **Experience gap:** Less experienced developers adopt fewer DevOps practices and technologies, indicating need for targeted training and onboarding.
- **Performance trend concern:** Proportion of low performers for deployment performance metrics is increasing—a worrying trend requiring attention.
- **Tool interoperability:** Deployment performance is worse when using multiple CI/CD tools of the same form, likely due to interoperability challenges.

**Adoption Best Practices:**
- **Start small and scale gradually:** Begin with essential gates (e.g., passing tests, basic code coverage) and build upon them as the process progresses. Don't attempt to implement all gates at once.
- **Communicate and train:** Ensure developers understand the purpose and importance of each quality gate. Provide proper training and feedback when gates fail. Cultural resistance often stems from lack of understanding or involvement in implementation.
- **Balance speed and quality:** Gates should ensure quality without hindering progress. Overly strict gates can slow delivery and frustrate developers, creating bottlenecks that negate CI/CD velocity benefits.
- **Customize per project maturity:** Not all projects require the same gates or thresholds. Customize based on team maturity, compliance needs, and criticality. Very Small Entities (VSEs) face resource constraints and need simplified platforms adapted to their scale.
- **Automate everything:** Minimize manual checks whenever possible and automate quality gates for consistency and scalability.
- **Monitor and review:** Continuously track quality gates to ensure they serve their intended purpose. Update threshold limits as codebases, processes, and technologies evolve.
- **Connect metrics to business outcomes:** Share insights on CI metrics across development, QA, management, and leadership. Help teams understand how metrics contribute to business values like customer satisfaction and time to market.

**Change Management for Adoption:**
- **Pilot with subset:** Introduce changes slowly, pilot with a subset of teams or projects before full rollout.
- **Frequent check-ins:** Monitor rollout progress and answer team questions regularly. Document successes to inspire other teams.
- **Feedback mechanisms:** Implement feedback loops that make employees feel heard and help refine the rollout.
- **Sustained engagement:** Maintain engagement beyond go-live moment to ensure long-term adoption.
- **Simplified tools for VSEs:** Very Small Entities struggle with tool complexity. Develop simplified platforms that allow small teams to implement CI/CD without steep learning curves. Alignment with standards like ISO 29110 has shown to facilitate adoption by providing familiar frameworks.

**Common Adoption Challenges:**
- **Resource constraints:** VSEs face significant challenges implementing CI/CD due to reduced structure and limited resources. Time constraints affect ability to implement efficient practices.
- **Tool complexity:** Complex requirements engineering and testing tools present significant barriers for small companies, slowing CI/CD adoption.
- **Lack of guidelines:** VSEs often lack clear guidelines for effective CI/CD tool and process implementation. Developing adapted frameworks and implementation guidelines is critical.
- **Microservices complexity:** Managing multiple dependencies and maintaining efficient CI/CD infrastructure is difficult when migrating to microservices architectures.
- **Cultural resistance:** Quality gates perceived as extra burden or bureaucratic obstacle. Developers may resist if not involved in implementation.

---

## 5. Test Environment & Infrastructure

### 5.1 Environment Topology

| Environment | Purpose | Key Services | Test Data |
|---|---|---|---|
| Local | Developer testing | Ollama, SQLite, Vitest, MSW | Synthetic, golden datasets |
| CI | Automated test suite | GitHub Actions runners, mocked services | Contract‑driven mocks |
| Staging | Integration, E2E, load | Supabase, Fly.io (FastAPI), Vercel (web), LiveKit, Upstash, Nylas sandbox | Anonymised production snapshots |
| Production‑like | Performance, DR | Mirrors production (active‑passive) | Read‑only anonymised copy |
| Production | Monitoring & trace‑first AI analysis | Full stack | Production traffic (no test writes) |

### 5.2 Test Data Management
- Golden datasets stored in versioned, encrypted object storage.
- Anonymisation performed by a reviewed pipeline; no PII reaches non‑production environments.
- Synthetic data generated for edge cases via faker‑based scripts, integrated into MSW handlers.

### 5.3 Contract Testing

#### Schemathesis Limitations for Real-Time Protocols
- **Schemathesis only supports HTTP REST (OpenAPI) and GraphQL schemas** - it does NOT support WebSocket or Server-Sent Events (SSE) protocols
- Designed for synchronous, request-response APIs; OpenAPI Specification 3.0 excels at documenting synchronous APIs but was not designed with WebSockets in mind
- SSE/WebSocket endpoints must be listed in an ignore file for Schemathesis to skip them
- Testing challenges for real-time protocols: state management (persistent connections), event ordering (unpredictable sequences under load), connection lifecycle (establishment, exchange, error handling, disconnection), concurrency (race conditions with multiple clients)

#### Alternative Contract Testing for Real-Time Endpoints

**Microcks** (Recommended for AsyncAPI/WebSocket contract testing)
- Open-source tool for API mocking and testing with AsyncAPI v2.1.0 support (first tool to support it)
- Added WebSocket support in v1.3.0 (released 2025) - simply add WebSocket binding to AsyncAPI spec, Microcks publishes endpoints automatically
- Contract conformance testing checks that implementation respects the contract (OpenAPI or AsyncAPI specification)
- Conformance index (estimates contract coverage by samples) and Conformance score (current test execution score) metrics
- Test history with request/response pairs, failure tracking, and violated assertion messages
- Supports multi-protocol approach: OpenAPI, AsyncAPI, gRPC/Protobuf, GraphQL, SOAP
- CI-ready with GitHub Actions integration

**Specmatic**
- Specmatic-async enables contract-driven testing for WebSocket APIs via AsyncAPI specification
- Ensures both producers and consumers adhere to AsyncAPI spec
- Transforms AsyncAPI specs into executable contracts for contract testing, intelligent service virtualization, and backward compatibility testing
- Working example: specmatic-websocket-sample project on GitHub

**AsyncAPI Ecosystem Tools**
- **AsyncAPI Payload Validator**: Python library/CLI for validating message payloads against AsyncAPI 2.x and 3.x specs with detailed JSON Schema validation (type checking, required fields, patterns, enums, constraints)
- **Zod Sockets**: Socket.IO solution with I/O validation, generates AsyncAPI specification and contract for consumers
- **Asynction**: SocketIO server framework driven by AsyncAPI specification, guarantees API works according to documentation

**Load Testing Tools with WebSocket Support** (for performance validation, not contract testing)
- **Artillery**: Load testing tool with WebSocket support for simulating high-load scenarios
- **k6**: Performance testing with WebSocket support; k6-jslib-k6chaijs-contracts for contract validation
- **JMeter**: WebSocket testing via WebSocket Samplers plugin

#### Recommended Strategy
- Use **Schemathesis** for HTTP REST (OpenAPI) and GraphQL contract testing
- Use **Microcks** for WebSocket and SSE contract testing via AsyncAPI specifications
- SSE endpoints can be tested as HTTP streaming endpoints with Schemathesis if they follow standard HTTP patterns, but full SSE protocol validation requires AsyncAPI-based tools
- Contract test failures block PRs and trigger automatic API documentation updates

### 5.4 Offline Sync Test Scenarios
The following scenarios are automated and run on PowerSync‑enabled environments:
- **Create‑while‑offline:** Mobile (Expo) creates a calendar event offline; after sync, event appears on web.
- **Concurrent edit conflict:** Both devices modify the same project deadline offline; conflict resolution (timestamp‑based) ensures convergence.
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

#### CVE Mapping

**Source:** Lares Labs OWASP Agentic AI Top 10: Threats in the Wild (2025-2026), NIST NVD, CISA KEV Catalog

**Key Findings:**
- **Lares Labs** is a security research organization that published comprehensive CVE mappings for OWASP Agentic Security Initiative (ASI) Top 10
- CVE mappings are maintained through real-world incident research and vulnerability discovery
- ASI01-ASI05 have assigned CVEs; ASI06-ASI10 are emerging risk categories with documented incidents but no CVEs assigned yet

**CVE Mapping Completeness Table:**

| ASI Code | Threat Category | CVEs Assigned | CVE IDs (from Lares Labs) | CVSS Scores | Status |
|---|---|---|---|---|---|
| ASI01 | Agent Goal Hijack | 4 | CVE-2025-32711, CVE-2025-53773, CVE-2025-64660, CVE-2025-61590 | 9.3, 7.8, N/A, N/A | Complete |
| ASI02 | Tool Misuse & Exploitation | 2 | CVE-2025-8217, CVE-2025-34291 | 7.8, N/A | Complete |
| ASI03 | Identity & Privilege Abuse | 0 | None assigned | N/A | No CVEs (incidents only) |
| ASI04 | Agentic Supply Chain Compromise | 1 | CVE-2025-6514 | 9.6 | Complete |
| ASI05 | Unexpected Code Execution | 4+ | CVE-2025-54135, CVE-2025-54136, CVE-2025-59944, +24 from IDEsaster Research | 8.6, 7.2, N/A, 8.9 | Partial (ongoing discovery) |
| ASI06 | Memory & Context Poisoning | 0 | None assigned | N/A | No CVEs (emerging) |
| ASI07 | Insecure Inter-Agent Communication | 0 | None assigned | N/A | No CVEs (emerging) |
| ASI08 | Cascading Agent Failures | 0 | None assigned | N/A | No CVEs (emerging) |
| ASI09 | Human-Agent Trust Exploitation | 0 | None assigned | N/A | No CVEs (emerging) |
| ASI10 | Rogue Agents | 0 | None assigned | N/A | No CVEs (emerging) |

**Validation Findings:**
- TASK INFORMATION PARTIALLY INCORRECT in 00-STRAT-BLUEPRINT.md
- **Error 1:** ASI03 incorrectly lists CVE-2025-32711 (EchoLeak) - this CVE belongs to ASI01, not ASI03
- **Error 2:** ASI05 incorrectly lists CVE-2025-53773 (GitHub Copilot YOLO Mode) - this CVE belongs to ASI01, not ASI05
- **Corrected:** ASI03 has no assigned CVEs (only incidents: Copilot Studio Connected Agents, CoPhish Attack, Copilot Studio Public-by-Default)
- **Corrected:** ASI05 CVEs are CVE-2025-54135 (CurXecute), CVE-2025-54136 (MCPoison), CVE-2025-59944 (Cursor Case-Sensitivity), Claude Desktop RCE, plus 24 CVEs from IDEsaster Research

**Gaps:**
- ASI06-ASI10 have no CVEs assigned yet as of April 2026 - these are emerging risk categories
- CVE discovery is ongoing, especially for ASI05 (Unexpected Code Execution) with new CVEs discovered monthly
- No automated CVE-to-ASI mapping exists - requires manual research and incident correlation

#### ASI Coverage

**Coverage Matrix with Missing Controls:**

| ASI Code | Threat | Test Coverage | Control Coverage | Missing Controls | Priority |
|---|---|---|---|---|---|
| ASI01 | Goal Hijack | High (jailbreak prompts, intent capsule tests) | Medium (input/output guardrails) | Persistent memory injection tests | High |
| ASI02 | Tool Misuse | High (tool authorization, schema allowlist) | High (MCP OAuth, least privilege) | Runtime tool behavior monitoring | Medium |
| ASI03 | Identity Abuse | Medium (auth flow simulation) | Medium (Agent Passports, short-lived creds) | Inter-agent identity verification | High |
| ASI04 | Supply Chain | Medium (MCP server verification) | Medium (dependency pinning) | Dynamic MCP server change detection | Critical |
| ASI05 | Code Execution | High (sandboxing, approval gates) | High (no auto-approve, human approval) | Filesystem isolation validation | Critical |
| ASI06 | Memory Poisoning | Low (memory audit tests) | Low (provenance tracking) | Memory integrity verification | High |
| ASI07 | Inter-Agent Comm | Low (session smuggling tests) | Low (mTLS, encryption) | Agent authentication verification | Medium |
| ASI08 | Cascading Failures | Low (circuit breaker tests) | Low (blast-radius caps) | Cascade simulation testing | High |
| ASI09 | Trust Exploitation | Low (human-in-the-loop tests) | Low (independent verification) | Trust manipulation detection | Medium |
| ASI10 | Rogue Agents | Low (behavioral monitoring) | Low (kill switches) | Drift detection before misalignment | Critical |

**Coverage Analysis:**
- **ASI01-ASI05:** Higher coverage due to established CVEs and mature mitigation patterns
- **ASI06-ASI10:** Lower coverage due to emerging status and lack of CVEs
- **Critical gaps:** ASI04 (supply chain), ASI05 (code execution), ASI10 (rogue agents) require immediate attention
- **Testing priority:** Focus on ASI06-ASI10 incident-based testing since no CVEs exist for validation

#### Automation

**Automated CVE Mapping Update Process:**

**NIST NVD API Integration (v2.0):**
- **Endpoint:** `https://services.nvd.nist.gov/rest/json/cves/2.0`
- **Parameters:** cpeName, cveId, cvssV3Severity, cweId, isExactMatch
- **Pagination:** Offset-based with startIndex and resultsPerPage (max 2000 per request)
- **Rate limits:** 5 requests per rolling 30-second window (NIST policy)
- **Prioritization (as of April 15, 2026):** NIST now prioritizes CVE enrichment for:
  - CVEs in CISA KEV Catalog (enriched within 1 business day)
  - CVEs for federal government software
  - CVEs for critical software (EO 14028 definition)
  - Other CVEs marked as "Lowest Priority - not scheduled for immediate enrichment"

**CISA KEV Catalog Integration:**
- **Endpoint:** CISA Known Exploited Vulnerabilities Catalog
- **Purpose:** Real-world exploited vulnerabilities requiring immediate action
- **Automation:** Poll KEV catalog daily for new entries, cross-reference with ASI categories
- **Due dates:** KEV entries have specific due dates for federal agency remediation

**Automated Update Workflow:**

```
┌─────────────────┐
│  Daily Cron Job  │
│  (00:00 UTC)     │
└────────┬────────┘
         │
         ├─→ Query NVD API for CVEs modified in last 24h
         │   - Filter by CPE names relevant to AI/LLM ecosystem
         │   - Check CVSS v3.1 severity (HIGH/CRITICAL priority)
         │   - Extract CWE mappings for ASI correlation
         │
         ├─→ Query CISA KEV Catalog for new entries
         │   - Cross-reference with AI/LLM software products
         │   - Flag KEV entries for immediate security review
         │
         ├─→ Parse Lares Labs RSS feed (if available)
         │   - Monitor for new ASI CVE mappings
         │   - Extract incident reports and CVE assignments
         │
         ├─→ Correlate CVEs with ASI categories
         │   - Use CWE-to-ASI mapping rules
         │   - Manual review for ambiguous cases
         │   - Update CVE Mapping table
         │
         ├─→ Generate alert for critical findings
         │   - Slack/Email notification for KEV entries
         │   - JIRA ticket creation for CVE requiring action
         │
         └─→ Update documentation
             - Commit CVE mapping updates to 07-TESTING.md
             - Update ASI Coverage matrix with new controls
             - Version control with Git commit messages
```

**Automation Tools & Configuration:**

**GitHub Actions Workflow Example:**
```yaml
name: CVE Mapping Update
on:
  schedule:
    - cron: '0 0 * * *'  # Daily at 00:00 UTC
  workflow_dispatch:

jobs:
  update-cve-mapping:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Query NVD API
        run: |
          curl -H "apiKey: ${{ secrets.NVD_API_KEY }}" \
            "https://services.nvd.nist.gov/rest/json/cves/2.0?cvssV3Severity=CRITICAL&resultsPerPage=2000" \
            > cves.json
      - name: Query CISA KEV
        run: |
          curl "https://www.cisa.gov/known-exploited-vulnerabilities-catalog.json" \
            > kev.json
      - name: Correlate with ASI
        run: python scripts/correlate_asi.py cves.json kev.json
      - name: Update Documentation
        run: |
          python scripts/update_cve_mapping.py docs/plan/07-TESTING.md
      - name: Commit Changes
        run: |
          git config user.name "CVE Bot"
          git config user.email "cve-bot@example.com"
          git add docs/plan/07-TESTING.md
          git commit -m "chore: update CVE mapping $(date +%Y-%m-%d)"
          git push
```

**Frequency and Triggers:**
- **Daily automated update:** 00:00 UTC cron job queries NVD and CISA APIs
- **Manual trigger:** GitHub Actions workflow_dispatch for on-demand updates
- **Event-driven:** Webhook from NVD (if available) for immediate critical CVE notification
- **Manual review:** Monthly review of ASI06-ASI10 for emerging incident patterns

**Limitations and Considerations:**
- **NVD API rate limits:** 5 requests/30s requires careful batching and pagination
- **NVD prioritization changes:** As of April 2026, NVD only enriches priority CVEs; others marked "Lowest Priority"
- **Manual correlation required:** CWE-to-ASI mapping is not automated; requires security researcher review
- **Emerging categories:** ASI06-ASI10 have no CVEs; rely on incident research (Lares Labs, OWASP community)
- **False positives:** Automated correlation may misclassify CVEs; manual verification required before documentation updates

### 6.2 MCP Security Testing
- **MCPSec L2 compliance** verified for all production servers (CI gate).
- **MCP Inspector exposure** prevented (integration test for 0.0.0.0 binding).
- **Adversarial testing** with AgentProbe (134 attack vectors) on every MCP server release.
- **SecureMCP** audits: OAuth token leakage, prompt injection, rogue server detection.

### 6.3 Grant & Auth Webhook Testing
- Simulate Nylas grant expiration; confirm webhook fires, re‑auth UI appears, and sync resumes without data loss.
- Test with revoked tokens at various stages of an active workflow.

### 6.4 Data Sovereignty & Privacy
- **Local Ollama processing:** Integration test confirms that during local‑first mode, no data leaves the device (network inspection).
- **RLS isolation:** Mandatory pgTAP tests for every table; no data cross‑tenant leakage.

### 6.5 Compliance Automation (Vanta)
- Vanta monitors cloud, identity, and code repos for SOC 2 controls.
- Automated evidence collection: test pass/fail logs, coverage reports, AI evaluation results.
- EU AI Act readiness tracker (deadlines: stand‑alone high‑risk 2 Dec 2027, embedded 2 Aug 2028).
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
- Backfill script: validate thread‑to‑conversation transformation, role mapping, image URL handling.
- Strict mode behavior change verification.

#### Pre‑Migration Gate
- All critical AI flows documented and passing.
- Backfill script tested on sample data.
- Feature parity checklist completed.

#### Post‑Migration Gate
- All AI flows pass with Responses API.
- No regression beyond defined thresholds (acc ≥base‑2%, latency ≤base+10% warn, ≤base+20% block).
- Historical threads backfilled successfully.

### 7.2 TypeScript 6.0 & 7.0
- CI upgrade to TypeScript 6.0; enforce `erasableSyntaxOnly`.
- tsgo 7.0 evaluated in parallel; break on configuration drift.
- No regression in build or type‑check performance.

### 7.3 React 20 Compiler
- Component tests run with React 20 Compiler enabled.
- Verify “use no memo” directives remain effective; performance benchmarks show no regression.

### 7.4 Claude 4.6 Compatibility
- Run all test prompts through Claude 4.6; compare output parity with previous model (max 5% divergence in accuracy score).
- Latency and token usage compared against baseline.

### 7.5 Temporal Safari Testing
- E2E test specifically on Safari, confirming Temporal polyfill activates and wall‑clock handling is correct.

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
| Baseline | 200 req/s | 10 min | Measure steady‑state performance |
| Sustained load | 1000 req/s | 1 hour | Validate system under expected peak |
| Stress | 200% of sustained (2000 req/s) | 2 hours | Identify breaking points and recovery |
| Soak | 800 req/s | 24 hours | Detect memory leaks and resource exhaustion |

Endpoints stressed: conflict detection API, chat completion, offline sync operations, and notification fan‑out.

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

### 9.1 Requirement‑Test Traceability
A traceability matrix connects each feature (J001, J002, etc.) to its test cases (QA_C). This is maintained in the test management tool (to be integrated). Placeholder:

| Feature ID | Feature | Test Case IDs | Status |
|---|---|---|---|
| J001 | Cross‑app conflict detection | QA_C‑001 to QA_C‑005 | Automated |
| J002 | Unified chat assistant | QA_C‑010 to QA_C‑020 | Automated |
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

## 10. Governance, Schedule & Risks

### 10.1 Phased Testing Schedule

| Phase | Focus | Timeline | Key Deliverables |
|---|---|---|---|
| Phase 1 | Foundation, core modules | Q2 2026 | Unit/component coverage ramp‑up, CI pipeline |
| Phase 2 | AI evaluation integration | Q2‑Q3 2026 | AgentAssay, DeepEval gates |
| Phase 3 | Feature module testing, E2E, offline sync | Q3 2026 | 15 critical flows automated, sync tests |
| Phase 4 | Security & compliance hardening | Q3‑Q4 2026 | MCP L2, ASI coverage, Vanta evidence |
| Phase 5 | Mobile & desktop (Expo, Tauri) | Q1 2027 | Mobile E2E, Tauri capability tests |

### 10.2 Risk Register

| Risk | Probability | Impact | Mitigation |
|---|---|---|---|
| OpenAI API changes break tool calling | Medium | High | Contract & parity tests; migration buffer until Aug 26 |
| Model provider model drift (accuracy) | Medium | High | AI quality gates, golden dataset refresh, A/B testing |
| MCP server security vulnerability | Low | Critical | Regular SecureMCP audits, L2 CI gate |
| Offline sync data conflicts | Medium | Medium | PowerSync conflict resolution tests, deterministic rules |
| SOC2 / EU AI Act timeline miss | Low | Critical | Vanta automation, dedicated compliance sprint |

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
Title: [Component] – Concise summary
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
Current per‑module coverage percentages are maintained in the dynamic test status dashboard (link to Grafana or internal tool), not in this static plan. The dashboard is refreshed on every CI run.

### D. Glossary
- **ASI:** AI Security Incident (08‑10 threat categories)
- **MCP:** Model Context Protocol
- **SPRT:** Sequential Probability Ratio Test
- **RAGAS:** Retrieval Augmented Generation Assessment
- **AIBOM:** AI Bill of Materials
- **TTFT:** Time to First Token

---

*End of document.*