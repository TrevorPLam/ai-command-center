---
title: "NIS2 Compliance"
owner: "Compliance"
status: "active"
updated: "2026-04-26"
canonical: ""
---

# NIS2 Compliance

The NIS2 Directive (EU 2022/2555) establishes a unified legal framework for cybersecurity across 18 critical sectors in the EU. It came into force in January 2023, with Member States required to transpose it into national law by October 17, 2024. NIS2 introduces stronger enforcement, wider scope, and management accountability for cybersecurity.

---

## Key NIS2 Requirements

### Article 20: Corporate Accountability

- Management must oversee, approve, and be trained on cybersecurity measures
- Breaches may result in penalties for management, including liability and potential temporary ban from management roles
- Board-level cybersecurity oversight is mandatory
- Management approval required for all risk management measures and residual risk acceptance

### Article 21: Risk Management Measures

NIS2 requires implementation of "appropriate and proportionate technical, operational and organisational measures" across 10 minimum measures:

1. **Risk assessments and security policies** for information systems
2. **Policies for evaluating effectiveness** of security measures
3. **Cryptography and encryption policies** for data protection
4. **Security incident handling plan** with detection and response procedures
5. **Procurement and development security** including vulnerability handling
6. **Cybersecurity training** and basic computer hygiene practices
7. **Employee security procedures** for access to sensitive data
8. **Business continuity plan** for during and after incidents (backups, access to IT systems)
9. **Multi-factor authentication** and encryption (voice, video, text, emergency comms)
10. **Supply chain security** for direct supplier relationships

### Article 23: Incident Reporting

- **Early warning**: 24-hour notification deadline for incidents with significant impact
- **Incident notification**: Detailed report within 72 hours
- **Final report**: Comprehensive report with root cause, impact, and remediation

### Articles 31 & 32: Documentation and Audit Trails

- Complete lifecycle history of all security-related documents
- Document versions with timestamps and author signatures
- Approval and review records with management sign-off
- Change logs explaining why updates were made
- Incident records retained long-term for regulatory investigations

---

## NIS2 Audit Trail Requirements

### Evidence-Based Compliance

NIS2 shifts from policy-based assurance to evidence-based proof. Documentation alone is insufficient; organizations must demonstrate continuous compliance through:

- **Audit trails linking risk treatment decisions to governance obligations**
- **Real-time behavioral evidence** of control effectiveness
- **Management dashboards** showing security KPIs and risk metrics
- **Continuous monitoring** not just point-in-time compliance

### Document Retention Requirements

While NIS2 does not specify exact retention periods, regulatory best practice suggests:

| Document Type | Minimum Retention | Rationale |
|---------------|-------------------|-----------|
| Incident records | 5 years | Regulatory investigations, forensic analysis |
| Risk assessments | 3 years | Demonstrate ongoing risk management |
| Policy documents | Life of policy + 3 years | Complete lifecycle history, version control |
| Training records | 3 years | Evidence of security awareness compliance |
| Supply chain assessments | 3 years | Third-party risk management evidence |
| Access control reviews | 3 years | Least privilege enforcement evidence |

### Audit Trail Components

**Governance Documentation**
- Documented Risk Management Policies with version histories, review logs, and meeting minutes showing formal management/board approval
- Incident Response and Crisis Management Plans with tabletop exercise logs, post-incident reports, and revision changelogs
- Supply Chain Security Policies with supplier vetting procedures, contracts with cybersecurity clauses, and assessment records

**Technical Logs**
- Access Control Review Logs: Timestamped records of quarterly/semi-annual reviews, approval logs, ex-employee account disablement evidence
- Security Monitoring and Event Logs (SIEM): Failed login attempts, impossible travel alerts, EDR logs, DLP alerts
- Human Risk KPIs and Reporting: Management dashboards showing security metrics, risk analysis, and decision-making

---

## Compliance Gap Analysis

### Current Architecture Assessment

