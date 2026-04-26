# Technical validation matrix

This document validates the major technology components selected for the AI Command Center platform with evidence from real-world implementations, benchmarks, and industry research.

---

## Core technology claims

| Technology | Claim | Status | Source |
|------------|-------|--------|--------|
| TypeScript 7.0 `tsgo` | Microsoft ships native preview builds exposing `tsgo`, a Go-native compiler running alongside `tsc`. Benchmarks show 10x speed improvements, with projects reporting 9x faster typechecking. | VER | Microsoft TypeScript preview builds |
| pgvectorscale with DiskANN | Timescale's extension achieves 28x lower p95 latency and 16x higher throughput vs. Pinecone's storage-optimized index on 50M Cohere embeddings. | VER | Timescale pgvectorscale benchmarks |
| APS (Agent Passport System) IETF Draft | Defines Agent Passports (Ed25519), 7-dimension constraint lattice, 3-signature chain, cascade revocation, Bayesian reputation, institutional governance, signed message envelopes, tool integrity signatures, nonce replay protection, trust levels L0-L4. | DRAFT | IETF draft for Agent Passport System |
| LiveKit Agents v1.0.0 | Production-ready framework for building real-time, multimodal voice and video AI agents using WebRTC. | PROD | LiveKit official release |
| Playwright AI Agents | Three-agent architecture (Planner, Generator, Healer) for automated E2E test creation delivered in Playwright 1.56.0. | REL | Playwright 1.56.0 release notes |
| Stripe Agent Toolkit | `@stripe/agent-toolkit`, `@stripe/ai-sdk`, and `@stripe/token-meter` provide metered billing, middleware, and MCP-based Stripe access. | AVAIL | Stripe developer documentation |
| Orval CVE-2026-25141 | Critical CVSS 9.3 code injection via unsanitized `x-enum-descriptions`; fixed in 8.2.0. | FIXED | CVE database, Orval security advisory |
| DOMPurify XSS | Versions 3.0.1-3.3.3 vulnerable to prototype pollution bypass (CVE-2026-41238). | VULN | CVE database, DOMPurify security advisory |
| React 20 Compiler / Vite 8 / Rolldown | Vite 8 ships with Rust-based Rolldown as default bundler; React Compiler support via `@rolldown/plugin-babel`. | REL | Vite 8 release notes, React Compiler documentation |
| Turborepo 2.x | `pipeline` renamed to `tasks`; task graph-based scheduling with topological ordering. | REL | Turborepo 2.0 migration guide |
| A2A v1.0 | Google's protocol with Agent Cards, decentralized discovery, and cryptographic identity primitives. | REL | Google A2A protocol documentation |
| Tailwind CSS v4 | CSS-first configuration via `@theme` directive for design tokens. | REL | Tailwind CSS v4 documentation |
| Zustand v5 | Lightweight state management with improved comparison mechanisms and `useShallow`. | REL | Zustand v5 release notes |
| Claude Opus 4.7 | Scores 87.6% on SWE-bench Verified, 94.2% on GPQA Diamond, 64.4% on Finance Agent. New xhigh effort level (coding default), task budgets in public beta, tokenizer multiplier 1.0-1.35×. | REL | Anthropic model card, benchmark results |
| EU AI Act | Current statutory deadline August 2, 2026 for majority of rules. Proposed Digital Omnibus extension (pending Council approval as of April 2026) would delay high-risk obligations to December 2, 2027 (stand-alone high-risk) / August 2, 2028 (embedded high-risk). Articles 9-15 mandate extensive documentation. | LEG | EU AI Act official documentation |
| OpenTelemetry `gen_ai` | Semantic conventions for agentic systems (agents, tasks, teams, artifacts) with Datadog native support. | REL | OpenTelemetry specification, Datadog documentation |
| MACH Alliance | Microservices, API-first, Cloud-native, Headless principles; launched AI Exchange in April 2025. | ACT | MACH Alliance official announcements |
| Decision Velocity | Defined as speed × accuracy × effectiveness; emerging metric for AI ROI. | CON | Industry research on AI ROI metrics |
| Semantic Layer | MATRIX ontology for multi-agent shared memory; knowledge graph integration for cross-agent communication. | CON | Research on multi-agent systems |
| TanStack DB 0.6 | SQLite-backed persistence, offline support, hierarchical data projection, query-driven sync with PowerSync and ElectricSQL. | REL | TanStack DB documentation |

**Status codes**: VER=Verified, DRAFT=Draft specification, PROD=Production-ready, REL=Released, AVAIL=Available, FIXED=Fixed, VULN=Vulnerability identified, LEG=Legislative process ongoing, ACT=Active, CON=Concept

---

## Security Vulnerability References

### MCP Security Issues

| CVE | Description | CVSS | Downloads | Mitigation |
|-----|-------------|------|-----------|------------|
| CVE-2025-6514 | mcp-remote command injection | 9.6 | 437K+ | CIS MCP Companion Guide (Apr 21, 2026) |
| CVE-2026-23744 | MCPJam Inspector RCE | - | - | CIS MCP Companion Guide |
| CVE-2025-49596 | MCP Inspector RCE | - | - | CIS MCP Companion Guide |

**Summary**: 30 CVEs disclosed in 60 days (Jan-Feb 2026), 13 rated critical by Vulnerable MCP Project

### OWASP ASI CVE Mapping (April 2026)

| Category | CVE | Description | CVSS | Incidents |
|----------|-----|-------------|------|----------|
| ASI01: Agent Goal Hijack | CVE-2025-32711 | EchoLeak, Microsoft 365 Copilot | 9.3 | - |
| ASI01: Agent Goal Hijack | CVE-2025-53773 | GitHub Copilot YOLO Mode | 7.8 | - |
| ASI01: Agent Goal Hijack | CVE-2025-64660 | AGENTS.MD Hijacking in VS Code | - | - |
| ASI01: Agent Goal Hijack | CVE-2025-61590 | AGENTS.MD Hijacking in VS Code | - | - |
| ASI02: Tool Misuse & Exploitation | CVE-2025-8217 | Amazon Q Code Assistant | 7.8 | - |
| ASI02: Tool Misuse & Exploitation | CVE-2025-34291 | Langflow AI RCE | - | - |
| ASI03: Identity & Privilege Abuse | CVE-2025-32711 | EchoLeak, Microsoft 365 Copilot | 9.3 | Copilot Studio Connected Agents, CoPhish Attack, Copilot Studio Public-by-Default Agents |
| ASI04: Agentic Supply Chain Compromise | CVE-2025-6514 | MCP Remote RCE | 9.6 | Postmark MCP supply chain attack, Shai-Hulud Worm (npm ecosystem) |
| ASI05: Unexpected Code Execution | CVE-2025-53773 | GitHub Copilot YOLO Mode | 7.8 | - |
| ASI05: Unexpected Code Execution | CVE-2025-54135 | CurXecute, Cursor MCP auto-start | 8.6 | - |
| ASI05: Unexpected Code Execution | CVE-2025-54136 | MCPoison, Cursor | 7.2 | - |
| ASI05: Unexpected Code Execution | CVE-2025-59944 | Cursor Case-Sensitivity Bypass | - | - |
| ASI05: Unexpected Code Execution | - | Claude Desktop RCE | 8.9 | - |
| ASI05: Unexpected Code Execution | - | IDEsaster Research | - | 24 CVEs across multiple AI IDEs |

---

## Notes

- This document should be updated as new technologies are evaluated
  or as validation status changes
- Security CVEs should be monitored and patched according to severity
- All package versions in the blueprint are pinned to specific versions
  for stability
