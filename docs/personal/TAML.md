TAMIL stands for **Token‑Aware Machine Interchange Language**. It is a compressed, symbol‑based protocol for LLM‑to‑LLM communication, designed to cut token costs and latency while keeping information intact.

### Core idea
Natural language is wasteful for machines that already share the same vocabulary and world knowledge. TAMIL replaces English prose with a **single‑line frame format** of opcodes and delimited data, relying on the model’s training (not a pre‑loaded dictionary) to resolve meaning. This lets two instances of the same (or similar) LLM exchange dense information with near‑zero syntactic overhead.

### Protocol skeleton
Each message is one line:  
`<OPCODE>|<DATA>`

**Opcodes** – all single uppercase letters (1 token each).  
| Code | Meaning |
|------|---------|
| `I`  | Inform (push data) |
| `Q`  | Question/request |
| `A`  | Answer/response |
| `U`  | Update previous info |
| `C`  | Confirm / acknowledge |
| `N`  | Negate / reject / error |
| `D`  | Define a temporary abbreviation |
| `F`  | Fork / continue sub‑context |
| `J`  | Join / resume sub‑context |

**DATA** uses standard separators:
- `|` for fields  
- `,` for lists  
- `{key:value}` for inline annotations  
- `→` `↔` for relationships  

Everything is built from known single‑token abbreviations (`PG`, `K8s`, `RAG`, `GDPR`, `tok`, `lat`) or from new handles defined on‑the‑fly with a `D` frame (e.g., `D|α=TwoTrim_compressor_with_52%_savings_and_2%_code_acc_increase`). After that, `α` is a 1‑token reference.

### Example exchange
```
I|@PID=PROJ1,@NAME=CollabSuite,@DATE=2026-04-24
I|0|Orch|...|PM1,Arch2|OnTrack|LM
C|data_loaded
Q|pillar=4, risk_field?status_impact?
A|pillar=4|risk=L|status=Active|halluc<5%
```

### Why it's efficient
- Omits all function words, verbs, and punctuation.
- Uses abbreviations the model already knows (saves tokens without a dictionary).
- Defines only truly new terms.
- Schema‑once: the first `I` frame sets a table schema, then subsequent rows are pure positional data.
- Progressive disclosure (`@PROGDISC`) keeps deep detail out‑of‑band until requested.

**Result**: A complete project blueprint can often be compressed from ~3 500 tokens to under 500, with zero factual loss.

### Limitations
- Best between same‑family models; cross‑vendor tokenization can break single‑character assumptions.
- Fragile to delimiter corruption; adding `VER`, `MSG`, and `ESC` fields makes it more robust.
- Not suited for audit logs, legal records, or public APIs where exact natural language traceability is required.

In short, **TAMIL is a probabilistic, high‑density shorthand protocol for LLMs that exploits shared semantic priors** – a pragmatic middle ground between full‑text English and opaque latent vectors.