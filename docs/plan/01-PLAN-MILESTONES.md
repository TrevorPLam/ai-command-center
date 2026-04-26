# Granular phased delivery plan: AI-integrated SaaS platform

**Refreshed: April 26, 2026**  
**Principle:** Nothing is removed from the blueprint. Everything is sequenced, deferred, or split.  
**Core Design Axioms:** LLM-First, Rule-Optimized · Local-Default, Cloud-Fallback

## Decision matrix: how features are sequenced

| Driver | Weight | Impact |
|---|---|---|
| User magic moment | Critical | Conflict-detection narrative powers every early phase |
| Revenue unlock | High | Stripe billing, external integrations |
| Cost sensitivity | High | Nylas ($500–$1,200+/mo) deferred; Google Calendar API (free) pulled forward; local models absorb free-tier load |
| Technical risk | High | LLM tool-calling reliability validated in Block 0B before any UI |
| Compliance deadline | Moderate | EU AI Act high-risk postponed to Dec 2027/Aug 2028; SOC2 not needed until enterprise sales |
| Solo feasibility | Governing | Any feature requiring >3 days review or >2 new tables splits across phases |

## Phase 0: foundation & core magic (solo → first demo)

**Duration target:** 12–16 weeks  
**Monthly infra cost:** ~$30–50 (Supabase Free/Pro $25 + Fly.io Hobby $5 + Resend Free)  
**Local model cost:** ~$0 (electricity only, local inference)

### Block 0A: Platform Skeleton (Weeks 1–3)

| ID | Feature | Notes |
|---|---|---|
| F001 | Vite SPA + FastAPI + Supabase plumbing, RLS verified with pgTAP | Full stack end-to-end |
| F002 | Auth: email/pw, org creation, JWT with org_id claim, custom access token hook | No passkeys yet |
| F003 | Org switching: refreshSession + queryClient.clear + RT reconnect | Critical for multi-tenant |
| F004 | Basic CI: typecheck (tsc + tsgo), lint, RLS tests | GitHub Actions. No Schemathesis yet |
| F005 | Deploy: Fly.io (FastAPI) + Vercel (Vite SPA) | Single shared-cpu-1x VM, auto-stop |

### Block 0B: Local AI Infrastructure ⚠️ HIGHEST TECHNICAL RISK (Weeks 3–5)

| ID | Feature | Notes |
|---|---|---|
| F006 | Ollama ≥0.21.1 integration: Docker Compose, OpenAI-compatible API, native tool calling | 165K+ GitHub stars. Supports Gemma 4, Qwen3.5, Phi‑4‑mini, Llama 4 |
| F007 | llama.cpp backend with ik_llama.cpp fork: BitNet support, fused MoE, hybrid GPU/CPU ops | Better CPU & hybrid performance than upstream |
| F008 | Model registry initial population: pull, verify checksum (SHA‑256), register, serve | Gemma 4 E2B (2B active, native tool calling, multimodal) as default orchestrator; Qwen3.5 4B as tool executor |
| F009 | GGUF Q4_K_M quantization policy: all local models quantized to ≤4.5 GB RAM footprint | Human reading speed (~6 TPS) on consumer CPU |
| F010 | LiteLLM proxy integration (≥1.83.7, cosign verified) | Claude Sonnet 4.6 ($3/$15 per 1M tok), Opus 4.7 as premium cloud fallback |
| F011 | Intent Dispatcher v1: routes tool calls via `preferred_executor` field | code → Haiku 4.5 → Sonnet 4.6 → Opus 4.7 cascade |
| F012 | Local‑first routing policy: free‑tier all local; cloud API gated behind paid subscription | Near‑zero marginal cost for free users |

**Decision point @ Week 5:** If local tool‑calling reliability <90% on Gemma 4 E2B, evaluate Qwen3.5 4B or Llama4‑7B as fallback orchestrator before proceeding.

### Block 0C: Chat + Agent Tool Calling (Weeks 5–8)

