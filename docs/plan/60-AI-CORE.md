---
title: "AI Core"
owner: "AI/ML Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

This document describes the complete AI architecture including intent dispatcher, local-first gateway, verifier cascade, memory architecture, evaluation pipeline, safety guardrails, cost attribution, prompt caching, observability, local model infrastructure, workflow engine, analytics, and model cards.

---

## AI & Model Rules

These control which models are used, how they are secured, and how their performance is evaluated.

For the complete rule definitions, see [00-RULES.yaml](00-RULES.yaml).

### Model selection & routing

- #AI-01: Default orchestrator: Gemma 4 E2B (local, native tool calling). Fallback: Qwen3.5 4B. Cloud models are premium only
- #AI-02: Free-tier users are restricted to local models only; AI must never make cloud API calls for them
- #AI-03: Claude Sonnet 4.6 is the default cloud model when authorised; Opus 4.7 for complex tasks
- #AI-04: Haiku 4.5 must never be used under any circumstances
- #AI-05: All new agents created after May 1, 2026 must use claude-sonnet-4-6 or opus-4-7 model IDs; legacy IDs cleaned by June 1, 2026
- #AI-06: OpenAI Assistants and ChatCompletions APIs must be migrated to the Responses API by August 26, 2026

### Guardrails (3-layer, all HARD)

- #AI-07: Input guardrails: PII detection, jailbreak detection, toxicity screening
- #AI-08: Output guardrails: Hallucination detection, safety validation, schema enforcement
- #AI-09: Runtime guardrails: Tool authorization and cost threshold checks
- #AI-10: All guardrail decisions are logged to audit_logs

### Cost & Budgets (all HARD)

- #AI-11: Synchronous pre-call budget check enforced at the LiteLLM proxy; if budget exceeded, return 429 and a cost limit banner
- #AI-12: Multi-level budgets: org, team, user, model
- #AI-13: Alert thresholds: at 15% remaining notify admin; at 5% notify admin + engineering; at 0% hard stop
- #AI-14: ai_cost_log is a TimescaleDB hypertable; x-litellm-tags carry org_id, user_id, feature

### Evaluation (HARD in CI)

- #AI-15: DeepEval for AI evaluation; RAGAS alongside for RAG
- #AI-16: Tool-calling precision >=90% (block if <85%)
- #AI-17: Hallucination rate <=2%
- #AI-18: Accuracy >= base-2%
- #AI-19: Latency <= base+10% (warn), >20% block
- #AI-20: Token usage <= base+15% (warn)
- #AI-21: All evaluator LLM-as-judge calls go through the LiteLLM proxy for cost tracking

### Caching & Context

- #AI-22: Prompt caching enabled; static content cached first
- #AI-23: Chat cache hit rate target >70%, RAG cache hit rate >90%
- #AI-24: Contextual Retrieval activated only when corpus >50K chunks, precision improvement >15%, and cache hit rate >60%

### Local model lifecycle

- #AI-25: All local models must be registered in the Model Trust Registry before use in agentic workflows
- #AI-26: Model quantisation: default GGUF Q4_K_M (<4.5 GB RAM); evaluated weekly for tool-calling pass rate
- #AI-27: The Verifier cascade (Phi-4-mini-reasoning) checks reasoning, schema validity, and budget before an action is committed (Phase 1)

---

## Section 1: AI Architecture

### Intent dispatcher

The **Intent Dispatcher** is a pure-code middleware that sits between the AI orchestrator and the tool execution layer. Its job is to route every potential action to the **cheapest, fastest, most reliable executor** that can handle it.

- **Layer 1: Deterministic Code.** Database queries, rule engines, schema validators. Called directly by the orchestrator via a tool definition. No LLM involved in execution.
- **Layer 2: Lightweight Models (Qwen 3.5 4B or local).** Simple NLP tasks: extract structured data from an email, classify intent, summarize a short thread.
- **Layer 3: Powerful Models (Sonnet 4.6 / Opus 4.7).** Complex reasoning, multi-step planning, open-ended conversation.

The orchestrator itself (an LLM) uses this dispatcher to execute tools efficiently.

### Local-first gateway extension

The multi-provider AI gateway is extended with a **local execution tier** as the default route. Every model definition now includes:
- `execution_location`: `local` | `cloud` | `hybrid`
- `privacy_tier`: `sovereign` | `shared` | `third_party`

**Default routing policy (Phase 0):**
1. Gemma 4 E2B/E4B (local) - orchestrator
2. Qwen3.5 4B (local) - tool executor, 97.5% tool-calling accuracy
3. Phi-4-mini-reasoning (local) - verifier (Phase 1)
4. Claude Sonnet 4.6 (cloud) - paid tier only, for tasks exceeding local capability
5. Claude Opus 4.7 (cloud) - premium tier only, for complex multi-step reasoning

### Verifier cascade

