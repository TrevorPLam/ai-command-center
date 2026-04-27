# Gemma 4 E2B Tool-Calling Performance Baseline

**Research Date:** April 26, 2026  
**Task:** R-AI-01  
**Objective:** Determine if Gemma 4 E2B regularly exceeds 90% tool-calling precision

---

## Executive Summary

**Verdict:** INSUFFICIENT DATA - No publicly available tool-calling accuracy benchmarks for Gemma 4 E2B were found across official sources, academic repositories, or community benchmarks. The project must conduct its own evaluation to determine if Gemma 4 E2B meets the 90% precision threshold required by AI-16 rule and Block 0B decision point.

**Confidence Level:** LOW - Documentation confirms native function calling support but lacks quantitative performance metrics.

**Recommendation:** Conduct a custom evaluation using the Berkeley Function Calling Leaderboard (BFCL) framework or DeepEval before Week 5 decision point.

---

## Research Findings

### 1. Official Sources (Google)

#### Sources Reviewed:
- Google AI for Developers: Gemma 4 Model Card
- Google AI for Developers: Gemma 4 Function Calling Documentation
- Google Blog: "Gemma 4: Byte for byte, the most capable open models"
- Hugging Face: google/gemma-4-E2B model card

#### Key Findings:
- **Native Function Calling:** All sources confirm Gemma 4 has "native support for structured tool use" and "function calling" across all model sizes
- **Agentic Workflows:** Documentation states models are "purpose-built for advanced reasoning and agentic workflows"
- **No Quantitative Metrics:** Official documentation does NOT provide tool-calling accuracy percentages, pass rates, or precision scores
- **Benchmark Focus:** Official benchmarks focus on reasoning (MMLU-Pro, AIME, GPQA, HLE), coding, and vision tasks - not function calling

#### Representative Quotes:
> "Function Calling – Native support for structured tool use, enabling agentic workflows."  
> — Gemma 4 Model Card

> "Agentic workflows: Native support for function-calling, structured JSON output, and native system instructions enables you to build autonomous agents that can interact with different tools and APIs and execute workflows reliably."  
> — Google Blog

---

### 2. Academic Repositories

#### Sources Reviewed:
- arXiv:2604.07035 - "Gemma 4, Phi-4, and Qwen3: Accuracy-Efficiency Tradeoffs in Dense and MoE Reasoning Language Models"

#### Key Findings:
- **Benchmark Scope:** The study evaluates Gemma 4 models on reasoning benchmarks (ARC-Challenge, GSM8K, Math Level 1-3, TruthfulQA MC1)
- **No Function Calling:** The paper does NOT include function calling or tool-use benchmarks
- **8,400 Evaluations:** Study covers model-dataset-prompt evaluations but none for tool calling
- **Conclusion:** Academic literature has not yet published independent tool-calling evaluations for Gemma 4

---

### 3. Community Benchmarks

#### Sources Reviewed:
- Berkeley Function Calling Leaderboard (BFCL) V4
- Reddit: r/LocalLLaMA discussions on Gemma 4 tool calling
- Hugging Face Blog: "Welcome Gemma 4"
- MindStudio: "Gemma 4 vs Qwen 3.6 Plus: Agentic Workflows"
- Lushbinary: "Google Gemma 4 Developer Guide"
- Gemma4-ai.com: Quantization benchmarks

#### Key Findings:

**Berkeley Function Calling Leaderboard (BFCL):**
- BFCL is the gold standard for function calling evaluation
- Gemma 4 models were NOT found in the leaderboard data accessed
- Leaderboard includes Llama 3.1, Qwen3, Nova, QwQ models but not Gemma 4
- This suggests Gemma 4 has not been formally evaluated on BFCL as of April 26, 2026

**Reddit Community (r/LocalLLaMA):**
- Multiple threads discuss Gemma 4's tool calling capabilities
- Users report "native tool calling" works with Ollama
- One user tested Gemma 4 E2B as a multi-agent coordinator: "Short answer: it works"
- **No quantitative accuracy data** reported in community discussions
- One thread mentions BFCL and NexusRaven benchmarks but does not provide Gemma 4 scores

**Third-Party Analysis:**
- **MindStudio:** Qualitative analysis states "Gemma 4's native function calling has been specifically trained to produce well-formed outputs with correct argument schemas" and "consistency reduces error handling overhead" - but no percentages
- **Lushbinary:** Confirms "native function calling support" and "agent framework integration" - no benchmarks
- **Gemma4-ai.com:** Discusses quantization impact on tool calling: "4-bit takes a meaningful hit on complex reasoning, math, and tool calling" - but no baseline accuracy provided

---

## Summary Table

| Source | Tool-Calling Accuracy | Benchmark Used | Confidence |
|--------|----------------------|----------------|------------|
| Google Official Model Card | NOT PROVIDED | N/A | HIGH (absence is definitive) |
| Google Function Calling Docs | NOT PROVIDED | N/A | HIGH (absence is definitive) |
| arXiv:2604.07035 | NOT EVALUATED | Reasoning only | HIGH (scope confirmed) |
| BFCL Leaderboard | NOT LISTED | BFCL V4 | HIGH (absence is definitive) |
| Reddit Community | ANECDOTAL ONLY | None | LOW (qualitative only) |
| MindStudio Analysis | QUALITATIVE ONLY | None | LOW (no numbers) |
| Lushbinary Guide | NOT PROVIDED | N/A | HIGH (absence is definitive) |

---

## Critical Gap Analysis

### Why This Matters for the Project

**Block 0B Decision Point (Week 5):**
> "If Gemma 4 E2B tool-calling reliability <90%, evaluate Qwen3.5 4B or Llama4-7B."

