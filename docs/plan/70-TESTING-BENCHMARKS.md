---
title: "Test Benchmarks"
owner: "QA Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

Deep dive benchmark analyses for pgTAP effectiveness, Orval accuracy, Playwright agent costs, contract testing tool comparisons, and CVE mapping details. This file is loaded on-demand for detailed reference.

**Document version:** 1.0
**Last updated:** April 2026
**Owner:** QA (R1)

---

## 1. DeepEval vs RAGAS Accuracy Comparison

**Source:** AIMMultiple RAG Evaluation Tools Benchmark (Dec 2025), 1,010 samples (HaluEval 480 + HotPotQA 530), GPT-4o as judge with temperature=0

### Key Findings

- **Top-1 Accuracy:** WandB (94.5%), TruLens, and Ragas are statistically tied with 95% CI overlapping between 94.0% and 98.0%
- **DeepEval limitation:** Under-scores golden contexts at mean 0.46 vs 0.82-0.91 for other tools, making it unreliable for identifying the single best context
- **Ragas advantage:** Dual-judge averaging with 5 possible output values (0.0, 0.25, 0.5, 0.75, 1.0) provides built-in resistance to prompt sensitivity
- **DeepEval approach:** Statement decomposition (G-Eval) produces continuous scores but is strict, penalizing contexts with off-topic sentences

### Scoring Method Comparison

- **WandB:** Binary LLM prompt (0 or 1) - highest Top-1 accuracy but cannot express degrees of relevance
- **TruLens:** 4-point Likert scale (0.0, 0.33, 0.67, 1.0) - highest NDCG@5 (0.932) and Spearman ρ (0.750)
- **Ragas:** Dual-judge averaging - two independent judges with different phrasing, averaged for 5 output values
- **DeepEval:** Statement decomposition - continuous 0.0-1.0 score based on relevant statement ratio

### Recommendation

Use Ragas for RAG evaluation due to dual-judge bias resistance and competitive accuracy. DeepEval's strict scoring makes it less suitable for single-best-context identification tasks.

---

## 2. LLM-as-Judge Bias Validation via LiteLLM Proxy

**Research Finding:** TASK INFORMATION INCORRECT. LiteLLM proxy does NOT provide built-in bias detection or validation capabilities for LLM-as-judge systems.

### LiteLLM Capabilities

- **Model Compare Playground UI:** Side-by-side comparison of up to 3 models with metrics (latency, token usage, cost)
- **A/B Testing:** Traffic mirroring to secondary (silent) model for evaluation purposes
- **Budget Control:** Per-key, per-user, per-team budgets with `max_budget` and `budget_duration` (e.g., "30s", "30m", "30d"). Budgets reset automatically; default check interval is 10 minutes (configurable via `proxy_budget_rescheduler_min_time` and `proxy_budget_rescheduler_max_time`).
- **Rate Limiting:** TPM (tokens per minute), RPM (requests per minute), and max parallel request limits can be set per key or team. Budget/rate limit tiers can be created and assigned to keys for structured access control.
- **Spend Tracking:** Spend per user/team tracked with response header `x-litellm-response-cost` and stored in `LiteLLM_SpendLogs` table. Enterprise features include spend reports, daily breakdown API, and custom tags for granular tracking.

### What LiteLLM Does NOT Provide

- No built-in bias detection algorithms
- No position bias validation (A,B vs B,A ordering)
- No verbosity bias mitigation
- No self-enhancement bias detection
- No multi-judge consensus mechanisms

### Actual Bias Mitigation Strategies (External to LiteLLM)

- **Position bias (~40% GPT-4 inconsistency):** Evaluate both (A,B) and (B,A) orderings; only count consistent wins
- **Verbosity bias (~15% inflation):** Use 1-4 scales, reward conciseness explicitly
- **Self-enhancement bias (5-7% boost):** Use different model families as judges
- **LLM jury approach:** Run 3-5 models (GPT-4, Claude, Llama-3) with majority vote for critical evaluations, reduces biases 30-40% but costs 3-5x more

### Updated Documentation

LiteLLM proxy is used for cost tracking, budgeting, and model comparison, but bias validation requires external implementation using the strategies above. The task assumption that LiteLLM can validate LLM-as-judge bias is incorrect.

