# TASKS.md — Markdown Documentation Safeguarding & Migration

> **Generated**: 2026-04-23  
> **Status**: All tasks pending  
> **Purpose**: Systematic migration of existing Markdown documentation to comply with block-aware editing guidelines from `read.md`, preventing structural damage during AI agent edits.  
> **IMPORTANT**: Before executing any task, work through its **verification placeholders** (see Key below). Every `[VERIFY: ...]` tag must be resolved first; otherwise the task is likely to fail or mis-target.

**[PROCESS]**: To resolve a `[VERIFY: …]`, open the file, run the described check, and record the outcome in a verification log (e.g., `VERIFICATION.md`). Only proceed when the condition is confirmed.

---

## 🔎 Placeholder Key

| Placeholder | Meaning |
|-------------|---------|
| `[VERIFY: <statement>]` | Claim must be confirmed against live code/specs before execution. |
| `[CHECK PATH: <path>]` | File or directory existence must be verified; update path if necessary. |
| `[CONFIRM ID: <id>]` | Task/component ID must exist in the canonical registry. |
| `[IMPLEMENT: <description>]` | Implementation details may need adjustment after the check; adapt accordingly. |
| `[UPDATE IF: <condition>]` | Action might be conditional; verify condition before proceeding. |

Each placeholder is **blocking** — do not proceed past it until resolved.

---

## 🔴 Phase 1: Audit & Backup (Foundation)

---

### TASK-MD-001: Create Git Checkpoint for Migration

**Status**: ✅ Complete  
**Priority**: 🔴 Critical  
**Parent Task ID**: TASK-MD-001

#### Subtasks

- [ ] **TASK-MD-001-01**: Create annotated Git tag `pre-markdown-migration` at current HEAD.  
  [VERIFY: Git repository is clean with no uncommitted changes; run `git status` to confirm] [IMPLEMENT: `git tag -a pre-markdown-migration -m "Pre-markdown migration checkpoint - preserves state before structural safeguarding"`]  
  **Target Files**: Git repository

- [ ] **TASK-MD-001-02**: Push tag to remote if remote exists.  
  [CHECK PATH: Remote origin configured via `git remote -v`] [UPDATE IF: no remote exists, skip this subtask]  
  **Target Files**: Git repository

#### Priority / Urgency

🔴 Critical. This is the rollback point. Without a clean checkpoint, any structural damage during migration cannot be easily reverted.

#### Research / Investigation

All subsequent tasks modify Markdown structure. A single corrupted edit could cascade through multiple files. The tag serves as an immutable restore point.  
[VERIFY: `git --version` is available and functional]

#### Related Files

- Entire project directory (all `*.md` files)
- `.git/` directory

#### Definition of Done

- `git tag -l | grep pre-markdown-migration` returns the tag name
- `git show pre-markdown-migration` displays the annotated tag with message
- Repository state is preserved

#### Acceptance Criteria

- Tag exists and points to current HEAD
- Tag message clearly indicates purpose
- Team members can run `git checkout pre-markdown-migration` to restore pre-migration state

#### Out of Scope

- Creating a branch (tags are sufficient for this checkpoint)
- Pushing changes to remote (only tag push)

#### Dependencies

None.

#### Estimated Effort

5 minutes

#### Testing Requirements

- Manual: Verify tag exists with `git tag -l`
- Manual: Inspect tag content with `git show pre-markdown-migration`

#### Validation Steps

1. Run `git status` - confirm working directory clean
2. Run `git tag -a pre-markdown-migration -m "Pre-markdown migration checkpoint"`
3. Run `git tag -l | grep pre-markdown` - confirm tag exists
4. Run `git show pre-markdown-migration` - verify annotation message

#### Strict Rules

- Do not proceed to Phase 2 until this tag is created
- Do not create additional commits between tagging and starting Phase 2

#### Existing Code Patterns

N/A - Git operation only

#### Advanced Code Patterns

N/A

#### Anti-Patterns

- Do NOT skip this step "just this once"
- Do NOT use lightweight tags (`git tag` without `-a`) - annotations preserve metadata

---

### TASK-MD-002: Audit Risk Patterns in All Markdown Files

**Status**: ✅ Complete  
**Priority**: 🔴 Critical  
**Parent Task ID**: TASK-MD-002

#### Subtasks

- [ ] **TASK-MD-002-01**: Scan all `*.md` files for reference-style link definitions.  
  [VERIFY: `grep -rnP '^\s*\[[^]]+\]:\s+' *.md` works on target OS; adapt for PowerShell if needed. This pattern excludes checkboxes, images, or other lines starting with `[` but not link definitions.] [IMPLEMENT: Create list of files with reference links and count per file]  
  **Target Files**: All `*.md` files in project root

- [ ] **TASK-MD-002-02**: Identify deeply nested structures (>2 levels: code in lists, tables in blockquotes, lists in tables).  
  [VERIFY: Files with complex nesting: `11-Chat.md`, `TODO.md`, `20-Projects.md`] [IMPLEMENT: Document each instance with file path and line number ranges]  
  **Target Files**: `11-Chat.md`, `TODO.md`, `20-Projects.md`, `21-Calendar.md`

- [ ] **TASK-MD-002-03**: List files exceeding 500 lines (context truncation risk).  
  [CHECK PATH: All `*.md` files at project root] [VERIFY: Line count thresholds - files >500 lines need attention, files >1000 lines need splitting] [IMPLEMENT: If a tokenizer is available (e.g., a helper script), report approximate token counts for files >500 lines. This helps refine split priorities beyond line-count proxies.]  
  **Target Files**: `11-Chat.md`, `TODO.md`, `20-Projects.md`, `31-Contacts.md`

- [ ] **TASK-MD-002-04**: Detect missing blank lines around code fences and lists (MD031/MD032 violations).  
  [VERIFY: `markdownlint` CLI available or can be installed via `npm install -g markdownlint-cli`] [IMPLEMENT: If markdownlint unavailable, manually scan for fences/lists without surrounding blank lines]  
  **Target Files**: All `*.md` files

- [ ] **TASK-MD-002-05**: Create `audit-report.md` with findings summary.  
  [CHECK PATH: Project root for write permissions] [IMPLEMENT: Categorize by risk level - High/Medium/Low]  
  **Target File**: `audit-report.md`

**Post-Migration Note**: After migration is complete, update `audit-report.md` with the final state (link counts zeroed, no lint violations, etc.), so it becomes a permanent record of the migration.

#### Priority / Urgency

🔴 Critical. This audit determines which files need which safeguards. Without this inventory, migration strategy cannot be properly targeted.

#### Research / Investigation

