---
title: "Dependency Security and Maintenance"
owner: "Security"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

LiteLLM supply chain attack March 2026 (pin >=1.83.7 with cosign), Orval CVEs (upgrade >=8.2.0, never run on untrusted OAS), various library maintenance status updates.

## Key Facts

### LiteLLM Security

**LITELLM_SEC**: Supply chain attack

- Date: March 24, 2026
- Affected versions: v1.82.7-1.82.8
- TeamPCP incident
- Fix: pin >=1.83.7 with cosign SHA verification
- CVEs: CVE-2026-35029 (RCE), CVE-2026-35030 (auth bypass)

### Orval Security

**ORVAL_SEC**: Multiple CVEs

- CVE-2026-24132, CVE-2026-23947, CVE-2026-25141 (JSFuck bypass)
- CVSS: 9.8 (Critical)
- Fix: upgrade >=8.2.0
- Never run on untrusted OpenAPI specs
- Reject patterns: brackets, parentheses, exclamation, plus, semicolon

### React Big Calendar Maintenance

**RBC_MAINTENANCE**: Latest release v1.19.4 (June 16, 2025)

- 10 months old as of April 26, 2026
- Last commits June 2025, no 2026 activity visible
- 8,500+ GitHub stars, ~500K weekly npm downloads
- Issues still being opened in 2026 (#2795 Mar 23, #2791 Jan 30, #2789 Jan 15, #2785 Jan 15)
- Not abandoned but maintenance appears slow (no commits in 10 months)
- React 19 compatibility: Partial - JSX transform warning (Issue #2785) with modern JSX runtime
- Workaround: Suppress warning or wait for library update to modern JSX transform
- Decision: Stay with v1.19.4 for now (ADR_014), monitor for updates, evaluate FullCalendar migration if maintenance continues to stall

### Tremor Maintenance Status

**TREMOR_STATUS**: Actively maintained by Tremor Labs (Vercel-acquired)

- v3.18.x stable
- v4 beta (early development)
- ~27K GitHub stars
- Safe ADR

### Tremor v4 Migration

**TREMOR_V4_STATUS**: Early beta, not ready for migration planning

- Version: v4.0.0-beta-tremor-v4.4
- NOT a stable preview ready for migration planning
- No official migration guide exists
- Breaking changes mentioned in changelog but not comprehensively documented
- v4 beta uses Tailwind CSS 4.0.0-beta.6 (itself in beta) and React 19.0.0
- Package.json shows version "0.0.0-development" indicating early development stage
- No GA timeline or production readiness information found
- Migration planning should wait until v4 reaches stable release with official migration documentation

#### Known Breaking Changes

**TREMOR_V4_BREAKING**: From changelog snippets

- Toggle component removed (replace with TabList variant="solid")
- Tabs component redesigned with new API (now has "line" and "solid" variants)
- Dropdown component removed (use new Select component)
- DateRangePicker API changed significantly
- Note: This is not a comprehensive list as no official breaking changes documentation exists for v4 beta

### rrule Library

**RSCHEDULE**: Library appears unmaintained

- Last commit: July 19, 2023 (almost 3 years old as of April 2026)
- Last version: v1.5.0 (February 3, 2023)
- 575 commits total but development stopped in 2023
- GitLab is canonical repo, GitHub is mirror
- Features: date-agnostic (works with Date, Moment, luxon, dayjs, js-joda), immutable objects, ICAL RFC 5545 support, JSON serialization, modular/tree-shakable
- Consider alternative: rrule or custom implementation with Temporal API when browser support improves

### rrule DST Bug

**RRULE_DST_BUG**: TZID-parameterized DTSTART RFC5545 non-compliant

- DST shifts 1 hour
- Replace: FE → rschedule + `@rschedule`/temporal-date-adapter
- BE unchanged

## Why It Matters

- Supply chain attacks can compromise entire application
- Dependency maintenance affects long-term support and security
- Unmaintained libraries pose security and compatibility risks
- Migration planning requires stable releases with documentation

## Sources

- CVE database entries
- GitHub repository activity
- npm package statistics
- Library changelogs
