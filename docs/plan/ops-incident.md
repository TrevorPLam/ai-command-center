---
title: "Operational Incident Runbooks"
owner: "Operations"
status: "active"
updated: "2026-04-26"
canonical: ""
---

This document contains operational runbooks for incident response, cross-cutting issues, testing failures, operational procedures, migration issues, observability, security incidents, data integrity, calendar & recurrence, and monitoring.

---

## Quick Reference: Runbook Index

| Subsection | Runbooks |
| :--- | :--- |
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

---

## 4.1 Incident Response Playbooks

### AI Failure

**Trigger**: >5 errors/60s

**Severity**: P0 if fallback fails

**Actions:**

1. Activate circuit breaker
2. Fallback to gpt-4o → claude
3. Notify Sentry + Slack
4. Monitor recovery
5. Post-incident analysis

**Escalation**: P0 if fallback fails

---

### Supabase Outage

**Trigger**: DB unreachable >2min

**Severity**: P1 if recovery >30min

**Actions:**

1. Enable read-only mode
2. Display outage banner
3. Disable Realtime fallbacks
4. Monitor DB health
5. Coordinate with Supabase support
6. Gradual re-enable of write operations

**Escalation**: P1 if recovery >30min

---

### Spec Validation Failure

**Trigger**: Invalid YAML or missing sections

**Severity**: P2 if blocking release

**Actions:**

1. Block DoD1 completion
2. Notify component author via PR
3. Require spec fixes before merge
4. Update spec validation CI
5. Enhance spec template validation

**Escalation**: P2 if blocking release

---

## 4.2 Cross-Cutting Issues

### Motion Violations

**Trigger**: Layout animations detected

**Severity**: P2 if blocking release

**Actions:**

1. CI block deployment
2. Require transform/opacity only
3. Update motion guidelines
4. Review component animation patterns

**Escalation**: P2 if blocking release

---

### Realtime Memory Issues

**Trigger**: Channel memory >40MB

**Severity**: P1 if >100MB

**Actions:**

1. Alert operations team
2. Consider channel splitting
3. Enable compaction
4. Review memory usage patterns

**Escalation**: P1 if >100MB

---

## 4.3 Testing Failures

### Security RLS Failure

**Trigger**: Row Level Security isolation failure

**Severity**: P0 if data leak risk

**Actions:**

1. Block deployment
2. Fix RLS policies
3. Run security test suite
4. Verify tenant isolation

**Escalation**: P0 if data leak risk

---

### AI Evaluation Accuracy Drop

**Trigger**: Accuracy <base-2%

**Severity**: P1 if >5% drop

**Actions:**

1. Block PR deployment
2. Adjust prompts/models
3. Retrain evaluation models
4. Update accuracy thresholds

**Escalation**: P1 if >5% drop

---

## 4.4 Operational Procedures

### P0 Incident Trigger

**Trigger**: P0 incident declared

**Severity**: CTO 30min

**Actions:**

1. Page on-call engineer
2. 15-minute update cadence
3. Auto-populate SOC2 log
4. Incident commander assignment

**Escalation**: CTO 30min

---

### Feature Flag Kill Switch

**Trigger**: Critical bug or performance issue

**Severity**: CTO if revert fails

**Actions:**

1. Revert to 0% within 5 minutes
2. Notify affected users
3. Postmortem within 48 hours
4. Review kill switch procedures

**Escalation**: CTO if revert fails

---

### Cost Budget Exceeded

**Trigger**: Monthly budget exceeded

**Severity**: VP Engineering if enterprise

**Actions:**

1. Block all AI requests (429)
2. Display CostLimitBanner
3. Enable admin override
4. Suggest upgrade options

**Escalation**: VP Engineering if enterprise

---

## 4.5 Migration Issues

### SQLModel Migration Drift

**Trigger**: CI detects schema drift

**Severity**: P2 if blocking release

**Actions:**

1. Block deployment
2. Require migrate deploy
3. Review migration scripts
4. Update drift detection

**Escalation**: P2 if blocking release

---

### Y-Sweet Migration

**Trigger**: Y-Sweet service migration required

**Severity**: P1 if migration >24h

**Actions:**

1. Deploy Docker container
2. Migrate S3 bucket
3. Switch clients to new endpoint
4. Fallback: Vercel KV session storage temporary

**Escalation**: P1 if migration >24h

---

### LiteLLM Upgrade

**Trigger**: Security advisory or feature requirement

**Severity**: P0 if CVE critical

**Actions:**

1. Upgrade litellm to >=1.83.7
2. Verify with cosign
3. Run CVE scan
4. Rotate keys if prior version used

**Escalation**: P0 if CVE critical

---

### Orval Upgrade

**Trigger**: Security advisory or feature requirement

**Severity**: P1 if breaking changes

**Actions:**

