# Documentation Optimization Task Checklist

Each parent task corresponds to a file (or new file) to be updated. Subtasks detail the specific changes required. Check off each item as completed.

---

## 1. `00-MANIFEST.yaml` (NEW)

- [x] Create `00-MANIFEST.yaml` at root of docs directory
    - [x] Define YAML structure: `files` list with `path`, `type` (governance/architecture/plan/spec/reference), `summary` (1 sentence), `load` (always/on-demand/never), `tags` (optional)
    - [x] Add entries for all existing documentation files (including auto‑generated ones)
    - [x] Add dependency links between files (key integration points)
    - [x] Document the tiered loading protocol: Session Starter, Task‑Specific, Deep Reference

---

## 2. Unified Rules Register `00-RULES.yaml` (NEW)

- [x] Create `00-RULES.yaml`
    - [x] Extract all `(HARD)`, `(MED)` rules from `30-ARCH-OVERVIEW.md`, `100-FRONTEND-RULES.md`, `60-AI-CORE.md`, `35-ARCH-SECURITY.md`, `31-ARCH-DATABASE.md`
    - [x] Assign a globally unique ID to each rule using the new namespace (`FE‑…`, `BE‑…`, `SEC‑…`, `AI‑…`, `GOV‑…`)
    - [x] For each rule include: `id`, `domain`, `severity`, `description` (≤1 sentence), `check` (lint rule or test name if applicable)
    - [x] Remove duplicate rules; keep single representation
    - [x] Validate that every (HARD) rule in the original documents has an entry in this register

- [x] Refactor all rule‑referencing documents to use rule IDs
    - [x] Replace full rule text in `30-ARCH-OVERVIEW.md § Architecture rules` with references like `#BE‑01`, `#FE‑02` (plus a one‑line summary where needed for readability)
    - [x] Replace rules in `100-FRONTEND-RULES.md` with references to `#FE‑xx`
    - [x] Replace AI/Model rules in `60-AI-CORE.md § AI & Model Rules` with `#AI‑xx`
    - [x] Replace security rules list in `35-ARCH-SECURITY.md` with `#SEC‑xx`
    - [x] Replace data/offline rules in `31-ARCH-DATABASE.md` with `#BE‑xx`
    - [x] Ensure all cross‑references use the new IDs, e.g., `complies with #SEC‑11`

- [x] Generate human‑friendly rule documents from the YAML
    - [x] Set up a CI script to transform `00-RULES.yaml` → `00-RULES.md` (grouped by domain)
    - [x] Regenerate any separate rule files (e.g., frontend rules, AI rules) from the same source, if still needed

---

## 3. Unified Decision Log `01-PLAN-DECISIONS.md` (MERGE)

- [x] Merge Decision Register and ADR Index into a single append‑only log
    - [x] Add `Type` column (process, architecture, product, question) and `ADR_Ref` column to the existing decision table
    - [x] Import all active ADR summaries from `22-PLAN-ADR-INDEX.md` into the unified table as `Type: architecture` rows, with `ADR_Ref` pointing to the full ADR document
    - [x] Convert open questions from `23-PLAN-QUESTIONS.md` into rows with `Type: question` and `Status: open`
    - [x] Ensure all ADR statuses (active/superseded/updated) are reflected; superseded ADRs remain in the history table
    - [x] Add guidance at top of file: this log is the single source for all decisions and questions
    - [x] Retain append‑only policy, now for all types

- [x] Update supersession logic
    - [x] Ensure superseded rows in the unified log point to the new decision/ADR that replaces them
    - [x] Add `Linked Items` column containing both the ADR ID and any related rule IDs

- [x] Update `DEC‑2026‑04‑26‑001` through `005` if their domain or type changes due to merge

- [x] Archive `22-PLAN-ADR-INDEX.md` (keep as historical reference but note that canonical source is now the unified log)
    - [x] Add a deprecation notice at top of `22-PLAN-ADR-INDEX.md` pointing to the unified log

- [x] Archive `23-PLAN-QUESTIONS.md` (migrate all live items to decision log, add note about archival)

---

## 4. `30-ARCH-OVERVIEW.md`

- [x] Apply inverted‑pyramid structure
    - [x] Add a "TL;DR" summary block (key decisions, technology constraints, domain ownership, rule references) directly under the title
    - [x] Move detailed deployment patterns (Y‑Sweet, LiveKit, Redis scaling) to `38-ARCH-DEPLOYMENT.md` or a new appendix
    - [x] Keep only the C1/C2 overview, architecture rules (in short form), and inter‑domain dependency summary

- [x] Replace inline rules with `#rule‑id` references (as per task 2)

- [x] Remove redundant security controls summary (the detailed matrix is in `35-ARCH-SECURITY.md`; reference it)

