# KV - Knowledge Base

// BACKEND
JWT_BRIDGE=JWKS 1h cache; SET LOCAL claims org_id+user_role; custom_access_token_hook for RBAC
ERR_ENV={error:{code,message,retryAfter}}
RATE=FastAPI-Limiter+Upstash Redis,per-user/org,429 retry-after
CORS=allow-list localhost:8000,prod; credentials true
HEALTH=GET /health→{status,version,db,redis,litellm}
SSRF=block 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,127.0.0.0/8,169.254.0.0/16; no redirects; IMDSv2
DOMPURIFY=≥3.4,SanitizedHTML,ALLOWED_TAGS whitelist,FORBID script/style/iframe/object/embed/svg/math,SANITIZE_DOM true

// SECURITY
Encryption|SB AES-256 at rest; PII encrypted at app layer(Vault keys); JWT signed+verified; httpOnly cookie
RBAC|user_roles+role_permissions; 5-role(Owner/Admin/Member/Viewer/External); authorize() fn; JWT hook
AuditLog|immutable append-only audit_logs; Prisma middleware+CDC; queryable admin; MCP/guardrail/privacy logged
Pentesting|annual Bugcrowd; quarterly SAST/DAST(Snyk,ZAP) in CI; MCP CVE scan(CVE-2025-49596,66416)
Pentesting_Scope|Bugcrowd scope types: Limited(specific targets), Wide(wildcard subdomains), Open(no limitations). Targets: web apps, mobile apps, IoT, APIs. Out-of-scope: DDoS, phishing, social engineering, physical attacks. Best practice: progress limited→wide→open over time
Pentesting_Schedule|Annual frequency is industry standard baseline. PCI DSS Requirement 11.3: annual penetration testing plus after significant changes. ISO 27001: recommended annually (not mandatory). NIST SP 800-115/FISMA: periodic testing "no less than annually" (Section 3544). FedRAMP: annual as part of continuous monitoring. Additional testing required after: new systems, major upgrades, network topology changes
SAST_DAST_Accuracy|Snyk Code SAST: 85% accuracy with 8% false positive rate (SAST Tool Evaluation Study 2024, sanj.dev); EASE 2024 academic benchmark: 11.2% detection rate (lowest of 4 tools) against 170 real-world Java vulnerabilities; G2 false positive score 6.8/10 (notably low). Snyk DAST (API/Web): claims 0.08% false positive rate (vendor marketing). OWASP ZAP DAST: 100% detection in WebGoat (Academia.edu 2024); open-source DAST scanners show 35-40% false positive rates; Skipfish outperforms ZAP with Youden index 0.7 (DVWA) vs 0.6 (WebGoat). Quarterly frequency is acceptable baseline but monthly preferred for critical systems (Indusface, Secureframe best practices). Note: SAST tools structurally miss business logic vulnerabilities (broken access control, auth flaws).
Remediation_SLA|CVSS-based SLA tiers: Critical(9.0+) 14 days (24-72h if actively exploited), High(7.0-8.9) 30 days, Medium(4.0-6.9) 60 days, Low(0.1-3.9) 90 days. Asset criticality tightens timelines. 85% compliance rate realistic for human teams. Threat intelligence(CISA KEV, Mandiant) reclassifies to reduce critical volume
Scan_Frequency|TASK INFORMATION INCORRECT: Quarterly is NOT sufficient for HIPAA compliance as of 2026. PCI DSS 4.0: external vulnerability scans quarterly by ASV, annual external/internal penetration testing (ACCURATE). HIPAA 2026: OCR shifted vulnerability scanning from recommendation to MANDATORY, minimum TWO comprehensive scans per year (biannual), not quarterly. Non-compliance penalties: $100 to $50,000 per violation. ISO 27001: recommended annually (not mandatory), risk-based frequency (ACCURATE). SOC 2: depends on control design (continuous/weekly/monthly/quarterly), annual risk assessments minimum (ACCURATE). CIS Control 7 (not 16): Control 7.5 (internal assets) requires quarterly or more frequent scans; Control 7.6 (externally-exposed assets) requires monthly or more frequent scans. Higher-risk environments: monthly or weekly scanning recommended. Trend toward per-release gates for faster remediation. Secureframe best practice: "as often as possible" - monthly, quarterly, or annually.
CI_Performance|GitHub Actions scanner performance benchmarks (arXiv 2026): semgrep 11.7-34.65s (highly variable due to dynamic elements like shell commands, secret references, conditionals), ggshield variable (layered secret detection with entropy analysis), frizbee slightly longer (commit SHA/image digest resolution), scharf max 0.05s (fastest pinning), pinny max 0.09s, actionlint 0.39s (YAML syntax/structure), poutine 0.46s (security-sensitive config), scorecard 1.37s (repository-wide evaluation), zizmor 0.23s (workflow triggers/contexts). Grype: optimized database queries for faster vulnerability matching, reduced memory consumption for large container images, zero-dependency architecture for CI/CD. Trivy vs Grype: Grype slightly faster for pure vulnerability scanning, Trivy all-in-one (vulnerabilities, misconfigurations, secrets, licenses, SBOM). Optimization strategies: Parallel scanning (independent scans run simultaneously), caching results for unchanged code, incremental scanning (only modified files/modules), progressive security by branch (feature: fast non-blocking, release: full scans with some blocking, production: strict gates on critical/high-risk), centralized vulnerability database to normalize findings and group related issues, reduce duplicate noise (one ticket per vulnerable library vs three from different scanners).
MCP_CVEs|CVE-2025-49596 (CVSS 9.4-9.8): Remote Code Execution in Anthropic's MCP Inspector. Attack Vector: CSRF in MCP-Inspector leads to RCE via 0.0.0.0 binding. Malicious website can craft requests to MCP inspector from public domain Javascript context, triggering arbitrary commands via /sse endpoint with stdio transport (command query parameter). Affected Versions: Prior to 0.14.1 (Oligo research) / 1.2.3 (security site). Discovery: January 2025 (reported Jan 10, patched Jan 15). Timeline: Oligo reported April 18, 2025; another researcher reported March 26, 2025; published June 13, 2025. Impact: Complete system takeover, data exfiltration, lateral movement, supply chain risk (compromise of development environments). Exploitation: Requires user interaction (user must inspect malicious server), but 0.0.0.0 Day vulnerability in Chromium/Firefox enables attacks even when binding to localhost. Internet-facing MCP Inspector instances identified as actively exposed. Fix: Version 0.14.1 added session token by default (similar to Jupyter notebooks) and allowed origins verification to mitigate browser attack vectors completely. CVE-2025-66416 (CWE-1188): DNS Rebinding Protection Disabled by Default in MCP Python SDK. Attack Vector: Malicious website exploits DNS rebinding to bypass same-origin policy and send requests to local MCP server. Conditions: HTTP-based server on localhost without authentication, using FastMCP with streamable HTTP or SSE transport, no TransportSecuritySettings configured. Impact: Invoke tools or access resources exposed by MCP server on behalf of user. Affected Versions: mcp Python SDK prior to v1.23.0. Does not affect servers using stdio transport. Fix: Version 1.23.0 enables DNS rebinding protection by default when host parameter is 127.0.0.1 or localhost. Users with custom low-level server configurations (StreamableHTTPSessionManager, SseServerTransport) must explicitly configure TransportSecuritySettings. CVE-2025-6514 (CVSS 9.6): Critical RCE in mcp-remote project used by MCP clients. Additional CVEs: CVE-2026-22252 (LibreChat), CVE-2026-22688 (WeKnora), CVE-2025-54994 (create-mcp-server-stdio), CVE-2025-54136 (Cursor) - all based on same core architectural issue (CSRF/RCE via 0.0.0.0 binding). OX Security disclosure April 15, 2026: 7K exposed servers, 150M+ downloads, 10 CVEs. Microsoft December 2025 Patch Tuesday addressed CVE-2025-62221 (MCP-related).
Patching|MCP SDKs across Python, TypeScript, Java, Rust have had security patches throughout 2025. Vulnerable MCP Project (vulnerablemcp.info) tracks comprehensive MCP vulnerability database. Patching patterns: version-based security updates, dependency pinning required (e.g., MCP Inspector >=0.14.1, MCP Python SDK >=1.23.0, mcp-remote updated for CVE-2025-6514). Regular dependency updates and security monitoring essential. MCPSec L2 mandatory for production per MCP_SEC_CRISIS (April 15, 2026). Automation: GitHub Actions Dependabot for automated PRs, Renovate for advanced scheduling, security advisories monitoring via GitHub Dependabot alerts. Patching workflow: 1) Monitor Vulnerable MCP Project and GitHub Security Advisories, 2) Evaluate CVSS severity and affected components, 3) Test patches in staging environment, 4) Roll out via CI/CD with automated rollback, 5) Verify patch effectiveness via security scanning. CI integration: Automated dependency pinning in package.json (exact versions for MCP-related packages), security gate blocking deployment if vulnerable MCP packages detected, post-deployment validation via MCP-specific security scanning (MCPTox, MindGuard). Supply chain controls: SCA scanning on all MCP servers before deployment, cryptographic verification of server integrity (digital signatures), package scanning for malware and hidden malicious instructions, pin specific MCP server versions and alert on changes. Governance: Centralized MCP gateway architecture as single control point, approval workflows for new server deployments, regular security reviews of tool access patterns, audit logging integrated with SIEM platforms.
GDPR|cascade-delete pipeline+audit; anonymize logs; SSE progress export; training opt-out per CNIL
GDPR_TRAINING_OPTOUT|TASK INFORMATION INCORRECT: No specific CNIL guidance exists on "training opt-out" requirements for GDPR/data protection training. Research findings: (1) GDPR training is effectively mandatory through interlocking provisions (Article 39 requires DPO to deliver awareness-raising and training; Article 32 requires appropriate organizational measures including training; Article 24 requires implementing necessary measures including staff training). (2) French labor law allows employees to refuse training only with legitimate motives (health issues, conflict with approved leave, procedural violations by employer, discriminatory use, training unrelated to job functions). (3) CNIL provides certification standards for data protection training programs (33 mandatory requirements, 44 optional) but no opt-out guidance. (4) No evidence of CNIL-specific opt-out requirements for data protection training. The "training opt-out per CNIL" reference appears to be incorrect. Updated documentation to reflect accurate information.
SOC2|VT continuous; aim TypeII 12mo; HARD rule→SOC2 TSC→evidence artifact mapping
SOC2_TIMELINE|First-time audit: 12 months total (prep 2-9mo + audit 1-3mo + reporting period 6-12mo); Type II reporting period typically 6-12 months (minimum 3mo for urgent needs, 6mo recommended by AICPA); renewal audits faster due to established controls; readiness phase 2-5 months for first-time, less for experienced organizations
SOC2_AUDITOR_SELECTION|CPA firm required with AICPA attestation standards and SSAE 18 compliance; selection criteria: industry experience (SaaS/cloud/healthcare/fintech), methodology rigor (sampling, evidence collection), communication style (responsiveness, project management), pricing (fixed vs variable, $5K-$15K readiness, $10K-$30K Type I, $25K-$70K+ Type II); enterprise buyers prefer Big 4 or large regional firms for trust; costs increase with additional TSC and systems audited
RLS|ENABLE+FORCE RLS,org_id via JWT; PB automated; drift detection blocks deploys
MCPG|zero-trust: OAuth tool auth,schema allowlist,elicitation high-risk,policy eval deterministic,SSRF,sandbox,CI TrustKit
Passkeys|SB Auth MFA; cross-device QR; platform sync(iCloud/Google); recovery codes; phishing-resistant

