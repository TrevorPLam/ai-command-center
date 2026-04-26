
# Architecture Overview

This document provides a high-level architectural view of the AI Command Center platform using the C4 model approach.

## System Context (C1)

The system interacts with multiple external actors and services:

- **Users**: Access the platform via browser and mobile applications
- **External APIs**: LLM providers (Claude, OpenAI, Gemini), Stripe for billing, Nylas for email
- **Supabase**: Provides database and real-time infrastructure

## Container Level (C2)

The platform consists of these high-level containers:

| Container | Technology | Purpose |
|-----------|------------|---------|
| Web Application | Vite SPA | React frontend with TypeScript |
| API Backend | FastAPI | Python backend handling business logic |
| Primary Database | Supabase PostgreSQL | Main application data with RLS |
| Time-Series DB | TimescaleDB | AI cost tracking and analytics |
| Cache | Redis (Upstash) | Rate limiting and semantic caching |
| Real-time Communication | LiveKit | Video conferencing and voice AI |

## Deployment Environments

### Production

| Service | Provider | Configuration | Scaling Strategy |
|---------|----------|---------------|------------------|
| FastAPI Backend | Fly.io | Machines v2, Python 3.12, 2 shared-cpu-1x HA | Auto-scale 1-10 VMs with zero-downtime rolling deployments |
| Web Application | Vercel | Vite SPA, Edge Functions, CDN, Edge Middleware | Global CDN distribution |
| Primary Database | Supabase | Postgres 15, RLS enabled, pgBouncer connection pooling | Managed high availability |
| Real-time | Supabase | WebSockets, 100 channels per connection, 200 free/500 Pro peak connections | Auto-scale capacity |
| Time-Series | TimescaleDB | Continuous aggregates with real-time materialization | Managed service |
| Cache | Upstash Redis | Rate limiting, semantic cache, session storage | Managed cluster |
| Conferencing | LiveKit | STT/LLM/TTS pipeline, WebRTC, turn detection | Managed SFU infrastructure |
| Secrets | HashiCorp Vault | JWT 90-day rotation, Stripe 180-day, MCP OAuth 90-day, LLM keys 30-day | Managed with auto-unseal |
| Environment Variables | Doppler | Per-environment (dev/staging/prod), GitHub Actions integration | Geo-redundant storage |

### Edge Functions Performance

| Metric | Value | Source |
|--------|-------|--------|
| Cold Start Latency (median) | 400ms | GitHub discussion #29301, Supabase maintainer (Oct 29, 2024) |
| Hot Start Latency (median) | 125ms | GitHub discussion #29301, Supabase maintainer (Oct 29, 2024) |
| Regional Variation | ±100ms from median | Supabase maintainer (Oct 29, 2024) |
| Bundle Format | ESZip (compact module graph) | Supabase Edge Functions Architecture docs |

### Realtime Architecture

| Metric | Value | Source |
|--------|-------|--------|
| Channel Ceiling per Connection | 100 channels | Supabase Realtime Concepts docs |
| Concurrent Peak Connections (Free) | 200 | Reddit discussions, Supabase community |
| Concurrent Peak Connections (Pro) | 500 included, $10/1,000 additional | Supabase Realtime Pricing docs |
| Message Pricing | $2.50 per 1M messages | Supabase Realtime Pricing docs |
| Heartbeat Interval (default) | 25 seconds | Supabase Realtime Heartbeat docs |
| Cluster Capacity | Millions of concurrent connections | Supabase Realtime Limits docs |

### Staging

- **FastAPI**: Single shared-cpu-1x VM on Fly.io, no auto-scaling, manual deployment
- **Web App**: Preview deployments on Vercel with branch-based builds
- **Database**: Separate Supabase project with RLS test data

### Development

- **Stack**: Docker Compose with local Supabase and mock LLM services
- **Purpose**: Local development with no external dependencies

## Data Flow Architecture

The following table describes how data flows between system components:

| Source | Destination | Protocol | Security Controls | Purpose |
|--------|-------------|----------|-------------------|---------|
| Browser | FastAPI | HTTPS | JWT authentication with org_id claim | All `/v1/*` API endpoints |
| FastAPI | Supabase | TCP | Internal network, RLS enforced | Database queries via Prisma client |
| FastAPI | LiteLLM | HTTPS | API key rotation with cosign verification | LLM routing (Claude, GPT, Gemini) |
| FastAPI | MCP Server | HTTP | MCPSec L2, OAuth tool auth | SSRF allowlist, nonce replay protection |
| FastAPI | Stripe | HTTPS | API key 180-day rotation | Billing via @stripe/ai-sdk |
| FastAPI | Nylas | HTTPS | OAuth2, grant.expired webhook | Email sync (upsert-first, 10s ack) |
| FastAPI | LiveKit | WebSocket | Token TTL 6h, RBAC scoped | Voice pipeline (STT/LLM/TTS) |
| Supabase | Browser | WebSocket | JWT auth, org-scoped channels | Realtime CDC updates |
| FastAPI | TimescaleDB | TCP | Internal network | AI cost logging hypertable |
| FastAPI | Upstash | Redis | TLS encrypted | Rate limiting and semantic cache |
| FastAPI | Sentry | HTTPS | DSN via environment variable | Error tracking and session replays |
| FastAPI | PostHog | HTTPS | API key authentication | Product analytics with allow_training flag |
| FastAPI | OTel Collector | HTTPS | OTLP protocol | GenAI traces with PII redaction |

