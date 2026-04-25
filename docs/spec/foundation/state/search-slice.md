---
id: state.search-slice
title: searchSlice
type: state-slice
status: draft
version: 1.0.0
state_slice_name: searchSlice
fields: globalQuery,searchHistory,recentEntities
persist_policy: searchHistory(max50),recentEntities(max20)
notes: 
last_updated: '2026-04-24T23:37:09.097553+00:00'
slice_type: SearchState
---

# searchSlice

## Fields
globalQuery,searchHistory,recentEntities

## Type
SearchState

## Persist Policy
searchHistory(max50),recentEntities(max20)

## Notes
