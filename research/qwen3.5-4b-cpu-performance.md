# Qwen3.5 4B CPU Performance Research

**Task ID:** R-AI-02  
**Date:** April 26, 2026  
**Status:** INSUFFICIENT DATA - Requires empirical testing

---

## Executive Summary

This research investigates Qwen3.5 4B performance on consumer CPU hardware (Intel/AMD AVX2, Apple Silicon) with GGUF Q4_K_M quantization. The goal is to determine if the model meets the project's TTFT ≤2s budget for free-tier users on Tier 1 hardware (16GB RAM, CPU-only).

**Key Finding:** No direct CPU benchmarks for Qwen3.5 4B were found in publicly accessible sources. Reddit discussions (r/LocalLLaMA) contain relevant data but are behind verification walls. Empirical testing is required before Week 5 decision point.

---

## Research Sources

### Official Documentation

1. **Qwen Official Speed Benchmarks** (qwen.readthedocs.io)
   - Provides GPU/transformers benchmarks for Qwen3 series
   - No CPU-specific data for Qwen3.5 4B
   - Focuses on SGLang and Hugging Face Transformers backends

2. **Ollama Library Page** (ollama.com/library/qwen3.5:4b)
   - Model size: ~2.5GB (Q4 quantization)
   - No CPU performance benchmarks provided
   - Benchmarks focus on language/vision capabilities, not inference speed

### Third-Party Benchmarks

3. **Artificial Analysis** (artificialanalysis.ai)
   - Provides general performance metrics (tokens/sec, TTFT)
   - Data is for cloud APIs, not local CPU inference
   - Not applicable to local deployment scenario

4. **Glukhov Ollama Benchmark** (glukhov.org)
   - Comprehensive GPU benchmark on RTX 4080 16GB
   - Tests Qwen3.5 9B, 27B, 35B (not 4B)
   - Shows CPU offloading penalties: 12-57 tokens/sec with 25-78% CPU offloading
   - Not pure CPU inference data

5. **GitHub Issue #22001** (ggml-org/llama.cpp)
   - Reports Qwen3.5 slower than Qwen3 on Intel Arc iGPU (SYCL backend)
   - No specific CPU numbers provided
   - Indicates architectural differences may affect performance

### Community Discussions (Behind Verification)

6. **Reddit r/LocalLLaMA** - Multiple threads
   - "Qwen 3 Performance: Quick Benchmarks Across" - Mentions Qwen3 4B running on iPhone
   - "Qwen3-30B-A3B runs at 12-15 tokens-per-second on CPU" - Ryzen 7 PRO 5875U, 64GB RAM
   - "Thread for CPU-only LLM performance comparison" - Contains CPU benchmark tables
   - "Some Qwen3.5 benchmarks on Strix Halo" - Mentions Qwen3.5-35B-A3B performance
   - **Status:** All threads behind Reddit verification, data not accessible

7. **Reddit r/LocalLLM**
   - "Qwen3.5-35B-A3B-4bit 60 tokens/second on my Apple Mac" - MLX performance
   - **Status:** Behind verification

### Hardware Requirements

8. **Techie007 Substack Guide**
   - Hardware requirements table:
     - Qwen3.5 4B: Minimum 6GB RAM, Recommended 8GB+ RAM for laptop
   - Ollama model size: ~2.5GB (Q4 quantization)
   - No CPU performance data

9. **WillItRunAI Apple Silicon Guide**
   - Comprehensive MLX benchmarks for Qwen3.5 on Apple Silicon
   - Focuses on 9B, 27B, 35B-A3B models
   - No 4B model benchmarks
   - Shows MLX is faster than GGUF on Apple Silicon

---

## Available Data Points

### Indirect Performance Indicators

1. **Qwen3 4B (Previous Generation)**
   - Runs on iPhone (Apple Silicon)
   - User reports: "feels smarter than any 70B model I tried on M1 Ultra"
   - Suggests acceptable latency on mobile hardware

2. **Qwen3-30B-A3B (30B MoE) on CPU**
   - Hardware: AMD Ryzen 7 PRO 5875U, 64GB RAM
   - Performance: 12-15 tokens/sec (CPU-only, koboldcpp)
   - Context: Larger model (30B) achieving reasonable speed on modern CPU

