---
title: "AI-Integrated SaaS Platform: Phased Delivery"
owner: "Product"
status: "active"
updated: "2026-04-26"
canonical: ""
---

**Refreshed:** 2026-04-26
**Principle:** Nothing removed. Everything sequenced, deferred, or split.
**Core:** LLM-First, Rule-Optimized · Local-Default, Cloud-Fallback  

## Sequencing Matrix
| Driver | Weight | Impact |
|---|---|---|
| User magic moment | Critical | Conflict-detection narrative powers early phases |
| Revenue unlock | High | Stripe billing, external integrations |
| Cost sensitivity | High | Nylas deferred; Google Calendar pulled forward; local models absorb free tier |
| Technical risk | High | LLM tool-calling validated in Block 0B before UI |
| Compliance deadline | Moderate | EU AI Act postponed to 2027/2028; SOC2 not needed until enterprise |
| Solo feasibility | Governing | Any feature >3d review or >2 new tables splits across phases |

## Phase 0: Foundation & Core Magic (Solo → First Demo)
**Duration:** 12–16w · **Cost:** ~$30–50/mo (Supabase Pro $25 + Fly.io Hobby $5 + Resend Free) · **Local model:** $0 (electricity only)

### Block 0A: Platform Skeleton (Wk 1–3)
| ID | Feature | Notes |
|---|---|---|
| F001 | Vite SPA + FastAPI + Supabase, RLS verified pgTAP | Full stack |
| F002 | Auth: email/pw, org creation, JWT org_id claim, custom hook | No passkeys |
| F003 | Org switching: refreshSession, queryClient.clear, RT reconnect | Multi-tenant critical |
| F004 | Basic CI: typecheck (tsc+tsgo), lint, RLS tests | GitHub Actions, no Schemathesis |
| F005 | Deploy: Fly.io FastAPI + Vercel Vite SPA | Single shared-cpu-1x, auto-stop |

### Block 0B: Local AI Infra ⚠️ HIGHEST RISK (Wk 3–5)
| ID | Feature | Notes |
|---|---|---|
| F006 | Ollama ≥0.21.1: Docker Compose, OpenAI-compat API, native tool calling | 165K+ stars; Gemma4, Qwen3.5, Phi-4-mini, Llama4 |
| F007 | llama.cpp + ik_llama.cpp fork: BitNet, fused MoE, hybrid GPU/CPU | Better CPU & hybrid perf |
| F008 | Model registry: pull, verify SHA-256, register, serve | Gemma 4 E2B (2B active, multimodal, tool calling) default; Qwen3.5 4B executor |
| F009 | GGUF Q4_K_M: all models ≤4.5GB RAM, ~6 TPS on consumer CPU | Human reading speed |
| F010 | LiteLLM proxy ≥1.83.7, cosign verified | Sonnet 4.6($3/$15 per 1M tok), Opus 4.7 premium fallback |
| F011 | Intent Dispatcher v1: routes via `preferred_executor` | code→Qwen3.5 4B→Sonnet4.6→Opus4.7 cascade |
| F012 | Local‑first routing: free‑tier all local; cloud API gated behind paid sub | ~$0 marginal cost free users |

**Decision Wk5:** If Gemma 4 E2B tool-calling reliability <90%, evaluate Qwen3.5 4B or Llama4‑7B.

### Block 0C: Chat + Agent Tool Calling (Wk 5–8)
| ID | Feature | Notes |
|---|---|---|
| F013 | Chat page: ThreadList, MessageList, ChatInput, MessageBubble | StaleTime:Infinity AI msgs, @V virtualization |
| F014 | Vercel AI SDK v6 streaming+tool calling | Tool approval gates, multi-step reasoning |
| F015 | LangGraph Supervisor → FLOWC01 state machine | Centralized supervisor→specialized workers; LangMem cross-session summaries |
| F016 | Tool: create/update/delete calendar event | events table, deterministic via Intent Dispatcher |
| F017 | Tool: list/create/update/delete tasks | tasks table |
| F018 | Guardrails input: PII, jailbreak, toxicity | All AI calls, logged audit_logs |
| F019 | Guardrails output: hallucination (LLM-as-judge DeepEval) | LiteLLM proxy, warning not blocking Phase 0 |

