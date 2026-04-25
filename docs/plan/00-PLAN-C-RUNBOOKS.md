---
steering: TO PARSE - READ INTRO
document_type: operational_runbooks
tier: infrastructure
description: Critical operational procedures and incident response playbooks
last_updated: 2026-04-25
version: 1.0
---

# RUNBOOKS - Operational Procedures

#RUNBOOKS
AIFailure|>5err/60s→circuit breaker,fallback gpt-4o→claude,notify Sentry+Slack
SupabaseOutage|DB unreachable>2min→read-only mode,banner,disable RT fallbacks
Spec_Validation_Fail|spec yaml invalid/missing sections→block DoD1,notify author PR,require before merge
XCT_Motion_Violation|layout anim detected→CI block,require transform/opacity only
XCT_Realtime_Memory|chan mem>40MB→alert ops,consider splitting or compaction
Nylas_Webhook_Timeout|endpoint>10s ack→alert immediately(NY disables after 95%/72h)
TESTC_Security_RLS_Fail|PB tenant isolation fail→block deploy,fix RLS
TESTC_AI_Eval_Accuracy_Drop|acc<base-2%→block PR,adjust prompt/model
Ops_P0_Trigger|P0 detected→page on-call,15min cadence,SOC2 log auto-populated
Ops_FeatureFlag_Kill|kill switch→revert 0%<5min,notify,postmortem within 48h
Ops_Cost_Exceeded|org>budget→429 all AI,CostLimitBanner,admin override+upgrade
Ops_Migration_Drift|Prisma drift in CI→block deploy,require migrate deploy or resolution
Ops_Observability_BR|BR>2%/1h→page on-call; >5%/6h→Slack; stability fixes
Sec_SSRF_Bypass|outbound bypasses allowlist→block,log security event,alert SOC
AI_Guardrail_Input_Block|PII/jailbreak/tox detected→redact/block+log to audit_logs
AI_Privacy_Opt_Out_Violation|opted-out org data in training→block,alert privacy officer
Offline_Tombstone_Missing|hard-delete without tombstone→ghost reappear on sync; fix: add deleted_at,backfill
Upload_Scan_Fail|CA fails or CVE detected→quarantine,alert security,patch required
Recurrence_DST_Fail|DST test fail→block deploy,fix TZID handling

## Incident Response Playbooks

### AI Failure
**Trigger**: >5 errors/60s

**Response Actions**:
1. Activate circuit breaker
2. Fallback to gpt-4o → claude
3. Notify Sentry + Slack
4. Monitor recovery
5. Post-incident analysis

**Escalation**: P0 if fallback fails

### Supabase Outage
**Trigger**: DB unreachable >2min

**Response Actions**:
1. Enable read-only mode
2. Display outage banner
3. Disable Realtime fallbacks
4. Monitor DB health
5. Coordinate with Supabase support

**Recovery**: Gradual re-enable of write operations

### Spec Validation Failure
**Trigger**: Invalid YAML or missing sections

**Response Actions**:
1. Block DoD1 completion
2. Notify component author via PR
3. Require spec fixes before merge
4. Update spec validation CI

**Prevention**: Enhanced spec template validation

### Cross-Cutting Issues

#### Motion Violations
**Trigger**: Layout animations detected

**Response Actions**:
1. CI block deployment
2. Require transform/opacity only
3. Update motion guidelines
4. Review component animation patterns

#### Realtime Memory Issues
**Trigger**: Channel memory >40MB

**Response Actions**:
1. Alert operations team
2. Consider channel splitting
3. Enable compaction
4. Review memory usage patterns

### Testing Failures

#### Security RLS Failure
**Trigger**: Row Level Security isolation failure

**Response Actions**:
1. Block deployment
2. Fix RLS policies
3. Run security test suite
4. Verify tenant isolation

#### AI Evaluation Accuracy Drop
**Trigger**: Accuracy <base-2%

**Response Actions**:
1. Block PR deployment
2. Adjust prompts/models
3. Retrain evaluation models
4. Update accuracy thresholds

### Operational Procedures

#### P0 Incident Trigger
**Response Actions**:
1. Page on-call engineer
2. 15-minute update cadence
3. Auto-populate SOC2 log
4. Incident commander assignment

#### Feature Flag Kill Switch
**Response Actions**:
1. Revert to 0% within 5 minutes
2. Notify affected users
3. Postmortem within 48 hours
4. Review kill switch procedures

#### Cost Budget Exceeded
**Response Actions**:
1. Block all AI requests (429)
2. Display CostLimitBanner
3. Enable admin override
4. Suggest upgrade options

### Migration Issues

#### Prisma Migration Drift
**Trigger**: CI detects schema drift

**Response Actions**:
1. Block deployment
2. Require migrate deploy
3. Review migration scripts
4. Update drift detection

### Observability & Monitoring

#### Burn Rate Alerts
**Warning**: BR >2%/1h → Page on-call
**Critical**: BR >5%/6h → Slack notification
**Action**: Stability fixes and resource optimization

### Security Incidents

#### SSRF Bypass
**Trigger**: Outbound request bypasses allowlist

**Response Actions**:
1. Block malicious requests
2. Log security event
3. Alert SOC team
4. Update allowlist rules

#### AI Guardrail Violations

**Input Block**:
- PII detected → Redact and block
- Jailbreak attempt → Block and log
- Toxic content → Filter and log

**Privacy Violation**:
- Opted-out data in training → Block
- Alert privacy officer
- Review data segregation

### Data Integrity

#### Offline Sync Issues
**Issue**: Hard delete without tombstone

**Response Actions**:
1. Add deleted_at column
2. Backfill existing records
3. Update sync logic
4. Test offline/online sync

#### Upload Security
**Trigger**: ClamAV scan failure or CVE

**Response Actions**:
1. Quarantine uploaded file
2. Alert security team
3. Patch vulnerable components
4. Update scan configurations

### Calendar & Recurrence

#### DST Test Failure
**Trigger**: Timezone handling fails

**Response Actions**:
1. Block deployment
2. Fix TZID handling
3. Update recurrence engine
4. Enhance DST test matrix

## Monitoring & Alerting

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
