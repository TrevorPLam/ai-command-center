I've now consolidated every change from our discussions since the last document refresh, including the local-first pivot, CPU-LLM research, and the new design axiom. Here are all the documentation updates you need to apply, structured so you can copy-paste each block directly into your IDE and have an agent update the files.

---

## Document Change Set

### 1. 00-00-00.md – Add design axiom, update EU AI Act dates, mention local infra

**Action:**  
- After the "Design Axiom: LLM‑First, Rule‑Optimized" section, insert a new "Design Axiom: Local‑Default, Cloud‑Fallback" section (provided below).  
- In Domain E.3, correct "August 2, 2026" to "December 2, 2027 (stand‑alone high‑risk) / August 2, 2028 (embedded high‑risk)".  
- In the Open Questions list, update the monetization item to reflect the free tier = local models, Pro = cloud access.  
- In Domain C, add a sub‑summary that references the local model infrastructure (covered in its own spec `00-PLAN-C-LOCAL.md`).

**Replace the Open Questions section and the Design Axiom block with the following:**

```markdown
### Design Axiom: LLM‑First, Rule‑Optimized
[ … unchanged … ]

### Design Axiom: Local‑Default, Cloud‑Fallback
All agentic intelligence runs on **local or self‑hosted models by default**. Cloud APIs (Claude, Gemini, etc.) are invoked only when:

- The user’s subscription tier authorizes it,
- The task demonstrably exceeds local model capabilities (verified by a verifier cascade), or
- The user explicitly requests a cloud model.

This principle inverts the industry default, making data sovereignty a product feature. Free‑tier users experience the full AI assistant using only local models (near‑zero marginal cost). Paid tiers unlock cloud AI as a premium add‑on.

---

## Open Questions (to be resolved during build)

- **Proactive behavior**: … (unchanged) …
- **"Appearance of AI" UX**: … (unchanged) …
- **Monetization model**: Free tier: local models only (Gemma 4, Qwen3.5); Pro tier: cloud API access (Sonnet 4.6); Team/Enterprise: Opus 4.7, fine‑tuning, private model hosting. Exact feature gates per tier TBD.
- **Multi‑tenancy**: … (unchanged) …
- **Local model lifecycle**: How to version, update, and deprecate local models without breaking user workflows. Policy needed for end‑of‑life model migration.
```

**In Domain C, after the bullet list of sub‑components, add:**

```markdown
**C.7 Local Model Infrastructure**  
- **Serving Stack**: Ollama (primary) / llama.cpp (backend). Docker Compose for reproducible environments.  
- **Model Registry**: Inventory of supported local models, their capabilities, quantization formats, and hardware requirements.  
- **Quantization Policy**: Default GGUF Q4_K_M; migration path to ternary (FairyFuse) when backend matures.  
- **Hardware Abstraction**: CPU‑only tier (AVX2, 16GB+), GPU‑accelerated tier (optional), Apple Silicon tier (M2+).  
- **Fine‑Tuning Pipeline**: Phase 2+ via Unsloth (GPU) or LoFT CLI (CPU‑only for small models).  
- **Distributed Inference**: Phase 3+ via Prima.cpp or Mesh LLM for 30‑70B models on commodity clusters.  
*(Detailed specification in `00-PLAN-C-LOCAL.md`)*
```

---

### 2. 00-PLAN-1-INTRO.md – Add Phase 0/1 tasks for local models, verifier, fine-tuning

**Action:**  
- In the `#MIL+TSK` section, add new task IDs for local model integration into Phase 0 and Phase 1, as shown below.  
- Insert the new tasks into the existing lists without removing any pending tasks.

**Add to Phase 0 tasks (after F005 or wherever logical):**

```markdown
pending|F006b|Ollama + llama.cpp integration: local serving stack, Docker Compose, OpenAI-compatible API proxy
pending|F006c|Download, quantize, and register default local model (Gemma 4 E2B or Qwen3.5 4B). Model registry initial population
pending|F006d|Local model tool-calling verification: ensure default local model passes >90% of tool-calling test suite
pending|F011b|Intent Dispatcher local routing policy: route all free-tier agent calls to local models by default
```

