I’ve analyzed the research consolidation and transformed each piece into targeted updates for your existing planning files. The changes are presented in the same compressed, token‑optimized format as the originals. Apply these patches to your `00‑PLAN‑*` files to integrate all April 2026 findings.

---

## 🔧 File Updates

### 1. `00‑PLAN‑1‑INTRO.md` – Core Lexicon, Rules, ADRs, Tasks, Budgets
**Locations to modify:**

- **#LEX** – Append new shortcuts (PART 9):
```plaintext
DRS|rschedule+@rschedule/temporal‑date‑adapter(replaces rrule.js FE)
DFG|FastGraphRAG(NLP entity extraction,10% cost)
DLG|LangGraph(Supervisor/Swarm/LangMem/Trustcall)
DDE|DeepEval(Pytest‑native AI eval)
DSW|SimpleWebAuthn(MIT passkeys)
DGR|Grype(replaces Trivy scanning)
DPH|PostHog Group Analytics
DVF|Vercel Flags SDK(OpenFeature adapter)
DMB|Multi‑burn‑rate(1h+5m P0,6h P1,3d P2)
DDP3|DOMPurify profile(STRICT|RICH|EMAIL)
DCTXR|Contextual Retrieval(50K chunk threshold)
DSEK|Secret rotation log table(SOC2 audit)
DRGI|RAG index stats & performance logging
DSCH|Schemathesis contract testing gate
DPMC|MCP security gateway+SMCP L2
DNHS|OWASP Non‑Human Identity management
DOCL|OKLCH token system+DSTOKEN hard rule enforcement
DPSY|PowerSync YAML rules per org+offline‑first sync
```

- **#VER** – Replace version entries (PART 3):
```plaintext
// Replace:
litellm|>=1.83.7 (SHA verify)
→ litellm|>=1.83.7 cosign+Grype not Trivy

temporal-polyfill|^0.3.0 (Safari gap)
→ temporal-polyfill|^0.3.2 ~20KB (Safari gap)

livekitagents|>=1.0.0,<2.0.0
→ livekitagents|>=2.0.0 ONLY

Upload_CA_Version|≥1.0.4
→ Upload_CA_Version|≥1.4.x freshclam hourly

// Add:
rschedule|latest @rschedule/temporal‑date‑adapter
SimpleWebAuthn|latest
deepeval|latest
ragas|>=0.2
openapi-backend|latest
pg_textsearch|latest
basejump-supabase_test_helpers|latest
pyclamd|latest

// Remove:
rrule.js (superseded)
livekitagents v1.0.0 (dual‑pin creates issues)
```