1. Upgrade orval to >=8.2.0
2. Regenerate types
3. Reject OAS patterns `[]()!+`
4. Ensure no untrusted specs in pipeline

**Escalation**: P1 if breaking changes

---

### Claude 4.6 Migration

**Trigger**: Model deprecation notice (June 15, 2026)

**Severity**: P1 if blocking release

**Actions:**

1. Update all model IDs to 4.6 suffixed
2. Verify completion and token limits (1M context)
3. Remove Sonnet/Opus 4 references
4. Test all AI flows

**Escalation**: P1 if blocking release

---

### OpenAI Migration

**Trigger**: Assistants API deprecation (Aug 26)

**Severity**: P1 if blocking release

**Actions:**

1. Scan all AI calls
2. Replace Assistants API with Responses API
3. Verify Vercel AI SDK v6 responses support
4. Run eval gate

**Escalation**: P1 if blocking release

---

### TypeScript 7.0 CI

**Trigger**: TypeScript 7.0 release

**Severity**: P2 if build failures

**Actions:**

1. Test tsgo in CI
2. Verify ESLint plugins & codemods compatibility
3. Fallback to tsc 6.0 if issues
4. Update build pipeline

**Escalation**: P2 if build failures

---

### React 20 Migration

**Trigger**: React 20 release (Q2/Q3 2026)

**Severity**: P1 if blocking release

**Actions:**

1. Q2: Create React20 branch
2. Validate RHF/Zustand carveouts
3. Test performance and Compiler compatibility
4. Q3: Roll out gradually

**Escalation**: P1 if blocking release

---

### Expo 5.5 Migration

**Trigger**: Expo 5.5 release

**Severity**: P1 if breaking changes

**Actions:**

1. Audit libs via expo-doctor
2. Migrate /app→/src/app
3. Test Hermes v1 OTA
4. Pin Reanimated v3

**Escalation**: P1 if breaking changes

---

## 4.6 Observability & Monitoring

### Burn Rate Alerts

**Trigger**: BR >2%/1h (warning) or >5%/6h (critical)

**Severity**: VP Engineering if >10%/6h

**Actions:**

1. Page on-call (warning)
2. Slack notification (critical)
3. Stability fixes and resource optimization
4. Review scaling configuration

**Escalation**: VP Engineering if >10%/6h

---

## 4.7 Security Incidents

### SSRF Bypass

**Trigger**: Outbound request bypasses allowlist

**Severity**: P0 if confirmed exploit

**Actions:**

1. Block malicious requests
2. Log security event
3. Alert SOC team
4. Update allowlist rules

**Escalation**: P0 if confirmed exploit

---

### AI Guardrail Violations

**Trigger**: PII, jailbreak, or toxic content detected

**Severity**: P0 if data breach risk

**Actions:**

- Input Block: Redact PII, block jailbreak, filter toxic content
- Privacy Violation: Block opted-out data, alert privacy officer, review segregation

**Escalation**: P0 if data breach risk

---

### MCP Inspector Isolation

**Trigger**: CVE-2025-49596 or security audit finding

**Severity**: P0 if exploit detected

**Actions:**

1. Disable network binding for MCP Inspector in dev
2. Block inbound tcp:3000 from non-localhost
3. Monitor CVE-2025-49596
4. Verify isolation in production

**Escalation**: P0 if exploit detected

---

### DND Kit Audit

**Trigger**: Security audit or dependency review

**Severity**: P2 if vulnerabilities found

**Actions:**

1. Verify dnd-kit pin (6.3.1)
2. Audit all drag operations
3. NO migration to PragmaticDnD
4. Document security posture

**Escalation**: P2 if vulnerabilities found

---

### MCP Audit

**Trigger**: Continuous monitoring of MCP SDK advisories

**Severity**: P0 if L2 violation in production

**Actions:**

1. Monitor advisories from OX, OWASP, Anthropic
2. Enforce MCPSec L2
3. Block non-L2 servers from production
4. Quarterly security review

**Escalation**: P0 if L2 violation in production

---

### Tauri Cap CI

**Trigger**: Capability drift detection

**Severity**: P0 if security risk

**Actions:**