**Add to Phase 1 tasks (after P116 or in the new Observability / AI reliability section):**

```markdown
pending|P116b|Verifier cascade: deploy Phi-4-mini-reasoning as local verifier; checks reasoning, schema, permission, cost
pending|P116c|Model capability registry: automated benchmarking of all registered models, tool-calling scores, latency profiles
pending|P116d|Loop controller (SLM-6 pattern): circuit breaker on orchestrator loops, configurable max iterations
pending|P116e|Model update and deprecation policy: version freeze, smooth migration, user notification schedule
pending|P210b|Fine-tuning pipeline: Unsloth/LoFT CLI for domain-specific local models; user-specific LoRA adapters (Phase 2 scope)
```

---

### 3. 00-PLAN-3-PRD.md – Rewrite monetization, add data sovereignty JTBD

**Action:**  
Replace the product vision and JTBD sections with the updated ones below. Keep the rest of the file as is (personas, constraints, etc.).

```markdown
## Product Vision
An AI‑integrated workspace where a conversational assistant works across your calendar, projects, and email to spot problems, suggest actions, and execute them on your behalf—**with all core intelligence running locally by default**, keeping user data private and marginal costs near zero.

## Key Jobs to Be Done

### J001 (P0): Cross‑App Conflict Detection & Resolution
(unchanged)

### J002 (P0): Unified Chat Assistant
(unchanged)

### J003 (P1): Proactive Notifications
(unchanged)

### J004 (P1): External Data Integration
(unchanged)

### J005 (P1): Data Sovereignty & Privacy
I want all my sensitive data to be processed on my own device or within my control, without being sent to third‑party cloud AI providers, so that I can trust the platform with confidential work.

## Monetization Model (Revised)

| Tier | AI Capability | Marginal Cost to Us | Pricing Strategy |
|------|---------------|---------------------|------------------|
| **Free** | Local models only (Gemma 4, Qwen3.5). No cloud API access. Full assistant functionality. | ~$0.00001/1K tokens (electricity) | Free forever, unlimited users |
| **Pro** | Cloud API unlocked (Sonnet 4.6). Local default remains, cloud used for complex tasks. | $0.10-0.50/user/month in cloud tokens | $20‑30/user/month |
| **Team/Enterprise** | Full cloud access (Opus 4.7). Dedicated fine‑tuning, private model hosting, priority support. | $1‑5/user/month in cloud tokens | Custom pricing |

*(Existing PRD content — personas, assumptions, constraints, dependencies — remains unchanged and follows here.)*
```

---

### 4. 00-PLAN-C-AI.md – Extend gateway, verifier cascade, cost model

**Action:**  
After the Intent Dispatcher section, add the following new sections. Keep all existing memory, evaluation, safety, and cost sections.

