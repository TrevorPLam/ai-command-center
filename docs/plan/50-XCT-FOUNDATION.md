---
title: "Foundation Services"
owner: "Platform Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

Authentication, secrets management, rate limiting, and content security policy.

---

## Services

### Authentication & Organization Service

#### CrossCuttingAuthOrg
- **Module**: XCT (Cross-Cutting)
- **Type**: Service
- **Patterns**: `@Passkeys`
- **Rules**: S8 (Security rule 8)
- **Dependencies**: Supabase Auth, JWT custom access token hook
- **Purpose**: Handles authentication and organization switching
- **Features**:
  - Organization switching with cache clearing
  - Realtime client reconnection on org switch
  - Passkey/WebAuthn integration
  - JWT token management

### WebAuthn Implementation

#### SimpleWebAuthn Integration
- **Module**: XCT (Cross-Cutting)
- **Type**: Service
- **Patterns**: `@Passkeys`
- **Rules**: S8 (Security rule 8)
- **Dependencies**: `@simplewebauthn/server@^13.0.0`, `@simplewebauthn/browser`, Supabase Auth
- **Purpose**: Implements passkey-based authentication using SimpleWebAuthn library
- **Implementation Guide**:

#### RP Identification
```typescript
const rpName = 'AI Command Center';
const rpID = 'aicommandcenter.dev'; // 'localhost' for local dev
const origin = `https://${rpID}`;
```

#### Registration flow
1. Generate registration options (GET endpoint):
```typescript
import { generateRegistrationOptions } from '@simplewebauthn/server';

const user = getUserFromDB(loggedInUserId);
const userPasskeys = getUserPasskeys(user);

const options = await generateRegistrationOptions({
  rpName,
  rpID,
  userName: user.username,
  attestationType: 'none', // Recommended for smoother UX
  excludeCredentials: userPasskeys.map(passkey => ({
    id: passkey.id,
    transports: passkey.transports,
  })),
  authenticatorSelection: {
    residentKey: 'preferred', // Generates synced passkeys on Android
    userVerification: 'preferred',
    authenticatorAttachment: 'platform',
  },
});
setCurrentRegistrationOptions(user, options);
return options;
```

2. Verify registration response (POST endpoint):
```typescript
import { verifyRegistrationResponse } from '@simplewebauthn/server';

const verification = await verifyRegistrationResponse({
  response: body,
  expectedChallenge: currentOptions.challenge,
  expectedOrigin: origin,
  expectedRPID: rpID,
});

if (verification.verified) {
  const { registrationInfo } = verification;
  const { credentialID, credentialPublicKey, counter } = registrationInfo;
  savePasskeyToDB(user.id, credentialID, credentialPublicKey, counter);
}
```

#### Authentication flow
1. Generate authentication options (GET endpoint):
```typescript
import { generateAuthenticationOptions } from '@simplewebauthn/server';

const user = getUserFromDB(username);
const userPasskeys = getUserPasskeys(user);

const options = await generateAuthenticationOptions({
  rpID,
  userVerification: 'preferred',
  allowCredentials: userPasskeys.map(passkey => ({
    id: passkey.id,
    transports: passkey.transports,
  })),
});
setCurrentAuthenticationOptions(user, options);
return options;
```

2. Verify authentication response (POST endpoint):
```typescript
import { verifyAuthenticationResponse } from '@simplewebauthn/server';

const passkey = getPasskeyFromDB(credentialID);
const verification = await verifyAuthenticationResponse({
  response: body,
  expectedChallenge: currentOptions.challenge,
  expectedOrigin: origin,
  expectedRPID: rpID,
  authenticator: {
    credentialID: passkey.id,
    credentialPublicKey: passkey.publicKey,
    counter: passkey.counter,
  },
});