## Security Architecture

The platform implements defense in depth with 12 security layers:

| Layer | Control | Mechanism | Test Method | Owner | Evidence |
|-------|---------|-------------|-------------|-------|----------|
| L1 | Network isolation | Fly.io private network, Supabase peering | Port scanning | Platform | Network diagram |
| L2 | Application security | CSP headers with nonce strategy, strict-dynamic, worker-src | CSP Report-Only monitoring | Security | CSP policy document |
| L3 | API protection | FastAPI-Limiter with Upstash Redis, per-user and per-org limits | Load testing 1000 req/s | Platform | Rate limit logs |
| L4 | Authentication | Custom access token hook, org_id JWT claim, 90-day rotation | Token expiry testing | Security | Auth audit logs |
| L5 | Data access | Row Level Security with org_id required, role-based access | pgTAP 33 test cases | Data | pg_prove output |
| L6 | Supply chain | Package pinning with cosign verification | Schemathesis CVE scan | Security | CI gate logs |
| L7 | MCP security | MCPSec L2 with Agent Passports (ECDSA P-256), signed envelopes | OWASP MCP Top10 audit | AI | MCPSec test suite |
| L8 | AI guardrails | 3-layer protection: Input (PII/jailbreak/tox), Output (halluc/safety/schema), Runtime (tool auth) | DeepEval test suite | AI | Guardrail audit logs |
| L9 | Secret management | Vault rotation: JWT 90d, Stripe 180d, MCP OAuth 90d, LLM keys 30d | Rotation script testing | Platform | Vault audit trail |
| L10 | Compliance | SOC2 Type I | Vanta evidence pipeline, quarterly refresh | GRC | SOC2 report |
| L11 | Privacy | GDPR compliance with allow_training flag, data segregation | Data deletion testing | GRC | PIA document |
| L12 | Audit | Immutable WORM logs with hash chaining | Log integrity checks | Security | Audit trail export |

## Authentication & Authorization

### Login

- **Provider**: Supabase Auth with email/password
- **Token Hook**: `custom_access_token_hook` embeds `org_id` and `role` in JWT
- **Security**: JWT tokens are httpOnly, not stored in localStorage

### Multi-Factor Authentication (MFA)

#### TOTP

- **Implementation**: Spectrum TOTP
- **Backup**: Recovery codes provided on enrollment

#### WebAuthn Passkeys

- **Implementation**: SimpleWebAuthn (ADR107)
- **Storage**: `webauthn_challenges` table
- **Flow**: RPC-based authentication flow
- **Features**:
  - Cross-device QR code support
  - Recovery codes for account recovery

### Organization Switching

- **Mechanism**: `supabase.auth.refreshSession()`
- **Cleanup**: Query client cache cleared
- **Reconnection**: Realtime reconnection triggered
- **Rule**: AUTHHOOK01 compliance

### Nylas Authentication

- **Protocol**: OAuth2 grant flow
- **Expiration**: `grant.expired` webhook triggers re-authentication
- **Window**: Must complete re-auth within 72 hours
- **Monitoring**: Daily cron job checks for expiring grants

### Security Controls

#### Token Security

- **Storage**: JWT never in localStorage
- **Cookies**: All tokens httpOnly
- **CSRF**: Double-submit cookie pattern

#### Session Management

- **Rotation**: Automatic on privilege change
- **Timeout**: 24-hour idle timeout
- **Concurrent**: Maximum 5 sessions per user

## Infrastructure & SLAs

| Component | Provider | SLA | Backup Strategy | Disaster Recovery | Monitoring |
|-----------|----------|-----|-----------------|-------------------|------------|
| FastAPI | Fly.io | 99.9% | Daily pg_dump, hourly WAL | Region failover | Sentry + Loki |
| Web App | Vercel | 99.9% | Git versioning | Global CDN | Vercel Analytics |
| Supabase DB | Supabase | 99.9% | Point-in-time recovery, 7-day retention | Cross-region replica | Supabase Dashboard |
| TimescaleDB | Supabase | 99.9% | Continuous aggregates backup | Read replica | Supabase Dashboard |
| Redis | Upstash | 99.9% | Persistence enabled, AOF | Multi-AZ | Upstash Dashboard |
| LiveKit | LiveKit | 99.9% | Recording retention | Region failover | LiveKit Dashboard |
| Vault | HashiCorp | 99.9% | Auto-unseal, RAID storage | Disaster recovery | Vault UI |
| Doppler | Doppler | 99.9% | Secret versioning | Geo-redundant | Doppler Dashboard |

## Third-Party Integrations