| ID | Feature | Notes |
|---|---|---|
| F013 | Chat page shell: ThreadList, MessageList, ChatInput, MessageBubble | StaleTime:Infinity for AI messages; @V virtualization |
| F014 | Vercel AI SDK v6 streaming + tool calling | Production-ready. Tool approval gates, multi‑step reasoning |
| F015 | LangGraph Supervisor pattern mapping to FLOWC01 state machine | Centralized supervisor routes to specialized worker agents; LangMem for cross‑session summaries |
| F016 | Tool: `create_calendar_event`, `update_calendar_event`, `delete_calendar_event` | Backed by events table; deterministic execution via Intent Dispatcher |
| F017 | Tool: `list_tasks`, `create_task`, `update_task`, `delete_task` | Backed by tasks table |
| F018 | Guardrails input layer: PII detection, jailbreak detection, toxicity screening | Activated for all AI calls. Logged to audit_logs |
| F019 | Guardrails output layer: hallucination detection (LLM‑as‑judge via DeepEval) | Routed through LiteLLM proxy. Warning threshold, not blocking in Phase 0 |

### Block 0D: Data Apps — Calendar & Tasks (Weeks 8–12)

| ID | Feature | Notes |
|---|---|---|
| F020 | Events table + FastAPI CRUD endpoints | events(id, org_id, title, start, end, tz, allDay, recurrence_id, cat, uat) |
| F021 | Calendar MonthView, WeekDayView, AgendaView | @M MotionGuard, @Z TimezoneAware, ARIA grid navigation, keyboard shortcuts |
| F022 | EventComposer: optimistic create/edit/delete with 5s undo | @O optimistic mutation, @R recurring support |
| F023 | EventDetailDrawer: inline edit, delete, agent log | Tabs: details, agent history, related tasks |
| F024 | Drag‑and‑drop reschedule: dnd‑kit centralized façade | @O optimistic; DragOverlay only; keyboard alt (WCAG 2.5.7) |
| F025 | Recurrence: rschedule + @rschedule/temporal‑date‑adapter | ZonedDateTime mandatory; DST matrix tests |
| F026 | Tasks table + FastAPI CRUD | tasks(id, org_id, project_id, title, status, assignee, due, priority, order) |
| F027 | Task list view: status toggles, due dates, inline editing, optimistic mutations | @V virtualization, @E InlineEdit |
| F028 | Kanban board: drag‑and‑drop columns, task cards | pointerWithin detection; @O optimistic on column change |
| F029 | Task comments: internal/external, DOMPurify RICH profile | @O optimistic; agent‑generated notes |
| F030 | Calendar‑Project linking: tasks with due dates → calendar overlay | Tasks appear as optional overlay on calendar views |
| F031 | Google Calendar read‑only integration: OAuth 2.0, sync engine | Free API (1M req/day). Periodic fetch, not real‑time |

**Decision point @ Week 12:** If Google Calendar sync is stable, optionally add Outlook read‑only (Microsoft Graph API). If not, defer to Phase 1.

### Block 0E: Dashboard & Conflict Agent (Weeks 12–15)

| ID | Feature | Notes |
|---|---|---|
| F032 | Dashboard shell: AmbientStatusBanner, ActivityFeed, AttentionQueue | @M MotionGuard, @AP AnimatePresence, role=log aria‑live |
| F033 | Notification table + real‑time subscription | notifications(id, org_id, user_id, template, deeplink, read, cat) |
| F034 | Notification feed with action buttons: "Reschedule", "Move task", "Ignore" | InAppNotifications template+deeplink rule |
| F035 | Conflict detection engine: deterministic overlap algorithm, multi‑timezone | Pure code—no LLM involved. Called by agent as a tool |
| F036 | Agent orchestration: Chat → `detect_conflicts` tool → Dashboard notification | Orchestrator (Gemma 4 E2B local) calls tool; Dispatcher routes to code |
| F037 | Agent action execution: Dashboard action → orchestrator → tool call → confirmation | `resolve_conflict` tool updates event or task; confirmation logged |
| F038 | Cost tracking: ai_cost_log TimescaleDB hypertable, per‑org/per‑model | x‑litellm‑tags: org_id, user_id, feature |

### Block 0F: Monetization & Polish (Weeks 15–16)