if (verification.verified) {
  updatePasskeyCounter(passkey.id, verification.authenticationInfo.newCounter);
  authenticateUser(user.id);
}
```

#### authenticatorSelection options
- `residentKey`: 'discouraged' (no synced passkeys on Android), 'preferred' (synced passkeys, consumes security key slots), 'required' (same as preferred)
- `userVerification`: 'discouraged' (no PIN prompt), 'preferred' (prompt when supported), 'required' (always prompt)
- `authenticatorAttachment`: 'platform' (device-bound), 'cross-platform' (security keys)

#### Best practices
- Store current options in session/temporary storage for verification
- Update passkey counter after each authentication to prevent replay attacks
- Use 'none' attestationType for smoother UX (no authenticator info collection)
- Implement excludeCredentials to prevent duplicate registration
- Support both platform and cross-platform authenticators for flexibility

### Supabase RPC Security

#### RPC Security Checklist
- **Module**: XCT (Cross-Cutting)
- **Type**: Security Pattern
- **Patterns**: `@RPCSecurity`
- **Rules**: S8 (Security rule 8)
- **Dependencies**: Supabase Postgres, Row Level Security (RLS)
- **Purpose**: Secures Remote Procedure Calls (RPCs) against unauthorized access and abuse
- **Security Checklist**:

#### Input validation
- Validate and sanitize all inputs using strict schemas (Zod)
- Use parameterized queries for all database interactions
- Never concatenate user input into SQL queries
- Validate data types, lengths, and formats at function entry
- Reject malformed requests immediately with 400 status

#### Authorization at entry point
- Verify caller identity using auth.uid() or JWT claims as first step
- Check specific role permissions (not just authentication status)
- For admin functions: Verify admin role in JWT claims
- For data export: Enforce strict pagination limits
- For password resets: Use cryptographically secure, single-use tokens
- Deny requests immediately if authorization fails

#### Rate limiting
- Implement global rate limits (e.g., 100 calls/hour per user)
- Apply stricter limits for sensitive operations (payment processing, account deletion)
- Use Upstash Redis for distributed rate limiting
- Return 429 status with retry-after header on limit exceeded
- Log rate limit violations for monitoring

#### Least privilege database roles
- Configure RPCs to run with dedicated database roles
- Grant minimum permissions necessary for task completion
- Example: Read-only function should not have write access
- Use SECURITY DEFINER with caution and audit
- Separate roles for different function categories (read, write, admin)

#### Error handling
- Return generic error messages to clients (no sensitive data exposure)
- Log detailed error information server-side
- Use structured error responses with error codes
- Implement proper error boundaries
- Avoid stack traces or internal details in responses

#### Audit logging
- Log all RPC invocations with timestamp, user, parameters
- Log authorization failures for security monitoring
- Log rate limit violations for abuse detection
- Integrate with SIEM for centralized monitoring
- Retain audit logs per compliance requirements (SOC2, HIPAA)

#### Testing scenarios
- Test with missing/invalid authentication tokens
- Test with insufficient permissions for role-based functions
- Test with SQL injection attempts in parameters
- Test with oversized payloads to prevent DoS
- Test rate limiting with burst requests
- Test error handling with various failure modes

### Upload Security Scanner

#### UploadSecurityScanner
- **Module**: UPSC (Upload Security)
- **Type**: Service
- **Patterns**: None
- **Rules**: S10 (Security rule 10)
- **Dependencies**: ClamAV (clamd)
- **Purpose**: Scans uploaded files for security threats
- **Features**:
  - Server-side scanning only
  - Chunked file processing
  - CVE monitoring
  - Version-pinned ClamAV

---

## Content Security Policy

### Overview

The Content Security Policy (CSP) defines approved sources of content to prevent XSS and data injection attacks. The policy uses nonce-based script execution with strict-dynamic for trusted scripts.

### Components

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| CSPPolicyProvider | XCT | Provider | - | S6, S7, S11 | helmet, nonce generator | Report-Only in pre-production |

### Policy Directives

| Directive | Value | Notes |
|-----------|-------|-------|
| default-src | 'self' | Only allow same-origin |
| script-src | 'nonce-{nonce}' 'strict-dynamic' 'unsafe-eval' https://cdn.jsdelivr.net | Nonce required, Monaco/Babel eval scoped |
| style-src | 'self' 'unsafe-inline' https://cdn.jsdelivr.net | Inline styles for Tailwind |
| style-src-attr | 'unsafe-inline' | Motion animations via inline styles |
| img-src | 'self' data: blob: https://*.supabase.co https://*.stripe.com | User uploads, external images |
| font-src | 'self' data: https://cdn.jsdelivr.net | Custom fonts |
| connect-src | 'self' https://*.supabase.co https://*.anthropic.com https://*.openai.com https://*.stripe.com https://*.nylas.com https://*.livekit.io | API endpoints |
| frame-src | 'self' https://*.stripe.com | Stripe Elements |
| worker-src | 'self' blob: | Service workers, blob URLs |
| object-src | 'none' | Block plugins |
| base-uri | 'self' | Prevent base tag attacks |
| form-action | 'self' | Prevent form submission to external |
| frame-ancestors | 'none' | Block embedding |
| report-uri | /api/csp-report | Violation reporting endpoint |
| report-to | csp-endpoint | Reporting API |

### Nonce Strategy

| Type | Generation | Scope | Validation | Rotation |
|------|------------|-------|------------|----------|
| per-request | Cryptographically random 16 bytes | Single request | Base64 validation | Not applicable |
| per-session | Cryptographically random 32 bytes | User session | JWT signature check | Session expiry |
| worker | Cryptographically random 24 bytes | Service worker | Worker scope validation | Worker update |

### Policy Exceptions

| Component | Directive | Exception | Justification | Mitigation |
|-----------|-----------|-----------|---------------|------------|
| Monaco Editor | script-src | 'unsafe-eval' | CodeMirror requires eval | Sandboxed iframe with separate CSP |
| Babel | script-src | 'unsafe-eval' | Transpilation requires eval | Sandboxed iframe with separate CSP |
| Motion | style-src-attr | 'unsafe-inline' | Dynamic animation values | Reduced motion check, values sanitized |
| Tailwind | style-src | 'unsafe-inline' | Runtime JIT compiler | CSP Report-Only monitoring |

### Violation Reporting

| Endpoint | Method | Payload | Retention | Alerting |
|----------|--------|---------|-----------|----------|
| /api/csp-report | POST | CSP report JSON | 90 days | Alert on repeated violations |
| csp-endpoint | Reporting API | CSP report JSON | 90 days | Alert on repeated violations |

### Testing Scenarios

| Scenario | Expected | Test Method |
|----------|----------|-------------|
| inline-script-blocked | Script blocked, CSP violation report | Schemathesis scan |
| eval-blocked | Eval blocked, CSP violation report | Monaco sandbox test |
| worker-src-blob | Worker allowed and executes | Service worker test |
| report-uri-called | Report sent to endpoint | CSP violation test |
| nonce-validation | Invalid nonce rejected, script blocked | Nonce tamper test |

### Enforcement Modes

| Environment | Mode | Block | Report | Upgrade |
|-------------|------|-------|----------|---------|
| production | enforce | Yes | Yes | No |
| staging | report-only | No | Yes | No |
| development | report-only | No | Yes | No |

### Audit Schedule

| Check | Frequency | Owner | Action |
|-------|-----------|-------|--------|
| CSP violations | Daily | Security | Investigate repeated violations |
| Directive review | Monthly | Security | Remove unused directives |
| Nonce leakage | Quarterly | Security | Verify nonce scope isolation |
| Report endpoint uptime | Continuous | Platform | Alert on endpoint failure |

---

## Rate Limiting

### Overview

The rate limiting system protects the API from abuse and ensures fair resource allocation across users and organizations. It uses a token-bucket algorithm with Upstash Redis for distributed state management.

### Components

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| RateLimitMiddleware | XCT | Middleware | - | S14 | FastAPI-Limiter, Upstash Redis | Per-user, per-org, Retry-After header |

### Rate Limits

| Scope | Endpoint | Limit | Window | Burst | Key |
|-------|----------|-------|--------|-------|-----|
| global | /v1/* | 1000 req/min | 60s | 100 | global |
| per-user | /v1/chat | 100 req/min | 60s | 20 | userId:endpoint |
| per-user | /v1/agent/execute | 50 req/min | 60s | 10 | userId:endpoint |
| per-org | /v1/* | 500 req/min | 60s | 50 | orgId:endpoint |
| per-model | /v1/chat | Claude:200/min, GPT:150/min, Gemini:100/min | 60s | N/A | model:endpoint |
| semantic | /v1/search | Similarity dedup | N/A | N/A | embedding_hash |

### Rate Limiting Strategies

| Algorithm | Storage | Cleanup | Cooldown |
|-----------|---------|---------|----------|
| token-bucket | Upstash Redis | TTL expiry | Sliding window, linear refill |
| fixed-window | Upstash Redis | TTL expiry | Reset on window, no refill |
| semantic | Upstash Redis | TTL 24h | Manual cleanup |

**Rate Limiting Implementation Examples:**

```typescript
// Token Bucket Algorithm (burst tolerance)
import { Ratelimit } from "@upstash/ratelimit";
import { Redis } from "@upstash/redis";