| NIS2 Requirement | Current Status | Gap | Remediation Priority |
|-----------------|----------------|-----|----------------------|
| Article 20: Management accountability | Partial | No formal board approval documentation for cybersecurity measures | High |
| Article 21(1): Risk assessments | Partial | Risk assessment process exists but lacks formal documentation trail | High |
| Article 21(2): Security policies | Partial | Security policies exist but lack version control and audit trails | High |
| Article 21(2)(d): Supply chain security | Gap | No continuous TPRM, only periodic vendor questionnaires | High |
| Article 23: Incident reporting (24h) | Partial | Incident response exists but no formal 24-hour early warning process | High |
| Articles 31/32: Document lifecycle | Gap | No centralized document retention, version control, or audit trail system | High |
| Evidence-based proof | Gap | Relies on static artifacts, no real-time behavioral evidence | Medium |
| Training records | Partial | Training occurs but lacks comprehensive record-keeping | Medium |
| Access control reviews | Partial | Reviews occur but lack formal audit trail | Medium |
| Business continuity planning | Partial | DR plan exists but needs NIS2-specific documentation | Medium |

### Critical Gaps Requiring Immediate Attention

1. **Document Lifecycle Management System**
   - No centralized repository for security-related documents
   - Missing version control with timestamps and author signatures
   - No approval workflow with management sign-off
   - Missing change logs and review records

2. **Management Accountability Documentation**
   - No formal records of board-level cybersecurity oversight
   - Missing management approval documentation for risk management measures
   - No evidence of management training on cybersecurity responsibilities

3. **Supply Chain Security**
   - No continuous third-party risk monitoring
   - Supplier cybersecurity clauses not standardized in contracts
   - Missing supplier assessment records and vetting procedures

4. **Incident Reporting Timeline**
   - No formal 24-hour early warning process
   - Missing incident notification templates and procedures
   - No clear escalation matrix for NIS2 reporting

5. **Evidence Collection and Audit Trails**
   - No automated collection of security telemetry
   - Missing correlation between technical logs and governance decisions
   - No management dashboards for security KPIs

---

## Documentation Inventory

### Required NIS2 Documentation

**Governance and Risk Management (Article 21)**
- [ ] Risk Management Policy (with version control, approval records, review logs)
- [ ] Incident Response and Crisis Management Plan (with tabletop exercise logs, post-incident reports)
- [ ] Supply Chain Security Policy (with supplier vetting procedures, contract templates, assessment records)
- [ ] Business Continuity Plan (with backup verification logs, recovery test results)
- [ ] Cryptography and Encryption Policy (with key management procedures)
- [ ] Access Control Policy (with review logs, approval records)
- [ ] Vulnerability Management Policy (with patch tracking, remediation records)
- [ ] Asset Inventory (with ownership, classification, lifecycle records)

**Training and Awareness**
- [ ] Cybersecurity Training Program (with training records, completion logs)
- [ ] Security Awareness Materials (with distribution records, effectiveness metrics)
- [ ] Phishing Simulation Results (with KPIs, improvement tracking)
- [ ] Management Training Evidence (C-suite and board training records)

**Incident Management**
- [ ] Incident Response Procedures (with escalation matrix, notification templates)
- [ ] Early Warning Notification Template (24-hour deadline)
- [ ] Incident Notification Template (72-hour deadline)
- [ ] Final Report Template (with root cause analysis format)
- [ ] Incident Log (with all incidents, timeline, remediation actions)

**Technical Evidence**
- [ ] Access Control Review Logs (quarterly/semi-annual, with approval records)
- [ ] Security Monitoring Logs (SIEM, with alert investigation records)
- [ ] Vulnerability Scan Reports (with remediation tracking)
- [ ] Backup Verification Logs (weekly restoration test results)
- [ ] Security KPI Dashboards (management reporting, trend analysis)

**Supply Chain**
- [ ] Supplier Vetting Checklist (completed for all suppliers)
- [ ] Supplier Security Assessments (completed records)
- [ ] Contracts with Cybersecurity Clauses (standardized templates)
- [ ] Continuous TPRM Monitoring Records (real-time supplier risk scores)

---

## Automation Opportunities

### High-Value Automation Targets

**Document Lifecycle Management**
- **Automated version control**: Git-based repository for all security documents with automatic versioning, timestamps, and author tracking
- **Approval workflow automation**: Implement approval gates in document management system requiring management sign-off before policy activation
- **Review reminder automation**: Automated notifications for annual/quarterly reviews with escalation to management if overdue
- **Change log generation**: Automatic capture of document changes with rationale and approval records

