# Technical validation matrix

This document validates the major technology components selected for the AI Command Center platform with evidence from real-world implementations, benchmarks, and industry research.

---

## Core technology claims

### TypeScript 7.0 `tsgo`

- **Claim**: Microsoft ships native preview builds exposing `tsgo`, a Go-native
  compiler running alongside `tsc`. Benchmarks show 10x speed improvements,
  with projects reporting 9x faster typechecking.
- **Status**: Verified
- **Source**: Microsoft TypeScript preview builds

### pgvectorscale with DiskANN

- **Claim**: Timescale's extension achieves 28x lower p95 latency and 16x higher
  throughput vs. Pinecone's storage-optimized index on 50M Cohere embeddings.
- **Status**: Verified
- **Source**: Timescale pgvectorscale benchmarks

### APS (Agent Passport System) IETF Draft

- **Claim**: Defines Agent Passports (Ed25519), 7-dimension constraint lattice,
  3-signature chain, cascade revocation, Bayesian reputation, institutional
  governance, signed message envelopes, tool integrity signatures, nonce replay
  protection, trust levels L0-L4.
- **Status**: Draft specification
- **Source**: IETF draft for Agent Passport System

### LiveKit Agents v1.0.0

- **Claim**: Production-ready framework for building real-time, multimodal voice
  and video AI agents using WebRTC.
- **Status**: Production-ready
- **Source**: LiveKit official release

### Playwright AI Agents

- **Claim**: Three-agent architecture (Planner, Generator, Healer) for automated
  E2E test creation delivered in Playwright 1.56.0.
- **Status**: Released
- **Source**: Playwright 1.56.0 release notes

### Stripe Agent Toolkit

- **Claim**: `@stripe/agent-toolkit`, `@stripe/ai-sdk`, and `@stripe/token-meter`
  provide metered billing, middleware, and MCP-based Stripe access.
- **Status**: Available
- **Source**: Stripe developer documentation

### Orval CVE-2026-25141

- **Claim**: Critical CVSS 9.3 code injection via unsanitized
  `x-enum-descriptions`; fixed in 8.2.0.
- **Status**: Fixed in 8.2.0
- **Source**: CVE database, Orval security advisory

### DOMPurify XSS

- **Claim**: Versions 3.0.1-3.3.3 vulnerable to prototype pollution bypass
  (CVE-2026-41238).
- **Status**: Vulnerability identified, upgrade to ≥3.4.0 required
- **Source**: CVE database, DOMPurify security advisory

### React 20 Compiler / Vite 8 / Rolldown

- **Claim**: Vite 8 ships with Rust-based Rolldown as default bundler; React
  Compiler support via `@rolldown/plugin-babel`.
- **Status**: Released
- **Source**: Vite 8 release notes, React Compiler documentation

### Turborepo 2.x

- **Claim**: `pipeline` renamed to `tasks`; task graph-based scheduling with
  topological ordering.
- **Status**: Released
- **Source**: Turborepo 2.0 migration guide

### A2A v1.0

- **Claim**: Google's protocol with Agent Cards, decentralized discovery, and
  cryptographic identity primitives.
- **Status**: Released
- **Source**: Google A2A protocol documentation

### Tailwind CSS v4

- **Claim**: CSS-first configuration via `@theme` directive for design tokens.
- **Status**: Released
- **Source**: Tailwind CSS v4 documentation

### Zustand v5

- **Claim**: Lightweight state management with improved comparison mechanisms
  and `useShallow`.
- **Status**: Released
- **Source**: Zustand v5 release notes

### Claude Opus 4.7

- **Claim**: Scores 87.6% on SWE-bench Verified, 94.2% on GPQA Diamond, 64.4% on
  Finance Agent. New xhigh effort level (coding default), task budgets in
  public beta, tokenizer multiplier 1.0-1.35×.
- **Status**: Released
- **Source**: Anthropic model card, benchmark results

### EU AI Act