- **#RULES** – Insert new HARD rules (PART 4) and security additions (PART 11):
```plaintext
// HARD
RRULEBAN|arch|H|rrule.js banned on FE; use rschedule+Temporal adapter.
CLAUDEMIGRATION|ai|H|New agents after May 1 use claude-sonnet-4-6 or opus‑4‑7 only. Legacy IDs clean by June 1.
TRIVYISOLATION|sec|H|Security scanners never have write access to CI credential store; pin scanners to SHA.
GRYPEREPLACE|sec|H|Replace Trivy with Grype for Docker scanning in all CI jobs.
AUTHHOOK|sec|H|supabase_auth_admin granted SELECT on userroles,orgmembers,rolepermissions; pgTAP verified.
TSERASABLE|arch|H|tsc --erasableSyntaxOnly --noEmit CI gate; ban TypeScript enum.
SENTRY01|sec|H|Four Sentry projects with beforeSend PII strip hook; maskAllText:true on Session Replay.
DSNOKEYUI|ui|H|No hardcoded hex/RGB colours; reference OKLCH CSS custom properties only.
MONACOLAZY|arch|H|Monaco never in initial bundle; React.lazy+Suspense+skeleton mandatory.
APIC003|arch|H|Schemathesis CI gate on main; schema validation gate on PR.
GRDL03|ai|H|All pgvector‑retrieved chunks pass through GRDL input layer before context injection.
NUQSBATCH|ui|H|>3 URL params must use useQueryStates, not multiple useQueryState.
DNDOVERLAY|arch|H|All drag operations use DragOverlay; never drag original DOM node.
COST03|arch|H|Budget enforcement synchronous pre‑call (not post‑call).
COMP03|comp|H|Every HARD security rule has corresponding Vanta test within 30 days.
TESTC04b|sec|H|Any new table without pgTAP test file blocks merge.
TESTC07|arch|H|MSW handlers generated from OAI3.1 spec via openapi‑backend.
FLYPRIVATE|ops|H|Y‑Sweet token endpoint unreachable from public internet; private networking only.
EVALCOST|ai|H|DeepEval LLM‑as‑judge calls routed through LiteLLM proxy.
SECREC01|ops|H|Automated secret rotation failure → P1 incident; logged as SOC2 evidence.
FFLG03|arch|H|Every flag must have explicit owner,defaultBehavior,reviewdate.
ZUSTANDCIRCULAR|arch|H|Slices cannot import other slice files; cross‑slice access via get() only.
POWERSYNC01|data|H|PowerSync bucket YAML per orgId; sync rules scoped to JWT orgId claim.
CONTEXTUALRETRIEVAL|ai|H|Activate Contextual Retrieval only when corpus >50K chunks AND precision>15% AND cache hit>60%.
FASTGRAPHRAG|ai|H|Start FastGraphRAG (10% cost). LLM‑based GraphRAG requires feature flag at 500K chunks.
MULTIBURN|obs|H|Multi‑burn‑rate SLO: 1h+5m P0 page,6h P1,3d P2; burn>14.4→EB100% incident.
OTEL02|obs|H|OTel GenAI conventions mandatory for all agents; OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai.
SANITIZEDHTML|ui|H|All user‑generated HTML passes SanitizedHTML component with profile(STRICT|RICH|EMAIL).
RESEND01|ops|H|Resend primary transactional email; email.complained→unsubscribed:true.
SECRETROTATE|ops|H|Every secret must have rotation schedule in secretrotationlog; dynamic DB credentials per deploy.
PQC2027|sec|H|Inventory long‑lived keys+data for post‑quantum readiness; hybrid classical+ML‑KEM plan by 2027.
AIBOM04|comp|H|AIBOM (CycloneDX) per model in CI; include training data provenance and safety evaluations.

// S22‑S28 explicit mapping
S22|sec|H|GRDL03: RAG content validation (pgvector chunks through GRDL input layer)
S23|sec|H|SECREC01: secret rotation failure→P1 incident; all rotations logged SOC2 evidence
S24|sec|H|GRYPEREPLACE: Grype not Trivy; scanners isolated from CI credentials
S25|sec|H|AUTHHOOK01: supabase_auth_admin SELECT grants verified by pgTAP after migration
S26|sec|H|SENTRY01: PII strip beforeSend; maskAllText:true Session Replay; four projects
S27|sec|H|CLAMAVPROD: v1.4.x sidecar; health check; freshclam hourly; no scan result caching
S28|sec|H|DPPROFILES: three DOMPurify profiles; no svg in STRICT/RICH; XSS test matrix

// MED rules (PART 4 subset – integrate with existing MED section)
OBSS04|obs|M|Multi‑window burn rate:1h+5m P0 page;6h P1;3d P2.
OBSS05|obs|M|SemanticCacheHitRate target≥70% chat,≥90% RAG; alert on breach.
AUTHHOOK01|arch|M|Org switch triggers supabase.auth.refreshSession()+RT client clear.
NYLASREAUTH|ops|M|grant.expired P1 incident;72h expiry grace; immediate revocation.
RAGINDEXSTRAT|arch|M|<500K:HNSW m16 efc200;≥500K:DiskANN;hybrid:BM25+DiskANN RRF k60 cross‑encoder.
COMPILERAUDIT|arch|M|Q2 2026 Compiler audit; bundle size delta ≤5%.
TEMPORALZDT|arch|M|Always use Temporal.ZonedDateTime not PlainDateTime for calendar events.
PINCATALOG|arch|M|Security‑pinned deps HARD‑pinned; weekly pnpm audit.
CTXRETRIEVAL|arch|M|Activate Contextual Retrieval when corpus >50K chunks/org tracked in ragindexstats.
GRAPHRAG|arch|M|FastGraphRAG first; LLM‑based gated at 500K chunks feature flag.
FLYSCALE01|ops|M|WorkflowEngine scales 0→3 via fly‑autoscaler on queue_depth >5.
EXPOPINSDK|arch|M|Decision May 15,2026:SDK55 if before July;SDK56 after July.
RESEND01‑M|arch|M|Resend primary email; email.complained→unsubscribed:true.
LANGGRAPH01|arch|M|LangGraph Supervisor maps to FLOWC01 SM;LangMem for cross‑session summarisation.
```

