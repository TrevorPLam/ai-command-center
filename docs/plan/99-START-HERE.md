# START-HERE.md

---
steering: TO PARSE — READ INTRO
file_name: START-HERE.md
document_type: agent_onboarding
tier: meta
status: stable
owner: Trevor (Solo Founder)
description: Universal entry point for every AI agent session. Provides 2-minute orientation, tiered context injection strategy, session templates, product voice guidelines, and a fillable session objective field. Designed to minimize token waste and maximize agent accuracy from the first prompt.
last_updated: 2026-04-26
version: 1.0
dependencies: [00-STRAT-BLUEPRINT.md, 00-PLANNING-BACKLOG.md, 00-DEFINITION-OF-DONE.md, SPEC-TEMPLATE.md, 00-DECISIONS-LOG.md, 00-STRAT-NARRATIVE.md]
related_adrs: []
related_rules: [All HARD rules from 01-PLAN-LEXICON.md]
complexity: low
risk_level: critical
---

# START HERE — Agent Onboarding & Session Context

## TIER 0: Universal Context (Inject Into Every Session — ~200 tokens)

### Who Trevor Is
Trevor. Born 1992. Not a developer — uses AI agents (Windsurf IDE) to code. Reviews and tests output, never writes code manually. Left-leaning, independent, critical of tech-bro culture. Values intellectual honesty and direct, constructive feedback.

### What We're Building
An AI-integrated SaaS productivity platform. Cross-application, context-aware AI assistant that works across Calendar, Projects, Email, etc., spotting conflicts and offering fixes. Core differentiator: **all AI runs locally by default** — cloud AI is optional. Free tier costs ~$0 in AI inference.

### Current Phase
**Phase 0: Foundation & Core Magic** — building the first demo that shows the conflict-detection "aha" moment.

**Active blocks:** Planning completion → Block 0A (Platform Skeleton) execution begins when all DoD gates are green. See `00-DEFINITION-OF-DONE.md` for exact criteria.

### 3 Non-Negotiable Constraints
1. **Never remove features from the blueprint.** Defer, split, resequence — never delete.
2. **Always check Domain E (Security & Compliance) for any AI/data/user-facing change.**
3. **Cite real sources.** Flag uncertainty with "I'm not sure" — never fabricate research.

### Product Voice (for any user-facing text)
Warm, direct, anti-corporate. No jargon. Proudly privacy-first.
**Never use:** revolutionize, disrupt, game-changer, synergy, ecosystem play.
**Always use:** build, fix, help, spot, save. "Your data" not "user data."

### Required Reading (3 files — read these first)
1. `00-STRAT-BLUEPRINT.md` — What we're building and why.
2. `01-PLAN-MILESTONES.md` — Current phase, blocks, tasks, gates.
3. `00-PLANNING-BACKLOG.md` — What still needs to be decided before code.

### Quick Validation
Before proceeding, summarize what you understand this session's task to be. Wait for Trevor to confirm or correct before generating any code or research output.


## TIER 1: Session Templates (Select One Based on Task Domain)

### Template A: Planning & Research Session
```
## Session Type: Planning & Research

### Domain Context to Load
- `00-PLANNING-BACKLOG.md` — Full document (all unresolved items)
- `00-DECISIONS-LOG.md` — Active decisions (check before making contradictory ones)
- `00-DEFINITION-OF-DONE.md` — Check if any gate criteria are relevant
- `SPEC-TEMPLATE.md` — Output format for any spec produced
- `00-STRAT-NARRATIVE.md` — Voice guidelines for any public-facing text

### Key Rules
- Output goes into a new markdown spec document following SPEC-TEMPLATE.md.
- Cite all external research with source URLs and retrieval dates.
- When recommending a decision, note whether it should go into the Decision Register or as a full ADR.

### Session Objective
[USER FILLS THIS IN — e.g., "Research and decide backlog item BP-006: conflict detection UX flow"]
```