### Block 0D: Data Apps — Calendar & Tasks (Wk 8–12)
| ID | Feature | Notes |
|---|---|---|
| F020 | Events table + FastAPI CRUD | events(id,org_id,title,start,end,tz,allDay,recurrence_id,cat,uat) |
| F021 | Calendar MonthView, WeekDayView, AgendaView | @M MotionGuard, @Z TimezoneAware, ARIA grid, keyboard shortcuts |
| F022 | EventComposer: optimistic CRUD, 5s undo | @O, @R recurring support |
| F023 | EventDetailDrawer: inline edit, delete, agent log | Tabs: details, agent history, related tasks |
| F024 | Drag‑and‑drop reschedule: dnd‑kit façade | @O, DragOverlay, keyboard alt (WCAG 2.5.7) |
| F025 | Recurrence: rschedule + @rschedule/temporal-date-adapter | ZonedDateTime mandatory, DST matrix tests |
| F026 | Tasks table + FastAPI CRUD | tasks(id,org_id,project_id,title,status,assignee,due,priority,order) |
| F027 | Task list: status toggles, due dates, inline editing | @O, @V virtualization, @E InlineEdit |
| F028 | Kanban: drag‑and‑drop columns, task cards | pointerWithin, @O column change |
| F029 | Task comments: internal/external, DOMPurify RICH | @O, agent‑generated notes |
| F030 | Calendar‑Project linking: tasks w/ due → overlay | Optional overlay on calendar |
| F031 | Google Calendar read‑only: OAuth2.0, sync engine | Free (1M req/d), periodic fetch |

**Decision Wk12:** If GC sync stable, optionally add Outlook read‑only (Graph API). Else defer Phase 1.

### Block 0E: Dashboard & Conflict Agent (Wk 12–15)
| ID | Feature | Notes |
|---|---|---|
| F032 | Dashboard: AmbientStatusBanner, ActivityFeed, AttentionQueue | @M, @AP AnimatePresence, role=log aria‑live |
| F033 | Notification table + real‑time sub | notifications(id,org_id,user_id,template,deeplink,read,cat) |
| F034 | Notification feed w/ actions: Reschedule, Move, Ignore | InAppNotifications template+deeplink |
| F035 | Conflict detection: deterministic overlap, multi‑tz | Pure code, agent tool |
| F036 | Agent orchestration: Chat→detect_conflicts→Dashboard | Orchestrator (Gemma4 E2B) calls tool, Dispatcher to code |
| F037 | Agent action: Dashboard→orchestrator→tool→confirmation | resolve_conflict tool, confirmation logged |
| F038 | Cost tracking: ai_cost_log TimescaleDB hypertable | Per‑org/model, x‑litellm‑tags: org_id,user_id,feature |

### Block 0F: Monetization & Polish (Wk 15–16)
| ID | Feature | Notes |
|---|---|---|
| F039 | Stripe metered billing: @stripe/ai‑sdk v0.1.2, 30% markup | 4‑layer cost governance: sync pre‑call budget check |
| F040 | Tiers: Free(local only), Pro($20‑30/mo Sonnet 4.6), Team(Opus 4.7, fine‑tuning) | Stripe customer portal self‑service |
| F041 | CSP: nonce, strict‑dynamic, Report‑Only pre‑prod | DOMPurify ≥3.4.0, SanitizedHTML |
| F042 | Rate limiting: FastAPI‑Limiter + Upstash Redis | Per‑user/org token bucket, 429 Retry‑After |
| F043 | WORM audit: all agent decisions immutable | audit_logs, hash chaining |
| F044 | Pre‑launch security audit: CSP, RLS, rate limit, MCP tool auth | Red teaming prompt injections/jailbreaks |

