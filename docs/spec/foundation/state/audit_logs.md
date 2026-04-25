---
id: state.audit_logs
title: audit_logs
type: No
state_slice_name: audit_logs
fields: **id** uuid,user_id FK,action,entity_type,entity_id
persist_policy: Anonymized on org delete
notes: 
last_updated: '2026-04-24T23:34:58.396317+00:00'
---

# audit_logs

## Fields
**id** uuid,user_id FK,action,entity_type,entity_id

## Persist Policy
Anonymized on org delete
