---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-0-UPD.md
document_type: research_sessions
tier: strategic
status: draft
owner: Research Team
description: Parallel research sessions across AI platforms
last_updated: 2026-04-25
version: 1.0
dependencies: []
related_adrs: []
related_rules: []
complexity: medium
risk_level: low
---

# Parallel Research Sessions Across AI Platforms

Based on your answers, Trevor, we now have a clear, unified direction. Let's update the strategic planning documents to reflect everything we've settled on.

I'll provide the updated contents for the core files: a refined blueprint overview, phasing plan, product requirements, and the AI architecture with the new Intent Dispatcher. Everything else remains technically valid and will be adjusted gradually as development proceeds.

---

## Updated 00-00-00.md (Blueprint Overview)

This document now captures the product identity, core design axiom, reprioritized MVP scope, phase gating triggers, and open questions. All existing technical validation and six-domain structure is preserved.

```markdown
---
steering: TO PARSE - READ INTRO
file_name: 00-00-00.md
document_type: blueprint_overview
tier: strategic
status: stable
owner: Executive / Product
description: AI-Agentic SaaS Stack Blueprint — now with clarified product identity, design axiom, MVP scope, and phasing
last_updated: 2026-04-25
version: 2.0
---

# The AI-Agentic SaaS Stack Blueprint (2026)

## Product Identity

The product is an **AI‑integrated SaaS productivity platform**. It provides:
- A **dashboard** to monitor, interact with, and control AI agents.
- A **feature‑rich chat** page (like ChatGPT / Claude) where the user converses with agents.
- A **suite of productivity applications** (Calendar, Projects, Email, etc.) where both the user and AI agents can create, read, update, and delete data.

### Core Innovation
**Cross‑application, context‑aware AI assistance.** An agent that notices conflicts across apps (e.g., an email rescheduling request conflicting with a project deadline) and proactively brings it to the user's attention with actionable options. This depth of integrated awareness does not exist at scale in current products.

### Design Axiom: LLM‑First, Rule‑Optimized
The experience is **LLM‑driven** at the orchestration layer: an AI agent decides what to do and which tools to call.  
However, the **tools themselves are largely deterministic code**.  

- An LLM orchestrator interprets user intent and selects actions.  
- Complex reasoning is routed to powerful models; simple, repetitive tasks are routed to lightweight models or pure code.  
- The system minimizes actual LLM utilization by giving the AI highly efficient, pre‑built tools, rather than having the model generate logic.  

This gives the user an intelligent, conversational assistant while keeping costs low, reliability high, and audit trails clear. It also naturally accommodates a future where AI models get cheaper or even run locally.

---

## Critical Analysis & Restructured Blueprint (unchanged)

[ *The full six‑domain framework, research validation matrix, dependency map, etc. from the original 00-00-00.md remains here, untouched. This is the complete vision.* ]

---

## Open Questions (to be resolved during build)

- **Proactive behavior**: How often should agents check for conflicts? Tied to subscription tiers and per‑feature configuration. Will be defined later; planning docs must reference this as a configurable policy.  
- **"Appearance of AI" UX**: UI patterns that make deterministic actions feel agentic (natural‑language summaries, thinking indicators, agent avatars). Open for design exploration.  
- **Monetization model**: Likely a free tier with extremely limited AI calls and locked modules; paid tiers with graduated AI access. Details to be finalized before Phase 1 launch.  
- **Multi‑tenancy**: Data model supports org_id from day one, but cross‑user conflict detection is deferred and documented.  

---

## Phased Delivery Strategy

### Phase 0: Foundation Shell + Single App
*Goal: Prove the full technical stack works, with AI‑agent control.*
- Auth, org switching, Dashboard shell with notification feed.
- One productivity app: **Calendar** (manual event creation, no external sync).
- Chat page with basic agent interaction (tool calling, simple intent handling).
- Agent can create / modify calendar events via MCP‑style tools.
- No revenue features yet.

**Phase Gate → Phase 1:** Successfully demonstrated to a closed group of test users.

### Phase 1: The First Cross‑App AI Flow (MVP)
*Goal: Deliver the "aha moment" that sells the platform.*
- Add a simple **Project board** (tasks with due dates).
- Implement the **Conflict Detection Agent**: on user request (or lightweight schedule), the agent examines calendar and projects, detects scheduling conflicts, posts a notification to the Dashboard with action buttons ("Reschedule", "Move task").
- The Chat agent can also be asked to find and resolve conflicts conversationally.
- Stripe billing activated (early adopter pricing).
- Immediate integration with popular external tools (Google Calendar, Outlook) is **essential** for adoption; users must be able to connect their existing data. MVP will support at least read‑only calendar sync.

**Phase Gate → Phase 2:** First paying customer.

### Phase 2: Email Integration & Proactive Agents
- Integrate Nylas for email (read and send). Incoming rescheduling emails automatically feed the conflict agent.
- Agent proactive behavior configurable per plan.
- Begin tool suite expansion (Contacts, Documents, etc.) one module at a time.

### Phase 3+: Scale & Full Blueprint
- Expand the application suite.
- Add offline sync, real‑time collaboration, voice, mobile.
- Full compliance automation (SOC2, EU AI Act).
- Team hiring as revenue permits.

---

## Intent Dispatcher (New Architectural Component)

A **pure‑code decision layer** in Domain C (AI Core) that routes every potential AI call:
1. **Deterministic tools** that can be called directly by the orchestrator without an LLM for that specific sub‑step (e.g., check a database for conflicts).
2. **Lightweight models** for simple NLP tasks (email parsing, keyword extraction).
3. **Powerful models** for complex reasoning, conversational chat, and multi‑step planning.

The orchestrator itself (an LLM) uses this dispatcher to execute tools efficiently.

---

## Research Validation & Domain Details (unchanged)

[ *All sections from the original 00-00-00.md continue below, with EU AI Act dates corrected to 2027/2028 where applicable.* ]
```

