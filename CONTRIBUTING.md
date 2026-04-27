# Contributing to Documentation

This document explains the new documentation architecture and how to work with it effectively.

## Documentation Architecture

The documentation is organized with a tiered loading protocol to minimize token usage for AI agents while maintaining comprehensive coverage.

### File Organization

```
docs/
├── 00-MANIFEST.yaml          # Single source of truth for all documentation files
├── _agent-bundle.yaml        # Auto-generated bundle for AI agents (load: always)
├── plan/
│   ├── 00-RULES.yaml        # Unified rules register (all HARD/MED rules)
│   ├── 00-RULES.md          # Human-readable rules (generated from YAML)
│   ├── 01-PLAN-DECISIONS.md # Unified decision log (ADRs, decisions, questions)
│   ├── 10-STRAT-PRD.md      # Product Requirements Document
│   ├── 11-STRAT-BLUEPRINT.md # Product blueprint and architecture framework
│   ├── 30-ARCH-OVERVIEW.md  # High-level C4 architecture
│   └── ...                   # Domain-specific documentation
├── 1/
│   ├── TASKS.md             # Documentation optimization task checklist
│   └── MD.md                # Markdown formatting guidelines
└── planning-docs/           # Additional planning documents
```

### Tiered Loading Protocol

AI agents follow a tiered loading protocol defined in `00-MANIFEST.yaml`:

**Session Starter (load: always)**
- Target: <3K tokens
- Loaded at session start
- Essential context: rules, decisions, product vision, architecture, current tasks

**Task-Specific (load: on-demand)**
- Loaded when working on specific domains
- Examples: frontend rules, database docs, API specs, security docs

**Deep Reference (load: never)**
- Loaded only when explicitly requested
- Examples: knowledge base, horizon scanning, tech validation

## How to Add Rules

1. **Add rule to `00-RULES.yaml`**
   - Assign a unique ID (e.g., `FE-01`, `BE-01`, `SEC-01`, `AI-01`)
   - Specify domain, severity (hard/medium), description, and check method
   - Follow the namespace convention: FE- (Frontend), BE- (Backend), SEC- (Security), AI- (AI Core), GOV- (Governance)

2. **Reference rules in documentation**
   - Use rule IDs instead of full text: `#FE-01`, `#SEC-11`
   - This reduces token usage and ensures single source of truth

3. **Regenerate human-readable docs**
   - Run the CI script to regenerate `00-RULES.md` from the YAML
   - The generated file is authoritative for human readers

## How to Record Decisions

All decisions, ADRs, and questions go into the unified decision log at `plan/01-PLAN-DECISIONS.md`.

### Decision Format

Use the append-only table format:

| ID | Date | Type | Domain | Decision | Rationale | Reversible? | Confidence | Status | Expiry | ADR_Ref | Linked Items | Session |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |

**Decision Types:**
- `process` - Process and workflow decisions
- `architecture` - System structure and technology choices
- `product` - Product features and UX decisions
- `question` - Open questions requiring resolution

**Status Values:**
- `active` - Currently in effect
- `superseded` - Replaced by a newer decision (add new row, mark old as superseded)
- `expired` - No longer applicable
- `open` - For questions only
- `deferred` - Decided to address later

**Rules:**
- Append only. Never edit existing rows.
- To change a decision, add a new row and mark the old one as `superseded`.
- ADR-worthy decisions (hard to reverse, system-impacting) should have a full ADR document.
- Simple decisions go directly in the register.

## How to Update Knowledge Base

The knowledge base is organized as atomic topic files in `plan/kb/`.

### Adding a Knowledge Topic

1. Create a new file in `plan/kb/` with a descriptive name (e.g., `kb/ai-models.md`)
2. Use the consistent structure:
   - TL;DR summary
   - Key Facts
   - Why it Matters
   - Sources
3. Update `plan/kb/_index.md` to list the new topic
4. Add any corrections to `plan/kb/_errata.md` instead of inline notes

## Markdown Guidelines

Follow the formatting guidelines in `docs/1/MD.md`:

- One H1 per document (title in sentence case)
- ATX headings only, never skip levels
- Exactly one blank line between block types
- Line length ≤100 characters
- Use spaces, never tabs
- No trailing spaces
- End files with single newline
- Prefer inline links over reference links
- Use fenced code blocks with language tags

## CI Automation

The documentation has CI automation to ensure consistency:

- **Agent Bundle Build** (`.github/workflows/agent-bundle.yml`)
  - Regenerates `_agent-bundle.yaml` on every documentation push
  - Validates token count is under 10K

- **Version Validation** (`.github/workflows/version-validation.yml`)
  - Validates `package.json` versions match `versions.yaml`

- **Rules Generation** (scripts)
  - `scripts/convert-rules-yaml-to-md.ps1` - Converts YAML to Markdown
  - `scripts/generate-frontend-rules.ps1` - Generates frontend-specific rules

## Common Tasks

### Updating a rule
1. Edit `plan/00-RULES.yaml`
2. Run the rules generation script
3. Update any documentation that references the old rule text to use the rule ID

### Recording a new decision
1. Add a row to the Active Decisions table in `plan/01-PLAN-DECISIONS.md`
2. If it's an ADR, create a full ADR document and reference it
3. If superseding an old decision, mark the old row as superseded

### Adding a new documentation file
1. Create the file in the appropriate directory
2. Add an entry to `00-MANIFEST.yaml` with:
   - `path`: Relative path from docs/
   - `type`: governance/architecture/plan/spec/reference
   - `summary`: One-sentence description
   - `load`: always/on-demand/never
   - `tags`: Relevant tags
   - `dependencies`: Files this depends on

### Checking for broken links
The manifest tracks dependencies. When moving or renaming files, update the manifest and search for references using grep:

```bash
grep -r "old-file-name.md" docs/
```

## Token Optimization

To minimize token usage for AI agents:

1. Use rule IDs instead of full rule text
2. Keep descriptions to ≤1 sentence where possible
3. Use concise tables over verbose prose
4. Apply inverted-pyramid structure: TL;DR first, details in appendices
5. Reference other docs instead of duplicating content

## Getting Help

For questions about documentation structure or process:
- Check `docs/1/TASKS.md` for ongoing optimization tasks
- Review `docs/1/MD.md` for formatting guidelines
- Examine existing files as examples of the expected format