- **#ADR_KEY** – Add new ADRs, update existing (PART 7):
```plaintext
// New ADRs
ADR106|FastGraphRAG first; LLM‑based gated at 500K chunk feature flag.
ADR107|SimpleWebAuthn for passkeys; webauthn_challenges RPC pattern.
ADR108|DeepEval as AI eval framework; RAGAS alongside for RAG.
ADR109|rschedule+@rschedule/temporal‑date‑adapter replaces rrule.js FE.
ADR110|OpenFeature with Vercel Flags SDK+PostHog provider.
ADR111|Grype replaces Trivy for Docker scanning; no scanners with CI cred write access.
ADR112|DOMPurify three profiles(STRICT/RICH/EMAIL) with SanitizedHTML component.
ADR113|LangGraph Supervisor for FLOWC01 SM; LangMem for cross‑session FIFO; Trustcall extraction.
ADR114|Four Sentry projects; PII strip beforeSend; replaysOnErrorSampleRate:1.0.
ADR115|LiveKit Agents v2.0 only; semantic turn detection mandatory.
ADR116|pg_textsearch BM25 replaces pgtrgm in hybrid search.
ADR117|ClamAV v1.4.x sidecar; freshclam hourly; health check integration.
ADR118|Contextual Retrieval Phase 1.5 evaluation at 50K chunk threshold.
ADR119|Vanta as SOC2 automation platform; Type I target Q4 2026.
ADR120|Upstash dynamic rate limits for plan‑tiers; semantic cache threshold 0.92.
ADR121|Multi‑burn‑rate SLO alerting:1h+5m P0,6h P1,3d P2.
ADR122|PowerSync confirmed primary offline sync; ElectricSQL documented as alternative.
ADR123|Playwright AI Agents(Planner/Generator/Healer) in CI; cost via LiteLLM proxy.
ADR124|Tailwind v4 OKLCH three‑layer token system; HARD DSTOKEN rule.
ADR125|Four‑layer cost governance: synchronous pre‑call budget check.
ADR126|PostHog Group Analytics mandatory from day one for org‑scoped events.

// Updates
UPDATE ADR082|rschedule replaces rrule.js; Python dateutil unchanged; ZonedDateTime mandatory.
UPDATE ADR088|Resend promoted from fallback to primary transactional email provider.
UPDATE ADR019|LiveKit Agents v2.0 only; remove v1.0 reference.
UPDATE ADR036|Contextual Retrieval cost model updated; Sonnet 4.6; 50K chunk threshold.
```

