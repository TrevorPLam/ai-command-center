---
id: state.messages
title: messages
type: No
state_slice_name: messages
fields: **id** uuid,thread_id FK,role,content,metadata
persist_policy: 'RLS:private channels'
notes: 
last_updated: '2026-04-24T23:34:58.376072+00:00'
---

# messages

## Fields
**id** uuid,thread_id FK,role,content,metadata

## Persist Policy
RLS:private channels