**Phase 0 Exit Gate:** 1 external user signs up, connects GC, creates tasks, agent detects conflict autonomously.

## Phase 1: Public Launch & Proactive Intelligence (Solo → First Paying)
**Trigger:** Phase 0 demo ≥3 external testers  
**Cost:** ~$200–500/mo (Supabase Pro $25, Fly Scale $29‑59, Nylas eval, Sentry Team $26, PostHog Free, Ollama local)

### Block 1A: Observability
| ID | Feature | Notes |
|---|---|---|
| P101 | Sentry: 4 projects, PII strip, maskAllText:true Session Replay | Team $26/mo |
| P102 | PostHog: event taxonomy, Group Analytics, allow_training flag | Free 1M events, mandatory day1 |
| P103 | OTel GenAI traces: gen_ai.*, DataPrepper root span, PII redaction | OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai |

### Block 1B: Email Integration
| ID | Feature | Notes |
|---|---|---|
| P104 | Nylas Email API: read, send, webhooks | Upsert‑first, 10s timeout, async. Cost gate: ≥50 accts $165/mo (~$3.30/acct); >$200/mo defer |
| P105 | Email conflict: parse reschedule→check conflicts | Local model (Qwen3.5 4B or Gemma4 E2B) parsing. Lightweight model via Dispatcher |
| P106 | grant.expired webhook: re‑auth <72h, proactive renewal | Daily cron, P1 if missed |
| P107 | Resend transactional: email.complained→unsub:true | Free 3K/mo, Pro $20/mo at scale |

### Block 1C: Proactive Intelligence
| ID | Feature | Notes |
|---|---|---|
| P108 | Agent proactivity config per plan: scheduled(AM), event‑driven(on email), manual | Free: manual, Pro: scheduled, Team: event‑driven |
| P109 | Proactive notification engine | Configurable per feature |

### Block 1D: Verifier & Local AI Enhancements
| ID | Feature | Notes |
|---|---|---|
| P110 | Verifier cascade: Phi‑4‑mini‑reasoning (3.8B) local | Checks reasoning, schema, permission/cost. Function calling supported |
| P111 | Model capability registry: automated benchmark all models | Tool‑calling scores, latency, hallucination rates |
| P112 | Loop controller (SLM‑6): circuit breaker orchestrator | Configurable max iterations, temperature=0 control |
| P113 | Model update/deprecation policy: version freeze, smooth migration | 30‑day notice, auto‑migrate successor |
| P114 | Second local model: Llama4‑7B or Qwen3.5‑4B high‑throughput | Task‑type selection, registry tracks pass rates |

### Block 1E: External & Feature Expansion
| ID | Feature | Notes |
|---|---|---|
| P115 | Google Calendar write: CRUD OAuth, free | Calendars.ReadWrite scope |
| P116 | Outlook Calendar read‑only: Graph API | **Blocker:** EWS blocks non‑MS apps Oct 2026; Graph only |
| P117 | Project Timeline, Workload view | Deferred from Phase 0 |
| P118 | Project templates & automation rules | Save‑as‑template, triggered=strikethrough |
| P119 | User onboarding: guided setup | EmptyState pattern |
| P120 | AI cost dashboard (admin) | Per‑org/team/user/model, forecast ±10% |
| P121 | Feature flags: OpenFeature + Vercel Flags SDK | off→internal(2d)→beta(3d)→5/20/50%(2d)→100%; kill<5min |

**Phase 1 Exit Gate:** ≥20 paying, <5% monthly churn, free AI cost <$0.05/mo, Pro cloud cost <$3/mo, NPS >40.

### Nylas Cost Decision Matrix
| Accounts | Cost | Action |
|---|---|---|
| ≤50 | ≤$165/mo | Absorb as CAC |
| 50–200 | $165–$660/mo | Require Pro plan ($20/mo) |
| >200 | >$660/mo | Passthrough or direct API |

## Phase 2: Suite Expansion & First Hire (Solo → Team)
**Trigger:** ≥20 paying or unable to review AI PRs <2d  
**Cost:** ~$500–1,500/mo