| ID | Feature | Notes |
|---|---|---|
| F039 | Stripe metered billing: @stripe/ai‑sdk v0.1.2, token tracking, 30% markup | Four‑layer cost governance: synchronous pre‑call budget check |
| F040 | Subscription tiers: Free (local models only, limited AI calls), Pro ($20–30/mo, Sonnet 4.6 cloud access), Team (Opus 4.7, fine‑tuning) | Stripe customer portal for self‑service |
| F041 | CSP policy: nonce strategy, strict‑dynamic, Report‑Only pre‑prod | DOMPurify ≥3.4.0; SanitizedHTML component |
| F042 | Rate limiting: FastAPI‑Limiter + Upstash Redis, per‑user/org | Token bucket; 429 with Retry‑After |
| F043 | WORM audit logging: all agent decisions immutable | audit_logs table; hash chaining |
| F044 | Pre‑launch security audit: CSP, RLS, rate limiting, MCP tool auth validation | Red teaming for prompt injections and jailbreaks |

**Phase 0 Exit Gate:** One external user signs up, connects Google Calendar, creates tasks, and sees the agent detect a scheduling conflict — all without direct intervention.

## Phase 1: Public Launch & Proactive Intelligence (Solo → First Paying Customers)

**Trigger:** Phase 0 demo succeeds with ≥3 external testers  
**Monthly infra cost:** ~$200–500 (Supabase Pro $25 + Fly.io Scale $29–$59 + Nylas evaluation + Sentry Team $26 + PostHog Free + Ollama local)

### Block 1A: Observability

| ID | Feature | Notes |
|---|---|---|
| P101 | Sentry error tracking: 4 projects, PII strip beforeSend, maskAllText:true on Session Replay | Team plan $26/mo |
| P102 | PostHog analytics: event taxonomy, Group Analytics, allow_training flag | Free 1M events/month initially. Mandatory from day one |
| P103 | OTel GenAI traces: gen_ai.* attributes, DataPrepper root span, PII redaction | OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai |

### Block 1B: Email Integration

| ID | Feature | Notes |
|---|---|---|
| P104 | Nylas Email API: read, send, webhooks | Upsert‑first, 10s timeout, async queue. **Cost gate:** evaluate at 50 connected accounts ($165/mo at approx. $3.30/account); if >$200/mo, defer further expansion |
| P105 | Email‑triggered conflict detection: incoming reschedule email → agent parses → checks conflicts | Local model (Haiku 4.5 or Gemma 4 E2B) for parsing ($1/$5 per 1M tok cloud if needed). Intent Dispatcher routes to lightweight model |
| P106 | grant.expired webhook handling: re‑auth <72h, proactive renewal | Daily cron for expiring grants. P1 incident if missed |
| P107 | Resend transactional email: email.complained→unsubscribed:true | Free tier (3K/mo) for transactional; Pro ($20/mo) at scale |

### Block 1C: Proactive Intelligence

| ID | Feature | Notes |
|---|---|---|
| P108 | Agent proactivity configuration per plan: schedule (daily AM), event‑driven (on new email), manual only | Free: manual only. Pro: scheduled. Team: event‑driven |
| P109 | Proactive notification engine: agent surfaces insights without user prompt | Configurable per feature |

### Block 1D: Verifier & Local AI Enhancements

| ID | Feature | Notes |
|---|---|---|
| P110 | Verifier cascade: Phi‑4‑mini‑reasoning (3.8B) as local verifier | Checks: reasoning soundness, schema validity, permission/cost budget. Function calling now supported on Phi‑4‑mini |
| P111 | Model capability registry: automated benchmarking of all registered models | Tool‑calling scores, latency profiles, hallucination rates |
| P112 | Loop controller (SLM‑6 pattern): circuit breaker on orchestrator loops | Configurable max iterations; temperature=0 for control layer |
| P113 | Model update and deprecation policy: version freeze, smooth migration | 30‑day notice before model sunset; auto‑migrate to successor |
| P114 | Second local model added: Llama4‑7B or Qwen3.5‑4B as high‑throughput alternative | Model selection based on task type; registry tracks per‑model tool‑calling pass rates |

