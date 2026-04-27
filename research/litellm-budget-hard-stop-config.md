# LiteLLM Budget Enforcement Configuration Guide

**Research Date:** April 26, 2026  
**LiteLLM Version:** ≥1.83.7  
**Purpose:** Configure budget limits, hard-stop enforcement, and cost attribution for the AI Command Center proxy

---

## Executive Summary

LiteLLM provides multi-level budget enforcement (org, team, user, model) with synchronous pre-call checks. However, there are **critical discrepancies** with the project's requirements that must be addressed:

1. **Status Code Mismatch**: LiteLLM returns HTTP 400 for budget exhaustion, not HTTP 429 as required by rule AI-11
2. **Soft Budget Alerts**: Email alerting requires Enterprise license (15%/5% thresholds)
3. **Known Bugs**: User budget enforcement issues with team associations

This guide documents the full configuration, known limitations, and recommended workarounds.

---

## 1. Budget Enforcement Architecture

### 1.1 Multi-Level Budget Hierarchy

LiteLLM supports budgets at four levels, checked in this order:

1. **Virtual Key**: Key-specific budget (most granular)

2. **Team**: Team-level budget when key has `team_id`

3. **User**: User-level budget when key has `user_id`

4. **Global Proxy**: Proxy-wide budget in `litellm_settings`

**Precedence Logic:**

- If a virtual key has a budget, it is enforced first
- If key belongs to a team, team budget is checked
- User budget is checked if user has `max_budget` set
- Global proxy budget is checked last

**⚠️ Known Bug (#12905, #14097):** User budgets are ignored when a virtual key belongs to a team. The current LiteLLM code has a condition `(team_object is None or team_object.team_id is None)` that prevents user budget checks for team-associated keys.

**Workaround:** Set budgets at the key level instead of user level when using teams.

### 1.2 Budget Duration Windows

Budgets can have reset durations:
- `"30s"` - 30 seconds
- `"30m"` - 30 minutes
- `"30h"` - 30 hours
- `"30d"` - 30 days

If `budget_duration` is not set, the budget never resets (cumulative).

### Multiple Budget Windows
A single key can have multiple concurrent budget limits at different time scales:

```yaml
budget_limits:
  - budget_duration: "24h"
    max_budget: 10  # $10 per day
  - budget_duration: "30d"
    max_budget: 100 # $100 per month
```

Each window is tracked independently and resets on its own schedule.

---

## 2. Configuration Examples

### 2.1 Global Proxy Budget

**config.yaml**

```yaml
general_settings:
  master_key: sk-1234

litellm_settings:
  max_budget: 1000.0      # $1000 USD global limit
  budget_duration: "30d" # Reset monthly
```

### 2.2 Team Budget

**API Call:**

```bash
curl -X POST 'http://localhost:4000/team/new' \
  --header 'Authorization: Bearer sk-1234' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "team_alias": "engineering",
    "members_with_roles": [{
      "role": "admin",
      "user_id": "user-123"
    }],
    "max_budget": 500.0,
    "budget_duration": "30d"
  }'
```

**Soft Budget (Enterprise License Required)**

```bash

```bash
curl -X POST 'http://localhost:4000/team/update' \
  --header 'Authorization: Bearer sk-1234' \
  --header 'Content-Type: application/json' \

```bash
curl --location 'http://localhost:4000/user/new' \
  --header 'Authorization: Bearer sk-1234' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "user_id": "user@example.com",
    "max_budget": 50.0,
    "budget_duration": "30d"
  }'
```

### 2.4 Virtual Key Budget

**API Call:**

```bash
curl 'http://0.0.0.0:4000/key/generate' \
  --header 'Authorization: Bearer sk-1234' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "user_id": "user@example.com",
    "team_id": "team-uuid",
    "max_budget": 10.0,
    "budget_duration": "24h",
    "budget_limits": [
      {"budget_duration": "24h", "max_budget": 10},
      {"budget_duration": "30d", "max_budget": 100}
    ]
  }'
```

---

## 3. x-litellm-tags Propagation

### 3.1 Tag Passing Methods

**Method 1: Config File (Automatic)**

```yaml
model_list:
  - model_name: claude-sonnet-4-6
    litellm_params:
      model: anthropic/claude-sonnet-4-6
      api_key: os.environ/ANTHROPIC_API_KEY
      tags: ["production", "claude"]
```

**Method 2: Header (Dynamic)**

```bash
curl -X POST 'http://0.0.0.0:4000/chat/completions' \
  -H 'Authorization: Bearer sk-1234' \
  -H 'Content-Type: application/json' \
  -H 'x-litellm-tags: org-123,user-456,feature-calendar' \
  -d '{
    "model": "claude-sonnet-4-6",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

**Method 3: Request Body**

```bash
curl -X POST 'http://0.0.0.0:4000/chat/completions' \
  -H 'Authorization: Bearer sk-1234' \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "claude-sonnet-4-6",
    "messages": [{"role": "user", "content": "Hello"}],
    "tags": ["org-123", "user-456", "feature-calendar"]
  }'