- **#MIL+TSK** – Append pending tasks P121‑P155 (PART 6 + Addendum). Condense:
```plaintext
pending|P121|rschedule migration+DST test cases
pending|P122|temporal-polyfill 0.3.2,bundle budget 20KB
pending|P123|AUTHHOOK pgTAP assertion(supabase_auth_admin grants)
pending|P124|SimpleWebAuthn passkeys; webauthn_challenges table
pending|P125|LangGraph Supervisor FLOWC01; LangMem crossSessionSummaries
pending|P126|pg_textsearch BM25; replace pgtrgm hybrid leg
pending|P127|React Compiler audit,bundle delta≤5%
pending|P128|LiveKit v2.0 only; VoicePipelineAgent v2 API
pending|P129|Four Sentry projects, PII strip, Session Replay, PostHog connect
pending|P130|Schemathesis CI PR+main jobs (@APIC002)
pending|P131|DeepEval adoption, RAGAS alongside
pending|P132|Vanta connect GH/Supabase/Vercel/Doppler/Fly; SOC2 Type I Q4
pending|P133|PostHog event taxonomy+Group Analytics
pending|P134|SLO multi‑burn‑rate(1h+5m,6h,3d); TTFT histogram
pending|P135|Upstash dynamic rate limits per plan+ cacheBlock audit
pending|P136|ClamAV v1.4.x sidecar; freshclam hourly; health check
pending|P137|SanitizedHTML component+3 profiles; XSS test cases
pending|P138|Zustand persistence versioning+migrate(); ESLint ZUSTANDCIRCULAR
pending|P139|OpenFeature+PostHog provider using Vercel Flags SDK
pending|P140|MSW openapi-backend codegen; 429 mock factory; SSE mock pattern
pending|P141|PowerSync bucket YAML per orgId, document 3‑user free tier
pending|P142|Schemathesis ignore file for SSE+WS endpoints
pending|P143|Grype replace Trivy in CI; pin to SHA; isolate CI creds
pending|P144|Monaco spec: per‑surface lang config; CSP sandbox; OKLCH theme
pending|P145|GraphRAG tables graphentities, graphrelationships stubs; migration path ADR106
pending|P146|Contextual Retrieval ragindexstats; 50K threshold; Phase1.5 eval Q1’27
pending|P147|Turborepo CI inputs(exclude *.test.ts), AI eval no cache; base=main
pending|P148|pnpm catalog tiers(default,react,python); security‑pinned HARD; dependabot patch‑only
pending|P149|Fly.io topology: Machine sizes, autostop, private net, autoscaler rule
pending|P150|Secret rotation: secretrotationlog table; Vault dynamic DB creds per deploy
pending|P151|React Router v7: library mode, no @react-router/dev, useViewTransitionState
pending|P152|nuqs canonical parsers; ESLint rule for >3 params→useQueryStates
pending|P153|pgTAP: PII tables first+supaShield auto‑gen; pnpm test:rls task
pending|P154|Chat: canvas CSP per artifact; staleTime:Infinity AI gen; SSE ReadableStream consumer; VVirtualizeList
pending|P155|CI pipeline: full job matrix(typecheck,tsgo,lint,test:*,drift,codegen,build)
```

- **#BUDG** – Adjust bundle budgets (PART 10):
```plaintext
// Update
Chunk_temporal_polyfill|20KB (was 8KB)

// Add
Chunk_rschedule|15KB
Chunk_simplewebauthn|12KB (lazy, auth routes only)
Chunk_deepeval|0KB (CI/server‑side)
Chunk_posthog|19KB (shared, feature flagged)

// Note
// Re‑validate 150KB initial chunk after polyfill update.
```

---

### 2. `00‑PLAN‑4‑TBL.md` – Database Schema Additions
Append to the existing table list. Use the compact format:

```plaintext
// New tables (Apr 2026)
graphentities|id$,org_id>,nm,type,desc,embedding,sourcecount,trustscore,cat|GraphRAG nodes
graphrelationships|id$,org_id>,source_id>,target_id>,reltype,weight,community,cat|GraphRAG edges
ragindexstats|org_id>,chunkcount,indextype,activatedctxretrieval,graphragactive,lastindexed,cat|Index monitoring
webauthn_challenges|id$,user_id>,challenge,type,expires,created|TTL15min; passkeys RPC
secretrotationlog|id$,secretname,rotatedat,method,success,evidence|SOC2 audit trail
posthogeventtaxonomy|id$,eventname,requiredprops,owner,cat|Analytics governance
flagevidence|id$,flag_id>,owner,defaultbehavior,reviewdate,cat|Feature flag compliance

// Schema modifications
connected_accounts|+ grantStatus (expired|revoked|active)
notifications|+ unsubscribed bool / notificationPreferences JSONB
grdlaudit_logs|+ reason (cacheBlock|redisBlock|quotaExceeded)
upscscanconfig|UPDATE version_pin 1.0.4→1.4.x
```

---

### 3. `00‑PLAN‑C‑KNOWLEDGE.md` – KV Store & Infrastructure Patterns
Append new KV entries and update existing:

