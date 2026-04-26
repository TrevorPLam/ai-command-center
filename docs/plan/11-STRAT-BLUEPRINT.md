# AI SaaS Stack Blueprint (2026)

> **TL;DR**: Six-domain architecture (Platform, Data, AI, Frontend, Security, Business) with LLM-first orchestration, local-default AI, and clear inter-domain dependencies. Design axioms: LLM-first rule-optimized, local-default cloud-fallback. Product vision, jobs, metrics, monetization, and personas in [10-STRAT-PRD.md](10-STRAT-PRD.md).

## Design Axiom: LLM‑First, Rule‑Optimized

LLM-driven orchestration layer: AI agent decides actions/tools.

Tools are deterministic code:

- LLM orchestrator interprets intent, selects actions

Result: intelligent assistant with low costs, high reliability, clear audit trails. Accommodates cheaper/local AI future.

### Design Axiom: Local‑Default, Cloud‑Fallback

Local/self-hosted models by default. Cloud APIs only when:

- Subscription tier authorizes
- Task exceeds local capabilities (verified by cascade)
- User explicitly requests cloud model

Inverts industry default → data sovereignty as feature. Free tier: full AI via local models (near-zero cost). Paid tiers: cloud AI as premium.

## Open Questions

Build process questions tracked in **[04-OPEN-QUESTIONS.md](04-OPEN-QUESTIONS.md)**. Reference as configurable policies to be defined later.

## Phased Delivery

See **[01-PLAN-MILESTONES.md](01-PLAN-MILESTONES.md)** for six-phase rollout.

---

## Intent Dispatcher

Pure-code decision layer in Domain C (AI Core) routes AI calls:

1. Deterministic tools: direct orchestrator calls without LLM (e.g., database conflict check)
2. Lightweight models: simple NLP (email parsing, keyword extraction)
3. Powerful models: complex reasoning, chat, multi-step planning

Orchestrator (LLM) uses dispatcher for efficient tool execution.

---

## Research Validation

Comprehensive tech component review confirms solid foundation. See **[36-ARCH-TECH-VALIDATION.md](36-ARCH-TECH-VALIDATION.md)** for validation evidence and CVE references.

---

## Organization Analysis

Original 18-pillar structure had weaknesses → six-domain reorganization. See **[docs/archive/ORGANIZATION-ANALYSIS.md](../archive/ORGANIZATION-ANALYSIS.md)** for detailed analysis and rationale.

---

## Six-Domain Framework

Original 18 pillars → six cohesive domains representing team boundaries. Organized infrastructure→product, security as cross-cutting wrapper. Self-contained domains minimize inter-dependencies, eliminate redundancy.

### Domain A: Platform Foundation & Dev Experience

**Ownership**: Platform Engineering / Dev Infrastructure
**Absorbs**: Pillars 0, 5, 7 (ops), 9 (infra), 6 (mobile tooling)

**Purpose**: Foundational tech stack, monorepo, CI/CD, infra deployment, observability for all domains.

→ Implementation: [30-ARCH-OVERVIEW.md § Domain A](30-ARCH-OVERVIEW.md)

### Domain B: Data, Sync & Knowledge

**Ownership**: Data Platform / Data Engineering
**Absorbs**: Pillar 2, semantic layer parts of 4/14, knowledge graph components

**Purpose**: Offline-first sync, real-time streaming, vector storage for semantic search, knowledge graph infrastructure for cross-app AI reasoning.

→ Implementation: [30-ARCH-OVERVIEW.md § Domain B](30-ARCH-OVERVIEW.md)

### Domain C: AI Core & Agent Architecture

**Ownership**: AI Platform / ML Engineering
**Absorbs**: Pillars 1, 4, 17 (full), 10 (audio/vision AI), 15 (coordination), semantic trust layer

**Purpose**: Multi-provider AI routing, agent protocols/identity verification, multi-agent orchestration, reliability engineering, local model infrastructure for safe, cost-effective, privacy-preserving AI.

→ Implementation: [30-ARCH-OVERVIEW.md § Domain C](30-ARCH-OVERVIEW.md)

### Domain D: Frontend, UX & Multimodal Interfaces

**Ownership**: Product Engineering / Frontend
**Absorbs**: Pillars 6, 10 (UX-related), mobile, voice

**Purpose**: Responsive, accessible web/mobile interfaces with real-time collaboration, multimodal I/O, seamless agent interaction for premium UX.

→ Implementation: [30-ARCH-OVERVIEW.md § Domain D](30-ARCH-OVERVIEW.md)

### Domain E: Security, Compliance & Governance

**Ownership**: Security / GRC
**NOTE**: CROSS-CUTTING across all domains
**Absorbs**: Pillars 3, 11, audit trail components of 17

**Purpose**: Security controls, compliance frameworks (EU AI Act, GDPR), audit trails, AI ethics governance protecting platform, users, agents across all domains.

→ Implementation: [30-ARCH-OVERVIEW.md § Domain E](30-ARCH-OVERVIEW.md) · CVEs: [36-ARCH-TECH-VALIDATION.md](36-ARCH-TECH-VALIDATION.md)

### Domain F: Business Strategy & Monetization

**Ownership**: Product / GTM / Executive
**Absorbs**: Pillars 8, 12, 13, 14 (workflow/composable), 16 (competitive)

**Purpose**: Monetization strategy, revenue optimization, product positioning, market models, ecosystem integration for sustainable growth and customer value.

→ Implementation: [30-ARCH-OVERVIEW.md § Domain F](30-ARCH-OVERVIEW.md)

### Horizon Scanning

Emerging tech/standards/market trends tracked in **[12-STRAT-HORIZON.md](12-STRAT-HORIZON.md)**: Temporal API, WebGPU, quantum computing, R&D, patent strategy, competitive monitoring.

---

## Inter-Domain Dependencies

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

**Key Integration Points**:

- **A→B**: Database infra (TimescaleDB, PgBouncer, Neon) provisioned by Platform → consumed by Data
- **B→C**: Vector store (pgvectorscale) + knowledge graph → AI Core for RAG/GraphRAG/semantic layer
- **C→D**: Agent outputs (JSON) streamed to frontend via real-time rendering. Agent Studio UI on Domain D
- **C+D→F**: Token consumption, agent actions, user interactions metered → Stripe billing (F.1)
- **E→All**: APS/A2A identity verification, CSP headers, audit logging, EU AI Act documentation across all domains

---

## Domain Ownership Matrix

| Domain | Primary Owner | Key Stakeholders | SLA Focus |
| --- | --- | --- | --- |
| A: Platform Foundation | Platform Engineering | All Engineering | Build times, deploy frequency, infra uptime |
| B: Data & Sync | Data Platform | AI Platform, Frontend | Sync latency, query performance, data freshness |
| C: AI Core & Agents | AI/ML Engineering | Product, Security, Data | Model latency, hallucination rate, agent reliability |
| D: Frontend & UX | Product Engineering | Design, AI Platform | Core Web Vitals, accessibility scores |
| E: Security & Compliance | Security/GRC | All teams, Legal | Incident response time, audit readiness |
| F: Business Strategy | Product/GTM | Executive, Engineering | Revenue growth, customer acquisition cost |

---

## AI-Assisted Development

For AI-assisted development: domain boundary enforcement, version pinning, dependency validation, security checks, semantic versioning → see **[docs/development/AI-WORKFLOW.md](../development/AI-WORKFLOW.md)**.