---

## Updated 00-PLAN-1-INTRO.md (Phasing & Milestones)

I've adjusted the milestones and tasks to align with the new Phase 0+1 MVP, while preserving the original long‑term milestones further out.

```markdown
---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-1-INTRO.md
document_type: research_sessions_and_milestones
tier: strategic
status: draft
owner: Executive / Product
description: Parallel research sessions, milestones, and tasks — updated for product identity and phased MVP
last_updated: 2026-04-25
version: 2.0
---

# Revised Milestones & Tasks

// Old timeline removed; new phased approach based on gates.

## Phase 0: Foundation + Single App (current)
- Auth / org creation
- Dashboard shell with notification list
- Calendar app (manual events)
- Basic Chat with MCP tool calling
- All data scoped to org_id with RLS

### Core tasks for Phase 0
in-progress|F001|Full-stack plumbing: Vite→FastAPI→Supabase (RLS verified)
pending|F002|Calendar month view with event CRUD
pending|F003|Chat page with agent tool use (create/modify calendar events)
pending|F004|Dashboard notification feed (static/polling)
pending|F005|Deploy on Fly.io + Vercel

## Phase 1: Conflict Agent MVP (next)
- Project board app (tasks, due dates)
- Conflict detection agent (calendar + projects)
- Dashboard notification with action buttons
- Stripe billing
- External calendar sync (read-only)
- Intent Dispatcher v1

### Core tasks for Phase 1
pending|C001|Project board with tasks
pending|C002|Conflict rule engine (deterministic overlap check)
pending|C003|Agent orchestration: detect conflict → notify → execute action
pending|C004|Chat integration: ask agent to find/resolve conflicts
pending|C005|Stripe subscription and metering
pending|C006|Google Calendar / Outlook read-only integration

## Phase 2: Email + Proactive (future)
pending|E001|Nylas email integration
pending|E002|Auto-trigger conflict detection on incoming reschedule email
pending|E003|Configurable agent proactivity per plan

## Phase 3+: Full Suite Expansion (future)
// The original milestones (Workflows, Projects, Calendar, etc.) are preserved as future targets.

// Existing #LEX, #DICT, #C, #RULES, #VER, #ROUTE, #KV, #RUNBOOKS, #TEST, #BUDG sections remain unchanged.
```

---

## Updated 00-PLAN-3-PRD.md (Product Requirements)

Adjusted to reflect the end‑user productivity focus and the conflict‑detection flow as the key JTBD.

