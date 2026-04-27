Trevor — here’s a structured, AI‑executable task list. Every task is designed to be completed through online research, documentation synthesis, or specification drafting (no runtime execution required). Tasks are small, atomic, and chainable.

---

## AI-Powered Pre‑Development Task List

**How to use:**  
Each **Parent Task** is a deliverable. **Subtasks** are the discrete steps an AI agent can execute. “Context” lists the documents you’ve already produced that contain the source material.

---

### Research Tasks

#### R‑AI‑01: Gemma 4 E2B Tool‑Calling Performance Baseline 
| Subtask | Action |
|--------|--------|
| R‑AI‑01‑1 | Search Google’s official Gemma 4 technical reports, model cards, and release blog posts for tool‑calling accuracy benchmarks. |
| R‑AI‑01‑2 | Search academic repositories (arXiv, Semantic Scholar) for independent evaluations of Gemma 4 E2B tool‑use. |
| R‑AI‑01‑3 | Screen community benchmarks on Hugging Face, Reddit (r/LocalLLaMA), and Ollama forums for real‑world tool‑calling pass rates. |
| R‑AI‑01‑4 | Compile findings into a report with a summary table, confidence levels, and a hard‑number verdict on whether it regularly exceeds 90% precision. |
| **Expected output** | `research/gemma4-e2b-tool-calling-benchmark.md` |
| **Context** | Rules AI‑01, AI‑16; Milestone Block 0B; AI Core doc section 7 |
| **Verdict** | INSUFFICIENT DATA - No public benchmarks found. Custom evaluation required before Week 5 decision point. |

#### R‑AI‑02: Qwen3.5 4B TTFT on Consumer CPU
| Subtask | Action |
|--------|--------|
| R‑AI‑02‑1 | Find Ollama‑published performance data and user reports for Qwen3.5 4B with GGUF Q4_K_M on CPU (Intel/AMD AVX2, Apple Silicon). |
| R‑AI‑02‑2 | Collect third‑party benchmarks from Reddit, LM Studio forums, and GitHub discussions. |
| R‑AI‑02‑3 | Document typical TTFT (time to first token) and tokens per second under real‑world chat+tool‑use scenarios. |
| R‑AI‑02‑4 | Provide a recommended hardware tier and estimated user‑facing latency for free‑tier users. |
| **Expected output** | `research/qwen3.5-4b-cpu-performance.md` |
| **Context** | Rules AI‑02, BE‑01; Performance budgets (TTFT ≤2s) |
| **Verdict** | INSUFFICIENT DATA - No direct CPU benchmarks found in publicly accessible sources. Reddit community data behind verification walls. Empirical testing required before Week 5 decision point. Conservative estimate: TTFT 1.5-2.5s on Tier 1 hardware (likely meets ≤2s budget, but low confidence). |

#### R‑AI‑03: LiteLLM Budget Enforcement Validation
| Subtask | Action |
|--------|--------|
| R‑AI‑03‑1 | Study LiteLLM ≥1.83.7 docs for budget limits, hard‑stop enforcement, and `x‑litellm‑tags` propagation. |
| R‑AI‑03‑2 | Search GitHub issues for known bugs in budget enforcement with Claude/OpenAI backends. |
| R‑AI‑03‑3 | Determine the exact configuration required to return 429s on budget exhaustion and emit cost headers. |
| R‑AI‑03‑4 | Write a "how‑to‑configure" guide for the project's proxy setup. |
| **Expected output** | `research/litellm-budget-hard-stop-config.md` |
| **Context** | Rules AI‑11–AI‑13; 60-AI-CORE.md cost section |
| **Verdict** | COMPLETED - Critical finding: LiteLLM returns HTTP 400, not HTTP 429 for budget exhaustion. FastAPI middleware required to transform 400 → 429. Soft budget alerts require Enterprise license. Known bugs documented with workarounds. |