- [x] Add a Mermaid dependency graph at the top showing domain/data flow

---

## 5. `11-STRAT-BLUEPRINT.md` & `10-STRAT-PRD.md`

- [x] Eliminate duplication between PRD and Blueprint
    - [x] Strip the Blueprint of all product‑level content (vision, jobs, metrics, monetisation, personas) – cross‑reference PRD with a one‑line note
    - [x] Keep in Blueprint only: design axioms, six‑domain framework, intent dispatcher, domain descriptions, inter‑domain dependencies, and horizon scanning link
    - [x] Verify that no essential information is lost; all product‑specific detail remains in PRD

- [x] Add a TL;DR summary block in both files

- [x] In `10-STRAT-PRD.md`, move the JTBD backlog and RICE/MoSCoW to appendices; keep only the vision and critical success metrics in the main narrative

---

## 6. `21-PLAN-MILESTONES.md`

- [ ] Align milestone features with PRD JTBDs
    - [ ] For each feature block (Block 0A–5), add a column or inline reference to the corresponding JTBD ID (J001, etc.) and RICE score
    - [ ] Remove standalone feature IDs (F001, P101) in favor of readable descriptions plus JTBD references; keep feature IDs only for internal tracking if necessary

- [ ] Add a traceability matrix at the end: feature ↔ JTBD ↔ RICE priority

- [ ] Apply inverted‑pyramid: concise summary of all phases and triggers, then detailed feature lists as appendices

---

## 7. `40-COMP-REGISTRY.md` → `component-registry.yaml` + human summary

- [ ] Create `component-registry.yaml` as the authoritative data source
    - [ ] Define YAML schema: `components` list with `id`, `module`, `type`, `tags` (single‑letter codes), `rules` (ID list), `dependencies`, `notes`
    - [ ] Migrate all entries from the current markdown table

- [ ] Create a concise human‑readable summary (`40-COMP-OVERVIEW.md`)
    - [ ] List modules and their component counts, plus highlights of important patterns
    - [ ] Link to `component-registry.yaml` for the full inventory
    - [ ] Keep the pattern tag glossary explained in one place (in the summary or a separate glossary)

- [ ] Set up CI to regenerate the summary table from the YAML when it changes, ensuring it never drifts

- [ ] Deprecate the original `40-COMP-REGISTRY.md` if fully replaced

---

## 8. `50-XCT-SERVICES.md` – Split into per‑domain service files

- [ ] Break into separate files by architectural layer
    - [ ] `50-XCT-FOUNDATION.md` (Auth/Secrets, Rate Limiting, CSP)
    - [ ] `50-XCT-DATA.md` (Realtime, Offline, Recurrence)
    - [ ] `50-XCT-AI.md` (Guardrails, Cost Tracking, OTel, MCP Security)
    - [ ] `50-XCT-UI.md` (Motion, Optimistic, Sanitisation, Design System)

- [ ] Create a `50-XCT-INDEX.md` as a light‑weight manifest linking to these files with one‑sentence descriptions

- [ ] Remove the monolithic `50-XCT-SERVICES.md`; redirect references to the index

---

## 9. `33-ARCH-ENDPOINTS.md` – Delete endpoint listing

- [ ] Remove all endpoint tables that duplicate `34-arch-endpoints-schema.yaml`
    - [ ] Keep the versioning strategy and API lifecycle sections
    - [ ] Convert the file into a concise “API Overview” describing the API domain groups (Core, Workflow, Agent, etc.) with links to the OpenAPI spec
    - [ ] Remove any per‑endpoint descriptions; the spec is the authoritative source

- [ ] Ensure the OpenAPI spec is the single source of truth and is linted in CI

---

## 10. `70-TESTING.md` – Split into strategy, benchmarks, schedule

- [ ] Create `70-TESTING-STRATEGY.md`
    - [ ] Move sections: Introduction, Quality Vision, Test Levels & Ownership, AI‑Specific Testing Approach (without deep benchmarks), Automation Strategy (high level), Release Criteria
    - [ ] Keep all gate configurations and thresholds

- [ ] Create `70-TESTING-BENCHMARKS.md`
    - [ ] Move deep dives: pgTAP effectiveness, Orval accuracy, Playwright agent costs, contract testing tool comparisons, CVE mapping details
    - [ ] Keep as appendix, loaded only when needed

- [ ] Create `70-TESTING-SCHEDULE.md`
    - [ ] Move phased testing schedule and risk register

- [ ] Add a `70-TESTING-INDEX.md` linking to these three files

---

## 11. `90-REF-KNOWLEDGE.md` – Refactor into atomic knowledge base

