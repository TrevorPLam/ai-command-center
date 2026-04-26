# The AI-agentic SaaS stack blueprint (2026)

## Product identity

The product is an **AI‑integrated SaaS productivity platform**. It provides:

- A **dashboard** to monitor, interact with, and control AI agents.
- A **feature‑rich chat** page (like ChatGPT / Claude) where the user converses with agents.
- A **suite of productivity applications** (Calendar, Projects, Email, etc.) where both the user and AI agents can create, read, update, and delete data.

### Core innovation

**Cross‑application, context‑aware AI assistance.** An agent that notices conflicts across apps (e.g., an email rescheduling request conflicting with a project deadline) and proactively brings it to the user's attention with actionable options. This depth of integrated awareness does not exist at scale in current products.

### Design axiom: LLM‑first, rule‑optimized

The experience is **LLM‑driven** at the orchestration layer: an AI agent decides what to do and which tools to call.

However, the **tools themselves are largely deterministic code**.

- An LLM orchestrator interprets user intent and selects actions.

- Complex reasoning is routed to powerful models; simple, repetitive tasks are routed to lightweight models or pure code.

- The system minimizes actual LLM utilization by giving the AI highly efficient, pre‑built tools, rather than having the model generate logic.

This gives the user an intelligent, conversational assistant while keeping costs low, reliability high, and audit trails clear. It also naturally accommodates a future where AI models get cheaper or even run locally.

### Design axiom: local‑default, cloud‑fallback

All agentic intelligence runs on **local or self‑hosted models by default**. Cloud APIs (Claude, Gemini, etc.) are invoked only when:

- The user's subscription tier authorizes it,
- The task demonstrably exceeds local model capabilities (verified by a verifier cascade), or
- The user explicitly requests a cloud model.

This principle inverts the industry default, making data sovereignty a product feature. Free‑tier users experience the full AI assistant using only local models (near‑zero marginal cost). Paid tiers unlock cloud AI as a premium add‑on.

## Open questions

Questions to be resolved during the build process are tracked in **[04-OPEN-QUESTIONS.md](04-OPEN-QUESTIONS.md)**. Planning documents should reference these as configurable policies to be defined later.

## Phased delivery strategy

See the authoritative phased plan in **[01-PLAN-MILESTONES.md](01-PLAN-MILESTONES.md)** for the complete six‑phase rollout.

---

## Intent dispatcher (new architectural component)

A **pure‑code decision layer** in Domain C (AI Core) that routes every potential AI call:

1. **Deterministic tools** that can be called directly by the orchestrator without an LLM for that specific sub‑step (e.g., check a database for conflicts).

2. **Lightweight models** for simple NLP tasks (email parsing, keyword extraction).

3. **Powerful models** for complex reasoning, conversational chat, and multi‑step planning.

The orchestrator itself (an LLM) uses this dispatcher to execute tools efficiently.

---

## Research validation matrix

A comprehensive review of each major technology component confirms the blueprint rests on a solid, real-world foundation. For detailed validation evidence and security CVE references, see **[03-TECH-VALIDATION.md](03-TECH-VALIDATION.md)**.

---

## Critical analysis of original organization

The original 18-pillar linear structure (Pillars 0-17) suffered from structural weaknesses that led to the six-domain reorganization. For detailed analysis of the original structure and the rationale for reorganization, see **[docs/archive/ORGANIZATION-ANALYSIS.md](../archive/ORGANIZATION-ANALYSIS.md)**.

---

## Restructured blueprint: six-domain framework

The following organization groups the original 18 pillars into **six cohesive domains**, each representing a real-world team boundary. Domains are organized from infrastructure to product, with security as a cross-cutting wrapper. Each domain is self-contained, minimizing inter-domain dependencies and eliminating all redundancy.

### Domain A: platform foundation & developer experience

**Ownership**: platform engineering / developer infrastructure team
**Absorbs**: Original Pillars 0, 5, 7 (ops), 9 (infra), 6 (mobile tooling)

**Purpose**: Establish the foundational technology stack, monorepo structure, CI/CD pipelines, infrastructure deployment, and observability systems that all other domains depend upon.

→ Implementation: [02-ARCH-OVERVIEW.md § Domain A](02-ARCH-OVERVIEW.md)

### Domain B: data, sync & knowledge

**Ownership**: data platform / data engineering team
**Absorbs**: Original Pillar 2, semantic layer parts of 4/14, knowledge graph components

**Purpose**: Provide offline-first data synchronization, real-time data streaming, vector storage for semantic search, and knowledge graph infrastructure that enables AI agents to reason across application boundaries.