const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL,
  token: process.env.UPSTASH_REDIS_REST_TOKEN,
});

// Token bucket: refills 5 tokens every 10 seconds, max 10 tokens
const ratelimit = new Ratelimit({
  redis: redis,
  limiter: Ratelimit.tokenBucket(5, "10 s", 10),
  analytics: true,
});

// Fixed Window Algorithm (simple, allows bursts at boundaries)
const fixedWindowLimit = new Ratelimit({
  redis: redis,
  limiter: Ratelimit.fixedWindow(10, "10 s"),
});

// Sliding Window Algorithm (smoother, more expensive)
const slidingWindowLimit = new Ratelimit({
  redis: redis,
  limiter: Ratelimit.slidingWindow(10, "10 s"),
});

// Usage in API handler
const identifier = "api"; // or userId, apiKey, ipAddress
const result = await ratelimit.limit(identifier);

if (!result.success) {
  // Rate limit exceeded
  res.setHeader('X-RateLimit-Limit', result.limit);
  res.setHeader('X-RateLimit-Remaining', result.remaining);
  res.status(429).json({
    error: "Rate limit exceeded",
    retry_after: result.reset,
  });
  return;
}

// Request allowed
res.setHeader('X-RateLimit-Limit', result.limit);
res.setHeader('X-RateLimit-Remaining', result.remaining);
```

### Response Format

| Status | Headers | Body |
|--------|---------|------|
| 429 | Retry-After: {seconds} | `{"error":"Rate limit exceeded","retry_after":30}` |
| 200 | X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset | N/A |

### Configuration

| Environment Variable | Default | Description |
|----------------------|---------|-------------|
| RATE_LIMIT_ENABLED | true | Enable/disable rate limiting |
| RATE_LIMIT_GLOBAL_LIMIT | 1000 | Global requests per minute |
| RATE_LIMIT_USER_LIMIT | 100 | Per-user requests per minute |
| RATE_LIMIT_ORG_LIMIT | 500 | Per-org requests per minute |
| RATE_LIMIT_BURST_SIZE | 20 | Burst allowance |
| RATE_LIMIT_REDIS_URL | Upstash Redis URL | Redis connection string |
| RATE_LIMIT_COOLDOWN | 30 | Cooldown seconds after 429 |

### Monitoring & Alerting

| Metric | Threshold | Alert | Action |
|--------|-----------|-------|--------|
| rate_limit_429_total | >100/hour | Slack | #incidents channel |
| rate_limit_user_burst | >10/min | Slack | Investigate abuse |
| rate_limit_org_burst | >50/min | Slack | Contact org admin |
| redis_connection_fail | >5/min | PagerDuty | Platform on-call |
| redis_memory | >80% | Slack | Scale cluster |

### Exceptions

| User Type | Limit | Justification | Approval |
|-----------|-------|---------------|----------|
| admin | 10x standard | Operational needs | Auto-approved |
| enterprise | 5x standard | Contractual SLA | Auto-approved |
| internal | Unlimited | Development needs | IP allowlist |
| api_key | Custom limit | API key tier | Key-based routing |

### Testing Scenarios

| Scenario | Expected | Test Method |
|----------|----------|-------------|
| global_limit | 429 after 1000 req | Load test 1001 req |
| user_limit | 429 after 100 req | Load test 101 req per user |
| org_limit | 429 after 500 req | Load test 501 req per org |
| retry_after | Header present | Header check on 429 response |
| cooldown | Request blocked | Backoff test |
| semantic | Dedup works | Embedding similarity test |

### Audit Schedule

| Check | Frequency | Owner | Action |
|-------|-----------|-------|--------|
| limit_adjustments | Monthly | Platform | Review and adjust limits |
| abuse_detection | Daily | Security | Investigate patterns |
| redis_health | Continuous | Platform | Alert on failure |
| cost_analysis | Monthly | Platform | Upstash cost review |

---

## Secrets Management

### Overview

The secrets management system provides secure storage, rotation, and injection of sensitive credentials across all environments. It combines Doppler for development workflow and HashiCorp Vault for production-grade secret management with automated rotation.

### Components

| Component | Module | Type | Patterns | Rules | Dependencies | Notes |
|-----------|--------|------|----------|-------|--------------|-------|
| SecretsProvider | XCT | Provider | - | S8 | Doppler, Vault Agent | Per-environment env vars, 90/180/30-day rotation |

### Doppler Configuration

| Project | Environment | Sync | Integration | Audit |
|---------|-------------|------|-------------|-------|
| ai-command-center | production | Automatic | GitHub Actions, Doppler GH Actions | Secret access logs |
| ai-command-center | staging | Automatic | GitHub Actions, Doppler GH Actions | Secret access logs |
| ai-command-center | development | Automatic | Local CLI, Doppler CLI | Secret access logs |

### Vault Secret Management

| Secret | Rotation | Backup | Recovery | Audit |
|--------|----------|--------|----------|-------|
| JWT signing keys | 90 days | Auto-shamir backup | Recovery keys split | Access logs |
| Stripe keys | 180 days | Auto-shamir backup | Recovery keys split | Access logs |
| MCP OAuth client secrets | 90 days | Auto-shamir backup | Recovery keys split | Access logs |
| LLM API keys | 30 days | Auto-shamir backup | Recovery keys split | Access logs |
| Database credentials | 90 days | Auto-shamir backup | Recovery keys split | Access logs |

### Rotation Schedule

| Secret | Trigger | Method | Downtime | Notification |
|--------|---------|--------|----------|--------------|
| JWT signing | 90 days | Vault cron | Zero-downtime | Slack 7 days before |
| Stripe keys | 180 days | Vault cron | Zero-downtime | Slack 7 days before |
| MCP OAuth | 90 days | Vault cron | Zero-downtime | Slack 7 days before |
| LLM keys | 30 days | Vault cron | Zero-downtime | Slack 3 days before |
| DB credentials | 90 days | Vault cron | Zero-downtime | Slack 7 days before |

### Secret Injection

| Service | Method | Path | Validation | Fallback |
|---------|--------|------|------------|----------|
| FastAPI | Vault Agent sidecar | /vault/secrets | Signature verification | Doppler fallback |
| Fly.io | Vault Agent sidecar | /vault/secrets | Signature verification | Doppler fallback |
| GitHub Actions | doppler run | Doppler CLI | Signature verification | Manual approval |
| Local Dev | Doppler CLI | Doppler CLI | Signature verification | Env file |

### Encryption Standards

| Algorithm | Key Size | Rotation | Storage | Backup |
|-----------|----------|----------|---------|--------|
| AES-256-GCM | 256 bits | 90 days | Vault transit | Shamir backup |
| RSA-4096 | 4096 bits | 180 days | Vault transit | Shamir backup |
| ECDSA P-256 | 256 bits | 90 days | Vault transit | Shamir backup |

### Compliance Mapping

| Requirement | Control | Evidence | Frequency | Owner |
|-------------|---------|----------|-----------|-------|
| SOC2 | Secret rotation | Vault audit logs | Quarterly | GRC |
| SOC2 | Secret access | Doppler access logs | Quarterly | GRC |
| SOC2 | Encryption | Vault transit logs | Quarterly | GRC |
| SOC2 | Backup | Shamir backup verification | Quarterly | GRC |
| GDPR | Data minimization | Secret scope audit | Quarterly | GRC |
| EU AI Act | Key management | Key rotation logs | Quarterly | GRC |

### Incident Response

| Scenario | Response | Recovery | Prevention | Timeline |
|----------|----------|----------|------------|----------|
| Secret leaked | Revoke all keys, rotate | Generate new keys | Reduce access scope | <1 hour |
| Vault down | Doppler fallback | Resume operations | Multi-region Vault | <15 minutes |
| Rotation failed | Manual rotation | Generate new keys | Retry with backoff | <4 hours |
| Access lost | Recovery keys | Restore access | Split recovery keys | <2 hours |

### Testing Scenarios

| Scenario | Expected | Test Method |
|----------|----------|-------------|
| Secret fetch | Secret retrieved from Vault | Integration test |
| Rotation success | Key rotated successfully | Integration test |
| Vault down | Doppler fallback activates | Chaos test |
| Access denied | Access blocked | Security test |
| Encryption valid | Data encrypts/decrypts | Unit test |

### Vault Configuration

#### Auto-Unseal with AWS KMS

Vault uses AWS KMS for automated unsealing, eliminating manual intervention after restarts. The configuration uses the `seal "awskms"` stanza in Vault's HCL configuration file.

**Configuration Example:**

```hcl
seal "awskms" {
  region     = "us-east-1"
  kms_key_id = "alias/vault-unseal-key"
  # Credentials can be provided via:
  # - IAM instance profile (recommended for EC2)
  # - Environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
  # - AWS shared credentials file (~/.aws/credentials)
  # Optional: endpoint for VPC endpoint usage
  endpoint = "https://vpce-0e1bb1852241f8cc6-pzi0do8n.kms.us-east-1.vpce.amazonaws.com"
}
```

**Authentication Methods:**

| Method | Use Case | Security Level |
|--------|----------|---------------|
| IAM Instance Profile | EC2/Fly.io deployments | Highest (no credentials in config) |
| Environment Variables | Container deployments | High (credentials in env, not file) |
| AWS Credentials File | Local development | Medium (credentials in ~/.aws) |

**Best Practices:**

- Use IAM instance profiles for production deployments to avoid storing credentials
- Configure VPC endpoints for KMS to keep traffic within AWS network
- Use separate KMS key for each Vault cluster
- Enable KMS key rotation (annual rotation recommended by AWS)
- Grant minimum IAM permissions: `kms:Decrypt`, `kms:Encrypt`, `kms:DescribeKey`

**Transit Auto-Unseal Alternative:**

For environments without cloud KMS access, Vault can use a separate "unsealing Vault" cluster with the transit secrets engine:

```hcl
seal "transit" {
  address         = "https://unsealing-vault.example.com:8200"
  token           = "s.1234567890abcdef" # Stored in environment variable
  disable_renewal = "false"
  key_name        = "unseal-key"
  mount_path      = "transit"
}
```

The unsealing Vault cluster:
- Runs as a single-node cluster with minimal resources
- Uses filesystem storage backend for simplicity
- Requires token with encrypt/decrypt permissions on transit key
- Becomes a critical security component in the protection chain

### Vault Encryption

#### Transit Performance Impact

Vault's Transit secrets engine provides encryption-as-a-service with measurable performance characteristics. The recommended envelope encryption pattern minimizes overhead.

**Performance Benchmarks:**

| Operation | p50 Latency | p99 Latency | Throughput | Notes |
|-----------|-------------|-------------|------------|-------|
| DEK Wrapping (encrypt) | 0.46ms | 0.63ms | ~97K ops/week | Vault-side processing only |
| DEK Unwrapping (decrypt) | 0.46ms | 0.63ms | ~97K ops/week | Vault-side processing only |
| Direct Encryption (deprecated) | 5-10ms | 20-30ms | ~10K ops/min | Sends full payload to Vault |

**Envelope Encryption Pattern:**

The envelope encryption pattern separates key management from data encryption:

1. **Application requests DEK** from Vault Transit: `POST /transit/datakey/plaintext`
2. **Vault returns** plaintext DEK + encrypted DEK (EDK)
3. **Application encrypts data locally** using plaintext DEK
4. **Application stores** encrypted data + EDK together
5. **To decrypt**: Request Vault to unwrap EDK, get plaintext DEK back, decrypt locally

**Performance Impact Analysis:**

| Scenario | Vault Overhead | Total Latency | Recommendation |
|----------|----------------|---------------|----------------|
| Envelope encryption (recommended) | 0.46ms per DEK operation | 0.46ms + local AES (~0.01ms) | Use for all production workloads |
| Direct encryption (not recommended) | 5-10ms per full payload | 5-10ms + network overhead | Avoid - sends sensitive data to Vault |
| No Vault encryption | N/A | Local AES only (~0.01ms | Use for non-sensitive data only |

**Key Caching Strategy:**

- DEK caching recommended: Cache plaintext DEKs with appropriate TTL (e.g., 1-24 hours)
- Balance security vs performance: Shorter TTL = more Vault calls, longer TTL = reduced rotation effectiveness
- Ariso.ai case study: 8:1 encrypt-to-decrypt ratio confirms DEK caching is effective
- Implement cache invalidation on secret rotation events

**Transit Engine Load Characteristics:**

- Transit is one of the most taxing operations on Vault server (runs encryption algorithm)
- High concurrent transit requests can impact overall Vault performance
- Monitor `vault.barrier.estimated_encryptions` metric for key rotation triggers
- Consider dedicated Vault cluster for high-volume transit operations

### Secret Rotation

#### Rotation Procedure

Vault supports automated secret rotation with zero-downtime operations. The 90-day rotation interval aligns with NIST SP 800-38D recommendations for AES-256-GCM keys.

**NIST Guidance:**

- NIST SP 800-38D recommends rotating AES-256-GCM keys before ~2^32 encryptions
- Vault monitors `vault.barrier.estimated_encryptions` metric and auto-rotates backend encryption key
- 90-day rotation is conservative and provides margin for high-volume workloads
- Manual rotation can be triggered via `vault operator rotate` command

**Rotation Workflow:**

```bash
# 1. Trigger rotation (automated via Vault cron or manual)
vault operator rotate