1. Validate capabilities/*.json against window manifests
2. Block deploy on capability drift
3. Review security implications
4. Update documentation

**Escalation**: P0 if security risk

---

## 4.8 Data Integrity

### Offline Sync Issues

**Trigger**: Hard delete without tombstone

**Severity**: P2 if data loss

**Actions:**

1. Add deleted_at column
2. Backfill existing records
3. Update sync logic
4. Test offline/online sync

**Escalation**: P2 if data loss

---

### Upload Security

**Trigger**: ClamAV scan failure or CVE

**Severity**: P0 if malware detected

**Actions:**

1. Quarantine uploaded file
2. Alert security team
3. Patch vulnerable components
4. Update scan configurations

**Escalation**: P0 if malware detected

---

### Y-Sweet Offline

**Trigger**: Offline sync implementation required

**Severity**: P2 if data loss

**Actions:**

1. Configure offlineSupport provider
2. Sync on reconnect
3. Test client-side Yjs doc merge
4. Verify conflict resolution

**Escalation**: P2 if data loss

---

### Nylas Grant Expired

**Trigger**: grant.expired webhook

**Severity**: P2 if data loss >24h

**Actions:**

1. Disable sync
2. Notify user
3. Provide re-auth URL
4. Backfill if re-authed <72h, else warn data loss

**Escalation**: P2 if data loss >24h

---

### Nylas Webhook Failure Patterns

Nylas uses a two-tier failure state model for webhook endpoints.

#### Failing State (15-minute window)

- Triggered when Nylas receives 95% non-200 responses or non-responses over 15 minutes
- While in failing state, Nylas continues delivering webhook notifications for 72 hours with exponential backoff
- Email notification sent when endpoint transitions to failing state
- Add `@nylas.com` to email allowlist to prevent notifications from going to spam

#### Failed State (72-hour window)

- Triggered when 95% non-200 responses or non-responses persist over 72 hours
- Webhook endpoint marked as failed and stops receiving notifications
- Email notification sent when endpoint transitions to failed state
- Manual reactivation required via Nylas Dashboard or Webhooks API
- Nylas does NOT send notifications for events that occurred while endpoint was failed
- Events missed during failed state are lost unless manually retrieved via API polling

#### Industry Comparison

- Nylas's 95% threshold is more conservative than typical circuit breaker patterns (50% failure rate)
- This design choice reduces false positives from transient failures
- Hookdeck guide suggests 50% failure rate over 1-minute window or 5 of 10 requests failed for circuit breakers

#### Monitoring Actions

1. Monitor webhook failure rate alerts
2. If failure rate exceeds 5% over 5 minutes, investigate immediately
3. Check webhook endpoint health and response times
4. Verify HMAC-SHA256 signature validation is working
5. Review Nylas Dashboard for webhook status
6. If approaching 95% threshold over 15-minute window, prepare for failing state
7. If approaching 72-hour failed state, prepare for manual reactivation

---

### Nylas Grant Expiration Handling (Detailed)

#### Best Practices

- Subscribe to `grant.*` notifications (recommended approach) to monitor status changes
- When `grant.expired` notification received, prompt user to re-authenticate immediately
- Alternative methods: Poll Get all grants endpoint and check `grant_status`, or monitor Nylas Dashboard
- Nylas cannot access user data when grant is expired

#### Re-authentication Flow

- When user re-authenticates successfully, Nylas checks when grant was last valid
- If grant was out of service < 72 hours: Nylas sends backfill notifications for changes during outage
- If grant was out of service > 72 hours: Nylas does NOT send backfill notifications
- For > 72 hour outages: Query Nylas APIs for objects that changed between `grant.expired` and `grant.updated` timestamps

#### Critical Limitation

- Message tracking events (message.opened, message.link_clicked, thread.replied) cannot be backfilled if grant was out of service > 72 hours
- These events are permanently lost and must be accepted as data gap
- Support cannot replay webhooks - manual API retrieval is the only recovery mechanism

#### Operational Actions

1. Monitor `grant.expired` webhook notifications
2. Track grants approaching expiration (daily cron job recommended)
3. Prompt users to re-authenticate before grant expires
4. When grant expires, disable sync and notify user immediately
5. Provide clear re-authentication URL and instructions
6. After re-authentication, check if grant was out of service <72 hours
7. If <72 hours: Monitor for backfill notifications from Nylas
8. If >72 hours: Warn user of potential data loss and manual retrieval options
9. Document all grant expiration events for audit trail

---

## 4.9 Calendar & Recurrence

### DST Test Failure

**Trigger**: Timezone handling fails

**Severity**: P2 if blocking release

**Actions:**

1. Block deployment
2. Fix TZID handling
3. Update recurrence engine
4. Enhance DST test matrix

**Escalation**: P2 if blocking release

---

### Temporal Polyfill

**Trigger**: Safari Temporal support issues

**Severity**: P2 if date bugs

**Actions:**

1. Feature detection: native Temporal if available
2. Use temporal-polyfill as fallback
3. Test on Safari
4. Verify date handling

**Escalation**: P2 if date bugs

---

## 4.10 Monitoring & Alerting

### Key Metrics

- AI error rate
- Database connectivity
- Spec validation pass rate
- Realtime channel memory
- Cost budget utilization
- Security incident count

### Alert Thresholds

- P0: Immediate paging
- P1: 15-minute response
- P2: 1-hour response
- P3: 24-hour response

### SOC2 Compliance

- All incidents logged
- Automated evidence collection
- Quarterly audit preparation
- Control effectiveness testing
