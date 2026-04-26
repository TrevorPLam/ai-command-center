---
steering: TO PARSE - READ INTRO
document_type: component_specification
module: CrossCutting
tier: infrastructure
component_count: 1
dependencies:
- FastAPI-Limiter 0.1.x
- Upstash Redis 1.x
motion_requirements:
- None
accessibility:
- Rate limit error messages accessible
performance:
- Sub-millisecond limit check
last_updated: 2026-04-25
version: 1.0
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Rate Limiting
RateLimitMiddleware|XCT|Middleware|-|S14|FastAPI-Limiter,Upstash Redis|Per-user,per-org,Retry-After header

#LIMITS|scope|endpoint|limit|window|burst|key
global|/v1/*|1000 req/min|60s|100|global
per-user|/v1/chat|100 req/min|60s|20|userId:endpoint
per-user|/v1/agent/execute|50 req/min|60s|10|userId:endpoint
per-org|/v1/*|500 req/min|60s|50|orgId:endpoint
per-model|/v1/chat|Claude:200/min,GPT:150/min,Gemini:100/min|60s|N/A|model:endpoint
semantic|/v1/search|Similarity dedup|N/A|N/A|embedding_hash

#STRATEGY|algorithm|storage|cleanup|cooldown
token-bucket|Upstash Redis|TTL expiry|Sliding window|Linear refill
fixed-window|Upstash Redis|TTL expiry|Reset on window|No refill
semantic|Upstash Redis|TTL 24h|Manual cleanup|N/A

#RESPONSE|status|headers|body|retry_after
429|Retry-After: {seconds}|{"error":"Rate limit exceeded","retry_after":30}|30s
200|X-RateLimit-Limit: {limit},X-RateLimit-Remaining: {remaining},X-RateLimit-Reset: {timestamp}|N/A|N/A

#CONFIG|env_var|default|description
RATE_LIMIT_ENABLED|true|Enable/disable rate limiting
RATE_LIMIT_GLOBAL_LIMIT|1000|Global requests per minute
RATE_LIMIT_USER_LIMIT|100|Per-user requests per minute
RATE_LIMIT_ORG_LIMIT|500|Per-org requests per minute
RATE_LIMIT_BURST_SIZE|20|Burst allowance
RATE_LIMIT_REDIS_URL|Upstash Redis URL|Redis connection string
RATE_LIMIT_COOLDOWN|30|Cooldown seconds after 429

#MONITORING|metric|threshold|alert|action
rate_limit_429_total|>100/hour|Slack|#incidents channel
rate_limit_user_burst|>10/min|Slack|Investigate abuse
rate_limit_org_burst|>50/min|Slack|Contact org admin
redis_connection_fail|>5/min|PagerDuty|Platform on-call
redis_memory|>80%|Slack|Scale cluster

#EXCEPTIONS|user_type|limit|justification|approval
admin|10x standard|Operational needs|Auto-approved
enterprise|5x standard|Contractual SLA|Auto-approved
internal|Unlimited|Development needs|IP allowlist
api_key|Custom limit|API key tier|Key-based routing

#TESTING|scenario|expected|test_method
global_limit|429 after 1000 req|Load test 1001 req
user_limit|429 after 100 req|Load test 101 req per user
org_limit|429 after 500 req|Load test 501 req per org
retry_after|Header present|429 response validation|Header check
cooldown|Request blocked|Backoff test|Cooldown verification
semantic|Dedup works|Similar query blocked|Embedding similarity test

#AUDIT|check|frequency|owner|action
limit_adjustments|Monthly|Platform|Review and adjust limits
abuse_detection|Daily|Security|Investigate patterns
redis_health|Continuous|Platform|Alert on failure
cost_analysis|Monthly|Platform|Upstash cost review

EOF
