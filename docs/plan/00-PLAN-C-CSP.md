---
steering: TO PARSE - READ INTRO
document_type: component_specification
module: CrossCutting
tier: infrastructure
component_count: 1
dependencies:
- ~h/useCSPNonce
- helmet
motion_requirements:
- None
accessibility:
- WCAG 2.2 AA compliance
performance:
- Minimal CSP header overhead
last_updated: 2026-04-25
version: 1.0
---

# C Components|name|mod|type|pats|rules|deps(non-local)|notes
// CSP Policy
CSPPolicyProvider|XCT|Provider|-|S6,S7,S11|helmet,nonce generator|Report-Only in pre-prod

#POLICY|directive|value|notes
default-src|'self'|Only allow same-origin
script-src|'nonce-{nonce}' 'strict-dynamic' 'unsafe-eval' https://cdn.jsdelivr.net|Nonce required,Monaco/Babel eval scoped
style-src|'self' 'unsafe-inline' https://cdn.jsdelivr.net|Inline styles for Tailwind
style-src-attr|'unsafe-inline'|Motion animations via inline styles
img-src|'self' data: blob: https://*.supabase.co https://*.stripe.com|User uploads,external images
font-src|'self' data: https://cdn.jsdelivr.net|Custom fonts
connect-src|'self' https://*.supabase.co https://*.anthropic.com https://*.openai.com https://*.stripe.com https://*.nylas.com https://*.livekit.io|API endpoints
frame-src|'self' https://*.stripe.com|Stripe Elements
worker-src|'self' blob:|Service workers,blob URLs
object-src|'none'|Block plugins
base-uri|'self'|Prevent base tag attacks
form-action|'self'|Prevent form submission to external
frame-ancestors|'none'|Block embedding
report-uri|/api/csp-report|Violation reporting endpoint
report-to|csp-endpoint|Reporting API

#NONCE|generation|scope|validation|rotation
per-request|Cryptographically random 16 bytes|Single request|Base64 validation|Not applicable
per-session|Cryptographically random 32 bytes|User session|JWT signature check|Session expiry
worker|Cryptographically random 24 bytes|Service worker|Worker scope validation|Worker update

#EXCEPTIONS|component|directive|exception|justification|mitigation
Monaco Editor|script-src|'unsafe-eval'|CodeMirror requires eval|Sandboxed iframe with separate CSP
Babel|script-src|'unsafe-eval'|Transpilation requires eval|Sandboxed iframe with separate CSP
Motion|style-src-attr|'unsafe-inline'|Dynamic animation values|Reduced motion check,values sanitized
Tailwind|style-src|'unsafe-inline'|Runtime JIT compiler|Content Security Policy Report-Only monitoring

#REPORTING|endpoint|method|payload|retention|alerting
/api/csp-report|POST|{csp-report:{document-uri,violated-directive,blocked-uri,original-policy}}|90 days|Alert on repeated violations
csp-endpoint|Reporting API|Same as above|90 days|Alert on repeated violations

#TESTING|scenario|expected|test_method
inline-script-blocked|Script blocked|CSP violation report|Schemathesis scan
eval-blocked|Eval blocked|CSP violation report|Monaco sandbox test
worker-src-blob|Worker allowed|Worker executes|Service worker test
report-uri-called|Report sent|Endpoint receives violation|CSP violation test
nonce-validation|Invalid nonce rejected|Script blocked|Nonce tamper test

#ENFORCEMENT|environment|mode|block|report|upgrade
production|enforce|Yes|Yes|No
staging|report-only|No|Yes|No
development|report-only|No|Yes|No

#AUDIT|check|frequency|owner|action
CSP violations|Daily|Security|Investigate repeated violations
Directive review|Monthly|Security|Remove unused directives
Nonce leakage|Quarterly|Security|Verify nonce scope isolation
Report endpoint uptime|Continuous|Platform|Alert on endpoint failure

EOF
