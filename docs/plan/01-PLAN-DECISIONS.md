# 00-PLAN-DECISIONS.md

```
---
steering: TO PARSE — READ INTRO
file_name: 00-DECISIONS-LOG.md
document_type: decisions_register
tier: strategic
status: active
owner: Trevor (Solo Founder)
description: Lightweight, append-only decision register for all product, UX, and implementation decisions that don't warrant a full Architecture Decision Record. Designed as shared context for AI coding agents and human review. Complements the existing ADR system (126 ADRs in 01-PLAN-LEXICON.md ADR_KEY).
last_updated: 2026-04-26
version: 1.0
dependencies: [01-PLAN-LEXICON.md, 00-PLANNING-BACKLOG.md, SPEC-TEMPLATE.md]
related_adrs: [ADR_054]
related_rules: []
complexity: low
risk_level: low
---

# Decision Register — Lightweight Decision Tracking

## README: Why This Exists

### The Problem

Your blueprint already has 126 Architecture Decision Records (ADRs) covering every significant architectural choice — from ADR_001 (Vite SPA over Next.js) to ADR_126 (PostHog Group Analytics mandatory). These are excellent for decisions that are architecturally significant, hard to reverse, and affect system structure.

But between now and launch, AI agents working on your project will make **hundreds of smaller decisions** that don't warrant a full ADR but still need a durable record:

- "What's the default calendar view — Month or Week?"
- "Should the conflict banner auto-dismiss after resolution, or require manual dismissal?"
- "What's the exact copy for the empty task list state?"
- "Should we paginate notifications at 20 or 50 per page?"

These decisions currently have no home. Without a register, they will:
- Get buried in chat logs across different AI sessions
- Be re-litigated when a new agent encounters the same question
- Drift as different agents make contradictory choices
- Become invisible to you during review

### Research Foundation

This register format is informed by four complementary sources:

1. **Microsoft Azure Well-Architected Framework (April 2026)**: "An ADR documents all key decisions, including alternatives that you ruled out... If a decision changes, write a new record that supersedes the original and link the two together. This approach preserves the history of your thinking." Also: "Keep records pithy, assertive, on-topic, and factual." 

2. **Addy Osmani's Automated Decision Logs (November 2024)**: The ADL is "a targeted, low-overhead mechanism for capturing the reasoning behind significant AI-driven code modifications. Think of it less as a comprehensive log and more as a structured set of notes-to-self." He recommends a project-local log (`fyi.md` or `ai_decisions.log`) and explicit prompting: "Make sure to keep a log of what, why and how you did what you did in the log." 

3. **DECIDER (sventorben, March 2026)**: "Turn architectural decisions into machine-readable constraints that both humans and AI coding agents can follow." Key innovation: decisions become constraints that AI agents queried before generating code, and CI enforces them. 

4. **EntireContext (April 2026)**: Introduces "decision staleness" — every decision has a `staleness_status` (fresh/stale/superseded/contradicted). When a decision's linked files change or newer decisions contradict it, the stale entry is demoted or hidden so agents don't act on obsolete guidance. 

### How This Register Differs from the Existing ADRs

| Aspect | ADRs (ADR_KEY) | Decision Register (this file) |
|---|---|---|
| **Scope** | Architecturally significant, hard to reverse | All decisions: product, UX, copy, config, process |
| **Format** | Full ADR document per decision | Single table row per decision |
| **Creation trigger** | When making architectural choices | Whenever any decision is made during planning or coding |
| **Review process** | Formal, PR-based | Lightweight, review-during-session |
| **Reversibility** | Usually hard to reverse | Varies; tracked explicitly |
| **AI agent role** | Read and reference | Read on session start AND append during session |

### How AI Agents Should Use This File

**On session start:**
1. Read this entire file. It contains the accumulated decisions from all prior sessions.
2. Pay special attention to decisions marked `status: active`. Do not contradict them.
3. If you encounter a decision that seems wrong or outdated, flag it for Trevor — do not silently ignore it.

**During the session:**
4. When you make any decision that affects the product, UX, or codebase, append a row to the Active Decisions table. Include all columns.
5. If a decision supersedes a prior one, add a new row and note the superseded decision ID in the Rationale column. Mark the old row's Status as `superseded`.
6. Do not edit existing rows (append-only log, per Microsoft's guidance).

**At session end:**
7. Review the log and ensure all decisions made in the session are captured.

**When generating code:**
8. Before writing code that involves a prior decision, check this register. If there's an active decision, follow it. If there's a stale or superseded decision, flag it.


## Decision Table Format

Every decision is a single row in the table below. The format is designed to be:
- **Scannable**: Trevor can review a session's decisions in under 60 seconds.
- **Agent-parseable**: Structured columns allow agents to filter by domain and status.
- **Linkable**: Each decision has a unique ID that can be referenced in specs, PRs, and ADRs.

### Column Definitions

| Column | Purpose | Required? |
|---|---|---|
| **ID** | `DEC-YYYY-MM-DD-NNN` (date + sequential). Unique and stable. | Yes |
| **Date** | When the decision was made (ISO 8601). | Yes |
| **Domain** | Which part of the product: `Platform`, `Data`, `AI-Core`, `Frontend`, `UX`, `Security`, `Business`, `Process` | Yes |
| **Decision** | One sentence: what was chosen. Be specific. | Yes |
| **Rationale** | Why this choice. Include rejected alternatives if they were seriously considered. | Yes |
| **Reversible?** | `Yes` (can change later at low cost), `Costly` (can change but requires migration), `No` (very hard to reverse). | Yes |
| **Confidence** | `High` (strong evidence), `Medium` (reasonable but could be wrong), `Low` (best guess, revisit soon). | Yes |
| **Status** | `active` (currently in effect), `superseded` (replaced by a newer decision), `expired` (time-boxed decision that has passed). | Yes |
| **Expiry** | If this is a temporary decision (e.g., "we'll use X until Y is ready"), when does it expire? Otherwise `none`. | No |
| **Linked Items** | Reference to related ADRs, backlog items (BP-XXX), or specs. | No |
| **Session** | Which AI session produced this decision (for traceability: `session-YYYY-MM-DD-platform-topic.md`). | No |


## Active Decisions

*Decisions in effect. AI agents: follow these. Do not override without Trevor's explicit instruction.*

| ID | Date | Domain | Decision | Rationale | Reversible? | Confidence | Status | Expiry | Linked Items | Session |
|----|------|--------|----------|-----------|-------------|------------|--------|--------|--------------|---------|
| DEC-2026-04-26-001 | 2026-04-26 | Process | All planning documents follow the SPEC-TEMPLATE.md format (YAML frontmatter + 9 mandatory sections) | Standardization across AI sessions; grounded in W3C machine-consumable spec guidelines and GitHub's 2,500+ repo analysis. Rejected alternative: free-form markdown with no template. | Costly | High | active | none | SPEC-TEMPLATE.md, ADR_054 | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-002 | 2026-04-26 | Process | Planning backlog (`00-PLANNING-BACKLOG.md`) is the single source of truth for unresolved decisions. No code execution until a block's prerequisites are resolved. | Prevents premature implementation; research-backed (Microsoft spec playbook: "define the smallest testable slice before coding"). Rejected alternative: start coding immediately and discover gaps during implementation. | Yes | High | active | none | 00-PLANNING-BACKLOG.md | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-003 | 2026-04-26 | Process | This decision register uses an append-only model: new decisions are added as new rows, old decisions are marked `superseded` rather than edited. | Microsoft Well-Architected Framework: "The ADR serves as an append-only log. Don't go back and edit accepted records. If a decision changes, write a new record that supersedes the original." Preserves decision history for audit and context recovery.  | Costly | High | active | none | — | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-004 | 2026-04-26 | Process | AI agents must read this decision register at session start and append any new decisions before session end. | Addy Osmani's ADL pattern: "Make sure to keep a log of what, why and how you did what you did." Prevents decision loss across sessions.  | Yes | High | active | none | — | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-005 | 2026-04-26 | Process | Reversible decisions (marked `Yes` in Reversible? column) are made quickly by AI agents without waiting for Trevor's approval. Costly and irreversible decisions require explicit Trevor review before implementation. | Prevents decision paralysis while protecting against costly mistakes. Solo-founder constraint: Trevor cannot pre-approve hundreds of small decisions. | Yes | Medium | active | Review after 10 sessions | — | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-006 | 2026-04-26 | UX | The conflict detection UX spec must cover all 8 states: no conflicts, conflict detected, awaiting action, resolving (optimistic), resolved, resolution failed, multiple conflicts, dismissed-without-action. | Blueprint gap analysis identified this as the most critical undefined flow (BP-006). The core product magic depends on this feeling intelligent, not mechanically correct. | Costly | High | active | none | BP-006, 10-UX-CONFLICT-FLOW.md | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-007 | 2026-04-26 | Process | The session naming convention is `session-YYYY-MM-DD-platform-topic.md`. All session outputs stored in `sessions/` folder. | Traceability across parallel AI platforms (Claude, DeepSeek, ChatGPT, etc.). | Yes | High | active | none | — | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-008 | 2026-04-26 | Security | CSP nonce strategy (HARD rules S6, S7, S11) will be implemented in Phase 0 Block 0F, not earlier. During Blocks 0A-0E development, Report-Only CSP is acceptable. | Security-critical but implementing nonce infrastructure early would slow down initial UI development. Report-Only mode catches violations without blocking. Rejected alternative: enforce CSP from day one (would create friction during rapid prototyping). | Yes | High | active | Expires at start of Block 0F | BP-009, 05-XCT-CSP.md | session-2026-04-26-claude-planning-framework |

---

## Superseded Decisions

*Decisions that were active but have been replaced. AI agents: do not follow these — find the superseding decision in the Active table.*

| ID | Date | Domain | Decision | Rationale | Superseded By | Superseded Date | Session |
|----|------|--------|----------|-----------|---------------|-----------------|---------|
| *No entries yet.* | | | | | | | |


## Expired Decisions

*Time-boxed decisions that have passed their expiry. AI agents: these are historical context only.*

| ID | Date | Domain | Decision | Rationale | Expired | Session |
|----|------|--------|----------|-----------|---------|---------|
| *No entries yet.* | | | | | | |


## Decision Statistics

*Updated at the end of each planning session.*

| Metric | Count |
|--------|-------|
| Total decisions | 8 |
| Active | 8 |
| Superseded | 0 |
| Expired | 0 |
| Reversible (Yes) | 5 |
| Costly to reverse | 2 |
| Irreversible (No) | 1 |
| High confidence | 7 |
| Medium confidence | 1 |
| Low confidence | 0 |


## Appendix A: When to Use a Full ADR vs. the Decision Register

*For AI agents: use this flowchart when deciding where to record a decision.*

```
Is the decision architecturally significant?
  └─ Does it affect system structure, key quality attributes, or technology choices?
     └─ YES → Write a full ADR (follow ADR_KEY format in 01-PLAN-LEXICON.md).
     └─ NO → Continue.
        └─ Is it hard to reverse?
           └─ YES → Write a full ADR (the cost of getting it wrong justifies the documentation).
           └─ NO → Add a row to this Decision Register.

