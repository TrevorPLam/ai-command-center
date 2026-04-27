---
title: "Operations Infrastructure"
owner: "Operations"
status: "active"
updated: "2026-04-26"
canonical: ""
---

This document describes operational infrastructure including observability, SLOs, disaster recovery, load testing, deployment strategy, and performance monitoring.

---

## Observability & SLOs

- (HARD) OpenTelemetry v1.40 with GenAI attributes mandatory for all AI interactions; `OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai`.
- (HARD) PII redacted at the collector level before traces are exported.

**Service Level Objectives:**

- TTFT (time to first token) ≤ 2 seconds at p95
- Availability 99.9%
- RAG response time ≤ 500 ms at p95
- LCP ≤ 800 ms at p75
- INP ≤ 200 ms

- (HARD) Multi-burn-rate alerting: P1 incidents fire if burn rate > 2% in 1 hour + 5 minutes; P2 fires at 6-hour window; P3 at 3-day window.
- (HARD) Error budget actions: at 50% consumed - notify; at 80% - feature freeze; at 100% - declare incident.

---

## Section 1: Disaster Recovery / Business Continuity Planning

### Quick Reference: Recovery Objectives

| Component | RTO | RPO |
| :--- | :--- | :--- |
| FastAPI | 5 min | 0 data loss |
| Database | 1 hour | 15 min max loss |

### Recovery Objectives

#### Recovery Time Objective (RTO)

- **FastAPI**: 5 minutes
- **Database**: 1 hour

#### Recovery Point Objective (RPO)

- **FastAPI**: 0 data loss (synchronous replication)
- **Database**: 15 minutes maximum data loss

### Testing

- **Chaos Tests**: Monthly chaos engineering tests
- **Backup Verification**: Weekly backup restoration tests

### Runbooks

- **Location**: `ops/dr/` directory
- **Coverage**: All critical failure scenarios

### Compliance

- **NIS2**: Full audit trail compliance (see compliance-nis2.md)
- **SOC2**: All incidents logged to SOC2 evidence repository
- **Documentation**: All recovery actions logged

---

## Section 2: Load Testing

### Testing Tools

- **k6**: Primary load testing framework
- **Artillery**: Secondary testing for complex scenarios

### Load Targets

#### Global Capacity

- **Target**: 1000 requests/second sustained

#### Per-User Limits

- **Chat**: 200 messages/minute per user

### Testing Schedule

- **Start**: 4-6 weeks before launch
- **Frequency**: Weekly during pre-launch phase
- **Regression**: After major deployments

### Test Types

#### Stress Test

- **Load**: 200% of peak expected traffic
- **Duration**: 2 hours sustained
- **Purpose**: Identify breaking points

#### Soak Test

- **Load**: 80% of peak expected traffic
- **Duration**: 8 hours sustained
- **Purpose**: Detect memory leaks and degradation

### Failure Criteria

Tests fail if any of the following occur:

- **p95 latency**: >2x baseline
- **Timeout rate**: >5 seconds response time
- **Error rate**: >0.1% non-2xx responses
- **Resource exhaustion**: Memory or CPU limits hit

---

## Section 3: Deployment Strategy

### Zero-Downtime Rolling Deployments

**Kubernetes Rolling Update Pattern:**

- Creates new ReplicaSet gradually while scaling down old one
- Key parameters control speed and safety:
  - `maxUnavailable`: Maximum pods unavailable during update
  - `maxSurge`: Maximum extra pods created above desired count
- Example: 4 replicas, maxUnavailable=1, maxSurge=1 ensures 75% availability

**Health Check Requirements:**

- Readiness probes: Pod ready to accept traffic
- Liveness probes: Pod healthy and running
- Graceful shutdown: Lifecycle hooks for cleanup
- Pre-start health checks: Before traffic routing

**Rollback Procedures:**

- Automatic rollback on health check failure
- Manual rollback via `kubectl rollout undo`
- Pausing rollouts for verification
- Monitoring deployment progress via metrics

**Reliability Validation:**

- Zero downtime achievable with proper configuration
- Health checks critical for preventing failed deployments
- Rolling updates provide gradual, controlled rollout
- Max surge provides buffer for capacity during transition

---

## Section 4: Performance Monitoring

### Supabase Performance Characteristics

| Service | Metric | Value | Source |
| :--- | :--- | :--- | :--- |
| Edge Functions | Cold Start Latency (median) | 400ms | GitHub #29301 (Oct 2024) |
| Edge Functions | Hot Start Latency (median) | 125ms | GitHub #29301 (Oct 2024) |
| Edge Functions | Regional Variation | ±100ms from median | Supabase maintainer |
| Edge Functions | Bundle Format | ESZip | Supabase Architecture docs |
| Realtime | Channel Ceiling per Connection | 100 channels | Supabase Realtime Concepts |
| Realtime | Concurrent Peak Connections (Free) | 200 | Supabase community |
| Realtime | Concurrent Peak Connections (Pro) | 500 included, $10/1,000 additional | Supabase Pricing docs |
| Realtime | Message Pricing | $2.50 per 1M messages | Supabase Pricing docs |
| Realtime | Heartbeat Interval (default) | 25 seconds | Supabase Heartbeat docs |
| Realtime | Cluster Capacity | Millions concurrent | Supabase Limits docs |
