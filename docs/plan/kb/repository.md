---
title: "Repository Structure"
owner: "DevOps"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

pnpm catalogs with Turborepo monorepo, strict package boundaries, OpenAPI codegen for types, TanStack Query with 5min staleTime and retry logic.

## Key Facts

### Monorepo

**Monorepo**: pnpm catalogs + Turborepo

- Strict boundary: packages/ui no import from features
- Spec validation CI gate

### Code Generation

**Codegen**: Type generation

- OpenAPI codegen, Supabase gen types
- pnpm codegen → packages/types/api + database
- MSW (Mock Service Worker)
- Supabase Connect tests

### Query Client

**QueryClient**: TanStack Query configuration

- staleTime: 5 minutes
- retry: 2
- noRefetchOnWindowFocus
- 429 → rate limit handling
- useSSE for real-time

## Why It Matters

- Monorepo enables code sharing and consistent builds
- Code generation ensures type safety across API boundaries
- TanStack Query provides efficient data fetching and caching

## Sources

- pnpm documentation
- Turborepo documentation
- OpenAPI specification
- TanStack Query documentation
