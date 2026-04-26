## Executive Summary: The New Landscape of Estimation & Forecasting

Estimation in 2026 is characterized by four major shifts:
1. **AI & LLMs** enable automated functional size measurement, story point estimation, and even natural-language budget generation
2. **Probabilistic forecasting** via Monte Carlo simulation provides range-based predictions with confidence intervals (P10–P90), replacing single-point estimates
3. **Hybrid methodologies** blend predictive and adaptive planning, with explicit phase‑specific estimation strategies
4. **Non‑functional sizing** is now standardized via **ISO/IEC/IEEE 32430:2025**

## I. Functional Size Measurement Artifacts

Functional size measurement provides the objective input for nearly all parametric estimation models. Key standards include IFPUG FPA, COSMIC, NESMA, and ISO 19761.

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **IFPUG FPA (Function Point Analysis)** | Measure software functional size based on functional user requirements. | Data functions (ILFs, EIFs), transactional functions (EIs, EOs, EQs), each rated simple/average/complex, to compute unadjusted and adjusted function points |
| **COSMIC Function Point Measurement** | ISO 19761 method sizing by counting data movements across functional processes. | Each functional user requirement mapped into four types of data movements (Entry, Exit, Read, Write). More suitable for real-time and embedded systems than IFPUG |
| **Non-Functional Size Measurement (ISO/IEC/IEEE 32430:2025)** | Quantify non-functional requirements to complement functional sizing. | Security, performance, reliability, and usability constraints sized using standardized method |
| **Use Case Points (UCP)** | Estimate based on use case models in object‑oriented analysis. | Count unadjusted actor weights, unadjusted use case weights, technical complexity factors, environmental factors |

COSMIC functional size measurement from textual requirements can now be automated using large language models (BERT, SE-BERT, CodeBERT).

## II. Parametric & Algorithmic Estimation Models

These models use historical‑data-driven coefficients requiring baseline calibration.

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **COCOMO (Basic / Intermediate / Detailed)** | Effort = a × KSLOCᵇ × EM；three modes: organic, semi‑detached, embedded. In Detailed COCOMO, multiply by cost drivers for each phase. |  | |
| **COCOMO II (Post‑Architecture / Early Design)** | Estimates based on source lines of code (SLOC) or function points. | Use scale factors (precedentedness, development flexibility, team cohesion) and effort multipliers (required reliability, product complexity, platform difficulty) |
| **CoBRA (Cost Estimation, Benchmarking, and Risk Assessment)** | Combines human judgment with measurement data for custom‑specific estimation. | Risk-adjusted effort = baseline effort + impact of risk factors (e.g., requirements volatility, team experience) |
| **SLIM / ESTIMACS** | Commercial tools based on Putnam's model (Norden–Rayleigh curve). | Calculate manpower buildup index, time to peak, lifecycle effort distribution， using QSM's parametric database for benchmarks. | |

### AI-Enhanced Parametric Models
Hybrid models (COCOMO II plus neural networks) have improved prediction accuracy while reducing variability；LLM‑driven workflows like GARMA can generate bounded resource demand estimates from early architectural artifacts.

## III. Agile & Relative Estimation Artifacts

Relative estimation focuses on comparative sizing rather than absolute hours.

### Story Point Reference Artifact

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **Baseline Story / Reference Story** | Define team-specific story point scale. | A specific story (or two) of known size; all other stories estimated relative to this baseline using Fibonacci sequence (1, 2, 3, 5, 8, 13, 21, 34, 55, ∞) |
| **Estimation Factor Definition** | Explicitly define factors considered in story points. | **Complexity** (how hard); **Effort** (how much work); **Risk/Doubt** (unknowns or dependencies) |

Story point adoption remains high at 71% among agile teams；68% use Planning Poker with Fibonacci or modified scales。

### Collaborative Estimation Artifacts

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **Planning Poker Deck / Template** | Facilitate consensus‑based relative estimation. | Cards showing Fibonacci values, plus special cards (?, infinity, coffee). Process: present story → each selects card → discuss extremes → converge |
| **Affinity Estimation (Bucket System)** | Quickly estimate large numbers of backlog items (20–100+). | Sort items into columns representing point values, using moderate‑sized (S/M/L/XL) or Fibonacci buckets |
| **T‑Shirt Sizing** | High‑level relative sizing without numeric precision. | S/M/L/XL/XXL used for epics or long‑term planning before breaking down into stories. Maps to story‑point ranges for conversion. |
| **Estimation Confidence Record** | Track estimation certainty per item. | Each item has story point value + confidence level (low/medium/high) + factors for uncertainty. |

### 2026 Landscape: Agile Estimation Usage