- **Claim**: Current statutory deadline August 2, 2026 for majority of rules.
  Proposed Digital Omnibus extension (pending Council approval as of April
  2026) would delay high-risk obligations to December 2, 2027 (stand‑alone
  high‑risk) / August 2, 2028 (embedded high‑risk). Articles 9-15 mandate
  extensive documentation.
- **Status**: Legislative process ongoing
- **Source**: EU AI Act official documentation

### OpenTelemetry `gen_ai`

- **Claim**: Semantic conventions for agentic systems (agents, tasks, teams,
  artifacts) with Datadog native support.
- **Status**: Released
- **Source**: OpenTelemetry specification, Datadog documentation

### MACH Alliance

- **Claim**: Microservices, API-first, Cloud-native, Headless principles; launched
  AI Exchange in April 2025.
- **Status**: Active
- **Source**: MACH Alliance official announcements

### Decision Velocity

- **Claim**: Defined as speed × accuracy × effectiveness; emerging metric for
  AI ROI.
- **Status**: Concept
- **Source**: Industry research on AI ROI metrics

### Semantic Layer

- **Claim**: MATRIX ontology for multi-agent shared memory; knowledge graph
  integration for cross-agent communication.
- **Status**: Concept
- **Source**: Research on multi-agent systems

### TanStack DB 0.6

- **Claim**: SQLite-backed persistence, offline support, hierarchical data
  projection, query-driven sync with PowerSync and ElectricSQL.
- **Status**: Released
- **Source**: TanStack DB documentation

---

## Security Vulnerability References

### MCP Security Issues

- **CVE-2025-6514**: mcp-remote command injection (CVSS 9.6, 437K+ downloads)
- **CVE-2026-23744**: MCPJam Inspector RCE
- **CVE-2025-49596**: MCP Inspector RCE
- **Total**: 30 CVEs disclosed in 60 days (Jan-Feb 2026), 13 rated critical by
  Vulnerable MCP Project
- **Mitigation**: CIS MCP Companion Guide (released April 21, 2026) provides
  practical guidance

### OWASP ASI CVE Mapping (April 2026)

- **ASI01: Agent Goal Hijack** - CVE-2025-32711 (EchoLeak, Microsoft 365
  Copilot, CVSS 9.3), CVE-2025-53773 (GitHub Copilot YOLO Mode, CVSS 7.8),
  CVE-2025-64660 (AGENTS.MD Hijacking in VS Code), CVE-2025-61590
  (AGENTS.MD Hijacking in VS Code)
- **ASI02: Tool Misuse & Exploitation** - CVE-2025-8217 (Amazon Q Code
  Assistant, CVSS 7.8), CVE-2025-34291 (Langflow AI RCE)
- **ASI03: Identity & Privilege Abuse** - CVE-2025-32711 (EchoLeak, Microsoft
  365 Copilot, CVSS 9.3); incidents: Copilot Studio Connected Agents,
  CoPhish Attack, Copilot Studio Public-by-Default Agents
- **ASI04: Agentic Supply Chain Compromise** - CVE-2025-6514 (MCP Remote
  RCE, CVSS 9.6); incidents: Postmark MCP supply chain attack,
  Shai-Hulud Worm (npm ecosystem)
- **ASI05: Unexpected Code Execution** - CVE-2025-53773 (GitHub Copilot YOLO
  Mode, CVSS 7.8), CVE-2025-54135 (CurXecute, Cursor MCP auto-start, CVSS
  8.6), CVE-2025-54136 (MCPoison, Cursor, CVSS 7.2), CVE-2025-59944
  (Cursor Case-Sensitivity Bypass), Claude Desktop RCE (CVSS 8.9),
  IDEsaster Research (24 CVEs across multiple AI IDEs)

---

## Notes

- This document should be updated as new technologies are evaluated or as
  validation status changes
- Security CVEs should be monitored and patched according to severity
- All package versions in the blueprint are pinned to specific versions for
  stability