| Service | Protocol | Authentication | Rate Limit | Retry Policy | Timeout | Circuit Breaker |
|---------|----------|----------------|------------|--------------|---------|-----------------|
| LiteLLM | HTTP | API key | 100 req/min | Exponential backoff 3x | 30s | Opens after 5 failures |
| Nylas | HTTP | OAuth2 | 100 req/min | Linear backoff 1s | 10s | Opens after 3 failures |
| Stripe | HTTP | API key | 100 req/min | Exponential backoff 2x | 30s | Opens after 5 failures |
| LiveKit | WebSocket | Token TTL 6h | N/A | N/A | N/A | N/A |
| Supabase Realtime | WebSocket | JWT | 100 channels per connection | Reconnect: 1s, 2s, 4s, 8s, max 30s | N/A | N/A |
| Upstash Redis | TCP | TLS | 10,000 ops/sec | N/A | 5s | Opens after 10 failures |

### Redis Performance

**10,000 ops/sec Sufficiency Validation:**

- Upstash Redis Free Tier: 500K commands/month (sufficient for development/testing)
- Upstash Pay-as-You-Go: $0.2 per 100K commands after free tier
- Upstash Fixed Plans: Start at $10/month for 250MB storage
- Upstash Enterprise: 100K+ commands per second supported
- Ops/sec limit is consistent across most initial plans, with higher plans providing increased throughput
- Rate Limit SDK minimizes Redis calls via caching to reduce latency and cost
- 10,000 ops/sec is sufficient for expected load (rate limiting, session storage, semantic caching)
- Upstash reaches out to discuss upgrade options if database exceeds max commands-per-second limit
| OTel Collector | HTTPS | OTLP | N/A | Exponential backoff 2x | 10s | Opens after 3 failures |
| Sentry | HTTPS | DSN | N/A | N/A | 5s | Opens after 5 failures |
| PostHog | HTTPS | API key | 1000 events/min | Linear backoff 500ms | 10s | Opens after 3 failures |

## Auto-Scaling Configuration

| Service | Metric | Threshold | Scale Up Action | Scale Down Action | Max | Min |
|---------|--------|-----------|-----------------|-------------------|-----|-----|
| FastAPI | CPU | 70% | Add 1 VM | Remove 1 VM | 10 | 1 |
| FastAPI | Memory | 80% | Add 1 VM | Remove 1 VM | 10 | 1 |
| Supabase DB | Connections | 80% | Add read replica | N/A | N/A | N/A |
| Supabase Realtime | Channels | 100 per connection | Add capacity | N/A | N/A | N/A |
| Upstash Redis | Memory | 70% | Scale cluster | N/A | N/A | N/A |
| LiveKit | Participants | 1000 | Add SFU | Remove SFU | N/A | N/A |

## Multi-Region Architecture

### FastAPI Active-Passive Deployment Pattern

**Architecture Overview:**

- Active region handles all production traffic
- Passive region has infrastructure pre-deployed with data replication
- Failover switches traffic from active to passive region during disaster
- Data maintained live in passive region for tight RTO/RPO objectives

**Implementation Pattern:**

```text
[Active Region]          [Passive Region]
     FastAPI VMs  ←→  Replication  ←→  FastAPI VMs (standby)
         ↓                              ↓
   Load Balancer                    Load Balancer (standby)
         ↓                              ↓
   User Traffic                     (ready to accept traffic)
```

**Failover Flow:**

1. Health check detects active region failure
2. DNS/traffic routing switches to passive region (seconds to minutes)
3. Passive region infrastructure accepts traffic immediately
4. Data replication ensures minimal data loss (RPO near 0)

**Key Considerations:**

- Infrastructure must be fully or partially deployed in passive region before failover
- Data replication must be active to avoid restoration from backup
- Network-level failover typically 2-5 seconds
- Application-level failover typically 1-3 minutes
- Total RTO achievable within 5 minutes with proper configuration

### Database Replication

#### Supabase Cross-Region Replication

**Implementation:**

- Streaming replication: WAL changes stream directly from primary to replica
- File-based log shipping: WAL files buffered and sent as fallback
- Hybrid approach: Streaming for low lag, file-based for resilience
- Replication is asynchronous (transactions not blocked on primary)

**Latency Characteristics:**

- Replication lag varies based on geographic distance and network conditions
- CAP theorem trade-off: consistency vs availability during network partitions
- Typical cross-region lag: 100-500ms depending on regions
- Monitoring available via Supabase Dashboard

**Failover Considerations:**

- Automatic failover currently Enterprise-only (planned for all paid plans)
- Read replicas are read-only only (select operations)
- Promotion to primary requires manual intervention or Enterprise auto-failover
- Geo-based load balancing in development (round-robin currently used)

**Recovery Time Objective (RTO):**

- PITR restoration time is variable and depends on:
  - Time since last full backup (weekly)
  - WAL activity volume since last backup
  - Database size (less critical than WAL activity)
- 1-hour RTO achievable for cross-region replica promotion with proper preparation
- Faster recovery possible with active-passive setup and pre-warmed infrastructure

### Fly.io Configuration

#### Machines v2 Auto-Scaling

**Autostop/Autostart (Load-Based):**

- Creates a pool of Machines in one or more regions
- Fly Proxy starts/stops Machines based on load
- Machines never created or deleted, only started/stopped
- Suitable for predictable traffic patterns

**Metrics-Based Autoscaling:**

