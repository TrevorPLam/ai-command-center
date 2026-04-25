---
id: state.agent_definitions
title: agent_definitions
type: Yes
state_slice_name: agent_definitions
fields: **id** uuid,**org_id** FK,name,system_prompt,tools jsonb,version
persist_policy: Versioned,org-scoped
notes: 
last_updated: '2026-04-24T23:34:58.407817+00:00'
---

# agent_definitions

## Fields
**id** uuid,**org_id** FK,name,system_prompt,tools jsonb,version

## Persist Policy
Versioned,org-scoped