Based on initial file scan:
- `11-Chat.md`: ~2030 lines, 119KB - high risk for context truncation
- `TODO.md`: ~2030 lines, 91KB - high risk, active work file
- `20-Projects.md`: ~2030 lines, 95KB - high risk
- Reference links likely present in module cross-references
- `.windsurf/rules/*.md` files contain code fences that may collide with agent output

[VERIFY: Re-scan files at execution time to confirm line counts and sizes]

#### Related Files

- `00-Plan.md` (472 lines - medium)
- `01-Foundations.md` (323 lines - low)
- `10-Dashboard.md` (139 lines - low)
- `11-Chat.md` (2030+ lines - critical)
- `12-Workflow.md` (268 lines - low)
- `20-Projects.md` (2030+ lines - critical)
- `21-Calendar.md` (2030+ lines - critical)
- `22-Lists.md` (2030+ lines - critical)
- `23-SharedRecurrence.md` (231 lines - low)
- `30-Email.md` (477 lines - medium)
- `31-Contacts.md` (2030+ lines - critical)
- `32-Conference.md` (240 lines - low)
- `33-Translation.md` (434 lines - medium)
- `40-News.md` (592 lines - medium)
- `41-Documents.md` (442 lines - medium)
- `42-Research.md` (461 lines - medium)
- `43-Media.md` (692 lines - medium)
- `50-Budget.md` (430 lines - medium)
- `90-Settings.md` (258 lines - low)
- `99-Polish-Validation.md` (252 lines - low)
- `TODO.md` (2030+ lines - critical)
- `.windsurf/rules/*.md` (all rule files)

#### Definition of Done

- `audit-report.md` exists with:
  - List of files with reference-style links (count per file)
  - List of deeply nested structures (file, line range, nesting type)
  - List of files >500 lines with line counts
  - List of MD031/MD032 violations
  - Risk categorization (High/Medium/Low) for each file

#### Acceptance Criteria

- Audit report is readable and actionable
- Each finding includes file path and specific location
- Risk levels are justified based on read.md guidelines

#### Out of Scope

- Fixing any issues (that is Phase 2+)
- Installing markdownlint if not available (manual scan acceptable)

#### Dependencies

- TASK-MD-001 (Git checkpoint must exist first)

#### Estimated Effort

1 hour

#### Testing Requirements

- Manual: Verify audit report accuracy by spot-checking 3-5 files
- Manual: Confirm line counts with `wc -l` or editor

#### Validation Steps

1. Run `grep -r "\[.*\]\[.*\]" *.md` > `reference-links.txt`
2. Run `wc -l *.md` > `line-counts.txt`
3. If markdownlint available: `markdownlint *.md` > `lint-violations.txt`
4. Create `audit-report.md` synthesizing findings
5. Review report for completeness

#### Strict Rules

- Do not modify any files during audit
- Document exact line numbers where possible
- Flag any uncertainty in the report
- [STRICT]: After completing all tasks in this phase, create an annotated tag 'post-phase-1' to allow rollback without losing all progress.

#### Existing Code Patterns

N/A - Analysis only

#### Advanced Code Patterns

N/A

#### Anti-Patterns

- Do NOT skip files assuming they are "fine"
- Do NOT round line counts - exact numbers matter for context truncation assessment

---

## 🟠 Phase 2: Structural Safeguards (Per-File)

---

### TASK-MD-003: Add Sentinel Comments to Large Files

**Status**: ⬜ Not Started  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-MD-003

#### Subtasks

- [x] **TASK-MD-003-01**: Add `<!-- SECTION: <name> -->` and `<!-- ENDSECTION -->` comments to `11-Chat.md` at major section boundaries.  
  [x] **TASK-MD-003-01**: Add `<!-- SECTION: <name> -->` and `<!-- ENDSECTION -->` comments to `11-Chat.md` at major section boundaries.  
  [VERIFY: Major sections are at `## ` headings; identify 10-15 logical boundaries] [VERIFY: Scan file for existing `<!-- SECTION:` comments to avoid duplicates or conflicts. Rename or retire any legacy sentinel-like comments before adding new ones.] [IMPLEMENT: Insert sentinel comments with blank lines before/after]  
  **Target File**: `11-Chat.md`  
  **COMPLETED**: All 13 major sections now have sentinel comments properly placed with blank lines before/after, following the format `<!-- SECTION: <name> -->` and `<!-- ENDSECTION: <name> -->`. No sentinels placed inside code fences or on lines immediately before/after fences.

- [ ] **TASK-MD-003-02**: Add sentinel comments to `TODO.md` at phase boundaries.  
  [VERIFY: Phases marked with `## ` headings (Phase 1, Phase 2, etc.)] [IMPLEMENT: Use `<!-- PHASE: X - Name -->` format]  
  **Target File**: `TODO.md`

- [ ] **TASK-MD-003-03**: Add sentinel comments to `20-Projects.md` at major section boundaries.  
  [VERIFY: Sections align with component/task documentation] [IMPLEMENT: Use descriptive section names from headings]  
  **Target File**: `20-Projects.md`

- [ ] **TASK-MD-003-04**: Add sentinel comments to `21-Calendar.md` at major section boundaries.  
  [CHECK PATH: `21-Calendar.md`] [VERIFY: Section structure follows calendar component organization]  
  **Target File**: `21-Calendar.md`

- [ ] **TASK-MD-003-05**: Add sentinel comments to `31-Contacts.md` at major section boundaries.  
  [CHECK PATH: `31-Contacts.md`] [VERIFY: Section structure follows contacts module organization]  
  **Target File**: `31-Contacts.md`

- [ ] **TASK-MD-003-06**: Add sentinel comments to all `.windsurf/rules/*.md` files at section boundaries.  
  [CHECK PATH: `.windsurf/rules/` directory] [VERIFY: Each rule file has consistent structure with `<rule_name>` tags]  
  **Target Files**: `.windsurf/rules/*.md`

#### Priority / Urgency

🟠 High. Sentinel comments prevent context-truncation blindness by making section boundaries explicit. Without these, agents may edit lines without knowing they are part of larger blocks.

#### Research / Investigation

Per read.md guideline #7: "Use sentinel lines – placeholder comments like `<!-- SECTION END: foo -->` – to explicitly mark boundaries. Instruct the agent: 'Never modify or move these comment markers.'"

Sentinel format should be:
- Opening: `<!-- SECTION: <descriptive-name> -->`
- Closing: `<!-- ENDSECTION: <descriptive-name> -->`

Place at:
- Every `## ` heading (major section)
- Before and after large code blocks (>20 lines)
- Before and after complex tables

[VERIFY: Count of sections per file to estimate scope]

#### Related Files

- All files from audit report with >500 lines
- `.windsurf/rules/*.md` (22 files)

#### Definition of Done

- Every file >500 lines has sentinel comments at major sections
- Sentinels are consistent format across all files
- Each sentinel is surrounded by blank lines (MD031 compliance)
- Agents can be instructed to "never modify sentinel comments"

