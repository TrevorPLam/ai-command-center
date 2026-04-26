# PRD

> **TL;DR**: AI workspace with cross-app conflict detection, unified chat, and local-first AI for privacy. Core jobs: conflict detection, unified chat, proactive notifications. Success metrics: <30s resolution, >60% paid conversion, <1% hallucination. Monetization: Free (local), Pro ($20-30/mo cloud), Enterprise (custom). Design axioms and architecture in [11-STRAT-BLUEPRINT.md](11-STRAT-BLUEPRINT.md).

## Vision

AI workspace: conversational assistant across calendar/projects/email → detects problems → suggests actions → executes on behalf. Local-first AI keeps data private, costs near-zero.

## Jobs

### J001 (P0): Cross‑App Conflict Detection

Client reschedule email → AI checks calendar/projects → alerts conflicts → fixes from dashboard.

### J002 (P0): Unified Chat

Chat Q/command → AI understands cross-app context → takes actions via available tools.

### J003 (P1): Proactive Notifications

AI surfaces cross-app insights on dashboard without prompting.

### J004 (P1): External Data Integration

Connect existing calendars/email → AI gets complete picture immediately.

### J005 (P1): Data Sovereignty & Privacy

Sensitive data processed on-device/user-controlled, not sent to third-party cloud AI.

## Success metrics

|Metric|Target|
|---|---|
|Resolution time|<30s|
|Flow conversion|>60% paid|
|Hallucination rate|<1%|

## Monetization

|Tier|AI Capability|Marginal Cost|Pricing|
|---|---|---|---|
|Free|Local models (Gemma 4, Qwen3.5)|~$0.00001/1K tokens|Free|
|Pro|Cloud API (Sonnet 4.6)|$0.10-0.50/user/mo|$20-30/mo|
|Enterprise|Full cloud (Opus 4.7), fine-tuning|$1-5/user/mo|Custom|

## Personas

|ID|Role|Goals|Pain Points|
|---|---|---|---|
|P1|PM|Ship faster, track AI usage|Manual tracking, unclear costs|
|P2|Sr Engineer|Build agents, debug flows|Complex orchestration, security gaps|
|P3|Data Scientist|Fine-tune models, evaluate|No eval framework, unclear metrics|
|P4|Platform Owner|Ensure uptime, manage secrets|Manual rotation, slow incident response|
|P5|UX Designer|Design agent UIs, prototype|No UI patterns, unclear motion specs|

## Outcomes

|ID|Outcome|Measurement|Timeline|
|---|---|---|---|
|O001|Reduce cost surprises|Budget alerts before overage|Q2 2026|
|O002|Accelerate development|Eval gate reduces PR cycle|Q2 2026|
|O003|Improve reliability|≤2% hallucination via guardrails|Q3 2026|
|O004|Enhance security|≥90% MCP OAuth adoption|Q2 2026|
|O005|Streamline compliance|SOC2 pipeline automated|Q3 2026|

## Assumptions & Risks

|ID|Assumption|Validation|Risk|
|---|---|---|---|
|A001|Claude Opus 4.7 remains complex tier|Monitor releases|Medium|
|A002|PowerSync SOC2/HIPAA certified|Verify docs|Low|
|A003|APS becomes IETF standard|Track draft|Medium|
|A004|EU AI Act Aug 2026 deadline (Annex III)|Monitor Omnibus extension|High|
|A005|AI agents classified as high-risk|Verify Annex III scope|High|
|A006|Stripe AI SDK supports metering|Test integration|Low|
|A007|Shadow AI / NHI risk manageable|CSA 2026: 54% orgs report 1-100 unsanctioned AI agents, 53% scope violations|High|

## Constraints

|ID|Constraint|Mitigation|
|---|---|---|
|C001|No SSR framework|Vite SPA only|
|C002|Supabase Storage no versioning|Separate S3 bucket|
|C003|Edge Functions no DB|Route to Serverless/FastAPI|
|C004|LiteLLM supply chain risk|Cosign verification mandatory|
|C005|Y-Sweet self-host required|Docker deployment|

## Dependencies

