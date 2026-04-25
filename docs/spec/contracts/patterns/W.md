---
id: pattern.W
type: pattern
tag: '@W'
compressed_description: 'workflow execution (topo sort,parallel,retry3 exp backoff,pause/resume/cancel,Zustand state machine: pending→running→{waiting_for_approval,waiting_for_event}→resuming→completed/failed/cancelled; parallel branches with join gates)'
order: 10
last_updated: '2026-04-25T00:07:50.858633+00:00'
---

# @W

workflow execution (topo sort,parallel,retry3 exp backoff,pause/resume/cancel,Zustand state machine: pending→running→{waiting_for_approval,waiting_for_event}→resuming→completed/failed/cancelled; parallel branches with join gates)
