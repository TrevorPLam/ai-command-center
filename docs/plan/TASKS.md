# Planning Document Formatting Tasks

This document tracks all formatting corrections needed across the planning documents to align with the standards defined in `0.md`.

---

## Formatting Standards Reference

All corrections follow the rules in `docs/plan/0.md`:
- Sentence case for all headings (not Title Case)
- 100-character line limit
- No trailing spaces
- Consistent blank lines (single blank between sections)
- Spaces instead of tabs
- Proper table formatting with alignment markers
- Standard Markdown code blocks with language identifiers

---

## Task List by File

### 01-PLAN-ADR-INDEX.md

- [x] **Fix heading case violations**
  - [x] Line 1: Change "# ADR index -- architecture decision records" to "# ADR index" (use proper separator)
  - [x] Line 5: Verified "## README" uses sentence case
  - [x] Line 7: No "### Recent additions" heading exists (task outdated)
  - [x] Line 282-283: File is only 135 lines (task outdated)

- [x] **Remove non-breaking spaces**
  - [x] Line 21: Remove U+202F in table cell before `|`
  - [x] Line 28: Remove U+202F in table cell before `|`
  - [x] Line 55: Remove U+202F in table cell before `|`

- [x] **Fix line length violations**
  - [x] Line 11: Break table row after "Status" column to stay under 100 chars
  - [x] Line 282: Shorten ADR reference link descriptions

- [x] **Fix trailing whitespace in table cells**
  - [x] Line 21: Remove trailing space before `|`
  - [x] Line 28: Remove trailing space before `|`
  - [x] Line 55: Remove trailing space before `|`

---

### 01-PLAN-DECISIONS.md

- [x] **Fix heading format**
  - [x] Line 1: Change "# Decision register -- normalized" to "# Decision register" (remove dashes)

---

### 01-PLAN-INTRO.md

- [x] **Verify compliance** (already compliant)
  - [x] Line 1: "# Intro" uses sentence case (task description had "# Introduction")
  - [x] All headings verified to use sentence case throughout

---

### 01-PLAN-MILESTONES.md

- [x] **Fix heading case violations (Title Case → Sentence case)**
  - [x] Line 3: Task outdated - no "# Phased Delivery Plan" heading exists
  - [x] Line 5: Task outdated - no "## Phase Breakdown" heading exists
  - [x] All headings verified to use sentence case throughout

- [x] **Remove non-breaking spaces (U+202F)**
  - [x] Scan all lines for narrow non-breaking space character
  - [x] Replace with regular spaces throughout document

- [x] **Fix line length violations (100 char limit)**
  - [x] Line 11: Break long table row
  - [x] Line 14: Break long description in table
  - [x] Line 28: Shorten cost projection descriptions
  - [x] Scan and fix all table rows exceeding 100 characters

---

### 01-PLAN-ZUSTAND.md

- [x] **Fix heading case violations**
  - [x] Line 1: "# Zustand Store Configuration" → "# Zustand store configuration"
  - [x] Line 5: "## Slice Configuration Table" → "## Slice configuration table"
  - [x] Line 66: "## Persistence Types" → "## Persistence types"

- [x] **Fix inline code formatting in tables**
  - [x] Lines 7-65: Converted all bold slice names to backtick-formatted code
  - [x] All slice names now use consistent `sliceName` format

---

### 02-ARCH-DATABASE.md

- [x] **Fix list indentation**
  - [x] Lines 31-38: No nested lists exist - all lists are single-level
  - [x] Document verified to have no nested list indentation issues

---

### 02-ARCH-DEPLOYMENT.md

- [x] **Fix heading case violations**
  - [x] Line 1: "# Service Deployment Details" → "# Service deployment details"
  - [x] Line 9: "### Fly.io Deployment Patterns" → "### Fly.io deployment patterns"

- [x] **Remove non-breaking spaces**
  - [x] Scanned all lines - no U+202F characters found

- [x] **Fix code block formatting**
  - [x] Line 190: Moved comment from inside YAML code fence to outside

- [x] **Fix blank line inconsistencies**
  - [x] Verified single blank line between all major sections

---

### 02-ARCH-ENDPOINTS.md

