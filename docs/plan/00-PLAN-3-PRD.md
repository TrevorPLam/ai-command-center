---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-3-PRD.md
document_type: product_requirements
tier: strategic
status: stable
owner: Product / GTM
description: Product requirements — updated for integrated productivity AI platform
last_updated: 2026-04-25
version: 2.0
dependencies: [00-PLAN-1-INTRO.md, 00-PLAN-9-TEAM.md]
related_adrs: []
related_rules: []
complexity: medium
risk_level: high
---

# PRD - Product Requirements (Revised)

## Product Vision
An AI‑integrated workspace where a conversational assistant works across your calendar, projects, and email to spot problems, suggest actions, and execute them on your behalf.

## Key Jobs to Be Done

### J001 (P0): Cross‑App Conflict Detection & Resolution
When my client emails to reschedule, I want my assistant to check my calendar and project deadlines, alert me to conflicts, and offer to fix them — all from one dashboard.

### J002 (P0): Unified Chat Assistant
When I ask a question or give a command in chat, I want the assistant to understand my context across apps and take appropriate actions using the available tools.

### J003 (P1): Proactive Notifications
I want the assistant to surface important cross‑app insights on the dashboard without me having to ask.

### J004 (P1): External Data Integration
I want to connect my existing calendars and email so the assistant immediately has a complete picture.

## Success Metrics
- Time from conflict detection to resolution action < 30 seconds.
- >60% of users who try the conflict flow become paid subscribers.
- Hallucination rate in structured tool calls < 1%.

## RICE & MoSCoW (adjusted)
// J001 and J002 are MUST now. All previous RICE items shifted to SHOULD/COULD but retained.

// The original full PRD content (personas, assumptions, constraints, etc.) remains valid and is appended unchanged.

#PERSONAS|id|role|goals|pain_points| JTBD
P1|PM|Product Manager|Ship features faster,track AI usage,collaborate with dev|Manual req tracking,unclear AI costs,slow feedback loops|When I need to ship a feature,I want to track AI costs so that I can stay within budget
P2|SE|Senior Engineer|Build AI agents,debug agent flows,secure MCP tools|Complex agent orchestration,security blind spots,poor observability|When I build an agent,I want to debug tool calls so that I can fix failures quickly
P3|DS|Data Scientist|Fine-tune models,analyze agent behavior,evaluate quality|No eval framework,unclear metrics,manual data collection|When I evaluate agents,I want automated metrics so that I can improve quality
P4|PO|Platform Owner|Ensure uptime,manage secrets,control costs|Manual secret rotation,opaque cost attribution,slow incident response|When a secret expires,I want auto-rotation so that I can prevent outages
P5|UX|UX Designer|Design agent UIs,ensure accessibility,prototype flows|No agent UI patterns,unclear motion guidelines,missing a11y specs|When I design an agent,I want motion patterns so that I can create polished UIs

#JTBD|priority|epic|acceptance
J001|P0|AI Cost Tracking|Real-time cost per org/team/user/model,15/5/0% alerts,forecast accuracy±10%
J002|P0|Agent Studio|Browse/clone agents,versioned prompts,eval gates,playground sandbox
J003|P0|MCP Security|OAuth tool auth,schema allowlist,elicitation for high-risk,audit logging
J004|P1|Offline Sync|Bidirectional SQLite/Postgres,conflict resolution,queue management
J005|P1|Real-time Collab|Yjs canvas,thought-trace visibility,version control integration
J006|P1|Guardrails|Input(PII/jailbreak/tox),Output(halluc/safety/schema),Runtime(tool auth/cost)
J007|P2|A2A Integration|Signed Agent Cards,cryptographic identity,multi-tenant endpoints
J008|P2|Observability|OTel GenAI traces,Sentry errors,PostHog analytics,Loki logs
J009|P2|Feature Flags|Progressive rollout,kill switch<5min,OpenFeature abstraction
J010|P2|Compliance|EU AI Act docs,SOC2 evidence,PIA quarterly,GDPR opt-out