# 2. Vault generates new internal encryption key
# 3. Vault adds new key to internal keyring
# 4. Vault creates temporary upgrade key (for HA standby nodes)
# 5. New writes use new key, old keys still decrypt legacy data
# 6. Old keys retained for data decryption
```

**Key Types and Rotation:**

| Key Type | Rotation Interval | Method | Downtime | Backup |
|----------|-------------------|--------|----------|--------|
| Internal encryption key | Auto (~2^32 encryptions) | Vault auto-rotate | Zero | Shamir backup |
| Root key (unseal key) | 180 days | Vault rekey | Zero | Shamir backup |
| Transit encryption keys | 90 days | Vault rotate | Zero | Key versioning |
| Application secrets (API keys) | 30-180 days | Custom automation | Zero | Vault audit logs |

**Automation Script Example:**

```bash
#!/bin/bash
# rotate-secret.sh - Automated secret rotation with notification

SECRET_PATH="secret/data/application/api-key"
NOTIFICATION_WEBHOOK="${SLACK_WEBHOOK_URL}"

# 1. Rotate the secret
vault kv patch $SECRET_PATH value="$(openssl rand -base64 32)"

# 2. Notify downstream services
curl -X POST $NOTIFICATION_WEBHOOK \
  -H 'Content-Type: application/json' \
  -d '{"text":"Secret rotated: '$SECRET_PATH'. Services should reload."}'

