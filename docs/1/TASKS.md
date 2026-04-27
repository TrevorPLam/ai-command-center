# Task List for Information Optimization

The following tasks model the structure of the provided `TASKS.md`. They implement the refined recommendations, focusing on removing non‑essential information, stripping down verbose prose, and consolidating duplicates.

---

## Task List: Documentation Optimization & Leanification

**Goal**: Reduce token load, eliminate noise, and ensure every document earns its place in the development workflow.

### 1. Immediate Rule Amendments (Prerequisite)

- [x] Amend `00-RULES.yaml`  
  - [x] **AI‑04**: “Haiku 4.5 must never be used under any circumstances.”  
  - [x] **BE‑10**: Change severity to MEDIUM; reword to “PowerSync is the target primary offline sync mechanism. Phase 2 implements tombstone + outbox; Phase 4 delivers full bidirectional sync.”  
  - [x] **BE‑17**: Clarify scope as “tenant‑scoped application data; excludes identity/auth tables (`users`, `organizations`, `connected_accounts`).”  
  - [x] **COLL‑01**: Change “50 MB document limit” to “default 50 MB document limit, configurable via `Y_SWEET_MAX_BODY_SIZE`.”  
- [x] Update documents that referenced old wording  
  - [x] Remove Haiku from `60-AI-CORE.md` Intent Dispatcher and replace with Qwen 3.5 4B.  
  - [x] Adjust cascade in `21-PLAN-MILESTONES.md` Block 0B to remove Haiku.  
  - [x] Update any other file listing “Haiku 4.5” as an allowed model.

### 2. Delete Deprecated or Fully Superseded Files

- [x] Delete `22-PLAN-ADR-INDEX.md` (already marked DEPRECATED).  
- [x] Delete `40-COMP-REGISTRY.md` (superseded by `component-registry.yaml`).  
- [x] Delete `23-PLAN-QUESTIONS.md` (migrated to decision log).  
- [x] Delete original monolithic `70-TESTING.md` if still present.  
- [x] Delete auto‑generated renderings `00-RULES.md` and `100-FRONTEND-RULES.md` if your team can work directly with the YAML; otherwise mark them clearly as auto‑generated and add regeneration CI step.

### 3. Prune Non‑Essential Information

- [x] `10-STRAT-PRD.md`  
  - [x] Remove persona section (P1‑P5); keep only JTBD backlog and success metrics.  
  - [x] Move RICE and MoSCoW to an appendix; remove introductory prose that duplicates the simplified version.  
- [x] `11-STRAT-BLUEPRINT.md`  
  - [x] Delete the entire “Organization Analysis” paragraph referencing non‑existent archive document.  
  - [x] Remove duplicated text from PRD (vision, jobs, metrics, personas); replace with a single cross‑reference.  
- [x] `35-ARCH-SECURITY.md`  
  - [x] Remove the ~1750‑word Vanta/SOC2 narrative; replace with a one‑sentence pointer to `compliance-soc2.md` (to be created later).  
- [x] `60-AI-CORE.md`  
  - [x] Remove “Pre‑Computed Quality Presets” (G1‑G8); if needed, move to a model‑config file.  
  - [x] Remove the verbose “Golden dataset curation” essay; keep only the recommended sizes.  
- [x] `80-OPS-MANUAL.md`  
  - [x] Extract NIS2 compliance full‑text (2500 words) into `compliance/` directory; leave a short summary and link.  
- [x] `12-STRAT-HORIZON.md`  
  - [x] Move the technology horizon table to `36-ARCH-TECH-VALIDATION.md` as a new “Horizon” section; archive the original file.

### 4. Strip Down Verbose Sections Without Losing Meaning

- [x] `10-STRAT-PRD.md`  
  - [x] Condense “Success Metrics” table introduction to one sentence.  
- [x] `11-STRAT-BLUEPRINT.md`  
  - [x] Replace “Design Axiom: LLM‑First…” two‑paragraph prose with a one‑sentence axiom plus a “Why” bullet.  
  - [x] Replace six‑domain descriptions (each a paragraph) with a table: Domain, Purpose, Lead, Key Services.  
- [x] `30-ARCH-OVERVIEW.md`  
  - [x] Delete all full‑text rule listings; replace with “All architecture rules in `00-RULES.yaml`; key rules referenced: #BE‑01, #FE‑01, …”  
  - [x] Move detailed deployment patterns (Y‑Sweet, LiveKit) to `38-ARCH-DEPLOYMENT.md`.  
