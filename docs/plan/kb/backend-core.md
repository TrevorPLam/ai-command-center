---
title: "Backend Core Architecture"
owner: "Backend Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

FastAPI project structure with Service-Repository pattern, WorkflowEngine with topological sort and state machine, RAG with LangChain and pgvector, Google A2A for agent communication, MCP with policy evaluation and OAuth.

## Key Facts

### FastAPI Project

**FastAPI_Proj**: Project structure

- app/main.py, routers/v1/*, services/*, dependencies.py, middleware/*
- Modules: A2A, Saga, RAG, Cost, MCP, SSRF, Privacy

### Service Repository Pattern

**ServiceRepo**: Route → Service → Repository (SQLModel)

- Dependency injection via FastAPI dependencies
- Compensation queue + dead-letter queue
- Webhook async queue

### Workflow Engine

**WorkflowEngine**: Orchestration

- Topological sort
- State machine
- Parallel execution
- Exponential backoff
- Compensation transactions
- Incremental Clocks
- Dead-letter queue after 3 retries

### RAG

**RAG**: Retrieval-Augmented Generation

- LangChain, pgvector, Edge Functions
- Pipeline: ingest → chunk (512 tokens, 64 overlap) → embed → HNSW → hybrid RRF → rerank → cache
- RLS at database level

### Agent-to-Agent

**A2A**: Google Agent-to-Agent v1.0

- Agent Card discovery
- Task state machine
- SSE streaming
- Artifact handling
- Agent Registry

### MCP Integration

**MCP**: Model Context Protocol

- Policy evaluation (allow/deny/approve)
- OAuth authentication
- Schema allowlist
- Elicitation detection
- SSRF protection
- Sandbox isolation
- CI TrustKit validation
- Audit logging

## Why It Matters

- Service-Repository pattern separates business logic from data access
- Workflow engine enables reliable distributed transactions
- RAG enables AI to access domain knowledge
- A2A enables agent collaboration
- MCP provides secure AI tool integration

## Sources

- FastAPI documentation
- LangChain documentation
- Google A2A specification
- MCP specification
