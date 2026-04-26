# 09-REF-DoD.md

```
---
steering: TO PARSE — READ INTRO
file_name: 00-DEFINITION-OF-DONE.md
document_type: governance
tier: strategic
status: stable
owner: Trevor (Solo Founder)
description: Hard gates that separate "planning" from "execution." Defines exactly what must be true before Phase 0 Block 0A code generation begins, and what "done" means for each subsequent block. Designed to prevent analysis paralysis while ensuring no critical gap goes unresolved.
last_updated: 2026-04-26
version: 1.0
dependencies: [00-PLANNING-BACKLOG.md, 01-PLAN-MILESTONES.md, 00-PHASE0-PRE-MORTEM.md, TASKS.md]
related_adrs: []
related_rules: []
complexity: medium
risk_level: critical
---

# Definition of Done — Planning vs. Execution

## README: The Line in the Sand

This document exists to answer one question: "When do we stop planning and start building?"

Without a clear answer, two failure modes emerge:
- **Premature execution**: Coding starts before critical decisions are made, forcing expensive rework mid-stream.
- **Analysis paralysis**: Planning continues indefinitely because every resolved question suggests two new ones.

This document defines exact, verifiable criteria. When these criteria are met, Trevor gives the order: "Begin Phase 0 Block 0A code generation." Not before.

**Principle from the pre-mortem (Scenario 5):** The P0 backlog is capped at 13 items. If a new P0 is discovered, an existing P0 must be demoted to P1 or resolved. This prevents infinite expansion.

**Research basis:**
- Microsoft's spec playbook: "Define the smallest testable slice before coding. Clear outcomes, non-goals, and acceptance criteria prevent scope creep." 
- The GitHub 2,500+ repo analysis found that teams with explicit "Definition of Done" for planning phases had 34% fewer reverted PRs.
- DECIDER framework (sventorben, March 2026): "Turn architectural decisions into machine-readable constraints... CI enforces them." Our DoD creates CI-enforceable gates.


## Part 1: The Master Gate — "Planning Complete for Phase 0"

The following criteria must ALL be `✅ RESOLVED` before any AI agent writes production code for Phase 0. Trevor signs off on each.

### Gate 1: Core Specifications Resolved

| ID | Criterion | Current Status | Verification |
|----|-----------|----------------|--------------|
| G1.1 | Zustand slice TypeScript interfaces defined (`01-PLAN-ZUSTAND-TYPES.md`) | 🔴 | File exists; all Phase 0 slices have complete interfaces |
| G1.2 | Database DDL for all Phase 0 tables generated (`02-ARCH-DATABASE-DDL.sql`) | 🔴 | DDL executes without errors on a fresh Supabase project; RLS enabled on all tables |
| G1.3 | OpenAPI 3.1 schemas for Phase 0 endpoints written (`02-ARCH-ENDPOINTS-SCHEMA.yaml`) | 🔴 | Schemathesis can validate against the schema without errors |
| G1.4 | Component props and state machines for Phase 0 critical-path components defined | 🔴 | At minimum: ChatPage, MonthView, KanbanBoard, AttentionQueue, DecisionPacket |
| G1.5 | Error taxonomy and user-facing message catalogue complete (`05-XCT-ERROR-TAXONOMY.md`) | 🔴 | All error codes from the Lexicon have message templates |
| G1.6 | Conflict detection UX flow fully specified (`10-UX-CONFLICT-FLOW.md`) | 🔴 | All 8 states from BP-006 defined; resolution language reviewed by Trevor |
| G1.7 | First-time user onboarding flow specified (`10-UX-ONBOARDING-FLOW.md`) | 🔴 | Includes demo data seeder ("Quick Start" button); step-by-step guidance |
| G1.8 | Agent tool-calling feedback loop UX specified (`10-UX-TOOL-CALLING.md`) | 🔴 | All states for ToolCallDisclosure, ThinkingTracePanel defined |

### Gate 2: Critical Decisions Made

| ID | Criterion | Current Status | Verification |
|----|-----------|----------------|--------------|
| G2.1 | Free vs. Pro feature matrix finalized (`00-STRAT-TIER-MATRIX.md`) | 🔴 | Tier limits are numeric, not aspirational; upgrade triggers are clear |
| G2.2 | Stripe integration pattern documented (`02-ARCH-STRIPE-INTEGRATION.md`) | 🔴 | Synchronous pre-call budget check pattern specified; local vs. cloud metering distinct |
| G2.3 | Google Calendar API quotas and OAuth strategy confirmed (`02-ARCH-CALENDAR-API-RESEARCH.md`) | 🔴 | Rate limits known; OAuth verification path understood |
| G2.4 | Local model tool-calling benchmarks completed (`06-AI-TOOL-CALLING-BENCHMARKS.md`) | 🔴 | Gemma 4 E2B AND Qwen3.5 4B independently benchmarked; go/no-go decision for Block 0B documented |

### Gate 3: Tooling & Environment Ready

| ID | Criterion | Current Status | Verification |
|----|-----------|----------------|--------------|
| G3.1 | `.windsurfrules` file created and tested | 🔴 | AI agent in Windsurf produces code that passes basic rule check |
| G3.2 | `START-HERE.md` written and validated | 🔴 | A fresh AI session receiving this file correctly identifies the 3 required reading files |
| G3.3 | CI pipeline skeleton running (typecheck, lint) | 🔴 | Green build on a trivial commit |
| G3.4 | Supabase project provisioned, local dev environment documented | 🔴 | `supabase start` succeeds; FastAPI connects to it |
| G3.5 | Ollama installed, Gemma 4 E2B pulled, tool-calling test suite executable | 🔴 | 40+ test cases run; pass rate recorded |

### Gate 4: Risk Mitigations Active

| ID | Criterion | Current Status | Verification |
|----|-----------|----------------|--------------|
| G4.1 | Phase 0 pre-mortem reviewed and acknowledged | ✅ | This document exists and has been read; early warning dashboard is empty |
| G4.2 | At least 3 external testers identified and briefed | 🔴 | Names, emails, and expected demo dates recorded |
| G4.3 | Practice run completed (Item 10) | 🔴 | A toy project using the same stack was built, reviewed, and lessons documented |
| G4.4 | `00-WORKFLOW-REVIEW.md` created and tested on the practice run | 🔴 | Review checklist used successfully; Trevor's review time per PR <20 minutes |

### Gate 5: Execution Readiness

| ID | Criterion | Current Status | Verification |
|----|-----------|----------------|--------------|
| G5.1 | Trevor has blocked 2 weeks of focused execution time | 🔴 | Calendar blocked; no major competing commitments |
| G5.2 | All P0 planning backlog items are `RESOLVED` | 🔴 | `00-PLANNING-BACKLOG.md` shows 0 P0 items in `NOT STARTED` status |
| G5.3 | Trevor explicitly signs off: "Begin Phase 0 Block 0A" | 🔴 | Signed and dated in this document (see signature block below) |

### Signature Block

```
I, Trevor, confirm that all Gate 1–5 criteria above have been met.
Phase 0 Block 0A code generation is authorized to begin.