#### Acceptance Criteria

- `grep -r "<!-- SECTION:" *.md` returns results for all large files
- `grep -r "<!-- ENDSECTION:" *.md` returns matching results
- No sentinel appears mid-paragraph or inside code blocks

#### Out of Scope

- Adding sentinels to small files (<300 lines) - not needed
- Modifying content within sections

#### Dependencies

- TASK-MD-002 (audit report must identify which files need sentinels)

#### Estimated Effort

2 hours

#### Testing Requirements

- Manual: Spot-check 3 files to verify sentinels are correctly placed
- Manual: Verify no sentinels were added inside code fences

#### Validation Steps

1. Open `11-Chat.md`
2. Before each `## ` heading, add: `<!-- SECTION: <heading-name> -->`
3. After each section's content (before next `## ` or EOF), add: `<!-- ENDSECTION: <heading-name> -->`
4. Ensure blank line before and after each sentinel
5. Repeat for other large files
6. Run `grep -n "<!-- SECTION" <file>` to verify placement
7. Run `grep -n -E '(<!-- (SECTION|ENDSECTION):|```)' <file>` and manually check that no sentinel is directly above or below a code fence.

#### Strict Rules

- Never place sentinels inside code fences
- Never place a sentinel on the line immediately before or after a code fence
- Always use blank lines around sentinels
- Use consistent naming (match the section heading text)
- Do not modify section content, only add boundary markers
- [STRICT]: After completing all tasks in this phase, create an annotated tag 'post-phase-2' to allow rollback without losing all progress.

#### Existing Code Patterns

HTML comments already used in some files for metadata

#### Advanced Code Patterns

Sentinels can later be used by automated tools:
```bash
# Extract section by sentinel
grep -A 1000 "<!-- SECTION: Chat Interface -->" 11-Chat.md | \
grep -B 1000 "<!-- ENDSECTION: Chat Interface -->"
```

#### Anti-Patterns

- Do NOT use sentinels as headings replacement - they supplement, don't replace
- Do NOT nest sentinels (no SECTION inside SECTION)
- Do NOT use different formats across files - consistency enables automation

---

### TASK-MD-004: Convert Reference-Style Links to Inline

**Status**: ⬜ Not Started  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-MD-004

#### Subtasks

- [ ] **TASK-MD-004-01**: Identify all reference-style link definitions (`[ref]: url` format).  
  [VERIFY: Use `grep -n "^\[" *.md` to find link definitions at start of lines] [IMPLEMENT: Create mapping of ref → URL for each file]  
  **Target Files**: All `*.md` with reference links per audit

- [ ] **TASK-MD-004-02**: Replace `[text][ref]` with `[text](url)` inline format.  
  [VERIFY: Use the mapping from subtask 01] [IMPLEMENT: Block-aware replacement - replace entire link blocks, not single lines]  
  **Target Files**: Files identified in audit

- [ ] **TASK-MD-004-03**: Remove orphaned link definitions at end of files.  
  [VERIFY: After conversion, verify no `[ref]:` patterns remain] [IMPLEMENT: Delete definition lines]  
  **Target Files**: All converted files

- [ ] **TASK-MD-004-04**: Verify no broken links remain.  
  [VERIFY: Search for `[text][` pattern that would indicate unconverted references]  
  **Target Files**: All `*.md` files

#### Priority / Urgency

🟠 High. Per read.md guideline #6: "Prefer inline links (`[text](url)`) in files that an agent will edit often – they are self-contained." Reference links break when text and definitions get separated during edits.

#### Research / Investigation

Reference-style links appear in:
- Cross-document task references (`[TASK-001]: 00-Plan.md`)
- Footnote-style documentation
- Repeated URL references

Self-contained inline links are safer for agent editing because:
- Text and URL are co-located
- Moving text doesn't break the link
- No dependency on distant definitions

[VERIFY: Count of reference links per file from audit report]

#### Related Files

- Files with `[ref]:` patterns identified in audit
- Likely candidates: `TODO.md`, `00-Plan.md`, cross-reference heavy files

#### Definition of Done

- Zero reference-style link definitions (`[ref]: url` at start of line) remain
- All previously referenced links converted to inline format
- No broken links (text with `[text][ref]` but no matching definition)
- Grep command `grep -rnP '^\s*\[[^]]+\]:\s+' *.md` returns zero results (true link definitions only)

#### Acceptance Criteria

- `grep -rnP '^\s*\[[^]]+\]:\s+' *.md` returns zero results (no `[ref]:` patterns)
- `grep -r "\[.*\]\[.*\]" *.md` returns zero results (no `[text][ref]` usage)
- All converted links are functional (manual spot-check)

#### Out of Scope

- Validating URL destinations are reachable (only format conversion)
- Converting image references if they use reference style (separate task if needed)

#### Dependencies

- TASK-MD-002 (audit identifies which files have reference links)
- TASK-MD-003 (sentinels help isolate link blocks for safe replacement)

#### Estimated Effort

1.5 hours

#### Testing Requirements

- Manual: Spot-check 10 converted links to verify they render correctly
- Manual: Verify no `[ref]:` patterns remain in converted files

#### Validation Steps

1. For each file with reference links:
   a. Extract link definitions: `grep -n "^\[" <file>`
   b. Map each ref to its URL
   c. Replace `[text][ref]` with `[text](url)` throughout file
   d. Delete the `[ref]: url` definition lines
2. Run `grep -rnP '^\s*\[[^]]+\]:\s+' *.md` - should return nothing (true link definitions only)
3. Run `grep -r "\[.*\]\[.*\]" *.md` - should return nothing
4. Spot-check that no orphaned references remain by searching for `[text][ref]` where the `ref` was never a definition

#### Strict Rules

- Use block-aware replacement - provide entire link-containing block for regeneration
- Preserve link text exactly - do not change visible text, only URL placement
- Delete definition blocks only after all references converted

#### Existing Code Patterns

Some files use reference links for:
- Task ID cross-references
- Repeated external URLs
- Footnote-style citations

#### Advanced Code Patterns

N/A - conversion is mechanical

#### Anti-Patterns

- Do NOT leave orphaned definitions (definitions with no references)
- Do NOT change the visible link text during conversion
- Do NOT use automated find/replace without block context (risks partial matches)

---

### TASK-MD-005: Fix MD031/MD032 Whitespace Violations

**Status**: ⬜ Not Started  
**Priority**: 🟠 High  
**Parent Task ID**: TASK-MD-005

#### Subtasks

- [ ] **TASK-MD-005-01**: Identify all code fences without surrounding blank lines (MD031).  
  [VERIFY: `markdownlint --rules MD031 *.md` if available; else manual scan for lines before/after fences] [IMPLEMENT: Document each violation with file and line number]  
  **Target Files**: All `*.md` files

