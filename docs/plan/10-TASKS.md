# 10-TASKS.md

```
---
steering: TO PARSE — READ INTRO
file_name: TASKS.md
document_type: task_tracker
tier: operational
status: active
owner: Trevor (Solo Founder)
description: Lightweight project management system for Phase 0 through Phase 6. Designed to be readable and updatable by both Trevor and AI coding agents. Complements the Planning Backlog (decisions) and Milestones (tasks-and-gates).
last_updated: 2026-04-26
version: 1.0
dependencies: [01-PLAN-MILESTONES.md, 00-PLANNING-BACKLOG.md, 00-DECISIONS-LOG.md]
related_adrs: []
related_rules: []
complexity: low
risk_level: low
---

# Project Task Tracker — TASKS.md

## README: Why This Exists

The blueprint contains Phase tasks (`F001`-`F044`, `C001`-`C006`, etc.) and the planning backlog contains what must be decided before execution. This file is the bridge: it lists what must be **built** and in what order, tracks status, and enables AI agents to mark tasks as complete without guessing at project state.

**For Trevor:** This is your weekly status report. Check off completed tasks, see what's blocked, and know exactly what to tell an agent to work on next.

**For AI agents:** This is your work queue. When Trevor says "work on Phase 0 Block 0C," reference this file to find the specific task IDs, their descriptions, and their dependencies. Update status when a task is complete.

---

## Task States

| Status | Meaning | Who Sets It |
|--------|---------|-------------|
| `🔴 PENDING` | Not yet started | Default for all tasks |
| `🟡 IN PROGRESS` | Actively being worked on | AI agent when starting |
| `🟢 DONE` | Completed and reviewed by Trevor | Trevor after review |
| `⛔ BLOCKED` | Cannot proceed (dependency unresolved) | AI agent or Trevor |
| `⚪ DEFERRED` | Explicitly postponed to later phase | Trevor only |

**AI agent rule:** When you start a task, mark it `🟡 IN PROGRESS`. When you submit a PR for it, note "awaiting review" but do NOT mark it `🟢 DONE` — only Trevor marks tasks complete.

---

## Phase 0: Foundation & Core Magic

### Block 0A: Platform Skeleton

| ID | Task | Description | Status | Dependencies | Assigned To | Notes |
|----|------|-------------|--------|--------------|-------------|-------|
| F001 | Full-stack plumbing | Vite SPA + FastAPI + Supabase, RLS verified with pgTAP | 🔴 PENDING | BP-003, BP-004 | — | End-to-end connection; first green test |
| F002 | Auth: email/pw, org creation | Supabase Auth with custom access token hook for JWT org_id claim | 🔴 PENDING | BP-003 | — | No passkeys yet |
| F003 | Org switching | refreshSession + queryClient.clear + RT reconnect | 🔴 PENDING | F002 | — | Critical for multi-tenant |
| F004 | Basic CI | typecheck (tsc + tsgo), lint, RLS tests, GitHub Actions | 🔴 PENDING | F001 | — | No Schemathesis yet |
| F005 | Deploy: Fly.io + Vercel | FastAPI on Fly.io Machines v2, Vite SPA on Vercel | 🔴 PENDING | F001 | — | Single shared-cpu-1x, auto-stop |

### Block 0B: Local AI Infrastructure

| ID | Task | Description | Status | Dependencies | Assigned To | Notes |
|----|------|-------------|--------|--------------|-------------|-------|
| F006 | Ollama integration | Docker Compose, OpenAI-compatible API proxy, native tool calling support | 🔴 PENDING | BP-015 | — | Gemma 4 E2B default |
| F007 | llama.cpp backend | ik_llama.cpp fork: BitNet support, fused MoE, hybrid GPU/CPU ops | 🔴 PENDING | F006 | — | Better CPU & hybrid perf |
| F008 | Model registry initial population | Pull, verify checksum (SHA-256), register, serve Gemma 4 E2B & Qwen3.5 4B | 🔴 PENDING | F007 | — | GGUF Q4_K_M quantization |
| F009 | Quantization policy | GGUF Q4_K_M default; documentation of QIGen for non-uniform quant | 🔴 PENDING | F008 | — | ≤4.5GB RAM footprint |
| F010 | LiteLLM proxy integration | ≥1.83.7, cosign verified, Claude Sonnet 4.6 + Opus 4.7 as cloud fallback | 🔴 PENDING | F008 | — | Supply-chain verified |
| F011 | Intent Dispatcher v1 | Routes tool calls via preferred_executor: code → Haiku 4.5 → Sonnet 4.6 → Opus 4.7 | 🔴 PENDING | F010 | — | Pure-code decision layer |
| F012 | Local-first routing policy | Free-tier: all local models; cloud API gated behind subscription | 🔴 PENDING | F011 | — | Near-zero marginal cost |

### Block 0C: Chat + Agent Tool Calling

| ID | Task | Description | Status | Dependencies | Assigned To | Notes |
|----|------|-------------|--------|--------------|-------------|-------|
| F013 | Chat page shell | ThreadList, MessageList, ChatInput, MessageBubble | 🔴 PENDING | BP-002 | — | StaleTime:Infinity for AI messages; @V virtualization |
| F014 | Vercel AI SDK v6 streaming + tool calling | Production-ready streaming, tool approval gates, multi-step reasoning | 🔴 PENDING | F001 | — | Tool approval gates |
| F015 | LangGraph Supervisor pattern | Centralized supervisor routes to specialized workers; LangMem cross-session | 🔴 PENDING | F014 | — | Maps to FLOWC01 SM |
| F016 | Tool: calendar CRUD | create_calendar_event, update_calendar_event, delete_calendar_event | 🔴 PENDING | BP-004 | — | Backed by events table |
| F017 | Tool: task CRUD | list_tasks, create_task, update_task, delete_task | 🔴 PENDING | BP-004 | — | Backed by tasks table |
| F018 | Guardrails input layer | PII detection, jailbreak detection, toxicity screening | 🔴 PENDING | F014 | — | Activated for all AI calls |
| F019 | Guardrails output layer | Hallucination detection (LLM-as-judge via DeepEval), warning threshold | 🔴 PENDING | F018 | — | Not blocking in Phase 0 |

### Block 0D: Data Apps — Calendar & Tasks

| ID | Task | Description | Status | Dependencies | Assigned To | Notes |
|----|------|-------------|--------|--------------|-------------|-------|
| F020 | Events table + FastAPI CRUD | events(id, org_id, title, start, end, tz, allDay, recurrence_id, cat, uat) | 🔴 PENDING | BP-003, BP-004 | — | |
| F021 | Calendar views | MonthView, WeekDayView, AgendaView | 🔴 PENDING | BP-002 | — | @M MotionGuard, @Z TimezoneAware |
| F022 | EventComposer | Optimistic create/edit/delete, 5s undo, recurring support | 🔴 PENDING | F021 | — | |
| F023 | EventDetailDrawer | Inline edit, delete, agent log | 🔴 PENDING | F022 | — | Tabs: details, agent history, related tasks |
| F024 | Drag-and-drop reschedule | dnd-kit centralized façade, optimistic, keyboard alt | 🔴 PENDING | F021 | — | WCAG 2.5.7 |
| F025 | Recurrence | rschedule + @rschedule/temporal-date-adapter | 🔴 PENDING | — | — | ZonedDateTime mandatory; DST matrix tests |
| F026 | Tasks table + FastAPI CRUD | tasks(id, org_id, project_id, title, status, assignee, due, priority, order) | 🔴 PENDING | BP-003, BP-004 | — | |
| F027 | Task list view | Status toggles, due dates, inline editing, optimistic mutations | 🔴 PENDING | BP-002, F026 | — | @V virtualization |
| F028 | Kanban board | Drag-and-drop columns, task cards, pointerWithin detection | 🔴 PENDING | F027 | — | @O optimistic on column change |
| F029 | Task comments | Internal/external, DOMPurify RICH profile | 🔴 PENDING | F028 | — | Agent-generated notes |
| F030 | Calendar-Project linking | Tasks with due dates → calendar overlay | 🔴 PENDING | F025, F028 | — | Tasks appear as overlay on calendar views |
| F031 | Google Calendar read-only sync | OAuth 2.0, sync engine, periodic fetch (free API, 1M req/day) | 🔴 PENDING | BP-016 | — | Not real-time; periodic fetch |

### Block 0E: Dashboard & Conflict Agent

| ID | Task | Description | Status | Dependencies | Assigned To | Notes |
|----|------|-------------|--------|--------------|-------------|-------|
| F032 | Dashboard shell | AmbientStatusBanner, ActivityFeed, AttentionQueue | 🔴 PENDING | BP-002, BP-006 | — | @M MotionGuard, @AP AnimatePresence |
| F033 | Notification table + real-time sub | notifications(id, org_id, user_id, template, deeplink, read, cat) | 🔴 PENDING | BP-003 | — | |
| F034 | Notification feed with action buttons | "Reschedule", "Move task", "Ignore" | 🔴 PENDING | F033, BP-006 | — | InAppNotifications template+deeplink |
| F035 | Conflict detection engine | Deterministic overlap algorithm, multi-timezone | 🔴 PENDING | F020, F026 | — | Pure code — no LLM involved |
| F036 | Agent orchestration | Chat → detect_conflicts tool → Dashboard notification | 🔴 PENDING | F011, F035 | — | Orchestrator (local) calls tool; Dispatcher routes to code |
| F037 | Agent action execution | Dashboard action → orchestrator → tool call → confirmation | 🔴 PENDING | F036, BP-006 | — | resolve_conflict tool; confirmation logged |
| F038 | Cost tracking | ai_cost_log TimescaleDB hypertable, per-org/per-model | 🔴 PENDING | BP-003 | — | x-litellm-tags |

### Block 0F: Monetization & Polish

| ID | Task | Description | Status | Dependencies | Assigned To | Notes |
|----|------|-------------|--------|--------------|-------------|-------|
| F039 | Stripe metered billing | @stripe/ai-sdk v0.1.2, token tracking, 30% markup | 🔴 PENDING | BP-011, BP-017 | — | Four-layer cost governance |
| F040 | Subscription tiers | Free (local), Pro ($20-30/mo), Team (Opus 4.7) | 🔴 PENDING | F039, BP-011 | — | Stripe customer portal |
| F041 | CSP policy | Nonce strategy, strict-dynamic, Report-Only pre-prod | 🔴 PENDING | BP-009 | — | DOMPurify ≥3.4.0 |
| F042 | Rate limiting | FastAPI-Limiter + Upstash Redis, per-user/org | 🔴 PENDING | — | — | 429 with Retry-After |
| F043 | WORM audit logging | All agent decisions immutable | 🔴 PENDING | — | — | audit_logs table; hash chaining |
| F044 | Pre-launch security audit | CSP, RLS, rate limiting, MCP tool auth | 🔴 PENDING | F041, F042, F043 | — | Red teaming for prompt injections |

---

## Phase 1: Public Launch & Proactive Intelligence *(future — not yet active)*

*Tasks P101-P121 from `01-PLAN-MILESTONES.md` are listed but collapsed into a single reference until Phase 1 trigger is reached.*

| ID | Task | Status |
|----|------|--------|
| P101 | Sentry error tracking: 4 projects | 🔴 PENDING |
| P102 | PostHog analytics: event taxonomy, Group Analytics | 🔴 PENDING |
| P103 | OTel GenAI traces | 🔴 PENDING |
| P104 | Nylas Email API | 🔴 PENDING |
| P105 | Email-triggered conflict detection | 🔴 PENDING |
| P106 | grant.expired webhook handling | 🔴 PENDING |
| P107 | Resend transactional email | 🔴 PENDING |
| P108 | Agent proactivity configuration per plan | 🔴 PENDING |
| P109 | Proactive notification engine | 🔴 PENDING |
| P110 | Verifier cascade (Phi-4-mini) | 🔴 PENDING |
| P111 | Model capability registry | 🔴 PENDING |
| P112 | Loop controller (SLM-6) | 🔴 PENDING |
| P113 | Model update/deprecation policy | 🔴 PENDING |
| P114 | Second local model (Llama4-7B) | 🔴 PENDING |
| P115 | Google Calendar write support | 🔴 PENDING |
| P116 | Outlook Calendar read-only | 🔴 PENDING |
| P117 | Project Timeline/Workload views | 🔴 PENDING |
| P118 | Project templates & automation | 🔴 PENDING |
| P119 | User onboarding flow | 🔴 PENDING |
| P120 | AI cost monitoring dashboard | 🔴 PENDING |
| P121 | Feature flags (OpenFeature + Vercel Flags SDK) | 🔴 PENDING |

---

## Phase 2+: Suite Expansion & Beyond

*Full task list in `01-PLAN-MILESTONES.md`. Not expanded here. Agents: reference the milestone document for P201-P606 when the Phase 2 trigger fires.*

---

## Cross-Cutting Tasks (All Phases)

| ID | Task | Description | Status | Phase |
|----|------|-------------|--------|-------|
| XCT-001 | Motion spec | transform/opacity, reduced motion, stagger≤3 | 🟡 IN PROGRESS | 0 |
| XCT-002 | Optimistic UI | React 19 useOptimistic, pending styling, 5s undo | 🔴 PENDING | 0 |
| XCT-003 | Realtime streaming | SSE Last-Event-ID, heartbeat, SB channel auth | 🔴 PENDING | 0 |
| FLOWC-001 | Workflow SM visualizer | Transition guard | 🔴 PENDING | 2 |
| APIC-001 | OpenAPI 3.1 → Orval codegen pipeline | OAI3.1 source of truth | 🔴 PENDING | 0 |
| COST-001 | Multi-level budget enforcement | org/team/user/model + 15/5/0% alerts | 🔴 PENDING | 0 |
| SECM-001 | Security Control Matrix | S1-S21 control mapping + evidence | 🔴 PENDING | 0 |
| GRDL-001 | AI guardrails: 3-layer | input/output/runtime + audit | 🔴 PENDING | 0 |

---

## How AI Agents Update This File

1. **When starting a task:** Change status to `🟡 IN PROGRESS` and add your session reference in the Notes column.
2. **When blocked:** Change status to `⛔ BLOCKED` and note the blocker (e.g., "⛔ BLOCKED — waiting on BP-003 DDL resolution").
3. **When submitting a PR:** Add a note: "PR submitted — awaiting Trevor review (session-YYYY-MM-DD)." Do NOT mark as DONE.
4. **Never remove rows.** If a task is superseded, add a note referencing the superseding task ID.

---

## Weekly Status Snapshot

*Trevor updates this section at the start of each week.*

| Week | Date | Tasks Completed | Tasks In Progress | Blockers |
|------|------|-----------------|-------------------|----------|
| 1 | — | 0 | 0 | Planning phase active; no execution yet |

---

## Task Statistics

| Phase | Total Tasks | Pending | In Progress | Done | Blocked |
|-------|-------------|---------|-------------|------|---------|
| Phase 0 | 44 | 44 | 0 | 0 | 0 |
| Phase 1 | 21 | 21 | 0 | 0 | 0 |
| Cross-Cutting | 8 | 7 | 1 | 0 | 0 |
| **Total** | **73** | **72** | **1** | **0** | **0** |

---

*This file is the operational companion to the strategic planning corpus. When in doubt about what to work on next, check the first 🔴 PENDING task in the current phase block.*
```

---