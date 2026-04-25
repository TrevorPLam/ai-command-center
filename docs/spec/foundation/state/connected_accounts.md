---
id: state.connected_accounts
title: connected_accounts
type: Yes
state_slice_name: connected_accounts
fields: **id** uuid,user_id FK,**org_id** FK,grant_id enc,provider
persist_policy: grant_id encrypted
notes: 
last_updated: '2026-04-24T23:34:58.400843+00:00'
---

# connected_accounts

## Fields
**id** uuid,user_id FK,**org_id** FK,grant_id enc,provider

## Persist Policy
grant_id encrypted