```

### 3.2 Tag Precedence

1. Body tags override header tags
2. Header/body tags override config tags
3. If both header and body tags are provided, body tags take precedence

### 3.3 Project-Specific Tag Schema

Per rule AI-14, tags must carry:

- `org_id`: Organization identifier
- `user_id`: User identifier
- `feature`: Feature being used (e.g., "calendar", "chat", "conflict-detection")

**Recommended tag format:**

```
x-litellm-tags: org-{org_id},user-{user_id},feature-{feature}
```

---

## 4. Cost Header Emission

LiteLLM automatically emits cost tracking headers in responses:

| Header | Description | Example |
|--------|-------------|---------|
| `x-litellm-response-cost` | Cost of current request | `0.000214` |
| `x-litellm-key-spend` | Total spend for the key | `12.847` |
| `x-litellm-response-duration-ms` | Request duration | `842.3` |
| `x-litellm-overhead-duration-ms` | Proxy overhead | `15.1` |

**Example Response:**

```http
HTTP/1.1 200 OK
x-litellm-response-cost: 0.000214
x-litellm-key-spend: 12.847
x-litellm-response-duration-ms: 842.3
x-litellm-overhead-duration-ms: 15.1
```

These headers are emitted automatically and require no additional configuration.

---

## 5. Budget Exceeded Response

### 5.1 Actual LiteLLM Behavior

**Regular Budget Exceeded (Key, Team, User, Global):**

When a budget is exceeded, LiteLLM returns:

**Status Code:** HTTP 400 (Bad Request)  
**Response Body:**

```json
{
  "detail": "Authentication Error, ExceededTokenBudget: Current spend for token: 7.2e-05; Max Budget for Token: 2e-07"
}
```

**Agent Session Budget Exceeded:**

For Agent Gateway sessions with `max_budget_per_session`, LiteLLM returns:

**Status Code:** HTTP 429 (Too Many Requests)  
**Response Behavior:** Documented as receiving 429 when session exceeds limit

**Rule AI-11 Requirement:**

> "Synchronous pre-call budget check enforced at the LiteLLM proxy; if budget exceeded, return 429 and a cost limit banner"

**Actual Behavior:**

- Regular budgets (key, team, user, global): HTTP 400, not HTTP 429
- Agent session budgets: HTTP 429 (correct status code)
- The error message is in the response body, not a separate "banner"

### 5.3 Proposed Solution: FastAPI Middleware

To comply with rule AI-11, implement FastAPI middleware to transform budget errors:

```python
from fastapi import Request, Response
from fastapi.responses import JSONResponse
import json

async def budget_error_middleware(request: Request, call_next):
    response = await call_next(request)
    
    # Check if response is a budget exceeded error
    if response.status_code == 400:
        body = await response.body()
        try:
            data = json.loads(body)
            detail = data.get("detail", "")
            
            if "ExceededTokenBudget" in detail or "ExceededBudget" in detail:
                # Transform to 429 with cost limit banner
                return JSONResponse(
                    status_code=429,
                    content={
                        "error": {
                            "message": "Budget exceeded. Please contact administrator.",
                            "type": "budget_exceeded",
                            "code": "429",
                            "original_detail": detail
                        }
                    },
                    headers={
                        "X-Cost-Limit-Banner": "true",
                        "Retry-After": "86400"  # 24 hours
                    }
                )
        except (json.JSONDecodeError, KeyError):
            pass
    
    return response
```

**Integration**

```python
from fastapi import FastAPI