#### R‑AI‑04: react‑big‑calendar + React Compiler Compatibility
| Subtask | Action |
|--------|--------|
| R‑AI‑04‑1 | Search the React Compiler working group discussions and react‑big‑calendar GitHub issues for any known incompatibilities. |
| R‑AI‑04‑2 | Check if react‑big‑calendar uses layout‑triggering animations or patterns that violate FE‑22 (layout property animations). |
| R‑AI‑04‑3 | Produce a memo on whether a “use no memo” directive is needed and any expected performance impact. |
| **Expected output** | `research/react-big-calendar-compiler-compat.md` |
| **Context** | Rules FE‑06, FE‑13, FE‑22; 21-PLAN-MILESTONES.md calendar section |

#### R‑AI‑05: DOMPurify XSS Test Matrix Validation
| Subtask | Action |
|--------|--------|
| R‑AI‑05‑1 | Collect known XSS bypass CVEs for DOMPurify 3.0.1–3.3.3 and confirm 3.4.0 patches them. |
| R‑AI‑05‑2 | Build a test‑case matrix for STRICT, RICH, and EMAIL profiles based on OWASP XSS Filter Evasion Cheat Sheet. |
| R‑AI‑05‑3 | Document the expected sanitization behavior for each profile. |
| **Expected output** | `research/dompurify-xss-test-matrix.md` |
| **Context** | Rules SEC‑01, SEC‑28; 50-XCT-UI.md sanitisation section |

#### R‑AI‑06: Supabase Realtime Memory Profile
| Subtask | Action |
|--------|--------|
| R‑AI‑06‑1 | Review Supabase Realtime documentation for per‑channel memory allocations and known limits. |
| R‑AI‑06‑2 | Search community forums for reports of high memory usage with many channels or large payloads. |
| R‑AI‑06‑3 | Draft a recommended channel‑usage guideline (max per user, max payload size) to stay under 40MB. |
| **Expected output** | `research/supabase-realtime-memory-limits.md` |
| **Context** | Rules BE‑07, BE‑11; 80-OPS-PERFORMANCE.md |

#### R‑AI‑07: PowerSync Sync Stream Feasibility
| Subtask | Action |
|--------|--------|
| R‑AI‑07‑1 | Read PowerSync documentation for Sync Streams (beta) with soft‑delete and ULID primary keys. |
| R‑AI‑07‑2 | Identify any known limitations with bidirectional sync and conflict resolution. |
| R‑AI‑07‑3 | Produce a compatibility assessment with the project’s offline‑first patterns. |
| **Expected output** | `research/powersync-sync-stream-assessment.md` |
| **Context** | Rules BE‑08, BE‑09; ADR_084; 50-XCT-DATA.md offline section |

---

### Planning & Documentation Artifact Tasks

#### P‑API‑01: Expand OpenAPI 3.1 Specification (Phase 0 resources)
| Subtask | Action |
|--------|--------|
| P‑API‑01‑1 | Extract all resource types from the SQL DDL (`32-arch-database-schema.sql`) and component registry that are needed in Phase 0. |
| P‑API‑01‑2 | For **events**: draft CRUD paths (`/v1/events`, `/v1/events/{id}`) with query params (time range, recurrence), request/response schemas, pagination. |
| P‑API‑01‑3 | For **tasks**: draft paths with status/assignee filters, subtask nesting, bulk reordering. |
| P‑API‑01‑4 | For **projects**: draft paths with status, priority, owner filters. |
| P‑API‑01‑5 | For **chat**: define `/v1/chat/stream` (SSE), thread/message CRUD. |
| P‑API‑01‑6 | For **notifications**: list, mark‑read, preferences endpoints. |
| P‑API‑01‑7 | For **cost**: `/v1/cost/forecast`, `/v1/cost/logs` with TimescaleDB hypertable awareness. |
| P‑API‑01‑8 | For **auth/org**: org switching, passkey enrollment, session management. |
| P‑API‑01‑9 | Add common schemas (Pagination, Error, ValidationError) and ensure all responses conform. |
| P‑API‑01‑10 | Validate the full YAML against OpenAPI 3.1 JSON Schema. |
| **Expected output** | `34-arch-endpoints-schema.yaml` (complete) |
| **Context** | Existing `34-arch-endpoints-schema.yaml`, `32-arch-database-schema.sql`, `33-ARCH-ENDPOINTS.md`, `component-registry.yaml` |

