# 00-PHASE0-PRE-MORTEM.md

```
---
steering: TO PARSE — READ INTRO
file_name: 00-PHASE0-PRE-MORTEM.md
document_type: pre_mortem
tier: strategic
status: stable
owner: Trevor (Solo Founder)
description: Pre-mortem analysis for Phase 0. Assumes failure has occurred and reverse-engineers the most likely causes, so they can be prevented before execution begins.
last_updated: 2026-04-26
version: 1.0
dependencies: [01-PLAN-MILESTONES.md, 00-STRAT-BLUEPRINT.md, 00-PLANNING-BACKLOG.md, 00-DECISIONS-LOG.md]
related_adrs: []
related_rules: []
complexity: medium
risk_level: high
---

# Phase 0 Pre-Mortem — "It Failed. Now What?"

## README

A pre-mortem is a thought experiment: assume Phase 0 has failed to deliver its exit gate (one external user signs up, connects Google Calendar, creates tasks, and sees the agent detect a scheduling conflict — all without human intervention). Work backward: what went wrong?

This document identifies the most likely failure modes, their early warning signs, and concrete mitigations. It is NOT a risk registry (the milestone document already has one). It is a narrative exercise in pessimistic imagination, designed to surface blind spots that structured planning missed.

**When to review:** Before starting Phase 0 execution, and at the mid-point of each block. If any "early warning sign" below is observed, escalate immediately.

**Research foundation:** The pre-mortem technique was pioneered by Gary Klein (1998) and validated by Harvard Business School research showing that "prospective hindsight" — imagining an event has already occurred — increases the ability to correctly identify reasons for future outcomes by 30%. This format adapts the method to a solo-founder AI-agentic development context.


## Failure Scenario 1: The Local Model Can't Cut It

### The Story
Phase 0 Block 0B invested four weeks integrating Ollama, llama.cpp, and Gemma 4 E2B as the default orchestrator. The model registry was populated, the Intent Dispatcher routed correctly, and the tool definitions were solid. But when Trevor sat down with the first external tester, the agent kept misinterpreting "Reschedule my call to Tuesday" — it created a new event instead of moving the existing one. Or it called `create_task` when it should have called `update_task`. Or it hallucinated a nonexistent calendar event.

The tool-calling pass rate on real-world prompts was 82%, not the 90%+ required. The demo felt broken. The tester said, "It doesn't understand me." Phase 0 failed to produce the magic moment.

### Why It's Plausible
- Gemma 4 E2B has only 2B active parameters. While it has native tool-calling tokens, its ability to correctly disambiguate between similar tool names (`create_calendar_event` vs. `update_calendar_event`) on complex, multi-step instructions is unproven outside benchmark conditions.
- The automated test suite may cover 40+ test cases, but test cases are clean. Real user input is messy: typos, ambiguous phrasing ("push my meeting to later"), incomplete information.
- The Qwen3.5 4B fallback (97.5% reported tool-calling) might also underperform on the specific conflict-detection tool chain, which involves cross-referencing across calendar and tasks.

### Early Warning Signs
- During Block 0B testing, the orchestrator fails tool-selection tests with ambiguous prompts.
- The verifier (Phi-4-mini, Phase 1) rejects more than 15% of orchestrator plans.
- Trevor, testing ahead of the demo, finds himself rephrasing prompts to "help" the agent.

### Mitigations
1. **Aggressively benchmark BEFORE committing to Gemma 4 E2B.** BP-015 must be completed before Block 0B starts. If independent benchmarks show <90% on tool-calling tasks similar to conflict detection, START with Qwen3.5 4B as the orchestrator and skip Gemma 4 E2B entirely.
2. **Build a "graceful degradation" fallback chain.** If the local orchestrator fails a tool call, the system should seamlessly escalate to Sonnet 4.6 (Pro tier placeholder) for that single call, log the escalation, and notify Trevor. The tester doesn't need to know the model switched — they just need it to work.
3. **Over-engineer the prompt templates for Phase 0 tools.** Spend extra time on few-shot examples, negative examples ("DON'T create a new event when the user says 'reschedule'"), and explicit tool selection rules in the system prompt.
4. **Accept that Phase 0 Block 0B might take 8 weeks, not 4.** This is the highest-technical-risk block. If it fails, everything else is irrelevant. Give it the time it needs.

### Contingency Plan
If local models cannot reach 90% tool-calling reliability by Week 8, pivot: Phase 0 demo uses Sonnet 4.6 as the default orchestrator, with a clear plan to migrate to local models in Phase 1 as they improve. This violates the "Local-Default, Cloud-Fallback" axiom temporarily, but a working demo that costs $0.50 in API calls is better than a broken demo that costs $0.


## Failure Scenario 2: The Conflict Demo Is Underwhelming

### The Story
The infrastructure works. The tester connects Google Calendar, creates tasks, and the agent detects a scheduling conflict. A notification appears: "⚠️ Conflict: Team Standup overlaps with Project Deadline Review." But the resolution options are mechanical: "Reschedule Event" or "Move Task." The tester tries both — they work — but the experience feels like a Google Calendar notification, not a breakthrough AI product.

The tester says, "Cool, but I could have seen this myself." They don't convert to a paid user. The "aha moment" didn't happen.

### Why It's Plausible
- The conflict detection engine is deterministic code (intentionally). It finds overlaps. But "finding overlaps" is table stakes — Google Calendar already does this. The value proposition is "cross-application, context-aware AI assistance," but if the resolution options are just mechanical rescheduling, the "AI" part is invisible.
- The blueprint acknowledges the "appearance of AI" as an open design question. If left unresolved, the product feels like a rules engine with a chat interface, not an intelligent assistant.
- The notification's copy, the action button labels, and the post-resolution feedback are all micro-copy moments that an AI agent might produce with generic, low-quality text.

### Early Warning Signs
- During internal testing, Trevor uses the conflict feature and feels "meh" rather than "wow."
- The action buttons are labeled with CRUD verbs ("Reschedule Event") instead of natural language ("Move this meeting to Wednesday at 2pm").
- The resolution doesn't include an explanation: "I moved your 3pm call to Thursday because your project deadline is Friday."

### Mitigations
1. **The conflict UX is the most important planning task.** BP-006 must be resolved with obsessive attention to the language of resolution. The agent should propose a specific new time, explain its reasoning, and show confidence in natural language ("I've moved the standup to 2:30pm — that's the only window before the deadline review. Want me to send a calendar update?").
2. **Invest in micro-copy.** Every button, notification, and agent response should be crafted by an AI agent instructed to produce copy that feels like a thoughtful human assistant, not a command-line tool. Include examples in the UX spec of "good" vs. "great" language.
3. **Add a "Why?" affordance.** The notification should include a one-line explanation of why the agent flagged this conflict ("This meeting overlaps with a project deadline"), not just that it exists.
4. **Build a "surprise and delight" moment.** After the user resolves the first conflict, the agent could proactively note: "By the way, I noticed your Thursday is now wide open — want me to schedule your deep work block?" This is a Phase 1 feature, but having a placeholder in Phase 0 makes the vision tangible.

### Contingency Plan
If the conflict demo still feels underwhelming after UX refinement, add a Phase 0 bonus feature: the agent generates a "weekly conflict report" summarizing all detected and resolved conflicts, showing the user time saved. This transforms a single notification into a narrative of ongoing value.


## Failure Scenario 3: The Onboarding Flow Is Confusing

### The Story
Trevor's external tester is a friend-of-a-friend — a project manager who uses Google Calendar daily. They agree to try the product. The signup works fine, but then:
- The OAuth flow for Google Calendar asks for "See, edit, share, and permanently delete all your calendars." The tester hesitates. They grant access reluctantly.
- After connecting, they see an empty calendar and an empty task list. There's no guidance. "What do I do now?"
- They add a task, but don't realize they need to also create a calendar event to trigger a conflict. Nothing happens. The dashboard shows "All clear."
- They leave. Phase 0 has no second tester lined up.

### Why It's Plausible
- The blueprint specifies OAuth read-only for Phase 0 (RESOLVED in the milestone document: "Google Calendar read-only integration"). But the OAuth consent screen still lists scary permissions by default. Google's OAuth verification process may also flag a new app with insufficient explanation.
- The first-time user experience is entirely undefined (BP-007). An empty calendar with no guidance is the most common failure mode for productivity apps.
- The "aha moment" requires the user to perform two distinct actions (create a task AND create a conflicting calendar event) before the agent does anything. If the user only does one, nothing happens.

### Early Warning Signs
- The tester asks Trevor "What am I supposed to do?" within the first 90 seconds.
- The Google OAuth consent screen takes more than one click to complete.
- No notification appears within 2 minutes of setup.

### Mitigations
1. **BP-007 is a P0 backlog item for a reason.** The onboarding flow must be fully specified before Phase 0 Block 0F. It must include: a welcome message, a guided step-by-step flow ("Step 1: Connect your calendar" → "Step 2: Create your first project" → "Step 3: Add a task with a due date"), and explicit instructions for triggering the conflict demo.
2. **Seed demo data.** For the first tester specifically, provide a "Quick Start" button that auto-creates a sample project, a sample task, and a conflicting calendar event — then immediately triggers the conflict detection. The tester sees the magic in 30 seconds, then can create their own data afterward.
3. **Pre-configure a dedicated Google Cloud project** for the demo with a verified OAuth consent screen, limited scopes (read-only calendar), and a clear app description. Avoid the scary permission screen entirely.
4. **Line up 3 testers, not 1.** The Phase 0 exit gate says "one external user." But one tester is fragile — they might be busy, might not "get it," or might encounter a network issue. Three testers increases the probability that at least one completes the flow successfully.

### Contingency Plan
If onboarding friction kills the demo, offer a "recorded demo" fallback — screen-share the product with the tester watching, control the flow yourself, and let them ask questions. This isn't the exit gate (which requires self-service), but it preserves the tester relationship and generates feedback.


## Failure Scenario 4: AI Agent PR Review Becomes the Bottleneck

### The Story
Trevor planned to review every AI-generated PR. But the agents are fast — they produce 3-5 PRs per day. Each PR touches multiple files, introduces new dependencies, or modifies database schemas. Reviewing one PR takes 30-45 minutes because:
- The agent's code works but doesn't follow the `.windsurfrules` perfectly.
- Trevor has to manually verify RLS policies, CSP compliance, and guardrail integration.
- After the third PR on a Tuesday evening, Trevor's attention is spent. The review quality drops. A bug slips through — an API endpoint without proper auth, or a Zustand slice that directly imports another slice violating `ZUSTANDCIRCULAR`.
- The bug is caught in production by the tester. Trust in the product is damaged.

### Why It's Plausible
- Trevor is not a developer. Reviewing AI-generated code is a learned skill with a steep learning curve. Identifying subtle logic errors in code you didn't write — in a language you didn't write — is harder than writing it yourself.
- The agents are optimizing for code generation, not for reviewability. PRs may be large, poorly documented, or include unrelated changes.
- The review checklist (`00-WORKFLOW-REVIEW.md`, to be created as Item 6) is necessary but not sufficient. It still requires human vigilance to apply consistently.

### Early Warning Signs
- Trevor's PR review time exceeds 20 minutes per PR.
- Trevor feels mentally exhausted after reviewing PRs and starts rubber-stamping them.
- A HARD rule violation is caught not during review, but during testing or in production.

### Mitigations
1. **`00-WORKFLOW-REVIEW.md` must be created and followed relentlessly.** It should include a 5-minute pre-check that catches the most common violations BEFORE deep review. If the pre-check fails, reject the PR immediately without reading the rest.
2. **Automate automated review.** Add CI gates that catch HARD rule violations: ESLint rules for `ZUSTANDCIRCULAR`, Supabase CLI tests for RLS, Schemathesis for API contract drift, and DOMPurify checks for sanitization. The agent should be forced to pass these gates before Trevor ever sees the PR.
3. **Limit daily PR intake.** Trevor should set a personal max: no more than 3 PRs per evening session. If agents produce more, they queue up. This prevents fatigue.
4. **Delegate low-risk PRs to auto-merge.** Define a "safe" category of changes that can merge without review: CSS-only changes, documentation updates, test data modifications, copy changes. This frees review bandwidth for high-risk changes (auth, database, AI, billing).
5. **Practice reviewing toy PRs first.** The "Practice Run" (Item 10) is partly for this — Trevor should review AI-generated code for a throwaway project before reviewing production code.

### Contingency Plan
If the review bottleneck is unmanageable by Week 3 of Phase 0, Trevor should consider hiring a part-time code reviewer (not a developer — a reviewer who audits AI output against the rules). This is an unplanned cost (~$500-1,000/month) but cheaper than shipping broken code.


## Failure Scenario 5: Scope Creep During "Planning" Phase

### The Story
Trevor committed to exhaustive planning before writing any code. The planning backlog has 20 items. Research sessions generate more questions than answers. The `00-PLANNING-BACKLOG.md` grows from 20 to 40 items. Each resolved item suggests two more decisions needed. Phase 0 execution, originally targeted for "after 5 planning sessions," slides to 15 sessions, then 25. Three months pass without a single line of production code.

Meanwhile, the technology landscape shifts. Qwen3.6 is released. Stripe deprecates agent-toolkit v1. The EU AI Act gets another amendment. The blueprint's version pins start to feel stale. Trevor has the most thoroughly planned unbuilt product in SaaS history.

### Why It's Plausible
- Trevor's instinct to plan exhaustively is correct for a project of this scale. But the line between "exhaustive planning" and "analysis paralysis" is blurry, especially for a solo founder without external accountability.
- Planning is intellectually satisfying. It feels like progress. Execution is messy and involves failure. The brain prefers planning.
- The "do not execute until all P0 items are resolved" rule (DEC-2026-04-26-002) can become a self-imposed prison if there's no hard limit on the number of P0 items.

### Early Warning Signs
- More than 30 days have passed since the start of planning without starting Block 0A.
- The backlog grows faster than it shrinks.
- Trevor feels a nagging sense that he's "almost ready" but never actually starts.
- New research sessions revisit decisions already made, reopening closed items.

### Mitigations
1. **Set a hard deadline for planning completion.** "Phase 0 Block 0A code generation begins on [date], regardless of how many P0 items remain." The remaining P0 items become P1 (for Phase 0 Blocks 0C-0F). This is scary but necessary.
2. **Cap the P0 backlog at 13 items.** No new P0 items can be added unless an existing P0 is resolved or demoted. This prevents infinite expansion.
3. **Use a "planning budget."** Allocate 40 hours to planning (5 sessions × 8 hours). When the budget is exhausted, start executing with whatever is resolved.
4. **Schedule the first tester now.** Even if you don't know the exact demo date, having a named person who has agreed to test creates accountability. You can't postpone indefinitely when someone is waiting.

### Contingency Plan
If planning has clearly passed the point of diminishing returns, execute a "minimum viable planning" pivot: resolve only BP-001, BP-003, BP-004, and BP-006 (the absolute minimum needed for Block 0A), then start coding. The remaining items are resolved in parallel with early development. The world will not end if the notification system isn't perfectly designed before the first calendar component renders.


## Failure Scenario 6: External Dependency Breaks

### The Story
It's Week 6 of Phase 0. Trevor has just finished the Google Calendar OAuth integration (Block 0D). But overnight:
- Google Calendar API introduces a breaking change to its event schema.
- OR: Supabase has a multi-hour outage on the day Trevor's tester tries the product.
- OR: Ollama releases v0.6.0, which changes the model serving API and breaks Trevor's Docker Compose setup.
- OR: Stripe's agent-toolkit introduces a new version that isn't backward-compatible with the token-meter Trevor integrated in Week 5.

Trevor, working solo, can't fix all of these simultaneously. The demo is delayed by two weeks.

### Why It's Plausible
- The tech stack has 20+ external service dependencies (Supabase, Fly.io, Vercel, Ollama, LiteLLM, Nylas, Stripe, Google, Resend, Sentry, PostHog, etc.). Each is a point of failure.
- The blueprint pins versions, but upstream releases and deprecations happen regardless.
- Solo founders have zero buffer — any unexpected incident consumes attention that was budgeted for feature work.

### Early Warning Signs
- A dependency announces a deprecation or breaking change with a deadline within Phase 0's timeline.
- An upstream service experiences an outage lasting more than 4 hours.
- Trevor encounters a bug in a dependency that has no workaround documented.

### Mitigations
1. **Version-pin aggressively (already done).** The Lexicon pins every package to a specific version. This prevents unexpected breaking changes from automatic updates.
2. **Build local fallbacks for critical paths.** The local-model-first architecture is itself a mitigation against API outages — if Ollama is down, the agent falls back to cloud. If both are down, the system displays a graceful error.
3. **Mock all external services in CI.** The MSW integration pattern (TESTC_07 rule) ensures that PRs are tested against mock services, not live APIs. A Supabase outage should not block PR testing.
4. **Subscribe to changelogs for all critical dependencies.** Set up Google Alerts or RSS feeds for: Anthropic API, Stripe Changelog, Google Workspace Updates, Supabase Changelog, Ollama GitHub releases.
5. **Budget a "dependency firefighting" buffer.** Assume 20% of Phase 0's schedule will be consumed by dealing with upstream changes. 12-week plan → plan for 15 weeks.

### Contingency Plan
If a critical dependency breaks with no quick fix, have a "degraded mode" for the demo. Example: if Google Calendar OAuth breaks, the demo uses manually entered events (already supported in the events table CRUD). The tester sees the conflict detection working, just without the auto-import. The integration is fixed after the demo.


## Pre-Mortem Summary: Top Mitigations to Implement Before Phase 0

| Priority | Mitigation | Failure Scenario Addressed |
|----------|------------|---------------------------|
| 1 | Complete BP-015 (local model benchmarks) BEFORE Block 0B | #1 |
| 2 | Complete BP-006 (conflict UX spec) with natural-language resolution language | #2 |
| 3 | Complete BP-007 (onboarding flow) with a "Quick Start" demo data seeder | #3 |
| 4 | Set a hard planning-completion deadline | #5 |
| 5 | Create `00-WORKFLOW-REVIEW.md` and implement automated CI gates | #4 |
| 6 | Line up 3 external testers, not 1 | #3 |
| 7 | Version-pin aggressively and subscribe to dependency changelogs | #6 |
| 8 | Budget 20% schedule buffer for dependency firefighting | #6 |
| 9 | Complete the "Practice Run" dry-run project before Phase 0 | #4 |
| 10 | Cap P0 backlog at current 13 items — no new P0 without demoting another | #5 |


## Early Warning Signal Dashboard

*Trevor reviews this at the start of each week during Phase 0.*

| Warning Signal | Status This Week | Action If Triggered |
|----------------|------------------|---------------------|
| Tool-calling fail rate on test suite >10% | | Escalate: re-evaluate orchestrator model choice |
| A tester asks "What am I supposed to do?" | | Escalate: add onboarding guidance immediately |
| PR review time per PR >20 minutes | | Escalate: tighten automated CI gates, reduce daily PR load |
| Planning phase exceeds 30 days without execution start | | Escalate: execute minimum viable planning pivot |
| A critical dependency announces a breaking change | | Escalate: allocate firefighting time, communicate with tester |
| Backlog grows to >20 P0 items | | Escalate: demote non-critical P0s to P1 |
| Trevor feels mentally exhausted during review sessions | | Escalate: take a day off, reduce PR intake |


---

*This pre-mortem is a living document. After every Phase 0 block, review the "Early Warning Signals" table. If any signal triggers, the relevant mitigation section should be activated immediately — not "when we have time." The purpose of a pre-mortem is to have the contingency plan ready before the crisis, not to scramble after it happens.*
```

---