- Deploys autoscaler as separate application
- Polls metrics (Prometheus, Temporal workflows)
- Computes required Machine count based on defined metric
- Can create/delete Machines or stop/start existing Machines
- Supports scaling on custom metrics like `queue_depth`

**CPU Performance Characteristics:**

- Shared vCPUs: 5ms quota per 80ms period (6.25% baseline)
- Performance vCPUs: Full 80ms period (100% baseline)
- Bursting: Accumulates unused quota for burst periods
- Monitoring: CPU Quota Balance and Throttling in Managed Grafana
- Throttling occurs when burst balance depleted

**Scaling Effectiveness:**

- Effective for bursty workloads with idle periods
- Latency-sensitive applications benefit from burst capability
- Scaling decisions based on configurable thresholds
- Cost-efficient by only running needed capacity

### Deployment Strategy

#### Zero-Downtime Rolling Deployments

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

## High Availability & Disaster Recovery

| Component | Strategy | RTO | RPO | Test Frequency |
|-----------|----------|-----|-----|----------------|
| FastAPI | Multi-region active-passive with pre-warmed infrastructure | 5 minutes | 0 | Monthly |
| Supabase DB | Cross-region replica with streaming replication | 1 hour | 0 | Quarterly |
| TimescaleDB | Continuous aggregates backup | 1 hour | 15 minutes | Monthly |
| Redis | Multi-AZ with persistence | 1 minute | 0 | Monthly |
| Vault | Raft cluster with auto-unseal | 5 minutes | 0 | Quarterly |
| Doppler | Geo-redundant storage | 1 minute | 0 | Monthly |

## SOC2 Automation

### Vanta SOC2 Automation Effectiveness

**Core Automation Capabilities:**

- **Continuous Evidence Collection**: Automatically capture screenshots, logs, and configuration data from 300+ integrated systems
- **Control Mapping and Monitoring**: Map organizational practices to specific SOC2 controls with real-time compliance tracking
- **Policy Template Libraries**: Access customizable policy templates covering all major compliance frameworks
- **Workflow Management**: Create task assignments, deadlines, and approval processes for compliance activities
- **Audit Trail Generation**: Produce comprehensive audit documentation with timestamps and change tracking
- **Dashboard Reporting**: Visualize compliance posture with executive-level reporting and trend analysis

**Effectiveness Metrics:**

- **Time Reduction**: 73% reduction in compliance preparation time compared to manual approaches (arXiv:2502.16344)
- **Integration Ecosystem**: 300+ pre-built integrations with cloud infrastructure, identity management, development tools, monitoring systems, and communication platforms
- **User Experience**: Consistently rated highest for ease of use among compliance automation platforms
- **Cost Range**: $10,000-$45,000 annually depending on company size and features

**Limitations and Expertise Gap:**

Automation tools cannot replace human expertise in critical areas:
- **Strategic Decision Making**: Determining appropriate security controls for specific risk profiles requires cybersecurity knowledge beyond templates
- **Policy Customization**: Tailoring policies to business processes, technology stack, and risk tolerance demands compliance expertise
- **Audit Preparation**: Managing auditor relationships, responding to complex findings, and presenting evidence requires audit process experience
- **Architecture Design**: Identifying and implementing security controls that integrate with existing infrastructure needs technical expertise

**Integration Reality:**

- Modern B2B SaaS companies typically use 100+ different software tools (Okta 2025 Businesses at Work Report)
- Vanta integrates with major categories: AWS/Azure/GCP, Okta/Azure AD/Google Workspace, GitHub/GitLab/Jira/Jenkins, DataDog/New Relic/Splunk, Slack/Microsoft Teams
- 95% of organizations report integration challenges (e.g., Salesforce) requiring custom configuration or manual evidence collection workarounds

## Evidence Collection

### Automated Evidence Pipeline Architecture

**Data Sources:**

- **Infrastructure**: Cloud and virtual environments (config changes, audit logs)
- **Identity & Access Management**: Provisioning, deprovisioning, role assignments, access reviews
- **CI/CD and Deployment Tools**: Build logs, change events, deployment metadata
- **Ticketing & Workflow Systems**: Incident reports, change requests, approval workflows
- **Security Monitoring Systems**: SIEMs or log aggregation platforms for real-time event feeds
- **Endpoint Controls**: Device posture, antivirus status, EDR alerts

**Collection Pipelines:**

- **APIs**: For structured, on-demand data pulls
- **Webhooks**: For real-time event-driven updates
- **Agents/Collectors**: For systems without API access

**Centralized Storage:**

Route all data into a secure, centralized repository with:
- Strict access control and encryption at rest and in transit
- Metadata tagging to map items to SOC2 criteria
- Version controls and timestamping for traceability and audit readiness

**Automation Benefits:**

- **Real-time Monitoring**: Continuous oversight of systems, networks, and controls with instant deviation flagging
- **Reduced Manual Effort**: Elimination of repetitive tasks (data entry, evidence gathering, document tracking)
- **Greater Accuracy and Consistency**: Uniform rules and standards across departments, reducing human error
- **Improved Audit Readiness**: Documentation, control logs, and evidence updated in real time
- **Enhanced Visibility and Reporting**: Data-driven insights into compliance health through dashboards and analytics
- **Continuous Improvement**: Pattern analysis for control failures enables corrective measures and process strengthening

