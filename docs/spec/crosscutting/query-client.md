---
id: arch.query-client
title: QUERY_CLIENT
type: architecture
status: draft
version: 1.0.0
compressed: |
PARAM|VALUE
staleTime|5min (chat:0,gcTime=∞)
retry|2
refetchOnWindowFocus|false
cache key pattern|[moduleKey,...]
error handling|network→retry→toast;401→refresh→redirect;403→toast+log;429→[RL];500→ErrorBoundary/toast
mutations|useOptimisticMutation wrapper
SSE|useSSE for AI streams,abortable,retry3 backoff
org switch|invalidate all queries,reconnect Realtime
last_updated: 2026-04-24T23:22:41.116003+00:00
---

# QUERY_CLIENT

PARAM|VALUE
staleTime|5min (chat:0,gcTime=∞)
retry|2
refetchOnWindowFocus|false
cache key pattern|[moduleKey,...]
error handling|network→retry→toast;401→refresh→redirect;403→toast+log;429→[RL];500→ErrorBoundary/toast
mutations|useOptimisticMutation wrapper
SSE|useSSE for AI streams,abortable,retry3 backoff
org switch|invalidate all queries,reconnect Realtime