# 3. Log to audit system
vault audit hash -format=json | grep "$SECRET_PATH" >> /var/log/vault/rotation.log
```

**Operational Overhead Analysis:**

| Task | Frequency | Duration | Automation Level | Complexity |
|------|-----------|----------|------------------|------------|
| JWT signing key rotation | 90 days | 2-5 min | Fully automated | Low |
| Database credential rotation | 90 days | 5-15 min | Semi-automated (app restart) | Medium |
| API key rotation | 30-180 days | 1-5 min | Fully automated | Low |
| Root key rekey | 180 days | 10-20 min | Manual (requires Shamir keys) | High |
| Backup verification | Quarterly | 30-60 min | Manual | Medium |

**Zero-Downtime Rotation Strategy:**

1. **Pre-rotation notification**: Send alert 7 days before scheduled rotation
2. **Generate new secret**: Create new credential in Vault without deprecating old
3. **Deploy to canary**: Test new secret in canary environment
4. **Gradual rollout**: Update services incrementally (blue-green deployment)
5. **Deprecate old secret**: Mark old secret as deprecated after 24-48 hours
6. **Delete old secret**: Remove after 7-30 days (retention policy)

### Doppler Configuration

#### Geo-Redundancy and SLA

Doppler provides cloud-based secrets management with defined service level objectives and maintenance policies.

**Service Level Objective (SLO):**

| Metric | Target | Exclusions | Measurement Period |
|--------|--------|------------|-------------------|
| Uptime | 99.95% | Scheduled maintenance | Quarterly |
| Maintenance downtime | ≤5 minutes | N/A | Per quarter |
| Data durability | 99.999999% | N/A | Annual |
| API response time | <200ms p95 | N/A | Monthly |

**Maintenance Policy:**

- Maintenance events scheduled in advance are excluded from SLO calculation
- Doppler aims to minimize maintenance events
- Typical maintenance limited to no more than 5 minutes of downtime per quarter
- Maintenance notifications sent via email, status page, and webhook alerts

**Infrastructure Architecture:**

| Component | Redundancy | Disaster Recovery | Notes |
|-----------|------------|-------------------|-------|
| Application servers | Multi-AZ | Automatic failover | Auto-scaling across availability zones |
| Database | Multi-region replica | Cross-region promotion | Streaming replication with PITR |
| CDN/Edge | Global edge network | Automatic failover | Cloudflare edge network |
| API gateway | Multi-region | DNS-based failover | Route53 health checks |

**Data Replication:**

- Primary region: US-East (default)
- Replica regions: US-West, EU-West (configurable per project)
- Replication method: Streaming with write-ahead logging
- RPO (Recovery Point Objective): <1 second for cross-region
- RTO (Recovery Time Objective): <5 minutes for automatic failover

**Integration with Cloud Providers:**

Doppler can sync secrets to cloud-native secret managers for hybrid deployments:

| Cloud Provider | Integration | Replication | Use Case |
|---------------|-------------|-------------|----------|
| AWS | AWS Secrets Manager | Automatic (multi-region) | Lambda, EC2, ECS workloads |
| GCP | GCP Secret Manager | Automatic (multi-region) | GKE, Cloud Functions |
| Azure | Azure Key Vault | Manual | Azure Functions, AKS |

**Configuration Example:**

```yaml
# Doppler project configuration
project: ai-command-center
environments:
  - name: production
    config: prod
    sync:
      - target: github-actions
        repo: org/repo
        environment: production
      - target: aws-secrets-manager
        region: us-east-1
        replication: automatic
  - name: staging
    config: staging
    sync:
      - target: github-actions
        repo: org/repo
        environment: staging
