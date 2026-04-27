---
title: "Operations Manual"
owner: "DevOps"
status: "active"
updated: "2026-04-26"
canonical: ""
---

This document describes the operational procedures including disaster recovery, incident response, load testing, runbooks, and team structure for the AI Command Center platform.

---

## Observability & SLOs

- (HARD) OpenTelemetry v1.40 with GenAI attributes mandatory for all AI interactions; `OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai`.
- (HARD) PII redacted at the collector level before traces are exported.
- **Service Level Objectives**:
  - TTFT (time to first token) ≤ 2 seconds at p95
  - Availability 99.9%
  - RAG response time ≤ 500 ms at p95
  - LCP ≤ 800 ms at p75
  - INP ≤ 200 ms
- (HARD) Multi‑burn‑rate alerting: P1 incidents fire if burn rate > 2% in 1 hour + 5 minutes; P2 fires at 6‑hour window; P3 at 3‑day window.
- (HARD) Error budget actions: at 50% consumed - notify; at 80% - feature freeze; at 100% - declare incident.

---

## Section 1: Disaster Recovery / Business Continuity Planning

### Quick Reference: Recovery Objectives

| Component | RTO | RPO |
|-----------|-----|-----|
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
- **NIS2**: Full audit trail compliance (see Section 6: NIS2 Compliance)
- **SOC2**: All incidents logged to SOC2 evidence repository
- **Documentation**: All recovery actions logged

---

## Section 2: Incident Response

### Severity Levels

| Severity | Definition | Response Time | Escalation |
| :--- | :--- | :--- | :--- |
| SEV0 - Critical | Complete system outage or data breach | Immediate (15 min) | CEO + security team |
| SEV1 - High | Major feature degradation affecting all users | 1 hour | VP Engineering |
| SEV2 - Medium | Partial feature degradation or performance issues | 4 hours | Team Lead |
| SEV3 - Low | Minor issues or cosmetic problems | Next business day | Ticket queue |

### Pre-Approved Templates

#### Outage Response
- Immediate rollback capability
- Communication plan to users
- Status page updates

#### Data Breach Response
- Immediate containment
- GDPR notification procedures
- Forensic investigation

#### Degraded Performance
- Scaling procedures
- Load balancing adjustments
- Circuit breaker activation

#### Third-Party Failure
- Fallback to local models
- Graceful degradation
- Vendor communication

### Compliance
- **SOC2**: All incidents logged to SOC2 evidence repository
- **Documentation**: Post-mortem required within 48 hours

---

## Section 3: Load Testing

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

## Section 4: Operational Runbooks

### Quick Reference: Runbook Index

| Subsection | Runbooks |
|------------|----------|
| 4.1 Incident Response | AI Failure, Supabase Outage, Spec Validation Failure |
| 4.2 Cross-Cutting Issues | Motion Violations, Realtime Memory Issues |
| 4.3 Testing Failures | Security RLS Failure, AI Evaluation Accuracy Drop |
| 4.4 Operational Procedures | P0 Incident Trigger, Feature Flag Kill Switch, Cost Budget Exceeded |
| 4.5 Migration Issues | SQLModel Migration Drift, Y-Sweet Migration, LiteLLM Upgrade, Orval Upgrade, Claude 4.6 Migration, OpenAI Migration, TypeScript 7.0 CI, React 20 Migration, Expo 5.5 Migration |
| 4.6 Observability & Monitoring | Burn Rate Alerts |
| 4.7 Security Incidents | SSRF Bypass, AI Guardrail Violations, MCP Inspector Isolation, DND Kit Audit, MCP Audit, Tauri Cap CI |
| 4.8 Data Integrity | Offline Sync Issues, Upload Security, Y-Sweet Offline, Nylas Grant Expired |
| 4.9 Calendar & Recurrence | DST Test Failure, Temporal Polyfill |
| 4.10 Monitoring & Alerting | Key Metrics, Alert Thresholds, SOC2 Compliance |

### 4.1 Incident Response Playbooks

#### AI Failure

**Trigger**: >5 errors/60s

**Actions**:
1. Activate circuit breaker
2. Fallback to gpt-4o → claude
3. Notify Sentry + Slack
4. Monitor recovery
5. Post-incident analysis

**Escalation**: P0 if fallback fails

#### Supabase Outage
**Trigger**: DB unreachable >2min