### Block 1E: External & Feature Expansion

| ID | Feature | Notes |
|---|---|---|
| P115 | Google Calendar write support: create/update/delete via OAuth | Free API. Calendars.ReadWrite scope |
| P116 | Outlook Calendar read‑only: Microsoft Graph API | **Blocker:** EWS blocks non‑Microsoft apps from Oct 2026; use Graph API exclusively |
| P117 | Project Timeline view, Workload view | Deferred from Phase 0 full module spec |
| P118 | Project templates & automation rules | Save‑as‑template; triggered=strikethrough |
| P119 | User onboarding: guided setup, connect calendar, create first task | EmptyState pattern |
| P120 | AI cost monitoring dashboard (admin only) | Per‑org/team/user/model. Forecast ±10% |
| P121 | Feature flags: OpenFeature + Vercel Flags SDK | Flag: off→internal(2d)→beta(3d)→5/20/50%(2d)→100%; kill<5min |

**Phase 1 Exit Gate:** ≥20 paying customers, <5% monthly churn, AI cost per free‑tier user under $0.05/month (local models, nearly zero), cloud cost per Pro user under $3/month, NPS >40.

### Nylas Cost Gate Decision Matrix

| Connected Accounts | Monthly Nylas Cost | Action |
|---|---|---|
| ≤50 (Free tier) | ≤$165/mo | Absorb as CAC; keep Nylas |
| 50–200 | $165–$660/mo | Require Pro plan ($20/mo) to cover costs |
| >200 | >$660/mo | Add Nylas fee passthrough or explore direct API integration |

## Phase 2: Suite Expansion & First Hire (Solo → Team)

**Trigger:** ≥20 paying customers, or can no longer review all AI PRs within 2 business days  
**Monthly infra cost:** ~$500–1,500

### Block 2A: Team

| ID | Feature | Notes |
|---|---|---|
| P201 | Hire first engineer (contract or full‑time) | Platform or Frontend depending on bottleneck |

### Block 2B: App Suite

| ID | Feature | Notes |
|---|---|---|
| P202 | Contacts app: ContactDetail, QuickAdd, EnrichmentPanel, TagManager | @E InlineEdit, privacy field‑level controls |
| P203 | Documents app: DocumentGrid, UploadManager, VersionHistory | ClamAV v1.4.x sidecar, freshclam hourly |
| P204 | Notes/Research app: MindMapEditor (markmap + Yjs), FlashcardDeck (FSRS) | @M MotionGuard, @AS Spring, collab opt‑in |
| P205 | Agent tools for each new app: consistent MCP tool definitions | All logged, all guarded |

### Block 2C: AI Depth

| ID | Feature | Notes |
|---|---|---|
| P206 | GraphRAG: FastGraphRAG (NLP entity extraction, ~10% cost) | Start with FastGraphRAG. LLM‑based GraphRAG gated at 500K chunks |
| P207 | Contextual Retrieval: activate at >50K chunks, precision >15%, cache hit >60% | Tracked via ragindexstats |
| P208 | Agent Studio: definition versioning, trust catalog, playground, eval gates | Semantic versioning for prompts |

### Block 2D: Local AI Maturation

| ID | Feature | Notes |
|---|---|---|
| P209 | Fine‑tuning pipeline: Unsloth (GPU, 2× faster, 70% less VRAM) for QLoRA adapters; LoFT CLI for CPU‑only 1–3B models; MLX‑LM for Apple Silicon | Domain‑specific task models, per‑org style adaptation |
| P210 | Multi‑model concurrent serving: Gemma 4 + Qwen3.5 + Phi‑4‑mini simultaneously | CPU affinity: orchestrator on one core cluster, inference on another |
| P211 | Model evaluation harness: automated tool‑calling pass rate benchmarking, weekly re‑evaluation | lm‑evaluation‑harness or custom; results stored in model registry |
| P212 | NUMA‑aware deployment: ArcLight architecture evaluated for multi‑socket servers | 46% higher throughput than mainstream frameworks on many‑core CPUs |

### Block 2E: Platform Maturation

