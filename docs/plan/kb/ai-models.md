---
title: "AI Models and Architecture"
owner: "AI/ML Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

Three-tier memory architecture (Zustand working, pgvector episodic/semantic), strict evaluation gates, cost attribution via Litellm tags, prompt caching for static content, OTel GenAI observability, and privacy controls with differential privacy.

## Key Facts

### Memory Architecture

**MemArch**: 3-tier system

- Working: Zustand (UI state)
- Episodic: Messages + pgvector, FIFO 50, Ebbinghaus decay
- Semantic: pgvector + facts, promotion to semantic layer

### Evaluation

**EvalCI**: Vitest + custom test suite

- Gate thresholds: accuracy ≥ base-2%, latency ≤ base+10%, tokens ≤ base+15%, tool ≥ 90%, hallucination ≤ 2%
- Blocks deployment if thresholds not met

### Context Window

**CtxWindow**: LLM token counter + `@CACHE`

- Prefix caching: static-first strategy
- RocketKV for long contexts

### Safety

**SafetyGuard**: Guardrails-AI + Pydantic validation

3-layer protection:

- Input: PII/jailbreak/toxicity detection
- Output: hallucination/safety/schema validation
- Runtime: tool/cost monitoring
- All logged for audit

### Cost Tracking

**CostAttrib**: x-litellm-tags org_id, user_id, feature

- ai_cost_log Timescale hypertable
- Alert tiers: 15%/5%/0% (critical)
- 429 hard stop on overage

### Prompt Caching

**PromptCache**: Anthropic cache_control + OAI auto-prefix

- Monitor hit rates: >70% chat, >90% RAG
- Static-first structure for optimal cache reuse

### Observability

**Observability**: OTel 1.40 GenAI semantic conventions

- DataPrepper root span propagation
- Attributes: gen_ai.system, model, input_tokens, output_tokens, finish_reason, cost.usd
- PII redaction applied

### Privacy

**Privacy**: Multi-layer privacy controls

- allow_training org flag
- Data segregation for opted-out users
- ODP differential privacy (ε configurable)
- TEE for sensitive processing
- Annual Privacy Impact Assessment

### Model Tiering

**MODEL_TIERING**: Default claude-sonnet-4-6-20250324, Complex claude-opus-4-6-20250324

- Never use claude-haiku-4-5 for agentic workflows (no injection guard)
- Migrate before June 15, 2026

### AI Gateway

**AI_GATEWAY**: Vercel AI SDK v6

- Provider routing
- Fallback chains
- Tool calling
- Structured output
- Streaming
- Wraps LiteLLM proxy
- Separate cost tracking

### OpenAI Responses API

**OPENAI_RESPONSES**: Assistants API + Chat Completions deprecated Aug 26, 2026

- Responses API: server-side context compaction
- Hosted shell containers (Python/Node/Ruby with storage)
- Reusable Skills
- Agentic execution loop
- Vercel AI SDK v6 gateway support

### Claude 4.6

**CLAUDE46**: claude-sonnet-4-6-20250324 default, claude-opus-4-6-20250324 complex

- claude-haiku-4-5 retired Apr 19, 2026
- No agentic Haiku (no injection guard)

### LangGraph

**LangGraph_Supervisor**: Maps FLOWC01 state machine

- Slightly underperforms swarm due to translation overhead
- Most generic architecture (fewest assumptions about sub-agents)
- Best for open-ended reasoning, iterative research, complex multi-turn dialogues
- Improvements: remove handoff messages, forward_message tool, tool naming optimization

### LangMem

**LangMem_Config**: Severe performance issues

- p95 search latency 59.82s on LOCOMO benchmark (not a typo)
- Accuracy 58.10% vs Mem0's 67.13% with 0.200s p95 latency
- NOT suitable for interactive user-facing agents
- Use for background/batch memory tasks only
- Mem0 recommended for interactive production agents (0.200s p95, 67.13% accuracy)
- Provides semantic (user facts), episodic (past interactions), procedural (self-updated system prompts - unique to LangMem)
- Requires embedding index (dims + embed model) for semantic search

### Trustcall

**Trustcall_Extraction**: Reliable structured data extraction using JSON patch operations

- Addresses LLM limitations with complex nested schemas
- Updates existing schemas without information loss
- Uses JSON patch to focus LLM on what has changed
- Increases extraction reliability without restricting JSON schema subset
- Use cases: complex schema extraction, memory management updates, simultaneous updates & insertions

### FastGraphRAG

**FastGraphRAG**: NLP-based, 16.7% cost (6x cheaper than conventional GraphRAG)

- Production-first approach
- Benchmarks: 96% perfect retrieval on 2wikimultihopQA vs 75% for GraphRAG
- 27x faster insertion
- LLM-based GraphRAG via feature flag at 500K tokens (dataset size threshold, not chunk count)

## Why It Matters

- Memory architecture balances immediate responsiveness with long-term learning
- Evaluation gates prevent regression in model performance
- Cost attribution enables per-feature ROI analysis
- Safety layers protect against prompt injection and data leakage
- Prompt caching significantly reduces costs for static content
- Observability enables debugging and optimization of AI interactions
- Privacy controls ensure compliance with GDPR and data protection regulations

## Sources

- Anthropic documentation on prompt caching
- OpenAI API deprecation notices
- OTel GenAI semantic conventions v1.40.0
- LangGraph and LangMem documentation
- FastGraphRAG research paper
