---
id: state.project-slice
title: projectSlice
type: state-slice
status: draft
version: 1.0.0
state_slice_name: projectSlice
fields: currentView,filters,selectedProjectId,taskOrder,triageState
persist_policy: currentView,filters(localStorage),others reset
notes: useShallow for selectors
last_updated: '2026-04-24T23:37:09.070586+00:00'
slice_type: ProjectState
---

# projectSlice

## Fields
currentView,filters,selectedProjectId,taskOrder,triageState

## Type
ProjectState

## Persist Policy
currentView,filters(localStorage),others reset

## Notes
useShallow for selectors