### Block 2A: Team
| ID | Feature | Notes |
|---|---|---|
| P201 | Hire first engineer (contract/FTE) | Platform or Frontend based on bottleneck |

### Block 2B: App Suite
| ID | Feature | Notes |
|---|---|---|
| P202 | Contacts: ContactDetail, QuickAdd, EnrichmentPanel, TagManager | @E InlineEdit, privacy field‑level |
| P203 | Documents: DocumentGrid, UploadManager, VersionHistory | ClamAV v1.4.x sidecar, freshclam hourly |
| P204 | Notes/Research: MindMapEditor(markmap+Yjs), FlashcardDeck(FSRS) | @M, @AS Spring, collab opt‑in |
| P205 | Agent tools for each app: consistent MCP definitions | Logged, guarded |

### Block 2C: AI Depth
| ID | Feature | Notes |
|---|---|---|
| P206 | GraphRAG: FastGraphRAG (NLP entities ~10% cost) | LLM-based gated 500K chunks |
| P207 | Contextual Retrieval: activate >50K chunks, precision >15%, cache >60% | Tracked ragindexstats |
| P208 | Agent Studio: versioning, trust catalog, playground, eval gates | Semantic versioning prompts |

### Block 2D: Local AI Maturation
| ID | Feature | Notes |
|---|---|---|
| P209 | Fine‑tuning: Unsloth(GPU QLoRA 2x,70% less VRAM), LoFT CLI(CPU 1‑3B), MLX‑LM(Apple) | Domain/per‑org style |
| P210 | Multi‑model concurrent: Gemma4+Qwen3.5+Phi‑4‑mini | CPU affinity: orchestrator core cluster, inference other |
| P211 | Model eval harness: automated tool‑calling pass rate, weekly | lm‑evaluation‑harness or custom, registry stored |
| P212 | NUMA‑aware: ArcLight eval for multi‑socket | 46% higher throughput on many‑core |

### Block 2E: Platform Maturation
| ID | Feature | Notes |
|---|---|---|
| P213 | Monorepo: Turborepo 2.x, pnpm catalogs | Strict: packages/ui no import from features |
| P214 | Full CI: typecheck, lint, test:unit/component/rls/e2e, prisma:drift, orval:codegen, docker:build, schemathesis | AI eval no cache, base=main |
| P215 | Offline: tombstone sync (deleted_at, ULID, IC), outbox MVP | PowerSync eval continues |
| P216 | Schemathesis contract test CI gate | Main+PR, ignore SSE/WS endpoints |
| P217 | DeepEval+RAGAS AI eval CI gates | LLM‑as‑judge LiteLLM proxy |

**Phase 2 Exit Gate:** ≥200 paying, NRR >90%, one app/quarter, cross‑app scenario (e.g., attach doc to client contact).

## Phase 3: Monetization Maturity & Compliance Readiness
**Trigger:** ≥200 paying or first enterprise SOC2 inquiry  
**Cost:** ~$2,000–5,000/mo

### Block 3A: Billing & Revenue
| ID | Feature | Notes |
|---|---|---|
| P301 | Tiered model access: license gates, feature flags per plan | Modules locked, AI limits graduated |
| P302 | Revenue optimization: unit economics dashboard, churn prediction | PostHog+Stripe data |
| P303 | DaaS foundation: anonymized exports, separate consent | allow_training flag respected |

### Block 3B: Compliance
| ID | Feature | Notes |
|---|---|---|
| P304 | EU AI Act docs: auto generation, risk logs | Deadline Dec 2027 standalone, Aug 2028 embedded |
| P305 | AIBOM (CycloneDX) per model CI: provenance, safety evals | High‑risk mandatory |
| P306 | SOC2 Type I: Vanta/Oneleet, evidence pipeline | ~$10K/yr Vanta, 3mo prep+audit $25‑50K |
| P307 | Privacy: GDPR opt‑out, segregation, annual PIA, diff privacy | TEE sensitive analytics |
| P308 | Passkeys: SimpleWebAuthn + webauthn_challenges | SB Auth MFA, cross‑device QR, recovery codes |