app = FastAPI()
app.middleware("http")(budget_error_middleware)
```

### 5.4 Alternative: Update Rule AI-11

If middleware is undesirable, update rule AI-11 to accept HTTP 400:

> "Synchronous pre-call budget check enforced at the LiteLLM proxy; if budget exceeded, return 400 with ExceededTokenBudget error and display cost limit banner in UI"

This would require frontend changes to parse the 400 error and display the banner.

---

## 6. Soft Budget Alert Limitations

### 6.1 Enterprise License Requirement

LiteLLM's soft budget alert feature (email notifications at 15%/5% thresholds) requires an **Enterprise license**. Without this license:

- Soft budget can be set but no email alerts are sent
- Custom alerting must be implemented via external monitoring

### 6.2 Alternative: Custom Monitoring via TimescaleDB

Implement custom alerting using TimescaleDB triggers on the `ai_cost_log` hypertable:

```sql
-- Trigger function to check budget thresholds
CREATE OR REPLACE FUNCTION check_budget_thresholds()
RETURNS TRIGGER AS $$
DECLARE
    current_spend NUMERIC;
    budget_limit NUMERIC;
    alert_threshold NUMERIC;
BEGIN
    -- Get current spend for the org/user
    SELECT COALESCE(SUM(cost), 0) INTO current_spend
    FROM ai_cost_log
    WHERE org_id = NEW.org_id
    AND created_at > NOW() - INTERVAL '30 days';
    
    -- Get budget limit from your budget table
    SELECT max_budget INTO budget_limit
    FROM budgets
    WHERE org_id = NEW.org_id;
    
    -- Check 15% threshold
    alert_threshold := budget_limit * 0.85;
    IF current_spend >= alert_threshold THEN
        -- Send alert (via pg_notify or external service)
        PERFORM pg_notify('budget_alert', 
            json_build_object(
                'org_id', NEW.org_id,
                'threshold', '15%',
                'current_spend', current_spend,
                'budget_limit', budget_limit
            )::text
        );
    END IF;
    
    -- Check 5% threshold
    alert_threshold := budget_limit * 0.95;
    IF current_spend >= alert_threshold THEN
        -- Send critical alert
        PERFORM pg_notify('budget_alert', 
            json_build_object(
                'org_id', NEW.org_id,
                'threshold', '5%',
                'current_spend', current_spend,
                'budget_limit', budget_limit
            )::text
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger

CREATE TRIGGER budget_threshold_trigger
AFTER INSERT ON ai_cost_log
FOR EACH ROW
EXECUTE FUNCTION check_budget_thresholds();
```

---

## 7. Known Bugs and Workarounds

### 7.1 Bug #12905: User Budget Not Enforced for Team Keys

**Issue:** User-level budget enforcement is bypassed when a virtual key belongs to a team.

**Root Cause:** Condition `(team_object is None or team_object.team_id is None)` in `/litellm/proxy/auth/auth_checks.py` prevents user budget checks for team-associated keys.

**Workaround:** Set budgets at the key level instead of user level when using teams:

```bash
# Instead of setting user budget:
curl 'http://localhost:4000/user/new' \
  --data '{"user_id": "user@example.com", "max_budget": 50.0}'

# Set key budget instead:
curl 'http://localhost:4000/key/generate' \
  --data '{
    "user_id": "user@example.com",
    "team_id": "team-uuid",
    "max_budget": 50.0
  }'
```

**Status:** Open issue as of April 2026. Monitor for fix in future LiteLLM releases.

### 7.2 Bug #12977: AzureOpenAI Client Bypass

**Issue:** Budget limitations can be bypassed by using the AzureOpenAI client library instead of the standard OpenAI client, despite both pointing to the same proxy endpoint.

**Workaround:** Enforce usage of the standard OpenAI client library in your application code:

```python
# CORRECT: Use standard OpenAI client
import openai
client = openai.OpenAI(
    api_key="sk-xxx",
    base_url="https://litellm-proxy-url"
)