Before any agentic action is committed, a lightweight local verifier model (Phi-4-mini-reasoning) performs a structured check:
1. **Reasoning soundness**: Was the orchestrator's plan coherent?
2. **Schema validity**: Does the proposed tool call match the tool's JSON schema?
3. **Permission budget**: Is the action within the user's role and cost limits?

All verifier decisions are logged to `audit_logs`. Verifier model is evaluated monthly; if accuracy drops below 90%, it is retrained or replaced.

### Updated cost model

| Execution Mode | Cost Model | Marginal Cost | Used By |
|----------------|------------|---------------|---------|
| Local CPU (Ollama/llama.cpp) | Fixed: electricity + hardware amortization | ~$0.00001/1K tokens | Free tier default |
| Self-hosted GPU (vLLM) | Fixed: GPU amortization + electricity | ~$0.0001/1K tokens | Team tier with dedicated hardware |
| Cloud API (Claude/Gemini) | Variable: per-token pricing | $3-$75/1M tokens | Paid tiers only |

### Model trust registry

A structured catalog of all models (local and cloud) with attested capabilities:
- Tool-calling pass rate (from automated test suite)
- Hallucination rate on evaluation datasets
- Latency profiles (TTFT, TPS) on target hardware
- Security audit status (for cloud models)
- Last verification date

All models must be registered before they can participate in agentic workflows. The registry is part of Agent Studio.

### Example: Conflict detection flow
1. User says "Check for scheduling conflicts."
2. Orchestrator (Sonnet 4.6) decides to call the `detect_conflicts` tool.
3. Dispatcher sees `detect_conflicts` is a pure-code function (overlap algorithm on DB records) → executes it directly, returns result.
4. Orchestrator formats a natural-language response from the result.
**No Opus call. Only one Sonnet call for intent and formatting.**

### Configuration
- Tool definitions include a `preferred_executor` field (code, haiku, sonnet, opus).
- Run-time cost and latency budgets can force fallback (e.g., code if under budget, else haiku).

---

## Section 2: Memory Architecture

| Type | Storage | Eviction | Purpose |
|------|---------|----------|---------|
| Working memory | Zustand | Session end | Short-term context, session state |
| Episodic memory | PostgreSQL + pgvector | FIFO50 | Message history with embeddings, conversation context |
| Semantic memory | pgvector + Facts | None | Long-term knowledge, fact promotion, cross-session persistence |

---

## Section 3: Evaluation Pipeline & CI Gates

### Continuous integration
- Vitest-based evaluation framework
- Custom evaluation metrics
- Automated CI gates

### Evaluation data (Golden dataset curation)

**Dataset Size Guidelines:**
- Modest use cases: 10-20 examples
- Complex applications: 100-200 diverse examples
- High-quality data reduces required size
- Selection strategies regress to random beyond 30-40 examples

### Performance thresholds
- **Accuracy**: ≥base-2% (blocking)
- **Latency**: ≤base+10% (warning), >20% (blocking)
- **Tokens**: ≤base+15% (warning)
- **Tool Precision**: ≥90% (blocking), <85% (fail)
- **Hallucination Rate**: ≤2% (blocking)

### Test outcomes

#### Three-valued verdicts

For non-deterministic AI agent testing, traditional binary pass/fail verdicts are insufficient. AgentAssay introduces three-valued probabilistic outcomes backed by statistical confidence intervals.

**Verdict Types**:

- **Pass**: Lower bound of confidence interval ≥ threshold
- **Fail**: Upper bound of confidence interval < threshold
- **Inconclusive**: Confidence interval straddles threshold (insufficient evidence)

#### Inconclusive rate analysis

**Causes of Inconclusive Results**:

1. **Insufficient Sample Size**: Too few trials to distinguish signal from noise
   - Example: n=50 trials, p̂=0.90, θ=0.85, α=0.05 → CI: [0.789, 0.958] → Inconclusive
   - At n=100 with same p̂=0.90 → CI: [0.826, 0.946] → Still Inconclusive
   - At n=200 with same p̂=0.90 → CI: [0.853, 0.935] → Pass

2. **High Behavioral Variance**: Agents with high coefficient of variation (CV) require more samples
   - Experimental data shows CV range of 19-62% across models
   - High-variance scenarios need adaptive budget optimization

3. **Threshold Proximity**: Observed pass rate close to decision boundary
   - When p̂ ≈ θ, confidence interval naturally straddles threshold
   - Requires more trials to resolve

**Statistical Properties**:

- **Type I Error Control**: ℙ[V=Pass | p<θ] ≤ α
- **True Pass Rate Guarantee**: p ≥ θ - ε(n) with probability ≥ 1-α, where ε(n) = O(1/√n)
- **Confidence Interval Method**: Wilson score bounds (or Clopper-Pearson for formal bounds)

#### Mitigation strategies

**1. Sequential Probability Ratio Test (SPRT)**

Adaptive stopping that reduces inconclusive rates by terminating early when evidence is clear:

- Expected trials under H₀ (agent fine): 52 trials (52% savings vs n=109 fixed)
- Expected trials under H₁ (agent regressed): 34 trials (69% savings)
- Optimality: Minimizes expected trials among all sequential tests with error bounds (α, β)

**2. Adaptive Budget Optimization**

No fixed trial counts. AgentAssay:
- Runs calibration set (5-10 trials)
- Measures behavioral variance
- Computes minimum trials needed for target confidence level
- High-variance scenarios get more trials, stable scenarios get fewer

**3. Behavioral Fingerprinting**

Instead of comparing raw text outputs (high-dimensional, noisy), extracts compact behavioral fingerprints:
- Tool sequences
- State transitions
- Decision patterns
- Low-dimensional signals requiring fewer samples to detect change

**Detection Power Improvement**:
- Fixed-n and SPRT-only testing: power = 0.00 (detects no behavioral changes)
- SPRT + Fingerprinting: power = 0.86 across all scenarios
- Multivariate Hotelling's T² test provides strictly higher detection power per sample

**4. Trace-First Offline Analysis**

Coverage metrics, contract checks, metamorphic relations, and mutation analysis run on production traces at zero additional token cost:

- Zero-cost testing using existing execution data
- Power = 0.98 across all scenarios
- Detects nearly all behavioral variations without live agent executions
- Formal soundness guarantees for coverage, contract, and metamorphic analyses

**5. CI Gate Configuration**

Inconclusive verdicts map to manual review rather than automatic blocking:

- Exit code 2: manual/inconclusive (configurable as warning vs hard failure)
- Teams may accept inconclusive results with human oversight
- Audit logs track all override decisions with justification
- Recommended n_max=30 with SPRT for CI pipelines (adequate power for δ ≥ 0.15 at α=0.05)

---

## Section 4: Safety & Guardrails

### Three-layer protection

#### Input layer
- PII detection and filtering
- Jailbreak attempt detection
- Toxicity screening
- Content sanitization

#### Output layer
- Hallucination detection
- Safety validation
- Schema compliance
- Content filtering

#### Runtime layer
- Tool authorization
- Cost threshold enforcement
- Resource limits
- Audit logging

---

## Section 5: Cost Attribution & Prompt Caching

### Multi-level tracking
- Organization level
- Team level
- User level
- Model level

### Alerting system
- 15% usage → admin alert
- 5% usage → admin + engineering alert
- 0% usage → 429 hard stop + CostLimitBanner

### Billing integration
- x-litellm-tags for attribution
- ai_cost_log TimescaleDB hypertable
- Stripe token meter integration
- 30% markup for automation

### Prompt caching

#### Cache control
- Anthropic cache_control headers
- OpenAI automatic prefix caching
- Static-first structure optimization

#### Performance monitoring
- Chat cache hit rate target: >70%
- RAG cache hit rate target: >90%
- Cache efficiency analytics

---

## Section 6: Observability & Privacy

### OpenTelemetry integration
- OTel v1.40.0 GenAI specification (released Feb 2026, commit 7fe5373)
- **Status**: Experimental/Development (as of March 2026)
- DataPrepper root span propagation
- Standardized attribute naming
- **Stability Opt-In**: Use `OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental` to emit latest experimental conventions
- **Default Behavior**: Continues emitting v1.36.0 or prior conventions by default
- **Transition Plan**: Will be updated to include stable version before GenAI conventions are marked as stable (no timeline provided)
- **Production Readiness**: Not production-ready for stable adoption; experimental conventions suitable for testing and early adoption with opt-in

### Required attributes
- gen_ai.system
- gen_ai.model
- gen_ai.usage.input_tokens
- gen_ai.usage.output_tokens
- gen_ai.usage.finish_reason
- gen_ai.usage.cost.usd

### Conversation tracking
- **Attribute**: `gen_ai.conversation.id` (string type)
- **Purpose**: Unique identifier for a conversation (session, thread), used to store and correlate messages within this conversation
- **Example**: `conv_5j66UpCpwteGg4YSxUnt7lPY`
- **Usage**: Set this attribute on all spans related to the same conversation to enable correlation across multiple LLM calls and tool executions

### Privacy protection
- PII redaction at collector level
- Sensitive data filtering
- Compliance with data protection regulations

### Training controls
- Organization-level opt-out flags
- Data segregation for opted-out organizations
- Differential privacy (ε configurable)

### Security measures
- Trusted Execution Environment (TEE) for sensitive data
- Annual Privacy Impact Assessment (PIA)
- GDPR compliance measures

### Data handling
- Training data isolation
- Audit trail for all AI operations
- Secure data lifecycle management

---

## Section 7: Local Model Infrastructure

### Serving stack (Phase 0)

- **Primary**: Ollama (≥0.5.0) - OpenAI-compatible API, native tool calling support, model management, Metal/CUDA/CPU backends. 52M+ monthly downloads.
- **Backend**: llama.cpp (March 2026, 100K GitHub stars) - GGUF quantization, speculative decoding, CPU-optimized.
- **Orchestration**: Docker Compose for reproducible local environments. Bifrost (model gateway) evaluated for Phase 2.
- **Fallback**: LiteLLM proxy already routes cloud API calls when local model is unavailable or insufficient.