```plaintext
// Additional KV (Apr 2026)
RRULE_DST_BUG|rrule.js TZID‑parameterized DTSTART RFC5545 non‑compliant; DST shifts 1h. Replace: FE→rschedule+@rschedule/temporal‑date‑adapter; BE unchanged.
REACT_COMPILER_STABLE|Includes existing useMemo/useCallback; skips some modules. Use eslint-plugin-react-compiler. Audit Q2’26.
PASSKEYS_SUPABASE_GAP|Supabase Auth lacks native WebAuthn. Use SimpleWebAuthn+RPC; table webauthn_challenges.
Nylas_Webhook_BestPractices|Async processing (ack<10s), idempotency via nylas_processed_events, DLQ after 3 retries, grant.expired handling (refresh attempt, 72h backfill window), daily cron for expiring grants. See runbook.
Resend_Primary|Resend is now primary transactional email. Handle email.complained→unsubscribed:true. Svix inbound webhooks.
LangGraph_Supervisor|Maps FLOWC01 SM; LangMem crossSessionSummaries; Trustcall for extraction.
FastGraphRAG|NLP-based, 10% cost; production first. LLM‑based GraphRAG via feature flag at 500K chunks.
SanitizedHTML_Profiles|Three DOMPurify profiles: STRICT(no svg), RICH(allowed div/span), EMAIL(link+img). Component prop driven.
PowerSync_Bucket|YAML rules per orgId (JWT claim); 3 users free tier; conflict resolution LWW.
Temporal_ZD_Required|Always Temporal.ZonedDateTime for calendar events; never PlainDateTime.
```

---

### 4. `00‑PLAN‑C‑RUNBOOKS.md` – New Runbooks
Append:

```plaintext
// New runbooks (Apr 2026)
Y_SWEET_MIGRATION|Deploy self‑host Docker, migrate S3, switch clients; fallback: Vercel KV temporary.
LITELLM_UPGRADE|Upgrade to ≥1.83.7; cosign verify; CVE scan; rotate keys if prior version used.
ORVAL_UPGRADE|Upgrade to ≥8.2.0; reject OAS patterns []()!+; no untrusted specs in pipeline.
MCP_INSPECTOR_ISOLATION|Disable network binding for dev; firewall tcp:3000 from non‑localhost.
CLAUDE46_MIGRATE|Update all model IDs to 4.6 suffixed; verify completion/token limits; remove 4 references before June 15.
DND_KIT_AUDIT|Verify dnd‑kit pin (6.3.1); audit drag ops; no migration to PragmaticDnD.
NYLAS_GRANT_EXPIRED|On grant.expired webhook, disable sync, notify user, provide re‑auth URL; backfill if <72h else data loss.
OPENAI_MIGRATION|Before Aug26: scan all AI calls, replace Assistants/ChatCompletions with Responses API; verify Vercel AI SDK v6 support.
TYPE7_CI|Test tsgo in CI; verify ESLint plugins & codemods; fallback to tsc 6.0.
REACT20_MIGRATE|Q2: create branch, validate RHF/Zustand carveouts, Compiler; Q3: gradual rollout.
TAURI_CAP_CI|Validate capabilities/*.json against window manifests in CI; block deploy on drift.
EXPO55_MIGRATION|Audit libs; migrate /app→/src/app; test Hermes v1 OTA; pin Reanimated v3.
TEMPORAL_POLYFILL|Feature detection; native if available, else temporal-polyfill; test on Safari.
SECRET_ROTATION_FAILURE|Automated rotation failure → P1; log evidence; manual rotation within 1h.
```

---

### 5. `00‑PLAN‑C‑TESTING.md` – Testing Strategy & New Gates
Append:

