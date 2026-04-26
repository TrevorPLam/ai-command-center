---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-7-FLOWS.md
document_type: critical_flows
tier: infrastructure
status: stable
owner: Product Engineering
description: Essential user interaction flows with state management and error handling
flow_count: 8
last_updated: 2026-04-25
version: 1.0
dependencies: [00-PLAN-1-INTRO.md, 00-PLAN-2-ZV.md, 00-PLAN-5-EP.md]
related_adrs: [ADR_032, ADR_058, ADR_062, ADR_063, ADR_064, ADR_065, ADR_067, ADR_077, ADR_079, ADR_082]
related_rules: [XCT_01, XCT_02, XCT_03, FLOWC_01, FLOWC_02, EVNT_01, EVNT_02, SECM_02, SECM_03, GRDL_01, PRIV_01, STKB_01, YJS_01, NYLS_01, CRDB_01, RCLL_01]
complexity: medium
risk_level: high
---

# FLOWS - Critical User Flows

// LOGIN
I|LoginPage→signInWithPassword→SB Auth
I|authSlice.currentUser← ; JWT embed org_id+user_role
I|onAuthStateChange→invalidate queries+RT reconnect→Dashboard

// CHAT
I|ChatInput→Msg→MsgList(@O,clientMsgId)
I|useSSE→FastAPI /v1/chat→LLM→stream tokens→MsgBubble
I|end: full msg cached(staleTime=0,gcTime=∞)

// EMAIL
I|Compose→POST /v1/email/send→FastAPI JWT→NY API
I|NY sends→webhook→EdgeFn→upsert emails→RT→inbox

// COST_BUDGET
I|LLM intercepts AI req with x-litellm-tags: org_id,user_id,feature
I|query cost_budgets; calc usage% from ai_cost_log(TS)
I|<85%: forward+log | ≥85%: warn admin(15%) | ≥95%: warn+eng(5%) | ≥100%: 429+CostLimitBanner
I|GET /v1/cost-forecast via continuous aggregates→{projected,CI,trend,action}

// NYLAS_WEBHOOK
I|NY→POST /v1/evnt/webhook/nylas→verify HMAC-SHA256→ack<10s
I|extract nylas_id→check UNIQUE(org_id,nylas_id)→upsert-first(fetch from NY if not found)
I|LWW via uat; async queue if historical filtering needed
I|monitor: alert if >5%/5min; NY auto-disables URL after 95%/72h

// MCP_POLICY
I|Agent→POST /v1/mcp/execute→zero-trust gateway
I|check mcp2_tool_authorizations: OAuth only(not API key)
I|validate args vs schema allowlist; eval allow/deny/approve(deterministic)
I|high-risk→elicitation(pause for human); approved→sandbox exec,log
I|denied→error+policy reason; log to mcp2_policy_evaluations

// SPEC_VALIDATION
I|comp flagged with @O/@SS/@R/@X/@U/@K→check for spec or linked parent spec
I|if missing→block DoD1,notify author via PR; if present→validate frontmatter+9 sections
I|auto-assign tier(@O/@SS/@R/@X/@U/@K→T1; cards/items→T2; presentational→T3)
I|store result in spec_metadata; trigger CI gate

// OPTIMISTIC_UI
I|op(create/update/delete)→useOptimistic immediately→pending(opacity0.5+italic+pulse)
I|gen temp ID(ULID for new); send req with IC
I|success→base matches optimistic; failure→auto-rollback+error toast+Undo(5s)