| ID | Feature | Notes |
|---|---|---|
| P213 | Monorepo: Turborepo 2.x tasks‑based pipelines, pnpm catalogs | Strict separation: packages/ui no import from features |
| P214 | Full CI matrix: typecheck(tsc+tsgo), lint, test:unit, test:component, test:rls, test:e2e, prisma:drift, orval:codegen, docker:build, schemathesis | AI eval no cache; base=main |
| P215 | Offline foundation: tombstone sync (deleted_at, ULID, IC), outbox pattern | MVP outbox. PowerSync eval continues |
| P216 | Schemathesis contract testing CI gate | Main + PR jobs. Ignore file for SSE/WS endpoints |
| P217 | DeepEval + RAGAS AI eval CI gates | LLM‑as‑judge through LiteLLM proxy |

**Phase 2 Exit Gate:** ≥200 paying customers, NRR >90%, one new app per quarter, second cross‑app scenario demonstrated (e.g., "attach this document to the client contact").

## Phase 3: Monetization Maturity & Compliance Readiness

**Trigger:** ≥200 paying customers or first enterprise inquiry about SOC2  
**Monthly infra cost:** ~$2,000–5,000

### Block 3A: Billing & Revenue

| ID | Feature | Notes |
|---|---|---|
| P301 | Tiered model access: license gates, feature flags per plan | Modules locked by subscription. AI call limits graduated |
| P302 | Revenue optimization: unit economics dashboard, churn prediction, expansion revenue | PostHog analytics, Stripe data |
| P303 | Data‑as‑a‑Service foundation: anonymized, structured data exports | Separate consent flow. allow_training flag respected |

### Block 3B: Compliance

| ID | Feature | Notes |
|---|---|---|
| P304 | EU AI Act technical documentation: automated generation, risk management logs | Deadline: Dec 2027 stand‑alone, Aug 2028 embedded. Ample runway |
| P305 | AIBOM (CycloneDX) per model in CI: training data provenance, safety evaluations | Mandatory for high‑risk classification |
| P306 | SOC2 Type I preparation: Vanta/Oneleet integration, evidence pipeline | ~$10K/yr Vanta. Target: 3‑month preparation + audit ($25–50K one‑time) |
| P307 | Privacy: GDPR opt‑out, data segregation, annual PIA, diff privacy aggregates | TEE for sensitive analytics |
| P308 | Passkeys: SimpleWebAuthn + webauthn_challenges table | SB Auth MFA. Cross‑device QR. Recovery codes |

### Block 3C: Mobile

| ID | Feature | Notes |
|---|---|---|
| P309 | Expo mobile app (read‑only v1): calendar, tasks, notifications | SDK 55 or 56. Decision: use SDK 56 if stable by build start; else SDK 55 |
| P310 | expo‑notifications: push for conflict alerts, deep link matrix | Dev build required for Android |

### Block 3D: Local AI at Scale

| ID | Feature | Notes |
|---|---|---|
| P311 | Distributed inference research: Prima.cpp (ICLR 2026) for 30–70B models on home clusters with mixed CPUs/GPUs | 26 TPS on 32B model with speculative decoding |
| P312 | Ternary model migration path: FairyFuse (32.4 tok/s on single Xeon, 1.24× llama.cpp) | When llama.cpp integrates ternary support; model registry tracks quantization format per version |
| P313 | Intel OpenVINO 2026.1 backend for llama.cpp: optimized inference across Intel CPUs, GPUs, NPUs | Enables Core Ultra NPU usage for local inference |

**Phase 3 Exit Gate:** SOC2 Type I obtained. First 10 enterprise accounts (≥50 seats each).

## Phase 4: Enterprise Scale & Real‑Time (Team: 3–5)

**Trigger:** SOC2 Type I complete + first enterprise contract signed  
**Monthly infra cost:** ~$5,000–12,000

### Block 4A: Enterprise

| ID | Feature | Notes |
|---|---|---|
| P401 | SSO (SAML/OIDC), SCIM provisioning, advanced RBAC | Enterprise plan feature gate |
| P402 | SOC2 Type II observation period: 6–12 months continuous monitoring | Annual audit cycle. Vanta continuous evidence |
| P403 | Custom data retention policies, audit report exports | Per‑org configuration |