- [ ] **TASK-MD-005-02**: Identify all lists without surrounding blank lines (MD032).  
  [VERIFY: `markdownlint --rules MD032 *.md` if available] [IMPLEMENT: Document each violation]  
  **Target Files**: All `*.md` files

- [ ] **TASK-MD-005-03**: Add blank lines before code fences where missing.  
  [VERIFY: Fence starts with ` ``` ` or `~~~` at start of line] [IMPLEMENT: Insert blank line before fence if previous line is not blank]  
  **Target Files**: Files with MD031 violations

- [ ] **TASK-MD-005-04**: Add blank lines after code fences where missing.  
  [VERIFY: Line after closing fence should be blank] [IMPLEMENT: Insert blank line after fence if next line is content (not another fence)]  
  **Target Files**: Files with MD031 violations

- [ ] **TASK-MD-005-05**: Add blank lines around lists where missing (MD032).  
  [VERIFY: List starts with `- `, `* `, `1. `, etc.] [IMPLEMENT: Blank line before first item and after last item]  
  **Target Files**: Files with MD032 violations

#### Priority / Urgency

🟠 High. Per read.md guideline #3: "Deleting or inserting a single blank line can merge separate blocks (headings become paragraphs, two lists become one)." Whitespace violations make files fragile to agent edits.

#### Research / Investigation

MD031: Fenced code blocks should be surrounded by blank lines  
MD032: Lists should be surrounded by blank lines

Violations common in:
- Task lists (checkboxes immediately after headings)
- Code examples immediately after paragraphs
- Adjacent lists that should be separate
- Nested content where blank lines were omitted for compactness

[VERIFY: Count violations per file from audit report]

#### Related Files

- All `*.md` files, especially:
- `TODO.md` (task lists everywhere)
- `11-Chat.md` (code examples)
- `20-Projects.md` (task lists)

#### Definition of Done

- Zero MD031 violations (fenced code blocks surrounded by blank lines)
- Zero MD032 violations (lists surrounded by blank lines)
- `markdownlint *.md` returns clean (if available)

#### Acceptance Criteria

- Every opening code fence has blank line before it (unless first line in file)
- Every closing code fence has blank line after it (unless last line in file)
- Every list has blank line before first item
- Every list has blank line after last item (unless immediately followed by fence)

#### Out of Scope

- Fixing other markdownlint rules (focus on MD031/MD032 only)
- Installing markdownlint CLI (optional tool)

#### Dependencies

- TASK-MD-002 (audit identifies violations)

#### Estimated Effort

1.5 hours

#### Testing Requirements

- Manual: Run `markdownlint --rules MD031,MD032 *.md` if available
- Manual: Spot-check 5 files for visual verification

#### Validation Steps

1. For MD031:
   a. Find: `^```\w*$` or `^~~~\w*$` (opening fences)
   b. Check: Previous line must be blank or file start
   c. Find: Closing fences `^```$` or `^~~~$`
   d. Check: Next line must be blank or EOF
2. For MD032:
   a. Find: `^\s*[-*+]\s` or `^\s*\d+\.\s` (list items)
   b. Check: Line before first item must be blank or heading or fence
   c. Check: Line after last item must be blank
3. Apply fixes as block replacements

#### Strict Rules

- Do not add blank lines inside code blocks (between fences)
- Do not add blank lines between list items (only before first and after last)
- Preserve content - only insert blank lines, never delete
- [STRICT]: After completing all tasks in this phase, create an annotated tag 'post-phase-3' to allow rollback without losing all progress.

#### Existing Code Patterns

Many files have compact formatting without blank lines for visual density

#### Advanced Code Patterns

N/A - mechanical fix

#### Anti-Patterns

- Do NOT add blank lines inside fenced code blocks (breaks code content)
- Do NOT add blank lines between adjacent list items
- Do NOT remove content while "fixing" whitespace

---

### TASK-MD-005A: Pilot Safeguard Test (Critical)

**Status**: ⬜ Not Started  
**Priority**: � Critical  
**Parent Task ID**: TASK-MD-005A

#### Subtasks

- [ ] **TASK-MD-005A-01**: Select pilot file `40-News.md` (medium size, no critical content).  
  [VERIFY: File is manageable and low-risk for testing]  
  **Target File**: `40-News.md`

- [ ] **TASK-MD-005A-02**: Apply sentinels, inline links, and whitespace fixes to pilot file.  
  [IMPLEMENT: Execute TASK-MD-003, TASK-MD-004, TASK-MD-005 patterns on single file]  
  **Target File**: `40-News.md`

- [ ] **TASK-MD-005A-03**: Run validation script and manual review on pilot.  
  [VERIFY: All safeguards applied correctly]  
  **Target File**: `40-News.md`

- [ ] **TASK-MD-005A-04**: Get team sign-off before continuing with large files.  
  [VERIFY: Pilot test validates the entire safeguard pipeline]  
  **Target**: Team approval

#### Priority / Urgency

🔴 Critical. This is the single most important add-on to the plan. Validates the entire safeguard pipeline on a low-risk file before touching large files.

#### Definition of Done

- Pilot file processed with all three safeguards
- Validation script passes
- Team sign-off obtained
- Lessons learned documented

#### Dependencies

- TASK-MD-002 (audit identifies pilot candidate)

#### Estimated Effort

45 minutes

---

## �🟡 Phase 3: File Splitting (Target: >50KB Files)

---

### TASK-MD-006: Split 11-Chat.md into Logical Sections

**Status**: ⬜ Not Started  
**Priority**: 🟡 Medium  
**Parent Task ID**: TASK-MD-006

#### Subtasks

- [ ] **TASK-MD-006-00**: Commit a backup copy of the original file as `11-Chat.md.bak` before any content modifications.  
  [VERIFY: Backup created for quick side-by-side recovery]  
  **Target File**: `11-Chat.md`

- [ ] **TASK-MD-006-01**: Analyze `11-Chat.md` structure and identify logical split points.  
  [VERIFY: Major sections at `## ` level; identify natural boundaries (Overview, Components, Integration, API)] [VERIFY: The split point falls on a `## ` heading or at a clear logical boundary, not inside a fenced block or nested structure.] [IMPLEMENT: Document split plan with section ranges]  
  **Target File**: `11-Chat.md`

- [ ] **TASK-MD-006-02**: Create `11-Chat-Overview.md` with header, introduction, and architecture.  
  [VERIFY: Sentinel comments from TASK-MD-003 mark section boundaries] [IMPLEMENT: Copy content up to first major component section]  
  **Target File**: `11-Chat-Overview.md` (new)

- [ ] **TASK-MD-006-03**: Create `11-Chat-Components.md` with all component specifications.  
  [VERIFY: Components section spans multiple subsections] [IMPLEMENT: Copy from COMPONENTS heading to INTEGRATION heading]  
  **Target File**: `11-Chat-Components.md` (new)

- [ ] **TASK-MD-006-04**: Create `11-Chat-Integration.md` with API, state management, and integration details.  
  [VERIFY: Remaining content after component section] [IMPLEMENT: Copy from INTEGRATION heading to EOF]  
  **Target File**: `11-Chat-Integration.md` (new)

- [ ] **TASK-MD-006-05**: Update `11-Chat.md` to become index/overview with links to split files.  
  [VERIFY: Original file must be preserved for git history, but content replaced] [IMPLEMENT: Add deprecation notice and links to new files]  
  **Target File**: `11-Chat.md` (modified)

- [ ] **TASK-MD-006-06**: Add cross-references between split files.  
  [IMPLEMENT: At end of each file, add "Next: [File Name](file.md)" or "See Also" section]  
  **Target Files**: All new `11-Chat-*.md` files

- [ ] **TASK-MD-006-07**: Update all cross-document references to the old file that targeted specific sections.  
  [VERIFY: A link `[Chat Overview](11-Chat.md#component)` must be changed to `[Chat Overview](11-Chat-Components.md)`. Use the audit report to locate affected links.]  
  **Target Files**: All `*.md` files with links to `11-Chat.md` sections

#### Priority / Urgency

🟡 Medium. Per read.md guideline #7: "Split long Markdown into separate files with a clear naming convention... so that each file is under ~500 lines." 11-Chat.md at ~2000 lines is at high risk for context truncation.

#### Research / Investigation

11-Chat.md (~119KB, 2030 lines) contains:
- Header and overview
- ChatInterface component
- MessageBubble component
- ToolCallDisclosure component
- CheckpointBanner component
- ChatInput component
- ThreadList component
- Integration patterns
- API specifications

Proposed split:
1. `11-Chat-Overview.md` (~300 lines): Header, architecture, cross-cutting concerns
2. `11-Chat-Components.md` (~1200 lines): All component specifications
3. `11-Chat-Integration.md` (~500 lines): API, state management, integration

[VERIFY: Re-examine file at execution to confirm structure and line counts]

#### Related Files

- `11-Chat.md` (source, to be split)
- `11-Chat-Overview.md` (new)
- `11-Chat-Components.md` (new)
- `11-Chat-Integration.md` (new)

#### Definition of Done

- Three new files created with content from `11-Chat.md`
- Each new file <600 lines
- Original `11-Chat.md` contains index with links
- Cross-references between files
- All content preserved (no information loss)

#### Acceptance Criteria

- `wc -l 11-Chat-*.md` shows all files <600 lines
- `cat 11-Chat-Overview.md 11-Chat-Components.md 11-Chat-Integration.md | wc -l` ≈ original line count
- Original `11-Chat.md` has working links to new files
- No content lost in split (compare total lines)

#### Out of Scope

- Content editing during split (preserve exactly, edit later if needed)
- Renumbering tasks (separate task)

#### Dependencies

- TASK-MD-003 (sentinels identify split boundaries)
- TASK-MD-004 (inline links prevent broken references during split)
- TASK-MD-005 (whitespace fixed for clean boundaries)

#### Estimated Effort

2 hours

#### Testing Requirements

- Manual: Verify all new files render correctly in Markdown preview
- Manual: Click links in index file to verify they work
- Manual: Line count verification

#### Validation Steps

1. Create new files:
   - `11-Chat-Overview.md` with header content
   - `11-Chat-Components.md` with component specs
   - `11-Chat-Integration.md` with integration specs
2. Replace `11-Chat.md` content with index page:
   - Header preserved
   - Notice: "This file has been split. See:"
   - Links to 3 new files with descriptions
3. Add cross-references:
   - Each file ends with "See Also" section
   - Links to related split files
4. Verify: `wc -l` on all files
5. Commit as single commit with message "refactor(docs): Split 11-Chat.md into 3 files"

#### Strict Rules

- Preserve exact content during split - do not edit while splitting
- Use consistent naming: `11-Chat-<Section>.md`
- Maintain sequential numbering (11- prefix)
- Never delete original file - convert to index
- [STRICT]: After completing all tasks in this phase, create an annotated tag 'post-phase-4' to allow rollback without losing all progress.

#### Existing Code Patterns

File naming convention: `##-Module.md` or `##-Module-Subsection.md`

#### Advanced Code Patterns

Index file pattern:
```markdown
# 11-Chat.md (Split)

> **Note**: This file has been split for easier maintenance.
> The content is now distributed across:

- [Overview](11-Chat-Overview.md) - Architecture and introduction
- [Components](11-Chat-Components.md) - All component specifications
- [Integration](11-Chat-Integration.md) - API and integration patterns
```

#### Anti-Patterns

- Do NOT delete original `11-Chat.md` (breaks git history and external links)
- Do NOT split mid-section (always at heading boundaries)
- Do NOT split into >5 files (creates fragmentation)

---

### TASK-MD-007: Split TODO.md by Phase/Status

**Status**: ⬜ Not Started  
**Priority**: 🟡 Medium  
**Parent Task ID**: TASK-MD-007

#### Subtasks

- [ ] **TASK-MD-007-00**: Commit a backup copy of the original file as `TODO.md.bak` before any content modifications.  
  **Target File**: `TODO.md`

- [ ] **TASK-MD-007-01**: Analyze `TODO.md` structure - identify phases and logical splits.  
  [VERIFY: Phases: Critical Cross-Document, Core Feature Work, Non-Core, Polish/Validation] [VERIFY: The split point falls on a `## ` heading or at a clear logical boundary, not inside a fenced block or nested structure.] [IMPLEMENT: Document split boundaries]  
  **Target File**: `TODO.md`

- [ ] **TASK-MD-007-02**: Create `TODO-Critical.md` with Phase 1 tasks (cross-document corrections).  
  [VERIFY: Phase 1 boundary marked by sentinel from TASK-MD-003] [IMPLEMENT: Copy Phase 1 content]  
  **Target File**: `TODO-Critical.md` (new)

- [ ] **TASK-MD-007-03**: Create `TODO-Core.md` with Phase 2 tasks (core feature work).  
  [VERIFY: Phase 2 contains majority of tasks] [IMPLEMENT: Copy Phase 2 content]  
  **Target File**: `TODO-Core.md` (new)

- [ ] **TASK-MD-007-04**: Create `TODO-Remaining.md` with Phases 3-5 (non-core and polish).  
  [VERIFY: Phases 3, 4, 5 boundaries] [IMPLEMENT: Copy remaining content]  
  **Target File**: `TODO-Remaining.md` (new)

- [ ] **TASK-MD-007-05**: Update `TODO.md` to become task index with status overview.  
  [IMPLEMENT: Dashboard-style index showing counts per file, quick links]  
  **Target File**: `TODO.md` (modified)

- [ ] **TASK-MD-007-06**: Update all cross-document references to the old file that targeted specific sections.  
  [VERIFY: Links like `[TODO Item](TODO.md#section)` must be updated to point to correct split file. Use the audit report to locate affected links.]  
  **Target Files**: All `*.md` files with links to `TODO.md` sections

#### Priority / Urgency

🟡 Medium. TODO.md is actively edited and at ~91KB/2030 lines risks context truncation. Splitting by phase separates critical work from backlog.

#### Research / Investigation

TODO.md structure:
- Phase 1: Critical Cross-Document Corrections (TASK-001 to TASK-00X)
- Phase 2: Core Feature Work (DASH-XXX, CHAT-XXX, etc.)
- Phase 3: Non-Core Enhancements
- Phase 4: Polish/Validation

Proposed split:
1. `TODO-Critical.md` (~400 lines): Phase 1 tasks
2. `TODO-Core.md` (~1000 lines): Phase 2 tasks
3. `TODO-Remaining.md` (~600 lines): Phases 3-5

[VERIFY: Re-examine file at execution to confirm phase boundaries]

#### Related Files

- `TODO.md` (source)
- `TODO-Critical.md` (new)
- `TODO-Core.md` (new)
- `TODO-Remaining.md` (new)

#### Definition of Done

- Three new files created with content from `TODO.md`
- Each new file <600 lines
- Original `TODO.md` contains task dashboard with links
- All task IDs preserved
- Cross-references between files

#### Acceptance Criteria

- `wc -l TODO-*.md` shows all files <600 lines
- All task IDs from original are present in split files
- `TODO.md` index has working links
- No tasks lost in split

#### Out of Scope

- Changing task status during split
- Renumbering or reorganizing tasks

#### Dependencies

- TASK-MD-003 (sentinels mark phase boundaries)
- TASK-MD-004 (inline links)
- TASK-MD-005 (whitespace compliance)

#### Estimated Effort

1.5 hours

#### Testing Requirements

- Manual: Verify task counts match before/after
- Manual: Verify all links work
- Manual: Spot-check task content preserved

#### Validation Steps

1. Identify phase boundaries using sentinels
2. Create `TODO-Critical.md` with Phase 1
3. Create `TODO-Core.md` with Phase 2
4. Create `TODO-Remaining.md` with Phases 3-5
5. Convert `TODO.md` to dashboard index
6. Add cross-references
7. Verify line counts and content preservation

#### Strict Rules

- Preserve task IDs exactly
- Preserve task content exactly
- Do not change status during split
- Never delete original TODO.md

#### Existing Code Patterns

Phase naming: "Phase X: Description"

#### Advanced Code Patterns

Index dashboard pattern:
```markdown
# TODO Dashboard

| File | Tasks | Status |
|------|-------|--------|
| [Critical](TODO-Critical.md) | 12 | 🔄 In Progress |
| [Core](TODO-Core.md) | 45 | ⬜ Not Started |
```

#### Anti-Patterns

- Do NOT split individual tasks across files
- Do NOT mix phases in split files
- Do NOT delete original TODO.md

---

### TASK-MD-008: Split 20-Projects.md by Concern

**Status**: ⬜ Not Started  
**Priority**: 🟡 Medium  
**Parent Task ID**: TASK-MD-008

#### Subtasks

- [ ] **TASK-MD-008-00**: Commit a backup copy of the original file as `20-Projects.md.bak` before any content modifications.  
  **Target File**: `20-Projects.md`

- [ ] **TASK-MD-008-01**: Analyze `20-Projects.md` and identify logical splits.  
  [VERIFY: Sections likely include: Overview, Page Specs, Views, TaskDetail] [VERIFY: The split point falls on a `## ` heading or at a clear logical boundary, not inside a fenced block or nested structure.] [IMPLEMENT: Document split plan]  
  **Target File**: `20-Projects.md`

- [ ] **TASK-MD-008-02**: Create `20-Projects-Overview.md` with header and architecture.  
  [IMPLEMENT: Copy header through first major section]  
  **Target File**: `20-Projects-Overview.md` (new)

- [ ] **TASK-MD-008-03**: Create `20-Projects-Views.md` with List, Kanban, Timeline, My Week, Workload views.  
  [VERIFY: Views section is substantial] [IMPLEMENT: Copy views section]  
  **Target File**: `20-Projects-Views.md` (new)

- [ ] **TASK-MD-008-04**: Create `20-Projects-TaskDetail.md` with TaskDetailDrawer specs.  
  [VERIFY: TaskDetail is major component] [IMPLEMENT: Copy TaskDetail section]  
  **Target File**: `20-Projects-TaskDetail.md` (new)

- [ ] **TASK-MD-008-05**: Update `20-Projects.md` as index with cross-references.  
  [IMPLEMENT: Create index page]  
  **Target File**: `20-Projects.md` (modified)

- [ ] **TASK-MD-008-06**: Update all cross-document references to the old file that targeted specific sections.  
  [VERIFY: Links to `20-Projects.md` sections must be updated to point to correct split file. Use the audit report to locate affected links.]  
  **Target Files**: All `*.md` files with links to `20-Projects.md` sections

#### Priority / Urgency

🟡 Medium. 20-Projects.md at ~95KB is high risk. Splitting by concern (overview/views/task detail) matches how the documentation is used.

#### Research / Investigation

20-Projects.md likely contains:
- Project module overview
- ProjectsPage specifications
- View specifications (List, Kanban, Timeline, My Week, Workload)
- TaskDetailDrawer specifications
- Template library

[VERIFY: Actual structure at execution time]

#### Related Files

- `20-Projects.md` (source)
- `20-Projects-Overview.md` (new)
- `20-Projects-Views.md` (new)
- `20-Projects-TaskDetail.md` (new)

#### Definition of Done

- Three new files created
- Each <600 lines
- Original preserved as index
- Cross-references present

#### Acceptance Criteria

- Line counts verified
- All content preserved
- Links functional

#### Out of Scope

Content changes during split

#### Dependencies

- TASK-MD-003, TASK-MD-004, TASK-MD-005

#### Estimated Effort

1.5 hours

#### Testing Requirements

- Manual verification of content and links

#### Validation Steps

1. Identify split points
2. Create new files
3. Convert original to index
4. Verify

#### Strict Rules

- Preserve content exactly
- Never delete original
- Split at headings only

#### Existing Code Patterns

Same naming convention as 11-Chat split

#### Advanced Code Patterns

N/A

#### Anti-Patterns

N/A

---

### TASK-MD-009: Split 21-Calendar.md, 22-Lists.md, 31-Contacts.md

**Status**: ⬜ Not Started  
**Priority**: 🟢 Low  
**Parent Task ID**: TASK-MD-009

#### Subtasks

- [ ] **TASK-MD-009-00**: Commit backup copies of all original files (`21-Calendar.md.bak`, `22-Lists.md.bak`, `31-Contacts.md.bak`) before any content modifications.  
  **Target Files**: Original files

- [ ] **TASK-MD-009-01**: Split `21-Calendar.md` into `21-Calendar-Overview.md`, `21-Calendar-Components.md`.  
  [VERIFY: The split point falls on a `## ` heading or at a clear logical boundary, not inside a fenced block or nested structure.]  
  **Target Files**: New split files

- [ ] **TASK-MD-009-02**: Split `22-Lists.md` into logical sections.  
  [VERIFY: The split point falls on a `## ` heading or at a clear logical boundary, not inside a fenced block or nested structure.]  
  **Target Files**: New split files

- [ ] **TASK-MD-009-03**: Split `31-Contacts.md` into logical sections.  
  [VERIFY: The split point falls on a `## ` heading or at a clear logical boundary, not inside a fenced block or nested structure.]  
  **Target Files**: New split files

- [ ] **TASK-MD-009-04**: Create index files for each original.  
  **Target Files**: Modified originals

- [ ] **TASK-MD-009-05**: Update all cross-document references to the old files that targeted specific sections.  
  [VERIFY: Links to sections in `21-Calendar.md`, `22-Lists.md`, `31-Contacts.md` must be updated to point to correct split files. Use the audit report to locate affected links.]  
  **Target Files**: All `*.md` files with links to these sections

#### Priority / Urgency

🟢 Low. These files are large but lower priority than Chat, TODO, and Projects. Defer until high-priority splits complete.

#### Research / Investigation

Each file >50KB needs splitting per read.md guidelines. Structure analysis needed at execution time.

#### Related Files

- `21-Calendar.md`, `22-Lists.md`, `31-Contacts.md`

#### Definition of Done

- Each large file split into 2-3 files <600 lines each
- Originals converted to index pages

#### Acceptance Criteria

- Line count targets met
- Content preserved
- Links functional

#### Out of Scope

N/A

#### Dependencies

- Completion of TASK-MD-006, TASK-MD-007, TASK-MD-008 (learn from those first)

#### Estimated Effort

3 hours (for all three)

#### Testing Requirements

Manual verification

#### Validation Steps

Same pattern as previous split tasks

#### Strict Rules

Same as previous split tasks

#### Existing Code Patterns

N/A

#### Advanced Code Patterns

N/A

#### Anti-Patterns

N/A

---

## 🟢 Phase 4: Tooling & Automation

---

### TASK-MD-010: Add .markdownlint.json Configuration

**Status**: ⬜ Not Started  
**Priority**: 🟢 Low  
**Parent Task ID**: TASK-MD-010

#### Subtasks

- [ ] **TASK-MD-010-01**: Create `.markdownlint.json` with MD031/MD032 enabled.  
  [VERIFY: markdownlint config format] [IMPLEMENT: JSON config file]  
  **Target File**: `.markdownlint.json`

- [ ] **TASK-MD-010-02**: Add rules for code fence style consistency.  
  [IMPLEMENT: Enforce triple backticks consistently]  
  **Target File**: `.markdownlint.json`

- [ ] **TASK-MD-010-03**: Document how to run linter in README or docs.  
  **Target File**: `README.md` or `docs/`

#### Priority / Urgency

🟢 Low. Per read.md guideline #8: "Run a Markdown linter automatically after any AI-generated edit." Having the config enables CI integration.

#### Research / Investigation

markdownlint rules relevant to this project:
- MD031: Fenced code blocks should be surrounded by blank lines
- MD032: Lists should be surrounded by blank lines
- MD040: Fenced code blocks should have a language specified
- MD014: Dollar signs used before commands without showing output

[VERIFY: Full rule list at execution time]

#### Related Files

- `.markdownlint.json` (new)
- All `*.md` files

#### Definition of Done

- `.markdownlint.json` exists in project root
- Config enforces MD031, MD032
- Documentation exists for running linter

#### Acceptance Criteria

- Config file valid JSON
- `markdownlint *.md` uses this config
- CI can run linter with this config

#### Out of Scope

- Fixing all existing violations (done in Phase 2)
- CI pipeline setup (separate task)

#### Dependencies

- TASK-MD-005 (whitespace fixes done first so linting passes)

#### Estimated Effort

30 minutes

#### Testing Requirements

- Manual: Run `markdownlint *.md` to verify config works

#### Validation Steps

1. Create `.markdownlint.json`:
```json
{
  "default": true,
  "MD031": true,
  "MD032": true,
  "MD013": false
}
```
2. Test: `markdownlint *.md`
3. Run `markdownlint -c .markdownlint.json *.md` and confirm no config-parsing errors appear
4. Document in README

#### Strict Rules

- Keep config minimal - only enforce critical rules
- Don't enable rules that would flag intentional formatting

#### Existing Code Patterns

N/A

#### Advanced Code Patterns

N/A

#### Anti-Patterns

- Don't enable all rules (too noisy)
- Don't disable rules we just fixed

---

### TASK-MD-011: Create Validation Script for Fence Symmetry

**Status**: ⬜ Not Started  
**Priority**: 🟢 Low  
**Parent Task ID**: TASK-MD-011

#### Subtasks

- [ ] **TASK-MD-011-01**: Create validation script that checks fence pairing.  
  [VERIFY: All opening fences have closing fences] [IMPLEMENT: Provide either a Node.js script using only built-in modules (fs, path) OR a shell script (validate-markdown.sh) as a fallback. List both options in the task documentation.]  
  **Target File**: `scripts/validate-markdown.js`

- [ ] **TASK-MD-011-02**: Add check for sentinel comment integrity.  
  [VERIFY: Every `<!-- SECTION:` has matching `<!-- ENDSECTION:`]  
  **Additional Check**: Flag sentinels directly before/after a fence as a warning (indicates potential misplacement).  
  **Target File**: `scripts/validate-markdown.js`

- [ ] **TASK-MD-011-03**: Add check for reference link orphans.  
  [VERIFY: No `[ref]:` definitions without `[text][ref]` usage]  
  **Target File**: `scripts/validate-markdown.js`

- [ ] **TASK-MD-011-04**: Integrate with package.json scripts if exists.  
  [CHECK PATH: `package.json` exists] [UPDATE IF: exists, add `validate:md` script]  
  **Target File**: `package.json` (if exists)

#### Priority / Urgency

🟢 Low. Automated validation catches structural damage before it propagates.

#### Research / Investigation

Validation checks:
1. Fence symmetry: Opening ``` must have closing ```
2. Sentinel integrity: SECTION markers paired with ENDSECTION
3. Link integrity: No orphaned reference definitions

Script can be run:
- Manually before commits
- In CI on PRs
- After any AI agent edit session

[VERIFY: Node.js available; if not, use shell script alternative]

#### Related Files

- `scripts/validate-markdown.js` (new)
- All `*.md` files

#### Definition of Done

- Script exists and is executable
- Script catches fence mismatches
- Script catches unpaired sentinels
- Script catches orphaned references
- Script exits with error code on violations

#### Acceptance Criteria

- `node scripts/validate-markdown.js` runs without errors on clean files
- Script detects intentionally introduced fence mismatch
- Script output is clear and actionable

#### Out of Scope

- Auto-fixing violations (validation only)
- Pre-commit hook setup (separate task)

#### Dependencies

- TASK-MD-003 (sentinels must exist to validate)
- TASK-MD-004 (reference links should be converted first)

#### Estimated Effort

1 hour

#### Testing Requirements

- Manual: Test with good file (passes)
- Manual: Test with bad file (fails with clear error)

#### Validation Steps

1. Create script with three validation functions
2. Test on current files
3. Verify error reporting
4. Document usage

#### Strict Rules

- Script must exit non-zero on violations (CI-friendly)
- Error messages must include file path and line number
- Don't modify files, only report

#### Existing Code Patterns

N/A

#### Advanced Code Patterns

Script structure:
```javascript
const fs = require('fs');
const glob = require('glob');

function validateFences(content, file) {
  // Count opening and closing fences
  // Return errors array
}

function validateSentinels(content, file) {
  // Check SECTION/ENDSECTION pairing
}

function validateReferences(content, file) {
  // Check for orphaned [ref]: definitions
}

// Main: glob all *.md, run validators, report, exit with count
```

#### Anti-Patterns

- Don't use regex for complex parsing (use line-by-line for fences)
- Don't validate content semantics (only structure)

---

### TASK-MD-012: Add Windsurf Rule for Markdown Editing

**Status**: ⬜ Not Started  
**Priority**: 🟢 Low  
**Parent Task ID**: TASK-MD-012

#### Subtasks

- [ ] **TASK-MD-012-01**: Create `.windsurf/rules/markdown-editing.md` with guidelines.  
  [VERIFY: Other rule files use `<rule_name>` tag format] [IMPLEMENT: Follow existing rule structure]  
  **Target File**: `.windsurf/rules/markdown-editing.md`

- [ ] **TASK-MD-012-02**: Include block-aware replacement instruction.  
  [IMPLEMENT: "Replace entire blocks, not single lines. Provide 3-line context anchors."]  
  **Target File**: `.windsurf/rules/markdown-editing.md`

- [ ] **TASK-MD-012-03**: Include sentinel preservation instruction.  
  [IMPLEMENT: "Never modify or move `<!-- SECTION:` or `<!-- ENDSECTION:` comment markers."]  
  **Target File**: `.windsurf/rules/markdown-editing.md`

- [ ] **TASK-MD-012-04**: Include fence and whitespace guidelines.  
  [IMPLEMENT: Rules from read.md summarized for agent context]  
  **Target File**: `.windsurf/rules/markdown-editing.md`

#### Priority / Urgency

🟢 Low. Adding a Windsurf rule ensures agents editing these files have the guidelines in context.

#### Research / Investigation

Existing rule files use format:
```markdown
<rule_name>
Rule content with guidelines...
</rule_name>
```

Content should summarize:
- read.md guideline #1: Block-aware, not line-aware
- read.md guideline #2: Use 3-line context anchors
- read.md guideline #3: Guard whitespace
- read.md guideline #4: Fence collision avoidance
- read.md guideline #7: Respect sentinels

[VERIFY: Check existing rule file structure in `.windsurf/rules/`]

#### Related Files

- `.windsurf/rules/markdown-editing.md` (new)
- `.windsurf/rules/*.md` (existing patterns to follow)
- `read.md` (source guidelines)

#### Definition of Done

- Rule file exists in `.windsurf/rules/`
- Rule follows existing format
- Rule covers all critical guidelines from read.md
- Rule is concise (agents have limited context)

#### Acceptance Criteria

- Rule file parses correctly (no markdown errors)
- Rule is discoverable by Windsurf
- Rule content is actionable
- Confirm in the Windsurf UI (or via `windsurf rules list`) that the `markdown_editing` rule is active and loaded correctly

#### Out of Scope

- Other rule modifications
- Skill modifications

#### Dependencies

- TASK-MD-003 (sentinels must exist to reference them in rule)

#### Estimated Effort

30 minutes

#### Testing Requirements

- Manual: Verify rule file is valid markdown
- Manual: Compare format to existing rules

#### Validation Steps

1. Read existing rule files for format reference
2. Create `markdown-editing.md`:
   - `<markdown_editing>` opening tag
   - Summary of block-aware guidelines
   - Sentinel preservation rule
   - Context anchor requirement
   - `</markdown_editing>` closing tag
3. Verify with markdown preview

#### Strict Rules

- Follow exact format of existing rule files
- Keep rule concise (under 100 lines)
- Focus on prevention, not general markdown syntax

#### Existing Code Patterns

`.windsurf/rules/*.md` use XML-style tags:
```markdown
<rule_name>
content...
</rule_name>
```

#### Advanced Code Patterns

N/A

#### Anti-Patterns

- Don't duplicate entire read.md content (too long)
- Don't use different tag format than other rules

---

## Summary of Phases

| Phase | Tasks | Priority | Goal |
|-------|-------|----------|------|
| 1 | TASK-MD-001, TASK-MD-002 | 🔴 Critical | Establish safety baseline and understand scope |
| 2 | TASK-MD-003, TASK-MD-004, TASK-MD-005 | 🟠 High | Apply structural safeguards to all files |
| 3 | TASK-MD-006, TASK-MD-007, TASK-MD-008, TASK-MD-009 | 🟡 Medium | Split large files for context safety |
| 4 | TASK-MD-010, TASK-MD-011, TASK-MD-012 | 🟢 Low | Tooling for ongoing protection |

**Estimated Total Effort**: ~13 hours  
**Critical Path**: TASK-MD-001 → TASK-MD-002 → (rest can parallelize per file)

---

## Dependencies Graph

```
TASK-MD-001 (Git Checkpoint)
    ↓
TASK-MD-002 (Audit)
    ↓
    ├── TASK-MD-003 (Sentinels) ─┐
    │                            ↓
    ├── TASK-MD-004 (Inline Links) ─┐
    │                               ↓
    ├── TASK-MD-005 (Whitespace) ───┤
    │                               ↓
    │                         Split Tasks (006-009)
    │                               ↓
    │                         Tooling (010-012)
    │
    └── Independent: Can start after 002
        ├── TASK-MD-010 (markdownlint config)
        └── TASK-MD-012 (Windsurf rule)
```
