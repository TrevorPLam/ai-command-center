---
id: state.eval_runs
title: eval_runs
type: No
state_slice_name: eval_runs
fields: **id** uuid,dataset_id FK,agent_id FK,scores jsonb
persist_policy: CI gate
notes: 
last_updated: '2026-04-24T23:34:58.413512+00:00'
---

# eval_runs

## Fields
**id** uuid,dataset_id FK,agent_id FK,scores jsonb

## Persist Policy
CI gate