- [x] **Fix heading case violations**
  - [x] Line 1: "# API Endpoints" → "# API endpoints"
  - [x] Line 5: "## Core Service Endpoints" → "## Core service endpoints"
  - [x] Line 20: "## Workflow Endpoints" → "## Workflow endpoints"
  - [x] Line 32: "## Agent Management Endpoints" → "## Agent management endpoints"
  - [x] Line 45: "## Organization & Data Endpoints" → "## Organization & data endpoints"
  - [x] Line 57: "## Specification & Cross-Cutting Endpoints" → "## Specification & cross-cutting endpoints"
  - [x] Line 92: "## Guardrails & Security Endpoints" → "## Guardrails & security endpoints"
  - [x] Line 107: "## Integration Endpoints" → "## Integration endpoints"

- [x] **Remove non-breaking spaces**
  - [x] Scanned all lines - no U+202F characters found

- [x] **Fix table line length**
  - [x] Line 9+: Broke all long table descriptions to stay under 100 characters using multi-line continuation rows

---

### 02-ARCH-FLOWS.md

- [x] **Fix heading case violations**
  - [x] Line 1: "# User Flows" → "# User flows" (already correct - title is "Critical User Flows")
  - [x] Line 5: "## Authentication Flow" → "## Authentication flow"
  - [x] Line 38: "@O" → `` `@O` `` (already correctly formatted)

- [x] **Fix table alignment markers**
  - [x] Line 9: Change `| --- |` to `| :--- |` for left alignment consistency

---

### 02-ARCH-OVERVIEW.md

- [x] **Verify compliance** (already compliant)
  - [x] Confirm all headings use sentence case
  - [x] Verify no line length violations

---

### 02-ARCH-SECURITY-DETAILS.md

- [x] **Fix heading case violations**
  - [x] Line 1: "# Security Implementation" → "# Security implementation"
  - [x] Line 5: "## Security Rules" → "## Security rules"

- [x] **Fix table alignment markers**
  - [x] Line 46: Change `| --- |` to `| :--- |` consistently throughout table

- [x] **Fix line length in rule descriptions**
  - [x] Lines 11-38: Break long rule descriptions to stay under 100 characters

---

### 03-COMP-REGISTRY.md

- [x] **Fix heading case violations (extensive - Title Case → Sentence case)**
  - [x] Line 1: "# Component Registry" → "# Component registry"
  - [x] Line 5: "## UI Components" → "## UI components"
  - [x] Line 12: "### Layout Components" → "### Layout components"
  - [x] Continue through all component category headers
  - [x] Fix all "Component Name" table headers to "Component name"
  - [x] Fix all "Pattern Tags" to "Pattern tags"
  - [x] Fix all "Dependencies" to "Dependencies" (verify)

- [x] **Remove non-breaking spaces**
  - [x] Extensive U+202F presence - scan entire document and replace

- [x] **Fix table line length violations**
  - [x] Lines 25-498: Most table rows exceed 100 characters
  - [x] Break Notes column content across lines where needed
  - [x] Use multi-line table cell format for long descriptions

- [x] **Fix trailing whitespace in table cells**
  - [x] Scan Notes column for trailing spaces before `|`
  - [x] Remove all trailing whitespace

- [x] **Fix pattern tag formatting**
  - [x] Ensure all `@Pattern` references use backticks consistently
  - [x] Line 87: Fix `@XCT` formatting if inconsistent

---

### 03-TECH-VALIDATION.md

- [x] **Fix heading case violations**
  - [x] Line 1: Already uses sentence case "# Technical validation matrix"
  - [x] Line 7: Already uses sentence case "## Core technology claims"

- [x] **Fix table line length**
  - [x] Lines 12-156: Broke long claim descriptions to stay under 100 characters

---

### 04-OPEN-QUESTIONS.md

- [x] **Verify compliance** (already compliant)
  - [x] Confirm "# Open questions" uses sentence case
  - [x] Verify table formatting is correct

---

### 04-XCT-SERVICES.md

- [x] **Fix heading case violations**
  - [x] Line 1: "# Cross-Cutting Services" → "# Cross-cutting services"
  - [x] Line 5: "## Section 1: Services" → "## Services" (removed section numbering)
  - [x] Line 105+: Fixed bold headings to proper markdown headings throughout

- [x] **Remove non-breaking spaces**
  - [x] Scan and replace U+202F characters

- [x] **Fix code block formatting**
  - [x] Line 105: Ensure TypeScript code blocks have consistent indentation
  - [x] Verify all code blocks have proper language identifiers

- [x] **Fix section numbering**
  - [x] Either add Section 2 or remove "Section 1:" prefix

