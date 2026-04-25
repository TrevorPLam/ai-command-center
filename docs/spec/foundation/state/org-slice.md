---
id: state.org-slice
title: orgSlice
type: state-slice
status: draft
version: 1.0.0
state_slice_name: orgSlice
fields: currentOrgId,orgs[]
persist_policy: currentOrgId(localStorage),orgs reset
notes: refreshSession on switch
last_updated: '2026-04-24T23:37:09.064240+00:00'
slice_type: OrgState
---

# orgSlice

## Fields
currentOrgId,orgs[]

## Type
OrgState

## Persist Policy
currentOrgId(localStorage),orgs reset

## Notes
refreshSession on switch
