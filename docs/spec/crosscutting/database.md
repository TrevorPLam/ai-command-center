---
id: arch.database
title: DATABASE
type: architecture
status: draft
version: 1.0.0
compressed: |
Tables: messages,threads,projects,tasks,events,emails,contacts,documents,media,transactions,goals,researchNotebooks,flashcards,conferenceRooms,translationSessions,newsArticles,workflowExecutions,audit_logs,notificationPreferences,org_members,connected_accounts,organizations,feature_flags,notifications,user_roles,role_permissions,agent_definitions,recurrence_rules,ai_cost_log,prompt_versions,eval_datasets,eval_runs,collab_documents
Shared tables: org_id FK,RLS via JWT custom claims(user_role,org_id)
connected_accounts: stores encrypted grant_id
agent_definitions: org-scoped,versioned,tools jsonb
recurrence_rules: entity_type,entity_id,rrule_string,exceptions
ai_cost_log: tokens,model,user,org
prompt_versions: content,variables,metrics
FE queries via supabase-js only;Prisma Client used exclusively in migrations/backend
pgvector HNSW(m=16,ef_construction=64)
Audit triggers on sensitive tables; migrations: add nullable→backfill→NOT NULL
last_updated: 2026-04-24T23:22:41.115555+00:00
---

# DATABASE

Tables: messages,threads,projects,tasks,events,emails,contacts,documents,media,transactions,goals,researchNotebooks,flashcards,conferenceRooms,translationSessions,newsArticles,workflowExecutions,audit_logs,notificationPreferences,org_members,connected_accounts,organizations,feature_flags,notifications,user_roles,role_permissions,agent_definitions,recurrence_rules,ai_cost_log,prompt_versions,eval_datasets,eval_runs,collab_documents
Shared tables: org_id FK,RLS via JWT custom claims(user_role,org_id)
connected_accounts: stores encrypted grant_id
agent_definitions: org-scoped,versioned,tools jsonb
recurrence_rules: entity_type,entity_id,rrule_string,exceptions
ai_cost_log: tokens,model,user,org
prompt_versions: content,variables,metrics
FE queries via supabase-js only;Prisma Client used exclusively in migrations/backend
pgvector HNSW(m=16,ef_construction=64)
Audit triggers on sensitive tables; migrations: add nullable→backfill→NOT NULL
