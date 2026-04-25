---
id: state.projects
title: projects
type: Yes
state_slice_name: projects
fields: **id** uuid,**org_id** FK,name,status,priority
persist_policy: 'RLS:owner+org_members'
notes: 
last_updated: '2026-04-24T23:34:58.378157+00:00'
---

# projects

## Fields
**id** uuid,**org_id** FK,name,status,priority

## Persist Policy
RLS:owner+org_members