**Key Control Areas:**

- **Access Controls**: User provisioning/deprovisioning logs, MFA enrollment, periodic access reviews with timestamps
- **Change Management**: Commit logs, approvals, release metadata, pull requests linked to tickets, deployment records
- **System Monitoring & Logging**: Ingest system/security logs, tag by control relevance, trigger alerts linked to incident response
- **Policy Management**: Employee acknowledgments, security training completion, policy version changes with authorship
- **Incident Response**: Full incident tickets with severity/timeline/resolution, linked logs/alerts/communications, tagged post-mortems
- **Vendor Management**: Vendor risk assessment logs, contract status/scope/termination documentation

## Control Mapping

### Trust Services Criteria (TSC) Mapping

**The 5 Trust Services Categories:**

1. **Security** (Required for all SOC2 audits): Protects systems and data from unauthorized access, misuse, or changes. Controls include identity and access management, risk assessment, firewalls, intrusion detection, logging/monitoring, security awareness training, change management, incident response.

2. **Availability** (Optional): Ensures in-scope system is available for operation as promised. Controls include disaster recovery, business continuity planning, backup processes, capacity planning, performance monitoring, incident handling for downtime.

3. **Processing Integrity** (Optional): Ensures system processing is complete, valid, accurate, timely, and authorized. Controls include input/output validation, data processing accuracy checks, error detection/correction, monitoring, reconciliation processes. Note: This evaluates whether processes work as intended, not whether input data is accurate.

4. **Confidentiality** (Optional): Protects information designated as confidential from unauthorized access, disclosure, or use. Controls include data classification/handling, access restrictions, data retention/disposal, encryption (at rest and in transit), contractual confidentiality obligations.

5. **Privacy** (Optional): Focuses on how personal information is collected, used, and disclosed. Controls include privacy policies, consent management, data subject rights processing, privacy impact assessments.

**TSC Selection Guidance:**

- **No Checklist or Guidance**: There is no AICPA checklist or guidance on how to choose the right trust services categories
- **Service Commitment-Based**: Selection should be predicated entirely on service commitments and system requirements
- **Customer Requirements**: Inclusion beyond relevant categories doesn't make sense—there wouldn't be enough to speak to
- **Industry Alignment**: Consider what customers expect (e.g., SaaS vendors often include availability for uptime commitments, payment processors include processing integrity, healthcare vendors include confidentiality and privacy)

**Mapping Completeness:**

- Security is the cornerstone and required for every SOC2 audit
- Other categories are included based on specific service commitments and system requirements
- Mapping organizational practices to TSC requires understanding which criteria apply to the in-scope system
- Vanta provides automated control mapping to SOC2 criteria with real-time compliance tracking

## Additional Infrastructure (April 2026)

| Service | Configuration | Phase |
|---------|---------------|-------|
| PowerSync | Managed service with SOC2 Type 2 audited, HIPAA compliance (Pro/Team/Enterprise), YAML sync rules (legacy), Sync Streams (Beta recommended), per-org bucket configuration | Phase 2 |
| Y-Sweet | Self-hosted on Fly.io private network, configurable body size limit (Y_SWEET_MAX_BODY_SIZE env var added in v0.9.0), offline support provider | Active |
| Grype | Docker image vulnerability scanner, replaces Trivy, isolated from CI credentials | Active |
| LangGraph | AI orchestration with Supervisor/Swarm patterns, LangMem integration, OTel gen_ai traces | Active |
| FastGraphRAG | RAG augmentation with NLP entity extraction, direct production deployment | Active |
| Vanta | SOC2 automation with evidence pipeline and TSC mapping | Active |

## Container Scanning

### Grype vs Trivy Scanner Accuracy

**Scanner Comparison Table:**

| Metric | Grype | Trivy | Source |
|--------|-------|-------|--------|
| **False Positive Rate** | Moderate (80% reduction after 2023 GHSA migration) | Higher (occasionally more false positives) | Anchore blog (2024), Stakater comparison |
| **False Negative Rate** | 11 false negatives in test data after 2,000+ false positive reduction | Misses some language dependencies (Reddit user feedback) | Anchore blog, Reddit r/devops |
| **Detection Modes** | GitHub Advisory Database (GHSA) primary, CPE optional | `--detection-priority` flag: `precise` (default) or `comprehensive` | Anchore blog, Trivy docs |
| **Risk Scoring** | Composite risk score (0.0-10.0) combining CVSS, EPSS, KEV | Severity-based filtering (LOW, MEDIUM, HIGH, CRITICAL) only | AppSecSanta comparison |
| **Speed** | Fast | Fast | Stakater comparison |
| **Scope** | Focused vulnerability scanner only | Multi-scanner (vulnerabilities, IaC, secrets, licenses) | AppSecSanta comparison |
| **Database** | Aggregates NVD, GHSA, Alpine SecDB, Debian, Red Hat, Ubuntu, Amazon Linux, Oracle Linux | Curated trivy-db maintained by Aqua Security | AppSecSanta comparison |
| **Ecosystem Coverage** | Alpine, Debian, Ubuntu, RHEL, CentOS, Amazon Linux, SUSE, Arch, Gentoo | Alpine, Debian, Ubuntu, RHEL, CentOS, Amazon Linux, SUSE, Photon OS, Windows | AppSecSanta comparison |
| **Language Coverage** | Go, Java, JavaScript, Python, Ruby, Rust, PHP, .NET | Go, Java, JavaScript, Python, Ruby, Rust, PHP, .NET | AppSecSanta comparison |
| **Quality Measurement** | Yardstick tool with F1 score (TP, FP, FN counts) | No formal quality gate documented | Anchore blog |