#### P‑DB‑01: Derive Prisma Schema from SQL DDL
| Subtask | Action |
|--------|--------|
| P‑DB‑01‑1 | Map every SQL table to a Prisma model, preserving column types, defaults, and constraints. |
| P‑DB‑01‑2 | Convert foreign keys to Prisma relations, marking cascade behaviour. |
| P‑DB‑01‑3 | Add `@@map` and `@map` attributes to align with existing snake_case table/column names. |
| P‑DB‑01‑4 | Mark `updatedAt` fields with `@updatedAt` and `createdAt` with `@default(now())`. |
| P‑DB‑01‑5 | Document which tables live in `public` schema and which use `auth` / `extensions` schemas. |
| P‑DB‑01‑6 | Provide a manual migration note for `ai_cost_log` hypertable (TimescaleDB) since Prisma can’t create it. |
| **Expected output** | `prisma/schema.prisma` |
| **Context** | `32-arch-database-schema.sql`, `31-ARCH-DATABASE.md`, rules BE‑08, BE‑09, BE‑18 |

#### P‑STORE‑01: Define Zustand Store TypeScript Interfaces
| Subtask | Action |
|--------|--------|
| P‑STORE‑01‑1 | For each slice listed in `01-PLAN-ZUSTAND.md`, infer the state shape from the planned features in `21-PLAN-MILESTONES.md` and the component registry. |
| P‑STORE‑01‑2 | Draft the initial state object and action signatures (e.g., `setCurrentOrg`, `addMessage`). |
| P‑STORE‑01‑3 | Define persist options: storage key, version number, `partialize` fields (from slice table), `migrate` stub. |
| P‑STORE‑01‑4 | Ensure cross‑slice access follows rule FE‑12 (use `get()`). |
| **Expected output** | `packages/shared/src/stores/types.ts` (or similar) or a specification document `spec/zustand-slice-interfaces.md` |
| **Context** | `01-PLAN-ZUSTAND.md`, `component-registry.yaml`, rules FE‑10–FE‑12 |

#### P‑TOOL‑01: MCP Tool JSON Contracts
| Subtask | Action |
|--------|--------|
| P‑TOOL‑01‑1 | Enumerate all agent tools: `detect_conflicts`, `create_event`, `update_event`, `delete_event`, `create_task`, `update_task`, `delete_task`, `send_email`, `read_email`, `search`, etc. |
| P‑TOOL‑01‑2 | For each tool, write a JSON Schema for input parameters, using OpenAPI `#/components/schemas` where possible. |
| P‑TOOL‑01‑3 | Assign a `preferred_executor` tier (code / lightweight model / powerful model) based on the Intent Dispatcher logic in `ai-architecture.md`. |
| P‑TOOL‑01‑4 | Document output schemas and error responses. |
| **Expected output** | `specs/mcp-tool-contracts.yaml` or `/tools/*.json` |
| **Context** | `ai-architecture.md`, Intent Dispatcher section, `10-STRAT-PRD.md` jobs |

#### P‑DOCKER‑01: Local Development Docker Compose
| Subtask | Action |
|--------|--------|
| P‑DOCKER‑01‑1 | Draft a `docker-compose.yml` that includes: FastAPI dev server, PostgreSQL (supabase‑local), Ollama with Gemma 4 E2B and Qwen3.5 4B models, ClamAV sidecar, Y‑Sweet, and mock servers for Nylas/Stripe. |
| P‑DOCKER‑01‑2 | Add volume mounts for hot‑reload and a startup health check sequence. |
| P‑DOCKER‑01‑3 | Create a companion `.env.dev` file with all required variables and safe defaults. |
| **Expected output** | `docker-compose.yml`, `.env.dev` |
| **Context** | `38-ARCH-DEPLOYMENT.md`, `versions.yaml`, `80-OPS-MANUAL.md` |