```markdown
## Local‑First Gateway Extension (C.1)

The multi‑provider AI gateway is extended with a **local execution tier** as the default route. Every model definition now includes:

- `execution_location`: `local` | `cloud` | `hybrid`
- `privacy_tier`: `sovereign` | `shared` | `third_party`

**Default routing policy (Phase 0):**
1. Gemma 4 E2B/E4B (local) – orchestrator
2. Qwen3.5 4B (local) – tool executor, 97.5% tool‑calling accuracy
3. Phi‑4‑mini‑reasoning (local) – verifier (Phase 1)
4. Claude Sonnet 4.6 (cloud) – paid tier only, for tasks exceeding local capability
5. Claude Opus 4.7 (cloud) – premium tier only, for complex multi‑step reasoning

## Verifier Cascade (C.6 sub‑component)

Before any agentic action is committed, a lightweight local verifier model (Phi‑4‑mini‑reasoning) performs a structured check:

1. **Reasoning soundness**: Was the orchestrator’s plan coherent?
2. **Schema validity**: Does the proposed tool call match the tool’s JSON schema?
3. **Permission budget**: Is the action within the user’s role and cost limits?

All verifier decisions are logged to `audit_logs`. Verifier model is evaluated monthly; if accuracy drops below 90%, it is retrained or replaced.

## Updated Cost Model (C.2)

| Execution Mode | Cost Model | Marginal Cost | Used By |
|----------------|------------|---------------|---------|
| Local CPU (Ollama/llama.cpp) | Fixed: electricity + hardware amortization | ~$0.00001/1K tokens | Free tier default |
| Self‑hosted GPU (vLLM) | Fixed: GPU amortization + electricity | ~$0.0001/1K tokens | Team tier with dedicated hardware |
| Cloud API (Claude/Gemini) | Variable: per‑token pricing | $3‑$75/1M tokens | Paid tiers only |

## Model Trust Registry (C.4)

A structured catalog of all models (local and cloud) with attested capabilities:

- Tool‑calling pass rate (from automated test suite)
- Hallucination rate on evaluation datasets
- Latency profiles (TTFT, TPS) on target hardware
- Security audit status (for cloud models)
- Last verification date

All models must be registered before they can participate in agentic workflows. The registry is part of Agent Studio.
```

---

### 5. New Document: 00-PLAN-C-LOCAL.md

Create a new file with the following content. This is a comprehensive specification for the local model infrastructure.