**Key Findings:**

- **Grype Accuracy Improvements (2023-2024):** Up to 80% reduction in false positives across some ecosystems after shifting from CPE-based matching to GitHub Advisory Database (GHSA). Reduced false positive matches by 2,000+ with only 11 false negatives in their test data. Uses Yardstick tool for quality measurement with F1 score. Particularly improved for Java applications (previously had cross-ecosystem confusion between C++ and Go protobuf libraries).

- **Trivy Accuracy:** Has `--detection-priority` flag with two modes: `precise` (reduces false positives, default) and `comprehensive` (detects more vulnerabilities but may increase false positives). Uses vendor severity ratings over NVD (documentation states vendor ratings are more accurate). Reddit user feedback: "Fast, great OS packages, but misses some language deps." Machine learning models in 2025 reduced false positive rates by 34% compared to previous versions.

- **Community Consensus:** Reddit r/devops discussion indicates "The combo approach (Trivy + Grype) seems to be the move" for comprehensive coverage. Grype excels at focused vulnerability detection with superior risk scoring (EPSS, KEV integration), while Trivy provides broader security scope including IaC, secrets, and license compliance.

- **Recommendation:** Use Grype for primary vulnerability scanning due to its superior accuracy (80% false positive reduction, composite risk scoring) and quality measurement (Yardstick F1 score). Consider Trivy as a secondary scanner if IaC misconfigurations, secrets detection, or license compliance scanning are required.

### CI Integration

**Credential Isolation Requirements:**

Based on the Trivy GitHub Actions supply chain compromise (March 19, 2026), where attackers force-pushed malicious code to 75 of 76 version tags and stole CI/CD secrets before running the real scanner, the following isolation requirements are mandatory:

| Requirement | Implementation Pattern | Source |
|-------------|----------------------|--------|
| **Scanner credential isolation** | Run scanners in separate jobs with no access to CI credentials. Pass artifacts between jobs instead of credentials. | CrowdStrike Trivy analysis (March 2026), OWASP CI/CD Cheat Sheet |
| **Action pinning** | Pin all third-party actions to full-length commit SHA (only immutable release method). Tags can be moved/deleted if repository is compromised. | GitHub Actions Secure Use reference |
| **Least privilege permissions** | Set `permissions: {}` at workflow level to force job-level specification. Grant only minimum necessary permissions to GITHUB_TOKEN. | Wiz GitHub Actions security guide, OWASP Least Privilege |
| **Secret scoping** | Pass secrets individually by name at step level env only where needed. Avoid `secrets: inherit` in reusable workflows. Never use `toJson(secrets)` antipattern. | GitHub Actions Secure Use reference, Wiz security guide |
| **OIDC for cloud resources** | Use OpenID Connect (OIDC) to authenticate with cloud providers instead of long-lived secrets. Reduces credential theft blast radius. | GitHub OIDC docs, Wiz security guide |
| **Environment-level secrets** | Use environment-level secrets for sensitive operations (e.g., deployment) with required approval gates. Limits secret exposure to approved workflows. | GitHub Actions Secure Use reference |
| **Cooldown period** | Adopt 7-14 day delay before adopting new action versions. Catches 80-90% of supply chain attacks with detection windows under one week. | Wiz GitHub Actions security guide |
| **Workflow linting** | Use tools like zizmor to catch common vulnerabilities (unpinned actions, template injection, dangerous triggers) before deployment. | Wiz GitHub Actions security guide |

**Dual-Scanner CI Integration Pattern:**

```yaml
name: Container Security Scan
on:
  push:
    branches: [main]
  pull_request:

permissions:
  contents: read
  security-events: write

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      image-digest: ${{ steps.build.outputs.digest }}
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - name: Build container image
        uses: docker/build-push-action@v6
        with:
          tags: localbuild/testimage:latest
          push: false
          load: true
          outputs: type=digest,destination=/tmp/digest
      - name: Export image digest
        run: |
          echo "digest=$(cat /tmp/digest)" >> $GITHUB_OUTPUT

  # Scanner job with NO credentials - isolated from CI secrets
  scan-grype:
    needs: build
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write
      # No other permissions - scanner cannot access secrets or write to repo
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - name: Load image from cache
        run: |
          docker build . --file Dockerfile --tag localbuild/testimage:latest
      - name: Scan with Grype
        uses: anchore/scan-action@v7
        id: scan-grype
        with:
          image: "localbuild/testimage:latest"
          fail-build: false
          severity-cutoff: high
          output-format: sarif
      - name: Upload Grype SARIF
        uses: github/codeql-action/upload-sarif@v4
        with:
          sarif_file: ${{ steps.scan-grype.outputs.sarif }}

  # Secondary scanner (optional) - also isolated
  scan-trivy:
    needs: build
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - name: Load image from cache
        run: |
          docker build . --file Dockerfile --tag localbuild/testimage:latest
      - name: Scan with Trivy
        uses: aquasecurity/trivy-action@0.24.0 # Pin to specific SHA after verification
        with:
          image-ref: 'localbuild/testimage:latest'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH,MEDIUM'
      - name: Upload Trivy SARIF
        uses: github/codeql-action/upload-sarif@v4
        with:
          sarif_file: 'trivy-results.sarif'
```