**Actions**:
1. Enable read-only mode
2. Display outage banner
3. Disable Realtime fallbacks
4. Monitor DB health
5. Coordinate with Supabase support
6. Gradual re-enable of write operations

**Escalation**: P1 if recovery >30min

#### Spec Validation Failure
**Trigger**: Invalid YAML or missing sections

**Actions**:
1. Block DoD1 completion
2. Notify component author via PR
3. Require spec fixes before merge
4. Update spec validation CI
5. Enhance spec template validation

**Escalation**: P2 if blocking release

### 4.2 Cross-Cutting Issues

#### Motion Violations
**Trigger**: Layout animations detected

**Actions**:
1. CI block deployment
2. Require transform/opacity only
3. Update motion guidelines
4. Review component animation patterns

**Escalation**: P2 if blocking release

#### Realtime Memory Issues
**Trigger**: Channel memory >40MB

**Actions**:
1. Alert operations team
2. Consider channel splitting
3. Enable compaction
4. Review memory usage patterns

**Escalation**: P1 if >100MB

### 4.3 Testing Failures

#### Security RLS Failure
**Trigger**: Row Level Security isolation failure

**Actions**:
1. Block deployment
2. Fix RLS policies
3. Run security test suite
4. Verify tenant isolation

**Escalation**: P0 if data leak risk

#### AI Evaluation Accuracy Drop
**Trigger**: Accuracy <base-2%

**Actions**:
1. Block PR deployment
2. Adjust prompts/models
3. Retrain evaluation models
4. Update accuracy thresholds

**Escalation**: P1 if >5% drop

### 4.4 Operational Procedures

#### P0 Incident Trigger
**Trigger**: P0 incident declared

**Actions**:
1. Page on-call engineer
2. 15-minute update cadence
3. Auto-populate SOC2 log
4. Incident commander assignment

**Escalation**: CTO 30min

#### Feature Flag Kill Switch
**Trigger**: Critical bug or performance issue

**Actions**:
1. Revert to 0% within 5 minutes
2. Notify affected users
3. Postmortem within 48 hours
4. Review kill switch procedures

**Escalation**: CTO if revert fails

#### Cost Budget Exceeded
**Trigger**: Monthly budget exceeded

**Actions**:
1. Block all AI requests (429)
2. Display CostLimitBanner
3. Enable admin override
4. Suggest upgrade options

**Escalation**: VP Engineering if enterprise

### 4.5 Migration Issues

#### SQLModel Migration Drift
**Trigger**: CI detects schema drift

**Actions**:
1. Block deployment
2. Require migrate deploy
3. Review migration scripts
4. Update drift detection

**Escalation**: P2 if blocking release

#### Y-Sweet Migration
**Trigger**: Y-Sweet service migration required

**Actions**:
1. Deploy Docker container
2. Migrate S3 bucket
3. Switch clients to new endpoint
4. Fallback: Vercel KV session storage temporary

**Escalation**: P1 if migration >24h

#### LiteLLM Upgrade
**Trigger**: Security advisory or feature requirement

**Actions**:
1. Upgrade litellm to >=1.83.7
2. Verify with cosign
3. Run CVE scan
4. Rotate keys if prior version used

**Escalation**: P0 if CVE critical

#### Orval Upgrade
**Trigger**: Security advisory or feature requirement

**Actions**:
1. Upgrade orval to >=8.2.0
2. Regenerate types
3. Reject OAS patterns []()!+
4. Ensure no untrusted specs in pipeline

**Escalation**: P1 if breaking changes

#### Claude 4.6 Migration
**Trigger**: Model deprecation notice (June 15, 2026)

**Actions**:
1. Update all model IDs to 4.6 suffixed
2. Verify completion and token limits (1M context)
3. Remove Sonnet/Opus 4 references
4. Test all AI flows

**Escalation**: P1 if blocking release

#### OpenAI Migration
**Trigger**: Assistants API deprecation (Aug 26)

**Actions**:
1. Scan all AI calls
2. Replace Assistants API with Responses API
3. Verify Vercel AI SDK v6 responses support
4. Run eval gate

**Escalation**: P1 if blocking release

#### TypeScript 7.0 CI
**Trigger**: TypeScript 7.0 release

**Actions**:
1. Test tsgo in CI
2. Verify ESLint plugins & codemods compatibility
3. Fallback to tsc 6.0 if issues
4. Update build pipeline