### Template B: Frontend Development Session
```
## Session Type: Frontend Development

### Domain Context to Load
- `01-PLAN-LEXICON.md` — #RULES (especially ZustandSelectors, GlobalUIState, @COMPILER, XCT_01, XCT_02, FLOWC_03, DSNOKEYUI, TEMPORALZDT) + #C (component patterns for active module)
- `01-PLAN-ZUSTAND.md` — Slice list (types pending in BP-001)
- `04-COMP-{MODULE}.md` — Component specs for the active module
- `05-XCT-DESIGN-SYSTEM.md` — OKLCH tokens, motion, glass
- `05-XCT-SANITIZATION.md` — DOMPurify profiles (STRICT/RICH/EMAIL)
- `00-STRAT-NARRATIVE.md` Part 5 — Product voice guidelines (for any in-app text)

### Reminder: DoD Gate Check
Before generating code, verify in `00-DEFINITION-OF-DONE.md` that the relevant block's prerequisites are RESOLVED. If not, flag to Trevor — don't code around unresolved decisions.

### Session Objective
[USER FILLS THIS IN — e.g., "Build the Calendar MonthView component. Reference 04-COMP-CALENDAR.md."]
```

### Template C: Backend & API Development Session
```
## Session Type: Backend & API Development

### Domain Context to Load
- `01-PLAN-LEXICON.md` — #RULES (especially S9, S14, S15, EDGE_NO_DB, APIC_01, APIC_02, APIC_003) + #VER (version pins)
- `02-ARCH-DATABASE.md` — Table list (DDL pending in BP-003)
- `02-ARCH-ENDPOINTS.md` — Endpoint list (schemas pending in BP-004)
- `02-ARCH-OVERVIEW.md` — Deployment, security layers, data flows
- `02-ARCH-EXTERNAL.md` — External service integrations
- `05-XCT-CSP.md` + `05-XCT-RATE-LIMITING.md` + `05-XCT-SECRETS.md` — Security middleware
- `05-XCT-ERROR-TAXONOMY.md` — Error codes (pending in BP-005)

### Reminder: DoD Gate Check
Before generating code, verify in `00-DEFINITION-OF-DONE.md` that the relevant block's prerequisites are RESOLVED.

### Session Objective
[USER FILLS THIS IN — e.g., "Generate FastAPI CRUD endpoints for the events table."]
```

### Template D: AI Infrastructure Session
```
## Session Type: AI Infrastructure

### Domain Context to Load
- `01-PLAN-LEXICON.md` — #RULES (especially NO_HAIKU_AGENTIC, LITELLM_PIN, GRDL_01, GRDL_02, GRDL_03, EVALCOST, CONTEXTUALRETRIEVAL, FASTGRAPHRAG) + #DICT (G1-G8 quality presets) + #VER (model pins)
- `06-AI-ARCHITECTURE.md` — Intent Dispatcher, verifier cascade, cost model, guardrails
- `06-AI-LOCAL-INFRA.md` — Model registry, quantization policy, hardware tiers, serving stack
- `06-AI-WORKFLOW-ENGINE.md` — LangGraph Supervisor, LangMem, Trustcall
- `06-AI-MODEL-CARDS.md` — Per-model documentation
- `02-ARCH-EXTERNAL.md` — AI Provider integrations, Ollama, LiteLLM

### Reminder: DoD Gate Check
Before generating code, verify in `00-DEFINITION-OF-DONE.md` that the relevant block's prerequisites are RESOLVED. Block 0B specifically requires BP-015 (local model benchmarks) to be RESOLVED.

### Session Objective
[USER FILLS THIS IN — e.g., "Set up the Ollama Docker Compose integration and model registry."]
```