// PASSKEY FLOW
PASSKEY_QR_FLOW|Cross-device QR code authentication flow (hybrid transport): 1) User initiates authentication on device without passkey, 2) Server generates unique time-sensitive session identifier, 3) QR code encodes FIDO URI with CBOR-encoded handshake and ephemeral secrets, 4) User scans QR code with device containing passkey, 5) Scanned device communicates with server via FIDO URI, 6) Server generates cryptographic challenge, 7) Challenge sent to user's device with passkey, 8) Device creates digital signature using private key (never leaves device), 9) Signed challenge sent via encrypted internet tunnel, 10) Server validates signature using public key, 11) Authentication confirmed. Security: One-time use session ID, CBOR-encoded ephemeral handshake, Bluetooth proximity check (not data exchange), Private keys never leave device, No sensitive data exposure, Asymmetric cryptography challenge-response. Complexity: Medium - requires QR code generation, FIDO URI handling, cryptographic challenge-response, encrypted tunnel, signature verification

// AI
MemArch|3-tier: Working(Zustand),Episodic(messages+pgvector,FIFO50,Ebbinghaus decay),Semantic(pgvector+facts,promotion)
EvalCI|Vitest+custom; gate: acc≥base-2%,lat≤base+10%,tok≤base+15%,tool≥90%,halluc≤2%
CtxWindow|LLM token counter+@CACHE; prefix caching static-first; RocketKV long contexts
SafetyGuard|Guardrails-AI+Pydantic; 3-layer: Input(PII/jailbreak/tox),Output(halluc/safety/schema),Runtime(tool/cost); all logged
CostAttrib|x-litellm-tags: org_id,user_id,feature; ai_cost_log TS hypertable; 15/5/0% alerts; 429 hard stop
PromptCache|Anthropic cache_control+OAI auto-prefix; monitor hit>70%chat/>90%RAG; static-first structure
Observability|OTel1.40 GenAI; DataPrepper root span prop; attrs: gen_ai.system/model/input_tokens/output_tokens/finish_reason/cost.usd; PII redact
Privacy|allow_training org flag; data segregation opted-out; ODP differential privacy(ε configurable); TEE for sensitive; annual PIA