```

**Failover Procedure:**

1. **Detection**: Automated monitoring detects region outage
2. **DNS failover**: Route53 health checks trigger DNS update
3. **Application reconnection**: Apps reconnect to new region endpoint
4. **Data consistency**: Streaming replication ensures minimal data loss
5. **Recovery timeline**: <5 minutes for automatic failover

### CI/CD Secrets

#### GitHub Actions Integration Security

GitHub Actions secrets integration follows security best practices using OIDC for cloud provider authentication and comprehensive audit logging.

**Authentication Methods:**

| Method | Security Level | Use Case | Pros | Cons |
|--------|----------------|----------|------|------|
| OIDC (recommended) | Highest | Cloud provider access | Short-lived tokens, no long-lived credentials | Requires OIDC provider configuration |
| GitHub Secrets | Medium | General secrets | Simple to use | Long-lived credentials stored in GitHub |
| Doppler sync | High | Centralized management | Single source of truth, audit trails | Requires Doppler integration |
| Vault Agent | Highest | Production secrets | Zero-trust, rotation support | Complex setup |

**OIDC Integration Example:**

```yaml
# .github/workflows/deploy.yml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write  # Required for OIDC
      contents: read
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions-role
          aws-region: us-east-1

      - name: Deploy to production
        run: |
          # AWS credentials are now available as environment variables
          aws s3 sync ./dist s3://production-bucket
