# ADR index — architecture decision records

## README

This index maps every ADR from `01-PLAN-LEXICON.md` #ADR_KEY to its domain and a one-line summary. Use it to quickly determine if an existing architectural decision covers a design choice you're about to make.

**For AI agents:** Query this index when you need to know if a decision has already been made. The "Related Decision Register ID" column links to the lightweight decision log (`00-DECISIONS-LOG.md`) if the decision has been further refined or superseded by a more recent choice.

**Statuses:** `active` (still in force), `superseded` (replaced by a newer ADR or decision), `updated` (modified but still active). Updates are noted in the Summary column.

**Domains:** Platform, Data, AI-Core, Frontend, Security, Business. Assignments are based on the ADR's primary scope.

## ADR index (sorted by ID)

| ADR ID | Domain | Summary | Status | Related Decision Register ID |
|--------|--------|---------|--------|------------------------------|
| ADR_001 | Platform | Use Vite SPA, not Next.js | active | — |
| ADR_002 | Data | Prisma schema + migrations, Supabase runtime | active | — |
| ADR_003 | Frontend | Use Zustand v5 for state management | active | — |
| ADR_004 | AI-Core | LiteLLM as the AI proxy/gateway | active | — |
| ADR_005 | Platform | Y‑Sweet + Yjs for real-time collaboration (self-host mandatory after ADR_083) | updated (see ADR_083) | — |
| ADR_006 | Frontend | LiveKit for real‑time communication (v2.0 only per ADR_115) | updated (see ADR_115) | — |
| ADR_007 | Platform | Edge Functions for webhooks (now routed to Serverless/FastAPI per ADR_099) | updated (see ADR_099) | — |
| ADR_008 | Frontend | markmap for MindMapEditor | active | — |
| ADR_011 | Security | FastAPI JWT bridge with custom access token hook | active | — |
| ADR_012 | AI-Core | Embeddings computed only on the backend | active | — |
| ADR_014 | Frontend | Pin react-big-calendar ^1.19.4 for React 19 compatibility | updated (see research findings) | — |
| ADR_016 | Frontend | react-helmet-async for meta tags | active | — |
| ADR_017 | Security | Pin DOMPurify ≥3.4.0, transitive CI audit | active | — |
| ADR_018 | Frontend | Lock dnd-kit as primary DnD library; no migration to PragmaticDnD | active | — |
| ADR_019 | AI-Core | LiveKit Agents v1 (updated to v2.0 only per ADR_115) | updated (see ADR_115) | — |
| ADR_020 | Security | Y‑Sweet token endpoint with CSP integration | active | — |
| ADR_021 | Security | Allow `style-src-attr 'unsafe-inline'` for motion animations | active | — |
| ADR_022 | Frontend | Monaco Editor isolated in sandboxed iframe with separate CSP | active | — |
| ADR_023 | Security | Custom Supabase access token hook for RBAC + org switch | active | — |
| ADR_024 | AI-Core | Agent sharing and versioning via Agent Studio | active | — |
| ADR_025 | Frontend | GenUI trusted component catalog for agent‑driven UI | active | — |
| ADR_027 | Security | ClamAV server‑side (`clamd`) for file scanning | active | — |
| ADR_028 | AI-Core | AI evaluation in CI as a mandatory gate | active | — |
| ADR_030 | AI-Core | Hybrid retrieval: RRF + cross‑encoder rerank | active | — |
| ADR_031 | AI-Core | A2A Agent Card Registry + decentralized discovery | active | — |
| ADR_032 | Business | Saga Compensation Pattern for workflow rollback | active | — |
| ADR_033 | Security | Automated RLS testing with pgTAP | active | — |
| ADR_034 | Frontend | React Compiler enabled globally (babel plugin) | active | — |
| ADR_035 | AI-Core | AI Peer for Yjs collaboration | active | — |
| ADR_036 | AI-Core | Contextual Retrieval (Phase 2, cost model updated 50K threshold) | updated (see ADR_118) | — |
| ADR_054 | Process | Standardized spec template (YAML + 9 sections) | active | DEC-2026-04-26-001 |
| ADR_058 | Platform | OpenAPI 3.1 as single source of truth, Orval codegen, Schemathesis CI | active | — |
| ADR_062 | Platform | Progressive rollout of feature flags with kill switch (<5 min) | active | — |
| ADR_063 | Business | Multi‑level AI cost governance (org/team/user/model, LLM middleware, forecasting) | active | — |
| ADR_064 | Data | Expand‑contract ZDT migrations with 6‑step rename | active | — |
| ADR_065 | Platform | SLO‑driven observability + error budgets (TTFT ≤2s, 99.9%, burn rate alerts) | active | — |
| ADR_067 | Security | MCP security model: OAuth, schema allowlist, high‑risk elicitation | updated (see ADR_096) | — |
| ADR_076 | Frontend | Yjs lifecycle: GC on, undo truncation last 5, snapshot version history | active | — |
| ADR_077 | Data | Nylas v3 webhooks: upsert‑first, 10s timeout, async queue, sync policy | active | — |
| ADR_079 | Data | Offline‑first tombstone pattern: `deleted_at` (nullable ms), ULID, idempotency keys | active | — |
| ADR_082 | Frontend | Recurrence engine: rschedule + Temporal date adapter, ZonedDateTime mandatory | updated (see ADR_109) | — |
| ADR_083 | Platform | Y‑Sweet must be self‑hosted (Jamsocket shutdown March 2026) | active | — |
| ADR_084 | Data | PowerSync as primary offline sync (replaces cr‑sqlite, Replicache) | active | — |
| ADR_085 | Frontend | dnd‑kit remains primary DnD library; no migration to PragmaticDnD | active | — |
| ADR_086 | AI-Core | Vercel AI SDK v6 for streaming, tool calling, and AI Gateway | active | — |
| ADR_087 | Frontend | Tremor charts for Tailwind‑native dashboards | active | — |
| ADR_088 | Platform | Resend promoted from fallback to primary transactional email | active | — |
| ADR_089 | AI-Core | Haiku excluded from all agentic deployments | active | — |
| ADR_090 | Security | MCP Inspector network isolation (dev‑only, firewall block) | active | — |
| ADR_091 | Security | LiteLLM must be ≥1.83.7 with cosign verification after supply‑chain attack | active | — |
| ADR_092 | Security | Orval ≥8.2.0 (mitigates CVEs 2026-24132, 23947, 25141) | active | — |
| ADR_093 | AI-Core | Claude 4.6 model IDs to be hard‑migrated by June 15, 2026 | active | — |
| ADR_094 | Frontend | React Compiler carveout: RHF “use no memo”, Zustand persist no Suspense | active | — |
| ADR_095 | Frontend | Temporal polyfill mandatory until Safari supports Temporal natively | active | — |
| ADR_096 | Security | MCPSec L2 mandatory for all MCP servers (replaces ADR_067 security posture) | active | — |
| ADR_097 | Frontend | React 20 adoption timeline (Q2 eval, Q3 migration) | active | — |
| ADR_098 | Platform | TypeScript 7.0 Go‑native readiness (tsgo CI, tooling impact) | active | — |
| ADR_099 | Platform | Vercel Serverless (not Edge) for DB‑dependent webhooks (routes Nylas webhooks away from Edge) | active | — |
| ADR_100 | Data | Nylas grant.expired proactive re‑auth within 72 hours | active | — |
| ADR_101 | Security | OWASP Agentic Top 10 (ASI 2026) compliance mapping for guardrails | active | — |
| ADR_102 | Data | Prisma Next evaluation postponed to Phase 3 (Postgres GA mid‑2026) | active | — |
| ADR_103 | AI-Core | OpenAI Responses API migration path (deadline Aug 26, 2026) | active | — |
| ADR_104 | Data | pgvectorscale threshold lowered to 500K vectors | active | — |
| ADR_105 | Frontend | Tremor v3.18.x as standard charting library | active | — |
| ADR_106 | AI-Core | FastGraphRAG first; LLM‑based GraphRAG gated behind 500K chunk feature flag | active | — |
| ADR_107 | Security | SimpleWebAuthn for passkeys; `webauthn_challenges` table | active | — |
| ADR_108 | AI-Core | DeepEval as primary AI evaluation framework; RAGAS alongside for RAG | active | — |
| ADR_109 | Frontend | rschedule + Temporal date adapter replaces rrule.js on frontend | active | — |
| ADR_110 | Platform | OpenFeature with Vercel Flags SDK + PostHog provider | active | — |
| ADR_111 | Security | Grype replaces Trivy for Docker scanning; scanners isolated from CI credentials | active | — |
| ADR_112 | Security | DOMPurify three profiles (STRICT/RICH/EMAIL) via SanitizedHTML component | active | — |
| ADR_113 | AI-Core | LangGraph Supervisor for workflow state machine; LangMem for cross‑session | active | — |
| ADR_114 | Platform | Four Sentry projects with PII stripping and session replay | active | — |
| ADR_115 | Frontend | LiveKit Agents v2.0 only; semantic turn detection mandatory | active | — |
| ADR_116 | Data | pg_textsearch BM25 replaces pg_trgm in hybrid search | active | — |
| ADR_117 | Security | ClamAV v1.4.x sidecar with hourly freshclam updates | active | — |
| ADR_118 | AI-Core | Contextual Retrieval activation at 50K chunk threshold (Phase 1.5 eval) | active | — |
| ADR_119 | Business | Vanta as SOC2 automation platform; Type I target Q4 2026 | active | — |
| ADR_120 | Security | Upstash dynamic rate limits per plan tier; semantic cache threshold 0.92 | active | — |
| ADR_121 | Platform | Multi‑burn‑rate SLO alerting (1h+5m P0, 6h P1, 3d P2) | active | — |
| ADR_122 | Data | PowerSync confirmed as primary offline sync; ElectricSQL documented as alternative | active | — |
| ADR_123 | Platform | Playwright AI agents (Planner/Generator/Healer) in CI; costs via LiteLLM proxy | active | — |
| ADR_124 | Frontend | Tailwind v4 OKLCH three‑layer token system; no hardcoded colours | active | — |
| ADR_125 | Business | Four‑layer cost governance with synchronous pre‑call budget check | active | — |
| ADR_126 | Business | PostHog Group Analytics mandatory from day one for org‑scoped events. Aggregation patterns: Trends (Unique with group type), Funnels (Aggregating by group type), Feature Flags (Match by group type). Query examples in 06-AI-CORE.md Section 9. | active | — |