// DATA
Redis|Upstash; rate limiting; semantic cache AI; hot settings; prefix caching; flag cohorts; IC storage
TimeSeries|TS hypertables: transactions,ai_cost_log,slo_metrics; continuous aggregates; cost forecast
ObjectStorage|SB Storage+S3 versioning; weekly sync; PITR manual sync; Yjs snapshot storage
VectorSearch|pgvector HNSW(m=16,ef_c=200,ef_s=40),pg_trgm,hybrid RRF(k=60)+cross-encoder rerank; RLS at DB
OfflineStore|IndexedDB outbox; tombstone(deleted_at nullable int ms); ULID; IC=actor_id+monotonic; LWW via uat
RealtimeChannels|SB Broadcast(ephemeral,256KB-3MB) vs PgChanges(durable WAL,1MB); org:{orgId}:{table}; mem alert@40MB; 100ch platform,20 self

// INFRA
Terraform|Vercel,Fly.io,SB,Upstash; state TF Cloud; PITR mgmt; SOC2 evidence pipeline
Docker|supabase start+FastAPI,Redis,minio; hot-reload; MCP sandbox; CA clamd daemon
Secrets|Doppler/Vault; no .env in images; JWT keys+ST keys+MCP OAuth secrets in Vault
ObsStack|Sentry,PostHog,OTel; Fly.io→Loki; metrics: AI tokens,cache hit,SLO BR; OTel1.40 GenAI
CI|GH Actions,pnpm,turbo; affected-only; remote cache; SC; PB RLS; AI eval gate
PrismaMig|EBC; migrate deploy prod; drift check CI; RLS versioning; 6-step ZDT rename

