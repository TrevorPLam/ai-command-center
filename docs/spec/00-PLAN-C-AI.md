---
steering: TO PARSE - READ INTRO
document_type: ai_architecture
tier: infrastructure
description: AI system architecture including memory, safety, cost tracking, and observability
last_updated: 2026-04-25
version: 1.0
---

# AI - Artificial Intelligence Architecture

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
