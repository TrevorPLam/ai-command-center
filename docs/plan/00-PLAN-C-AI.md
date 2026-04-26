---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-C-AI.md
document_type: ai_architecture
tier: infrastructure
status: stable
owner: AI/ML Engineering
description: AI system architecture including Intent Dispatcher, memory, safety, cost tracking, and observability
last_updated: 2026-04-25
version: 2.0
dependencies: [00-PLAN-1-INTRO.md, 00-PLAN-C-KNOWLEDGE.md]
related_adrs: [ADR_004, ADR_028, ADR_030, ADR_035, ADR_036, ADR_058, ADR_063, ADR_065, ADR_067, ADR_077, ADR_079, ADR_082, ADR_086, ADR_087, ADR_089, ADR_093, ADR_094, ADR_095, ADR_096, ADR_097, ADR_098, ADR_099, ADR_100]
related_rules: [GRDL_01, GRDL_02, PRIV_01, STKB_01, YJS_01, NYLS_01, OTEL_01, OTEL_02]
complexity: high
risk_level: critical
---

# AI - Artificial Intelligence Architecture (Revised)

## Intent Dispatcher (New)

The **Intent Dispatcher** is a pure‑code middleware that sits between the AI orchestrator and the tool execution layer. Its job is to route every potential action to the **cheapest, fastest, most reliable executor** that can handle it.

- **Layer 1: Deterministic Code.** Database queries, rule engines, schema validators. Called directly by the orchestrator via a tool definition. No LLM involved in execution.
- **Layer 2: Lightweight Models (Haiku 4.5 or local).** Simple NLP tasks: extract structured data from an email, classify intent, summarize a short thread.
- **Layer 3: Powerful Models (Sonnet 4.6 / Opus 4.7).** Complex reasoning, multi‑step planning, open‑ended conversation.

The orchestrator (an LLM itself) selects tools. The dispatcher ensures each tool is executed optimally and that the orchestrator never wastes tokens on work that code can do.

### Example: Conflict Detection Flow
1. User says "Check for scheduling conflicts."
2. Orchestrator (Sonnet 4.6) decides to call the `detect_conflicts` tool.
3. Dispatcher sees `detect_conflicts` is a pure‑code function (overlap algorithm on DB records) → executes it directly, returns result.
4. Orchestrator formats a natural‑language response from the result.
**No Opus call. Only one Sonnet call for intent and formatting.**

### Configuration
- Tool definitions include a `preferred_executor` field (code, haiku, sonnet, opus).
- Run‑time cost and latency budgets can force fallback (e.g., code if under budget, else haiku).

---

// AI
MemArch|3-tier: Working(Zustand),Episodic(messages+pgvector,FIFO50,Ebbinghaus decay),Semantic(pgvector+facts,promotion)
EvalCI|Vitest+custom; gate: acc≥base-2%,lat≤base+10%,tok≤base+15%,tool≥90%,halluc≤2%
CtxWindow|LLM token counter+@CACHE; prefix caching static-first; RocketKV long contexts
SafetyGuard|Guardrails-AI+Pydantic; 3-layer: Input(PII/jailbreak/tox),Output(halluc/safety/schema),Runtime(tool/cost); all logged
CostAttrib|x-litellm-tags: org_id,user_id,feature; ai_cost_log TS hypertable; 15/5/0% alerts; 429 hard stop
PromptCache|Anthropic cache_control+OAI auto-prefix; monitor hit>70%chat/>90%RAG; static-first structure
Observability|OTel1.39 GenAI; DataPrepper root span prop; attrs: gen_ai.system/model/input_tokens/output_tokens/finish_reason/cost.usd; PII redact
Privacy|allow_training org flag; data segregation opted-out; ODP differential privacy(ε configurable); TEE for sensitive; annual PIA

## Memory Architecture

### Working Memory (Zustand)
- Short-term context storage
- Session-specific state
- Fast access, limited capacity

### Episodic Memory (PostgreSQL + pgvector)
- Message history with embeddings
- FIFO50 eviction policy
- Ebbinghaus decay algorithm
- Conversation context retrieval

### Semantic Memory (pgvector + Facts)
- Long-term knowledge storage
- Fact promotion system
- Vector similarity search
- Cross-session persistence

## Evaluation Pipeline

### Continuous Integration
- Vitest-based evaluation framework
- Custom evaluation metrics
- Automated CI gates

### Performance Thresholds
- **Accuracy**: ≥base-2% (blocking)
- **Latency**: ≤base+10% (warning), >20% (blocking)
- **Tokens**: ≤base+15% (warning)
- **Tool Precision**: ≥90% (blocking), <85% (fail)
- **Hallucination Rate**: ≤2% (blocking)

## Context Window Management

### Token Counting
- Real-time token tracking
- @CACHE integration
- Prefix caching optimization
- RocketKV for long contexts

### Caching Strategy
- Static content prioritized
- Dynamic content cached on demand
- Cache hit rate monitoring

## Safety & Guardrails

### Three-Layer Protection

#### Input Layer
- PII detection and filtering
- Jailbreak attempt detection
- Toxicity screening
- Content sanitization

#### Output Layer
- Hallucination detection
- Safety validation
- Schema compliance
- Content filtering

#### Runtime Layer
- Tool authorization
- Cost threshold enforcement
- Resource limits
- Audit logging

## Cost Attribution

### Multi-Level Tracking
- Organization level
- Team level
- User level
- Model level

### Alerting System
- 15% usage → admin alert
- 5% usage → admin + engineering alert
- 0% usage → 429 hard stop + CostLimitBanner

### Billing Integration
- x-litellm-tags for attribution
- ai_cost_log TimescaleDB hypertable
- Stripe token meter integration
- 30% markup for automation

## Prompt Caching

### Cache Control
- Anthropic cache_control headers
- OpenAI automatic prefix caching
- Static-first structure optimization

### Performance Monitoring
- Chat cache hit rate target: >70%
- RAG cache hit rate target: >90%
- Cache efficiency analytics

## Observability

### OpenTelemetry Integration
- OTel v1.39 GenAI specification
- DataPrepper root span propagation
- Standardized attribute naming

### Required Attributes
- gen_ai.system
- gen_ai.model
- gen_ai.usage.input_tokens
- gen_ai.usage.output_tokens
- gen_ai.usage.finish_reason
- gen_ai.usage.cost.usd

### Privacy Protection
- PII redaction at collector level
- Sensitive data filtering
- Compliance with data protection regulations

## Privacy & Compliance

### Training Controls
- Organization-level opt-out flags
- Data segregation for opted-out organizations
- Differential privacy (ε configurable)

### Security Measures
- Trusted Execution Environment (TEE) for sensitive data
- Annual Privacy Impact Assessment (PIA)
- GDPR compliance measures

### Data Handling
- Training data isolation
- Audit trail for all AI operations
- Secure data lifecycle management