### Block 3C: Mobile
| ID | Feature | Notes |
|---|---|---|
| P309 | Expo mobile (read‑only v1): calendar, tasks, notifications | SDK 55/56, use 56 if stable else 55 |
| P310 | expo‑notifications: push conflict alerts, deep link | Dev build Android required |

### Block 3D: Local AI at Scale
| ID | Feature | Notes |
|---|---|---|
| P311 | Distributed inference: Prima.cpp (ICLR 2026) 30‑70B home clusters | 26 TPS 32B speculative decoding |
| P312 | Ternary migration: FairyFuse (32.4 tok/s Xeon, 1.24x llama.cpp) | When ternary in llama.cpp, registry tracks quant format |
| P313 | Intel OpenVINO 2026.1 backend llama.cpp | Core Ultra NPU usage |

**Phase 3 Exit Gate:** SOC2 Type I, first 10 enterprise (≥50 seats each).

## Phase 4: Enterprise Scale & Real‑Time (Team 3–5)
**Trigger:** SOC2 Type I + first enterprise contract  
**Cost:** ~$5,000–12,000/mo

### Block 4A: Enterprise
| ID | Feature | Notes |
|---|---|---|
| P401 | SSO (SAML/OIDC), SCIM, advanced RBAC | Enterprise gate |
| P402 | SOC2 Type II observation 6‑12mo | Annual audit, Vanta continuous |
| P403 | Custom retention, audit exports | Per‑org config |

### Block 4B: Real‑Time & Collaboration
| ID | Feature | Notes |
|---|---|---|
| P404 | Yjs real‑time: CollabCanvas, RealTimeCoEdit | Y‑Sweet self‑host (Jamsocket shutdown Mar 2026), GC, undo trunc last5, 50MB |
| P405 | LiveKit Agents v2.0: VoiceShell, conference agent, semantic turn detection | STT→LLM→TTS, WebRTC |

### Block 4C: Offline & Mobile Maturation
| ID | Feature | Notes |
|---|---|---|
| P406 | PowerSync bidirectional: SQLite↔Postgres | YAML sync rules per orgId, 3‑user free, SOC2/HIPAA |
| P407 | Offline mobile: full CRUD, conflict resolution, queue replay | TanStack DB 0.6 persistence, hierarchical projection |

**Phase 4 Exit Gate:** 500+ paying orgs, 10 with >50 seats, first seven‑figure ARR.

## Phase 5: Advanced AI & Ecosystem (Team 5–10)
**Trigger:** 500+ orgs, stable revenue, dedicated AI team

| ID | Feature | Notes |
|---|---|---|
| P501 | A2A Protocol v1.0: Agent Cards, cryptographic identity, decentralized discovery | Linux Foundation, multi‑tenant |
| P502 | Semantic Layer: MATRIX ontology, knowledge graph, cross‑agent vocab | Merkle lineage extends A2A Cards |
| P503 | Edge AI: Transformers.js+Wasm (Phi‑4, Gemma‑2B) | Prefix caching 80% TTFT reduction |
| P504 | MCP marketplace: third‑party publishing, trust catalog | MCPSec L2 mandatory |
| P505 | MACH composable: API‑first all apps, third‑party integrations | MACH Alliance |
| P506 | Desktop app: Tauri v2, Capabilities per window, auto‑update | CI capability audit |
| P507 | Internationalization: multi‑language UI | East Asia readiness |

**Phase 5 Exit Gate:** Ecosystem, third‑party dev community active, ARR tens of millions.

## Phase 6: Maturity & Moonshots (Team 15–30)
**Trigger:** Strong market position, R&D budget