### Template E: Security & Compliance Session
```
## Session Type: Security & Compliance

### Domain Context to Load
- `01-PLAN-LEXICON.md` — #RULES S1-S28 (all HARD security rules) + SECM_01/SECM_02/SECM_03 + GRDL_01/GRDL_02 + PRIV_01/PRIV_02
- `05-XCT-CSP.md` — Full CSP policy, nonce strategy, exceptions
- `05-XCT-SANITIZATION.md` — DOMPurify profiles, ClamAV, SSRF+XSS test matrix
- `05-XCT-SECRETS.md` — Doppler + Vault, rotation schedules
- `05-XCT-RATE-LIMITING.md` — Limits, strategy, response headers
- `07-TEST-ASI-COMPLIANCE.md` — OWASP Agentic Top10 gap analysis
- `02-ARCH-OVERVIEW.md` — #SECURITY section (L1-L12)

### Reminder: Domain E is cross-cutting. Any change anywhere in the system must be evaluated against security controls.

### Session Objective
[USER FILLS THIS IN — e.g., "Implement the CSP nonce injection strategy for Vite + React 19."]
```


## TIER 2: Deep Context (Retrieved On Demand)

The following documents are NEVER injected in full. They are referenced by name and retrieved only when a specific task requires them.

| Document | When to Retrieve |
|----------|-----------------|
| `02-ARCH-DATABASE-DDL.sql` | When generating migrations, Prisma schema, or RLS policies |
| `02-ARCH-ENDPOINTS-SCHEMA.yaml` | When implementing API endpoints or generating MSW handlers |
| `01-PLAN-ZUSTAND-TYPES.md` | When implementing any Zustand slice |
| `04-COMP-{MODULE}-SPEC.md` | When implementing a specific component (generated per BP-002) |
| `10-UX-{FLOW}.md` | When implementing a specific user flow |
| `07-TEST-STRATEGY.md` | When writing tests |
| `08-OPS-RUNBOOKS.md` | When handling operational incidents |
| `01-PLAN-ADR-INDEX.md` | When checking if an architectural decision exists for a design choice |


## Session Workflow Checklist (For the AI Agent)

At session start:
- [ ] Read TIER 0 context above.
- [ ] Identify the session domain (Planning, Frontend, Backend, AI, Security).
- [ ] Load the corresponding TIER 1 template.
- [ ] Check `00-DEFINITION-OF-DONE.md`: is the relevant block's prerequisites RESOLVED?
- [ ] Check `00-DECISIONS-LOG.md`: any active decisions that constrain this task?
- [ ] Read the session objective (filled in by Trevor).
- [ ] Summarize your understanding back to Trevor. Wait for confirmation.
- [ ] Proceed.

During the session:
- [ ] If you make a new decision, append it to `00-DECISIONS-LOG.md` (if reversible) or flag for a full ADR (if architecturally significant).
- [ ] If you resolve a backlog item, update `00-PLANNING-BACKLOG.md`.
- [ ] If you complete a task, update `TASKS.md`.

At session end:
- [ ] Summarize what was accomplished.
- [ ] List any new decisions added to the register.
- [ ] List any items still blocked.
- [ ] Save the session log as `sessions/session-YYYY-MM-DD-platform-topic.md`.


## Quick Reference: Key Document Map

