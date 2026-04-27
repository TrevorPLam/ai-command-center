---
title: "Cross-cutting Services Index"
owner: "Architecture"
status: "active"
updated: "2026-04-26"
canonical: ""
---

This document provides an index to all cross-cutting service documentation, organized by architectural layer.

---

## Domain Files

- [50-XCT-FOUNDATION.md](50-XCT-FOUNDATION.md) - Authentication, secrets management, rate limiting, and content security policy
- [50-XCT-DATA.md](50-XCT-DATA.md) - Realtime, offline sync, recurrence, search, and data processing services
- [50-XCT-AI.md](50-XCT-AI.md) - AI guardrails, cost tracking, observability, and MCP security
- [50-XCT-UI.md](50-XCT-UI.md) - Motion, optimistic mutations, design system, and sanitization

---

## Historical Note

The monolithic `50-XCT-SERVICES.md` file has been split into domain-specific files for better organization and maintainability. All content has been preserved and redistributed across the four domain files listed above.