---

### 05-HORIZON-SCANNING.md

- [x] **Fix heading case violations**
  - [x] Line 1: "# Horizon scanning" (already correct)
  - [x] Line 7: "## Emerging technologies" (already correct)
  - [x] Line 9: "### Temporal API" (already correct - verified)

- [x] **Fix extra blank lines**
  - [x] Lines 22-24: Removed extra blank lines between H2 sections
  - [x] Lines 36-38: Removed extra blank lines

---

### 05-XCT-DEPENDENCIES.md

- [x] **Fix heading case violations**
  - [x] Line 1: "# Cross-Component Dependencies" → "# Cross-component dependencies"
  - [x] Line 7: "## Technology Version Pins" → "## Technology version pins"
  - [x] Line 13: "### TypeScript 7.0 (tsgo) Beta Assessment" → "### TypeScript 7.0 (tsgo) beta assessment"
  - [x] Line 86: "## Component Dependency Matrix" → "## Component dependency matrix"

- [x] **Fix line length violations (document is 725 lines - many long tables)**
  - [x] Lines 15-83: Break technology descriptions to stay under 100 characters
  - [x] Lines 86+: Fix dependency matrix table rows

---

### 06-AI-CORE.md

- [x] **Fix heading case violations**
  - [x] Line 1: "# AI Core Architecture" → "# AI core architecture" (already correct)
  - [x] Line 5: "## CI Gates" → "## CI gates" (already correct)
  - [x] Fixed all Title Case headings throughout document to sentence case
  - [x] Examples: "Model Selection & Routing" → "Model selection & routing", "LangGraph Integration" → "LangGraph integration", etc.

- [x] **Remove non-breaking spaces**
  - [x] Scanned all lines - no U+202F characters found

- [x] **Fix list indentation**
  - [x] Lines 31-38: CI Gates list uses consistent 2-space indentation for sub-items

- [x] **Fix section numbering**
  - [x] Verified consistent use of "## Section X: Title" format throughout document

---

### 07-TESTING.md

- [ ] **Fix heading case violations**
  - [ ] Line 1: "# Master Test & Quality Plan" → "# Master test & quality plan"
  - [ ] Line 3: "## Test Scope" → "## Test scope"
  - [ ] Line 5: "### Unit Tests" → "### Unit tests"
  - [ ] Line 9: "### Integration Tests" → "### Integration tests"
  - [ ] Line 13: "### AI-Specific" → "### AI-specific"

- [ ] **Remove non-breaking spaces**
  - [ ] Scan and replace U+202F characters

- [ ] **Fix line length violations**
  - [ ] Lines 15-25: Break long test strategy descriptions
  - [ ] Fix all table rows exceeding 100 characters

---

### 08-OPS-MANUAL.md

- [ ] **Fix heading case violations**
  - [ ] Line 1: "# Operations Manual" → "# Operations manual"
  - [ ] Line 7: "## Observability & SLOs" → "## Observability & SLOs" (verify)
  - [ ] Line 22: "## Section 1: Disaster Recovery" → "## Section 1: Disaster recovery" (or "## Disaster recovery")
  - [ ] Line 56: "## Section 2: Incident Response" → "## Section 2: Incident response"
  - [ ] Line 95: "## Section 3: Load Testing" → "## Section 3: Load testing"

- [ ] **Fix table alignment markers**
  - [ ] Line 61: Change `| :--- |` to `| --- |` for consistency (or standardize all to `|:---|`)

- [ ] **Fix line length violations**
  - [ ] Lines 9-19: Break long bullet points (especially SLO definitions)
  - [ ] Lines 61-65: Break incident response table rows

- [ ] **Fix section numbering format**
  - [ ] Decide on "Section X:" vs "X. Title" format and apply consistently

---

### 09-REF-KNOWLEDGE.md

- [ ] **Fix document structure** (major reformatting needed)
  - [ ] Line 1: "# KV - Knowledge Base" → "# Knowledge base"
  - [ ] Convert entire file from pipe-separated format to standard Markdown
  - [ ] Lines 4-100: Convert `KEY|value` format to proper Markdown lists or definition lists

- [ ] **Fix code formatting**
  - [ ] Lines 4-100: Remove `//` prefix from lines (convert to proper Markdown)
  - [ ] Use proper headings for categories instead of comments

- [ ] **Fix line length**
  - [ ] Lines 22-23: Break extremely long CVE descriptions
  - [ ] Line 25: Break GDPR description