#SUCCESS|metric|target|frequency
S001|TTFT|≤2s p95|continuous
S002|Availability|99.9%|monthly
S003|Hallucination Rate|≤2%|per eval run
S004|Tool Precision|≥90%|per eval run
S005|Cost Forecast Accuracy|±10%|monthly
S006|LCP|≤800ms p75|weekly
S007|INP|≤200ms|weekly
S008|Incident Response P0|immediate|per incident
S009|Secret Rotation Compliance|100%|quarterly
S010|Eval Gate Pass Rate|≥base-2%|per PR

#RICE|id|reach|impact|confidence|effort|score|priority
R001|AI Cost Dashboard|100|8|0.9|4|180|P0
R002|Agent Studio|80|9|0.8|6|96|P0
R003|MCP Security Gateway|100|10|0.95|5|190|P0
R004|Offline Sync|60|7|0.7|8|37|P1
R005|Guardrails Engine|100|9|0.85|7|109|P1
R006|A2A Integration|40|6|0.6|8|18|P2
R007|Feature Flags|90|7|0.8|5|101|P1
R008|Compliance Pipeline|50|8|0.7|6|47|P2

#MoSCoW|must|should|could|won't
MUST|AI Cost Tracking|Agent Studio|MCP Security|Guardrails|Auth/Org Switch|RLS
SHOULD|Offline Sync|Real-time Collab|Feature Flags|Observability|A2A Integration
COULD|GraphRAG|Contextual Retrieval|Voice Agents|Mobile App|Desktop App
WONT|Blockchain Audit|Quantum Prep|Custom LLM Training|On-prem Deployment

#OUTCOMES|id|description|measurement|timeline
O001|Reduce AI cost surprises|Budget alerts before overage|Q2 2026
O002|Accelerate agent development|Eval gate CI reduces PR cycle time|Q2 2026
O003|Improve agent reliability|Hallucination rate≤2% via guardrails|Q3 2026
O004|Enhance security posture|MCP OAuth≥90% adoption|Q2 2026
O005|Streamline compliance|SOC2 evidence pipeline automated|Q3 2026

#ASSUMPTIONS|id|assumption|validation|risk
A001|Claude Opus 4.7 remains default complex tier|Monitor Anthropic releases|Medium
A002|PowerSync SOC2/HIPAA certified|Verify certification docs|Low
A003|MCPSec L2 becomes IETF standard|Track draft progress|Medium
A004|EU AI Act deadline Dec 2027|Monitor official amendments|Low
A005|Stripe AI SDK supports metering|Test integration|Low

#CONSTRAINTS|id|constraint|mitigation
C001|No SSR framework|Vite SPA only|Design constraint
C002|Supabase Storage no versioning|Separate S3 bucket|Architecture workaround
C003|Edge Functions no DB|Route to Serverless/FastAPI|Architecture pattern
C004|LiteLLM supply chain risk|Cosign verification mandatory|Security control
C005|Y-Sweet self-host required|Docker deployment|Ops requirement

#DEPENDENCIES|id|dependency|blocked_by
D001|Agent Studio|MCP Security Gateway|SECM_002
D002|AI Cost Dashboard|Stripe Token Meter|STKB_001
D003|Offline Sync|PowerSync eval|CRDB_002
D004|Guardrails Engine|LiteLLM proxy|LITELLM_PIN
D005|A2A Integration|Signed Agent Cards spec|ADR_031

#PHASING|phase|deliverables|timeline
PHASE1|Foundation|Auth/Org Switch,Shell,Dashboard,Chat basic|Jan-Apr 2026
PHASE2|Core AI|Agent Studio,MCP Security,Guardrails,AI Cost Tracking|Apr-Jun 2026
PHASE3|Advanced|Offline Sync,Real-time Collab,Feature Flags|Aug-Sep 2026
PHASE4|Scale|Observability,Compliance,A2A Integration|Oct-Dec 2026
PHASE5|Optimization|GraphRAG,Contextual Retrieval,Mobile|H1 2027

EOF