→ Implementation: [02-ARCH-OVERVIEW.md § Domain B](02-ARCH-OVERVIEW.md)

### Domain C: AI core & agent architecture

**Ownership**: AI platform / ML engineering team
**Absorbs**: Original Pillars 1, 4, 17 (full), 10 (audio/vision AI), 15 (coordination), semantic trust layer

**Purpose**: Provide multi-provider AI routing, agent protocols and identity verification, multi-agent orchestration, reliability engineering, and local model infrastructure that enables safe, cost-effective, and privacy-preserving AI assistance.

→ Implementation: [02-ARCH-OVERVIEW.md § Domain C](02-ARCH-OVERVIEW.md)

### Domain D: frontend, UX & multimodal interfaces

**Ownership**: product engineering / frontend team
**Absorbs**: Original Pillars 6, 10 (full UX-related), mobile, voice

**Purpose**: Build responsive, accessible web and mobile interfaces with real-time collaboration, multimodal input/output capabilities, and seamless agent interaction that provides a premium user experience.

→ Implementation: [02-ARCH-OVERVIEW.md § Domain D](02-ARCH-OVERVIEW.md)

### Domain E: security, compliance & governance

**Ownership**: security / GRC team
**NOTE**: This domain is CROSS-CUTTING, applicable to all other domains.
**Absorbs**: Original Pillars 3, 11, audit trail components of 17

**Purpose**: Establish security controls, compliance frameworks (EU AI Act, GDPR), audit trails, and AI ethics governance that protect the platform, users, and agents across all domains.

→ Implementation: [02-ARCH-OVERVIEW.md § Domain E](02-ARCH-OVERVIEW.md) · CVEs: [03-TECH-VALIDATION.md](03-TECH-VALIDATION.md)

### Domain F: business strategy & monetization

**Ownership**: product / GTM / executive team
**Absorbs**: Original Pillars 8, 12, 13, 14 (workflow/composable), 16 (competitive)

**Purpose**: Define monetization strategy, revenue optimization, product positioning, market models, and ecosystem integration that drives sustainable growth and customer value.

→ Implementation: [02-ARCH-OVERVIEW.md § Domain F](02-ARCH-OVERVIEW.md)

### Horizon scanning

Emerging technologies, standards, and market trends that may impact the platform are tracked in **[05-HORIZON-SCANNING.md](05-HORIZON-SCANNING.md)**. This includes Temporal API, WebGPU, quantum computing, internal R&D, patent strategy, and competitive monitoring.

---

## Inter-domain dependency map

```text
Domain A (Platform Foundation)
  ↓
Domain B (Data & Sync)
  ↓
Domain C (AI Core & Agents)
  ↓
Domain D (Frontend & UX)
  ↓
Domain F (Business Strategy & Monetization)

Domain E (Security & Compliance) ←→ ALL DOMAINS (cross-cutting)
```

**Key Integration Points**:

- **A→B**: Database infrastructure (TimescaleDB, PgBouncer, Neon) provisioned by Platform, consumed by Data.
- **B→C**: Vector store (pgvectorscale) and knowledge graph infrastructure consumed by AI Core for RAG, GraphRAG, and semantic layer.
- **C→D**: Agent outputs (structured JSON) streamed to frontend components via real-time rendering. Agent Studio UI built on Domain D.
- **C+D→F**: Token consumption, agent actions, and user interactions metered and fed into Stripe billing (F.1).
- **E→All**: APS/A2A identity verification, CSP headers, audit logging, EU AI Act documentation applied across all domains.

---

## Domain ownership & responsibility matrix

| Domain | Primary Owner | Key Stakeholders | SLA Focus |
|--------|--------------|------------------|-----------|
| A: Platform Foundation | Platform Engineering | All engineering teams | Build times, deploy frequency, infra uptime |
| B: Data & Sync | Data Platform | AI Platform, Frontend | Sync latency, query performance, data freshness |
| C: AI Core & Agents | AI/ML Engineering | Product, Security, Data | Model latency, hallucination rate, agent reliability |
| D: Frontend & UX | Product Engineering | Design, AI Platform | Core Web Vitals, accessibility scores |
| E: Security & Compliance | Security/GRC | All teams, Legal | Incident response time, audit readiness |
| F: Business Strategy | Product/GTM | Executive, Engineering | Revenue growth, customer acquisition cost |

---

## AI-assisted development guidelines

For effective AI-assisted development of this blueprint, including domain boundary enforcement, version pinning, dependency validation, security checks, and semantic versioning, see **[docs/development/AI-WORKFLOW.md](../development/AI-WORKFLOW.md)**.