// BACKEND CORE
FastAPI_Proj|app/main.py,routers/v1/*,services/*,dependencies.py,middleware/*; A2A,Saga,RAG,Cost,MCP,SSRF,Privacy
ServiceRepo|Route→Service→Repository(Prisma); DI FastAPI deps; compensation queue+DLQ; webhook async queue
WorkflowEngine|topo sort,SM; parallel,exp backoff,compensation,ICs; DLQ after 3 retries
RAG|LangChain,pgvector,EdgeFns; ingest→chunk(512tok,64overlap)→embed→HNSW→hybrid RRF→rerank→cache; RLS at DB
A2A|google-A2A; Agent Card discovery,task SM,SSE streaming,artifact handling; Agent Registry
MCP|policy eval(allow/deny/approve); OAuth auth; schema allowlist; elicitation; SSRF; sandbox; CI TrustKit; audit

// CLIENT
Tauri|v2; GH Actions build; Mac signing+notarization; auto-update tauri-plugin-updater; Capabilities per window; dep chain audit(Rust+npm)
Expo|SDK53/54; EAS Build; OTA critical-fixes only; native secrets EAS; CI on tag; expo-notifications dev build req Android; deep link matrix
DesignSystem|Tailwind v4 @theme; OKLCH tokens; 4px grid; motion tokens; useShouldAnimate; EmptyState required; skeleton<2s,spinner>2s
A11y|WCAG2.2 AA; contrast checks; reduced motion; kbd nav(Tab/Enter/Escape/Arrows all interactive); canvas alt; aria-live

// REPO
Monorepo|pnpm catalogs,Turborepo; strict: packages/ui no import from features; spec validation CI gate
Codegen|OR openapi-codegen,SB gen types; pnpm codegen→packages/types/api+database; MSW; SC tests
QueryClient|staleTime5min,retry2,noRefocus,429→RL,useSSE

// OPS
IncidentComm|Better Stack,PagerDuty; auto status page on health fail; on-call escalation
FeedbackLoop|thumbs on AI→eval_datasets; automated sampling
Billing|ST webhook(verified HMAC); idempotency processed_stripe_events; handle invoice.paid,subscription.updated; ST Portal; MeteredAI via ai_cost_log; LicenseGate 402+CTA

// Additional Knowledge (Apr 2026)
// Y-SWEET SELF-HOST
Y_SWEET_SELFHOST|Jamsocket shut March 2026; Y-Sweet must be self-hosted (Docker); offlineSupport provider; S3 persistence; monitor fork activity
// OFFLINE STRATEGY
OFFLINE_SYNC|MVP: tombstone+ULID+IC outbox; Phase 2: PowerSync bidirectional (SQLite/Postgres), SOC2/HIPAA, sync rules YAML; cr-sqlite unmaintained, Replicache maintenance mode
// DND STATUS
DND_STATUS|dnd-kit is community standard (18.9M/mo); PragmaticDnD is Atlassian-internal (~180K/wk); NO migration between them
// REACT COMPILER CAVEATS
COMPILER_CAVEATS|RHF: "use no memo" directive required; Zustand persist: conditional rendering not Suspense; Zustand core: compatible
// AI GATEWAY
AI_GATEWAY|Vercel AI SDK v6: provider routing, fallback chains, tool calling, structured output, streaming; wraps LiteLLM proxy; separate cost tracking
// MODEL TIERING
MODEL_TIERING|Default: claude-sonnet-4-6-20250324; Complex: claude-opus-4-6-20250324; Never agentic: claude-haiku-4-5 (no injection guard); Migrate before June 15, 2026
RSCHEDULE|TASK INFORMATION: Library appears unmaintained. Last commit: July 19, 2023 (almost 3 years old as of April 2026). Last version: v1.5.0 (February 3, 2023). 575 commits total but development stopped in 2023. GitLab is canonical repo, GitHub is mirror. Features: date-agnostic (works with Date, Moment, luxon, dayjs, js-joda), immutable objects, ICAL RFC 5545 support, JSON serialization, modular/tree-shakable. Consider alternative: rrule or custom implementation with Temporal API when browser support improves.
PATTERN_MATCHING|TASK INFORMATION INCORRECT: Pattern matching (match/using syntax) is TC39 Stage 1 proposal, NOT part of ES2026. Approved for Stage 1 in May 2018, still in early development. No polyfill available. Syntax uses `match` expression and `is` operator, not `using`. Champions: Daniel Rosenwasser (Microsoft), Jack Works (Sujitech), Jordan Harband (HeroDevs), Mark Cohen, Ross Kirsling (Sony), Tab Atkins-Bittner (Google). Do NOT plan for ES2026 adoption - not ready for production.

// NYLAS WEBHOOK RELIABILITY
WEBHOOK_RELIABILITY|Nylas two-tier failure model: Failing state (95% non-200 responses over 15min, continues delivery for 72h with exponential backoff, email notification sent), Failed state (95% non-200 over 72h, manual reactivation required via Dashboard/API, events missed during failed state lost unless manually retrieved). 95% threshold validated from official Nylas docs - more conservative than industry standard (50% circuit breaker threshold) to reduce false positives from transient failures. Add @nylas.com to email allowlist to prevent spam folder delivery. Industry comparison: Hookdeck suggests 50% failure rate over 1-minute window or 5 of 10 requests failed for circuit breakers. Nylas design choice prioritizes avoiding false positives over rapid failure detection.

// NYLAS BACKFILL STRATEGY
BACKFILL_STRATEGY|72-hour backfill window: If grant out of service <72h, Nylas sends backfill notifications for changes during outage. If grant out of service >72h, Nylas does NOT send backfill notifications. For >72h outages: Query Nylas APIs for objects that changed between grant.expired and grant.updated timestamps. Critical limitation: Message tracking events (message.opened, message.link_clicked, thread.replied) cannot be backfilled if grant was out of service >72 hours - these events are permanently lost and must be accepted as data gap. Support cannot replay webhooks - manual API retrieval is the only recovery mechanism. 72-hour window is a hard limit set by Nylas infrastructure, not configurable.
// LITELLM SECURITY
LITELLM_SEC|Supply chain attack March 24,2026 (v1.82.7-1.82.8), TeamPCP; pin >=1.83.7 with cosign SHA verification; CVE-2026-35029 (RCE), CVE-2026-35030 (auth bypass)
// ORVAL SECURITY
ORVAL_SEC|CVE-2026-24132,CVE-2026-23947,CVE-2026-25141 (JSFuck bypass) CVSS9.8; upgrade >=8.2.0; never run on untrusted OAS; reject patterns []()!+;
// MCP INSPECTOR SEC
MCP_INSPECTOR_SEC|CVE-2025-49596 CVSS9.4; pin devDep >=0.14.1; firewall dev network access
// MCP SECURITY CRISIS
MCP_SEC_CRISIS|April15,2026 OX Security disclosure: 7K exposed servers, 150M+ downloads, 10 CVEs; MCPSec L2 mandatory for prod
// MCPSec
MCPSEC|IETF draft: Agent Passports (ECDSA P-256), per-message signing, tool definition integrity, nonce+timestamp replay protection, trust levels L0-L4; backward-compatible envelope; median latency 8.3ms; reduces attack success 52.8%→12.4%
// OPENAI RESPONSES
OPENAI_RESPONSES|Assistants API + Chat Completions deprecated Aug26,2026; Responses API: server-side context compaction, hosted shell containers (Python/Node/Ruby with storage), reusable Skills, agentic execution loop; Vercel AI SDK v6 gateway support
// Nylas grant.expired
NYLAS_GRANT_EXP|When grant expires, all webhooks stop. Re-auth <72h → backfill; >72h → permanent data loss. Handle grant.expired webhook immediately.
// VERCEL EDGE
VERCEL_EDGE_NO_DB|Edge Functions run V8 isolates, no Node.js runtime, no direct TCP DB connections. Use Neon serverless driver (HTTP), Vercel Serverless (300s), or FastAPI proxy.
// REACT 20
REACT20|GA March 2026. Compiler built-in default, no opt-in. useMemo/useCallback/React.memo deprecated. "use no memo" still needed for RHF, Zustand persist. Concurrent Rendering 2.0
// TYPESCRIPT CASCADE
TYPESCRIPT_67|TS6.0 (March 23,2026): final JS release; erasableSyntaxOnly, isolatedDeclarations, strict defaults. TS7.0 Beta (April 2026): Go-native (tsgo) ~10x faster; CI-ready now.
// PRISMA NEXT
PRISMA_NEXT|TypeScript-native ORM, Postgres GA June-July 2026, schema in TS, pgvector extension, 12-month Prisma7 LTS; Phase 3 evaluation.
// OWASP AGENTIC
OWASP_ASI2026|Agentic Top10: ASI01 Goal Hijack, ASI02 Tool Misuse, ASI03 Identity Abuse, etc. Map to GRDL layers, SECM controls.
// PGVECTORSCALE
PGVECTORSCALE|0.4.0 DiskANN; 50M vectors: 471 QPS, 28ms p95, 11.4x Qdrant, 28x Pinecone latency, 75% cheaper. Threshold reduced to 500K vectors.
// ES2026
ES2026_MATCH|match expression (declarative pattern matching), using keyword (resource cleanup), Promise.try, Error.isError, Math.sumPrecise, Uint8Array base64/hex, Iterator helpers.
// TEMPORAL
TEMPORAL_SAFARI|Stage4 ES2026 (March 2026), Chrome144+, Firefox139+, Safari not yet. Polyfill mandatory (temporal-polyfill). Conditional import. Bundle impact 8KB.
// A2A V1
A2A_V1|Google Agent-to-Agent v1.0, Linux Foundation, 150+ organizations production. Stable .proto, three-layer architecture.
// DOMPURIFY CVES
DOMPURIFY_CVES|>=3.4.0 mitigates: CVE-2025-15599, CVE-2026-0540, CVE-2026-41238, CVE-2026-41240, CVE-2025-25141
// PRISMA SAVEPOINTS
PRISMA_SAVEPOINT|v7.8.0+ nested transaction savepoints; Saga rollback via savepoint release
// REACT ROUTER V7
RRV7|Imports from react-router (merged); nuqs adapter v7; library mode; no react-router-dom
// REACT FLOW V12
RF12|@xyflow/react import; node.measured replaces node.width/height for layout (dagre/elk)
// EXPO SDK55
EXPO55|New Architecture mandatory; expo-av removed; notifications config plugin required; Reanimated v4 incompatible with NativeWind→pin v3
// TAURI V2
TAURI_V2|v2.7.0 stable; capability audit CI; delta updates roadmap only; mobile for internal tools
// TEMPORAL API
TEMPORAL_API|ES2026; @rrulenet/recurrence candidate; Phase 2 evaluation
// CLAUDE 4.6
CLAUDE46|claude-sonnet-4-6-20250324 default; claude-opus-4-6-20250324 complex; claude-haiku-4-5 retired Apr 19 2026; no agentic Haiku
// Supabase Edge Functions
SB_EF|Deno runtime; npm: prefix; pre-bundled; cold start 400ms median, hot 125ms median; use for webhooks+async
// Deno Runtime Compatibility
DENO_RUNTIME|Deno 2.0 full npm compatibility with npm: specifier; CommonJS support (.cjs, package.json type, auto-detect); Node built-ins require node: prefix; Native C++ modules (bcrypt, sharp, sqlite3) fail - use pure JS alternatives (bcryptjs, Deno KV); File system APIs differ but npm:fs works
// OTel GenAI details
OTEL_GENAI|v1.40.0 released Feb 2026 (commit 7fe5373); Status: Experimental/Development as of March 2026; gen_ai.* namespace; use OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental for opt-in; default emits v1.36.0 or prior; track gen_ai.conversation.id (string, conversation/session/thread correlation); NO production readiness timeline - transition plan will be updated before marking stable (no date provided); not production-ready for stable adoption
// Resend inbound
RESEND_INBOUND|Svix delivery; TASK INFORMATION INCORRECT: 3-day log retention insufficient - HIPAA requires 6 years, SOC 2 requires policies (no specific duration), industry standards: HIPAA 6 years, SOX 7 years, NERC 6 months logs/3 years audit records, ISO 27001 12 months, PCI DSS 12 months; React Email 5.0; inbound parse available
// Svix integration patterns
SVIX_INTEGRATION|Acknowledge-first pattern: verify signature, validate structure, write to queue, return 200 immediately; Queue selection: Redis (moderate volume, simple/fast), RabbitMQ/SQS (delivery guarantees, dead-letter queues), Kafka (high volume/durability, replay capabilities); Key requirements: durability and at-least-once delivery; Keep queue close to webhook endpoint to minimize latency; Short timeouts protect providers from cascading failures
// PowerSync architecture
PWRSYNC_ARCH|SQLite client; Postgres server; YAML sync rules (legacy), Sync Streams (Beta recommended); 50 concurrent connections free tier; SOC2 Type 2 audited, HIPAA compliant (Pro/Team/Enterprise)
// Tauri capability security
TAURI_CAP|Fine-grained capability per window; XSS containment; CI manifest validation
TAURI_CAP_MODEL|Capabilities are a grouping and boundary mechanism to isolate access to the IPC layer. They control application windows' and webviews' fine-grained access to Tauri core, application, or plugin commands. Windows can be added to a capability by exact name (e.g., main-window) or glob patterns (e.g., *, admin-*). A window can have none, one, or multiple associated capabilities. If a webview or its window is not matching any capability, it has no access to the IPC layer at all. Capabilities can be platform-specific (linux, macOS, windows, iOS, android). Remote API access can be configured to allow remote sources access to certain Tauri commands (e.g., https://*.tauri.app). Security boundaries: minimize impact of frontend compromise, prevent exposure of local system interfaces and data, prevent privilege escalation from frontend to backend/system. Does NOT protect against: malicious/insecure Rust code, too lax scopes and configuration, incorrect scope checks in command implementation, intentional bypasses from Rust code, 0-days or unpatched 1-days in system WebView, supply chain attacks or compromised developer systems. Tauri generates JSON schemas with all available permissions through tauri-build for IDE autocompletion (gen/schemas/desktop-schema.json, gen/schemas/mobile-schema.json).
TAURI_XSS_CONTAINMENT|Tauri uses Content Security Policy (CSP) to restrict CSP of HTML pages to reduce or prevent impact of common web-based vulnerabilities like XSS. Local scripts are hashed, styles and external scripts are referenced using cryptographic nonce, which prevents unallowed content from being loaded. CSP protection is only enabled if set on Tauri configuration file. Configuration example: "csp": { "default-src": "'self' customprotocol: asset:", "connect-src": "ipc: http://ipc.localhost", "font-src": ["https://fonts.gstatic.com"], "img-src": "'self' asset: http://asset.localhost blob: data:", "style-src": "'unsafe-inline' 'self' https://fonts.googleapis.com" }. Isolation Pattern: injects a secure application between frontend and Tauri Core to intercept and modify incoming IPC messages. Uses sandboxing feature of <iframe>s to run JavaScript securely. Messages are encrypted using AES-GCM with runtime-generated keys (new keys each time application runs). Performance implications: additional overhead due to encryption, but most applications should not notice runtime costs (AES-GCM is relatively fast, messages are relatively small). Limitations: external files don't load correctly inside sandboxed <iframes> on Windows (script inlining step during build time), ES Modules won't successfully load. Tauri highly recommends using isolation pattern whenever possible, especially when using external Tauri APIs or applications with many dependencies.
TAURI_CI_VALIDATION|Tauri configuration is validated against JSON Schema located at https://schema.tauri.app/config/2. Schema validation ensures configuration file structure is correct before build. CI integration patterns: Use GitHub Actions with JSON Schema Validate action to validate tauri.conf.json (or Tauri.toml) against official schema. Example workflow: name: Validate Config, on: [push, pull_request], jobs: validate-config: runs-on: ubuntu-latest, steps: - uses: actions/checkout@v4, - uses: SchemaStore/schemastore-action@v1, with: schema: https://schema.tauri.app/config/2, files: src-tauri/tauri.conf.json. Alternative: Use validate-json action with schema parameter. Tauri also supports JSON5 and TOML formats via config-json5 and config-toml Cargo features. Platform-specific configuration files (tauri.linux.conf.json, tauri.windows.conf.json, etc.) are merged with main configuration. Schema validation should run on all configuration files to catch misconfigurations early in CI pipeline.
// Tremor maintenance status
TREMOR_STATUS|Actively maintained by Tremor Labs (Vercel-acquired); v3.18.x stable; v4 beta (early development); ~27K GitHub stars; safe ADR
// TREMOR V4 MIGRATION
TREMOR_V4_STATUS|TASK INFORMATION INCORRECT/PREMATURE: Tremor v4 is in early beta (v4.0.0-beta-tremor-v4.4), NOT a stable preview ready for migration planning. No official migration guide exists. Breaking changes mentioned in changelog but not comprehensively documented. v4 beta uses Tailwind CSS 4.0.0-beta.6 (itself in beta) and React 19.0.0. Package.json shows version "0.0.0-development" indicating early development stage. No GA timeline or production readiness information found. Migration planning should wait until v4 reaches stable release with official migration documentation.
TREMOR_V4_BREAKING|Known breaking changes from changelog snippets: Toggle component removed (replace with TabList variant="solid"), Tabs component redesigned with new API (now has "line" and "solid" variants), Dropdown component removed (use new Select component), DateRangePicker API changed significantly. Note: This is not a comprehensive list as no official breaking changes documentation exists for v4 beta.
// Additional KV (Apr 2026)
RRULE_DST_BUG|rrule.js TZID-parameterized DTSTART RFC5545 non-compliant; DST shifts 1h. Replace: FE→rschedule+@rschedule/temporal-date-adapter; BE unchanged.
REACT_COMPILER_STABLE|Includes existing useMemo/useCallback; skips some modules. Use eslint-plugin-react-compiler. Audit Q2'26.
// REACT COMPILER ESLINT
REACT_COMPILER_ESLINT|TASK INFORMATION INCORRECT: eslint-plugin-react-compiler has been DEPRECATED. Users should now use eslint-plugin-react-hooks@latest instead. The linting functionality has been integrated into eslint-plugin-react-hooks. The linter helps identify code that breaks the Rules of React. New lint rules include: set-state-in-render, set-state-in-effect, refs. Does not require the compiler to be installed, so no risk in upgrading.
// REACT COMPILER COMPATIBILITY
REACT_COMPILER_COMPAT|Recommendation: Only compile own source code with React Compiler, do NOT compile 3rd-party code. Library authors have full control over whether to use React Compiler or manually optimize. Some third-party library hooks return new objects on every render, breaking memoization chains: TanStack Query's useMutation(), Material UI's useTheme(), React Router's useLocation(). Libraries should be designed to be memoize-able for non-hook usage and provide hooks as static functions (not as first-class values).
PASSKEYS_SUPABASE_GAP|Supabase Auth lacks native WebAuthn. Use SimpleWebAuthn+RPC; table webauthn_challenges.
Nylas_Webhook_BestPractices|Async processing (ack<10s), idempotency via nylas_processed_events, DLQ after 3 retries, grant.expired handling (refresh attempt, 72h backfill window), daily cron for expiring grants. See runbook.
Resend_Primary|Resend is now primary transactional email. Handle email.complained→unsubscribed:true. Svix inbound webhooks.
LangGraph_Supervisor|Maps FLOWC01 SM; slightly underperforms swarm due to translation overhead; most generic architecture (fewest assumptions about sub-agents); best for open-ended reasoning, iterative research, complex multi-turn dialogues; improvements: remove handoff messages, forward_message tool, tool naming optimization.
LangMem_Config|TASK INFORMATION INCORRECT: LangMem has severe performance issues - p95 search latency 59.82s on LOCOMO benchmark (not a typo), accuracy 58.10% vs Mem0's 67.13% with 0.200s p95 latency; NOT suitable for interactive user-facing agents; use for background/batch memory tasks only; Mem0 recommended for interactive production agents (0.200s p95, 67.13% accuracy); provides semantic (user facts), episodic (past interactions), procedural (self-updated system prompts - unique to LangMem); requires embedding index (dims + embed model) for semantic search.
Trustcall_Extraction|Reliable structured data extraction using JSON patch operations; addresses LLM limitations with complex nested schemas and updating existing schemas without information loss; uses JSON patch to focus LLM on what has changed; increases extraction reliability without restricting JSON schema subset; use cases: complex schema extraction, memory management updates, simultaneous updates & insertions.
FastGraphRAG|NLP-based, 16.7% cost (6x cheaper than conventional GraphRAG); production first. Benchmarks: 96% perfect retrieval on 2wikimultihopQA vs 75% for GraphRAG, 27x faster insertion. LLM-based GraphRAG via feature flag at 500K tokens (dataset size threshold, not chunk count).
SanitizedHTML_Profiles|Three DOMPurify profiles: STRICT(no svg), RICH(allowed div/span), EMAIL(link+img). Component prop driven.
// SVG SECURITY
SVG_Security|DOMPurify SVG sanitization removes event handlers (onload, onclick, onmouseover, onerror) to prevent JavaScript injection via SVG. SVG security risks: JavaScript execution through event handlers, MathML rendering process vulnerabilities, namespace confusion leading to mXSS. Safe patterns: USE_PROFILES: { svg: true } for SVG-only content, FORBID_ATTR: ['onload', 'onclick', 'onmouseover', 'onerror', 'onfocus'], FORBID_TAGS: ['script', 'style'] within SVG, SAFE_FOR_XML: true (default) to prevent namespace confusion. RICH profile validation: FORBID_TAGS: ['svg', 'mathml'] blocks SVG entirely in RICH profile (recommended for rich text editors), ALLOWED_TAGS limited to HTML formatting tags only, no SVG event handlers allowed. SVG handling in RICH profile: BLOCKED - RICH profile explicitly forbids SVG tags (FORBID_TAGS: ['svg', 'mathml']) to prevent SVG-based XSS attacks, only HTML formatting tags allowed (div, span, p, br, b, i, u, strong, em, ul, ol, li, a, img), images allowed via <img> tag with ALLOWED_ATTR: ['src', 'alt', 'title'] but SVG <image> elements blocked.
// EMAIL SECURITY
Email_Security|DOMPurify EMAIL profile for HTML email sanitization. Configuration: USE_PROFILES: { html: true }, ALLOWED_TAGS: ['div', 'span', 'p', 'br', 'a', 'img', 'table', 'tr', 'td', 'th'], ALLOWED_ATTR: ['href', 'src', 'alt', 'title', 'width', 'height'], FORBID_TAGS: ['svg', 'mathml', 'script', 'style', 'iframe', 'object', 'embed', 'form'], FORBID_ATTR: ['onload', 'onclick', 'onerror', 'formaction'], ALLOW_DATA_ATTR: false. Link safety: href attributes allowed but validated by DOMPurify's URI sanitization (javascript: protocol blocked), mailto: links allowed, http/https links allowed, data: URIs blocked by default. Image safety: src attribute allowed but validated (javascript: protocol blocked), http/https URLs allowed, data: URIs for images blocked by default, alt and title attributes allowed for accessibility. Additional validation: KEEP_CONTENT: true preserves content when tags removed, FORBID_TAGS: ['form'] prevents CSRF via email forms, FORBID_ATTR: ['formaction'] prevents form action hijacking, ALLOW_DATA_ATTR: false prevents ujs-based XSS via data-* attributes. Email-specific considerations: HTML email clients have varying CSS support, inline styles recommended (but blocked in EMAIL profile for security), table-based layouts common (tables allowed in EMAIL profile), responsive design via media queries (not supported in all email clients).
PowerSync_Bucket|YAML rules per orgId (JWT claim); 50 concurrent connections free tier; conflict resolution LWW.
Temporal_ZD_Required|Always Temporal.ZonedDateTime for calendar events; never PlainDateTime.
// REACT-BIG-CALENDAR MAINTENANCE
RBC_MAINTENANCE|Latest release v1.19.4 (June 16, 2025) - 10 months old as of April 26, 2026. Last commits June 2025, no 2026 activity visible. 8,500+ GitHub stars, ~500K weekly npm downloads. Issues still being opened in 2026 (#2795 Mar 23, #2791 Jan 30, #2789 Jan 15, #2785 Jan 15). Not abandoned but maintenance appears slow (no commits in 10 months). React 19 compatibility: Partial - JSX transform warning (Issue #2785) with modern JSX runtime ("jsx": "react-jsx"). Workaround: Suppress warning or wait for library update to modern JSX transform. Decision: Stay with v1.19.4 for now (ADR_014), monitor for updates, evaluate FullCalendar migration if maintenance continues to stall.