```markdown
---
steering: TO PARSE - READ INTRO
file_name: 00-PLAN-C-LOCAL.md
document_type: local_model_infrastructure
tier: infrastructure
status: draft
owner: AI/ML Engineering
description: Local model serving, model registry, quantization policy, hardware tiers, fine-tuning pipeline, distributed inference
last_updated: 2026-04-26
version: 1.0
dependencies: [00-PLAN-C-AI.md, 00-PLAN-6-EXT.md]
related_adrs: [ADR_086, ADR_089, ADR_093]
related_rules: [NO_HAIKU_AGENTIC, LITELLM_PIN, EVALCOST]
complexity: high
risk_level: high
---

# LOCAL – Local Model Infrastructure

## Serving Stack (Phase 0)

- **Primary**: Ollama (≥0.5.0) – OpenAI‑compatible API, native tool calling support, model management, Metal/CUDA/CPU backends. 52M+ monthly downloads.
- **Backend**: llama.cpp (March 2026, 100K GitHub stars) – GGUF quantization, speculative decoding, CPU‑optimized.
- **Orchestration**: Docker Compose for reproducible local environments. Bifrost (model gateway) evaluated for Phase 2.
- **Fallback**: LiteLLM proxy already routes cloud API calls when local model is unavailable or insufficient.

## Model Registry

Every local model is tracked with the following metadata:

| Field | Description |
|-------|-------------|
| `model_id` | Unique identifier (e.g., `gemma-4-e2b`) |
| `parameter_count` | Active parameters (e.g., 2B) |
| `quantization_format` | `GGUF Q4_K_M`, `GGUF Q8_0`, `ternary` (future) |
| `memory_requirement` | RAM needed for inference (e.g., 3.4 GB) |
| `tool_calling_tier` | `native` (special tokens), `prompt` (needs prompt engineering), `unreliable` |
| `verified_tool_call_pass_rate` | From automated test suite |
| `latency_profile` | TTFT, TPS on target hardware tiers |
| `evaluation_date` | Last benchmark run |
| `status` | `active`, `deprecated`, `sunset` |

**Initial Phase 0 models:**

| Model | Size | Tool Calling | Role |
|-------|------|--------------|------|
| Gemma 4 E2B | 2B active | Native tokens | Default orchestrator (light hardware) |
| Gemma 4 E4B | 4.5B dense | Native tokens | Default orchestrator (≥16GB RAM) |
| Qwen3.5 4B | 3.4 GB (Q4_K_M) | 97.5% pass rate | Tool executor |
| Phi‑4‑mini‑reasoning | 3.8B | Prompt | Verifier (Phase 1) |
| Llama4‑7B | 7B (MoE) | Prompt | High‑throughput chat (optional) |

## Quantization Policy

- **Default format**: GGUF Q4_K_M (memory <4.5GB, human reading speed on CPU).
- **Migration path**: When llama.cpp integrates ternary support (FairyFuse), models will be re‑quantized and re‑registered. The registry tracks quantization format per model version.
- **Non‑uniform quantization**: QIGen (Apache‑2.0) available if per‑layer sensitivity optimization is needed for specific models.

## Hardware Tiers

| Tier | Requirements | Typical Setup | Target Models |
|------|--------------|---------------|---------------|
| **Tier 1 (CPU‑only)** | AVX2, 16GB RAM, single NUMA node | Intel i7‑12800H, Mac Mini M2 | Gemma 4 E2B, Qwen3.5 4B |
| **Tier 2 (GPU‑accelerated)** | RTX 3060+ / Apple M2+ 16GB | Workstation with 12GB+ VRAM | Gemma 4 E4B, Llama4‑7B |
| **Tier 3 (Server)** | Multi‑core Xeon, 32GB+ RAM, multi‑NUMA (Phase 2) | Fly.io performance nodes | Multi‑model concurrent serving |

**NUMA consideration**: For Phase 0, deploy on single‑NUMA‑node machines (Fly.io shared‑cpu‑1x is fine). For Phase 2+, ArcLight NUMA‑aware orchestration may be configured for multi‑socket servers.

## Model Lifecycle Pipeline

1. **Pull**: Download model from HuggingFace/Ollama registry with SHA‑256 verification.
2. **Quantize** (if needed): Convert to GGUF Q4_K_M using llama.cpp tools.
3. **Register**: Populate model registry with capability scores (automated eval harness, lm‑evaluation‑harness or custom).
4. **Serve**: Deploy via Ollama. Health check `GET /api/tags`.
5. **Update**: New model version → parallel deployment → capability re‑benchmark → traffic shift → deprecate old version after grace period.
6. **Sunset**: Notify users 30 days before model removal. Auto‑migrate to successor model if compatible.

## Verifier Cascade (Phase 1)

A lightweight local model (Phi‑4‑mini‑reasoning) performs pre‑action validation:

1. **Reasoning check**: Is the orchestrator’s plan consistent with the user intent?
2. **Schema check**: Does the tool call match the JSON schema exactly?
3. **Budget & permission check**: Is the action within the user’s plan limits?

Verifier decisions are logged to `audit_logs` with confidence score. If verifier rejects, the orchestrator is re‑prompted with feedback.

## Fine‑Tuning Pipeline (Phase 2)

- **Primary tool**: Unsloth (2× faster training, 70% less VRAM). QLoRA adapters.
- **CPU‑only alternative**: LoFT CLI for small models (1‑3B), exports to GGUF.
- **Apple Silicon**: MLX‑LM (Apple’s MLX framework) for local fine‑tuning on Mac.
- **Use cases**: Domain‑specific task models, per‑organization style adaptation, user‑personalised agent behavior (LoRA adapters loaded dynamically).

## Distributed Inference (Phase 3+)

- **Prima.cpp** (ICLR 2026): 30‑70B models on home clusters with mixed CPUs/GPUs, Wi‑Fi links. 26 TPS on 32B model with speculative decoding.
- **Mesh LLM** (GitHub, 2026): Pools spare GPU capacity, OpenAI‑compatible API.
- **Goal**: Serve larger models (8‑32B) across multiple on‑premise or edge devices, reducing reliance on cloud even for complex tasks.

## Model Evaluation Harness

All models undergo automated testing before registration:

- Tool‑calling pass rate (schema‑aware deterministic scoring, 40+ test cases)
- Hallucination rate on TruthfulQA or equivalent
- Latency (TTFT, TPS) on target Tier 1/2 hardware
- Multi‑tool chaining success rate (Phase 1)

Results stored in model registry. Evaluations rerun weekly for active models, triggered by CI.

## Security & Supply Chain

- Model downloads verified with SHA‑256 or Sigstore signatures.
- GGUF conversion done in sandboxed environment.
- No model execution in production without registry entry.
- Local models isolated from internet by default; no telemetry sent.
- Cloud fallback requires explicit user opt‑in (paid tier).

## Integration with Dispatcher

The Intent Dispatcher (00-PLAN-C-AI.md) queries the model registry to route tasks:

- `preferred_executor` field in tool definitions maps to model tiers.
- Dispatcher checks registry for model availability and capability before routing.
- If preferred local model is unavailable or below confidence threshold, dispatcher escalates to cloud (if authorized) or returns "task too complex for current plan" error.

## Open Questions

- How often to re‑benchmark models (weekly? per‑update? continuous?).
- Policy for user‑installed third‑party models (app store model?).
- Handling of Apple Silicon vs. Intel‑specific quantization (Metal vs. AVX2).
- Full migration timeline to ternary (FairyFuse) if llama.cpp integrates it.
```

