# Markdown Guide (Token‑Optimized)

## Overview

**Markdown** – lightweight markup (Gruber, 2004). Uses simple symbols for formatting. Separation of content/presentation. Plain text: cross‑platform, version‑control‑friendly.

**Problems solved:** cross‑platform compatibility, focus on content, Git‑manageable, future‑proof.

---

## 1. Syntax Quick Reference

### Headings (ATX only)

`#`‑`######` + space + text. One H1 per doc.

### Inline Formatting

| Style           | Syntax          | Example       |
|-----------------|-----------------|---------------|
| Italic          | `*text*`/`_text_` | *text*        |
| Bold            | `**text**`/`__text__` | **text**      |
| Bold+Italic     | `***text***`    | ***text***    |
| Strikethrough   | `~~text~~`      | ~~text~~      |
| Inline code     | `` `code` ``    | `code`        |

### Links & Images

- **Inline link:** `[text](URL)`  
- **Reference link:** `[text][label]` → `[label]: URL`  
- **Raw URL:** `<URL>`  
- **Image:** `![alt](src)`

### Lists

- **Unordered:** `-`, `*`, `+` + space; nested via 4‑space indent  
- **Ordered:** `1.` item (numbers can be any)  
- **Task:** `- [ ]` / `- [x]`

### Code

- Inline: `` `code` ``  
- Fenced block: ` ```lang ` (surround with blank lines)

### Tables

```markdown
| Left | Center | Right |
|:-----|:------:|------:|
| a    |   b    |     c |
```

- Include leading/trailing pipes for readability  
- Alignment: `:---` left, `:---:` center, `---:` right  
- Consistent column counts

### Other

- **Blockquote:** `> ` prefix  
- **Horizontal rule:** `***` or `---`  
- **Line break:** two trailing spaces  
- **Paragraph:** blank line between

---

## 2. Core Principles

**Readability first** – plain text must be legible.

**Parsing phases:**
1. *Block structure* – leaf blocks, container blocks, link refs  
2. *Inline structure* – emphasis, links, code spans

**Whitespace:**
- Exactly one blank line between different block types  
- No multiple consecutive blank lines (render as one)  
- No trailing spaces (affect rendering)  
- Use spaces, never tabs

**Escaping:** `\` before special char (`\#`, `\*`, `\_`, etc.)

**Markdown ≠ full typography.** Fallback: inline HTML or LaTeX.

---

## 3. Best Practices (Condensed)

- **One H1** per document, first heading = title (sentence case)  
- **ATX headings only**; never skip levels (H1→H2→…)  
- **Headings:** no bold/italic; blank line above each  
- **Emphasis:** use `_italic_`, `**bold**`; bold only for UI elements/notices; italic sparingly  
- **Links:** prefer inline over raw; meaningful link text; validate  
- **Lists:** consistent indent (4 spaces); blank line before start  
- **Code blocks:** fenced + language tag; blank lines around  
- **Tables:** leading/trailing pipes; align logically  
- **Line length:** ≤100 characters (79 for “about_” articles); use Reflow Markdown  
- **File names:** lowercase, hyphens, no reserved words; UTF‑8; end file with single newline  
- **Heading anchors:** no periods; use hyphens for versions; no duplicate IDs  

---

## 4. Standards: CommonMark & GFM

### CommonMark

**Problem:** original Markdown ambiguous → inconsistent rendering across sites.  
**Solution:** CommonMark spec (v0.31.2, Jan 2024) – precise parsing algorithm + test suite.

**Key differences from “classic” Markdown:**
- Requires blank lines before many block elements  
- Strict list indentation (4 spaces)  
- Fenced code blocks standardized (backticks/tildes)  
- Delimiter‑stack algorithm for nested emphasis  
- Hard line breaks: two spaces at EOL  

### GitHub Flavored Markdown (GFM)

Extends CommonMark with:  
- Tables, task lists, strikethrough  
- Autolinks, emoji shortcodes  
- Syntax highlighting via language tags  

**Best practice:** use GFM where supported; fall back to CommonMark or raw HTML.

---

## 5. Extended Syntax (Tool‑Specific)

| Extension         | Syntax/Usage                |
|-------------------|-----------------------------|
| Admonitions       | `> [!NOTE]` etc. (GitHub)   |
| Math              | `$...$` / `$$...$$` (KaTeX) |
| Mermaid diagrams  | ` ```mermaid `              |
| Footnotes         | `[^label]`                  |
| Definition lists  | Term: definition            |
| Spoilers          | `||text||` or `<details>`   |
| Sub/superscript   | `~sub~` `^sup^`             |
| Highlight         | `==highlight==`             |
| Insert/underline  | `++insert++`                |
| Emoji             | `:smile:`                   |

**Use only when rendering environment is known.** Fallback to standard Markdown.

---

## 6. Tools for Quality

- **markdownlint** – Node.js linter (VS Code extension, CLI). Key rules: MD001 (heading increment), MD025 (single H1), MD030 (list spacing). Configurable via `.markdownlint.yaml`.  
- **markdig** – CommonMark parser (used by Microsoft Learn).  
- **Prettier** – formatting.  
- **Reflow Markdown** – line length enforcement.  

---

## Quick‑Reference Standards Summary

| Standard            | Description                                          |
|---------------------|------------------------------------------------------|
| CommonMark          | Unambiguous spec (v0.31.2); ensures consistent rendering |
| GFM                 | GitHub’s CommonMark extensions (tables, tasks, etc.) |
| One H1 / doc        | Exactly one top‑level heading                        |
| Blank lines         | One between different block types                    |
| Line length         | ≤100 characters (79 for “about_”)                    |
| Spaces, never tabs  | Consistent indentation                               |
| No trailing spaces  | Avoid unpredictable rendering                        |
| ATX headings        | `# …` not underlined                                 |
| Sentence case       | Only first word + proper nouns capitalized           |

---

## Final Recommendations

1. Baseline on CommonMark; add GFM if publishing on GitHub.
2. Lint with markdownlint in CI.
3. Enforce one blank line between blocks; no trailing spaces.
4. Use spaces, ≤100‑char lines.
5. Logical heading hierarchy: one H1, no skipping.
6. Leading/trailing pipes in tables.
7. Language tags on fenced code blocks.
8. Validate links.
9. Avoid extended syntax unless renderer is controlled.
10. End files with a single newline.