**Escalation**: P2 if build failures

#### React 20 Migration
**Trigger**: React 20 release (Q2/Q3 2026)

**Actions**:
1. Q2: Create React20 branch
2. Validate RHF/Zustand carveouts
3. Test performance and Compiler compatibility
4. Q3: Roll out gradually

**Escalation**: P1 if blocking release

#### Expo 5.5 Migration
**Trigger**: Expo 5.5 release

**Actions**:
1. Audit libs via expo-doctor
2. Migrate /app→/src/app
3. Test Hermes v1 OTA
4. Pin Reanimated v3

**Escalation**: P1 if breaking changes

### 4.6 Observability & Monitoring

#### Burn Rate Alerts
**Trigger**: BR >2%/1h (warning) or >5%/6h (critical)

**Actions**:
1. Page on-call (warning)
2. Slack notification (critical)
3. Stability fixes and resource optimization
4. Review scaling configuration

**Escalation**: VP Engineering if >10%/6h

### 4.7 Security Incidents

#### SSRF Bypass
**Trigger**: Outbound request bypasses allowlist

**Actions**:
1. Block malicious requests
2. Log security event
3. Alert SOC team
4. Update allowlist rules

**Escalation**: P0 if confirmed exploit

#### AI Guardrail Violations
**Trigger**: PII, jailbreak, or toxic content detected

**Actions**:
- Input Block: Redact PII, block jailbreak, filter toxic content
- Privacy Violation: Block opted-out data, alert privacy officer, review segregation

**Escalation**: P0 if data breach risk

#### MCP Inspector Isolation
**Trigger**: CVE-2025-49596 or security audit finding

**Actions**:
1. Disable network binding for MCP Inspector in dev
2. Block inbound tcp:3000 from non-localhost
3. Monitor CVE-2025-49596
4. Verify isolation in production

**Escalation**: P0 if exploit detected

#### DND Kit Audit
**Trigger**: Security audit or dependency review

**Actions**:
1. Verify dnd-kit pin (6.3.1)
2. Audit all drag operations
3. NO migration to PragmaticDnD
4. Document security posture

**Escalation**: P2 if vulnerabilities found

#### MCP Audit
**Trigger**: Continuous monitoring of MCP SDK advisories

**Actions**:
1. Monitor advisories from OX, OWASP, Anthropic
2. Enforce MCPSec L2
3. Block non-L2 servers from production
4. Quarterly security review

**Escalation**: P0 if L2 violation in production

#### Tauri Cap CI
**Trigger**: Capability drift detection