**Key Implementation Details:**

- **Artifact passing**: Build job outputs image digest, scanner jobs rebuild image from source (no registry credentials needed)
- **Permission isolation**: Scanner jobs have only `contents: read` and `security-events: write` - no access to repository secrets
- **No credential inheritance**: Scanner jobs run in separate job context with no access to parent job credentials
- **SARIF integration**: Both scanners upload to GitHub Security tab for unified vulnerability view
- **Optional secondary scanner**: Trivy runs only if IaC/secrets/license scanning is needed (per ADR_111 recommendation)

## Y-Sweet Deployment

### Fly.io Deployment Patterns

**Docker Image:**

Y-Sweet provides an official Docker image for deployment: `ghcr.io/jamsocket/y-sweet:latest`

**Dockerfile Example:**

```dockerfile
FROM ghcr.io/jamsocket/y-sweet:latest

# Set environment variables for S3 configuration
ENV Y_SWEET_STORE=s3://my-bucket/path
ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
ENV AWS_REGION=us-east-1

# Configure body size limit (optional, added in v0.9.0)
ENV Y_SWEET_MAX_BODY_SIZE=104857600  # 100MB in bytes

# Expose the default Y-Sweet port
EXPOSE 8080

# Run the Y-Sweet server
CMD ["y-sweet", "serve"]
```

**fly.toml Configuration:**

```toml
app = "y-sweet-app"

[build]
  dockerfile = "Dockerfile"

[env]
  Y_SWEET_STORE = "s3://my-bucket/path"
  AWS_REGION = "us-east-1"
  Y_SWEET_MAX_BODY_SIZE = "104857600"

[http_service]
  internal_port = 8080
  force_https = true

[[vm]]
  cpu_kind = "shared"
  cpus = 1
  memory_mb = 1024
```

**Deployment Commands:**

```bash
# Initialize Fly.io app
fly launch

# Set secrets for AWS credentials
flyctl secrets set AWS_ACCESS_KEY_ID=your_key
flyctl secrets set AWS_SECRET_ACCESS_KEY=your_secret

# Deploy
fly deploy
```

**S3 Storage Configuration:**

- Y-Sweet supports S3-compatible storage (AWS S3, MinIO, Wasabi, etc.)
- Uses AWS credentials from environment variables or `aws configure`
- For S3 storage, directory path must start with `s3://`
- Credentials picked up from environment: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`

**Local Development:**

```bash
# Run with local filesystem storage
npx y-sweet@latest serve /path/to/data

