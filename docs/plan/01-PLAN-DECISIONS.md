# Unified Decision Log

**Single source of truth for all decisions, ADRs, and questions.** Append-only log. Check before new decisions.

## Format

| Column | Description |
| :--- | :--- |
| **ID** | `DEC-YYYY-MM-DD-NNN` or `ADR_XXX` or `Q-NNN` |
| **Date** | ISO 8601 |
| **Type** | process/architecture/product/question |
| **Domain** | Platform/Data/AI-Core/Frontend/UX/Security/Business |
| **Decision** | One sentence, specific |
| **Rationale** | Why + rejected alternatives |
| **Reversible?** | Yes/Costly/No |
| **Confidence** | High/Medium/Low |
| **Status** | active/superseded/expired/open/deferred |
| **Expiry** | none or date |
| **ADR_Ref** | ADR document link (for Type: architecture) |
| **Linked Items** | ADR IDs, rule IDs, BP-XXX, filenames |
| **Session** | session file for traceability |

## Rules

- Append only. Never edit existing rows -- supersede with new row.
- Reversible decisions: quick agent decisions. Costly/irreversible: Trevor's explicit review.
- Register reviewed for staleness after 5 planning sessions + each Phase gate.
- This log replaces separate ADR Index and Questions documents.

## Active Decisions