| ID | Feature | Notes |
|---|---|---|
| P601 | Temporal API native (ES2027+), remove polyfill | Safari gap closed |
| P602 | Quantum‑resistant crypto: hybrid classical+ML‑KEM long‑lived keys | Inventory by 2027 |
| P603 | Full multimodal agents: voice, video, vision‑native | LiveKit Agents mature |
| P604 | Horizontal: lightweight ERP, CRM, HR modules | AI cross‑app awareness moat |
| P605 | API marketplace: dev community, revenue share, certification | DaaS monetization |
| P606 | Custom models: proprietary from open‑source bases, from scratch when ready | Mistral Forge or equivalent |

## Cost Projections
| Phase | Monthly | Key Drivers |
|---|---|---|
| 0 | $30–50 | Supabase $25, Fly $5, Resend free, local $0 |
| 1 | $200–500 | Nylas $165+, Sentry $26, Fly Scale $29‑59, Claude API Pro |
| 2 | $500–1,500 | Nylas scale, Supabase scale, first hire, Claude growth |
| 3 | $2k–5k | Vanta $10k/yr, SOC2 audit $25‑50k, mobile, server upgrades |
| 4 | $5k–12k | PowerSync $51+, LiveKit, SOC2 Type II annual, salaries |
| 5 | $5k–20k | Multi‑region, marketplace, Tauri signing |
| 6 | $10k–50k+ | Enterprise suite, dedicated AI compute, custom training |

## Key Blockers & Risks
| Blocker | Impact | Mitigation | Phase |
|---|---|---|---|
| LLM tool‑calling <90% | Magic fails | Test Block 0B, fallback Qwen3.5 4B (97.5%), stricter prompts, LangGraph checkpointing | 0 |
| Nylas scale ($3.30/acct) | Cost explosion | Gate 50 accts, eval direct API | 1‑2 |
| EWS deprecation Oct’26 | Outlook block | Graph API only | 1 |
| SOC2 Type II 6‑12mo | Delays enterprise | Type I Phase 3, Type II Phase 4 | 3‑4 |
| OpenAI Assistants shutdown Aug’26 | API void | Responses API+Vercel AI SDK v6 from Phase 0 | 0 |
| Y‑Sweet/Jamsocket shutdown Mar’26 | No hosted Yjs | Self‑host Fly.io Phase 4 | 4 |
| EU AI Act high‑risk | Compliance cost | Deadlines Dec’27/Aug’28, docs Phase 3 | 3‑4 |
| Gemini free tier restrictions Mar’26 | Free tier limited | Local models absorb free, Gemini Flash fallback | 0 |
| Local model staleness | Accuracy drift | Weekly re‑benchmark, verifier monitors, registry dates | 2+ |

## Local Model Fleet
| Phase | Models | Roles | Hardware |
|---|---|---|---|
| 0 | Gemma4 E2B(2B), Qwen3.5 4B | Orche+chat, tool exec | CPU 16GB |
| 1 | + Phi‑4‑mini‑reasoning(3.8B) | Verifier | Concurrent serving |
| 2 | + Llama4‑7B / Gemma4 E4B(4.5B) | High‑throughput, complex | GPU optional, multi‑model |
| 3 | + Fine‑tuned LoRA adapters | Per‑org personalization | Dedicated server/GPU |
| 4‑5 | + Distributed 30‑70B Prima.cpp | Enterprise workflows | Home cluster/multi‑GPU |
| 6 | Custom proprietary models | Full vertical | Dedicated AI compute |

## Monetization: Local‑Default, Cloud‑Premium
| Tier | AI Capability | Marginal Cost/user/mo | Pricing |
|---|---|---|---|
| Free | Local only (Gemma4 E2B, Qwen3.5 4B) | ~$0.0001 (electricity) | Free forever |
| Pro | Local + Sonnet 4.6 ($3/$15 per 1M tok) | $0.10–0.50 | $20–30/mo |
| Team | Local + Opus 4.7 ($5/$25 per 1M tok) + fine‑tuning | $1–5 | $50–100/user/mo |
| Enterprise | Dedicated models, private hosting, SSO, compliance | Custom | Custom |

**Structural advantage:** 10k free users: cloud competitor burns $50k–$150k/mo AI inference; your cost ~$10/mo electricity.