### Model registry

| Field | Description |
|-------|-------------|
| model_id | Unique identifier (e.g., `gemma-4-e2b`) |
| parameter_count | Active parameters (e.g., 2B) |
| quantization_format | GGUF Q4_K_M, GGUF Q8_0, ternary (future) |
| memory_requirement | RAM needed for inference (e.g., 3.4 GB) |
| tool_calling_tier | native (special tokens), prompt (needs prompt engineering), unreliable |
| verified_tool_call_pass_rate | From automated test suite |
| latency_profile | TTFT, TPS on target hardware tiers |
| evaluation_date | Last benchmark run |
| status | active, deprecated, sunset |

**Initial Phase 0 models:**

| Model | Size | Tool Calling | Role |
|-------|------|--------------|------|
| Gemma 4 E2B | 2B active | Native tokens | Default orchestrator (light hardware) |
| Gemma 4 E4B | 4.5B dense | Native tokens | Default orchestrator (≥16GB RAM) |
| Qwen3.5 4B | 3.4 GB (Q4_K_M) | 97.5% pass rate | Tool executor |
| Phi-4-mini-reasoning | 3.8B | Prompt | Verifier (Phase 1) |
| Llama4-7B | 7B (MoE) | Prompt | High-throughput chat (optional) |

### Quantization policy

| Format | Memory | Status | Use Case |
|--------|--------|--------|----------|
| GGUF Q4_K_M | <4.5GB | Default | Human reading speed on CPU |
| GGUF Q8_0 | Higher | Available | Higher accuracy |
| Ternary (FairyFuse) | TBD | Future | Per-layer sensitivity optimization |
| QIGen | Variable | Optional | Non-uniform quantization for specific models |

### Hardware tiers

| Tier | Requirements | Typical Setup | Target Models |
|------|--------------|---------------|---------------|
| **Tier 1 (CPU-only)** | AVX2, 16GB RAM, single NUMA node | Intel i7-12800H, Mac Mini M2 | Gemma 4 E2B, Qwen3.5 4B |
| **Tier 2 (GPU-accelerated)** | RTX 3060+ / Apple M2+ 16GB | Workstation with 12GB+ VRAM | Gemma 4 E4B, Llama4-7B |
| **Tier 3 (Server)** | Multi-core Xeon, 32GB+ RAM, multi-NUMA (Phase 2) | Fly.io performance nodes | Multi-model concurrent serving |

**NUMA consideration**: For Phase 0, deploy on single-NUMA-node machines (Fly.io shared-cpu-1x is fine). For Phase 2+, ArcLight NUMA-aware orchestration may be configured for multi-socket servers.

### Model lifecycle pipeline

1. **Pull**: Download model from HuggingFace/Ollama registry with SHA-256 verification.
2. **Quantize** (if needed): Convert to GGUF Q4_K_M using llama.cpp tools.
3. **Register**: Populate model registry with capability scores (automated eval harness, lm-evaluation-harness or custom).
4. **Serve**: Deploy via Ollama. Health check `GET /api/tags`.
5. **Update**: New model version → parallel deployment → capability re-benchmark → traffic shift → deprecate old version after grace period.
6. **Sunset**: Notify users 30 days before model removal. Auto-migrate to successor model if compatible.

### Verifier cascade (Phase 1)

A lightweight local model (Phi-4-mini-reasoning) performs pre-action validation:
1. **Reasoning check**: Is the orchestrator's plan consistent with the user intent?
2. **Schema check**: Does the tool call match the JSON schema exactly?
3. **Budget & permission check**: Is the action within the user's plan limits?

Verifier decisions are logged to `audit_logs` with confidence score. If verifier rejects, the orchestrator is re-prompted with feedback.

### Fine-tuning pipeline (Phase 2)