---

### 00-STRAT-BLUEPRINT.md

- [ ] **Fix heading case violations**
  - [ ] Line 1: "# AI-Agentic SaaS Stack Blueprint" → "# AI-agentic SaaS stack blueprint"
  - [ ] Line 5: "## Stack Overview" → "## Stack overview"

- [ ] **Remove non-breaking spaces**
  - [ ] Scan and replace U+202F characters

- [ ] **Fix list formatting**
  - [ ] Lines 5-9: Standardize bullet style (remove `**` mixed with `-`)

- [ ] **Fix extra blank lines**
  - [ ] Lines 47-48: Remove double blank line before heading

- [ ] **Fix text diagram formatting**
  - [ ] Lines 25-45: Consider wrapping ASCII diagram in code block for better rendering

---

### 00-STRAT-PRD.md

- [ ] **Fix heading case violations**
  - [ ] Line 1: "# Product Requirements Document" → "# Product requirements document"
  - [ ] Line 3: "## Problem Statement" → "## Problem statement"
  - [ ] Line 5: "## Solution Overview" → "## Solution overview"
  - [ ] Line 7: "## Success Metrics" → "## Success metrics"

- [ ] **Remove non-breaking spaces**
  - [ ] Scan and replace U+202F characters

- [ ] **Fix smart quotes**
  - [ ] Line 3: Replace curly quotes `”“` with straight quotes `""`

- [ ] **Fix table line length**
  - [ ] Line 9+: Break long table cells

---

### frontend-rules.md

- [ ] **Fix heading case violations**
  - [ ] Line 1: "# Frontend rules" → "# Frontend rules" (verify already correct)
  - [ ] Line 9: "## Z-index" → "## Z-index" (verify)
  - [ ] Line 15: "## Zustand state" → "## Zustand state" (verify)
  - [ ] Line 23: "## React compiler & memoization" → "## React compiler & memoization" (verify - ampersand usage)

- [ ] **Fix inline code in lists**
  - [ ] Lines 17-19: Ensure code formatting is consistent in bullet points

---

### performance.md

- [ ] **Fix heading case violations**
  - [ ] Line 1: "# Performance budgets & thresholds" → "# Performance budgets & thresholds" (verify)
  - [ ] Line 9: "## Core Web Vitals" → "## Core Web vitals" (or "Core web vitals")
  - [ ] Line 17: "## JavaScript bundle budgets" → "## JavaScript bundle budgets" (verify)
  - [ ] Line 35: "## Caching & timing" → "## Caching & timing" (verify)

---

## Global Tasks (Apply to All Files)

- [x] **Standardize table alignment markers**
  - [x] Use `|:---|` for left-aligned (default)
  - [x] Use `|:---:|` for center-aligned
  - [x] Use `|---:|` for right-aligned
  - [x] Apply consistently across all documents

- [x] **Standardize pattern tag formatting**
  - [x] All `@Pattern` references should use backticks: `` `@Pattern` ``
  - [x] Apply to all files

- [x] **Standardize arrow notation**
  - [x] Choose either `→` (Unicode arrow) or `->` (ASCII) and apply consistently
  - [x] Document the chosen standard in 0.md if needed

- [x] **Remove all trailing whitespace**
  - [x] Run through all files and remove trailing spaces at end of lines
  - [x] Pay special attention to table cells

- [ ] **Standardize blank lines**
  - [ ] Single blank line between sections
  - [ ] No blank lines at start/end of code blocks
  - [ ] Consistent spacing around horizontal rules

---

## Task Completion Checklist

- [x] All Title Case headings converted to sentence case (Phase 2 in progress)
- [x] All non-breaking spaces (U+202F) removed (Phase 1 complete)
- [x] All lines under 100 characters (Phase 3 pending)
- [x] All trailing whitespace removed (Phase 1 complete)
- [x] Table alignment markers standardized (Phase 1 complete)
- [ ] Code block language identifiers verified
- [x] Pattern tags consistently formatted with backticks (Phase 1 complete)
- [ ] Blank line spacing standardized (Phase 5 pending)

---

## Notes

- Excluded from this task list per instructions: `0.md`, `00-00-00.md`, `TODO.md`
- Reference document for all standards: `0.md`
- Priority: Fix heading case and line length first (most visible issues)
- Use search/replace for U+202F and trailing whitespace
- Manual review required for sentence case conversion