**AI-16 Rule:**
> "Tool-calling precision >=90% (block if <85%)"

**AI-26 Rule:**
> "Model quantisation: default GGUF Q4_K_M (<4.5 GB RAM); evaluated weekly for tool-calling pass rate"

### The Problem
The project has a hard requirement (>=90% precision) and a binary decision point (Week 5) that depends on this metric, but **no public data exists** to inform this decision.

### Quantization Impact
From Gemma4-ai.com analysis:
> "4-bit takes a meaningful hit on complex reasoning, math, and tool calling"

The project plans to use GGUF Q4_K_M quantization (AI-26 rule). If 4-bit quantization significantly degrades tool-calling accuracy, the baseline (unquantized) accuracy must be substantially higher than 90% to maintain >=90% after quantization.

---

## Recommendations

### Immediate Actions (Before Week 5)

1. **Conduct Custom BFCL Evaluation**
   - Run Gemma 4 E2B through the Berkeley Function Calling Leaderboard framework
   - Use the official BFCL evaluation pipeline: `pip install bfcl-eval==2025.12.17`
   - Evaluate both FP16 and Q4_K_M quantized versions
   - Target: >=90% overall accuracy on BFCL

2. **Alternative: DeepEval Evaluation**
   - Use DeepEval (already in tech stack per AI-15 rule) for tool-calling evaluation
   - Create a golden dataset of 40+ tool-calling test cases (per AI-26 rule)
   - Schema-aware deterministic scoring
   - Weekly re-benchmarking per AI-26 rule

3. **Fallback Planning**
   - If Gemma 4 E2B <90%: Evaluate Qwen3.5 4B (documented 97.5% in 60-AI-CORE.md)
   - If Qwen3.5 4B also <90%: Consider Llama4-7B or defer tool-calling to cloud models (paid tier only)

### Long-Term Strategy

1. **Submit to BFCL**
   - Submit Gemma 4 E2B evaluation results to the Berkeley Function Calling Leaderboard
   - This provides public validation and community benchmarking

2. **Weekly Monitoring**
   - Implement AI-26 rule: weekly re-benchmarking of tool-calling pass rate
   - Track accuracy drift over time
   - Alert if accuracy drops below 85% (blocking threshold)

3. **Quantization Testing**
   - Establish baseline accuracy at FP16
   - Test Q4_K_M, Q8_0, and other quantization formats
   - Document accuracy-quantization tradeoffs
   - Choose quantization that maintains >=90% precision

---

## Appendix: Search Queries Attempted

1. "Gemma 4 E2B tool calling accuracy benchmarks official Google 2026"
2. "Gemma 4 E2B function calling performance model card technical report"
3. "Gemma 4 E2B tool use evaluation arXiv Semantic Scholar 2026"
4. "Gemma 4 E2B function calling benchmark Hugging Face"
5. "Gemma 4 E2B tool calling pass rate Reddit LocalLLaMA Ollama"
6. "Gemma 4 E2B function calling evaluation benchmark 90% precision"
7. "Gemma 4 function calling benchmark accuracy percentage tool use"
8. "Gemma 4 E2B tool calling evaluation Berkeley Function Calling Leaderboard"
9. "Gemma 4 native function calling performance metrics benchmark table"
10. "Gemma 4 E2B BFCL score overall accuracy function calling"
11. "Gemma 4 BFCL score overall accuracy function calling"
12. "Gemma 4 tool calling accuracy benchmark results"
13. "site:gorilla.cs.berkeley.edu Gemma 4 BFCL score"
14. "Gemma 4 function calling benchmark score percentage Berkeley"
15. "Gemma 4 tool calling BFCL score percentage"
16. "Gemma 4 E2B function calling accuracy benchmark NexusRaven"
17. "Gemma 4 function calling pass rate benchmark"

---

## Sources

1. Google AI for Developers - Gemma 4 Model Card: https://ai.google.dev/gemma/docs/core/model_card_4
2. Google AI for Developers - Function Calling with Gemma 4: https://ai.google.dev/gemma/docs/capabilities/text/function-calling-gemma4
3. Google Blog - Gemma 4: Byte for byte, the most capable open models: https://blog.google/innovation-and-ai/technology/developers-tools/gemma-4/
4. Hugging Face - google/gemma-4-E2B: https://huggingface.co/google/gemma-4-E2B
5. arXiv:2604.07035 - Gemma 4, Phi-4, and Qwen3: Accuracy-Efficiency Tradeoffs: https://arxiv.org/abs/2604.07035
6. Berkeley Function Calling Leaderboard: https://gorilla.cs.berkeley.edu/leaderboard.html
7. BFCL Leaderboard (llm-stats.com): https://llm-stats.com/benchmarks/bfcl
8. Hugging Face Blog - Welcome Gemma 4: https://huggingface.co/blog/gemma4
9. MindStudio - Gemma 4 vs Qwen 3.6 Plus: https://www.mindstudio.ai/blog/gemma-4-vs-qwen-3-6-plus-agentic-workflows
10. Lushbinary - Gemma 4 Developer Guide: https://lushbinary.com/blog/gemma-4-developer-guide-benchmarks-architecture-local-deployment-2026/
11. Gemma4-ai.com - 4-Bit Quantization Benchmarks: https://gemma4-ai.com/blog/gemma4-4bit-quantization
12. Reddit - r/LocalLLaMA Gemma 4 tool calling discussions (multiple threads)

---

**Report Status:** COMPLETE  
**Next Action:** Conduct custom BFCL or DeepEval evaluation before Week 5 decision point  
**Blocking Risk:** HIGH - Without this data, the Week 5 decision cannot be made evidence-based
