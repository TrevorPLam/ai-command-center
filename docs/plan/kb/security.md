---
title: "Security Controls and Compliance"
owner: "Security"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

AES-256 encryption at rest, PII encrypted at app layer with Vault keys, JWT signed/verified, RBAC with 5 roles, immutable audit logs, annual Bugcrowd pentesting, quarterly SAST/DAST, CVSS-based remediation SLA.

## Key Facts

### Encryption

**Encryption**: AES-256 at rest

- PII encrypted at application layer (Vault keys)
- JWT signed and verified
- httpOnly cookie for session tokens

### RBAC

**RBAC**: Role-based access control

- user_roles + role_permissions tables
- 5 roles: Owner, Admin, Member, Viewer, External
- authorize() function for permission checks
- JWT hook for role extraction

### Audit Logging

**AuditLog**: Immutable append-only audit_logs

- SQLAlchemy event listeners + CDC
- Queryable by admin
- MCP, guardrail, privacy events logged

### Pentesting

**Pentesting**: Annual Bugcrowd program

- Quarterly SAST/DAST (Snyk, ZAP) in CI
- MCP CVE scan (CVE-2025-49596, 66416)

#### Scope Types

- Limited: specific targets
- Wide: wildcard subdomains
- Open: no limitations

#### Targets

- Web apps
- Mobile apps
- IoT
- APIs

#### Out-of-scope

- DDoS
- Phishing
- Social engineering
- Physical attacks

#### Best Practice

Progress limited → wide → open over time

### Pentesting Schedule

**Pentesting_Schedule**: Annual frequency industry standard

- PCI DSS Requirement 11.3: annual penetration testing plus after significant changes
- ISO 27001: recommended annually (not mandatory)
- NIST SP 800-115/FISMA: periodic testing "no less than annually"
- FedRAMP: annual as part of continuous monitoring
- Additional testing required after: new systems, major upgrades, network topology changes

### SAST/DAST Accuracy

**SAST_DAST_Accuracy**: Tool performance benchmarks

- Snyk Code SAST: 85% accuracy, 8% false positive rate (SAST Tool Evaluation Study 2024)
- EASE 2024 academic benchmark: 11.2% detection rate (lowest of 4 tools) against 170 real-world Java vulnerabilities
- G2 false positive score 6.8/10 (notably low)
- Snyk DAST: claims 0.08% false positive rate (vendor marketing)
- OWASP ZAP DAST: 100% detection in WebGoat (Academia.edu 2024)
- Open-source DAST scanners: 35-40% false positive rates
- Skipfish outperforms ZAP with Youden index 0.7 (DVWA) vs 0.6 (WebGoat)
- Quarterly frequency acceptable baseline, monthly preferred for critical systems
- Note: SAST tools structurally miss business logic vulnerabilities (broken access control, auth flaws)

### Remediation SLA

**Remediation_SLA**: CVSS-based tiers

- Critical (9.0+): 14 days (24-72h if actively exploited)
- High (7.0-8.9): 30 days
- Medium (4.0-6.9): 60 days
- Low (0.1-3.9): 90 days
- Asset criticality tightens timelines
- 85% compliance rate realistic for human teams
- Threat intelligence (CISA KEV, Mandiant) reclassifies to reduce critical volume

### Scan Frequency

**Scan_Frequency**: Vulnerability scanning requirements

- PCI DSS 4.0: external vulnerability scans quarterly by ASV, annual external/internal penetration testing
- HIPAA 2026: OCR shifted vulnerability scanning from recommendation to MANDATORY, minimum TWO comprehensive scans per year (biannual)
- ISO 27001: recommended annually (not mandatory), risk-based frequency
- SOC 2: depends on control design (continuous/weekly/monthly/quarterly), annual risk assessments minimum
- CIS Control 7 (not 16): Control 7.5 (internal assets) requires quarterly or more frequent scans; Control 7.6 (externally-exposed assets) requires monthly or more frequent scans
- Higher-risk environments: monthly or weekly scanning recommended
- Trend toward per-release gates for faster remediation
- Secureframe best practice: "as often as possible"

### CI Performance

**CI_Performance**: GitHub Actions scanner benchmarks (arXiv 2026)