**Evidence Collection**
- **SIEM integration**: Automated collection of security logs with correlation to governance controls
- **Access control review automation**: Scheduled reviews with automated notification to data owners for approval
- **Training record automation**: LMS integration with automatic capture of completion records and effectiveness metrics
- **Incident logging automation**: Automated incident capture from monitoring systems with template-based reporting

**Supply Chain Security**
- **Continuous TPRM integration**: Automated supplier risk scoring with real-time alerts for high-risk suppliers
- **Contract clause enforcement**: Automated review of contracts for required cybersecurity clauses during procurement
- **Supplier assessment automation**: Standardized assessment forms with automated scoring and remediation tracking

**Reporting and Dashboards**
- **Management dashboard automation**: Real-time security KPI dashboards with trend analysis and risk heatmaps
- **Incident reporting automation**: Automated 24-hour early warning generation with pre-populated templates
- **Audit trail visualization**: Automated generation of compliance evidence packages for audits

### Implementation Priority

| Automation Target | Complexity | Impact | Timeline | Estimated Effort |
|-------------------|------------|-------|----------|------------------|
| Document version control (Git) | Low | High | Q2 2026 | 2-3 weeks |
| Approval workflow automation | Medium | High | Q2 2026 | 4-6 weeks |
| Review reminder automation | Low | Medium | Q2 2026 | 1-2 weeks |
| SIEM integration for evidence | High | High | Q3 2026 | 8-10 weeks |
| Access control review automation | Medium | High | Q3 2026 | 4-6 weeks |
| Training record automation (LMS) | Medium | Medium | Q3 2026 | 3-4 weeks |
| Continuous TPRM integration | High | High | Q4 2026 | 10-12 weeks |
| Management dashboard automation | High | High | Q4 2026 | 8-10 weeks |
| Incident reporting automation | Medium | High | Q3 2026 | 4-6 weeks |
| Contract clause enforcement | Medium | Medium | Q4 2026 | 3-4 weeks |

---

## Implementation Roadmap

### Phase 1: Foundation (Q2 2026)
- Establish Git-based document repository for all security-related documents
- Implement version control with automatic timestamps and author tracking
- Create approval workflow requiring management sign-off
- Develop document templates for all required NIS2 documentation
- Implement review reminder automation

### Phase 2: Evidence Collection (Q3 2026)
- Integrate SIEM for automated log collection and correlation
- Implement access control review automation
- Deploy training record automation (LMS integration)
- Establish incident reporting automation with 24-hour early warning
- Create management dashboard for security KPIs

### Phase 3: Supply Chain and Advanced Automation (Q4 2026)
- Implement continuous TPRM integration
- Deploy contract clause enforcement automation
- Enhance management dashboard with predictive analytics
- Implement automated audit trail visualization
- Conduct full NIS2 compliance audit and remediation

---

## Monitoring and Continuous Improvement

### KPIs for NIS2 Compliance

| KPI | Target | Measurement Frequency | Owner |
|-----|--------|----------------------|-------|
| Document review completion rate | 100% | Monthly | GRC Lead |
| Management approval timeliness | <5 business days | Monthly | GRC Lead |
| Incident early warning compliance (24h) | 100% | Per incident | Security Lead |
| Access control review completion | 100% | Quarterly | Security Lead |
| Training completion rate | 95% | Quarterly | HR + Security |
| Supplier assessment completion | 100% | Quarterly | Security Lead |
| Evidence collection automation rate | >80% | Monthly | Platform Lead |
| Audit trail completeness | 100% | Monthly | GRC Lead |

### Continuous Improvement Process

1. **Monthly compliance review**: Assess KPI performance, identify gaps, update remediation plans
2. **Quarterly management review**: Present compliance status to board, address strategic issues
3. **Annual gap assessment**: Full NIS2 compliance assessment against updated regulatory requirements
4. **Continuous monitoring**: Automated alerts for compliance drift, documentation overdue, evidence gaps

---

## References

- [NIS2 Directive (EU 2022/2555)](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32022L2555)
- [ENISA NIS2 Technical Implementation Guidance](https://www.enisa.europa.eu/publications/nis2-technical-implementation-guidance)
- [EU Digital Strategy - NIS2 Directive](https://digital-strategy.ec.europa.eu/en/policies/nis2-directive)
- [NIS2 Cooperation Group Guidelines](https://digital-strategy.ec.europa.eu/en/policies/nis-cooperation-group)