- [x] `60-AI-CORE.md`  
  - [x] Memory architecture section: turn into a table (Type, Storage, Eviction, Purpose).  
  - [x] Local model infrastructure: condense into tables for registry fields, hardware tiers, quantization policy.  
- [x] `70-TESTING‑STRATEGY.md`  
  - [x] Move LLM‑as‑judge bias mitigation details to `70‑TESTING‑BENCHMARKS.md`; keep a one‑paragraph summary.  
- [x] `80-OPS‑MANUAL.md` incident response playbooks  
  - [x] Convert each to a templated format: Trigger, Actions (numbered list), Escalation – no narrative.

### 5. Consolidate and Deduplicate

- [x] Pattern tags  
  - [x] Create `pattern-tags.yaml` with all tags and descriptions.  
  - [x] Replace tag definitions in `20-PLAN-INTRO.md` and `40-COMP-OVERVIEW.md` with a generated table from the YAML.  
- [x] Technology version pins  
  - [x] Ensure `versions.yaml` is the single source; strip the prose list from `51-XCT-DEPENDENCIES.md`.  
  - [x] Keep only rationale commentary in `51-XCT-DEPENDENCIES.md`, referencing `versions.yaml`.  
- [x] Security controls  
  - [x] Create `security-controls.yaml` (S1‑S12 with descriptions, mechanisms, threats).  
  - [x] In `35-ARCH-SECURITY.md`, replace the long control matrix with a summary table and link to YAML.  
- [x] ADR listings  
  - [x] Remove any duplicate ADR title listings from architecture overviews; the unified decision log (`01-PLAN-DECISIONS.md`) is canonical.  
- [x] Z‑index rules  
  - [x] Ensure rule #FE‑09 in `00-RULES.yaml` is the only place; delete repeating lines in component registry if present (retain only in rules).

### 6. Split Monolithic Files

- [x] `60-AI-CORE.md` →
  - [x] `ai-architecture.md` (intent dispatcher, verifier cascade, cost model)
  - [x] `ai-local-model-infra.md` (registry, quant, hardware tiers)
  - [x] `ai-guardrails.yaml` (3‑layer rules and thresholds)
  - [x] `ai-evaluation-gates.yaml` (CI gate parameters)
  - [x] `ai-workflow-engine.md` (LangGraph, LangMem, Trustcall)
  - [x] `model-cards.yaml`
- [x] `80-OPS-MANUAL.md` →
  - [x] `ops-incident.md` (runbooks in templated Markdown with front‑matter)
  - [x] `ops-team.md` (RACI, ownership)
  - [x] `compliance-nis2.md` (moved NIS2 content)
  - [x] Keep remaining sections (deployment strategy, performance monitoring) in a shorter `ops-infra.md`.

### 7. Convert Static Reference Data to YAML

- [x] `tech-validation.yaml`
  - [x] From `36-ARCH-TECH-VALIDATION.md` claims table (Technology, Claim, Status, Source).
  - [x] Add a short markdown intro; the YAML is the source.
- [x] `pattern-tags.yaml` (from step 5)
- [x] `security-controls.yaml` (from step 5)
- [x] `model-cards.yaml` (from step 6)
- [x] `zustand-slices.yaml`
  - [x] From `01-PLAN-ZUSTAND.md`; replace markdown table.

### 8. Add YAML Front‑Matter to All Core Documents

- [x] For every remaining Markdown file, add front‑matter with:  
  ```yaml
  ---
  title: "Document Title"
  owner: "Team or Role"
  status: "active|archived"
  updated: "2026-04-26"
  canonical: "link to YAML source if applicable"
  ---
  ```

### 9. Validation and CI

- [x] Set up CI to validate YAML files against JSON schemas (for `versions.yaml`, `component-registry.yaml`, `security-controls.yaml`, etc.).
- [x] Add a link-checker to ensure no broken cross-references.
- [x] Regenerate any derived documents (e.g., component overview table) from YAML on every push.

---

**Completion Criteria**:
- All checkboxes ticked.
- No non‑essential information remains in core development documents.
- Every piece of reference data has a single source of truth.
- Duplicate content between files eliminated.
- Total token load for “session starter” set reduced by at least 40%.

---