#### P‑AGENTS‑01: Agent Instruction File (AGENTS.md)
| Subtask | Action |
|--------|--------|
| P‑AGENTS‑01‑1 | Collect all project constraints from `00-RULES.yaml` and `01-PLAN-DECISIONS.md` into a concise “immutable rules” section. |
| P‑AGENTS‑01‑2 | Document the monorepo structure, build system, and exact commands for lint/test/build. |
| P‑AGENTS‑01‑3 | List all architectural boundaries (e.g., “Prisma only in FastAPI backend”, “never import dnd‑kit directly, use façade”). |
| P‑AGENTS‑01‑4 | Specify the agent’s output conventions (TypeScript, code style, test file naming). |
| **Expected output** | `AGENTS.md` (root of repo) |
| **Context** | `00-RULES.yaml`, `30-ARCH-OVERVIEW.md`, `51-XCT-DEPENDENCIES.md` |

#### P‑ROUTES‑01: Frontend Route Tree & Code Splitting Map
| Subtask | Action |
|--------|--------|
| P‑ROUTES‑01‑1 | Map every page and major sub‑view from `component-registry.yaml` to a URL pattern. |
| P‑ROUTES‑01‑2 | Define lazy‑load boundaries for heavy dependencies (Monaco, Yjs, LiveKit, react‑big‑calendar). |
| P‑ROUTES‑01‑3 | Assign a Suspense fallback and error boundary to each lazy route. |
| P‑ROUTES‑01‑4 | Produce a route tree diagram and a table with bundle budgets per chunk. |
| **Expected output** | `specs/route-tree.md` |
| **Context** | `component-registry.yaml`, `80-OPS-PERFORMANCE.md` bundle budgets, `50-XCT-UI.md` |

#### P‑PROMPTS‑01: Version‑Controlled Prompt Library
| Subtask | Action |
|--------|--------|
| P‑PROMPTS‑01‑1 | Review the AI architecture and product jobs for required prompts: orchestrator system prompt, tool‑use prompts, verifier instructions, guardrail prompts. |
| P‑PROMPTS‑01‑2 | Draft each prompt with placeholders for dynamic context (org name, user timezone, etc.). |
| P‑PROMPTS‑01‑3 | Add semantic versioning guidance (ADR_024) and a changelog template. |
| **Expected output** | `prompts/` directory with `.yaml` or `.md` files per prompt, plus an index. |
| **Context** | `60-AI-CORE.md` sections 1, 4, 5, 7; `01-PLAN-DECISIONS.md` ADR_024 |

#### P‑CI‑01: GitHub Actions Workflow Templates
| Subtask | Action |
|--------|--------|
| P‑CI‑01‑1 | Based on the testing strategy and blocking gates, create a PR workflow YAML with jobs: typecheck (tsc + tsgo), lint, unit tests, component tests, RLS tests (pgTAP), Orval codegen integrity check, Schemathesis contract test, Grype Docker scan, Docker build. |
| P‑CI‑01‑2 | Add a separate nightly workflow for AI evaluation (DeepEval + AgentAssay). |
| P‑CI‑01‑3 | Implement credential isolation as described in `35-ARCH-SECURITY.md` (no credentials in scanner jobs). |
| **Expected output** | `.github/workflows/pr.yml`, `.github/workflows/nightly-ai-eval.yml` |
| **Context** | `70-TESTING-STRATEGY.md`, `35-ARCH-SECURITY.md`, `80-OPS-MANUAL.md` |

#### P‑GUARD‑01: Guardrail Configuration Files
| Subtask | Action |
|--------|--------|
| P‑GUARD‑01‑1 | Research public lists of PII patterns (GDPR definitions) and compile a regex library for input guard. |
| P‑GUARD‑01‑2 | Curate a list of known jailbreak and prompt injection strings from OWASP and academic papers. |
| P‑GUARD‑01‑3 | Set initial toxicity thresholds (using Perspective API or similar taxonomies) as configurable YAML. |
| P‑GUARD‑01‑4 | Write tool authorisation rules: which tools require explicit approval, which are auto‑approved. |
| **Expected output** | `config/guardrails/pii-patterns.yaml`, `config/guardrails/jailbreak-phrases.yaml`, `config/guardrails/toxicity-thresholds.yaml`, `config/guardrails/tool-auth.yaml` |
| **Context** | Rules AI‑07–AI‑10; `60-AI-CORE.md` safety section |