| Usage | Percentage |
| :--- | :--- |
| Story point adoption | 71% |
| Planning poker usage | 68% |
| Monte Carlo forecasting among elite teams | 41% |
| On‑time delivery (elite teams) | 88% |
| Faster lead times (elite teams) | 40% |

Elite teams (`DORA Elite`) achieve 88% on‑time delivery with 40% faster lead times.

## IV. Probabilistic & Uncertainty Quantification Artifacts

The Cone of Uncertainty helps manage estimation accuracy across the lifecycle. Accuracy at project start is roughly ±400%, narrowing to ±4% near completion。Estimation must be **revisited at each lifecycle stage**; forcing one estimate at the start yields bias exceeding 60%。

### Monte Carlo Forecasting

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **Monte Carlo Simulation Engine** | Generate probabilistic completion forecasts using historical data. | Run thousands of simulations to output confidence intervals (e.g., “85% chance to complete by Friday”). Available for Jira (Agile Gadgets) and spreadsheets |
| **Probabilistic Forecast Report** | Communicate estimation uncertainty to stakeholders. | Charts with P10 (10% likelihood), P50 (median), P90 (90% likelihood) completion dates, plus burn‑down simulation bands |
| **Velocity Range Forecast** | Predict future sprint capacity using historical velocity distribution. | Use past velocity data to sample → produce range of likely future completions。Often combined with AI for real‑time confidence levels |
| **What‑If Scenario Analysis** | Model capacity changes (e.g., team size, availability). | Simulate variations in team availability / velocity and compare forecast ranges to baseline plan |

### Human–AI Collaboration Framework for Estimation
Given the rise of various AI estimation techniques, documenting the team's collaborative approach is essential.

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **Human–AI Collaboration (HAIC) Framework for Estimation** | Document the governance policies for AI‑assisted estimation. | Approved AI‑estimation tools; data inputs allowed; human review / approval thresholds; evaluation metrics for AI accuracy (e.g., MRE, Pred‑25) |

## V. AI & LLM‑Driven Estimation Artifacts

### Functional Size Estimation Automation

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **LLM‑Based COSMIC Measurement Report** | Automate functional size measurement from textual requirements. | Input user story or requirement text → LLM (CodeBERT, SE‑BERT) outputs COSMIC point value with confidence score, reducing manual overhead |
| **Predictive Functional Size via NLP** | Estimate size of unmeasured requirements using natural language processing. | NLP models (including LLMs) predict functional size from requirement statements；aims to eliminate manual FPA counting |

**SELU Benchmark (Software Engineering Language Understanding)** evaluates LLMs on 17 non‑code tasks including effort and complexity estimation.

### Story Point Estimation via LLM

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **LLM‑Generated Story Point Estimate** | Automate relative sizing using project‑specific calibration。 | Fine‑tuned LLM (e.g., CodeBERT, LLAMA models) trained on historical story data predicts story points for new items |
| **Comparative Learning Framework** | Calibrate project‑specific prediction models via comparative learning. | Input reference stories plus candidate story → compute optimal similarity weighting to produce point estimate |
| **Multi‑Agent LLM Estimation Consensus Record** | Simulate Planning Poker using autonomous agent conversations。 | Multiple LLM agents discuss and negotiate estimates, then report final consensus + alternative views |

**Explainable AI (XAI) for Story Point Estimation** provides traceable reasoning (e.g., SHAP values) to help teams understand AI decisions。

### Budget & Cost Automation

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **AI‑Generated Project Cost Estimate** | Produce natural‑language estimate containing tasks, dependencies, timeline, and budget。 | Input project description → AI (OpenAI, LLMs) outputs structured estimate with line‑item breakdown, stack suggestions, and AI confidence score. Used for agency proposals and client quotes |
| **Human Equivalent Effort (HEE) Report** | Translate AI agent task telemetry into business‑legible effort units。 | Raw task logs → HEE and Financial Equivalent Cost (FEC) figures for finance reviews |
| **AI‑Driven Budget Recommendation (Historical Data)** | Auto‑generate budgets using actual past project data。 | System analyzes completed project logs) to produce draft budgets for new similar projects (moving beyond raw estimates) |

## VI. Database‑Driven & Template‑Based Estimation

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **Feature Lego Block Catalog** | Reusable component database for bottom‑up estimation。 | Predefined atomic feature types (e.g., user login, payment integration, search) with historical effort and cost averages. Allows quick composition estimates without blank‑page starting |
| **Historical Benchmark Database** | Industry / organizational benchmark data for estimation calibration。 | Include project size, domain, effort productivity, cost per function point, defect rates, etc. China's BS CEA publishes authoritative annual software industry benchmark data |
| **Template‑Based Estimation Workflow** | Prebuilt templates for speed and consistency。 | Use org‑specific templates populated by AI assistance (through custom integration tools) |