| ID | Date | Type | Domain | Decision | Rationale | Reversible? | Confidence | Status | Expiry | ADR_Ref | Linked Items | Session |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| DEC-2026-04-26-001 | 2026-04-26 | process | Process | All planning documents follow SPEC-TEMPLATE.md format | Standardization; rejected free-form markdown | Costly | High | active | none | -- | SPEC-TEMPLATE.md, ADR_054 | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-002 | 2026-04-26 | process | Process | `00-PLANNING-BACKLOG.md` is single source of truth for unresolved decisions | Prevents premature implementation | Yes | High | active | none | -- | 00-PLANNING-BACKLOG.md | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-003 | 2026-04-26 | process | Process | Decision register uses append-only: new decisions get new rows; old ones marked `superseded` | Preserves decision history | Costly | High | active | none | -- | -- | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-004 | 2026-04-26 | process | Process | AI agents must read this register at session start + append new decisions before session end | Prevents decision loss | Yes | High | active | none | -- | -- | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-005 | 2026-04-26 | process | Process | Reversible decisions made by AI agents without Trevor approval. Costly/irreversible require explicit Trevor review | Prevents decision paralysis while protecting against costly mistakes | Yes | Medium | active | Review after 10 sessions | -- | -- | session-2026-04-26-claude-planning-framework |
| ADR_001 | 2026-04-26 | architecture | Platform | Use Vite SPA, not Next.js | SPA architecture preferred for client-side control | Costly | High | active | none | docs/adr/ADR_001.md | -- | -- |
| ADR_002 | 2026-04-26 | architecture | Data | Prisma schema + migrations, Supabase runtime | Type-safe ORM with managed Postgres | Costly | High | active | none | docs/adr/ADR_002.md | -- | -- |
| ADR_003 | 2026-04-26 | architecture | Frontend | Use Zustand v5 for state management | Lightweight state management for UI-only state | Costly | High | active | none | docs/adr/ADR_003.md | -- | -- |
| ADR_004 | 2026-04-26 | architecture | AI-Core | LiteLLM as AI proxy/gateway | Unified API for multiple LLM providers | Costly | High | active | none | docs/adr/ADR_004.md | -- | -- |
| ADR_008 | 2026-04-26 | architecture | Frontend | markmap for MindMapEditor | Markdown-based mind mapping | Costly | High | active | none | docs/adr/ADR_008.md | -- | -- |
| ADR_011 | 2026-04-26 | architecture | Security | FastAPI JWT bridge with custom access token hook | Custom auth integration with Supabase | Costly | High | active | none | docs/adr/ADR_011.md | -- | -- |
| ADR_012 | 2026-04-26 | architecture | AI-Core | Embeddings computed only on backend | Centralize vector computation | Costly | High | active | none | docs/adr/ADR_012.md | -- | -- |
| ADR_016 | 2026-04-26 | architecture | Frontend | react-helmet-async for meta tags | SEO and document head management | Costly | High | active | none | docs/adr/ADR_016.md | -- | -- |
| ADR_017 | 2026-04-26 | architecture | Security | Pin DOMPurify ≥3.4.0, transitive CI audit | XSS protection with supply chain security | Costly | High | active | none | docs/adr/ADR_017.md | -- | -- |
| ADR_018 | 2026-04-26 | architecture | Frontend | Lock dnd-kit as primary DnD library; no migration to PragmaticDnD | Stable drag-and-drop implementation | Costly | High | active | none | docs/adr/ADR_018.md | -- | -- |
| ADR_020 | 2026-04-26 | architecture | Security | Y-Sweet token endpoint with CSP integration | Secure token generation for Y-Sweet | Costly | High | active | none | docs/adr/ADR_020.md | -- | -- |
| ADR_021 | 2026-04-26 | architecture | Security | Allow `style-src-attr 'unsafe-inline'` for motion animations | Enable CSS-in-JS animations | Costly | High | active | none | docs/adr/ADR_021.md | -- | -- |
| ADR_022 | 2026-04-26 | architecture | Frontend | Monaco Editor isolated in sandboxed iframe with separate CSP | Secure code editor isolation | Costly | High | active | none | docs/adr/ADR_022.md | -- | -- |
| ADR_023 | 2026-04-26 | architecture | Security | Custom Supabase access token hook for RBAC + org switch | Multi-tenant auth with org context | Costly | High | active | none | docs/adr/ADR_023.md | -- | -- |
| ADR_024 | 2026-04-26 | architecture | AI-Core | Agent sharing and versioning via Agent Studio | Agent lifecycle management | Costly | High | active | none | docs/adr/ADR_024.md | -- | -- |
| ADR_025 | 2026-04-26 | architecture | Frontend | GenUI trusted component catalog for agent-driven UI | Safe agent-generated UI components | Costly | High | active | none | docs/adr/ADR_025.md | -- | -- |
| ADR_027 | 2026-04-26 | architecture | Security | ClamAV server-side (`clamd`) for file scanning | Malware detection for uploads | Costly | High | active | none | docs/adr/ADR_027.md | -- | -- |
| ADR_028 | 2026-04-26 | architecture | AI-Core | AI evaluation in CI as mandatory gate | Quality gate for AI features | Costly | High | active | none | docs/adr/ADR_028.md | -- | -- |
| ADR_030 | 2026-04-26 | architecture | AI-Core | Hybrid retrieval: RRF + cross-encoder rerank | Improved RAG accuracy | Costly | High | active | none | docs/adr/ADR_030.md | -- | -- |
| ADR_031 | 2026-04-26 | architecture | AI-Core | A2A Agent Card Registry + decentralized discovery | Agent interoperability standard | Costly | High | active | none | docs/adr/ADR_031.md | -- | -- |
| ADR_032 | 2026-04-26 | architecture | Business | Saga Compensation Pattern for workflow rollback | Distributed transaction consistency | Costly | High | active | none | docs/adr/ADR_032.md | -- | -- |
| ADR_033 | 2026-04-26 | architecture | Security | Automated RLS testing with pgTAP | Row-level security validation | Costly | High | active | none | docs/adr/ADR_033.md | -- | -- |
| ADR_034 | 2026-04-26 | architecture | Frontend | React Compiler enabled globally (babel plugin) | Automatic React optimization | Costly | High | active | none | docs/adr/ADR_034.md | -- | -- |
| ADR_035 | 2026-04-26 | architecture | AI-Core | AI Peer for Yjs collaboration | AI-assisted collaborative editing | Costly | High | active | none | docs/adr/ADR_035.md | -- | -- |
| ADR_054 | 2026-04-26 | architecture | Process | Standardized spec template (YAML + 9 sections) | Consistent documentation structure | Costly | High | active | none | docs/adr/ADR_054.md | DEC-2026-04-26-001 | -- |
| ADR_058 | 2026-04-26 | architecture | Platform | OpenAPI 3.1 as single source of truth, Orval codegen, Schemathesis CI | API-first development with contract testing | Costly | High | active | none | docs/adr/ADR_058.md | -- | -- |
| ADR_062 | 2026-04-26 | architecture | Platform | Progressive rollout of feature flags with kill switch (<5 min) | Safe feature deployment | Costly | High | active | none | docs/adr/ADR_062.md | -- | -- |
| ADR_063 | 2026-04-26 | architecture | Business | Multi-level AI cost governance (org/team/user/model, LLM middleware, forecasting) | Cost control and predictability | Costly | High | active | none | docs/adr/ADR_063.md | -- | -- |
| ADR_064 | 2026-04-26 | architecture | Data | Expand-contract ZDT migrations with 6-step rename | Zero-downtime schema migrations | Costly | High | active | none | docs/adr/ADR_064.md | -- | -- |
| ADR_065 | 2026-04-26 | architecture | Platform | SLO-driven observability + error budgets (TTFT ≤2s, 99.9%, burn rate alerts) | Performance monitoring with SLOs | Costly | High | active | none | docs/adr/ADR_065.md | -- | -- |
| ADR_076 | 2026-04-26 | architecture | Frontend | Yjs lifecycle: GC on, undo truncation last 5, snapshot version history | Yjs memory management | Costly | High | active | none | docs/adr/ADR_076.md | -- | -- |
| ADR_077 | 2026-04-26 | architecture | Data | Nylas v3 webhooks: upsert-first, 10s timeout, async queue | Reliable webhook processing | Costly | High | active | none | docs/adr/ADR_077.md | -- | -- |
| ADR_079 | 2026-04-26 | architecture | Data | Offline-first tombstone pattern: `deleted_at` (nullable ms), ULID, idempotency keys | Offline sync with deletion tracking | Costly | High | active | none | docs/adr/ADR_079.md | -- | -- |
| ADR_083 | 2026-04-26 | architecture | Platform | Y-Sweet must be self-hosted (Jamsocket shutdown March 2026) | Vendor independence for Y-Sweet | Costly | High | active | none | docs/adr/ADR_083.md | -- | -- |
| ADR_084 | 2026-04-26 | architecture | Data | PowerSync as primary offline sync (replaces cr-sqlite, Replicache) | Offline-first with Postgres | Costly | High | active | none | docs/adr/ADR_084.md | -- | -- |
| ADR_085 | 2026-04-26 | architecture | Frontend | dnd-kit remains primary DnD library; no migration to PragmaticDnD | Confirm DnD library choice | Costly | High | active | none | docs/adr/ADR_085.md | -- | -- |
| ADR_086 | 2026-04-26 | architecture | AI-Core | Vercel AI SDK v6 for streaming, tool calling, AI Gateway | Unified AI SDK with streaming | Costly | High | active | none | docs/adr/ADR_086.md | -- | -- |
| ADR_087 | 2026-04-26 | architecture | Frontend | Tremor charts for Tailwind-native dashboards | Dashboard charting library | Costly | High | active | none | docs/adr/ADR_087.md | -- | -- |
| ADR_088 | 2026-04-26 | architecture | Platform | Resend promoted from fallback to primary transactional email | Primary email provider | Costly | High | active | none | docs/adr/ADR_088.md | -- | -- |
| ADR_089 | 2026-04-26 | architecture | AI-Core | Haiku excluded from all agentic deployments | Model exclusion policy | Costly | High | active | none | docs/adr/ADR_089.md | -- | -- |
| ADR_090 | 2026-04-26 | architecture | Security | MCP Inspector network isolation (dev-only, firewall block) | Secure MCP development | Costly | High | active | none | docs/adr/ADR_090.md | -- | -- |
| ADR_091 | 2026-04-26 | architecture | Security | LiteLLM must be ≥1.83.7 with cosign verification after supply-chain attack | Supply chain security for LiteLLM | Costly | High | active | none | docs/adr/ADR_091.md | -- | -- |
| ADR_092 | 2026-04-26 | architecture | Security | Orval ≥8.2.0 (mitigates CVEs 2026-24132, 23947, 25141) | Security patch for Orval | Costly | High | active | none | docs/adr/ADR_092.md | -- | -- |
| ADR_093 | 2026-04-26 | architecture | AI-Core | Claude 4.6 model IDs to be hard-migrated by June 15, 2026 | Model deprecation migration | Costly | High | active | none | docs/adr/ADR_093.md | -- | -- |
| ADR_094 | 2026-04-26 | architecture | Frontend | React Compiler carveout: RHF "use no memo", Zustand persist no Suspense | React Compiler exceptions | Costly | High | active | none | docs/adr/ADR_094.md | -- | -- |
| ADR_095 | 2026-04-26 | architecture | Frontend | Temporal polyfill mandatory until Safari supports Temporal natively | Date/time handling polyfill | Costly | High | active | none | docs/adr/ADR_095.md | -- | -- |
| ADR_096 | 2026-04-26 | architecture | Security | MCPSec L2 mandatory for all MCP servers (replaces ADR_067) | MCP security standard | Costly | High | active | none | docs/adr/ADR_096.md | ADR_067 | -- |
| ADR_097 | 2026-04-26 | architecture | Frontend | React 20 adoption timeline (Q2 eval, Q3 migration) | React upgrade planning | Costly | High | active | none | docs/adr/ADR_097.md | -- | -- |
| ADR_098 | 2026-04-26 | architecture | Platform | TypeScript 7.0 Go-native readiness (tsgo CI, tooling impact) | TypeScript upgrade preparation | Costly | High | active | none | docs/adr/ADR_098.md | -- | -- |
| ADR_099 | 2026-04-26 | architecture | Platform | Vercel Serverless (not Edge) for DB-dependent webhooks | Webhook deployment target | Costly | High | active | none | docs/adr/ADR_099.md | ADR_007 | -- |
| ADR_100 | 2026-04-26 | architecture | Data | Nylas grant.expired proactive re-auth within 72 hours | OAuth refresh handling | Costly | High | active | none | docs/adr/ADR_100.md | -- | -- |
| ADR_101 | 2026-04-26 | architecture | Security | OWASP Agentic Top 10 (ASI 2026) compliance mapping for guardrails | AI security compliance | Costly | High | active | none | docs/adr/ADR_101.md | -- | -- |
| ADR_102 | 2026-04-26 | architecture | Data | Prisma Next evaluation postponed to Phase 3 (Postgres GA mid-2026) | Prisma upgrade deferred | Costly | High | active | none | docs/adr/ADR_102.md | -- | -- |
| ADR_103 | 2026-04-26 | architecture | AI-Core | OpenAI Responses API migration path (deadline Aug 26, 2026) | API migration planning | Costly | High | active | none | docs/adr/ADR_103.md | -- | -- |
| ADR_104 | 2026-04-26 | architecture | Data | pgvectorscale threshold lowered to 500K vectors | Vector search scaling | Costly | High | active | none | docs/adr/ADR_104.md | -- | -- |
| ADR_105 | 2026-04-26 | architecture | Frontend | Tremor v3.18.x as standard charting library | Chart library version pin | Costly | High | active | none | docs/adr/ADR_105.md | -- | -- |
| ADR_106 | 2026-04-26 | architecture | AI-Core | FastGraphRAG first; LLM-based GraphRAG gated behind 500K chunk feature flag | GraphRAG rollout strategy | Costly | High | active | none | docs/adr/ADR_106.md | -- | -- |
| ADR_107 | 2026-04-26 | architecture | Security | SimpleWebAuthn for passkeys; `webauthn_challenges` table | Passkey authentication | Costly | High | active | none | docs/adr/ADR_107.md | -- | -- |
| ADR_108 | 2026-04-26 | architecture | AI-Core | DeepEval as primary AI evaluation framework; RAGAS alongside for RAG | AI evaluation tooling | Costly | High | active | none | docs/adr/ADR_108.md | -- | -- |
| ADR_109 | 2026-04-26 | architecture | Frontend | rschedule + Temporal date adapter replaces rrule.js on frontend | Recurrence engine migration | Costly | High | active | none | docs/adr/ADR_109.md | ADR_082 | -- |
| ADR_110 | 2026-04-26 | architecture | Platform | OpenFeature with Vercel Flags SDK + PostHog provider | Feature flag implementation | Costly | High | active | none | docs/adr/ADR_110.md | -- | -- |
| ADR_111 | 2026-04-26 | architecture | Security | Grype replaces Trivy for Docker scanning; scanners isolated from CI credentials | Container security scanning | Costly | High | active | none | docs/adr/ADR_111.md | -- | -- |
| ADR_112 | 2026-04-26 | architecture | Security | DOMPurify three profiles (STRICT/RICH/EMAIL) via SanitizedHTML component | Contextual XSS protection | Costly | High | active | none | docs/adr/ADR_112.md | -- | -- |
| ADR_113 | 2026-04-26 | architecture | AI-Core | LangGraph Supervisor for workflow state machine; LangMem for cross-session | AI workflow orchestration | Costly | High | active | none | docs/adr/ADR_113.md | -- | -- |
| ADR_114 | 2026-04-26 | architecture | Platform | Four Sentry projects with PII stripping and session replay | Error monitoring strategy | Costly | High | active | none | docs/adr/ADR_114.md | -- | -- |
| ADR_115 | 2026-04-26 | architecture | Frontend | LiveKit Agents v2.0 only; semantic turn detection mandatory | Real-time agent framework | Costly | High | active | none | docs/adr/ADR_115.md | ADR_006, ADR_019 | -- |
| ADR_116 | 2026-04-26 | architecture | Data | pg_textsearch BM25 replaces pg_trgm in hybrid search | Search performance improvement | Costly | High | active | none | docs/adr/ADR_116.md | -- | -- |
| ADR_117 | 2026-04-26 | architecture | Security | ClamAV v1.4.x sidecar with hourly freshclam updates | Antivirus update policy | Costly | High | active | none | docs/adr/ADR_117.md | -- | -- |
| ADR_118 | 2026-04-26 | architecture | AI-Core | Contextual Retrieval activation at 50K chunk threshold (Phase 1.5 eval) | RAG feature rollout | Costly | High | active | none | docs/adr/ADR_118.md | ADR_036 | -- |
| ADR_119 | 2026-04-26 | architecture | Business | Vanta as SOC2 automation platform; Type I target Q4 2026 | Compliance automation | Costly | High | active | none | docs/adr/ADR_119.md | -- | -- |
| ADR_120 | 2026-04-26 | architecture | Security | Upstash dynamic rate limits per plan tier; semantic cache threshold 0.92 | Rate limiting strategy | Costly | High | active | none | docs/adr/ADR_120.md | -- | -- |
| ADR_121 | 2026-04-26 | architecture | Platform | Multi-burn-rate SLO alerting (1h+5m P0, 6h P1, 3d P2) | Alerting strategy | Costly | High | active | none | docs/adr/ADR_121.md | -- | -- |
| ADR_122 | 2026-04-26 | architecture | Data | PowerSync confirmed as primary offline sync; ElectricSQL documented as alternative | Offline sync confirmation | Costly | High | active | none | docs/adr/ADR_122.md | -- | -- |
| ADR_123 | 2026-04-26 | architecture | Platform | Playwright AI agents (Planner/Generator/Healer) in CI; costs via LiteLLM proxy | AI-powered testing | Costly | High | active | none | docs/adr/ADR_123.md | -- | -- |
| ADR_124 | 2026-04-26 | architecture | Frontend | Tailwind v4 OKLCH three-layer token system; no hardcoded colours | Design system migration | Costly | High | active | none | docs/adr/ADR_124.md | -- | -- |
| ADR_125 | 2026-04-26 | architecture | Business | Four-layer cost governance with synchronous pre-call budget check | Cost enforcement | Costly | High | active | none | docs/adr/ADR_125.md | -- | -- |
| ADR_126 | 2026-04-26 | architecture | Business | PostHog Group Analytics mandatory from day one for org-scoped events | Analytics setup | Costly | High | active | none | docs/adr/ADR_126.md | -- | -- |
| Q-001 | 2026-04-26 | question | AI-Core | How often should agents check for conflicts? | Agents must proactively identify cross-app conflicts (e.g., email reschedule vs. project deadline) | Yes | Medium | open | none | -- | -- | -- |
| Q-002 | 2026-04-26 | question | Frontend | What UI patterns make deterministic actions feel agentic? | Deterministic code tools should still feel intelligent and agentic in the UX | Yes | Medium | open | none | -- | -- | -- |
| Q-003 | 2026-04-26 | question | Business | What are the exact feature gates per subscription tier? | Need to define which features are available at each tier | Yes | Medium | open | none | -- | -- | -- |
| Q-004 | 2026-04-26 | question | Data | How should cross-user conflict detection work? | Data model supports `org_id` from day one, but cross-user conflict detection is undefined | Yes | Medium | deferred | none | -- | -- | -- |
| Q-005 | 2026-04-26 | question | AI-Core | How to version, update, and deprecate local models without breaking workflows? | Local models (Ollama, llama.cpp) need a lifecycle management policy | Yes | Medium | open | none | -- | -- | -- |