---

## 3. Cost Effectiveness of LLM-as-Judge vs Traditional Testing

**Source:** Label Your Data (2026), Evidently AI (2026), industry benchmarks

### Cost Comparison

- **LLM-as-judge:** $0.03-0.10 per evaluation
- **Human review:** $5-15 per evaluation (varies by domain expertise)
- **At 10,000 monthly evaluations:** LLM judges save $50,000-100,000 vs. human review while maintaining 80% agreement

### Cost-Benefit Analysis

- **Scale advantage:** Evaluating 1000+ outputs regularly where human review is cost-prohibitive
- **Speed advantage:** Rapid iteration cycles (80% agreement acceptable vs. perfect human review)
- **Semantic assessment:** Tone, helpfulness, paraphrases that traditional metrics miss

### When to Use LLM Judges

- Scale: evaluating 1000+ outputs regularly
- Semantic assessment: tone, helpfulness, paraphrases
- Speed: rapid iteration cycles

### When to Keep Humans in Loop

- High-stakes domains (legal, medical, safety-critical)
- Specialized expertise requirements where judges hallucinate
- Frontier model evaluation (judging models at/beyond judge capability)
- Bias measurement (judge's own biases skew results)

### When to Use Simpler Approaches

- Deterministic checks (format validation, keyword presence)
- Exact matching tasks (calculations, schema validation)
- Real-time requirements <50ms (use specialized classifiers)

### Recommendation

Use LLM-as-judge for large-scale semantic evaluation where 80% human agreement is acceptable. Reserve human review for high-stakes decisions and bias measurement. Use deterministic code-based checks for simple validation tasks.

---

## 4. Playwright AI Agents (MCP) - Effectiveness Metrics

### Token Efficiency

- **Token efficiency**: Playwright CLI uses ~27K tokens per task vs ~114K tokens with MCP (4x reduction). CLI saves snapshots to disk instead of streaming full accessibility tree in tool responses.

### Agent Workflow

- **Planner**: Explores app and creates structured markdown test plans
- **Generator**: Converts plans to executable Playwright tests with production-grade locators
- **Healer**: Diagnoses and fixes failing tests by replaying in debug mode, inspecting console logs/network/page snapshots

### Success Factors

- Agents use Model Context Protocol (MCP) to connect LLM with real browser, making decisions based on live DOM state rather than guessing from screenshots.

### Limitations

- Context window limits on long flows (50+ steps can exceed LLM capacity)
- Model variance (identical requests produce different assertion styles/variable names)
- TypeScript/JavaScript only (no Python support yet)
- Selectors aren't always right (text locators break when copy changes)
- Complex UI changes need human intervention
- Business logic gaps (healer handles selector failures but struggles with backend changes/API contract shifts/feature flags)

### Cost per Action

Rough token costs per agent action vary by model. For a team running 200 PRs/week with healing on every run: $10-20/week in LLM costs.

### Smart Approach

- Use agents for new feature coverage and initial test generation
- Use traditional test authoring for business-critical paths
- Run healer on weekly schedule rather than every PR

---

## 5. Playwright AI Agents - Cost Optimization via LiteLLM Proxy

### Budget Control

LiteLLM proxy supports per-key, per-user, per-team, and per-customer budgets with `max_budget` and `budget_duration` (e.g., "30s", "30m", "30d"). Budgets reset automatically; default check interval is 10 minutes (configurable via `proxy_budget_rescheduler_min_time` and `proxy_budget_rescheduler_max_time`).

### Rate Limiting

TPM (tokens per minute), RPM (requests per minute), and max parallel request limits can be set per key or team. Budget/rate limit tiers can be created and assigned to keys for structured access control.

### Spend Tracking

LiteLLM tracks spend per user/team with response header `x-litellm-response-cost` and stores logs in `LiteLLM_SpendLogs` table. Enterprise features include spend reports, daily breakdown API, and custom tags for granular tracking.

### Cost Tracking Integration

Playwright agent LLM calls routed through LiteLLM proxy with user/team tags. Cost alerts at 15%, 5%, and 0% of budget thresholds. Hard limit enforcement when budget exhausted (API calls rejected).

### Optimization Strategies

- Use Playwright CLI instead of MCP when agent has filesystem access (4x token savings)
- Use `includeSnapshot: false` to reduce token consumption
- Run headless in CI
- Minimize navigation steps
- Batch agent runs (healer only on failing tests, not entire suite)

---

## 6. Playwright AI Agents - CI Integration Patterns

### Standard CI Workflow

Agents themselves are interactive tools for VS Code Copilot/Claude Code/OpenCode, but generated tests are standard Playwright tests that run in CI like any other suite. GitHub Actions workflow: checkout → setup-node → npm ci → playwright install --with-deps → playwright test → upload artifact (with `if: always()` to save failed test reports).

### Multi-Agent Orchestration

2026 pattern runs specialized agents in parallel (Functional Agent for happy path, Security Agent for XSS/auth bypass, Accessibility Agent for WCAG, Performance Agent for Core Web Vitals). Uses Observer-Driver pattern: Driver Agents own write-actions/state transitions (only one per flow to prevent conflicts); Observer Agents run asynchronously to perform specialized audits without disrupting execution.

### Agent Orchestration in CI

Dedicated CI workers for agent operations to avoid impacting test speed. Planner/Generator run during development or on feature branches; Healer runs on failed tests during nightly builds or on-demand. Agent traces logged for debugging and compliance (EU AI Act requires audit trail of agent reasoning).

### Integration with ADR_123

Playwright agents configured with LiteLLM proxy for cost tracking. Agent definitions stored in `.github/` and regenerated when Playwright is updated. CI gate validates agent-generated test stability before merging.

Token consumption is monitored; agents are used on dedicated CI workers to avoid impacting test speed.

---

## 7. pgTAP RLS Test Coverage Patterns

**Source:** supabase-test-helpers (usebasejump/supabase-test-helpers), PostgreSQL documentation, industry best practices

### Key Findings

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

### Test Pattern Example

```sql
BEGIN;
SELECT plan(1);
-- Check RLS is enabled on all tables in public schema
SELECT tests.rls_enabled('public');
SELECT * FROM finish();
ROLLBACK;
```

### Authentication Context Testing

```sql
-- Create test user and authenticate as them
SELECT tests.create_supabase_user('test_owner');
SELECT tests.authenticate_as('test_owner');
-- Run RLS policy tests
SELECT tests.clear_authentication();
```

### Coverage Requirements

- All tables in exposed schemas must have RLS enabled
- RLS policies tested with multiple user contexts (owner, member, anon, service_role)
- Policy logic verified for both allow and deny scenarios
- Cross-tenant isolation validated (no data leakage between tenants)

---

## 8. pg_prove Automation Effectiveness

**Source:** pgTAP documentation (pgtap.org), Capital One engineering blog, End Point Dev blog

### Key Findings

- **pg_prove** is the command-line tool for running pgTAP tests in bulk with a single command
- Processes TAP output using TAP::Harness to summarize test results
- **Highly effective for automation** with CI/CD integration capabilities
- Supports two test formats:
  - **SQL scripts**: Files containing TAP-emitting SQL statements
  - **xUnit Test Functions**: Database functions that return SETOF TEXT with pgTAP function results

### Automation Effectiveness

- **Capital One production use**: pgTAP tests ensure database validation, proactively identifying formatting issues and edge cases
- **Simple, readable code**: pgTAP tests are easy to understand and maintain compared to traditional Perl-based database testing
- **CI/CD integration**: pg_prove simplifies automation of testing, making tests repeatable and reliable
- **Batch execution**: Can run large numbers of tests from a directory with single command
- **Exit codes**: Returns appropriate exit codes for CI gate integration (0=success, non-zero=failure)

### Usage Pattern

```bash
# Run all tests in a directory
pg_prove -d mydatabase tests/

# Run specific test file
pg_prove -d mydatabase tests/00-test.sql

# Run xUnit test functions
pg_prove --dbname mydb --schema test --match 'test$' --runtests
```

### CI Integration

- Integrates with build processes and continuous integration pipelines
- Provides test counts, success/failure rates, and diagnostic messages
- Output format suitable for CI log parsing and reporting
- Can be combined with other TAP-emitting tests using `prove` command

### Performance

- Fast execution: Tests run within transactions, rolled back after completion
- Minimal overhead: Direct database connection, no external dependencies
- Scalable: Handles hundreds of tests efficiently (example: 216 tests in 1 wallclock second)

---

## 9. Drift Detection - Detailed Approaches

**Source:** Liquibase documentation, Atlas monitoring docs, SchemaSmith guide, Firefly CI/CD implementation

### Key Findings

- **Drift detection** is critical for preventing schema mismatches between environments
- Multiple approaches exist for automated drift detection with CI/CD blocking

### Liquibase Pro Approach

- `liquibase diff --format=json` provides structured list of differences between database schemas
- JSON output can be used to:
  - Count differences and prioritize fixes
  - Halt CI/CD process if critical table/column is in drift report
  - Trigger notifications to team
- **Drift Detection Reports** compare current database state to previous snapshot or target environment
- Integrated into CI/CD pipeline for continuous monitoring

### Atlas Approach

- GitHub Actions integration for schema monitoring
- Agent deployment in database VPC or GitHub Action for tracking schema changes
- **Features:**
  - Live visibility with automated ER diagrams
  - Changelog of all schema changes
  - Webhooks or Slack notifications for drift alerts
- Quickstart guides available for GitHub Actions, GitLab CI/CD, BitBucket Pipelines

### SchemaSmith Approach

- **State-based drift detection**: Compare live database against declared source of truth (metadata definition in version control)
- Detects drift AND provides path to resolution (tool knows correct state)
- **Detection methods:**
  - Manual comparison (time-consuming, easy to skip)
  - Automated schema comparison (CI-triggered diffs between live databases)
  - State-based detection (against source of truth in version control)
  - Audit trails (DDL triggers, database audit logs)

### Firefly/Terraform Approach

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

### Drift Detection Blocking Procedures

1. **Pre-deployment check:** Run drift detection as part of CI pipeline before deployment
2. **Exit code handling:** Use exit codes to block deployment when drift detected
3. **Issue tracking:** Create GitHub Issues for drift reports, close when resolved
4. **Scheduled checks:** Run drift detection weekly even when no code changes committed
5. **Severity-based blocking:** Block deployment for critical drift (tables, columns), warn for non-critical

### Best Practices

- Integrate drift detection into CI/CD so every infrastructure update is verified against actual state
- Use state-based detection (compare against version control) rather than just environment-to-environment comparison
- Implement scheduled drift checks (e.g., weekly) to catch changes made outside normal deployment process
- Use structured output (JSON) for programmatic handling of drift reports
- Maintain audit trails for compliance and troubleshooting

---

## 10. Orval Code Generation Accuracy

**Sources:** GitHub issues #2933, #1537, #1602; Sascha Becker blog (2026); Ackee blog (2024); Orval documentation

### Key Findings

### Known Codegen Bugs (as of Dec 2025)

- **GitHub Issue #2933 (Orval 8.2.0):** Multiple Zod schema generation bugs when using `client: 'angular'`, `schemas.type: 'zod'`, and `mode: 'split'`
  - Bug 1: Broken constraint placement - generates `export const X = export const yMin = 0;` instead of proper ordering
  - Bug 2: `@type` property name sanitized to `_type` - breaks JSON-LD/HAL responses (property names starting with @ are incorrectly sanitized)
  - Bug 3: Empty `strictObject({})` for generic Object types - infers to `Record<string, never>` which rejects all properties instead of allowing any
  - Bug 4: Near-identical schema names produce broken `.zod.ts files with dangling references (lines starting with `d.`)
  - Workaround: Post-processing scripts with regex replacements required in production

### OpenAPI Validation Limitations

- **GitHub Issue #1537 (Jul 2024):** OpenAPI validation (`validation: true`) appears ineffective - Orval generated invalid TypeScript code even when validation was enabled
  - Example: Empty `oneOf` array with discriminator mapping produced `whiteBalanceSettingsLeft: ;` (missing type)
  - IBM OpenAPI Validator detected the error and additional issues (wrong parameter name casing) that Orval missed
  - Recommendation: Validate OpenAPI specs with external tools (IBM OpenAPI Validator, spectral) before running Orval

### OpenAPI Spec Parsing Issues

- **GitHub Issue #1602 (Aug 2024):** Orval fails to complete generation on certain valid OpenAPI 3.0.1 specs
  - Issue occurs with path parameters and query parameters using schema references
  - No workaround documented; spec restructuring may be required

### Ecosystem Shift (2026)

- **Sascha Becker blog (Jan 2026):** The ecosystem has moved away from hook generation to options-based generation
  - `@hey-api/openapi-ts` is now the recommended frontrunner for OpenAPI-to-TypeScript generation
  - Orval still generates custom hooks by default (`useListPets()`, `useGetPetById()`), which is now considered outdated
  - Orval remains a solid choice if you need mock generation (MSW handlers)
  - Ackee (Jul 2024) chose Orval over Zodios due to Zodios's runtime library overhead and harder-to-debug conventions

### Accuracy Assessment

- **TypeScript type generation:** Generally accurate for standard OpenAPI patterns, but edge cases (empty oneOf, discriminator mapping) can produce invalid code
- **Zod schema generation:** Has known bugs in split mode with Angular client; requires post-processing workarounds
- **OpenAPI validation:** Not reliable for catching spec errors; external validation tools recommended
- **Hook generation pattern:** Outdated compared to options-based approach (TanStack Query v5 pattern)

### Recommendations

- Validate OpenAPI specs with external tools (IBM OpenAPI Validator, spectral) before Orval codegen
- Consider `@hey-api/openapi-ts` for new projects if mock generation is not required
- If using Orval with Zod schemas in split mode, implement post-processing workarounds for known bugs
- Use Orval primarily for MSW mock generation where it remains strong

---

## 11. Orval Mock Generation (MSW Handlers)

**Sources:** Orval MSW documentation; Medium articles on MSW + Faker.js

### Key Findings

### MSW Handler Generation Quality

- Orval generates high-quality MSW handlers using the recommended `HttpResponse` class from MSW
- Three types of generated functions:
  1. **Mock Data Generators:** Functions returning mocked values using Faker.js (`getShowPetByIdResponseMock()`)
  2. **Request Handlers:** Functions binding mock data to MSW `http.*` handlers with `HttpResponse` class
  3. **Aggregated Handlers:** Functions combining all handlers for easy setup (`getPetsMock()`)

### Content Type Support

- Orval automatically selects the correct `HttpResponse` helper based on OpenAPI spec content type:
  - `application/json` → `HttpResponse.json()`
  - `application/xml` → `HttpResponse.xml()`
  - `text/html` → `HttpResponse.html()`
  - `text/*` → `HttpResponse.text()`
  - `application/octet-stream`, `image/*` → `HttpResponse.arrayBuffer()`
- Configuration option `mock.preferredContentType` allows preferring specific content type when multiple are defined

### Mock Data Generation

- Faker.js integration provides realistic mock data (names, numbers, strings)
- Override pattern: `getShowPetByIdResponseMock({ name: 'Buddy' })` for custom values
- Dynamic responses: Pass async function for request-based data generation
- Example: `getShowPetByIdMockHandler(async (info) => { const petId = info.params.petId; return { id: Number(petId), name: `Pet ${petId}` }; })`

### MSW Best Practices Integration

- Orval follows MSW best practice for network behavior overrides using `server.use()`
- Allows test-specific overrides while keeping default happy-path handlers
- Supports `RequestHandlerOptions` (e.g., `{ once: true }`) for one-time handlers
- Integration with Vitest for testing: mock functions can track calls and assert on parameters

### Quality Assessment

- **Handler generation:** High quality - uses modern `HttpResponse` class, follows MSW best practices
- **Content type handling:** Excellent - automatic helper selection with manual override capability
- **Mock data realism:** Good - Faker.js provides realistic data, override pattern flexible
- **Test integration:** Strong - supports server.use() pattern, RequestHandlerOptions, Vitest integration

### Known Limitations

- **GitHub Issue #2934:** Same `@type` → `_type` sanitization bug affects MSW mock generation (breaks JSON-LD/HAL)
- No built-in validation that generated mocks match OpenAPI spec (external validation required)

### Recommendations

- Use Orval for MSW handler generation - quality is high and integration is excellent
- Implement post-processing to fix `@type` sanitization if using JSON-LD/HAL responses
- Validate generated mocks against OpenAPI spec using external tools if contract compliance is critical

---

## 12. Orval Schema Validation Effectiveness

**Sources:** Orval DeepWiki (Zod Schema Validation); Orval v8 documentation

### Key Findings

### Zod Integration Architecture

- Two-phase generation architecture:
  1. **Phase 1:** Intermediate Representation (IR) - transforms OpenAPI schemas to internal representation
  2. **Phase 2:** Code String Generation - converts IR to Zod validation code strings
- Benefits: Separation of concerns, easier maintenance, consistent type mapping

### Validation Coverage

- Orval generates up to five Zod validation schemas per API endpoint:
  1. URL Parameters (`{operationName}Params`)
  2. Query Parameters (`{operationName}QueryParams`)
  3. Headers (`{operationName}Header`)
  4. Request Body (`{operationName}Body`)
  5. Response Body (`{operationName}Response`)

### Type Mapping Accuracy

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

### Advanced Schema Support

- **Composition schemas:** Supports `allOf`, `oneOf`, `anyOf` with proper Zod composition
- **Enum handling:** Converts OpenAPI enums to Zod `zod.enum()`
- **Default values:** Preserves default values from OpenAPI in generated schemas
- **Discriminated unions:** Supports discriminated unions for type-safe variant handling
- **Tuple support:** Handles OpenAPI tuple schemas with `zod.tuple()`
- **Multi-type schemas:** Supports OpenAPI 3.1 multi-type schemas
- **File type handling:** Special handling for file uploads with form data validation

### Configuration Options

- **Strict mode:** Configurable strict mode for request/response/query/param/header/body validation
- **Type coercion:** Optional type coercion for string-to-number conversions
- **Custom preprocessing:** Preprocessing functions for data transformation before validation
- **DateTime options:** Configurable date/time format validation with version-specific handling
- **Selective schema generation:** Can generate only specific validation schemas (e.g., body only)

### Zod Version Compatibility

- Automatic detection of Zod version (v3 vs v4)
- API differences handled transparently
- Compatibility functions for version-specific features
- String format patterns supported in v4 only

### Validation Effectiveness Assessment

- **Runtime validation:** Excellent - provides comprehensive runtime type checking complementing TypeScript compile-time types
- **Type mapping accuracy:** High - standard OpenAPI types mapped correctly to Zod validators
- **Advanced schema support:** Strong - supports complex compositions (allOf, oneOf, anyOf), discriminated unions, tuples
- **Configuration flexibility:** Excellent - granular control over strict mode, coercion, preprocessing
- **Version compatibility:** Good - automatic Zod version detection with compatibility layer

### Known Limitations

- **GitHub Issue #2933:** Zod schema generation has known bugs in split mode (see Code Generation section)
- **Performance:** Runtime validation adds overhead; use only at system boundaries where data trust is required
- **Complex schemas:** Very complex nested schemas may require manual tuning for optimal validation

### Recommendations

- Use Orval's Zod validation for runtime type checking at API boundaries (requests/responses)
- Enable strict mode for production to catch data contract violations
- Use selective schema generation if full validation overhead is unnecessary
- Implement post-processing workarounds if using split mode with Angular client (see known bugs)
- Consider using external OpenAPI validation tools (IBM OpenAPI Validator) in addition to Orval's validation

---

## 13. CVE Mapping Details

**Source:** Lares Labs OWASP Agentic AI Top 10: Threats in the Wild (2025-2026), NIST NVD, CISA KEV Catalog

### Key Findings

- **Lares Labs** is a security research organization that published comprehensive CVE mappings for OWASP Agentic Security Initiative (ASI) Top 10
- CVE mappings are maintained through real-world incident research and vulnerability discovery
- ASI01-ASI05 have assigned CVEs; ASI06-ASI10 are emerging risk categories with documented incidents but no CVEs assigned yet

### CVE Mapping Completeness Table

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

### Validation Findings

- TASK INFORMATION PARTIALLY INCORRECT in 11-STRAT-BLUEPRINT.md
- **Error 1:** ASI03 incorrectly lists CVE-2025-32711 (EchoLeak) - this CVE belongs to ASI01, not ASI03
- **Error 2:** ASI05 incorrectly lists CVE-2025-53773 (GitHub Copilot YOLO Mode) - this CVE belongs to ASI01, not ASI05
- **Corrected:** ASI03 has no assigned CVEs (only incidents: Copilot Studio Connected Agents, CoPhish Attack, Copilot Studio Public-by-Default)
- **Corrected:** ASI05 CVEs are CVE-2025-54135 (CurXecute), CVE-2025-54136 (MCPoison), CVE-2025-59944 (Cursor Case-Sensitivity), Claude Desktop RCE, plus 24 CVEs from IDEsaster Research

### Gaps

- ASI06-ASI10 have no CVEs assigned yet as of April 2026 - these are emerging risk categories
- CVE discovery is ongoing, especially for ASI05 (Unexpected Code Execution) with new CVEs discovered monthly
- No automated CVE-to-ASI mapping exists - requires manual research and incident correlation

---

## 14. ASI Coverage Analysis

### Coverage Matrix with Missing Controls

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

### Coverage Analysis

- **ASI01-ASI05:** Higher coverage due to established CVEs and mature mitigation patterns
- **ASI06-ASI10:** Lower coverage due to emerging status and lack of CVEs
- **Critical gaps:** ASI04 (supply chain), ASI05 (code execution), ASI10 (rogue agents) require immediate attention
- **Testing priority:** Focus on ASI06-ASI10 incident-based testing since no CVEs exist for validation

---

## 15. Automated CVE Mapping Update Process

### NIST NVD API Integration (v2.0)

- **Endpoint:** `https://services.nvd.nist.gov/rest/json/cves/2.0`
- **Parameters:** cpeName, cveId, cvssV3Severity, cweId, isExactMatch
- **Pagination:** Offset-based with startIndex and resultsPerPage (max 2000 per request)
- **Rate limits:** 5 requests per rolling 30-second window (NIST policy)
- **Prioritization (as of April 15, 2026):** NIST now prioritizes CVE enrichment for:
  - CVEs in CISA KEV Catalog (enriched within 1 business day)
  - CVEs for federal government software
  - CVEs for critical software (EO 14028 definition)
  - Other CVEs marked as "Lowest Priority - not scheduled for immediate enrichment"

### CISA KEV Catalog Integration

- **Endpoint:** CISA Known Exploited Vulnerabilities Catalog
- **Purpose:** Real-world exploited vulnerabilities requiring immediate action
- **Automation:** Poll KEV catalog daily for new entries, cross-reference with ASI categories
- **Due dates:** KEV entries have specific due dates for federal agency remediation

### Automated Update Workflow

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
             - Commit CVE mapping updates to 70-TESTING.md
             - Update ASI Coverage matrix with new controls
             - Version control with Git commit messages
```

### Automation Tools & Configuration

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
          python scripts/update_cve_mapping.py docs/plan/70-TESTING.md
      - name: Commit Changes
        run: |
          git config user.name "CVE Bot"
          git config user.email "cve-bot@example.com"
          git add docs/plan/70-TESTING.md
          git commit -m "chore: update CVE mapping $(date +%Y-%m-%d)"
          git push
```

### Frequency and Triggers

- **Daily automated update:** 00:00 UTC cron job queries NVD and CISA APIs
- **Manual trigger:** GitHub Actions workflow_dispatch for on-demand updates
- **Event-driven:** Webhook from NVD (if available) for immediate critical CVE notification
- **Manual review:** Monthly review of ASI06-ASI10 for emerging incident patterns

### Limitations and Considerations

- **NVD API rate limits:** 5 requests/30s requires careful batching and pagination
- **NVD prioritization changes:** As of April 2026, NVD only enriches priority CVEs; others marked "Lowest Priority"
- **Manual correlation required:** CWE-to-ASI mapping is not automated; requires security researcher review
- **Emerging categories:** ASI06-ASI10 have no CVEs; rely on incident research (Lares Labs, OWASP community)
- **False positives:** Automated correlation may misclassify CVEs; manual verification required before documentation updates

---

*End of document.*
