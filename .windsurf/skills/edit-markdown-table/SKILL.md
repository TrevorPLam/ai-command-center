---
name: edit-markdown-table
description: Safely edit a Markdown table by regenerating the entire table with proper header separator row and column alignment. Use when any table cell content needs modification.
---

# Edit Markdown Table Skill

## When to Use

- Any table cell content needs modification
- Adding or removing table rows
- Changing column alignment
- Fixing table formatting issues

## Procedure

### 1. Capture the Complete Table

Extract the ENTIRE table including:
- Header row (column names)
- Separator row (`---` alignment markers)
- All data rows

```markdown
| Column A | Column B | Column C |
|:---------|:--------:|---------:|
| Left     | Center   | Right    |
| Data 1   | Data 2   | Data 3   |
```

### 2. Apply Changes

Make edits to the complete table structure, ensuring:
- Column count remains consistent
- Separator row uses correct alignment markers
- All rows have the same number of cells

### 3. Output the Complete Table

Regenerate the entire table with changes applied.

## Column Alignment Reference

| Marker | Alignment |
|--------|-----------|
| `:---` | Left (default) |
| `:---:` | Center |
| `---:` | Right |

## Example

**Task:** Fix typo in column B, row 2

**Input:**
```markdown
| Name | Status | Date |
|------|--------|------|
| Task 1 | Complte | 2024-01-01 |
| Task 2 | Pending | 2024-01-02 |
```

**Output (regenerate entire table):**
```markdown
| Name | Status | Date |
|------|--------|------|
| Task 1 | Complete | 2024-01-01 |
| Task 2 | Pending | 2024-01-02 |
```

## Validation Checklist

- [ ] Header row present
- [ ] Separator row with alignment markers
- [ ] All rows have same column count
- [ ] No merged cells (simple tables only)
- [ ] Consistent column widths (visual only)