- [ ] Create `kb/` directory
- [ ] For each major topic, extract a separate file with consistent structure: `TL;DR`, `Key Facts`, `Why it Matters`, `Sources`
    - [ ] `kb/ai-models.md` (model registry, cost models, tool‑calling)
    - [ ] `kb/mcp-cves.md` (all MCP‑related CVEs and mitigations)
    - [ ] `kb/nylas-webhooks.md` (webhook reliability, grant expiry, backfill)
    - [ ] `kb/powersync-config.md` (sync rules, connection limits)
    - [ ] `kb/tauri-capabilities.md` (capability model, CI validation)
    - [ ] … and similarly for all other sections currently in the monolithic KB

- [ ] Create `kb/_index.md` listing all topics with one‑line summaries and links

- [ ] Create `kb/_errata.md` for all previous “TASK INFORMATION INCORRECT” notes; remove inline corrections from the knowledge files

- [ ] Replace the original `90-REF-KNOWLEDGE.md` with a pointer to the `kb/` index

---

## 12. `versions.yaml` (NEW) + `51-XCT-DEPENDENCIES.md`

- [ ] Create `versions.yaml`
    - [ ] Extract all technology version pins from `51-XCT-DEPENDENCIES.md` and other docs
    - [ ] Structure as YAML map: `package: version` (with exact versions for hard pins, ranges for loose)

- [ ] Update `51-XCT-DEPENDENCIES.md`
    - [ ] Replace the version table with a reference to `versions.yaml`
    - [ ] Keep only rationale and risk commentary (e.g., “we pin Prisma 7.8.0 because…”)

- [ ] Set up CI to validate that locked versions in `package.json` match `versions.yaml`

---

## 13. `35-ARCH-SECURITY.md` – Extract control matrix to YAML

- [ ] Create `security-controls.yaml`
    - [ ] List all S1‑S28 controls with description, mechanism, test method, ADR reference
    - [ ] Map each control to the relevant ASI/OWASP threat

- [ ] In the prose document, replace the control matrix with a brief summary and link to the YAML

- [ ] Ensure cross‑references to rule IDs (`#SEC‑xx`) are consistent

---

## 14. `100-FRONTEND-RULES.md` – Convert to generated file

- [ ] After rules register creation, set `100-FRONTEND-RULES.md` to be regenerated from `00-RULES.yaml` (filter by domain `frontend`)
    - [ ] The generated file retains the Z‑index, loading states, etc., already defined in the register

- [ ] Add a note at top: “This file is auto‑generated; do not edit directly. Source: `00-RULES.yaml`.”

---

## 15. `DEC‑2026‑04‑26‑004` – Update tiered loading decision

- [ ] Supersede `DEC‑2026‑04‑26‑004` with a new decision
    - [ ] New decision: “AI agents follow tiered loading protocol defined in `00-MANIFEST.yaml`; always load session starter set, expand on demand.”
    - [ ] Mark old entry as `superseded`, link to new row

---

## 16. Missing `SPEC-TEMPLATE.md` (NEW)

- [ ] Create `SPEC-TEMPLATE.md`
    - [ ] Define mandatory frontmatter (title, status, tier, authors)
    - [ ] Define required sections (Summary, Constraints, Dependencies, Quality Gates, etc.)
    - [ ] Include guidance for token‑efficient formatting (concise tables, rule references)

- [ ] Update Decision Register entry `DEC‑2026‑04‑26‑001` to link to the new template

---

## 17. CI Pipeline for Auto‑Generated Agent Context Bundle

- [ ] Create a script `scripts/build-agent-bundle.sh` (or similar)
    - [ ] Assemble `_agent-bundle.yaml` from: `00-MANIFEST.yaml`, `00-RULES.yaml` (active rules only), `versions.yaml`, active decisions from unified log, component dependency map (from `component-registry.yaml`)
    - [ ] Ensure total token size under 10K

- [ ] Integrate script into GitHub Actions so the bundle is regenerated on every push to documentation

- [ ] Update `00-MANIFEST.yaml` to list `_agent-bundle.yaml` as `load: always` for AI agents

---

## 18. Global Cleanup

- [ ] Scan all files for references to old ADR index, old decision register, old rules, etc., and update to new locations
- [ ] Ensure no broken cross‑file links
- [ ] Update any CI checks that validate documentation (e.g., Schemathesis, drift detection) to use new file paths
- [ ] Perform a final token count of the minimal “Session Starter” set to verify <3K tokens
- [ ] Add a `CONTRIBUTING.md` (or update existing) explaining the new documentation architecture: where to put rules, how to record decisions, how to update the knowledge base

---

**Completion Criteria:**
- All checkboxes ticked.
- Generated `_agent-bundle.yaml` exists and loads successfully in an AI session.
- No duplicate information across major documents.
- Total token load for session start reduced by at least 50% from current baseline.