---

### 6. 00-PLAN-6-EXT.md – Add local model services

**Action:**  
Append the following entries to the external services section.

```markdown
Ollama|Local model serving (≥0.5.0), OpenAI‑compatible API, native tool calling. 52M+ monthly downloads. Docker Compose integration
llama.cpp|Backend inference engine (100K GitHub stars). GGUF quantization, CPU‑optimized, speculative decoding. Used as Ollama’s backend
Unsloth|Fine‑tuning framework (53.9K GitHub stars). 2× faster, 70% less VRAM. QLoRA adapters. Phase 2
MLX‑LM|Apple Silicon fine‑tuning (MLX framework). Local training on M2+ Macs. Phase 2
LoFT CLI|CPU‑only fine‑tuning for 1‑3B models, GGUF export. Phase 2
ModelCascade|Reference cascade router (MIT). Three‑tier: LOCAL→FAST→CAPABLE. 74% local handling, $3/night operating cost
Bifrost|Model gateway for multi‑model serving. Evaluated for Phase 2
Prima.cpp|Distributed inference (ICLR 2026). 30‑70B models on home clusters. Phase 3+
Mesh LLM|GPU capacity pooling, OpenAI‑compatible API. Phase 3+
```

---

### 7. 00-PLAN-C-KNOWLEDGE.md – Add local model KV entries

**Action:**  
Insert these under the `// Additional domain shortcuts` section (near other `D|` entries).

```markdown
D|OLLAMA=Ollama local model serving (≥0.5.0 for multi-GPU)
D|GGUF=GGUF Q4_K_M default quantization
D|TERNARY=FairyFuse ternary inference (post-llama.cpp integration)
D|NUMA=NUMA-aware deployment (single-node Phase 0, ArcLight Phase 2+)
D|CASCADE=ModelCascade three-tier routing (LOCAL→FAST→CAPABLE)
D|SLM6=Six SLM-first patterns (Router, Schema Enforcer, Output Validator, Loop Controller, Consequence Modeler, Context Pruner)
D|VERIFIER=Phi-4-mini-reasoning used as pre-action verifier (Phase 1)
D|UNSLOTH=Unsloth QLoRA fine‑tuning framework (Phase 2)
D|MLX=MLX‑LM for Apple Silicon fine‑tuning
D|PRIMA=Prima.cpp distributed inference (Phase 3+)
```

---

### 8. 00-PLAN-C-ASI-COMPLIANCE.md (if not already updated) – Correct EU AI Act dates

**Action:**  
Find the line `EU AI Act|Stand-alone high-risk deadline Dec 2,2027; embedded Aug 2,2028` and ensure it matches. If it still says 2026, replace with `Dec 2,2027 (stand-alone) / Aug 2,2028 (embedded)`. (This file may have been updated earlier; verify.)

---

That covers all documentation changes to capture the local-first strategy, CPU-LLM research, and the new design axiom. Once these are applied, the planning docs will fully reflect your current direction, and we can resume the grand phased planning overhaul with everything properly aligned. Let me know if you want me to tweak any section before you paste them in, Trevor.