If in doubt: add to this register now. A decision can always be promoted to an ADR later,
but an unrecorded decision is lost immediately.
```

**Examples of ADR-worthy decisions:** "Use PostgreSQL not MongoDB" (ADR_002), "Use Vite SPA not Next.js" (ADR_001), "Use MCPSec L2 for all MCP servers" (ADR_096).

**Examples of Decision Register-worthy decisions:** "Default calendar view is Month", "Notification batch size is 20", "The empty dashboard state says 'Your AI assistant is monitoring for conflicts' rather than 'No notifications'", "The sidebar collapses on screens below 1024px."


## Appendix B: Staleness Policy

Inspired by EntireContext's staleness model , decisions in this register are reviewed for staleness:

| Review Trigger | Action |
|----------------|--------|
| After every 5 planning sessions | Trevor reviews all active decisions. Any that no longer apply are marked `superseded` or `expired`. |
| When a decision's linked items change | The decision should be reviewed. Example: if BP-006 is resolved, DEC-2026-04-26-006 may need updating. |
| When an AI agent flags a decision | Agents can note in their session summary: "Decision DEC-XXX appears stale because [reason]." Trevor reviews. |
| After any Phase gate is passed | Full register review to ensure decisions are still valid for the next phase. |


## Appendix C: How This Register Integrates with the Planning Pipeline

```
00-PLANNING-BACKLOG.md         00-DECISIONS-LOG.md          01-PLAN-LEXICON.md
(What needs deciding)          (What was decided)           (How it's encoded as rules)
         │                            │                            │
         │  Backlog items             │  Decisions resolve        │  Some decisions become
         │  are researched            │  backlog items             │  HARD or MED rules
         │  and decided               │                            │
         │                            │                            │
         └────────────────────────────┴────────────────────────────┘
                         │
                         ▼
                    SPEC-TEMPLATE.md
                    (Decisions encoded into implementable specs)
                         │
                         ▼
                    Phase Blocks
                    (Execution begins)
```

**Workflow:**
1. Backlog item `BP-XXX` identified as needing a decision.
2. AI research session produces a recommendation.
3. Trevor (or AI agent for reversible decisions) makes the call.
4. Decision recorded here with ID, linking back to the backlog item.
5. If the decision establishes a new rule, it may be promoted to `01-PLAN-LEXICON.md` as a HARD or MED rule.
6. The decision is then referenced in the relevant spec document (via `SPEC-TEMPLATE.md`).

---