# AVOID: AzureOpenAI client bypasses budget checks
from openai import AzureOpenAI
client = AzureOpenAI(
    api_key="sk-xxx",
    azure_endpoint="https://litellm-proxy-url",
    api_version="2023-05-15"
)
```

**Status:** Open issue as of April 2026.

### 7.3 Bug #14097: Budget & Limit Precedence Issues

**Issue:** User budgets and limits are ignored if a team is present. Customer budgets/limits are ignored when JWT tokens are used.

**Workaround:** Use key-level budgets as the primary enforcement mechanism when using teams or JWT authentication.

**Status:** Open issue as of April 2026. Proposed "First Limit Hit" logic not yet implemented.

### 7.4 Bug #15805: Pass-Through Endpoint Fix

**Issue:** Pass-through endpoints (like `/anthropic/v1/messages`) were not being checked for budget limits due to incorrect route matching logic.

**Status:** **FIXED** in PR #15805 (merged October 2025). Ensure LiteLLM version ≥1.83.7 includes this fix.

---

## 8. Recommended Configuration for AI Command Center

### 8.1 config.yaml

```yaml
general_settings:
  master_key: ${LITELLM_MASTER_KEY}

litellm_settings:
  max_budget: 10000.0      # $10,000 global limit
  budget_duration: "30d"   # Monthly reset

model_list:
  # Local models (Ollama)
  - model_name: gemma-4-e2b
    litellm_params:
      model: ollama/gemma-4-e2b
      api_base: http://localhost:11434
      tags: ["local", "orchestrator"]
  
  - model_name: qwen3.5-4b
    litellm_params:
      model: ollama/qwen3.5-4b
      api_base: http://localhost:11434
      tags: ["local", "tool-executor"]
  
  # Cloud models (Anthropic)
  - model_name: claude-sonnet-4-6
    litellm_params:
      model: anthropic/claude-sonnet-4-6
      api_key: ${ANTHROPIC_API_KEY}
      tags: ["cloud", "premium"]
  
  - model_name: claude-opus-4-7
    litellm_params:
      model: anthropic/claude-opus-4-7
      api_key: ${ANTHROPIC_API_KEY}
      tags: ["cloud", "premium"]
```

### 8.2 Budget Setup Script

```python
import requests
import os

LITELLM_URL = "http://localhost:4000"
MASTER_KEY = os.environ["LITELLM_MASTER_KEY"]

headers = {
    "Authorization": f"Bearer {MASTER_KEY}",
    "Content-Type": "application/json"
}

def create_team(org_id, budget):
    """Create a team with budget for an organization."""
    response = requests.post(
        f"{LITELLM_URL}/team/new",
        headers=headers,
        json={
            "team_alias": f"org-{org_id}",
            "max_budget": budget,
            "budget_duration": "30d"
        }
    )
    return response.json()

def create_user_key(user_id, team_id, budget):
    """Create a virtual key with budget for a user."""
    response = requests.post(
        f"{LITELLM_URL}/key/generate",
        headers=headers,
        json={
            "user_id": user_id,
            "team_id": team_id,
            "max_budget": budget,
            "budget_duration": "30d",
            "budget_limits": [
                {"budget_duration": "24h", "max_budget": budget / 30},
                {"budget_duration": "30d", "max_budget": budget}
            ]
        }
    )
    return response.json()

# Example usage
team = create_team("org-123", 500.0)
key = create_user_key("user-456", team["team_id"], 50.0)
print(f"Generated key: {key['key']}")
```

### 8.3 Client Integration

```python
import openai
import os

class AIClient:
    def __init__(self, org_id, user_id, feature):
        self.client = openai.OpenAI(
            api_key=os.environ["LITELLM_API_KEY"],
            base_url=os.environ["LITELLM_PROXY_URL"]
        )
        self.org_id = org_id
        self.user_id = user_id
        self.feature = feature
    
    def chat(self, model, messages):
        try:
            response = self.client.chat.completions.create(
                model=model,
                messages=messages,
                extra_headers={
                    "x-litellm-tags": f"org-{self.org_id},user-{self.user_id},feature-{self.feature}"
                }
            )
            return response
        except openai.BadRequestError as e:
            # Handle budget exceeded (HTTP 400)
            if "budget_exceeded" in str(e).lower():
                raise BudgetExceededError(str(e))
            raise

class BudgetExceededError(Exception):
    """Raised when budget limit is exceeded."""
    pass
