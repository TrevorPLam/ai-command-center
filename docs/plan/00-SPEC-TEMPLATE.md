# SPEC-TEMPLATE.md

```
---
steering: TO PARSE — READ INTRO
file_name: SPEC-TEMPLATE.md
document_type: specification_template
tier: meta
status: stable
owner: Trevor (Solo Founder)
description: Standardized specification template for all component, flow, and feature specs. Designed for AI agent consumption first, human review second. Based on the Lexicon's SPEC_01/SPEC_02 rules, W3C machine-consumable spec principles, and GitHub's 2,500+ repo analysis of effective agent instructions.
last_updated: 2026-04-26
version: 1.0
dependencies: [01-PLAN-LEXICON.md, 00-STRAT-BLUEPRINT.md, 00-PLANNING-BACKLOG.md]
related_adrs: [ADR_054]
related_rules: [SPEC_01, SPEC_02, TIER_01, TIER_02, TIER_03]
complexity: low
risk_level: low
---

# SPEC-TEMPLATE — Standardized Specification Template

## README: Why This Template Exists

This template bridges two worlds: the Lexicon's nine-section mandatory structure defined in `SPEC_02`, and the emerging 2026 best practices for specifications that AI coding agents can consume with minimal misinterpretation.

**Research foundation:**
- GitHub's analysis of 2,500+ agent configuration repositories identified six categories that "consistently improve agent performance": commands, testing, project structure, code style, git workflow, and boundaries. 
- W3C's March 2026 draft on machine-consumable specifications mandates: express requirements as constraints not aspirations, include negative examples, provide machine-readable requirement blocks, and link requirements to automated tests. 
- The Princeton AGENTS.md study measured 28.6% faster task completion and 16.6% fewer tokens when agents receive structured context upfront. 
- arXiv study: formal architecture descriptors reduce agent navigation steps by 33–44% and reduce behavioral variance by 52%. 
- Anthropic and GitHub's Spec Kit both promote spec-driven development where "specs become the shared source of truth… living, executable artifacts that evolve with the project." 
- Microsoft's spec playbook defines an implementable spec as: clear outcomes, non-goals, edge cases, acceptance criteria, and the smallest testable slice. 

**Key principle from the research: human-written specifications outperform auto-generated ones.** The W3C further notes that "AI coding agents occupy a third position between human readers and traditional machine parsers" — specifications must be redundantly clear, stating requirements as prose, as constraints, and as counter-examples. 

**How Trevor uses this:** Every planning backlog item resolved, every feature spec drafted, every component detailed — all use this exact template. An AI agent receiving this document plus a brief prompt should be able to produce a complete, reviewable specification without guessing at structure.


## Part 1: The YAML Frontmatter (REQUIRED)

Every spec file must begin with this exact frontmatter block. The Lexicon's `SPEC_02` rule mandates this format. 【01-PLAN-LEXICON.md SPEC_02】

```yaml
---
steering: TO PARSE — READ INTRO
file_name: {MODULE}-{TOPIC}.md        # e.g., 04-COMP-CHAT-TOOL-CALLING.md
document_type: {type}                  # component_specification | flow_specification | feature_specification | api_specification | data_model_specification
module: {ModuleName}                   # e.g., Chat, Calendar, AI-Core, XCT
tier: {tier}                           # core | feature | infrastructure | strategic
status: draft                          # draft → review → stable → deprecated
owner: {owner}                         # individual or team
description: {one-line summary}        # concise, searchable
last_updated: YYYY-MM-DD
version: 1.0
dependencies: [file-refs]              # files this spec depends on
related_adrs: [ADR_###]              # architectural decisions this implements
related_rules: [RULE_ID]             # HARD/MED rules this must satisfy
complexity: low | medium | high
risk_level: low | medium | high | critical
---
```

**Rules for the frontmatter:**
- `steering` is always `TO PARSE — READ INTRO`.
- `status` starts as `draft`. Trevor manually promotes to `review` → `stable`.
- `dependencies` must reference actual filenames in the planning corpus, not old names.
- `complexity` and `risk_level` are human judgments; AI agents should estimate conservatively.
- `related_rules`: every HARD rule that constrains this spec must be listed. Missing this causes CI failures down the line (HARD rule SPEC_01).


## Part 2: The Nine Mandatory Sections (REQUIRED by SPEC_02)

The Lexicon mandates these nine sections for every specification. 【01-PLAN-LEXICON.md SPEC_02】 The following expands each into an AI-actionable format.

### Section 1: Purpose

**What to write:** A concise statement of what this spec defines and why it exists. Answer: what problem does this component/flow/feature solve? Who is the user?

**Format:**
```
## 1. Purpose

### 1.1 What This Is
[One paragraph. If an AI agent reads only this paragraph, it should understand the spec's scope.]

### 1.2 User Story (if applicable)
As a [persona from 00-STRAT-PRD.md], I want to [action] so that [outcome].

### 1.3 Non-Goals (CRITICAL for AI agents)
This spec does NOT cover:
- [Explicit exclusion 1]
- [Explicit exclusion 2]
```

**Why non-goals matter:** Microsoft's spec playbook identifies non-goals as essential for implementable specs.  AI agents, unlike human developers, will not intuitively understand what is out of scope. Explicit non-goals prevent scope creep during implementation.

---

### Section 2: UX States

**What to write:** Every visual state the user can encounter. This is the most important section for frontend components because AI agents default to happy-path implementations.

**Format (use a table for every state):**

```
## 2. UX States

### 2.1 State Catalog
| State ID | State Name | Trigger Condition | Visual Behavior | User Action Available |
|----------|------------|-------------------|-----------------|----------------------|
| S-LOADING | Loading | Component mounted, data fetching | Skeleton/shimmer (<2s), spinner (>2s) | None |
| S-EMPTY | Empty | Data loaded, zero results | EmptyState component with CTA | [action] |
| S-DATA | Data Present | Data loaded, ≥1 result | Normal rendering | [actions] |
| S-ERROR | Error | Fetch failed, validation failed | Error message + retry button | Retry |
| S-OFFLINE | Offline | Network lost | Offline indicator + stale data | Queue actions |
| S-DISABLED | Disabled | Permission missing, feature gated | Greyed out + tooltip | None |

### 2.2 State Transition Diagram
[Describe valid transitions. Use the FLOWC_01 state machine pattern from the Lexicon.]
Example: S-LOADING → S-EMPTY | S-DATA | S-ERROR
         S-ERROR → S-LOADING (on retry)
```

**Negative example requirement (W3C principle):** For every loading/error/empty state, include a "DO NOT" example showing a common failure mode. For instance: "DO NOT show a blank white screen while loading. Always render a skeleton." 

---

### Section 3: Transitions & Animations

**What to write:** Every animation, transition, and motion behavior. The Lexicon defines motion patterns (`@M`, `@AP`, `@AS`, `@AG`, `@Q`) that must be referenced here.

**Format:**
```
## 3. Transitions & Animations

### 3.1 Motion Patterns Used
| Pattern | Lexicon Ref | Applied To | Duration/Spring | Notes |
|---------|-------------|------------|-----------------|-------|
| @M | MotionGuard | Entire component | — | Respects prefers-reduced-motion |
| @AP | AnimatePresence | Page transitions | — | layoutId where applicable |
| @AS | Spring | List items appear | tension≥300, damping≥30 | stagger≤3 |
| @O | OptimisticMutation | Data mutations | pending: opacity0.5 + italic + pulse | undo 5s for delete |

### 3.2 DO NOT (HARD constraints from Lexicon)
- DO NOT animate layout properties. Only transform and opacity. (Rule XCT_01)
- DO NOT stagger more than 3 children. (Rule @AG)
- DO NOT animate when prefers-reduced-motion is active. Instant transition. (Rule g6)
```

---

### Section 4: Data Shapes

**What to write:** Every data structure this spec depends on. This is where AI agents most frequently make wrong assumptions.

**Format:**
```
## 4. Data Shapes

### 4.1 Zustand Slice (if applicable)
```typescript
// Reference: 01-PLAN-ZUSTAND-TYPES.md
interface [SliceName] {
  // Exact shape
}
```

### 4.2 Database Tables Referenced
| Table | Columns Used | RLS Policy |
|-------|-------------|------------|
| tasks | id, org_id, title, status, due, ... | org_id = auth.jwt()->>org_id |

### 4.3 API Payloads
#### Request
```json
{
  "field": "type // constraint"
}
```
#### Response (200)
```json
{
  "data": {},
  "error": null,
  "meta": {}
}
```
#### Response (Error)
```json
{
  "data": null,
  "error": {"code": "ERROR_CODE", "message": "Human-readable"},
  "meta": {}
}
```

### 4.4 Validation Rules
- [Field]: [Zod schema or constraint]. Example: "title: string, min 1 char, max 200 chars"
```

**Constraint formulation (W3C principle):** Express data requirements as constraints, not aspirations. "Title must be 1-200 characters" not "Title should be reasonable." 

---

### Section 5: Edge Cases & Error Handling

**What to write:** Every edge case, race condition, and error scenario. This section is mandatory because these are what AI agents most frequently miss.

**Format:**
```
## 5. Edge Cases & Error Handling

### 5.1 Edge Cases
| ID | Scenario | Expected Behavior | Test Verification |
|----|----------|-------------------|-------------------|
| EC-001 | [Description] | [Behavior] | [How to test] |

### 5.2 Error Scenarios
| Error Code (ref: 05-XCT-ERROR-TAXONOMY.md) | Trigger | User Sees | System Does | Recovery |
|---------------------------------------------|---------|-----------|-------------|----------|
| RATE_LIMITED | >100 req/min | Toast + retry-after countdown | 429 response | Auto-retry after window |
| AI_FAILED | Model returns error | "AI unavailable" banner + fallback to local | Circuit breaker increments | Retry with backoff |

### 5.3 Race Conditions
- [Scenario]: [Mitigation]. Example: "User edits event while agent is modifying it → LWW via uat column."
```

---

### Section 6: Acceptance Criteria

**What to write:** Testable, pass/fail criteria. This is what gates a spec from draft to stable.

**Format:**
```
## 6. Acceptance Criteria

### 6.1 Functional
- [ ] [Criterion 1]: [How to verify]
- [ ] [Criterion 2]: [How to verify]

### 6.2 Performance (if applicable)
- [ ] LCP ≤ 800ms p75
- [ ] INP ≤ 200ms
- [ ] TTFT ≤ 2s p95 (AI calls)

### 6.3 Accessibility (mandatory for all UI specs)
- [ ] WCAG 2.2 AA: keyboard navigation functional
- [ ] WCAG 2.2 AA: screen reader announces all state changes
- [ ] WCAG 2.2 AA: focus order is logical
- [ ] prefers-reduced-motion: all animations disabled

### 6.4 Security (cross-reference Domain E)
- [ ] CSP: no inline scripts introduced
- [ ] RLS: all queries scoped to org_id
- [ ] Input: all user content passes through SanitizedHTML with appropriate profile
```

---

### Section 7: Accessibility

**What to write:** Specific accessibility requirements beyond the general WCAG 2.2 AA mandate.

**Format:**
```
## 7. Accessibility

### 7.1 ARIA Roles & Labels
| Element | Role | aria-label | Notes |
|---------|------|------------|-------|
| [Component] | [role] | [label] | [notes] |

### 7.2 Keyboard Navigation
| Key | Action | Notes |
|-----|--------|-------|
| Tab | Move to next interactive element | |
| Enter | Activate/Confirm | |
| Escape | Close/Cancel | Must restore focus |

### 7.3 Screen Reader Announcements
| Event | aria-live Region | Message |
|-------|-----------------|---------|
| Data loaded | polite | "X items loaded" |
| Error occurred | assertive | "Error: [message]" |

### 7.4 DO NOT
- DO NOT use color alone to convey state (WCAG 1.4.1).
- DO NOT trap focus without escape.
- DO NOT auto-play animations longer than 5 seconds (WCAG 2.2.2).
```

---

### Section 8: Testing Strategy

**What to write:** Specific tests for this spec, linked to the testing infrastructure defined in `07-TEST-STRATEGY.md` and `07-TEST-INFRA.md`.

**Format:**
```
## 8. Testing Strategy

### 8.1 Unit Tests (Vitest)
| Test | What It Verifies | Target Coverage |
|------|-----------------|-----------------|
| [test name] | [verification] | |

### 8.2 Component Tests (Vitest + Testing Library)
| Test | What It Verifies |
|------|-----------------|
| [test name] | [verification] |

### 8.3 Integration Tests (Playwright for critical flows)
| Flow | Steps |
|------|-------|
| [flow name] | [step 1 → step 2 → ...] |

### 8.4 Security Tests (pgTAP, CSP, Schemathesis)
| Test | Rule Reference |
|------|---------------|
| RLS: tenant isolation | TESTC_04, S5 |
| CSP: no inline scripts | S6 |
| Input validation: SQL injection, XSS | TESTC_04 |

### 8.5 AI Evaluation Tests (if AI behavior is involved)
| Metric | Threshold | Framework |
|--------|-----------|-----------|
| Tool precision | ≥90% | DeepEval |
| Hallucination rate | ≤2% | DeepEval |
| Latency | ≤base+10% | Custom |

### 8.6 Test Data Requirements
- [Factory/seeds needed]
```

**Link to automated tests (W3C principle):** Where automated tests exist for a requirement, reference them directly. This allows AI agents to include post-generation validation in their workflow. 

---

### Section 9: Risks & Open Questions

**What to write:** Known risks, unresolved decisions, and assumptions.

**Format:**
```
## 9. Risks & Open Questions

### 9.1 Risks
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| [risk] | Low/Med/High | Low/Med/High | [mitigation] |

### 9.2 Open Questions
- [Question 1] → Target resolution: [date or milestone]
- [Question 2] → Target resolution: [date or milestone]

### 9.3 Assumptions
- [Assumption 1]
- [Assumption 2]
```

---

## Part 3: AI Agent Instructions (Embedded Guidance)

The following section is **not part of the spec itself** but is embedded in this template as guidance for AI agents that will read and implement this specification.

### For AI Agents: How to Read This Spec

1. **Read the Purpose and Non-Goals first.** Never implement anything in the Non-Goals list.
2. **Implement every UX State.** The most common agent failure mode is implementing only the happy path (S-DATA) and ignoring S-LOADING, S-EMPTY, S-ERROR, and S-OFFLINE.
3. **Reference the Lexicon patterns.** When you see `@M`, `@O`, `@V`, etc., look up the exact implementation in `01-PLAN-LEXICON.md` and `05-XCT-SERVICES.md`. These are not suggestions; they are HARD constraints.
4. **Check Domain E (Security & Compliance) for every spec.** AI calls must route through LiteLLM. User content must use SanitizedHTML. New tables must have RLS. CSP must not be broken.
5. **Never remove a state or edge case from this spec.** If something seems impossible, flag it for Trevor's review — don't silently omit it.
6. **When you complete implementation, check off every acceptance criterion** and report which ones are verified.

### For AI Agents: How to Write a Spec Using This Template

When Trevor asks you to "produce a spec for [X]":

1. **Start with the YAML frontmatter.** Fill in every field. Set status to `draft`.
2. **Write the Purpose and Non-Goals first.** Get Trevor's confirmation before continuing.
3. **Brainstorm all UX States.** Ask yourself: "What if the data is loading? What if it's empty? What if it errors? What if we're offline? What if the user lacks permissions?"
4. **Define exact Data Shapes.** Reference existing tables and slices. Do not invent new structures without justification.
5. **Catalog Edge Cases.** Think about race conditions, concurrent edits, network interruptions, timezone issues, and AI failures.
6. **Write testable Acceptance Criteria.** Every criterion must be pass/fail verifiable.
7. **Tag the spec with complexity and risk_level.** When in doubt, err high.
8. **List all related_rules from the Lexicon** that constrain this spec. Missing a HARD rule is itself a violation.
9. **Output the complete file** and tell Trevor which items need his decision.

### For AI Agents: Size and Context Management

- **Maximum spec size:** Each spec should be completable in one agent session. If a spec exceeds ~300 lines, split it into parent + child specs using the Lexicon's Tier system (Tier 1 = standalone spec, Tier 2 = grouped, Tier 3 = design system only).
- **Use the extended TOC pattern from Addy Osmani:** "Summarize the spec above into a very concise outline with each section's key points and a reference tag."  This summary stays in the agent's context while full details are retrieved on demand.
- **For large specs:** The agent should build a hierarchical summary first, then work section by section. 

### For AI Agents: Post-Generation Validation (W3C Principle)

After generating code from this spec, the agent should:
1. Run the linked automated tests where they exist. 
2. Verify every acceptance criterion.
3. Report which criteria passed and which need human verification.
4. Flag any discrepancy between the spec and what was actually built.


## Part 4: Quick-Start Example

Below is a minimal but complete spec for a hypothetical component, showing the template in use.

```markdown
---
steering: TO PARSE — READ INTRO
file_name: 04-COMP-DASHBOARD-CONFLICT-BANNER.md
document_type: component_specification
module: Dashboard
tier: core
status: draft
owner: Trevor
description: Conflict notification banner that appears in the Dashboard when the conflict agent detects a scheduling conflict.
last_updated: 2026-04-26
version: 1.0
dependencies: [04-COMP-DASHBOARD.md, 10-UX-CONFLICT-FLOW.md]
related_adrs: []
related_rules: [XCT_01, XCT_02, FLOWC_03, g10, GRDL_01]
complexity: medium
risk_level: medium
---

# ConflictBanner — Component Specification

## 1. Purpose

### 1.1 What This Is
A dismissible, animated banner that appears in the Dashboard's AttentionQueue when the conflict agent detects a scheduling conflict. It presents the conflict with actionable resolution buttons and an "Ignore" option.

### 1.2 User Story
As a PM, I want to see scheduling conflicts surfaced on my dashboard so that I can resolve them without checking my calendar and project board separately.

### 1.3 Non-Goals
- Does NOT handle conflict detection logic (that's in the conflict engine).
- Does NOT handle external calendar write-back (Phase 1).
- Does NOT handle multi-user conflict resolution (deferred).

## 2. UX States

### 2.1 State Catalog
| State ID | State Name | Trigger Condition | Visual Behavior | User Action |
|----------|------------|-------------------|-----------------|-------------|
| S-LOADING | Loading | Conflict check in progress | Skeleton banner with pulse animation | None |
| S-NO-CONFLICT | No Conflicts | Check complete, zero conflicts | No banner shown. EmptyState in AttentionQueue: "All clear." | None |
| S-CONFLICT | Conflict Detected | ≥1 conflict found | Banner slides in from top (@M, @AP). Shows: event name, conflicting task name, time overlap. Three buttons: Reschedule, Move Task, Ignore. | Reschedule / Move Task / Ignore |
| S-RESOLVING | Resolving | User clicked action | Banner shows spinner. Buttons disabled. Text: "Resolving..." | None (optimistic) |
| S-RESOLVED | Resolved | Resolution succeeded | Banner shows checkmark + "Resolved!" for 3s, then slides out. Undo button for 5s. | Undo (5s window) |
| S-FAILED | Resolution Failed | Backend returned error | Banner turns red. Text: "Couldn't resolve. Try again?" Retry + Ignore buttons. | Retry / Ignore |

### 2.2 State Transitions
S-LOADING → S-NO-CONFLICT | S-CONFLICT
S-CONFLICT → S-RESOLVING (on action click) | S-NO-CONFLICT (on Ignore)
S-RESOLVING → S-RESOLVED | S-FAILED
S-RESOLVED → S-NO-CONFLICT (after undo timeout or undo clicked)
S-FAILED → S-RESOLVING (on retry) | S-NO-CONFLICT (on Ignore)

### 2.3 DO NOT
- DO NOT show more than one ConflictBanner at a time. Queue additional conflicts.
- DO NOT auto-dismiss a conflict without user action. (Proactive Phase 1 behavior is configurable.)
- DO NOT allow "Reschedule" for read-only external calendar events. Show "View in Calendar" instead.

## 3. Transitions & Animations
| Pattern | Applied To | Notes |
|---------|------------|-------|
| @M (MotionGuard) | Banner entrance/exit | transform: translateY(-100%) → translateY(0) |
| @AP (AnimatePresence) | Banner mount/unmount | |
| @O (OptimisticMutation) | Resolution action | pending: opacity 0.5 + italic + pulse. Undo 5s. |
| @Q (OpacityFade) | Resolved checkmark | ≤150ms |

## 4. Data Shapes

### 4.1 Zustand Slice
Reference: notificationSlice
```typescript
interface ConflictNotification {
  id: string;           // ULID
  org_id: string;
  type: 'conflict_detected';
  template: 'conflict_banner';
  deeplink: string;     // e.g., "/calendar?event=evt_xxx&task=tsk_yyy"
  read: boolean;
  data: {
    event_id: string;
    event_title: string;
    event_start: string;    // ISO 8601
    event_end: string;
    task_id: string;
    task_title: string;
    task_due: string;
    conflict_type: 'overlap' | 'adjacent' | 'deadline_during_event';
  };
}
```

### 4.2 API: Resolve Conflict
POST /v1/conflicts/resolve
Request: { notification_id, action: 'reschedule_event' | 'move_task' | 'ignore', new_time?: ISO8601 }
Response 200: { data: { status: 'resolved' } }
Response 400: { error: { code: 'VALIDATION_ERROR', message: '...' } }

### 4.3 Validation Rules
- new_time, if provided, must be a valid ISO 8601 datetime in the user's timezone.
- action 'ignore' must not include new_time.

## 5. Edge Cases & Error Handling

| ID | Scenario | Expected Behavior |
|----|----------|-------------------|
| EC-001 | Two conflicts detected simultaneously | Queue them. Show the highest-priority one first. |
| EC-002 | User resolves, but event was already moved by another session | Server returns CONFLICT_DETECTED error. Banner refreshes with updated data. |
| EC-003 | User clicks Undo after resolve | Optimistic rollback. 5-second window per XCT_02 rule. |
| EC-004 | Network fails during resolve | S-FAILED state. Retry button. Stale data shown with offline indicator. |

## 6. Acceptance Criteria
- [ ] All six UX states render correctly.
- [ ] Resolve action triggers optimistic UI within 100ms.
- [ ] Undo reverses the optimistic update within the 5-second window.
- [ ] Banner does not render when notification.read is true.
- [ ] Keyboard: Enter on "Reschedule" triggers action. Escape dismisses (equivalent to Ignore).
- [ ] Screen reader announces: "Scheduling conflict detected: [event] conflicts with [task]."
- [ ] aria-live="polite" on the banner container.

## 7. Accessibility
| Element | Role | aria-label |
|---------|------|------------|
| Banner container | alert | "Scheduling conflict detected" |
| Reschedule button | button | "Reschedule [event name]" |
| Move Task button | button | "Move task [task name]" |
| Ignore button | button | "Ignore this conflict" |

## 8. Testing Strategy
- Unit: Verify all state transitions.
- Component: Render each of 6 states, verify button actions fire correct callbacks.
- Integration (Playwright): Full flow: conflict detected → user clicks Reschedule → banner shows resolved → undo.
- Security: Verify RLS on notifications table (pgTAP). Verify SanitizedHTML on event/task titles.

## 9. Risks & Open Questions
- Risk: If conflict detection is slow (>3s), the loading skeleton may frustrate users. Mitigation: deterministic conflict engine should return in <200ms.
- Open: Should Ignored conflicts re-surface after a configurable time? → Deferred to Phase 1 proactive config (BP-013).
- Assumption: Only one org at a time (org switcher clears notification state per XCT_06).
```


## Part 5: Template Maintenance

**Versioning:** This template follows semantic versioning. Major version bump if sections are added or removed (affects all existing specs). Minor version bump if guidance is refined. Patch bump for typo fixes.

**Review cadence:** Review every 6 months against evolving agent best practices. The W3C machine-consumable spec guidelines are still in draft (as of March 2026); update this template when they stabilize. 

**Integration with planning corpus:** All specs produced with this template must be referenced in `00-PLANNING-BACKLOG.md` when they resolve a backlog item. The file name convention follows the numeric prefix system: `04-COMP-{MODULE}-{TOPIC}.md` for components, `10-UX-{FLOW}.md` for UX flows.

**Companion files:**
- `01-PLAN-LEXICON.md` — the pattern language this template references.
- `05-XCT-SERVICES.md` — the cross-cutting service implementations referenced by patterns.
- `00-PLANNING-BACKLOG.md` — items awaiting specs using this template.
- `START-HERE.md` — agent onboarding (references this template as the output standard).

---

*This template is a living document. If an AI agent consistently misinterprets a section, the section should be rewritten with clearer constraints, not blamed on the agent. The W3C principle holds: express requirements as constraints, not aspirations.* 
```

---

## Post-Delivery Analysis

Trevor, here's what this template does and why it's structured the way it is:

**What it incorporates from current industry best practices:**

| Source | What I Used |
|---|---|
| GitHub 2,500+ repo study | Six core areas (commands/testing/structure/style/git/boundaries) embedded in agent instructions and the quick-start example |
| W3C Machine-Consumable Specs (Mar 2026) | Requirements as constraints not aspirations; negative examples ("DO NOT" blocks); machine-readable requirement blocks; link requirements to automated tests; structure for selective retrieval |
| Addy Osmani's Agent Spec Framework (Jan 2026) | Strong structure (PRD-like sections), non-goals as essential, extend TOC/summaries for large specs, spec as living artifact |
| Princeton AGENTS.md study | Evidence that structured context reduces runtime 28.6% and tokens 16.6% |
| arXiv Architecture Descriptors study | Evidence that formal descriptors reduce navigation 33–44% and behavioral variance 52% |
| Microsoft Spec Playbook (Mar 2026) | Clear outcomes, non-goals, edge cases, acceptance criteria, smallest testable slice |
| Anthropic/Claude Code practices | Sub-agents for specialized tasks; each spec section as context slice |

**Why the "DO NOT" sections are everywhere:** The W3C finding is critical — when the training corpus is dominated by non-compliant patterns (95.9% of homepages fail WCAG, per the Web Almanac 2025), AI agents statistically default to the wrong behavior. Negative examples are a corrective mechanism that pure prose specifications lack. 

**Why each Section 2 (UX States) gets a table with explicit states:** The research shows that AI agents default to happy-path implementation. By making S-LOADING, S-EMPTY, S-ERROR, and S-OFFLINE required rows in a table, we force the agent to acknowledge them.

**The quick-start example is real:** I used your actual `ConflictBanner` component as the example so it doubles as a draft spec you can refine. It references your actual notification schema, the conflict resolution endpoint, and the Lexicon patterns.

**This template replaces the need for agents to guess.** When you inject this + a prompt like "Produce a spec for the calendar MonthView component" into a fresh session, the agent knows exactly what to produce.