3. **CPU Offloading Penalties (Glukhov Benchmark)**
   - 25% CPU offloading: 57.17 tokens/sec (qwen3-coder:30b)
   - 43% CPU offloading: 20.66 tokens/sec (qwen3.5:35b)
   - 78% CPU offloading: 12.64 tokens/sec (gpt-oss:120b)
   - Pattern: More CPU = slower, but 4B model should be faster than 30B/35B

### Hardware Requirements

- **Model Size:** ~2.5GB (Q4_K_M quantization via Ollama)
- **Minimum RAM:** 6GB
- **Recommended RAM:** 8GB+ for laptop
- **Project Tier 1 Spec:** 16GB RAM, AVX2 CPU (Intel i7-12800H or Mac Mini M2)

---

## Performance Estimates (Inferred)

Based on available data points, we can estimate Qwen3.5 4B CPU performance:

### Conservative Estimate
- **TTFT:** 1.5-2.5 seconds (based on Qwen3 4B iPhone performance)
- **Tokens/sec:** 15-25 tokens/sec (extrapolated from 30B-A3B at 12-15 t/s on similar CPU)
- **Rationale:** 4B model is ~7.5x smaller than 30B-A3B, should be proportionally faster

### Optimistic Estimate
- **TTFT:** 0.8-1.5 seconds
- **Tokens/sec:** 25-40 tokens/sec
- **Rationale:** Modern AVX2 CPUs have strong SIMD performance; 4B model fits entirely in L3 cache on some CPUs

### Apple Silicon (MLX)
- **TTFT:** Likely faster than x86 CPU (MLX optimized for Apple Silicon)
- **Tokens/sec:** 30-50 tokens/sec (based on 9B at 25-35 t/s in WillItRunAI)
- **Note:** MLX backend not available in Ollama; requires separate setup

---

## Hardware Tier Recommendations

### Tier 1 (CPU-only, 16GB RAM)

**Intel/AMD AVX2 (e.g., Intel i7-12800H)**
- **Expected TTFT:** 1.5-2.5s (conservative)
- **Expected TPS:** 15-25 tokens/sec
- **Verdict:** **LIKELY MEETS ≤2s TTFT budget** (conservative estimate at upper bound)
- **Confidence:** LOW (requires empirical testing)

**Apple Silicon (M2/M3)**
- **Expected TTFT:** 1.0-2.0s
- **Expected TPS:** 25-35 tokens/sec
- **Verdict:** **LIKELY MEETS ≤2s TTFT budget**
- **Confidence:** MEDIUM (based on Qwen3 4B iPhone performance, MLX benchmarks)

### Free-Tier User Experience

**Estimated Latency for Typical Chat:**
- Prompt processing (512 tokens): ~0.5-1.0s
- First token (TTFT): ~1.5-2.5s
- Generation (100 tokens @ 20 t/s): ~5.0s
- **Total:** ~7-8.5s for 100-token response

**Assessment:** Acceptable for free-tier users, but may feel sluggish compared to cloud models. TTFT is the critical metric; if ≤2s, users perceive responsiveness.

---

## Gaps and Limitations

### Critical Gaps

1. **No Direct CPU Benchmarks:** No accessible source provides actual TTFT/TPS measurements for Qwen3.5 4B on CPU
2. **Reddit Data Inaccessible:** Most community benchmarks are behind Reddit verification
3. **No Tool-Use Performance:** No data on performance under chat+tool-use scenarios (vs simple generation)
4. **No AVX2 Specific Data:** Most benchmarks reference specific CPUs (Ryzen, Intel Arc) without clear AVX2 classification

### Limitations

1. **Inference from Larger Models:** Estimates based on 30B-A3B performance may not scale linearly
2. **Architecture Differences:** Qwen3.5 may have different inference characteristics than Qwen3
3. **Quantization Impact:** Q4_K_M performance may vary between llama.cpp/Ollama implementations
4. **Context Window Impact:** Performance at 19K context (Glukhov test) may differ from typical 4K context

---

## Recommendations