|ID|Dependency|Blocked By|
|---|---|---|
|D001|Agent Studio|MCP Security Gateway|
|D002|AI Cost Dashboard|Stripe Token Meter|
|D003|Offline Sync|PowerSync evaluation|
|D004|Guardrails Engine|LiteLLM proxy|
|D005|A2A Integration|Signed Agent Cards spec|

## Phases

|Phase|Deliverables|Timeline|
|---|---|---|
|Phase 1|Foundation: Auth, Shell, Dashboard, Chat, EU AI Act Compliance Planning|Jan-Apr 2026|
|Phase 2|Core AI: Agent Studio, MCP, Guardrails, Cost|Apr-Jun 2026|
|Phase 3|Advanced: Offline, Collab, Feature Flags|Aug-Sep 2026|
|Phase 4|Scale: Observability, SOC2 Pipeline, A2A|Oct-Dec 2026|
|Phase 5|Optimization: GraphRAG, Mobile|H1 2027|

---

## Appendix A: JTBD Backlog

|ID|Priority|Epic|Acceptance Criteria|
|---|---|---|---|
|J001|P0|AI Cost Tracking|Real-time org/team/user, 15/5/0% alerts, ±10% forecast|
|J002|P0|Agent Studio|Browse/clone agents, versioned prompts, eval gates, sandbox|
|J003|P0|MCP Security|OAuth auth, schema allowlist, high-risk elicitation, audit logs|
|J004|P0|EU AI Act Compliance|High-risk agent classification, Annex III obligations, conformity assessment|
|J005|P1|Offline Sync|SQLite↔Postgres bidirectional, conflict resolution, queue|
|J006|P1|Real-time Collab|Yjs canvas, thought-trace visibility, version control|
|J007|P1|Guardrails|Input/output/runtime layers with audit logging|
|J008|P2|A2A Integration|Signed Agent Cards, cryptographic identity|
|J009|P2|Observability|OTel GenAI traces, Sentry, PostHog, Loki|
|J010|P2|Feature Flags|Progressive rollout, <5min kill switch, OpenFeature|
|J011|P2|SOC2 Evidence|Automated evidence collection, quarterly PIA|

## Appendix B: Detailed Metrics

|ID|Metric|Target|Frequency|
|---|---|---|---|
|S001|TTFT|≤2s p95|Continuous|
|S002|Availability|99.9%|Monthly|
|S003|Hallucination Rate|≤2%|Per eval|
|S004|Tool Precision|≥90%|Per eval|
|S005|Cost Forecast|±10%|Monthly|
|S006|LCP|≤800ms p75|Weekly|
|S007|INP|≤200ms|Weekly|
|S008|P0 Response|Immediate|Per incident|
|S009|Secret Rotation|100%|Quarterly|
|S010|Eval Gate Pass|≥base-2%|Per PR|

## Appendix C: RICE Prioritization

|ID|Feature|Reach|Impact|Confidence|Effort|Score|Priority|
|---|---|---|---|---|---|---|---|
|R001|AI Cost Dashboard|100|8|0.9|4|180|P0|
|R002|Agent Studio|80|9|0.8|6|96|P0|
|R003|MCP Security Gateway|100|10|0.95|5|190|P0|
|R004|Offline Sync|60|7|0.7|8|37|P1|
|R005|Guardrails Engine|100|9|0.85|7|109|P1|
|R006|A2A Integration|40|6|0.6|8|18|P2|
|R007|Feature Flags|90|7|0.8|5|101|P1|
|R008|EU AI Act Compliance|100|10|0.9|5|180|P0|
|R009|SOC2 Pipeline|50|8|0.7|6|47|P2|

## Appendix D: MoSCoW Prioritization

**MUST:** AI Cost Tracking, Agent Studio, MCP Security, EU AI Act Compliance, Guardrails, Auth/Org Switch, RLS

**SHOULD:** Offline Sync, Real-time Collab, Feature Flags, Observability, A2A Integration, SOC2 Pipeline

**COULD:** GraphRAG, Contextual Retrieval, Voice Agents, Mobile App, Desktop App

**WON'T:** Blockchain Audit, Quantum Prep, Custom LLM Training, On-prem Deployment

---

*Jobs J001/J002 are MUST priorities. RICE items retained, shifted to appropriate priority tiers.*