### Block 4B: Real‑Time & Collaboration

| ID | Feature | Notes |
|---|---|---|
| P404 | Yjs real‑time collaboration: CollabCanvas, RealTimeCoEdit | Y‑Sweet self‑host (Jamsocket shutdown March 2026). GC enabled, undo trunc last5, 50MB limit |
| P405 | LiveKit Agents v2.0: VoiceShell, conference agent, semantic turn detection | STT→LLM→TTS pipeline. WebRTC |

### Block 4C: Offline & Mobile Maturation

| ID | Feature | Notes |
|---|---|---|
| P406 | PowerSync bidirectional sync: SQLite↔Postgres | YAML sync rules per orgId. 3‑user free tier. SOC2/HIPAA |
| P407 | Offline mobile apps: full CRUD, conflict resolution, queue replay | TanStack DB 0.6 persistence. Hierarchical data projection |

**Phase 4 Exit Gate:** 500+ paying organizations, 10 with >50 seats. First seven‑figure ARR year.

## Phase 5: Advanced AI & Ecosystem (Team: 5–10)

**Trigger:** 500+ orgs, stable revenue, dedicated AI team

| ID | Feature | Notes |
|---|---|---|
| P501 | A2A Protocol v1.0: Agent Cards, cryptographic identity, decentralized discovery | Linux Foundation. Multi‑tenant endpoints |
| P502 | Semantic Layer: MATRIX ontology, knowledge graph, cross‑agent shared vocabulary | Extends A2A Agent Cards with Merkle‑based lineage |
| P503 | Edge AI: Transformers.js + Wasm (Phi‑4, Gemma‑2B) for privacy‑sensitive tasks | Prefix caching for 80% TTFT reduction |
| P504 | MCP marketplace: third‑party agent/tool publishing, discovery, trust catalog | MCPSec L2 mandatory for all published tools |
| P505 | MACH composable architecture: API‑first all apps, third‑party integrations | MACH Alliance principles |
| P506 | Desktop app: Tauri v2, Capabilities per window, auto‑update | CI capability audit |
| P507 | Internationalization: multi‑language UI | East Asia market readiness |

**Phase 5 Exit Gate:** Platform becomes ecosystem. Third‑party developer community active. Annual ARR in tens of millions.

## Phase 6: Maturity & Moonshots (Team: 15–30)

**Trigger:** Strong market position, R&D budget available

| ID | Feature | Notes |
|---|---|---|
| P601 | Temporal API native (ES2027+). Remove polyfill | Safari gap closed |
| P602 | Quantum‑resistant crypto: hybrid classical+ML‑KEM for long‑lived keys | Inventory long‑lived data by 2027 |
| P603 | Full multimodal agents: voice, video, vision‑native workflows | LiveKit Agents mature feature set |
| P604 | Horizontal expansion: lightweight ERP, CRM, HR modules | AI cross‑app awareness as moat |
| P605 | API marketplace: developer community, revenue share, certification | Data‑as‑a‑Service monetization |
| P606 | Custom model training: proprietary models from open‑source bases; full from‑scratch training when resources permit | Mistral Forge or equivalent enterprise platform |

## Cost Projection Summary

| Phase | Monthly Infra (target) | Key Cost Drivers |
|---|---|---|
| 0 | $30–50 | Supabase Pro $25, Fly.io Hobby $5, Resend Free, Google Calendar Free, **local models: $0** |
| 1 | $200–500 | Nylas ($165+), Sentry Team $26, Fly.io Scale $29–59, Claude API for Pro users |
| 2 | $500–1,500 | Nylas scale, Supabase scale, first hire, Claude API growth |
| 3 | $2,000–5,000 | Vanta ($10K/yr), SOC2 audit ($25–50K one‑time), mobile infra, local model server upgrades |
| 4 | $5,000–12,000 | PowerSync ($51+/mo), LiveKit, SOC2 Type II annual, team salaries |
| 5 | $5,000–20,000 | Multi‑region, marketplace infra, Tauri signing |
| 6 | $10,000–50,000+ | Full enterprise suite, dedicated AI compute, custom model training |