- semgrep: 11.7-34.65s (highly variable due to dynamic elements)
- ggshield: variable (layered secret detection with entropy analysis)
- frizbee: slightly longer (commit SHA/image digest resolution)
- scharf: max 0.05s (fastest pinning)
- pinny: max 0.09s
- actionlint: 0.39s (YAML syntax/structure)
- poutine: 0.46s (security-sensitive config)
- scorecard: 1.37s (repository-wide evaluation)
- zizmor: 0.23s (workflow triggers/contexts)
- Grype: optimized database queries, reduced memory consumption, zero-dependency architecture
- Trivy vs Grype: Grype slightly faster for pure vulnerability scanning, Trivy all-in-one (vulnerabilities, misconfigurations, secrets, licenses, SBOM)

#### Optimization Strategies

- Parallel scanning (independent scans run simultaneously)
- Caching results for unchanged code
- Incremental scanning (only modified files/modules)
- Progressive security by branch (feature: fast non-blocking, release: full scans with some blocking, production: strict gates on critical/high-risk)
- Centralized vulnerability database to normalize findings and group related issues

### GDPR

**GDPR**: Data protection compliance

- Cascade-delete pipeline + audit
- Anonymize logs
- SSE progress export
- Training opt-out per CNIL

#### GDPR Training Opt-out

**GDPR_TRAINING_OPTOUT**: Correction on CNIL guidance

- No specific CNIL guidance exists on "training opt-out" requirements for GDPR/data protection training
- Research findings:
  1. GDPR training effectively mandatory through interlocking provisions (Article 39 requires DPO to deliver awareness-raising and training; Article 32 requires appropriate organizational measures including training; Article 24 requires implementing necessary measures including staff training)
  2. French labor law allows employees to refuse training only with legitimate motives (health issues, conflict with approved leave, procedural violations by employer, discriminatory use, training unrelated to job functions)
  3. CNIL provides certification standards for data protection training programs (33 mandatory requirements, 44 optional) but no opt-out guidance
  4. No evidence of CNIL-specific opt-out requirements for data protection training
- The "training opt-out per CNIL" reference appears to be incorrect

### SOC 2

**SOC2**: Compliance framework

- VT continuous
- Aim for Type II 12mo
- HARD rule: SOC2 TSC → evidence artifact mapping

#### SOC2 Timeline

**SOC2_TIMELINE**: First-time audit 12 months total

- Prep: 2-9 months
- Audit: 1-3 months
- Reporting period: 6-12 months
- Type II reporting period typically 6-12 months (minimum 3mo for urgent needs, 6mo recommended by AICPA)
- Renewal audits faster due to established controls
- Readiness phase 2-5 months for first-time, less for experienced organizations

#### Auditor Selection

**SOC2_AUDITOR_SELECTION**: CPA firm required

- Requirements: AICPA attestation standards and SSAE 18 compliance
- Selection criteria: industry experience (SaaS/cloud/healthcare/fintech), methodology rigor (sampling, evidence collection), communication style (responsiveness, project management), pricing (fixed vs variable, $5K-$15K readiness, $10K-$30K Type I, $25K-$70K+ Type II)
- Enterprise buyers prefer Big 4 or large regional firms for trust
- Costs increase with additional TSC and systems audited

### Row Level Security

**RLS**: Database-level access control

- ENABLE + FORCE RLS
- org_id via JWT
- Policy Builder automated
- Drift detection blocks deploys

### MCP Guardrails

**MCPG**: Zero-trust architecture

- OAuth tool auth
- Schema allowlist
- Elicitation high-risk detection
- Policy eval deterministic
- SSRF protection
- Sandbox isolation
- CI TrustKit validation

### OWASP Agentic

**OWASP_ASI2026**: Agentic Top 10

- ASI01 Goal Hijack
- ASI02 Tool Misuse
- ASI03 Identity Abuse
- Map to GRDL layers, SECM controls

## Why It Matters

- Encryption protects data at rest and in transit
- RBAC ensures principle of least privilege
- Audit logs provide accountability and forensic capability
- Regular security testing identifies vulnerabilities before exploitation
- CVSS-based SLA prioritizes critical vulnerabilities
- Compliance frameworks (SOC2, HIPAA, GDPR) required for regulated industries

## Sources

- PCI DSS 4.0 documentation
- HIPAA 2026 OCR guidance
- ISO 27001 standard
- NIST SP 800-115
- FedRAMP requirements
- CIS Controls v8
- OWASP standards
- SAST Tool Evaluation Study 2024
