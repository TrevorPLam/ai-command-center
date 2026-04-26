# Security Implementation Details

This document contains detailed security implementation specifications and configurations for the AI Command Center platform. For high-level security architecture, see [02-ARCH-OVERVIEW.md](02-ARCH-OVERVIEW.md).

---

## Security Rules (S1 – S28)

All security rules are **HARD**. Violating any of them will block a deployment.

- **S1**: Never use `dangerouslySetInnerHTML`; all user‑generated HTML passes through `SanitizedHTML` with the appropriate profile (STRICT, RICH, or EMAIL).
- **S2**: Supabase storage access only via the `StorageService` wrapper; never call the Supabase client directly.
- **S3**: Nylas API calls happen only from the FastAPI backend; frontend never talks to Nylas directly.
- **S4**: Only supabase‑js is allowed in the browser; Prisma must never be imported in frontend code.
- **S5**: Every Prisma schema change must be checked for RLS impact; RLS policies must be updated accordingly.
- **S6**: Global Content‑Security‑Policy enforced in production (nonce‑based, `strict-dynamic`).
- **S7**: `'unsafe-eval'` is allowed only for Monaco Editor and Babel, and only within their sandboxed iframes (scoped to their nonces).
- **S8**: JWT is stored only in an httpOnly cookie; never put it in Zustand or `localStorage`.
- **S9**: All API calls under `/v1/*` must go through the centralised `api.ts` client.
- **S10**: DOMPurify ≥3.4.0 is mandatory; an automated CVE audit for DOMPurify runs in CI.
- **S11**: CSP nonce must be cryptographically random per request; nonce strategy with `strict-dynamic` is required.
- **S12**: LiveKit tokens are scoped to specific rooms and capabilities; RBAC is enforced on token generation.
- **S13**: Role‑Based Access Control is applied to all resources; no ad‑hoc permission checks.
- **S14**: Rate limiting is enforced per user and per organization.
- **S15**: Organization deletion cascades correctly; notify admins 7 days before permanent deletion.
- **S16**: Agent‑driven UI may only use components from the trusted GenUI catalog; no arbitrary component rendering.
- **S17**: Yjs collaboration is opt‑in per document type; separate documents for different collaboration scopes.
- **S18**: AI cost hard cap is enforced at the LLM proxy level; frontend also has a cost budget notification.
- **S19**: MCP tool registration requires admin approval; every invocation is logged.
- **S20**: AI cost thresholds trigger alerts and rate limits (RATE_LIMITED error) to enforce budgets.
- **S21**: OpenAPI 3.1 is the single source of truth; Orval generates TypeScript types from it; Schemathesis checks contract compliance in CI.
- **S22**: (GRDL03) All pgvector‑retrieved chunks pass through the guardrails input layer before being injected into a prompt.
- **S23**: (SECREC01) Failure of automated secret rotation is treated as a P1 incident; all rotations are logged as SOC2 evidence.
- **S24**: (GRYPEREPLACE) Use Grype (not Trivy) for Docker image scanning; scanners must be isolated from CI credentials.
- **S25**: (AUTHHOOK01) The Supabase `supabase_auth_admin` role must have SELECT grants on `user_roles`, `org_members`, and `role_permissions`; verified by pgTAP after each migration.
- **S26**: (SENTRY01) Four Sentry projects; before sending any event, PII is stripped; Session Replay masks all text.
- **S27**: (CLAMAVPROD) ClamAV v1.4.x runs as a sidecar in production; freshclam updates hourly; do not cache scan results.
- **S28**: (DPPROFILES) Three DOMPurify profiles: STRICT (no SVG), RICH (allowed div/span), EMAIL (links and images); test matrix ensures XSS prevention.

---

## 12-Layer Security Architecture

The platform implements defense in depth with 12 security layers:

| Layer | Control | Mechanism | Test Method | Owner/Evidence |
| --- | --- | --- | --- | --- |
| L1 | Network isolation | Fly.io private network, Supabase peering | Port scanning | Platform: Network diagram |
| L2 | Application security | CSP headers, nonce strategy, strict-dynamic, worker-src | CSP Report-Only monitoring | Security: CSP policy document |
| L3 | API protection | FastAPI-Limiter, Upstash Redis, per-user/org limits | Load testing 1000 req/s | Platform: Rate limit logs |
| L4 | Authentication | Custom access token hook, org_id JWT claim, 90d rotation | Token expiry testing | Security: Auth audit logs |
| L5 | Data access | RLS with org_id required, role-based access | pgTAP 33 test cases | Data: pg_prove output |
| L6 | Supply chain | Package pinning, cosign verification | Schemathesis CVE scan | Security: CI gate logs |
| L7 | MCP security | MCPSec L2, Agent Passports (ECDSA P-256), signed envelopes | OWASP MCP Top10 audit | AI: MCPSec test suite |
| L8 | AI guardrails | 3-layer: Input (PII/jailbreak/tox), Output (halluc/safety/schema), Runtime (tool auth) | DeepEval test suite | AI: Guardrail audit logs |
| L9 | Secret management | Vault rotation: JWT 90d, Stripe 180d, MCP OAuth 90d, LLM keys 30d | Rotation script testing | Platform: Vault audit trail |
| L10 | Compliance | SOC2 Type I | Vanta evidence pipeline, quarterly refresh | GRC: SOC2 report |
| L11 | Privacy | GDPR compliance, allow_training flag, data segregation | Data deletion testing | GRC: PIA document |
| L12 | Audit | Immutable WORM logs, hash chaining | Log integrity checks | Security: Audit trail export |

---

## PowerSync Certification

| Certification | Status | Plan Availability | Documentation Links | Compliance Gaps |
|---------------|--------|-------------------|---------------------|-----------------|
| SOC 2 Type 2 | Audited (several years) | Team and Enterprise plans | https://docs.powersync.com/resources/security | None - fully compliant |
| HIPAA | Compliant (requires BAA) | Pro, Team, and Enterprise plans | https://docs.powersync.com/resources/hipaa | Customer must sign BAA before storing ePHI |

---

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

### Evidence Collection

**Automated Evidence Pipeline Architecture:**

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

### Control Mapping

**Trust Services Criteria (TSC) Mapping:**

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

---

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

---

## Related Documentation

- [02-ARCH-OVERVIEW.md](02-ARCH-OVERVIEW.md) - High-level security architecture
- [ADR_111](01-PLAN-ADR-INDEX.md#adr_111) - Grype replaces Trivy for Docker scanning
- [ADR_119](01-PLAN-ADR-INDEX.md#adr_119) - Vanta as SOC2 automation platform
