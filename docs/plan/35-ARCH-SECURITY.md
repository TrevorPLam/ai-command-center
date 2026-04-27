---
title: "Security Implementation Details"
owner: "Security"
status: "active"
updated: "2026-04-26"
canonical: "security-controls.yaml"
---

This document contains detailed security implementation specifications and configurations for the AI Command Center platform. For high-level security architecture, see [30-ARCH-OVERVIEW.md](30-ARCH-OVERVIEW.md).

---

## Security rules (S1 - S28)

All security rules are **HARD**. Violating any of them will block a deployment.

For the complete rule definitions, see [00-RULES.yaml](00-RULES.yaml).

- #SEC-01: Use SanitizedHTML for all user-generated HTML (STRICT, RICH, EMAIL profiles)
- #SEC-02: Supabase storage access only via StorageService wrapper
- #SEC-03: Nylas API calls only from FastAPI backend
- #SEC-04: Only supabase-js allowed in browser; SQLModel never in frontend
- #SEC-05: SQLModel schema changes must update RLS policies
- #SEC-06: Global CSP enforced in production (nonce-based, strict-dynamic)
- #SEC-07: unsafe-eval only for Monaco/Babel in sandboxed iframes
- #SEC-08: JWT stored only in httpOnly cookie, never in Zustand/localStorage
- #SEC-09: All /v1/* API calls through centralized api.ts client
- #SEC-10: DOMPurify >=3.4.0 mandatory; automated CVE audit in CI
- #SEC-11: CSP nonce cryptographically random per request; strict-dynamic
- #SEC-12: LiveKit tokens scoped to rooms and capabilities; RBAC enforced
- #SEC-13: RBAC applied to all resources; no ad-hoc permission checks
- #SEC-14: Rate limiting enforced per user and organization
- #SEC-15: Organization deletion cascades; notify admins 7 days before
- #SEC-16: Agent-driven UI only uses trusted GenUI catalog components
- #SEC-17: Yjs collaboration opt-in per document type
- #SEC-18: AI cost hard cap enforced at LLM proxy level
- #SEC-19: MCP tool registration requires admin approval; all logged
- #SEC-20: AI cost thresholds trigger alerts and rate limits
- #SEC-21: OpenAPI 3.1 single source of truth; Orval generates types
- #SEC-22: pgvector-retrieved chunks pass guardrails input layer
- #SEC-23: Secret rotation failure treated as P1 incident; SOC2 evidence
- #SEC-24: Use Grype (not Trivy) for Docker scanning; credential isolation
- #SEC-25: Supabase auth_admin role requires SELECT grants on user tables
- #SEC-26: Sentry projects strip PII; Session Replay masks text
- #SEC-27: ClamAV v1.4.x sidecar in production; freshclam hourly
- #SEC-28: Three DOMPurify profiles; test matrix ensures XSS prevention

---

## 12-Layer Security Architecture

The platform implements defense in depth with 12 security layers (S1-S12). For the complete control registry including descriptions, mechanisms, test methods, and threat mappings, see [security-controls.yaml](./security-controls.yaml).

**Key Layers:**

- **L1-L3**: Infrastructure hardening (network isolation, CSP, rate limiting)
- **L4-L5**: Identity and data access (JWT auth, RLS with org_id)
- **L6-L8**: Supply chain and AI security (dependency verification, MCP guardrails)
- **L9-L12**: Operations and compliance (secret rotation, SOC2, GDPR, audit logging)

---

## PowerSync Certification

| Certification | Status | Plan Availability | Documentation Links | Compliance Gaps |
|---------------|--------|-------------------|---------------------|-----------------|
| SOC 2 Type 2 | Audited (several years) | Team and Enterprise plans | https://docs.powersync.com/resources/security | None - fully compliant |
| HIPAA | Compliant (requires BAA) | Pro, Team, and Enterprise plans | https://docs.powersync.com/resources/hipaa | Customer must sign BAA before storing ePHI |

---

## SOC2 Automation

SOC2 automation via Vanta; see [compliance-soc2.md](compliance-soc2.md) for detailed evidence collection, control mapping, and TSC guidance.

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

The complete GitHub Actions workflow is maintained in a separate file for better maintainability and token efficiency.

- **Workflow file**: [.github/workflows/security-scan.example.yml](../../.github/workflows/security-scan.example.yml)
- **Purpose**: Dual-scanner pattern with credential isolation per Trivy supply chain compromise lessons
- **Key features**:
  - Build job outputs image digest, scanner jobs rebuild from source (no registry credentials)
  - Permission isolation: Scanner jobs have only `contents: read` and `security-events: write`
  - No credential inheritance: Separate job context with no access to parent credentials
  - SARIF integration: Both scanners upload to GitHub Security tab
  - Optional secondary scanner: Trivy runs only if IaC/secrets/license scanning needed

---

## Related Documentation

- [30-ARCH-OVERVIEW.md](30-ARCH-OVERVIEW.md) - High-level security architecture
- [ADR_111](01-PLAN-DECISIONS.md#adr_111) - Grype replaces Trivy for Docker scanning
- [ADR_119](01-PLAN-DECISIONS.md#adr_119) - Vanta as SOC2 automation platform