```markdown
---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-3-PRD.md
document_type: product_requirements
tier: strategic
status: stable
owner: Product / GTM
description: Product requirements — updated for integrated productivity AI platform
last_updated: 2026-04-25
version: 2.0
---

# PRD - Product Requirements (Revised)

## Product Vision
An AI‑integrated workspace where a conversational assistant works across your calendar, projects, and email to spot problems, suggest actions, and execute them on your behalf.

## Key Jobs to Be Done

### J001 (P0): Cross‑App Conflict Detection & Resolution
When my client emails to reschedule, I want my assistant to check my calendar and project deadlines, alert me to conflicts, and offer to fix them — all from one dashboard.

### J002 (P0): Unified Chat Assistant
When I ask a question or give a command in chat, I want the assistant to understand my context across apps and take appropriate actions using the available tools.

### J003 (P1): Proactive Notifications
I want the assistant to surface important cross‑app insights on the dashboard without me having to ask.

### J004 (P1): External Data Integration
I want to connect my existing calendars and email so the assistant immediately has a complete picture.

## Success Metrics
- Time from conflict detection to resolution action < 30 seconds.
- >60% of users who try the conflict flow become paid subscribers.
- Hallucination rate in structured tool calls < 1%.

## RICE & MoSCoW (adjusted)
// J001 and J002 are MUST now. All previous RICE items shifted to SHOULD/COULD but retained.

// The original full PRD content (personas, assumptions, constraints, etc.) remains valid and is appended unchanged.
```

---

## Updated 00-PLAN-C-AI.md (AI Architecture with Intent Dispatcher)

Added the Intent Dispatcher as a first‑class component.

```markdown
---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-C-AI.md
document_type: ai_architecture
tier: infrastructure
status: stable
owner: AI/ML Engineering
description: AI system architecture including Intent Dispatcher, memory, safety, cost tracking
last_updated: 2026-04-25
version: 2.0
---

# AI - Artificial Intelligence Architecture (Revised)

## Intent Dispatcher (New)

The **Intent Dispatcher** is a pure‑code middleware that sits between the AI orchestrator and the tool execution layer. Its job is to route every potential action to the **cheapest, fastest, most reliable executor** that can handle it.

- **Layer 1: Deterministic Code.** Database queries, rule engines, schema validators. Called directly by the orchestrator via a tool definition. No LLM involved in execution.
- **Layer 2: Lightweight Models (Haiku 4.5 or local).** Simple NLP tasks: extract structured data from an email, classify intent, summarize a short thread.
- **Layer 3: Powerful Models (Sonnet 4.6 / Opus 4.7).** Complex reasoning, multi‑step planning, open‑ended conversation.

The orchestrator (an LLM itself) selects tools. The dispatcher ensures each tool is executed optimally and that the orchestrator never wastes tokens on work that code can do.

### Example: Conflict Detection Flow
1. User says "Check for scheduling conflicts."
2. Orchestrator (Sonnet 4.6) decides to call the `detect_conflicts` tool.
3. Dispatcher sees `detect_conflicts` is a pure‑code function (overlap algorithm on DB records) → executes it directly, returns result.
4. Orchestrator formats a natural‑language response from the result.
**No Opus call. Only one Sonnet call for intent and formatting.** 

### Configuration
- Tool definitions include a `preferred_executor` field (code, haiku, sonnet, opus).
- Run‑time cost and latency budgets can force fallback (e.g., code if under budget, else haiku).

## Memory Architecture (unchanged)
 [ … ]
## Evaluation Pipeline (unchanged)
 [ … ]
## Context Window Management (unchanged)
 [ … ]
## Safety & Guardrails (unchanged, still 3‑layer)
 [ … ]
## Cost Attribution (unchanged)
 [ … ]
## Observability (unchanged)
 [ … ]
## Privacy (unchanged)
 [ … ]
```

---

## What's Not Changing

- All technical specifications (Tables, Endpoints, External Services, Architecture, Flows, Team, etc.) remain exactly as written; the six‑domain structure and rules are the long‑term target.
- The detailed component specs (Shell, Dashboard, Chat, etc.) still hold; they will be built incrementally as apps are added.
- The testing strategy and runbooks remain; we added a note that conflict rule engine tests must be prioritized in Phase 1.

---

## Next Step: Implementation Spec for Phase 0+1

With the strategic docs now reflecting the real product, we can drill into the concrete spec for the first two phases — exact tables, API endpoints, React components, and the conflict detection rule engine.

Would you like me to draft that implementation spec now, Trevor?