---

## Superseded Decisions

| ID | Date | Domain | Decision | Superseded By | Superseded Date | Linked Items | Session |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| ADR_005 | 2026-04-26 | Platform | Y-Sweet + Yjs for real-time collab (self-host mandatory) | ADR_083 | 2026-04-26 | -- | -- |
| ADR_006 | 2026-04-26 | Frontend | LiveKit for real-time comm (v2.0 only per ADR_115) | ADR_115 | 2026-04-26 | -- | -- |
| ADR_007 | 2026-04-26 | Platform | Edge Functions for webhooks (now Serverless/FastAPI per ADR_099) | ADR_099 | 2026-04-26 | -- | -- |
| ADR_019 | 2026-04-26 | AI-Core | LiveKit Agents v1 (updated to v2.0 only per ADR_115) | ADR_115 | 2026-04-26 | -- | -- |
| ADR_036 | 2026-04-26 | AI-Core | Contextual Retrieval (Phase 2, cost model updated 50K threshold) | ADR_118 | 2026-04-26 | -- | -- |
| ADR_067 | 2026-04-26 | Security | MCP security model: OAuth, schema allowlist, high-risk elicitation | ADR_096 | 2026-04-26 | -- | -- |
| ADR_082 | 2026-04-26 | Frontend | Recurrence engine: rschedule + Temporal date adapter, ZonedDateTime mandatory | ADR_109 | 2026-04-26 | -- | -- |

---

## Expired Decisions

| ID | Date | Domain | Decision | Expired | Session |
| :--- | :--- | :--- | :--- | :--- | :--- |
| *None yet* | | | | | |

---

## Statistics

| Metric | Count |
| :--- | :--- |
| Total decisions | 136 |
| Active | 129 |
| Superseded | 7 |
| Expired | 0 |
| Reversible (Yes) | 5 |
| Costly to reverse | 130 |
| Irreversible (No) | 1 |
| High confidence | 135 |
| Medium confidence | 1 |
| Low confidence | 0 |

---

## ADR vs Decision Register

**Use ADR when:**

- Affects system structure, quality attributes, or technology choices
- Hard to reverse (cost of being wrong justifies documentation)

**Use Decision Register when:**

- Easy to reverse choices
- Configuration, UX copy, process decisions

Examples:
- **ADR-worthy:** "Use PostgreSQL not MongoDB," "Use Vite SPA not Next.js"
- **Register-worthy:** "Default calendar view is Month," "Notification batch size is 20"