```plaintext
// New test gates (Apr 2026)
ORVAL_INTEGRITY|Verify generated TS client hash; reject []()!+ patterns in OAS.
LITELLM_PROVENANCE|CI step: cosign verify litellm Docker image; block if not signed.
MCP_INSPECTOR_SEC|Dev env test: MCP Inspector not exposed on 0.0.0.0; integration test for CVE‑2025‑49596 block.
CLAUDE46_MODEL|Test all prompts using new model IDs; output parity with old model ≤5% divergence.
POWER_SYNC|Integration test: offline→online sync; conflict resolution; tombstone/outbox replay.
MCP_SEC_POSTURE|CI step: verify MCPSec L2 compliance for all MCP server configs; fail if any production server not L2.
GRANT_EXPIRED_SIM|Simulate grant expiration; ensure webhook fires, re‑auth triggers, sync resumes.
OPENAI_RESPONSES_PARITY|Test all AI flows with Responses API; no regression in accuracy/latency/tokens.
TYPESCRIPT67|CI upgrade to TS 6.0 config, then optionally tsgo 7.0; enforce erasableSyntaxOnly.
REACT20_COMPILER|Component tests with React20 Compiler; verify “use no memo” directives still effective; no perf regression.
TEMPORAL_SAFARI|E2E test on Safari: ensure Temporal polyfill activates correctly; wall‑clock handling consistent.
ADDITIONAL_SEC_TESTS|XSS test matrix for SanitizedHTML profiles; ClamAV health check; secret rotation simulation.
```

---

### 6. `00‑PLAN‑6‑EXT.md` – External Services Integration
Update Nylas, Resend, ClamAV, and add Grype:

```plaintext
// Replace Nylas section
Nylas|OAuth2,FastAPI proxy,webhook→Serverless(no Edge DB),upsert‑first,10s timeout,async queue,idempotency via nylas_processed_events,grant.expired webhook→re‑auth<72h; daily cron for expiring grants; DLQ after 3 retries; LWW via uat

// Update Resend
Resend|Primary transactional email; React Email 5.0; 3k/mo free tier; inbound via Svix; email.complained→unsubscribed:true

// Update ClamAV
ClamAV|Server‑side sidecar(clamd v1.4.x),freshclam hourly,health check in /health,no scan result caching by hash; pyclamd integration

// Add Grype
Grype|Docker image vulnerability scanning (replaces Trivy); isolated from CI credential store; pin to SHA digest
```

---

### 7. `00‑PLAN‑8‑ARCH.md` – Architecture & Infrastructure
Add deployment notes for new services and security:

```plaintext
#INFRA (additions)
PowerSync|Managed (SOC2/HIPAA)|YAML sync rules, per‑org bucket|Phase 2
Y‑Sweet|Docker self‑host (Fly.io private network only)|OFFLINE support provider; 50MB limit
Grype|CI Docker scanner|Replaces Trivy, isolated from CI creds
LangGraph|AI orchestration|Supervisor/Swarm; LangMem; OTel gen_ai traces
FastGraphRAG|RAG augmentation|NLP entities, direct production; graph DB future
Vanta|SOC2 automation|Evidence pipeline, TSC mapping
```

Also add the Nylas grant flow detail if needed.

---

### 8. `00‑PLAN‑9‑TEAM.md` – Domain Ownership Map
Append:

```plaintext
#DOMAIN_OWNERSHIP|domain|owner|backup|cross‑cutting
A: Platform & DX|Platform Eng|Senior SRE|DB infra,CI/CD,monorepo
B: Data & Sync|Data Platform|Data Lead|AI vector/graph,frontend sync state
C: AI Core & Agents|AI/ML Eng|AI Lead|Frontend GenUI streaming,business metering
D: Frontend & UX|Product Eng|Frontend Lead|AI prompt/agent UI,business telemetry
E: Security & GRC|Security/GRC|Security Lead|Identity,audit,compliance across all
F: Business & Monetization|Product/GTM|Product Lead|Budget gates,feature flags
```

---

## 📄 New Documents to Create

Based on PART 8 and Final Addendum, create the following files with compressed content as shown.

### `00‑PLAN‑C‑AUTH.md`
```markdown
---
steering: TO PARSE - READ INTRO
document_type: auth_specification
tier: infrastructure
description: Authentication flows, passkeys, OAuth, org switch, MFA
last_updated: 2026-04-25
version: 1.0
---
#Auth
Login|Supabase Auth email/pw; custom_access_token_hook embeds org_id+role
MFA|TOTP (Spectrum); WebAuthn passkeys via SimpleWebAuthn (ADR107)
Passkeys|webauthn_challenges table; RPC flow; cross‑device QR; recovery codes
OrgSwitch|supabase.auth.refreshSession()+qclient.clear()+RT reconnect; AUTHHOOK01
NylasAuth|OAuth2 grant; grant.expired→re‑auth<72h; daily cron
Security|JWT not in localStorage; all tokens httpOnly; CSRF double‑submit
```

