# Decision register

This is the append‑only log of every decision made during planning and development. It tracks product, UX, copy, configuration, and process choices that don't warrant a full Architecture Decision Record (ADR) but must be recorded.

**For everyone:** Before making a new decision, check this file -- an active decision may already cover it. If you make a new decision, append a row.

## Decision table format

Every decision is a single row. All columns must be filled.

| Column | Description |
|--------|-------------|
| **ID** | `DEC-YYYY-MM-DD-NNN` (date + sequential number) |
| **Date** | When the decision was made (ISO 8601). |
| **Domain** | `Platform`, `Data`, `AI-Core`, `Frontend`, `UX`, `Security`, `Business`, `Process` |
| **Decision** | What was chosen. One sentence, specific. |
| **Rationale** | Why this choice. Include rejected alternatives if they were seriously considered. |
| **Reversible?** | `Yes` (can change later at low cost), `Costly` (can change but requires migration work), `No` (very hard to undo). |
| **Confidence** | `High`, `Medium`, `Low`. |
| **Status** | `active`, `superseded`, `expired` |
| **Expiry** | If temporary, when it expires. Otherwise `none`. |
| **Linked Items** | Related ADR IDs, backlog items (BP-XXX), or spec filenames. |
| Session | `session-YYYY-MM-DD-platform-topic.md` for traceability. |

## Rules

- Append only. Never edit existing rows -- supersede them with a new row.
- Reversible decisions can be made quickly by an agent. Costly/irreversible ones need Trevor's explicit review.
- The register is reviewed for staleness after every 5 planning sessions and at each Phase gate.

## Active decisions

| ID | Date | Domain | Decision | Rationale | Reversible? | Confidence | Status | Expiry | Linked Items | Session |
|----|------|--------|----------|-----------|-------------|------------|--------|--------|--------------|---------|
| DEC-2026-04-26-001 | 2026-04-26 | Process | All planning documents follow SPEC-TEMPLATE.md format (YAML frontmatter + 9 sections). | Standardization across sessions; rejected free-form markdown. | Costly | High | active | none | SPEC-TEMPLATE.md, ADR_054 | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-002 | 2026-04-26 | Process | `00-PLANNING-BACKLOG.md` is the single source of truth for unresolved decisions. No code execution until block prerequisites are resolved. | Prevents premature implementation. Rejected alternative: start coding immediately. | Yes | High | active | none | 00-PLANNING-BACKLOG.md | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-003 | 2026-04-26 | Process | This decision register uses append‑only: new decisions get new rows; old ones are marked `superseded`. | Preserves decision history for audit and context recovery. | Costly | High | active | none | -- | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-004 | 2026-04-26 | Process | AI agents must read this register at session start and append any new decisions before session end. | Prevents decision loss across sessions. | Yes | High | active | none | -- | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-005 | 2026-04-26 | Process | Reversible decisions are made by AI agents without waiting for Trevor’s approval. Costly or irreversible decisions require explicit Trevor review. | Prevents decision paralysis while protecting against costly mistakes. | Yes | Medium | active | Review after 10 sessions | -- | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-006 | 2026-04-26 | UX | The conflict detection UX spec must cover all 8 states: no conflicts, conflict detected, awaiting action, resolving, resolved, failed, multiple conflicts, dismissed-without-action. | Core product magic depends on this feeling intelligent. | Costly | High | active | none | BP-006, 10-UX-CONFLICT-FLOW.md | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-007 | 2026-04-26 | Process | Session naming convention: `session-YYYY-MM-DD-platform-topic.md`. Store all session outputs in `sessions/` folder. | Traceability across parallel AI platforms. | Yes | High | active | none | -- | session-2026-04-26-claude-planning-framework |
| DEC-2026-04-26-008 | 2026-04-26 | Security | CSP nonce strategy will be implemented in Phase 0 Block 0F, not earlier. During Blocks 0A-0E, Report‑Only CSP is acceptable. | Security‑critical but early enforcement would slow initial UI development. Rejected alternative: enforce from day one. | Yes | High | active | Expires at start of Block 0F | BP-009, 05-XCT-CSP.md | session-2026-04-26-claude-planning-framework |

---

## Superseded decisions

| ID | Date | Domain | Decision | Rationale | Superseded By | Superseded Date | Session |
|----|------|--------|----------|-----------|---------------|-----------------|---------|
| *None yet* | | | | | | | |

---

## Expired decisions

| ID | Date | Domain | Decision | Rationale | Expired | Session |
|----|------|--------|----------|-----------|---------|---------|
| *None yet* | | | | | | |

---

## Statistics

| Metric | Count |
|--------|-------|
| Total decisions | 8 |
| Active | 8 |
| Superseded | 0 |
| Expired | 0 |
| Reversible (Yes) | 5 |
| Costly to reverse | 2 |
| Irreversible (No) | 1 |
| High confidence | 7 |
| Medium confidence | 1 |
| Low confidence | 0 |

---

## Appendix: decision register vs. full ADR

Use this flowchart to decide where to record a decision:

- **Does it affect system structure, quality attributes, or technology choices?**
  - Yes → Write a full ADR (follow the ADR_KEY format in `01-PLAN-LEXICON.md`).
  - No → Continue.
- **Is it hard to reverse?**
  - Yes → Write a full ADR (the cost of being wrong justifies the documentation).
  - No → Add a row to this Decision Register.

Examples:
- ADR‑worthy: “Use PostgreSQL not MongoDB,” “Use Vite SPA not Next.js,” “MCPSec L2 mandatory for all MCP servers.”
- Decision Register‑worthy: “Default calendar view is Month,” “Notification batch size is 20,” “The empty dashboard state says ‘Your assistant is monitoring for conflicts’.”

---

*This register is the companion to the ADR index (`01-PLAN-ADR-INDEX.md`). Together they contain every architectural and operational choice made in the project.*