- **Primary tool**: Unsloth (2× faster training, 70% less VRAM). QLoRA adapters.
- **CPU-only alternative**: LoFT CLI for small models (1-3B), exports to GGUF.
- **Apple Silicon**: MLX-LM (Apple's MLX framework) for local fine-tuning on Mac.
- **Use cases**: Domain-specific task models, per-organization style adaptation, user-personalised agent behavior (LoRA adapters loaded dynamically).

### Distributed inference (Phase 3+)

- **Prima.cpp** (ICLR 2026): 30-70B models on home clusters with mixed CPUs/GPUs, Wi-Fi links. 26 TPS on 32B model with speculative decoding.
- **Mesh LLM** (GitHub, 2026): Pools spare GPU capacity, OpenAI-compatible API.
- **Goal**: Serve larger models (8-32B) across multiple on-premise or edge devices, reducing reliance on cloud even for complex tasks.

### Model evaluation harness

All models undergo automated testing before registration:
- Tool-calling pass rate (schema-aware deterministic scoring, 40+ test cases)
- Hallucination rate on TruthfulQA or equivalent
- Latency (TTFT, TPS) on target Tier 1/2 hardware
- Multi-tool chaining success rate (Phase 1)

Results stored in model registry. Evaluations rerun weekly for active models, triggered by CI.

### Security & supply chain

- Model downloads verified with SHA-256 or Sigstore signatures.
- GGUF conversion done in sandboxed environment.
- No model execution in production without registry entry.
- Local models isolated from internet by default; no telemetry sent.
- Cloud fallback requires explicit user opt-in (paid tier).

### Integration with dispatcher

The Intent Dispatcher queries the model registry to route tasks:
- `preferred_executor` field in tool definitions maps to model tiers.
- Dispatcher checks registry for model availability and capability before routing.
- If preferred local model is unavailable or below confidence threshold, dispatcher escalates to cloud (if authorized) or returns "task too complex for current plan" error.

### Open questions

- How often to re-benchmark models (weekly? per-update? continuous?).
- Policy for user-installed third-party models (app store model?).
- Handling of Apple Silicon vs. Intel-specific quantization (Metal vs. AVX2).
- Full migration timeline to ternary (FairyFuse) if llama.cpp integrates it.

---

## Section 8: Workflow Engine

### LangGraph integration

- **Pattern**: Supervisor pattern maps to FLOWC01 state machine
- **Transitions**: StateGraph edges for state transitions
- **State Management**: Deterministic state transitions with checkpointing

### Memory management

#### LangMem

- **Purpose**: Cross-session summarization with semantic, episodic, and procedural memory
- **Replacement**: Replaces simple FIFO memory
- **Storage**: Episodic memory tier for long-term context retention
- **Memory Types**:
  - Semantic: User preferences and factual knowledge (e.g., "user works in Pacific time, prefers Python examples")
  - Episodic: Past interactions distilled as few-shot examples (e.g., "last time the agent solved X by doing Y")
  - Procedural: Updated system instructions the agent writes to itself (e.g., "always confirm before deleting") - unique to LangMem
- **Performance Issues**: TASK INFORMATION INCORRECT - LangMem has severe performance limitations:
  - p95 search latency: 59.82 seconds on LOCOMO benchmark (not a typo)
  - Accuracy: 58.10% on LOCOMO vs Mem0's 67.13% with 0.200s p95 latency
  - NOT suitable for interactive user-facing agents due to extremely high latency
- **Recommended Use**: Background/batch memory tasks or non-latency-sensitive applications only
- **Alternative**: Mem0 (0.200s p95, 67.13% LOCOMO accuracy) for interactive production agents requiring sub-second memory retrieval
- **Configuration**: Requires embedding index (dims + embed model) for semantic search; store.search() returns nothing without it
- **Code Example**:
```python
from langmem import create_manage_memory_tool, create_search_memory_tool
from langgraph.store.memory import InMemoryStore
from langgraph.prebuilt import create_react_agent

# Embedding index REQUIRED for semantic search
store = InMemoryStore(
    index={
        "dims": 1536,
        "embed": "openai:text-embedding-3-small",
    }
)

# Namespace under user ID (NOT thread_id)
manage_memory = create_manage_memory_tool(namespace=("user-123",))
search_memory = create_search_memory_tool(namespace=("user-123",))

agent = create_react_agent(
    model=init_chat_model("anthropic/claude-3-5-sonnet-20241022"),
    tools=[manage_memory, search_memory],
    store=store
)

# Production: replace InMemoryStore with PostgresStore
# from langgraph.store.postgres import PostgresStore
# store = PostgresStore.from_conn_string("postgresql://user:pass`@host`/dbname")
```

### Tool integration

#### Trustcall

- **Function**: Reliable structured data extraction using JSON patch operations
- **Purpose**: Addresses two main LLM limitations:
  1. Populating complex, nested schemas (LLMs struggle with deeply nested structures)
  2. Updating existing schemas without information loss (LLMs often omit data when regenerating)
- **Approach**: Uses JSON patch operations to focus LLM on what has changed, reducing information loss
- **Benefits**: Increases extraction reliability without restricting to subset of JSON schema
- **Use Cases**: Complex schema extraction, memory management updates, simultaneous updates & insertions
- **Code Example**:
```python
from trustcall import create_extractor
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-4o")
bound = create_extractor(llm, tools=[UserSchema])

# Update existing object with new information
result = bound.invoke({
    "messages": [{"role": "user", "content": "Update memory with new info"}],
    "existing": {"UserSchema": current_state.model_dump()}
})
```
- **Validation**: All tool calls schema-validated before execution
- **Error Handling**: Graceful fallbacks for invalid tool calls

### Multi-agent orchestration

#### Supervisor pattern

- **Architecture**: Central orchestrator agent delegates to specialized worker agents
- **Communication**: Workers only communicate through supervisor (no direct worker-to-worker or worker-to-user communication)
- **Implementation**: LangGraph `create_supervisor` with StateGraph nodes
- **Effectiveness**: Slightly underperforms swarm architecture due to "translation" overhead (supervisor acts as middleman between sub-agents and user)
- **Token Cost**: Uses more tokens than swarm for same reason (supervisor paraphrases sub-agent responses)
- **Advantages**: Most generic architecture (fewest assumptions about sub-agents), feasible for all multi-agent scenarios including third-party agents
- **Best For**: Open-ended reasoning, iterative research, complex multi-turn dialogues where path isn't known upfront
- **Trade-offs**: Graphs can become "spaghetti" without strict Supervisor boundaries
- **Improvements**: Removing handoff messages (de-clutters context), forwarding messages tool (reduces paraphrasing errors), tool naming optimization
- **Code Example**:
```python
from langgraph.prebuilt import create_supervisor
from langgraph.graph import StateGraph

# Define workers
researcher = create_react_agent(model, tools=[search_tool])
coder = create_react_agent(model, tools=[code_tool])

# Supervisor orchestrates workers
supervisor = create_supervisor(
    [researcher, coder],
    initial_prompt="You are the Boss. Route the task to the right expert."
)

# Build graph
builder = StateGraph(State)
builder.add_node("researcher", researcher)
builder.add_node("coder", coder)
builder.add_node("supervisor", supervisor)
builder.add_edge("researcher", "supervisor")
builder.add_edge("coder", "supervisor")
builder.set_entry_point("supervisor")
graph = builder.compile()
```

#### Swarm

- **Capability**: Multi-agent orchestration with direct agent-to-agent handoffs
- **Protocol**: Handoff protocol for agent-to-agent transfers
- **Coordination**: Centralized coordinator for agent scheduling
- **Performance**: Slightly outperforms supervisor architecture due to no translation layer (agents respond directly to user)
- **Limitations**: Each sub-agent must know all other agents (not feasible with third-party agents)

### Observability

#### OpenTelemetry

- **Attributes**: `gen_ai.*` attributes on all workflow nodes
- **Root Span**: Distributed tracing via DataPrepper
- **Coverage**: 100% of AI workflow executions traced

### Cost management

- **Metering**: All tool calls metered
- **Budget Check**: Synchronous budget check (COST03 rule)
- **Alerts**: Real-time cost threshold alerts

---

## Section 9: AI Analytics & Feature Flags

### Analytics events

#### Canonical event list

- **agent_invoked**: Agent execution started
- **workflow_started**: Workflow execution initiated
- **workflow_completed**: Workflow execution finished
- **feature_adopted**: New feature adopted by user
- **ai_cost_threshold_hit**: AI cost budget threshold reached
- **auth_passkey_enrolled**: User enrolled WebAuthn passkey
- **sync_offline_queue**: Offline sync queue processed
- **mcp_tool_call**: MCP tool executed
- **rate_limit_triggered**: Rate limit enforced

#### Required properties

All events must include:
- **orgId**: Organization identifier
- **userId**: User identifier
- **timestamp**: Event timestamp (ISO 8601)
- **sessionId**: Session identifier

#### Group analytics

- **Enabled**: Group Analytics for organization-level insights
- **Aggregation**: Automatic rollups by organization

##### Implementation patterns

**Group types configuration**

PostHog Group Analytics enables tracking events at organizational, project, or team levels. Key concepts:

- **Group Types**: Categories defined by the application (e.g., "company", "project", "team"). Maximum 5 group types per project.
- **Groups**: Individual entities within each type (e.g., "Acme Corp", "Tech Solutions Inc."). Unlimited groups per type.
- **Group Keys**: Unique identifiers for each group (e.g., database ID, domain name).

**Frontend implementation (JavaScript Web SDK)**

```javascript
// Identify user and connect to group
posthog.identify('user`@example`.com');
posthog.group('company', 'company_id_in_your_db');

// All subsequent events in session automatically linked to group
posthog.capture('user_signed_up');

// Update group properties (also connects all subsequent events)
posthog.group('company', 'company_id_in_your_db', {
  name: 'PostHog',
  subscription: 'premium',
  date_joined: '2020-01-23'
});

// Reset group when user logs out (prevents event leakage)
posthog.resetGroup();
```

**Backend implementation (Python SDK)**

```python
# Create/update group (sends $groupidentify event)
posthog.group_identify('company', 'company_id_in_your_db', {
  'name': 'PostHog',
  'subscription': 'premium',
  'date_joined': '2020-01-23'
})

# Associate events with group (must include groups parameter for every event)
posthog.capture('user`@example`.com', 'user_signed_up', groups={
  'company': 'company_id_in_your_db'
})

# Multiple group types per event (different types only)
posthog.capture('user`@example`.com', 'feature_used', groups={
  'company': 'company_id_in_your_db',
  'project': 'project_id_in_your_db'
})
```

**Backend implementation (Go SDK)**

```go
// Create/update group
client.Enqueue(posthog.GroupIdentify{
  Type: "company",
  Key: "company_id_in_your_db",
  Properties: posthog.NewProperties().
    Set("name", "PostHog").
    Set("subscription", "premium").
    Set("date_joined", "2020-01-23"),
})

// Associate events with group
client.Enqueue(posthog.Capture{
  DistinctId: "user`@example`.com",
  Event: "user_signed_up",
  Groups: posthog.NewGroups().Set("company", "company_id_in_your_db"),
})
```

**Event linking rules**

- Events must be identified (anonymous events won't link to groups unless `$process_person_profile` is configured)
- JavaScript Web SDK: Call `posthog.group()` once, all session events link automatically (stateful)
- Other SDKs: Pass `groups` parameter for every event (stateless)
- Cannot assign one event to multiple groups of the same type
- Can assign one event to groups of different types

**Group properties**

Every group can have properties (similar to person properties). At least one property required for group to appear in People tab.

```javascript
// Option 1: Set in group() call (recommended)
posthog.group('company', 'company_id', {
  name: 'Acme Corp',
  subscription_tier: 'enterprise',
  date_joined: '2024-01-15'
});

// Option 2: Manual $groupidentify event
posthog.capture('$groupidentify', {
  '$group_type': 'company',
  '$group_key': 'company_id',
  '$group_set': {
    name: 'Acme Corp',
    subscription_tier: 'enterprise'
  }
});
```

##### Org-scoped event aggregation

**Aggregation patterns**

PostHog enables unique organization-level aggregations across all insight types:

1. **Trends**: Select "Unique" with group type to count unique organizations instead of users
2. **Funnels**: Set "Aggregating by" to group type to track organization conversion rates
3. **Feature Flags**: Match by group type for organization-level feature rollouts

**Query Examples**

```javascript
// Trends: Count unique organizations that signed up
// 1. Create insight with signup event
// 2. Expand menu next to event
// 3. Select "Unique" → "company" (group type)

// Funnels: Track organization conversion
// Set "Aggregating by" to "company"
// Shows: unique organizations per step, drop-off percentage, specific orgs that dropped off

// Feature Flags: Release by organization
// In PostHog app: Create flag → Release conditions → Match by → "company"
// In code:
if (posthog.isFeatureEnabled('new-org-feature', groups: { company: 'company_id' })) {
  // Enable feature for this organization
}
```

**Data Model**

Groups are stored as sets of events with group identities, not sets of people. This enables:

- Event-level granularity for group analytics
- Historical analysis of group behavior over time
- Multi-tenant isolation without user linkage
- Cross-product analysis across different group types

**Limitations**

- Maximum 5 group types per project
- Cannot link one event to multiple groups of same type
- Group properties required for group visibility in People tab
- Deleted group types don't count toward limit (data filtered by deletion timestamp)

##### Privacy & GDPR Compliance

**GDPR Requirements for Group Analytics**

Group Analytics processes organization-level data which may include personal data. GDPR compliance requires:

**Data Controller vs Processor Roles**

- **Data Controller**: Your application (collects end users' data, decides why/how it's processed)
- **Data Processor**: PostHog (processes customer data on behalf of controllers)

**Hosting Provider Selection**

- **PostHog Cloud EU**: Recommended for GDPR compliance (servers in Frankfurt)
- **PostHog Cloud US**: Acceptable with additional data protection measures
- **Self-hosted**: Compliance depends on hosting location (EU recommended for EU users)

**IP Data Capture Configuration**

IP addresses are considered personal data under GDPR:

- **Organization-level default**: Configure IP data capture default for all new projects
- **Project-level override**: Individual projects can override organization default
- **PostHog Cloud EU**: IP data capture automatically disabled by default for new projects
- **PostHog Cloud US/Self-hosted**: Manual configuration required to disable IP capture

**Consent Configuration**

Since PostHog automatically captures data, unambiguous consent is required:

- **Right to be informed**: Identify personal data types being processed and tools used
- **Tool identification**: List "PostHog" for Cloud deployments or "Product Analytics" for self-hosted
- **Opt-out mechanism**: Stop all data capturing and processing when user opts out
- **Application logic**: Ensure SDKs are not loaded or data capturing is disabled on opt-out

**Data Control & Storage**

PostHog provides tools to control data collection and storage:

- **Before-send transformations**: Redact data before sending to PostHog servers
- **Before-storage transformations**: Anonymize user data before storage (required for EU users on US/self-hosted)
- **Realtime transformations**: Apply privacy rules at ingestion time

**Security Configuration**

- **PostHog Cloud**: Access control at organization, project, and resource levels
- **Self-hosted**: HTTPS required, limit access to authorized personnel only
- **CDP caution**: Ensure proper controls when sharing personal data via CDPs

**Right to be Forgotten**

PostHog supports GDPR right to be forgotten requests:
- Data deletion capabilities available in PostHog interface
- Group-level deletion requires manual coordination with user deletion
- Audit logging for compliance verification

**Group-Specific Privacy Considerations**

- Group properties may contain organizational PII (company names, contact info)
- Group keys should not contain personal identifiers unless necessary
- Group analytics enable organization-level insights without individual user linkage
- Consider data minimization: only collect group properties necessary for analysis

**Compliance Checklist**

- [ ] Select appropriate hosting provider (PostHog Cloud EU recommended)
- [ ] Configure IP data capture defaults at organization level
- [ ] Implement consent mechanism for data collection
- [ ] Configure before-storage transformations for EU user data
- [ ] Secure access controls (organization/project/resource levels)
- [ ] Implement opt-out functionality in application logic
- [ ] Document data processing activities
- [ ] Establish right to be forgotten procedures
- [ ] Review CDP configurations for personal data sharing
- [ ] Regular compliance audits and reviews

### Governance

#### Event Registration

- **PR Approval**: Required for all new event types
- **CI Validation**: Automated schema validation in CI pipeline
- **Documentation**: All events must be documented

### Feature Flagging

#### OpenFeature Integration

- **SDK**: Vercel Flags SDK
- **Provider**: PostHog provider
- **Use Case**: Analytics sampling and feature rollouts

---

## Section 10: Model Cards

Per agent: Model ID, intended use, limitations, bias metrics, safety eval, training data provenance, SHA-256, review date, owner.

---

## Section 11: GraphRAG Implementation

### FastGraphRAG vs LLM-based GraphRAG

#### Accuracy Comparison Benchmarks

Based on research from FastGraphRAG benchmarks (CircleMind, 2024) and arXiv evaluation frameworks:

| Method | 2wikimultihopQA (51 queries) | 2wikimultihopQA (101 queries) | HotpotQA (101 queries) |
|--------|------------------------------|--------------------------------|------------------------|
| FastGraphRAG (Circlemind) | 96% perfect retrieval | 93% perfect retrieval | 84% perfect retrieval |
| GraphRAG (Microsoft) | 75% perfect retrieval | 73% perfect retrieval | Crashed after 30 min |
| VectorDB RAG | 49% perfect retrieval | 42% perfect retrieval | 78% perfect retrieval |
| LightRAG | 47% perfect retrieval | 45% perfect retrieval | 55% perfect retrieval |

**Key Findings:**
- FastGraphRAG is 4x more accurate than VectorDB RAG on multi-hop queries
- FastGraphRAG is 27x faster than GraphRAG while being over 40% more accurate in retrieval
- From arXiv paper "How Significant Are the Real Performance Gains?" (2025): FGRAG (FastGraphRAG) performs best among methods, but performance gaps are moderate (relative win rates mostly below 8%, except vs LightRAG at 21%)
- Win rates are generally smaller than reported by previous work, and tie rates are notable (over 20% in most cases)
- FGRAG excels in comprehensiveness, MGRAG leads in directness

#### Cost Analysis

| Method | Cost per Operation | Cost Reduction vs Conventional GraphRAG |
|--------|-------------------|----------------------------------------|
| FastGraphRAG | $0.08 | 83% cheaper (6x reduction) |
| Conventional GraphRAG | $0.48 | Baseline |

**Note:** The documentation previously claimed "10% cost" which was incorrect. Research shows FastGraphRAG costs 16.7% of conventional GraphRAG (6x cheaper), not 10%.

#### Performance Metrics

**Insertion Time (~800 chunks):**
| Method | Time (minutes) |
|--------|----------------|
| VectorDB | ~0.3 |
| FastGraphRAG | ~1.5 |
| LightRAG | ~25 |
| GraphRAG | ~40 |

**Architecture Differences:**
- FastGraphRAG uses PageRank-based graph exploration for enhanced accuracy
- Assigns concise and informative contexts to entities and relations
- Adopts PageRank scores to rank retrieved entities and relations
- Designed for incremental updates and real-time data evolution

---

## Section 12: Chunking Strategy

### Dataset size thresholds

The 500K threshold is a decision point for dataset size in **tokens**, not chunk count:

**Decision Framework:**
```
Does your dataset contain >500K tokens?
→ Yes: Consider GraphRAG (better for complex multi-hop reasoning)
→ No: Consider cost vs. benefit (vector RAG may be sufficient)
```

**Rationale:**
- GraphRAG's indexing overhead is justified for datasets >500K tokens
- Below this threshold, vector RAG's quick re-indexing is often more efficient
- The threshold balances indexing cost against retrieval performance gains
- This is NOT a chunk limit - it's a dataset size decision point

**Chunk Size Best Practices:**
- Common chunk sizes: 128-512 tokens for RAG applications
- Larger chunks (512-1024 tokens) for detail-oriented queries
- Smaller chunks (128-256 tokens) for multi-hop reasoning


Use these directly when configuring model parameters in agent definitions.
- Overlap of 10-20% recommended to maintain context continuity