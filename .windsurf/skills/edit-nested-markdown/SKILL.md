---
name: edit-nested-markdown
description: Edit deeply nested Markdown structures (code blocks inside list items, lists within blockquotes) by extracting and regenerating complete parent blocks to preserve structural integrity.
---

# Edit Nested Markdown Skill

## When to Use

- Code blocks inside list items
- Nested lists (lists within lists)
- Blockquotes containing other elements
- Tables with formatted cell content
- Any nested structure requiring modification

## Core Principle

**Always regenerate the complete outer block.** Never edit just the inner nested element.

## Procedure

### 1. Identify the Structure Hierarchy

Analyze the nesting levels:

```markdown
1. First item (Level 1)
   - Nested bullet (Level 2)
     ```typescript
     // Code block (Level 3)
     const x = 1;
     ```
   - Another bullet (Level 2)
2. Second item (Level 1)
```

### 2. Extract the Complete Parent Block

When editing the code block above, extract the ENTIRE Level 1 item:

```markdown
1. First item (Level 1)
   - Nested bullet (Level 2)
     ```typescript
     // Code block (Level 3)
     const x = 1;
     ```
   - Another bullet (Level 2)
```

### 3. Regenerate with Changes

Output the complete parent block with modifications applied.

## Indentation Standards

- Standard indent: 2 or 3 spaces per level
- Code blocks in lists: maintain relative indent from list item
- Consistency within file: match existing indentation style

## Common Patterns

### List Item with Code Block

**Editing:** Code inside list item

**Extract:** Entire list item including nested bullets

**Output:** Complete regenerated list item

### Nested Lists

**Editing:** Third-level bullet

**Extract:** Entire first or second-level branch

**Output:** Complete regenerated branch

### Blockquote with Mixed Content

**Extract:** Entire blockquote from `>` start to blank line

**Output:** Complete regenerated blockquote

## Validation Checklist

- [ ] Indentation preserved at all levels
- [ ] Nested fences properly aligned
- [ ] Blank lines maintained between blocks
- [ ] Parent block boundaries intact
