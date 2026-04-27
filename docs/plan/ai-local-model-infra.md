---
title: "AI Local Model Infrastructure"
owner: "AI/ML Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

This document describes the local model infrastructure including serving stack, model registry, quantization policy, hardware tiers, and model lifecycle pipeline.

---

## Serving Stack (Phase 0)

- **Primary**: Ollama (≥0.5.0) - OpenAI-compatible API, native tool calling support, model management, Metal/CUDA/CPU backends. 52M+ monthly downloads.
- **Backend**: llama.cpp (March 2026, 100K GitHub stars) - GGUF quantization, speculative decoding, CPU-optimized.
- **Orchestration**: Docker Compose for reproducible local environments. Bifrost (model gateway) evaluated for Phase 2.
- **Fallback**: LiteLLM proxy already routes cloud API calls when local model is unavailable or insufficient.

---

## Model Registry

| Field | Description |
| :--- | :--- |
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
| :--- | :--- | :--- | :--- |
| Gemma 4 E2B | 2B active | Native tokens | Default orchestrator (light hardware) |
| Gemma 4 E4B | 4.5B dense | Native tokens | Default orchestrator (≥16GB RAM) |
| Qwen3.5 4B | 3.4 GB (Q4_K_M) | 97.5% pass rate | Tool executor |
| Phi-4-mini-reasoning | 3.8B | Prompt | Verifier (Phase 1) |
| Llama4-7B | 7B (MoE) | Prompt | High-throughput chat (optional) |

---

## Quantization Policy

| Format | Memory | Status | Use Case |
| :--- | :--- | :--- | :--- |
| GGUF Q4_K_M | <4.5GB | Default | Human reading speed on CPU |
| GGUF Q8_0 | Higher | Available | Higher accuracy |
| Ternary (FairyFuse) | TBD | Future | Per-layer sensitivity optimization |
| QIGen | Variable | Optional | Non-uniform quantization for specific models |

---

## Hardware Tiers

| Tier | Requirements | Typical Setup | Target Models |
| :--- | :--- | :--- | :--- |
| **Tier 1 (CPU-only)** | AVX2, 16GB RAM, single NUMA node | Intel i7-12800H, Mac Mini M2 | Gemma 4 E2B, Qwen3.5 4B |
| **Tier 2 (GPU-accelerated)** | RTX 3060+ / Apple M2+ 16GB | Workstation with 12GB+ VRAM | Gemma 4 E4B, Llama4-7B |
| **Tier 3 (Server)** | Multi-core Xeon, 32GB+ RAM, multi-NUMA (Phase 2) | Fly.io performance nodes | Multi-model concurrent serving |

**NUMA consideration**: For Phase 0, deploy on single-NUMA-node machines (Fly.io shared-cpu-1x is fine). For Phase 2+, ArcLight NUMA-aware orchestration may be configured for multi-socket servers.

---

## Model Lifecycle Pipeline

1. **Pull**: Download model from HuggingFace/Ollama registry with SHA-256 verification.
2. **Quantize** (if needed): Convert to GGUF Q4_K_M using llama.cpp tools.
3. **Register**: Populate model registry with capability scores (automated eval harness, lm-evaluation-harness or custom).
4. **Serve**: Deploy via Ollama. Health check `GET /api/tags`.
5. **Update**: New model version → parallel deployment → capability re-benchmark → traffic shift → deprecate old version after grace period.
6. **Sunset**: Notify users 30 days before model removal. Auto-migrate to successor model if compatible.

---

## Verifier Cascade (Phase 1)

A lightweight local model (Phi-4-mini-reasoning) performs pre-action validation:

1. **Reasoning check**: Is the orchestrator's plan consistent with the user intent?
2. **Schema check**: Does the tool call match the JSON schema exactly?
3. **Budget & permission check**: Is the action within the user's plan limits?

Verifier decisions are logged to `audit_logs` with confidence score. If verifier rejects, the orchestrator is re-prompted with feedback.

---

## Fine-Tuning Pipeline (Phase 2)

- **Primary tool**: Unsloth (2× faster training, 70% less VRAM). QLoRA adapters.
- **CPU-only alternative**: LoFT CLI for small models (1-3B), exports to GGUF.
- **Apple Silicon**: MLX-LM (Apple's MLX framework) for local fine-tuning on Mac.
- **Use cases**: Domain-specific task models, per-organization style adaptation, user-personalised agent behavior (LoRA adapters loaded dynamically).

---

## Distributed Inference (Phase 3+)

- **Prima.cpp** (ICLR 2026): 30-70B models on home clusters with mixed CPUs/GPUs, Wi-Fi links. 26 TPS on 32B model with speculative decoding.
- **Mesh LLM** (GitHub, 2026): Pools spare GPU capacity, OpenAI-compatible API.
- **Goal**: Serve larger models (8-32B) across multiple on-premise or edge devices, reducing reliance on cloud even for complex tasks.

---

## Model Evaluation Harness

All models undergo automated testing before registration:

- Tool-calling pass rate (schema-aware deterministic scoring, 40+ test cases)
- Hallucination rate on TruthfulQA or equivalent
- Latency (TTFT, TPS) on target Tier 1/2 hardware
- Multi-tool chaining success rate (Phase 1)

Results stored in model registry. Evaluations rerun weekly for active models, triggered by CI.

---

## Security & Supply Chain

- Model downloads verified with SHA-256 or Sigstore signatures.
- GGUF conversion done in sandboxed environment.
- No model execution in production without registry entry.
- Local models isolated from internet by default; no telemetry sent.
- Cloud fallback requires explicit user opt-in (paid tier).

---

## Integration with Dispatcher

The Intent Dispatcher queries the model registry to route tasks:

- `preferred_executor` field in tool definitions maps to model tiers.
- Dispatcher checks registry for model availability and capability before routing.
- If preferred local model is unavailable or below confidence threshold, dispatcher escalates to cloud (if authorized) or returns "task too complex for current plan" error.

---

## Open Questions

- How often to re-benchmark models (weekly? per-update? continuous?).
- Policy for user-installed third-party models (app store model?).
- Handling of Apple Silicon vs. Intel-specific quantization (Metal vs. AVX2).
- Full migration timeline to ternary (FairyFuse) if llama.cpp integrates it.
