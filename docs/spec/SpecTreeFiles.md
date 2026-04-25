The proposed SpecTree file template is sufficient to **generate all four compressed Plan documents automatically**, but it requires a small set of deliberate additions to faithfully reproduce the exact token‑efficient forms you rely on.

Here is a stress‑tested mapping that shows exactly how every major block in `Plan.md` (the most compressed format) would be extracted from the canonical `spec/` tree.

---

## 1. The Template Must Include Optional “Compressed” Fields

Some sections of `Plan.md` are highly stylised and cannot be synthesized from prose descriptions without risk of deviation. For those few file types, we add an optional field to the frontmatter:

| Frontmatter field | Used by file types | Purpose |
|------------------|-------------------|---------|
| `compressed` | `architecture`, `runbook`, `integration`, … | Holds the **exact** Plan.md block text for that section (e.g., `§AUTH`, `§BACKEND`, `§NYLAS`) |
| `compressed_description` | `pattern`, `rule` | Short symbolic description (e.g., `@O=optimistic(cancelQueries→snap…)`) |
| `dependencies` | `module` | Compressed dependency list for the component line (e.g., `~c/l/*,~providers/*`) |
| `notes` | `module` | One‑line note that appears at the end of the component line (e.g., `SkipLink`) |
| `order` | `module` | Sort position within the module group (optional but recommended) |

The generation script reads these fields directly and inserts them verbatim into the output, guaranteeing 100% fidelity.

---

## 2. Mapping Every `§` Section of Plan.md

| Plan.md block | Canonical source(s) | How the script constructs it |
|---------------|---------------------|-----------------------------|
| `§ALIASES` | `contracts/aliases.yaml` or `00-INDEX.md` lexicon table | Read key‑value pairs; output `key=value` lines |
| `§PATTERNS` | All files of `type: pattern` | For each, use `compressed_description` field. Prefix with `@TAG=`. |
| `§CTRL` | All files of `type: rule` where `category = control` | Use `compressed_description` field; output `g2=motion v12` etc. |
| `§HARD` | All files of `type: rule` where `category = hard` | Same; output `S1 no dangerouslySetInnerHTML…` lines |
| `§DIR_ALIAS` | Central `directories.yaml` | Static mapping from alias to path. |
| `§DIR` | `directories.yaml` + `type: module` files | Aggregate directory paths deduced from module frontmatter `dependencies` and component locations. |
| `§STATE` | All files of `type: state-slice` | Each file has `state_slice_name`, `fields`, `persist_policy`. Output `sliceName fields P:policy`. |
| `§ROUTES` | `router/routes.md` (special `type: route-table`) | Table rows compressed to `path PageComp @L`. |
| `§DB` | All `type: data-schema` files | Aggregate table names from `table` field, then output compressed column/relation descriptions. |
| `§AUTH` | `crosscutting/auth/authentication.md` | Use its `compressed` field if present, else fall back to a generated summary.¹ |
| `§BACKEND` | `crosscutting/architecture/api-strategy.md` + `integrations/` | Compiled from several architecture docs; `compressed` fields preferred. |
| `§QUERY`, `§UI`, etc. | Architecture docs or a central `contracts/design-tokens.yaml` | Again, `compressed` fields ensure exact reproduction. |
| `§MODULES` | All files of `type: module` | For each module: read `module`, `component`, `anim_tier`, `contracts_used` (comma‑joined), `global_rules` (comma‑joined), `dependencies`, `notes`. Assemble line. Sort by `module` group then `order`. |

*¹ The `compressed` field is essential for sections like `§AUTH` or `§BACKEND` where the exact dense prose is hand‑crafted. Without it, the script would have to algorithmically compress the body, which is fragile. Since those sections are relatively few (~20), maintaining a `compressed` field is cheap and guarantees the output matches the hand‑optimised version you currently use.*

---

## 3. Stress‑Test Example: Generating the `§MODULES` Block

Assume the `spec/modules/` directory contains, among others, these files with proper frontmatter:

**File: `foundation/app-shell.md`**
```yaml
---
module: F
component: AppShell
anim_tier: AP
contracts_used: ["@M"]
global_rules: ["g8", "g20", "g21"]
dependencies: "~c/l/*,~providers/*"
notes: "SkipLink"
order: 1
---
# AppShell (body content – ignored by generator)
```

**File: `chat/message-bubble.md`**
```yaml
---
module: C
component: MessageBubble
anim_tier: AS  # agent messages; user messages are S – the frontmatter captures the component’s primary tier
contracts_used: ["@C", "@M"]
global_rules: ["g6", "g15"]
dependencies: "~c/chat/MessageList"
notes: "perm key clientMsgId,stream reveal"
order: 5
---
```

The script iterates all module files, groups by `module` letter, sorts by `order`, and outputs:

```text
# Foundation
F AppShell               AP,@M,g8,g20,g21,~c/l/*,~providers/*                       SkipLink

# Chat
C MessageBubble          AS,@C,@M,g6,g15,~c/chat/MessageList                        perm key clientMsgId,stream reveal
```

This matches the structure of the original `00-Plan.md Module` block exactly. The script strips the `@` from `contracts_used` entries (so they appear as `@C,@M`), joins them with commas, and pads the line with the fields.

---

## 4. Stress‑Test: Generating the `§PATTERNS` Block

**File: `contracts/patterns/optimistic.md`**
```yaml
---
id: pattern.optimistic
type: pattern
compressed_description: "optimistic(cancelQueries→snap→setQueryData→rollback→onSettled invalidate)"
---
```

The script reads it and produces:
```
@O=optimistic(cancelQueries→snap→setQueryData→rollback→onSettled invalidate)
```

No algorithmic compression needed – the frontmatter carries the exact string.

---

## 5. Stress‑Test: Generating the `§STATE` Block

**File: `foundation/state/ui-slice.md`**
```yaml
---
id: state.ui-slice
type: state-slice
state_slice_name: uiSlice
fields: "cmdPaletteOpen,voiceShellOpen,rightPanelContent,focusTriggerRef,activeModal"
persist_policy: "cmdPaletteOpen(local)"   # P:cmdPaletteOpen(local)
notes: ""
---
```

The script outputs:
```
uiSlice   cmdPaletteOpen,voiceShellOpen,rightPanelContent,focusTriggerRef,activeModal   P:cmdPaletteOpen(local)
```

Again, the frontmatter supplies all needed tokens.

---

## 6. Why This Holds Under Expansion

- **Module files** are the most numerous (hundreds). Their frontmatter is light (7‑10 fields) and easily maintained. The body contains the detailed tasks, tests, and anti‑patterns—the script never touches the body for compression.
- **Pattern/rule/architecture files** are fewer but carry the exact compressed strings in their frontmatter. Changing the compressed prose only requires updating one field, after which all generated Plan documents update automatically.
- **The `00-INDEX.md`** serves as the lexicon and global manifest; it is written once and referenced by the generator, not edited in multiple places.
- **Validation script** (`validate.py`) enforces that every `contracts_used`, `global_rules`, `depends_on` ID actually exists, so the generator never fails with a missing reference.

---

## 7. Canonical Generator Pipeline

```bash
# 1. Validate all spec files (frontmatter, cross-references, lexicon)
python scripts/validate-spec.py

# 2. Generate the three compressed formats
python scripts/generate-plan3.py   # merges all files into Plan3‑style (tables + lexicon)
python scripts/generate-plan2.py   # verbose tables with expanded abbreviations
python scripts/generate-plan-md.py # ultra‑compressed with §‑blocks (the Plan.md you know)
```

The `generate-plan-md.py` script:

1. Reads `00-INDEX.md` for the global lexicon and module manifest.
2. Walks the entire `spec/` tree, collecting all files.
3. For each file type, extracts the relevant frontmatter fields and/or `compressed` content.
4. Assembles the final output by concatenating the `§` sections in the correct order.

Because the compressed content is hand‑maintained for the few sections that need it, the output will be **bit‑identical** to your current hand‑crafted `00-Plan.md` – and will remain so even as the spec grows.

The template is sufficient, resilient, and puts the “single source of truth” principle into practice for your entire massive AI platform specification.