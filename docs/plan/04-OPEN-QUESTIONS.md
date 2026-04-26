# Open questions

This document tracks questions that need to be resolved during the build process. Planning documents should reference these as configurable policies to be defined later.

---

## Questions to resolve

| # | Question | Context | Resolution approach | Status |
| --- | ---------- | --------- | --------------------- | -------- |
| 1 | How often should agents check for conflicts? | Agents must proactively identify cross-app conflicts (e.g., email reschedule vs. project deadline) | Tier-based frequency; per-feature config (calendar 5 min, email 15 min); user-configurable | Open -- to be defined during implementation |
| 2 | What UI patterns make deterministic actions feel agentic? | Deterministic code tools should still feel intelligent and agentic in the UX | NL summaries, thinking indicators, agent avatars, progress indicators; design exploration needed | Open -- design exploration needed |
| 3 | What are the exact feature gates per subscription tier? | Need to define which features are available at each tier | Free: local models (Gemma 4, Qwen 3.5); Pro: cloud API (Sonnet 4.6); Enterprise: Opus 4.7, fine-tuning. TBD: token limits, agent counts, storage, overage pricing, trial periods | Open -- feature gates TBD |
| 4 | How should cross-user conflict detection work? | Data model supports `org_id` from day one, but cross-user conflict detection is undefined | Deferred to later phases; data model prepared; single-org conflict detection first | Deferred -- documented for future phases |
| 5 | How to version, update, and deprecate local models without breaking workflows? | Local models (Ollama, llama.cpp) need a lifecycle management policy | SemVer for configs; deprecation notices + migration paths; N-version backward compat; auto-migration scripts; EOL policy with timelines | Open -- policy needed |

---

## Notes

- This document should be updated as questions are resolved
- Resolved questions should be moved to appropriate planning documents
- New questions should be added here as they emerge during development