Signed: _____________________
Date: _____________________
```


## Part 2: Block-Level Definitions of Done

Once Phase 0 execution begins, each block has its own exit criteria. An AI agent must not start Block N+1 until Block N's criteria are all `✅`.

### Block 0A: Platform Skeleton — DoD

| ID | Criterion | Status |
|----|-----------|--------|
| 0A-D1 | User can sign up with email/password and create an organization | 🔴 |
| 0A-D2 | JWT contains org_id and user_role claims (verified by pgTAP) | 🔴 |
| 0A-D3 | Org switcher correctly clears query cache and reconnects Realtime | 🔴 |
| 0A-D4 | CI pipeline (typecheck, lint, RLS tests) passes on every PR | 🔴 |
| 0A-D5 | FastAPI is deployed to Fly.io; Vite SPA deployed to Vercel; they communicate over HTTPS | 🔴 |
| 0A-D6 | `supabase start` works on Trevor's local machine; FastAPI connects successfully | 🔴 |

### Block 0B: Local AI Infrastructure — DoD

| ID | Criterion | Status |
|----|-----------|--------|
| 0B-D1 | Ollama serves Gemma 4 E2B and Qwen3.5 4B via Docker Compose | 🔴 |
| 0B-D2 | LiteLLM proxy routes to Ollama by default, Claude Sonnet 4.6 when authorized | 🔴 |
| 0B-D3 | Model registry populated with SHA-256 checksums and capability scores | 🔴 |
| 0B-D4 | Tool-calling test suite passes on local models at ≥90% (or documented fallback choice) | 🔴 |
| 0B-D5 | Intent Dispatcher correctly routes a test tool call to code, then lightweight model, then powerful model | 🔴 |
| 0B-D6 | Free-tier routing policy enforced: cloud API calls fail with clear error if user is on Free tier | 🔴 |

### Block 0C: Chat + Agent Tool Calling — DoD

| ID | Criterion | Status |
|----|-----------|--------|
| 0C-D1 | Chat UI renders with ThreadList, MessageList, ChatInput, MessageBubble | 🔴 |
| 0C-D2 | User can send a message and receive a streaming response from the local orchestrator | 🔴 |
| 0C-D3 | Agent can call create_calendar_event, update_calendar_event, list_tasks, create_task tools successfully | 🔴 |
| 0C-D4 | Guardrails input layer blocks PII, jailbreak attempts, and toxic input (verified in test) | 🔴 |
| 0C-D5 | Guardrails output layer detects clear hallucination cases (warning, not blocking in Phase 0) | 🔴 |
| 0C-D6 | ToolCallDisclosure shows tool execution: pending, success, failure states | 🔴 |

### Block 0D: Data Apps — Calendar & Tasks — DoD

| ID | Criterion | Status |
|----|-----------|--------|
| 0D-D1 | User can create, edit, delete calendar events (manual, not via agent) | 🔴 |
| 0D-D2 | User can create, edit, delete tasks and drag them between Kanban columns | 🔴 |
| 0D-D3 | Google Calendar OAuth flow succeeds; events are imported (read-only) | 🔴 |
| 0D-D4 | Recurring events expand correctly on all 33 RFC 5545 test cases + DST matrix | 🔴 |
| 0D-D5 | Tasks with due dates appear as optional overlay on calendar views | 🔴 |
| 0D-D6 | All CRUD operations are optimistic with 5s undo per XCT_02 | 🔴 |

### Block 0E: Dashboard & Conflict Agent — DoD

| ID | Criterion | Status |
|----|-----------|--------|
| 0E-D1 | Dashboard renders ActivityFeed and AttentionQueue | 🔴 |
| 0E-D2 | Conflict detection engine correctly identifies overlapping events and task deadlines | 🔴 |
| 0E-D3 | When a conflict is detected, a notification appears with Reschedule / Move Task / Ignore buttons | 🔴 |
| 0E-D4 | User can resolve a conflict via the notification; resolution triggers tool call and confirmation | 🔴 |
| 0E-D5 | All agent decisions logged to audit_logs (WORM, hash-chained) | 🔴 |
| 0E-D6 | ai_cost_log records token usage for every AI call, tagged with org_id and feature | 🔴 |

### Block 0F: Monetization & Polish — DoD

| ID | Criterion | Status |
|----|-----------|--------|
| 0F-D1 | Stripe metered billing records AI usage; test charge succeeds | 🔴 |
| 0F-D2 | Free tier user cannot access cloud models (clear error message) | 🔴 |
| 0F-D3 | Pro tier user can access Sonnet 4.6; usage is metered and billed | 🔴 |
| 0F-D4 | CSP headers are enforced (nonce strategy) in production; Report-Only in staging | 🔴 |
| 0F-D5 | Rate limiting returns 429 with Retry-After header when limit exceeded | 🔴 |
| 0F-D6 | Pre-launch security audit complete: CSP, RLS, rate limiting, MCP tool auth all verified | 🔴 |

### Phase 0 Exit Gate

| ID | Criterion | Status |
|----|-----------|--------|
| EXIT-1 | One external user signs up, connects Google Calendar, creates tasks, and sees the agent detect a scheduling conflict — all without Trevor's intervention | 🔴 |


## Part 3: What "Not Done" Looks Like (Negative Examples)

Per the W3C machine-consumable spec principle, every DoD must include counter-examples. These are common misinterpretations that do NOT satisfy the criteria.

| Criterion | NOT Satisfied By |
|-----------|-----------------|
| G3.1 (`.windsurfrules` tested) | A `.windsurfrules` file that exists but has never been tested with an actual AI code generation session |
| G1.6 (Conflict UX specified) | A spec that describes only the happy path (conflict detected → resolved) without the other 6 states |
| G2.1 (Tier matrix finalized) | A matrix with placeholders like "TBD" or "~$20/mo" instead of concrete numbers |
| 0B-D4 (Tool-calling ≥90%) | A benchmark run on a curated subset of easy test cases; must include adversarial and ambiguous prompts |
| 0C-D3 (Agent tool calling works) | "Works" when Trevor carefully phrases the prompt; must work on natural, unscripted language |
| EXIT-1 (External tester sees magic) | A recorded demo where Trevor drives the UI; must be self-service by the tester |


## Part 4: The Escape Hatch — When to Start Despite Incomplete Gates

This DoD is strict, but dogmatic adherence can itself be a failure mode. The following conditions permit starting Block 0A before ALL gates are green:

1. **Gates G1.1–G1.4 and G2.1–G2.4 (database DDL, API schemas, component types, tier matrix) MUST be green.** These are the foundation; without them, code generation will produce garbage.
2. **Gates G1.6–G1.8 (UX flows) may be yellow** (in review, not yet stable). Basic placeholder UX is acceptable for initial scaffolding; UX refinement can happen in parallel with Blocks 0A-0C.
3. **Gate G4.3 (practice run) may be waived** if Trevor has completed at least 3 sessions of AI-generated code review and feels comfortable with the review process.
4. **Gate G5.1 (blocked time)** is non-negotiable. If Trevor cannot commit to 2 weeks of focused execution, Phase 0 will stall.

**If the escape hatch is invoked:** Trevor must document which gates were waived and why in the Signature Block below, with a commitment to resolve them by a specific date.


## Part 5: Governance

**Review cadence:** Trevor reviews this DoD at the start of every planning session. When all Gate 1-5 criteria are green, signing occurs immediately — no further deliberation.

**Amendment process:** This DoD can be amended by Trevor at any time. Amendments that add criteria are encouraged (they represent lessons learned). Amendments that remove criteria must include a written rationale in this document.

**Post-Phase 0:** After Phase 0 exits, a separate `00-DEFINITION-OF-DONE-PHASE1.md` will be created using this template, with gates appropriate to Phase 1's scope and risks.

---

*This document is the contract between planning and execution. When Trevor signs below, the project transitions from blueprint to build. No signature = no code. Full stop.*
```

---