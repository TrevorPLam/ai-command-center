---
name: validate-markdown-edit
description: Post-edit validation workflow for Markdown files. Run after any Markdown edit to check for structural damage, lint violations, and common corruption patterns.
---

# Validate Markdown Edit Skill

## When to Use

- After ANY Markdown file edit
- Before committing Markdown changes
- When reviewing AI-generated Markdown edits
- As a sanity check for complex modifications

## Procedure

### 1. Structural Integrity Check

Verify no structural damage occurred:

```bash
# Check for common issues
grep -n '```\|`' file.md | head -20  # Fence balance
grep -c '^# ' file.md               # Heading count (before vs after)
wc -l file.md                       # Line count (should match expected)
```

### 2. Run Markdown Linter

Execute markdownlint with project config:

```bash
npx markdownlint file.md
# Or with config:
npx markdownlint -c .markdownlint.json file.md
```

### 3. Manual Spot Checks

Review for these common corruptions:

| Check | What to Look For |
|-------|------------------|
| Blank lines | Were any removed or added incorrectly? |
| Indentation | Are nested structures still properly indented? |
| Code fences | Are all fences properly closed? |
| Tables | Do column counts match? Is separator row intact? |
| Links | Are reference definitions still present? |
| Lists | Are separate lists still separate? |

### 4. Golden Rules Verification

Confirm the "golden rules" from read.md:

- [ ] Lists regenerated as complete blocks (not line-edited)
- [ ] Tables regenerated with header + separator rows
- [ ] Context anchors used for search/replace
- [ ] Blank lines preserved exactly
- [ ] Fence collisions avoided
- [ ] Links updated in pairs (if reference-style)

## Common Damage Patterns

| Symptom | Cause | Fix |
|---------|-------|-----|
| Two lists merged | Blank line removed | Re-add blank line between lists |
| Code block merged with text | Missing fence | Add proper opening/closing fences |
| Table alignment lost | Separator row corrupted | Restore `---` alignment markers |
| Nested code over-indented | Indentation calculation error | Match parent list item indent |
| Link broken | Definition moved/deleted | Restore reference definition |

## Quick Validation Commands

```bash
# Check fence balance
[[ $(grep -c '```' file.md) % 2 -eq 0 ]] && echo "Fences balanced" || echo "FENCE ERROR"

# Check for orphaned reference links
grep -o '\[.*?\]\[.*?\]' file.md | sort | uniq

# Verify line count hasn't changed dramatically
wc -l file.md
```

## Report Format

After validation, report findings:

```markdown
## Validation Report: `filename.md`

### Structural Checks
- [x] Fences balanced
- [x] Line count matches expected
- [x] Heading hierarchy intact

### Lint Results
- 0 errors, 2 warnings (MD031 - acceptable)

### Manual Review
- [x] Blank lines preserved
- [x] Tables properly formatted
- [x] Links functional

**Result:** ✅ PASS / ❌ FAIL
```

## Integration

Run this skill automatically after any Markdown edit by:
1. Manual invocation: `@validate-markdown-edit`
2. Workflow integration: Add to `/markdown-safe-edit` workflow
3. Hook integration: Add to post-edit hooks