#### P‑SEED‑01: PII‑Free Seed Data Fixture Schema
| Subtask | Action |
|--------|--------|
| P‑SEED‑01‑1 | List all core entities that need seed data (organisations, users, events, tasks, projects, messages). |
| P‑SEED‑01‑2 | Define a JSON/YAML schema for seed data that uses Faker‑compatible field types. |
| P‑SEED‑01‑3 | Create an example seed dataset with one org, 5 users, 20 events, 30 tasks, and a few chat threads. |
| **Expected output** | `db/seeds/schema.yaml`, `db/seeds/dev-seed.yaml` |
| **Context** | `32-arch-database-schema.sql`, `21-PLAN-MILESTONES.md` Phase 0 features |

#### P‑TIER‑01: Subscription Tier Feature Gates Specification
| Subtask | Action |
|--------|--------|
| P‑TIER‑01‑1 | Analyse product goals and AI cost models to propose which features are Free/Pro/Team/Enterprise. |
| P‑TIER‑01‑2 | Draft a feature‑gating matrix: model access, API rate limits, offline sync availability, collaboration tools, storage quotas. |
| P‑TIER‑01‑3 | Propose default cost budgets per tier based on research from R‑AI‑01 and R‑AI‑02. |
| **Expected output** | `specs/tier-feature-gates.md` |
| **Context** | `10-STRAT-PRD.md` monetization, `60-AI-CORE.md` cost section, open question Q‑003 |

#### P‑EVENT‑01: AsyncAPI Contracts for Push Events
| Subtask | Action |
|--------|--------|
| P‑EVENT‑01‑1 | Identify all server‑to‑client event streams: Nylas webhook forward, Supabase Realtime broadcast, notification push. |
| P‑EVENT‑01‑2 | For each, write an AsyncAPI 3.0 specification file describing the channel, payload schema, and security. |
| P‑EVENT‑01‑3 | Validate payloads against the existing database schemas. |
| **Expected output** | `specs/asyncapi/nylas-webhooks.yaml`, `specs/asyncapi/realtime-changes.yaml`, `specs/asyncapi/notifications.yaml` |
| **Context** | `34-arch-endpoints-schema.yaml`, `80-OPS-MANUAL.md` Nylas section, `37-ARCH-FLOWS.md` |

#### P‑EVAL‑01: Golden Evaluation Datasets
| Subtask | Action |
|--------|--------|
| P‑EVAL‑01‑1 | Define the structure of an evaluation dataset (input, expected output, metadata). |
| P‑EVAL‑01‑2 | Using the product jobs (J001, J002) and component registry, create 10–20 scenario‑based test cases for conflict detection accuracy and chat tool‑calling. |
| P‑EVAL‑01‑3 | Provide a README with instructions on how to run evaluations via DeepEval. |
| **Expected output** | `evaluation/datasets/conflict-detection.json`, `evaluation/datasets/chat-tool-calling.json` |
| **Context** | `70-TESTING-STRATEGY.md` section 3.3, `10-STRAT-PRD.md` jobs |

#### P‑AIBOM‑01: AI Bill of Materials for Initial Models
| Subtask | Action |
|--------|--------|
| P‑AIBOM‑01‑1 | For Gemma 4 E2B, Qwen3.5 4B, Claude Sonnet 4.6, and Opus 4.7, gather public metadata: training data provenance, safety benchmarks, quantization information. |
| P‑AIBOM‑01‑2 | Generate a CycloneDX‑compatible JSON file per model with the required fields (name, version, supplier, hashes, pedigree). |
| **Expected output** | `ai-bom/gemma4-e2b.cdx.json`, `ai-bom/qwen3.5-4b.cdx.json`, `ai-bom/claude-sonnet-4.6.cdx.json`, `ai-bom/claude-opus-4.7.cdx.json` |
| **Context** | `60-AI-CORE.md` model registry, `36-ARCH-TECH-VALIDATION.md` |



**Next step:** If you’d like, I can begin executing any of these tasks in a sequential order, starting with the highest‑blocker research (R‑AI‑01) or the longest‑running artifact (P‑API‑01). Choose the thread.