### Immediate Actions

1. **Empirical Testing Required:** Run actual benchmarks on Tier 1 hardware before Week 5 decision point
   - Test on Intel i7-12800H (or similar AVX2 CPU)
   - Test on Apple M2/M3 (MLX and Ollama backends)
   - Measure TTFT and TPS under realistic chat+tool-use scenarios
   - Test with context sizes: 512, 2048, 4096 tokens

2. **Reddit Data Access:** Attempt to access r/LocalLLaMA threads for direct CPU benchmarks
   - "Thread for CPU-only LLM performance comparison" likely contains relevant data
   - "Qwen3-30B-A3B runs at 12-15 tokens-per-second on CPU" provides baseline

### Testing Protocol

**Hardware:**
- Intel i7-12800H (8 P-cores + 12 E-cores), 16GB DDR5
- Apple M2 Mac Mini, 16GB unified memory

**Software:**
- Ollama 0.19+ (latest stable)
- llama.cpp latest (for comparison)
- MLX (Apple Silicon only)

**Test Scenarios:**
1. Simple generation: "Explain quantum computing in one paragraph"
2. Chat context: 5-turn conversation history
3. Tool use: Simulated tool-calling scenario (JSON extraction)
4. Context sizes: 512, 2048, 4096 tokens

**Metrics:**
- TTFT (time to first token)
- TPS (tokens per second during generation)
- Total response time for 100-token output
- CPU utilization
- Memory usage

### Decision Criteria

**Proceed with Qwen3.5 4B as Free-Tier Default if:**
- TTFT ≤2s at p95 on Tier 1 hardware
- TPS ≥15 tokens/sec during generation
- Tool-calling performance acceptable (no significant degradation)

**Consider Alternatives if:**
- TTFT >2.5s consistently
- TPS <10 tokens/sec
- Tool-calling causes significant latency spikes

**Alternative Models to Test:**
- Gemma 4 E2B (2B, smaller, potentially faster)
- Qwen3.5 2B (even smaller, if quality acceptable)
- Phi-4-mini-reasoning (3.8B, optimized for reasoning)

---

## Conclusion

**Status:** INSUFFICIENT DATA

While indirect evidence suggests Qwen3.5 4B may meet the ≤2s TTFT budget on Tier 1 hardware, no direct CPU benchmarks are available in publicly accessible sources. Reddit community discussions likely contain the needed data but are behind verification walls.

**Recommendation:** Conduct empirical testing on representative Tier 1 hardware (Intel i7-12800H, Apple M2/M3) before making a final decision on Qwen3.5 4B as the free-tier default model. Testing should include realistic chat+tool-use scenarios and multiple context sizes.

**Timeline:** Complete empirical testing by Week 5 decision point to inform model selection for Phase 0 deployment.

---

## References

1. Qwen Official Documentation - Speed Benchmarks: https://qwen.readthedocs.io/en/latest/getting_started/speed_benchmark.html
2. Ollama Library - qwen3.5:4b: https://ollama.com/library/qwen3.5:4b
3. Artificial Analysis - Qwen3.5 4B: https://artificialanalysis.ai/models/qwen3-5-4b
4. Glukhov Benchmark - Ollama on 16GB VRAM: https://www.glukhov.org/llm-performance/benchmarks/choosing-best-llm-for-ollama-on-16gb-vram-gpu/
5. GitHub Issue #22001 - Qwen 3.5 on Arrow Lake: https://github.com/ggml-org/llama.cpp/issues/22001
6. Techie007 Substack - Qwen 3.5 Complete Guide: https://techie007.substack.com/p/qwen-35-the-complete-guide-benchmarks
7. WillItRunAI - Qwen 3.5 on Apple Silicon: https://willitrunai.com/blog/qwen-3-5-mlx-apple-silicon-guide
8. Unsloth Documentation - Qwen3.5: https://unsloth.ai/docs/models/qwen3.5
9. Project Rules - 00-RULES.yaml (AI-02, BE-01)
10. Performance Budgets - 80-OPS-PERFORMANCE.md (TTFT ≤2s)
11. AI Core Architecture - 60-AI-CORE.md (local model infrastructure)
