---
steering: TO PARSE - READ INTRO
file_name: 05-XCT-SECRETS.md
document_type: component_specification
module: CrossCutting
tier: infrastructure
status: stable
owner: Platform Engineering
component_count: 1
dependencies:
- Doppler
- HashiCorp Vault
motion_requirements:
- None
accessibility:
- N/A
performance:
- <100ms secret fetch
last_updated: 2026-04-25
version: 1.0
dependencies: [01-PLAN-LEXICON.md, 09-REF-KNOWLEDGE.md]
related_adrs: [ADR_063]
related_rules: [S8, SECREC01]
complexity: high
risk_level: critical
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// Secrets Management
SecretsProvider|XCT|Provider|-|S8|Doppler,Vault Agent|Env vars per environment,90/180/30d rotation

#DOPPLER|project|environment|sync|integration|audit
ai-command-center|production|Automatic|GitHub Actions,Doppler GH Actions|Secret access logs
ai-command-center|staging|Automatic|GitHub Actions,Doppler GH Actions|Secret access logs
ai-command-center|development|Automatic|Local CLI,Doppler CLI|Secret access logs

#VAULT|secret|rotation|backup|recovery|audit
JWT signing keys|90 days|Auto-shamir backup|Recovery keys split|Access logs
Stripe keys|180 days|Auto-shamir backup|Recovery keys split|Access logs
MCP OAuth client secrets|90 days|Auto-shamir backup|Recovery keys split|Access logs
LLM API keys|30 days|Auto-shamir backup|Recovery keys split|Access logs
Database credentials|90 days|Auto-shamir backup|Recovery keys split|Access logs

#ROTATION|secret|trigger|method|downtime|notification
JWT signing|90 days|Vault cron|Zero-downtime key rotation|Slack 7d before
Stripe keys|180 days|Vault cron|Zero-downtime key rotation|Slack 7d before
MCP OAuth|90 days|Vault cron|Zero-downtime key rotation|Slack 7d before
LLM keys|30 days|Vault cron|Zero-downtime key rotation|Slack 3d before
DB credentials|90 days|Vault cron|Zero-downtime key rotation|Slack 7d before

#INJECTION|service|method|path|validation|fallback
FastAPI|Vault Agent sidecar|/vault/secrets|Signature verification|Doppler fallback
Fly.io|Vault Agent sidecar|/vault/secrets|Signature verification|Doppler fallback
GitHub Actions|doppler run|Doppler CLI|Signature verification|Manual approval
Local Dev|Doppler CLI|Doppler CLI|Signature verification|Env file

#ENCRYPTION|algorithm|key_size|rotation|storage|backup
AES-256-GCM|256 bits|90 days|Vault transit|Shamir backup
RSA-4096|4096 bits|180 days|Vault transit|Shamir backup
ECDSA P-256|256 bits|90 days|Vault transit|Shamir backup

#COMPLIANCE|requirement|control|evidence|frequency|owner
SOC2|Secret rotation|Vault audit logs|Quarterly|GRC
SOC2|Secret access|Doppler access logs|Quarterly|GRC
SOC2|Encryption|Vault transit logs|Quarterly|GRC
SOC2|Backup|Shamir backup verification|Quarterly|GRC
GDPR|Data minimization|Secret scope audit|Quarterly|GRC
EU AI Act|Key management|Key rotation logs|Quarterly|GRC

#INCIDENT|scenario|response|recovery|prevention|timeline
Secret leaked|Revoke all keys,rotate|Generate new keys|Reduce access scope|<1 hour
Vault down|Doppler fallback|Resume operations|Multi-region Vault|<15 minutes
Rotation failed|Manual rotation|Generate new keys|Retry with backoff|<4 hours
Access lost|Recovery keys|Restore access|Split recovery keys|<2 hours

#TESTING|scenario|expected|test_method
secret_fetch|Secret retrieved|Fetch from Vault|Integration test
rotation_success|Key rotated|Trigger rotation,verify new key|Integration test
vault_down|Doppler fallback|Block Vault,verify fallback|Chaos test
access_denied|Access blocked|Invalid token test|Security test
encryption_valid|Data encrypts/decrypts|Encrypt test data|Unit test

#AUDIT|check|frequency|owner|action
secret_inventory|Monthly|Platform|Update secret catalog
access_review|Quarterly|GRC|Review access,remove unused
rotation_compliance|Monthly|Security|Verify all rotations
backup_verification|Quarterly|Platform|Test recovery keys
cost_review|Monthly|Platform|Review Vault costs

EOF
