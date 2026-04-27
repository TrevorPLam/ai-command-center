---
title: "Technology Updates and Releases"
owner: "Architecture"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

React 20 GA March 2026 with built-in compiler, TypeScript 6.0/7.0 with Go-native compiler, Prisma Next TypeScript-native ORM, Vercel Edge Functions no DB, Deno 2.0 full npm compatibility, OTel GenAI v1.40.0 experimental.

## Key Facts

### React 20

**REACT20**: GA March 2026

- Compiler built-in default (no opt-in)
- useMemo/useCallback/React.memo deprecated
- "use no memo" still needed for RHF, Zustand persist
- Concurrent Rendering 2.0

### React Compiler

**REACT_COMPILER_STABLE**: Includes existing useMemo/useCallback

- Skips some modules
- Use eslint-plugin-react-compiler
- Audit Q2 2026

#### React Compiler ESLint

**REACT_COMPILER_ESLINT**: eslint-plugin-react-compiler deprecated

- Users should use eslint-plugin-react-hooks@latest instead
- Linting functionality integrated into eslint-plugin-react-hooks
- New lint rules: set-state-in-render, set-state-in-effect, refs
- Does not require compiler to be installed

#### React Compiler Compatibility

**REACT_COMPILER_COMPAT**: Only compile own source code

- Do NOT compile 3rd-party code
- Library authors have full control over whether to use React Compiler or manually optimize
- Some third-party library hooks return new objects on every render, breaking memoization chains: TanStack Query's useMutation(), Material UI's useTheme(), React Router's useLocation()
- Libraries should be designed to be memoize-able for non-hook usage and provide hooks as static functions

### TypeScript 6.0/7.0

**TYPESCRIPT_67**: TS6.0 (March 23, 2026)

- Final JS release
- erasableSyntaxOnly, isolatedDeclarations, strict defaults

**TS7.0 Beta** (April 2026)

- Go-native (tsgo) ~10x faster
- CI-ready now

### Prisma Next

**PRISMA_NEXT**: TypeScript-native ORM

- Postgres GA June-July 2026
- Schema in TypeScript
- pgvector extension
- 12-month Prisma 7 LTS
- Phase 3 evaluation

### Vercel Edge

**VERCEL_EDGE_NO_DB**: Edge Functions limitations

- Run V8 isolates
- No Node.js runtime
- No direct TCP DB connections
- Use Neon serverless driver (HTTP), Vercel Serverless (300s), or FastAPI proxy

### Deno Runtime

**DENO_RUNTIME**: Deno 2.0 full npm compatibility

- npm: specifier for npm packages
- CommonJS support (.cjs, package.json type, auto-detect)
- Node built-ins require node: prefix
- Native C++ modules (bcrypt, sharp, sqlite3) fail - use pure JS alternatives (bcryptjs, Deno KV)
- File system APIs differ but npm:fs works

### OTel GenAI

**OTEL_GENAI**: v1.40.0 released Feb 2026 (commit 7fe5373)

- Status: Experimental/Development as of March 2026
- gen_ai.* namespace
- Use OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental for opt-in
- Default emits v1.36.0 or prior
- Track gen_ai.conversation.id (string, conversation/session/thread correlation)
- NO production readiness timeline - transition plan will be updated before marking stable (no date provided)
- Not production-ready for stable adoption

### Temporal

**TEMPORAL_SAFARI**: Stage 4 ES2026 (March 2026)

- Chrome 144+, Firefox 139+
- Safari not yet supported
- Polyfill mandatory (temporal-polyfill)
- Conditional import
- Bundle impact 8KB

**TEMPORAL_API**: ES2026

- `@rrulenet/recurrence` candidate
- Phase 2 evaluation

**TEMPORAL_ZD_REQUIRED**: Always Temporal.ZonedDateTime for calendar events

- Never PlainDateTime

### Google A2A v1

**A2A_V1**: Google Agent-to-Agent v1.0

- Linux Foundation
- 150+ organizations production
- Stable .proto
- Three-layer architecture

### Supabase Edge Functions

**SB_EF**: Deno runtime

- npm: prefix
- Pre-bundled
- Cold start 400ms median, hot 125ms median
- Use for webhooks + async

### React Router v7

**RRV7**: Imports from react-router (merged)

- nuqs adapter v7
- Library mode
- No react-router-dom

### React Flow v12

**RF12**: `@xyflow/react` import

- node.measured replaces node.width/height for layout (dagre/elk)

### Expo SDK 55

**EXPO55**: New Architecture mandatory

- expo-av removed
- Notifications config plugin required
- Reanimated v4 incompatible with NativeWind → pin v3

### Claude 4.6

**CLAUDE46**: Model updates

- claude-sonnet-4-6-20250324 default
- claude-opus-4-6-20250324 complex
- claude-haiku-4-5 retired Apr 19 2026
- No agentic Haiku

### ES2026 Features

**ES2026_MATCH**: match expression (declarative pattern matching), using keyword (resource cleanup), Promise.try, Error.isError, Math.sumPrecise, Uint8Array base64/hex, Iterator helpers

### OWASP Agentic

**OWASP_ASI2026**: Agentic Top 10

- ASI01 Goal Hijack
- ASI02 Tool Misuse
- ASI03 Identity Abuse
- Map to GRDL layers, SECM controls

### pgvector-scale

**PGVECTORSCALE**: 0.4.0 DiskANN

- 50M vectors: 471 QPS, 28ms p95
- 11.4x Qdrant, 28x Pinecone latency
- 75% cheaper
- Threshold reduced to 500K vectors

### Prisma Savepoints

**PRISMA_SAVEPOINT**: v7.8.0+ nested transaction savepoints

- Saga rollback via savepoint release

## Why It Matters

- React 20 compiler changes optimization patterns
- TypeScript 7.0 Go-native compiler improves CI speed
- Prisma Next provides type-safe ORM
- Edge Functions have limitations requiring architecture adjustments
- Deno 2.0 npm compatibility simplifies dependency management
- OTel GenAI provides AI observability but still experimental

## Sources

- React 20 release notes
- TypeScript 6.0/7.0 release notes
- Prisma documentation
- Vercel Edge Functions documentation
- Deno 2.0 release notes
- OTel GenAI documentation