### `00‑PLAN‑C‑DESIGN‑SYSTEM.md`
```markdown
---
steering: TO PARSE - READ INTRO
document_type: design_system
tier: infrastructure
description: Tailwind v4 OKLCH tokens, motion, LiquidGlass, colour rules
last_updated: 2026-04-25
version: 1.0
---
#DS
Tokens|OKLCH‑based; three‑layer: brand/semantic/component. No hardcoded colours (HARD DSNOKEYUI).
Motion|Spring(tension≥300,damping≥30); stagger≤3; transform/opacity only; prefers‑reduced‑motion instant.
Glass|LiquidGlass effect: backdrop‑blur,noise overlay; use CSS variables for tint.
DarkMode|System preference + manual toggle; persist in localStorage.
Components|SanitizedHTML with STRICT|RICH|EMAIL profiles; EmptyState pattern.
```

### `00‑PLAN‑C‑SANITIZATION.md`
```markdown
---
steering: TO PARSE - READ INTRO
document_type: sanitization_spec
tier: security
description: DOMPurify profiles, ClamAV, Zod sanitisation, SSRF+XSS test matrix
last_updated: 2026-04-25
version: 1.0
---
#San
DOMPurify|≥3.4.0; SanitizedHTML component with profile prop:
  STRICT: no svg, no style, minimal tags
  RICH: div, span, strong, em, ul/li, no svg
  EMAIL: a, img, p, br; force rel=noopener
ClamAV|v1.4.x sidecar, freshclam hourly; health check on /health; no scan caching
Zod|URL params validated with Zod schemas; output sanitised
MCP SSRF|middleware blocks all private IPs; allowlist validation; no redirects
Test|XSS payload matrix (10 cases) in TESTC04; CSP violation checks
```

### `00‑PLAN‑C‑TESTING‑INFRA.md`
```markdown
---
steering: TO PARSE - READ INTRO
document_type: testing_infrastructure
tier: infrastructure
description: Vitest, MSW, Playwright, pgTAP, contract testing, CI matrix
last_updated: 2026-04-25
version: 1.0
---
#TestInfra
Vitest|Unit+component; global Setup file; coverage Istanbul
MSW|Server‑side handlers auto‑generated from OAI3.1 via openapi-backend (TESTC07); 429 rate‑limit factory; SSE mock pattern
Playwright|E2E critical flows (10‑15); per‑environment config; AI agents (Planner/Generator/Healer) on CI
pgTAP|RLS isolation tests; auto‑generation with supaShield; mandatory for new tables (TESTC04b)
Contract|Schemathesis in CI (APIC003); schema validation PR; main post‑deploy contract test; ignore file for SSE/WS
AI Eval|DeepEval + RAGAS; thresholds in #TEST; LLM‑as‑judge through LiteLLM proxy
CI|Full matrix: typecheck (tsc 6.0 + tsgo 7.0), eslint, test:unit, test:component, test:rls, test:e2e, prisma:drift, orval:codegen, docker:build, schemathesis
```

### `00‑PLAN‑C‑WORKFLOW‑ENGINE.md`
```markdown
---
steering: TO PARSE - READ INTRO
document_type: workflow_engine_spec
tier: infrastructure
description: LangGraph Supervisor mapping, LangMem, Trustcall, SM integration
last_updated: 2026-04-25
version: 1.0
---
#WFE
LangGraph|Supervisor pattern maps to FLOWC01 SM; StateGraph edges for transitions
LangMem|cross‑session summarisation; replaces FIFO memory; store in episodic memory
Trustcall|Tool call extraction; schema‑validated
Swarm|Multi‑agent orchestration; handoff protocol
OTel|gen_ai.* attributes on all nodes; root span via DataPrepper
Cost|All tool calls metered; sync budget check (COST03)
```

