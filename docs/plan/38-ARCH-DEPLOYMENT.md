# Service deployment details

This document contains detailed deployment configurations and implementation specifications for external services integrated into the AI Command Center platform. For high-level architecture, see [30-ARCH-OVERVIEW.md](30-ARCH-OVERVIEW.md).

---

## Y-Sweet deployment

### Fly.io deployment patterns

**Docker Image:**

Y-Sweet provides an official Docker image for deployment: `ghcr.io/jamsocket/y-sweet:latest`

**Dockerfile Example:**

See [deployment-examples/Dockerfile](deployment-examples/Dockerfile)

**fly.toml Configuration:**

See [deployment-examples/fly.toml](deployment-examples/fly.toml)

**Deployment Commands:**

See [deployment-examples/deploy-commands.sh](deployment-examples/deploy-commands.sh)

**S3 Storage Configuration:**

- Y-Sweet supports S3-compatible storage (AWS S3, MinIO, Wasabi, etc.)
- Uses AWS credentials from environment variables or `aws configure`
- For S3 storage, directory path must start with `s3://`
- Credentials picked up from environment: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`

**Local Development:**

See [deployment-examples/local-dev.sh](deployment-examples/local-dev.sh)

### Y-Sweet Limits

**Body Size Limit:**

- **Configurable via:** `Y_SWEET_MAX_BODY_SIZE` environment variable (added in v0.9.0, PR #405)
- **Default value:** Not documented in public sources (requires testing to determine)
- **Configuration:** Set environment variable to desired byte value (e.g., 104857600 for 100MB)
- **Purpose:** Controls maximum WebSocket message size to prevent memory exhaustion
- **Note:** Original task information stating "50MB document limit" was not found in documentation; actual limit is configurable via environment variable

**Workarounds for Large Documents:**

- Increase `Y_SWEET_MAX_BODY_SIZE` if needed for larger documents
- Implement client-side chunking for very large payloads
- Consider document splitting strategies for collaborative editing scenarios
- Monitor memory usage when increasing limits

---

## LiveKit integration

### Voice AI Pipeline Architecture

**Sequential Pipeline Stages:**

| Stage | Purpose | Latency | Streaming Support |
|-------|---------|---------|-------------------|
| Voice Activity Detection (VAD) | Detect speech vs noise | 10-50ms | Continuous |
| Speech-to-Text (STT) | Convert audio to text | 200ms complete, <100ms partial | Yes (Deepgram Nova, OpenAI Whisper) |
| Large Language Model (LLM) | Generate response | 300-800ms first token | Yes (token streaming) |
| Text-to-Speech (TTS) | Convert text to audio | 100-200ms first chunk | Yes |
| Audio Transport | Deliver audio to user | Network-dependent | WebRTC/SIP trunking |

**Streaming Architecture:**

- Naive pipeline latency: VAD + STT + LLM + TTS (sequential blocking)
- Streaming pipeline latency: max(VAD, STT, LLM, TTS) (parallel processing)
- Streaming enables: STT emits partial transcripts before user finishes, LLM generates tokens as transcript arrives, TTS synthesizes from first sentence while LLM generates rest, audio playback begins while TTS renders later chunks

**Cascaded vs Speech-to-Speech (S2S):**

| Architecture | Description | Use Case | Trade-offs |
|--------------|-------------|----------|------------|
| Cascaded Pipeline (default 2026) | STT → LLM → TTS with text intermediary | Production deployments, regulated industries, tool calling | Transparency, debuggability, component flexibility, audit trails |
| Speech-to-Speech | Native audio-in/audio-out models (GPT-4o Realtime, Gemini 2.5 Flash) | Latency-sensitive conversational flows, simple fast exchanges | Lower latency for simple exchanges, less control, harder debugging |
| Hybrid | S2S for fast exchanges, cascaded for complex reasoning | Balanced approach for mixed workloads | Combines benefits of both, increased complexity |

**Barge-in and Interruption Handling:**

- VAD detects speech during agent TTS playback
- Automatic interruption event cancels active TTS playback
- Queued audio flushed immediately
- Pipeline restarts from STT stage
- Edge cases: filler sounds ("mm-hmm") shouldn't trigger full interruption, echo/agent audio leakage can cause false positives, mid-tool-call interruptions require decision (cancel or complete silently)
- Protection: `run_ctx.disallow_interruptions()` for irreversible operations, `await context.wait_for_playout()` to wait for agent completion

**Conversation History Management:**

- ChatContext object accumulates turns across session
- Every user message and agent response appended
- Handoffs to other agents pass ChatContext to preserve conversation
- Without ChatContext transfer, each agent starts with fresh context

### WebRTC Scaling

**SFU Scaling Benchmarks (c2-standard-16, 16-core):**

| Scenario | Publishers | Subscribers | Resolution/Bitrate | Finding |
|----------|------------|-------------|-------------------|---------|
| Audio-only | 10 | 1000 | 3kbps average audio | Large audio sessions with few speakers supported |
| Video room | 150 | 150 | 720p video | Large meeting scenario validated |
| Livestreaming | 1 | 3000 | 720p video | Broadcast-to-many scenario validated |

**Scaling Constraints:**

- Each room must fit within a single node (cannot split one room across multiple nodes)
- Many simultaneous rooms supported via distributed multi-node setup
- SFU work per participant: receive tracks (tens of packets/sec), forward to subscribers (decryption + encryption + packet processing + forwarding)
- Performance factors: number of tracks published, number of subscribers, data rate to each subscriber
- Load testing available via `lk load-test` CLI command

**Resource Planning:**

| Metric | Value | Source |
|--------|-------|--------|
| Max participants per node | 500 (configurable) | LiveKit SFU Architecture docs |
| Audio bitrate (large sessions) | 3kbps | LiveKit Benchmarking docs |
| Video resolution (benchmarks) | 720p | LiveKit Benchmarking docs |

### SFU Architecture

**Multi-SFU Coordination:**

- Redis required for distributed, multi-node setups
- Peer-to-peer routing via Redis ensures clients joining same room connect to same node
- Single node deployment: no external dependencies
- Distributed deployment: Redis as distributed state layer

**Redis Configuration:**

livekit.yaml -- distributed deployment configuration

See [deployment-examples/livekit-redis.yaml](deployment-examples/livekit-redis.yaml)

**Geographic Distribution and Edge Routing:**

- Multi-region nodes with region labels (e.g., us-east-1)
- Node selector configuration: kind: any, sort_by: random
- Load balancing across regions via geographic routing
- TLS everywhere for secure transport

**SFU vs MCU vs P2P:**

| Architecture | Description | Advantages | Disadvantages |
|--------------|-------------|-------------|----------------|
| SFU (Selective Forwarding Unit) | Forwards media tracks without manipulation | Scalable, flexible, per-track control, horizontal scaling | Higher downstream bandwidth (individual streams) |
| MCU (Multipoint Conferencing Unit) | Decodes, composites, re-encodes streams | Lower downstream bandwidth (single stream) | Poor scalability, limited flexibility, requires beefy hardware |
| P2P (Peer-to-Peer) | Direct peer connections | No server needed | Limited to 2-3 peers due to upstream bandwidth |

**LiveKit SFU Characteristics:**

- Written in Go, leveraging Pion WebRTC implementation
- Horizontally scalable: 1 to 100+ nodes with identical configuration
- Automatic bandwidth adaptation: measures subscriber downstream bandwidth, adjusts track parameters (resolution/bitrate)
- Client SDK handles adaptive streaming transparently

---

## Redis Performance

| Tier | Commands/Month | Price | Storage | Ops/sec |
|------|----------------|-------|---------|---------|
| Free | 500K | $0 | N/A | 10,000 |
| Pay-as-You-Go | Unlimited | $0.2/100K after free tier | N/A | 10,000 |
| Fixed | Unlimited | $10/month | 250MB | 10,000 |
| Enterprise | Unlimited | Custom | Custom | 100K+ |

**Sufficiency Validation:**

- Rate Limit SDK minimizes calls via caching
- 10,000 ops/sec sufficient for rate limiting, session storage, semantic caching
- Upstash contacts for upgrade when exceeding max ops/sec

---

## Fly.io Configuration

### Machines v2 Auto-Scaling

**Autostop/Autostart (Load-Based):**

- Creates a pool of Machines in one or more regions
- Fly Proxy starts/stops Machines based on load
- Machines never created or deleted, only started/stopped
- Suitable for predictable traffic patterns

**Metrics-Based Autoscaling:**

- Deploys autoscaler as separate application
- Polls metrics (Prometheus, Temporal workflows)
- Computes required Machine count based on defined metric
- Can create/delete Machines or stop/start existing Machines
- Supports scaling on custom metrics like `queue_depth`

**CPU Performance Characteristics:**

- Shared vCPUs: 5ms quota per 80ms period (6.25% baseline)
- Performance vCPUs: Full 80ms period (100% baseline)
- Bursting: Accumulates unused quota for burst periods
- Monitoring: CPU Quota Balance and Throttling in Managed Grafana
- Throttling occurs when burst balance depleted

**Scaling Effectiveness:**

- Effective for bursty workloads with idle periods
- Latency-sensitive applications benefit from burst capability
- Scaling decisions based on configurable thresholds
- Cost-efficient by only running needed capacity

---

## Related Documentation

- [30-ARCH-OVERVIEW.md](30-ARCH-OVERVIEW.md) - High-level architecture overview
- [ADR_083](22-PLAN-ADR-INDEX.md#adr_083) - Y-Sweet self-hosting decision
- [ADR_115](22-PLAN-ADR-INDEX.md#adr_115) - LiveKit Agents v2.0 decision