```

---

## 9. Validation Steps

### 9.1 Test Budget Enforcement

1. Create a key with a small budget ($0.01)

2. Make requests until budget is exceeded

3. Verify response is HTTP 400 with `ExceededTokenBudget` error

4. Verify FastAPI middleware transforms to HTTP 429 (if implemented)

### 9.2 Test Tag Propagation

1. Make a request with `x-litellm-tags` header

2. Check `ai_cost_log` table in TimescaleDB

3. Verify tags are stored in the `tags` column

4. Verify cost attribution works by querying spend by tag

### 9.3 Test Cost Headers

1. Make a successful request

2. Verify response includes:
   - `x-litellm-response-cost`
   - `x-litellm-key-spend`

3. Verify values are accurate by comparing with TimescaleDB logs

### 9.4 Test Multi-Level Budgets

1. Set global proxy budget to $100

2. Set team budget to $50

3. Set user key budget to $10

4. Verify key budget is enforced first (most granular)

5. Verify team budget is enforced if key has no budget

6. Verify global budget is enforced as fallback

---

## 10. Monitoring and Alerting

### 10.1 TimescaleDB Queries

**Current spend by organization:**

```sql
SELECT 
    org_id,
    SUM(cost) as total_spend,
    COUNT(*) as request_count
FROM ai_cost_log
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY org_id
ORDER BY total_spend DESC;
```

**Spend by feature:**

```sql
SELECT 
    tags->>'feature' as feature,
    SUM(cost) as total_spend,
    COUNT(*) as request_count
FROM ai_cost_log
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY feature
ORDER BY total_spend DESC;
```

**Budget utilization:**

```sql
SELECT 
    o.org_id,
    o.max_budget,
    COALESCE(SUM(ac.cost), 0) as current_spend,
    (COALESCE(SUM(ac.cost), 0) / o.max_budget * 100) as utilization_percent
FROM organizations o
LEFT JOIN ai_cost_log ac ON o.org_id = ac.org_id
    AND ac.created_at > NOW() - INTERVAL '30 days'
GROUP BY o.org_id, o.max_budget
HAVING (COALESCE(SUM(ac.cost), 0) / o.max_budget) > 0.85
ORDER BY utilization_percent DESC;
```

### 10.2 Prometheus Metrics

LiteLLM exposes Prometheus metrics for budget tracking:

- `litellm_spend_total`: Total spend by key/user/team
- `litellm_requests_total`: Total requests by key/user/team
- `litellm_budget_remaining`: Remaining budget by key/user/team

Configure Prometheus scrape target in `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'litellm'
    static_configs:
      - targets: ['localhost:4000']
    metrics_path: '/metrics'
```

---

## 11. Security Considerations

### 11.1 API Key Security

- Never commit API keys to version control

- Use environment variables for all sensitive credentials

- Rotate master key regularly

- Use key aliases for easier identification without exposing key values

### 11.2 Budget Security

- Set reasonable default budgets to prevent runaway costs

- Implement rate limits in addition to budget limits

- Monitor for unusual spending patterns

- Set up alerts for budget exhaustion

### 11.3 Tag Security

- Validate tag values to prevent injection attacks

- Ensure org_id and user_id are authenticated before setting tags

- Use tag allowlist to prevent arbitrary tag values

---

## 12. References

- [LiteLLM Budget Documentation](https://docs.litellm.ai/docs/proxy/users)
- [LiteLLM Request Tags](https://docs.litellm.ai/docs/proxy/request_tags)
- [LiteLLM Response Headers](https://docs.litellm.ai/docs/proxy/response_headers)
- [LiteLLM Team Soft Budget Alerts](https://docs.litellm.ai/docs/proxy/ui_team_soft_budget_alerts)
- [Issue #12905: User Budget Not Enforced for Team Keys](https://github.com/BerriAI/litellm/issues/12905)
- [Issue #12977: AzureOpenAI Client Bypass](https://github.com/BerriAI/litellm/issues/12977)
- [Issue #14097: Budget & Limit Precedence](https://github.com/BerriAI/litellm/issues/14097)
- [PR #15805: Pass-Through Endpoint Fix](https://github.com/BerriAI/litellm/pull/15805)

---

## 13. Conclusion

LiteLLM provides robust budget enforcement capabilities, but the AI Command Center project must address:

1. **Status Code Transformation**: Implement FastAPI middleware to convert HTTP 400 → HTTP 429 for budget errors

2. **Custom Alerting**: Build TimescaleDB-based monitoring for 15%/5% thresholds (Enterprise license not available)

3. **Bug Workarounds**: Use key-level budgets instead of user-level when using teams; enforce standard OpenAI client usage

With these adjustments, the system can comply with rules AI-11 through AI-14 while leveraging LiteLLM's multi-level budget enforcement and cost attribution features.