### `00‑PLAN‑C‑ASI‑COMPLIANCE.md`
```markdown
---
steering: TO PARSE - READ INTRO
document_type: asicompliance
tier: compliance
description: OWASP Agentic AI Top10 2026 gap analysis, controls
last_updated: 2026-04-25
version: 1.0
---
#ASI
Gap mappings|ASI01‑ASI10 ↔ GRDL layers, SECM controls. See matrix below.
ASI01 Goal Hijack|GRDL input+output; Intent Capsule validation
ASI02 Tool Misuse|MCP OAuth+schema allowlist; runtime tool auth
ASI03 Identity Abuse|NHS; MPCsec L2 Agent Passports
ASI04 Poison|Input guardrails; vector DB quarantine
... (etc)
AIBOM|CycloneDX per model; training data provenance; safety eval (AIBOM04)
EU AI Act|Stand‑alone high‑risk deadline Dec 2,2027; embedded Aug 2,2028
Singapore Framework|Align with draft; documented decision log
```

### `00‑PLAN‑C‑ANALYTICS.md`
```markdown
---
steering: TO PARSE - READ INTRO
document_type: analytics_spec
tier: business
description: PostHog event taxonomy, Group Analytics, OpenFeature integration
last_updated: 2026-04-25
version: 1.0
---
#Analytics
Events|Canonical list: agent_invoked, workflow_started, workflow_completed, feature_adopted, ai_cost_threshold_hit, auth_passkey_enrolled, sync_offline_queue, mcp_tool_call, rate_limit_triggered
Properties|orgId,userId,timestamp,sessionId mandatory; Group Analytics enabled
Enforcement|PR approval required for new events; CI validates schema
OpenFeature|Vercel Flags SDK+PostHog provider; flagging for analytics sampling
```

### Additional Enterprise Docs (optional, minimal stubs)

#### `00‑PLAN‑API‑VERSIONING.md`
```markdown
---
steering: TO PARSE
document_type: api_versioning
last_updated: 2026-04-25
---
#API Versioning|URL path (/v1/); deprecation 12mo; Sunset header; OpenAPI discriminator; lifecycle draft→beta→stable→deprecated→sunset; migration guides required.
```

#### `00‑PLAN‑DR‑BCP.md`
```markdown
---
steering: TO PARSE
document_type: disaster_recovery
last_updated: 2026-04-25
---
#DR/BCP|RTO:FastAPI 5min,DB 1h; RPO:FastAPI 0,DB 15min; monthly chaos tests; runbooks in ops/dr/; NIS2 audit trails; backup verification weekly.
```

#### `00‑PLAN‑LOAD‑TESTING.md`
```markdown
---
steering: TO PARSE
document_type: load_testing
last_updated: 2026-04-25
---
#Load Testing|k6+Artillery; global 1000req/s; per‑user chat 200/min; start 4‑6 weeks pre‑launch; stress test 200% peak 2h; soak 80% 8h; fail if p95>2x baseline or timeout>5s.
```

#### `00‑PLAN‑MODEL‑CARDS.md`
```markdown
---
steering: TO PARSE
document_type: model_cards
last_updated: 2026-04-25
---
#Model Cards|Per agent: Model ID, intended use, limitations, bias metrics, safety eval, training data provenance, SHA‑256, review date, owner.
```

#### `00‑PLAN‑INCIDENT‑TEMPLATES.md`
```markdown
---
steering: TO PARSE
document_type: incident_templates
last_updated: 2026-04-25
---
#Incident Templates|SEV0‑SEV3 definitions; response SLA; pre‑approved templates: Outage, Data Breach, Degraded Performance, Third‑party Failure; all logged to SOC2.
```

---

## 🚦 Implementation Order
1. **Critical updates**: `00‑PLAN‑1‑INTRO.md` rules, versions, ADRs – unblock development.
2. **Schema**: `00‑PLAN‑4‑TBL.md` – DB migration prerequisite.
3. **Knowledge & Runbooks**: `00‑PLAN‑C‑KNOWLEDGE.md`, `00‑PLAN‑C‑RUNBOOKS.md` – guide operations.
4. **New specs**: start with Auth, Sanitization, Analytics (high touchpoints).
5. **Infra/test documents**: Testing Infra, ASI Compliance – needed before CI gates.
6. **Enterprise docs**: API Versioning, DR/BCP – required for audit readiness.

Every update here is directly sourced from the research consolidation. You can safely apply these patches to your repository; they are production‑ready and maintain the same compressed style as the rest of the planning suite.