## VII. Estimation Validation & Improvement Artifacts

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **Estimation Accuracy Log** | Track accuracy of previous estimates to improve future projections。 | Record estimate type, predicted vs. actual, variance reason (e.g., missed scope, inaccurate assumption, new requirement), lessons learned |
| **Spike Result / Research Record** | Document uncertainty reduction activities。 | Spike hypothesis (e.g., “estimate 2 weeks to build, actual will be 3–5 weeks“)， outcome, revised estimate with reduced uncertainty |
| **Phase‑Specific Estimate Update** | Refresh estimates at each lifecycle stage (analysis, design, development, test, deployment, operations). | In addition to the forward schedule: original vs. current estimate plus delta analysis；required for projects in which uncertainty reduction works |

## VIII. Estimation Templates & Tools (2026)

### Spreadsheet‑Based Templates

| Tool Type | Key Features |
| :--- | :--- |
| **Agile Project Estimation Excel Template** | Story point estimation, sprint velocity calculation, team capacity planning |
| **Function Point Analysis Workbook (Excel)** | Automated complexity rating, FP counting, adjustment factor handling |
| **Budget Estimate Template (Excel / Google Sheets)** | Automated formulas for cost categories (labor, material, overhead, contingency)；cloud‑based collaborative editing |
| **Use Case Points Calculator (Excel)** | Automated UCP count + effort conversion |

### Specialized Estimation Platforms

| Tool / Platform | Key Capabilities |
| :--- | :--- |
| **Sourcetable (AI-Powered Spreadsheets)** | Dynamic story point tracking with AI‑generated formulas. Built‑in AI suggests story points and category mapping |
| **Devtimate** | Automated estimation using feature Lego‑block library and database‑driven matching |
| **ai‑estimator2** | OpenA I‑powered cost estimate generation with natural‑language understanding |
| **COCOMO II Python Implementation (aayush598)** | REST API for COCOMO II.2000 estimates |

## IX. Supporting Estimation Governance Artifacts

### Estimation Process Documentation

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **Estimation Strategy Document** | Define estimation approach tailored to project phase。 | Determine which methods (top‑down, bottom‑up, parametric, analogous) to use at each phase; specify required uncertainty scoring |
| **Bottom‑Up vs. Top‑Down Reconciliation Summary** | Quantify differences between approaches to align stakeholders。 | Table of bottom‑up details vs. top‑down summary, reconciliation decisions, approved final estimate。The most robust approach combines bottom‑up detail with top‑down alignment |
| **Three‑Point Estimate (PERT) Document** | The template for single‑item estimates giving an approximation's risk。 | Optimistic (O), Most Likely (M), Pessimistic (P) values, plus calculated expected (E = (O+4M+P)/6) and standard deviation (σ = (P‑O)/6) |
| **Reserve / Contingency Calculation** | Document the contingency buffers for risk mitigation。 | Known‑unknowns buffer (e.g., 20% added) + unknown‑unknowns management strategy |

### Quality Standards & Measurement Process

| Artifact | Primary Purpose | Key Content |
| :--- | :--- | :--- |
| **Measurement Plan (per ISO/IEC 15939)** | Define measurement process with goals, scope, and data quality controls。 | Measurement goals linked to information needs; data collection / validation / storage procedures；analysis techniques and reporting formats |
| **Benchmarking Agreement / Calibration Log** | Document calibration using industry benchmarks or historical data。 | Selected benchmark source or dataset; calibration method; derived coefficients or productivity rates；re‑calibration events |

## X. Implementation Guidelines

A successful estimation documentation practice requires six key principles:

*   **Use a tiered approach**: Start exploration with T‑shirt sizing or affinity estimation; plan detailed increments with planning poker and story points；forecast large releases using Monte Carlo simulation。
*   **Automate functional size and macro‑level forecasts** to reduce manual overhead, but require human‑in‑the‑loop for high‑stakes decisions.
*   **Keep estimation documentation lightweight**；single‑point estimates are rarely accurate, so use ranges and confidence values.
*   **Re‑estimate at every lifecycle phase**；factors change, so costs and effort must be refreshed accordingly。
*   **Integrate estimation into decision‑making, not forecasting**；estimates help answer: “Should we continue? What’s the best next step?”
*   **Follow trade‑off standards guidance**：ISO 20926 (functional size) + ISO 32430 (non‑functional size) together provide a complete measure of software.

By integrating these artifacts into a cohesive, context‑appropriate strategy, software teams establish an audit‑trail of predictions that supports planning, budgeting, and ongoing project control.