**Actions**:
1. Validate capabilities/*.json against window manifests
2. Block deploy on capability drift
3. Review security implications
4. Update documentation

**Escalation**: P0 if security risk

### 4.8 Data Integrity

#### Offline Sync Issues
**Trigger**: Hard delete without tombstone

**Actions**:
1. Add deleted_at column
2. Backfill existing records
3. Update sync logic
4. Test offline/online sync

**Escalation**: P2 if data loss

#### Upload Security
**Trigger**: ClamAV scan failure or CVE

**Actions**:
1. Quarantine uploaded file
2. Alert security team
3. Patch vulnerable components
4. Update scan configurations

**Escalation**: P0 if malware detected

#### Y-Sweet Offline
**Trigger**: Offline sync implementation required

**Actions**:
1. Configure offlineSupport provider
2. Sync on reconnect
3. Test client-side Yjs doc merge
4. Verify conflict resolution

**Escalation**: P2 if data loss

#### Nylas Grant Expired
**Trigger**: grant.expired webhook

**Actions**:
1. Disable sync
2. Notify user
3. Provide re-auth URL
4. Backfill if re-authed <72h, else warn data loss

**Escalation**: P2 if data loss >24h

#### Nylas Webhook Failure Patterns

Nylas uses a two-tier failure state model for webhook endpoints:

**Failing State (15-minute window)**
- Triggered when Nylas receives 95% non-200 responses or non-responses over 15 minutes
- While in failing state, Nylas continues delivering webhook notifications for 72 hours with exponential backoff
- Email notification sent when endpoint transitions to failing state
- Add ``@nylas`.com` to email allowlist to prevent notifications from going to spam

**Failed State (72-hour window)**
- Triggered when 95% non-200 responses or non-responses persist over 72 hours
- Webhook endpoint marked as failed and stops receiving notifications
- Email notification sent when endpoint transitions to failed state
- Manual reactivation required via Nylas Dashboard or Webhooks API
- Nylas does NOT send notifications for events that occurred while endpoint was failed
- Events missed during failed state are lost unless manually retrieved via API polling

**Industry Comparison**
- Nylas's 95% threshold is more conservative than typical circuit breaker patterns (50% failure rate)
- This design choice reduces false positives from transient failures
- Hookdeck guide suggests 50% failure rate over 1-minute window or 5 of 10 requests failed for circuit breakers

**Monitoring Actions**:
1. Monitor webhook failure rate alerts
2. If failure rate exceeds 5% over 5 minutes, investigate immediately
3. Check webhook endpoint health and response times
4. Verify HMAC-SHA256 signature validation is working
5. Review Nylas Dashboard for webhook status
6. If approaching 95% threshold over 15-minute window, prepare for failing state
7. If approaching 72-hour failed state, prepare for manual reactivation

#### Nylas Grant Expiration Handling (Detailed)

**Best Practices**
- Subscribe to `grant.*` notifications (recommended approach) to monitor status changes
- When `grant.expired` notification received, prompt user to re-authenticate immediately
- Alternative methods: Poll Get all grants endpoint and check `grant_status`, or monitor Nylas Dashboard
- Nylas cannot access user data when grant is expired

**Re-authentication Flow**
- When user re-authenticates successfully, Nylas checks when grant was last valid
- If grant was out of service < 72 hours: Nylas sends backfill notifications for changes during outage
- If grant was out of service > 72 hours: Nylas does NOT send backfill notifications
- For > 72 hour outages: Query Nylas APIs for objects that changed between `grant.expired` and `grant.updated` timestamps

**Critical Limitation**
- Message tracking events (message.opened, message.link_clicked, thread.replied) cannot be backfilled if grant was out of service > 72 hours
- These events are permanently lost and must be accepted as data gap
- Support cannot replay webhooks - manual API retrieval is the only recovery mechanism

**Operational Actions**:
1. Monitor `grant.expired` webhook notifications
2. Track grants approaching expiration (daily cron job recommended)
3. Prompt users to re-authenticate before grant expires
4. When grant expires, disable sync and notify user immediately
5. Provide clear re-authentication URL and instructions
6. After re-authentication, check if grant was out of service <72 hours
7. If <72 hours: Monitor for backfill notifications from Nylas
8. If >72 hours: Warn user of potential data loss and manual retrieval options
9. Document all grant expiration events for audit trail

### 4.9 Calendar & Recurrence

#### DST Test Failure
**Trigger**: Timezone handling fails

**Actions**:
1. Block deployment
2. Fix TZID handling
3. Update recurrence engine
4. Enhance DST test matrix

**Escalation**: P2 if blocking release

#### Temporal Polyfill
**Trigger**: Safari Temporal support issues

**Actions**:
1. Feature detection: native Temporal if available
2. Use temporal-polyfill as fallback
3. Test on Safari
4. Verify date handling

**Escalation**: P2 if date bugs

### 4.10 Monitoring & Alerting

#### Key Metrics
- AI error rate
- Database connectivity
- Spec validation pass rate
- Realtime channel memory
- Cost budget utilization
- Security incident count

#### Alert Thresholds
- P0: Immediate paging
- P1: 15-minute response
- P2: 1-hour response
- P3: 24-hour response

#### SOC2 Compliance
- All incidents logged
- Automated evidence collection
- Quarterly audit preparation
- Control effectiveness testing

---

## Section 5: Team & Ownership

### Quick Reference: Domain Ownership

| Domain | Owner | Key SLAs |
|--------|-------|----------|
| Platform Foundation | Platform Engineering | Build <5min, deploy daily |
| Data & Sync | Data Platform | Sync <500ms, query p95<2s |
| AI Core & Agents | AI/ML Engineering | Latency <2s, halluc≤2% |
| Frontend & UX | Product Engineering | LCP≤800ms, INP≤200ms |
| Security & Compliance | Security/GRC | Response <15min, audit ready |
| Business Strategy | Product/GTM | Revenue growth tracked |

### 5.1 Ownership & Accountability

#### RACI Matrix

| Task | Platform | Data | AI | Frontend | Security | Product | GRC |
|------|----------|------|----|----------|----------|---------|-----|
| AI Cost Tracking | C | A | R | C | I | A | I |
| Agent Studio | C | I | R | C | I | A | I |
| MCP Security | I | I | R | C | R | A | A |
| Guardrails Engine | I | I | R | C | R | A | A |
| Offline Sync | C | R | C | I | I | I | I |
| Real-time Collab | C | C | I | R | I | I | I |
| Feature Flags | C | I | I | R | I | A | I |
| Observability | C | C | C | C | R | I | I |
| A2A Integration | I | I | R | C | R | A | I |
| Compliance Pipeline | I | I | I | I | R | R | A |
| CSP Policy | I | I | I | I | R | R | A |
| Rate Limiting | C | I | I | I | R | I | I |
| Secrets Rotation | C | I | I | I | R | R | A |
| Incident Response | C | C | C | C | R | I | I |
| SOC2 Evidence | I | I | I | I | R | R | A |

#### Ownership Matrix

| Domain | Owner | Backup | SLA | Escalation |
|--------|-------|--------|-----|------------|
| Platform Foundation | Platform Engineering | DevOps Lead | Senior SRE | Build times<5min,deploy freq daily | CTO |
| Data & Sync | Data Platform | Data Lead | Senior Data Engineer | Sync latency<500ms,query p95<2s | VP Engineering |
| AI Core & Agents | AI/ML Engineering | AI Lead | Senior ML Engineer | Model latency<2s,halluc≤2% | CTO |
| Frontend & UX | Product Engineering | Frontend Lead | Senior FE Engineer | LCP≤800ms,INP≤200ms | VP Engineering |
| Security & Compliance | Security/GRC | Security Lead | Senior Security Engineer | Incident response<15min,audit ready | CTO |
| Business Strategy | Product/GTM | Product Lead | Senior PM | Revenue growth tracked,acquisition cost monitored | CEO |

### 5.2 On-Call & Escalation

#### On-Call Rotation

| Role | Rotation | Coverage | Response Time | Escalation | Handoff |
|------|----------|----------|---------------|------------|---------|
| P0 Incident | All Leads | Weekly 24/7 | 15min immediate | CTO 30min | Written postmortem 48h |
| P1 Platform | Platform Engineering | Weekly 24/7 | 1 hour | VP Engineering 2 hours | Ticket handoff with notes |
| P1 Data | Data Platform | Weekly 24/7 | 1 hour | VP Engineering 2 hours | Ticket handoff with notes |
| P1 AI | AI/ML Engineering | Weekly 24/7 | 1 hour | CTO 2 hours | Ticket handoff with notes |
| P1 Frontend | Product Engineering | Weekly 24/7 | 1 hour | VP Engineering 2 hours | Ticket handoff with notes |
| P1 Security | Security/GRC | Weekly 24/7 | 15 minutes | CTO 30 minutes | Security audit log |
| P2 Issues | All Teams | Business hours only | 4 hours | Team Lead next business day | Ticket queue assignment |

#### Escalation Matrix

| Level | Trigger | Contact | Response | Decision |
|-------|---------|---------|----------|----------|
| L1 | Routine issue | Team Slack | Team Lead responds within 1h | Team Lead resolves |
| L2 | Team blocked | Team Lead unresponsive | VP Engineering responds within 30min | VP Engineering unblocks |
| L3 | Cross-team impact | Multiple teams blocked | CTO responds within 15min | CTO coordinates resources |
| L4 | Critical incident | P0 production outage | CEO notified immediately | CEO directs crisis response |
| L5 | Security breach | Confirmed exploit | Legal/PR notified immediately | Crisis management team activated |

### 5.3 Team Structure

#### Roles & Responsibilities

| Role | Responsibilities | Skills | On Call | Backup |
|------|------------------|--------|---------|--------|
| Platform Lead | Infra,CI/CD,deployment | Kubernetes,Fly.io,Turborepo | Yes | Senior SRE |
| Data Lead | DB,sync,vector store | Postgres,TimescaleDB,pgvector | Yes | Senior Data Engineer |
| AI Lead | LLM gateway,agents,guardrails | LangChain,LiteLLM,eval frameworks | Yes | Senior ML Engineer |
| Frontend Lead | React,performance,a11y | React 19,Motion,Tailwind | Yes | Senior FE Engineer |
| Security Lead | MCP,CSP,audit | OWASP,MCPSec,Vault | Yes | Senior Security Engineer |
| Product Lead | PRD,roadmap,metrics | RICE,MoSCoW,analytics | No | Senior PM |
| GRC Lead | SOC2,EU AI Act,compliance | Vanta,PIA,evidence pipeline | No | Compliance Analyst |

#### Skills Matrix

| Skill | Team | Proficiency | Training | Certification |
|-------|------|-------------|----------|--------------|
| Kubernetes | Platform | Expert | quarterly K8s training | CKA |
| Postgres | Data | Expert | Postgres Deep Dive course | Postgres Certified |
| LangChain | AI | Expert | LangChain workshops | Internal cert |
| React 19 | Frontend | Expert | React Conf attendance | Meta cert |
| OWASP MCP | Security | Expert | OWASP training | CISSP |
| SOC2 | GRC | Expert | Vanta training | SOC2 audit experience |
| Incident Response | All | Intermediate | GameDay exercises | ITIL Foundation |

### 5.4 Operations

#### Meeting Schedule

| Meeting | Frequency | Attendees | Duration | Purpose |
|---------|-----------|-----------|----------|---------|
| Daily Standup | Daily | All engineers | 15min | Blockers,progress,plan |
| Weekly Planning | Weekly | All leads | 1h | Sprint planning,review,retro |
| Biweekly Architecture | Biweekly | Tech leads | 1h | Design reviews,ADR discussions |
| Monthly All-Hands | Monthly | All company | 1h | Roadmap,metrics,announcements |
| Quarterly Planning | Quarterly | All leads | 4h | OKR setting,resource allocation |
| Incident Review | Ad-hoc | On-call team | 1h | Postmortem,action items |
| Security Review | Monthly | Security+GRC | 1h | Vulnerability scan,compliance status |

#### Communication Channels

| Channel | Purpose | Audience | Etiquette |
|----------|---------|----------|----------|
| #incidents | P0/P1 incidents | All engineers | Alerts only,use threads for discussion |
| #platform | Platform issues | Platform team | Technical discussions,decisions |
| #data | Data issues | Data team | Schema changes,performance |
| #ai | AI issues | AI team | Model changes,eval results |
| #frontend | Frontend issues | Frontend team | UI/UX discussions,performance |
| #security | Security issues | Security+GRC | Vulnerabilities,compliance |
| #product | Product updates | All | Roadmap,features,metrics |
| #random | Non-work | All | Social,team building | No work discussions |

#### Decision Framework

| Type | Maker | Consult | Inform | Timeline | Appeal |
|------|-------|--------|-------|----------|--------|
| Technical | Tech Lead | Team | All | Immediate | CTO |
| Product | Product Lead | Stakeholders | All | Weekly | CEO |
| Security | Security Lead | GRC | CTO | Immediate | CEO |
| Budget | VP Engineering | Finance | CTO | Monthly | CEO |
| Hiring | Hiring Manager | Team | HR | As needed | CEO |
| Pricing | Product Lead | Sales | CEO | Quarterly | Board |

#### Domain Ownership Map (April 2026)

| Domain | Owner | Backup | Cross-Cutting |
|--------|-------|--------|---------------|
| A: Platform & DX | Platform Eng | Senior SRE | DB infra,CI/CD,monorepo |
| B: Data & Sync | Data Platform | Data Lead | AI vector/graph,frontend sync state |
| C: AI Core & Agents | AI/ML Eng | AI Lead | Frontend GenUI streaming,business metering |
| D: Frontend & UX | Product Eng | Frontend Lead | AI prompt/agent UI,business telemetry |
| E: Security & GRC | Security/GRC | Security Lead | Identity,audit,compliance across all |
| F: Business & Monetization | Product/GTM | Product Lead | Budget gates,feature flags |

---

## Section 6: Performance Monitoring

### Supabase Performance Characteristics

| Service | Metric | Value | Source |
|---------|--------|-------|--------|
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

---

## Section 7: Deployment Strategy

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

## Section 7: NIS2 Compliance

NIS2 Directive (EU 2022/2555) establishes unified cybersecurity framework for 18 critical sectors. Full compliance documentation including requirements, audit trails, gap analysis, and implementation roadmap in [compliance/compliance-nis2.md](compliance/compliance-nis2.md).

---