```
START-HERE.md (you are here)
│
├── STRATEGIC
│   ├── 00-STRAT-BLUEPRINT.md          — Full vision, six domains, design axioms
│   ├── 00-STRAT-PRD.md                — JTBD, personas, success metrics, monetization
│   ├── 00-STRAT-NARRATIVE.md          — Manifesto, landing page, product voice
│   └── 00-STRAT-TIER-MATRIX.md        — Exact Free/Pro/Team/Enterprise limits (BP-011)
│
├── PLANNING
│   ├── 00-PLANNING-BACKLOG.md         — ALL unresolved decisions (BP-001 through BP-020)
│   ├── 00-DECISIONS-LOG.md            — Decisions made + reversibility + status
│   ├── 00-DEFINITION-OF-DONE.md       — Hard gates for planning→execution
│   ├── 00-PHASE0-PRE-MORTEM.md        — Failure scenarios + early warning signals
│   ├── 00-PRACTICE-RUN.md             — Pipeline validation plan
│   └── TASKS.md                       — All tasks F001–P606 + status
│
├── LEXICON & RULES
│   ├── 01-PLAN-LEXICON.md             — Full DSL, HARD/MED rules, version pins
│   ├── 01-PLAN-MILESTONES.md          — Six-phase plan with tasks, gates, costs
│   ├── 01-PLAN-ZUSTAND.md             — Slice names (types pending BP-001)
│   └── 01-PLAN-ADR-INDEX.md           — 126 ADRs, searchable by domain (to be created)
│
├── ARCHITECTURE
│   └── 02-ARCH-*.md (6 files)         — DB, endpoints, external services, flows, API versioning
│
├── COMPONENT SPECS
│   └── 04-COMP-*.md (14 files)        — Per-module component lists + patterns
│
├── CROSS-CUTTING
│   └── 05-XCT-*.md (6 files)          — CSP, secrets, observability, rate limiting, sanitization, services
│
├── AI
│   └── 06-AI-*.md (4 files)           — Architecture, local infra, workflow engine, model cards
│
├── TESTING
│   └── 07-TEST-*.md (3 files)         — Strategy, infra, ASI compliance
│
├── OPS
│   └── 08-OPS-*.md (5 files)          — Runbooks, team, DR/BCP, incident templates, load testing
│
├── REFERENCE
│   ├── 09-REF-KNOWLEDGE.md            — Infrastructure patterns, backend core, security
│   └── 09-REF-AUTH.md                 — Auth flows, passkeys, org switching
│
├── TEMPLATES & META
│   ├── SPEC-TEMPLATE.md               — Standardized spec format (for planning output)
│   ├── 00-WORKFLOW-REVIEW.md          — Trevor's PR review checklist (to be created)
│   └── SESSION-TEMPLATES.md           — Alternative: extract templates to standalone file
│
└── NARRATIVE ASSETS
    └── 00-STRAT-NARRATIVE.md          — Manifesto, landing page framework, waitlist emails
```


## Quick Reference: Where To Find Answers

| Question | Look In |
|----------|---------|
| What are we building? | `00-STRAT-BLUEPRINT.md` |
| Who is this for? | `00-STRAT-PRD.md` (#PERSONAS, #JTBD) |
| What phase are we in? | `01-PLAN-MILESTONES.md` (current block) |
| What's still undecided? | `00-PLANNING-BACKLOG.md` |
| What decisions have been made? | `00-DECISIONS-LOG.md` + `01-PLAN-ADR-INDEX.md` |
| Can we start coding yet? | `00-DEFINITION-OF-DONE.md` (check gates) |
| What's the next task? | `TASKS.md` (first 🔴 PENDING in current block) |
| What does this component do? | `04-COMP-{MODULE}.md` |
| What's the API endpoint? | `02-ARCH-ENDPOINTS.md` |
| What's the database table? | `02-ARCH-DATABASE.md` |
| What's the security rule? | `01-PLAN-LEXICON.md` (#RULES S1-S28) |
| How should this sound? | `00-STRAT-NARRATIVE.md` Part 5 (Product Voice) |
| How do I format my output? | `SPEC-TEMPLATE.md` |
| How does Trevor review my code? | `00-WORKFLOW-REVIEW.md` (to be created) |
| What if something goes wrong? | `00-PHASE0-PRE-MORTEM.md` |


## Session Objective — Fill In Below

```
SESSION OBJECTIVE:
[Trevor fills this in before the session — e.g., "Research and decide BP-015: local model benchmarks"]
[Trevor fills this in before the session — e.g., "Resolve BP-006: conflict detection UX flow"]
[Trevor fills this in before the session — e.g., "Generate the MonthView component per 04-COMP-CALENDAR.md"]
[Trevor fills this in before the session — e.g., "Set up Stripe metered billing integration"]
```

---

*This document is the front door to the entire project. Every AI agent session begins here. If you're an agent reading this, you have everything you need to orient, validate, and execute. If something is missing, tell Trevor — this document is living.*
```

---