# Run with S3 storage
npx y-sweet@latest serve s3://my-bucket/path
```

### Y-Sweet Limits

**Body Size Limit:**

- **Configurable via:** `Y_SWEET_MAX_BODY_SIZE` environment variable (added in v0.9.0, PR #405)
- **Default value:** Not documented in public sources (requires testing to determine)
- **Configuration:** Set environment variable to desired byte value (e.g., 104857600 for 100MB)
- **Purpose:** Controls maximum WebSocket message size to prevent memory exhaustion
- **Note:** Original task information stating "50MB document limit" was not found in documentation; actual limit is configurable via environment variable

**Workarounds for Large Documents:**

- Increase `Y_SWEET_MAX_BODY_SIZE` if needed for larger documents
- Implement client-side chunking for very large payloads
- Consider document splitting strategies for collaborative editing scenarios
- Monitor memory usage when increasing limits

## PowerSync SOC2/HIPAA Certification Status

| Certification | Status | Plan Availability | Documentation Links | Compliance Gaps |
|---------------|--------|-------------------|---------------------|-----------------|
| SOC 2 Type 2 | Audited (several years) | Team and Enterprise plans | https://docs.powersync.com/resources/security | None - fully compliant |
| HIPAA | Compliant (requires BAA) | Pro, Team, and Enterprise plans | https://docs.powersync.com/resources/hipaa | Customer must sign BAA before storing ePHI |

## LiveKit Integration

### Voice AI Pipeline Architecture

**Sequential Pipeline Stages:**

| Stage | Purpose | Latency | Streaming Support |
|-------|---------|---------|-------------------|
| Voice Activity Detection (VAD) | Detect speech vs noise | 10-50ms | Continuous |
| Speech-to-Text (STT) | Convert audio to text | 200ms complete, <100ms partial | Yes (Deepgram Nova, OpenAI Whisper) |
| Large Language Model (LLM) | Generate response | 300-800ms first token | Yes (token streaming) |
| Text-to-Speech (TTS) | Convert text to audio | 100-200ms first chunk | Yes |
| Audio Transport | Deliver audio to user | Network-dependent | WebRTC/SIP trunking |

**Streaming Architecture:**

- Naive pipeline latency: VAD + STT + LLM + TTS (sequential blocking)
- Streaming pipeline latency: max(VAD, STT, LLM, TTS) (parallel processing)
- Streaming enables: STT emits partial transcripts before user finishes, LLM generates tokens as transcript arrives, TTS synthesizes from first sentence while LLM generates rest, audio playback begins while TTS renders later chunks

**Cascaded vs Speech-to-Speech (S2S):**

| Architecture | Description | Use Case | Trade-offs |
|--------------|-------------|----------|------------|
| Cascaded Pipeline (default 2026) | STT → LLM → TTS with text intermediary | Production deployments, regulated industries, tool calling | Transparency, debuggability, component flexibility, audit trails |
| Speech-to-Speech | Native audio-in/audio-out models (GPT-4o Realtime, Gemini 2.5 Flash) | Latency-sensitive conversational flows, simple fast exchanges | Lower latency for simple exchanges, less control, harder debugging |
| Hybrid | S2S for fast exchanges, cascaded for complex reasoning | Balanced approach for mixed workloads | Combines benefits of both, increased complexity |

**Barge-in and Interruption Handling:**

- VAD detects speech during agent TTS playback
- Automatic interruption event cancels active TTS playback
- Queued audio flushed immediately
- Pipeline restarts from STT stage
- Edge cases: filler sounds ("mm-hmm") shouldn't trigger full interruption, echo/agent audio leakage can cause false positives, mid-tool-call interruptions require decision (cancel or complete silently)
- Protection: `run_ctx.disallow_interruptions()` for irreversible operations, `await context.wait_for_playout()` to wait for agent completion

**Conversation History Management:**

- ChatContext object accumulates turns across session
- Every user message and agent response appended
- Handoffs to other agents pass ChatContext to preserve conversation
- Without ChatContext transfer, each agent starts with fresh context

### WebRTC Scaling

**SFU Scaling Benchmarks (c2-standard-16, 16-core):**

| Scenario | Publishers | Subscribers | Resolution/Bitrate | Finding |
|----------|------------|-------------|-------------------|---------|
| Audio-only | 10 | 1000 | 3kbps average audio | Large audio sessions with few speakers supported |
| Video room | 150 | 150 | 720p video | Large meeting scenario validated |
| Livestreaming | 1 | 3000 | 720p video | Broadcast-to-many scenario validated |

**Scaling Constraints:**

- Each room must fit within a single node (cannot split one room across multiple nodes)
- Many simultaneous rooms supported via distributed multi-node setup
- SFU work per participant: receive tracks (tens of packets/sec), forward to subscribers (decryption + encryption + packet processing + forwarding)
- Performance factors: number of tracks published, number of subscribers, data rate to each subscriber
- Load testing available via `lk load-test` CLI command

**Resource Planning:**

| Metric | Value | Source |
|--------|-------|--------|
| Max participants per node | 500 (configurable) | LiveKit SFU Architecture docs |
| Audio bitrate (large sessions) | 3kbps | LiveKit Benchmarking docs |
| Video resolution (benchmarks) | 720p | LiveKit Benchmarking docs |

### SFU Architecture

**Multi-SFU Coordination:**

- Redis required for distributed, multi-node setups
- Peer-to-peer routing via Redis ensures clients joining same room connect to same node
- Single node deployment: no external dependencies
- Distributed deployment: Redis as distributed state layer

**Redis Configuration:**

```yaml
# livekit.yaml — distributed deployment configuration
redis:
  address: redis-cluster:6379
  username: livekit
  password: ${REDIS_PASSWORD}
  db: 0
  keys:
    API_KEY: ${LIVEKIT_API_SECRET}
    room: enabled
```

**Geographic Distribution and Edge Routing:**

- Multi-region nodes with region labels (e.g., us-east-1)
- Node selector configuration: kind: any, sort_by: random
- Load balancing across regions via geographic routing
- TLS everywhere for secure transport

**SFU vs MCU vs P2P:**

| Architecture | Description | Advantages | Disadvantages |
|--------------|-------------|-------------|----------------|
| SFU (Selective Forwarding Unit) | Forwards media tracks without manipulation | Scalable, flexible, per-track control, horizontal scaling | Higher downstream bandwidth (individual streams) |
| MCU (Multipoint Conferencing Unit) | Decodes, composites, re-encodes streams | Lower downstream bandwidth (single stream) | Poor scalability, limited flexibility, requires beefy hardware |
| P2P (Peer-to-Peer) | Direct peer connections | No server needed | Limited to 2-3 peers due to upstream bandwidth |

**LiveKit SFU Characteristics:**

- Written in Go, leveraging Pion WebRTC implementation
- Horizontally scalable: 1 to 100+ nodes with identical configuration
- Automatic bandwidth adaptation: measures subscriber downstream bandwidth, adjusts track parameters (resolution/bitrate)
- Client SDK handles adaptive streaming transparently