## Key Blockers & Risk Registry

| Blocker | Impact | Mitigation | Phase |
|---|---|---|---|
| LLM tool‑calling reliability <90% | Blocks product magic | Test local models in Block 0B; fallback: Qwen3.5 4B (97.5% tool‑calling reported), stricter prompt engineering, LangGraph checkpointing | Phase 0 |
| Nylas pricing at scale (~$3.30/account) | Cost explosion | Gate at 50 accounts. Evaluate direct Google/Microsoft API | Phase 1–2 |
| EWS deprecation (Oct 2026) | Blocks Outlook integration | Use Microsoft Graph API exclusively | Phase 1 |
| SOC2 Type II observation (6–12 months) | Delays enterprise sales | Type I in Phase 3 for immediate credibility; Type II during Phase 4 | Phase 3–4 |
| OpenAI Assistants API shutdown (Aug 2026) | Blocks deprecated APIs | Use Responses API + Vercel AI SDK v6 from Phase 0 | Phase 0 |
| Y‑Sweet/Jamsocket shutdown (March 2026) | No hosted Yjs option | Self‑host on Fly.io private network; activate when real‑time needed (Phase 4) | Phase 4 |
| EU AI Act high‑risk obligations | Compliance cost | Stand‑alone: Dec 2027; embedded: Aug 2028. Documentation begins Phase 3 | Phase 3–4 |
| Google Gemini free tier restrictions (March 2026) | Pro models limited to paid tiers | Free tier uses Flash models only. Local models absorb free‑tier load; Gemini Flash as fallback | Phase 0 |
| Local model staleness | Tool‑calling accuracy drift | Weekly automated re‑benchmarking; verifier monitors orchestrator quality; registry tracks last‑verified dates | Phase 2+ |

## Local Model Fleet: Phase‑by‑Phase Deployment

| Phase | Models Active | Roles | Hardware |
|---|---|---|---|
| 0 | Gemma 4 E2B (2B active), Qwen3.5 4B | E2B: orchestrator, chat. Qwen3.5: tool executor | CPU‑only, 16GB RAM, single NUMA node |
| 1 | + Phi‑4‑mini‑reasoning (3.8B) | Verifier: pre‑action validation, reasoning checks | Same CPU. Concurrent serving |
| 2 | + Llama4‑7B or Gemma 4 E4B (4.5B) | High‑throughput chat, complex reasoning | GPU‑accelerated tier optional. Multi‑model concurrent |
| 3 | + Fine‑tuned domain LoRA adapters | Per‑org personalized agent behavior | Dedicated server or GPU workstation |
| 4–5 | + Distributed 30–70B via Prima.cpp | Complex multi‑step enterprise workflows | Home cluster or multi‑GPU pool |
| 6 | + Custom proprietary models from scratch | Full vertical integration | Dedicated AI compute infrastructure |

## Monetization: Local‑Default, Cloud‑Premium

| Tier | AI Capability | Marginal AI Cost/User/Month | Pricing |
|---|---|---|---|
| **Free** | Local models only: Gemma 4 E2B, Qwen3.5 4B. Full assistant. No cloud. | ~$0.0001 (electricity) | Free forever |
| **Pro** | Local default + Sonnet 4.6 cloud ($3/$15 per 1M tok) for complex tasks | $0.10–$0.50 | $20–30/mo |
| **Team** | Local default + Opus 4.7 cloud ($5/$25 per 1M tok) + fine‑tuning | $1–5 | $50–100/user/mo |
| **Enterprise** | Dedicated models, private hosting, SSO, compliance | Custom | Custom |

**The structural advantage:** At 10,000 free users, a cloud‑dependent competitor burns $50K–$150K/month in AI inference. Your cost: ~$10/month in electricity. Free‑tier economics are defensible against any all‑cloud competitor.

*This plan preserves every component from the six‑domain blueprint. Nothing is removed—only sequenced, split, or deferred across phases. Each phase gate is governed by customer or revenue triggers, not calendar dates.*