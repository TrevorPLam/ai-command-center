---
name: search-replace-context-anchor
description: Perform precise search/replace in Markdown using 2-3 line surrounding context to prevent ambiguous matches. Use for all find-and-replace operations in Markdown files.
---

# Search Replace Context Anchor Skill

## When to Use

- Any find-and-replace operation in Markdown
- Renaming terms or fixing repeated typos
- Updating URLs or references
- Changing terminology across a document

## The Problem

Short search strings match multiple locations:
- "fix" appears in "prefix", "suffix", "fix"
- "add" appears in "addition", "address"

## The Solution: Context Anchors

Provide 2-3 lines of surrounding context to make location unambiguous.

## Procedure

### 1. Build the Context Anchor

Include content BEFORE and AFTER the target:

```markdown
<!-- Context anchor (3 lines before, 3 lines after) -->
Previous content line 1
Previous content line 2
Target line to replace
Following content line 1
Following content line 2
```

### 2. Specify the Replacement

Clearly indicate what changes in the target:

```markdown
Find:
Previous content line 1
Previous content line 2
Target line to replace
Following content line 1
Following content line 2

Replace with:
Previous content line 1
Previous content line 2
New replacement line
Following content line 1
Following content line 2
```

### 3. Unified Diff Format (Optional)

For complex edits, output in diff format:

```diff
--- a/file.md
+++ b/file.md
@@ -10,13 +10,13 @@
 Previous content line 1
 Previous content line 2
-Target line to replace
+New replacement line
 Following content line 1
 Following content line 2
```

## Context Size Guidelines

| Situation | Context Lines |
|-----------|---------------|
| Unique phrase | 1 line before/after |
| Common word | 2-3 lines before/after |
| Repeated pattern | 3-5 lines before/after |
| Near identical sections | Include unique identifiers |

## Example

**File content:**
```markdown
## Installation

Run the install command:
```bash
npm install
```

## Configuration

Edit the config file:
```bash
nano config.json
```
```

**Task:** Change "npm install" to "npm ci"

**Weak anchor (ambiguous):**
Find: `npm install`

**Strong anchor (unambiguous):**
```markdown
## Installation

Run the install command:
```bash
npm install
```
```

## Validation Checklist

- [ ] Context anchor is unique in the file
- [ ] Surrounding lines are verbatim copies
- [ ] Replacement preserves surrounding context
- [ ] Only the intended location will match