```

**Security Checklist:**

| Control | Implementation | Verification |
|---------|----------------|--------------|
| OIDC authentication | Configure AWS/Azure/GCP OIDC providers | Test token issuance and expiration |
| Secret access restrictions | Environment protection rules | Verify secrets only available after approval |
| Audit logging | Enable GitHub audit log | Review org.update_actions_secret events |
| Secret scanning | GitHub Advanced Security | Scan for leaked secrets in commits |
| Dependency pinning | Pin action versions in workflows | Verify no unpinned actions |
| Branch protection | Require approval for production deployments | Verify branch rules enforced |

**Audit Log Events:**

| Event | Description | Retention |
|-------|-------------|-----------|
| org.update_actions_secret | Organization secret updated | 90 days |
| repo.update_actions_secret | Repository secret updated | 90 days |
| workflow_run | Workflow execution | 90 days |
| oidc_token_requested | OIDC token issued | 90 days |

**Audit Log Query Example:**

```bash
# Query audit log for secret changes
gh api /orgs/ORG_NAME/audit-log \
  --jq '.[] | select(.action == "org.update_actions_secret")' \
  --paginate
```

**Doppler + GitHub Actions Integration:**

```yaml
# .github/workflows/ci.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Install Doppler CLI
        run: |
          curl -Ls https://cli.doppler.com/install.sh | sh

      - name: Load secrets from Doppler
        run: |
          doppler run -- ./test-script.sh
        env:
          DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN }}
          DOPPLER_PROJECT: ai-command-center
          DOPPLER_CONFIG: production
