---
title: "AI SaaS Stack Blueprint"
owner: "Architecture"
status: "active"
updated: "2026-04-26"
canonical: ""
---

> **TL;DR**: Six-domain architecture (Platform, Data, AI, Frontend, Security, Business) with LLM-first orchestration, local-default AI, and clear inter-domain dependencies. Design axioms: LLM-first rule-optimized, local-default cloud-fallback. Product vision, jobs, metrics, monetization, and personas in [10-STRAT-PRD.md](10-STRAT-PRD.md).

## Design Axiom: LLM‑First, Rule‑Optimized

LLM orchestrator interprets intent and selects deterministic tools for execution.

- **Why**: Low costs, high reliability, clear audit trails; accommodates cheaper/local AI future.

### Design Axiom: Local‑Default, Cloud‑Fallback

Local/self-hosted models by default; cloud APIs only when authorized, capability-exceeded, or user-requested.

- **Why**: Inverts industry default → data sovereignty as feature; free tier via local models (near-zero cost).

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

## Six-Domain Framework

Original 18 pillars → six cohesive domains representing team boundaries. Organized infrastructure→product, security as cross-cutting wrapper. Self-contained domains minimize inter-dependencies, eliminate redundancy.

| Domain | Purpose | Lead | Key Services |
| --- | --- | --- | --- |
| A: Platform Foundation | Foundational tech stack, monorepo, CI/CD, infra deployment, observability | Platform Engineering | Ops, infra, mobile tooling |
| B: Data & Sync | Offline-first sync, real-time streaming, vector storage, knowledge graph | Data Platform | Semantic layer, knowledge graph components |
| C: AI Core & Agents | Multi-provider AI routing, agent protocols, orchestration, local model infra | AI/ML Engineering | Audio/vision AI, coordination, trust layer |
| D: Frontend & UX | Responsive interfaces, real-time collaboration, multimodal I/O, agent interaction | Product Engineering | Mobile, voice, UX components |
| E: Security & Compliance | Security controls, compliance frameworks, audit trails, AI ethics governance | Security/GRC | Cross-cutting across all domains |
| F: Business Strategy | Monetization, revenue optimization, product positioning, market models | Product/GTM | Workflow, competitive analysis |

**Implementation**: See [30-ARCH-OVERVIEW.md](30-ARCH-OVERVIEW.md) for each domain.
**CVEs**: [36-ARCH-TECH-VALIDATION.md](36-ARCH-TECH-VALIDATION.md) (Domain E).

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
