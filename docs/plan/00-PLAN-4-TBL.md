---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-4-TBL.md
document_type: database_schema
tier: infrastructure
status: stable
owner: Data Platform
description: PostgreSQL database table schemas with RLS and multi-tenant patterns
table_count: 63
last_updated: 2026-04-25
version: 1.0
dependencies: [00-PLAN-1-INTRO.md, 00-PLAN-8-ARCH.md]
related_adrs: [ADR_002, ADR_033]
related_rules: [P3, S5, S19]
complexity: high
risk_level: critical
---

# TBL - Database Tables

table|key cols|notes
// Col suffixes: $=PK,>=FK,?=nullable; types implied by context
messages|id$,org_id>,thread_id>,usr_id>,content,cat,uat|RLS private
threads|id$,org_id>,title,cat|-
projects|id$,org_id>,nm,desc,status,priority,start,end,budget,owner>,client_email,tags,cat,uat|ORG,RLS
tasks|id$,project_id>,parent_id$?,title,status,assignee>,due,est,priority,order,checklist,cat,uat|subtasks
events|id$,org_id>,title,start,end,tz,allDay,recurrence_id$?,cat,uat|recurrence FK
emails|id$,org_id>,account_id$,nylas_id,subject,from,to,cc,bcc,body,attachments,dir,cat|NY synced
contacts|id$,org_id>,nm,email,phone,company,privacy,tags,data,cat,uat|privacy fields
documents|id$,org_id>,nm,type,size,storage_path,is_trash,cat,uat|SB Storage ref
media|id$,org_id>,nm,type,url,alt,blurhash,album_id$?,cat,uat|AI alt,blurhash
transactions|id$,org_id>,amt,date,desc,category,type,is_planned,cat|-
goals|id$,org_id>,nm,target,current,deadline,cat|-
researchNotebooks|id$,org_id>,title,content,cat,uat|-
flashcards|id$,org_id>,front,back,deck,fsrs_state,cat,uat|FSRS
conferenceRooms|id$,org_id>,name,livekit_room_id,cat|-
translationSessions|id$,org_id>,source_lang,target_lang,speakers,segments,status,cat|-
newsArticles|id$,org_id>,url,title,source,sentiment,summary,cat|-
workflowExecutions|id$,org_id>,workflow_id$,step_id,status,input,output,started,finished,cat|SM
audit_logs|id$,org_id>,actor_id$,action,entity,entity_id,old,new,cat|anon on delete
notificationPreferences|id$,org_id>,user_id$,channels,cat|-
org_members|org_id$,user_id$,role_id$,joined|RLS join
connected_accounts|id$,org_id>,provider,grant_id,access_token,expires,cat|grant_id encrypted
organizations|id$,slug,name,plan,created,allow_training|multi-tenant root
feature_flags|id$,org_id>,flag,percent,enabled,cat|lifecycle
notifications|id$,org_id>,user_id$,template,deeplink,read,cat|templates+deeplink
user_roles|id$,org_id>,nm,perms|admin,manager,member,viewer,external
role_permissions|role_id$,resource,action|RBAC matrix
agent_definitions|id$,org_id>,name,desc,tools,config,ver,is_public,cat,uat|versioned,org-scoped
recurrence_rules|id$,org_id>,entity_type,entity_id$,rrule,start_tz,exdates,overrides,cat|shared engine
ai_cost_log|id$,org_id>,req_id$,model,tok_in,tok_out,cost,caller,cat|per-request; TS hypertable
prompt_versions|id$,org_id>,prompt_id$,tmpl,vars,ver,is_prod,cat|eval gate
eval_datasets|id$,org_id>,name,test_cases,cat|-
eval_runs|id$,org_id>,dataset_id$,prompt_ver_id$,metrics,passed,cat|CI gate
collab_documents|id$,org_id>,ysweet_doc,ent_type,ent_id$,perms,creator$,cat|YS integration
// Spec/XCT monitoring tables (abbreviated)
spec_metadata|id$,component_name,tier(1/2/3),status,frontmatter,sections_required,authors,deps,cat,uat|spec registry
xct_realtime_channels|id$,org_id>,channel_name,sub_count,memory_mb,created,last_activity|RT monitoring
xct_offline_ops|id$,org_id>,actor_id$,op,entity_type,entity_id$,IC,tombstone,deleted_at?,created|offline queue
flowc_workflow_states|id$,workflow_id$,state,transition_reason,guard_evaluated,ts|SM audit
evnt_webhook_dedup|id$,org_id>,provider,provider_event_id,processed,dedup_key,created|idempotency
testc_coverage_targets|id$,module,unit(0.80),component(0.85),integration(0.70),e2e_flows(10-15),a11y_critical(0)|targets
opsr_incidents|id$,org_id>,severity(P0-P3),title,desc,status,roles,slo_impact,created,resolved|SOC2 lifecycle
fflg_flags|id$,org_id>,flag,desc,owner,default_behavior,targeting_rules,current_stage,cohort_hash,review_date|registry
cost_budgets|id$,org_id>,level(org/team/user/model),scope_id$,monthly_limit,current_usage,alert_15,alert_5,alert_0,hard_cap,updated|-
obs_slo_definitions|id$,org_id$,service,metric,target,window,current,EB_remaining|-
secm_control_mappings|id$,rule_id(S1-S21),control_desc,mechanism,test_method,owner,evidence,last_verified|SCM
mcp2_tool_authorizations|id$,org_id>,tool_name,auth_method(oauth),scope,allowlist_schema,elicitation_required,approved_by,approved|-
pass_passkeys|id$,org_id>,user_id$,credential_id,authenticator_type,created,last_used,recovery_codes|-
grdl_audit_logs|id$,org_id>,layer(input/output/runtime),decision(allow/block/warn),reason,ts|100% logging
ssrf_allowlists|id$,org_id>,allowed_domain,allowed_ip_range,validation_method,created,updated|-
priv_training_opt_outs|id$,org_id$,allow_training,opted_out,reason,segregation_applied|-
stkb_usage_records|id$,org_id$,stripe_meter_id$,token_count,cost_usd,recorded,stripe_status|-
yjs_document_lifecycle|id$,org_id$,doc_ns,gc_enabled,undo_stack(≤5),snapshot_ver,size_mb,compaction_triggered,cat,uat|-
nyls_webhook_config|id$,org_id$,trigger_type,upsert_first,async_queue,timeout(10),sync_policy|-
otel_span_definitions|id$,org_id$,span_name,required_attrs(gen_ai.*),redaction_rules|-
crdb_tombstone_config|id$,org_id$,entity_type,deleted_at_col,retention_days,compaction_schedule|-
rlmt_channel_limits|id$,org_id$,platform(100),self(20),current,alert_at(15),alert_triggered|-
upsc_scan_config|id$,org_id$,scanner(clamd),ver_pinned(1.0.4+),cve_mon,chunked,pre_scan_validation|-
rcll_recurrence_rules|id$,org_id$,entity_type,rrule,rdate,exdate,tzid,edit_mode,exception_storage(keyed by start_utc O(1))|-
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