## Domain Groupings (For Quick Filtering)

### Platform (A)
ADR_001, ADR_005*, ADR_007*, ADR_058, ADR_062, ADR_065, ADR_083, ADR_088, ADR_098, ADR_099, ADR_110, ADR_114, ADR_121, ADR_123

### Data (B)
ADR_002, ADR_064, ADR_077, ADR_079, ADR_084, ADR_100, ADR_102, ADR_104, ADR_116, ADR_122

### AI-Core (C)
ADR_004, ADR_012, ADR_019*, ADR_024, ADR_028, ADR_030, ADR_031, ADR_035, ADR_036*, ADR_086, ADR_089, ADR_093, ADR_103, ADR_106, ADR_108, ADR_113, ADR_118

### Frontend (D)
ADR_003, ADR_006*, ADR_008, ADR_014, ADR_016, ADR_018, ADR_022, ADR_025, ADR_034, ADR_076, ADR_082*, ADR_085, ADR_087, ADR_094, ADR_095, ADR_097, ADR_105, ADR_109, ADR_115, ADR_124

### Security (E)
ADR_011, ADR_017, ADR_020, ADR_021, ADR_023, ADR_027, ADR_033, ADR_067*, ADR_090, ADR_091, ADR_092, ADR_096, ADR_101, ADR_107, ADR_111, ADR_112, ADR_117, ADR_120

### Business (F)
ADR_032, ADR_063, ADR_119, ADR_125, ADR_126

### Process (Meta)
ADR_054

*Updated ADRs are listed under their primary domain; see the index for current status.*

## How to Use

- **Before implementing a feature**, scan the relevant domain above. If an ADR exists, read its summary and decide if it applies. For the full context, open the ADR in `01-PLAN-LEXICON.md`.
- **If you create a new decision** that supersedes an ADR, append a new row to this index with status `superseded` and link to the new ADR or Decision Register entry.
- **ADR_054 and DEC-2026-04-26-001** are an example of an ADR that has been further refined in the Decision Register. The ADR describes the *standard*; the Decision Register entry describes the *process* for its application.

*This index is a living companion to the Decision Register. Together, they form a complete map of every architectural and operational decision in the project.*