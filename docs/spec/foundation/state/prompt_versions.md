---
id: state.prompt_versions
title: prompt_versions
type: No
state_slice_name: prompt_versions
fields: **id** uuid,prompt_id FK,content,variables jsonb,metrics jsonb
persist_policy: Eval suite gating
notes: 
last_updated: '2026-04-24T23:34:58.411337+00:00'
---

# prompt_versions

## Fields
**id** uuid,prompt_id FK,content,variables jsonb,metrics jsonb

## Persist Policy
Eval suite gating
