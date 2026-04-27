---
title: "Knowledge Base Errata"
owner: "Knowledge Base"
status: "active"
updated: "2026-04-26"
canonical: ""
---

This file documents corrections for "TASK INFORMATION INCORRECT" notes that were previously inline in the knowledge base. These corrections have been applied to the relevant knowledge files.

## Errata Log

### Scan Frequency (Security)

**Original Claim**: Quarterly vulnerability scanning is sufficient for HIPAA compliance.

**Correction**: Quarterly is NOT sufficient for HIPAA compliance as of 2026. OCR shifted vulnerability scanning from recommendation to MANDATORY, minimum TWO comprehensive scans per year (biannual), not quarterly. Non-compliance penalties: $100 to $50,000 per violation.

#### Accurate Information: Scan Frequency

- PCI DSS 4.0: external vulnerability scans quarterly by ASV, annual external/internal penetration testing (accurate)
- HIPAA 2026: minimum TWO comprehensive scans per year (biannual), not quarterly
- ISO 27001: recommended annually (not mandatory), risk-based frequency (accurate)
- SOC 2: depends on control design (accurate)
- CIS Control 7 (not 16): Control 7.5 (internal assets) requires quarterly or more frequent scans; Control 7.6 (externally-exposed assets) requires monthly or more frequent scans
- Higher-risk environments: monthly or weekly scanning recommended

**Applied to**: [security.md](security.md)

### GDPR Training Opt-out (Security)

**Original Claim**: Training opt-out per CNIL for GDPR/data protection training.

**Correction**: No specific CNIL guidance exists on "training opt-out" requirements for GDPR/data protection training.

#### Accurate Information: GDPR Training Opt-out

- GDPR training is effectively mandatory through interlocking provisions (Article 39 requires DPO to deliver awareness-raising and training; Article 32 requires appropriate organizational measures including training; Article 24 requires implementing necessary measures including staff training)
- French labor law allows employees to refuse training only with legitimate motives (health issues, conflict with approved leave, procedural violations by employer, discriminatory use, training unrelated to job functions)
- CNIL provides certification standards for data protection training programs (33 mandatory requirements, 44 optional) but no opt-out guidance
- No evidence of CNIL-specific opt-out requirements for data protection training

**Applied to**: [security.md](security.md)

### rschedule Library (Dependencies)

**Original Claim**: Library appears unmaintained.

**Correction**: Library appears unmaintained. Last commit: July 19, 2023 (almost 3 years old as of April 2026). Last version: v1.5.0 (February 3, 2023). 575 commits total but development stopped in 2023.

**Accurate Information**:

- GitLab is canonical repo, GitHub is mirror

- Features: date-agnostic (works with Date, Moment, luxon, dayjs, js-joda), immutable objects, ICAL RFC 5545 support, JSON serialization, modular/tree-shakable

- Consider alternative: rrule or custom implementation with Temporal API when browser support improves

**Applied to**: [dependencies.md](dependencies.md)

### Pattern Matching ES2026 (Technology Updates)

**Original Claim**: Pattern matching (match/using syntax) is part of ES2026.

**Correction**: Pattern matching (match/using syntax) is TC39 Stage 1 proposal, NOT part of ES2026.

**Accurate Information**:
- Approved for Stage 1 in May 2018, still in early development

- No polyfill available

- Syntax uses `match` expression and `is` operator, not `using`

- Champions: Daniel Rosenwasser (Microsoft), Jack Works (Sujitech), Jordan Harband (HeroDevs), Mark Cohen, Ross Kirsling (Sony), Tab Atkins-Bittner (Google)

- Do NOT plan for ES2026 adoption - not ready for production

**Applied to**: [technology-updates.md](technology-updates.md)

### Resend Inbound Log Retention (Webhooks)

**Original Claim**: 3-day log retention.

**Correction**: 3-day log retention insufficient - HIPAA requires 6 years, SOC 2 requires policies (no specific duration).

**Accurate Information**:

- Industry standards: HIPAA 6 years, SOX 7 years, NERC 6 months logs/3 years audit records, ISO 27001 12 months, PCI DSS 12 months

- React Email 5.0

- Inbound parse available

**Applied to**: [webhooks.md](webhooks.md)

### Tremor v4 Status (Dependencies)

**Original Claim**: Tremor v4 is stable preview ready for migration planning.

**Correction**: Tremor v4 is in early beta (v4.0.0-beta-tremor-v4.4), NOT a stable preview ready for migration planning.

**Accurate Information**:
- No official migration guide exists

- Breaking changes mentioned in changelog but not comprehensively documented

- v4 beta uses Tailwind CSS 4.0.0-beta.6 (itself in beta) and React 19.0.0

- Package.json shows version "0.0.0-development" indicating early development stage

- No GA timeline or production readiness information found

- Migration planning should wait until v4 reaches stable release with official migration documentation

**Applied to**: [dependencies.md](dependencies.md)

### React Compiler (Technology Updates)

**Original Claim**: Use eslint-plugin-react-compiler.

**Correction**: eslint-plugin-react-compiler has been DEPRECATED. React Compiler is now implemented via @babel/plugin-react-compiler Babel plugin. Linting is handled by eslint-plugin-react-hooks@latest.

**Accurate Information**:

- The linting functionality has been integrated into eslint-plugin-react-hooks

- New lint rules include: set-state-in-render, set-state-in-effect, refs

- Does not require the compiler to be installed, so no risk in upgrading

**Applied to**: [technology-updates.md](technology-updates.md)

### LangMem Configuration (AI Models)

**Original Claim**: LangMem for interactive agents.

**Correction**: LangMem has severe performance issues - p95 search latency 59.82s on LOCOMO benchmark (not a typo), accuracy 58.10% vs Mem0's 67.13% with 0.200s p95 latency. NOT suitable for interactive user-facing agents.

**Accurate Information**:

- Use for background/batch memory tasks only

- Mem0 recommended for interactive production agents (0.200s p95, 67.13% accuracy)

- LangMem provides semantic (user facts), episodic (past interactions), procedural (self-updated system prompts - unique to LangMem)

- Requires embedding index (dims + embed model) for semantic search

**Applied to**: [ai-models.md](ai-models.md)

---

## Notes

All corrections have been applied to the respective knowledge base files. The original monolithic 90-REF-KNOWLEDGE.md file contained these "TASK INFORMATION INCORRECT" notes inline; they have been extracted and corrected here for reference.