```

**Security Best Practices:**

1. **Use OIDC for cloud authentication**: Eliminate long-lived credentials
2. **Environment protection rules**: Require approval for production secrets
3. **Secret rotation**: Rotate secrets regularly (30-90 days)
4. **Audit log review**: Monthly review of secret access events
5. **Least privilege**: Grant minimum required permissions to workflows
6. **Branch protection**: Require approval for workflow modifications
7. **Dependabot**: Keep actions updated with Dependabot version updates

### Automation

#### Secret Rotation Automation

Automated secret rotation workflows ensure regular credential updates without manual intervention, reducing security risk and operational overhead.

**Rotation Automation Architecture:**

```
┌─────────────┐
│  Scheduler  │ (Vault cron / GitHub Actions cron)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Rotation    │ (Generate new secret)
│  Script     │
└──────┬──────┘
       │
       ├───► Update Vault
       ├───► Update Doppler
       ├───► Notify services (webhook)
       └───► Log to audit system
```

**GitHub Actions Automation Example:**

```yaml
# .github/workflows/rotate-secrets.yml
name: Rotate Secrets
on:
  schedule:
    - cron: '0 0 1 * *'  # Monthly on 1st of month
  workflow_dispatch:

jobs:
  rotate:
    runs-on: ubuntu-latest
    steps:
      - name: Install Doppler CLI
        run: curl -Ls https://cli.doppler.com/install.sh | sh

      - name: Rotate API key
        run: |
          # Generate new secret
          NEW_SECRET=$(openssl rand -base64 32)

          # Update Doppler
          doppler secrets set API_KEY "$NEW_SECRET" \
            --project ai-command-center \
            --config production

          # Trigger service reload
          curl -X POST ${{ secrets.RELOAD_WEBHOOK }} \
            -H 'Content-Type: application/json' \
            -d '{"action":"reload_secrets"}'

          # Log rotation
          echo "$(date): Rotated API_KEY" >> rotation.log
        env:
          DOPPLER_TOKEN: ${{ secrets.DOPPLER_SERVICE_TOKEN }}
```

**Vault Rotation Automation:**

```bash
# /etc/vault/scripts/rotate.sh
#!/bin/bash

# Rotate database credentials
vault kv patch secret/database \
  username="app_$(date +%s)" \
  password="$(openssl rand -base64 32)"

# Restart application (via systemd)
systemctl restart application

# Notify Slack
curl -X POST $SLACK_WEBHOOK \
  -H 'Content-Type: application/json' \
  -d '{"text":"Database credentials rotated"}'
```

**Automation Schedule:**

| Secret Type | Rotation Frequency | Automation Tool | Notification |
|-------------|-------------------|-----------------|--------------|
| LLM API keys | 30 days | GitHub Actions cron | Slack 3 days before |
| JWT signing keys | 90 days | Vault cron | Slack 7 days before |
| Database credentials | 90 days | Vault cron + systemd | Slack 7 days before |
| Stripe keys | 180 days | GitHub Actions manual | Slack 7 days before |
| MCP OAuth secrets | 90 days | Vault cron | Slack 7 days before |

**Workflow Diagram:**

```
┌─────────────────────────────────────────────────────────┐
│                    Rotation Trigger                      │
│            (Scheduled: 90 days / Manual)                │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              Pre-Rotation Notification                    │
│         (Slack: 7 days before, Email: 3 days)           │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              Generate New Credential                     │
│          (Vault: vault kv patch / OpenSSL)               │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              Update Secret Stores                        │
│     (Vault + Doppler + Cloud Provider sync)              │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              Canary Deployment Test                       │
│              (Test in staging environment)               │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              Gradual Rollout                             │
│         (Blue-green deployment, 10% increments)          │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              Deprecate Old Credential                     │
│              (Mark as deprecated, 48h grace)              │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              Delete Old Credential                        │
│              (After 7-30 day retention)                   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│              Post-Rotation Audit                          │
│         (Log to audit system, update inventory)           │
└─────────────────────────────────────────────────────────┘
```

**Rollback Procedure:**

If rotation fails:

1. **Immediate rollback**: Restore previous secret from Vault version history
2. **Service recovery**: Restart affected services with old secret
3. **Incident response**: Create incident ticket, notify on-call
4. **Root cause analysis**: Investigate failure (automation bug, service dependency)
5. **Fix automation**: Update rotation script to prevent recurrence
6. **Retry rotation**: Schedule retry with additional testing

**Monitoring and Alerting:**

| Metric | Threshold | Alert | Action |
|--------|-----------|-------|--------|
| Rotation failure | Any failure | PagerDuty | Manual intervention |
| Rotation duration | >30 minutes | Slack | Investigate bottleneck |
| Service downtime | >5 minutes | PagerDuty | Rollback secret |
| Secret sync failure | Any failure | Slack | Manual sync |

### Audit Schedule

| Check | Frequency | Owner | Action |
|-------|-----------|-------|--------|
| Secret inventory | Monthly | Platform | Update secret catalog |
| Access review | Quarterly | GRC | Review access, remove unused |
| Rotation compliance | Monthly | Security | Verify all rotations |
| Backup verification | Quarterly | Platform | Test recovery keys |
