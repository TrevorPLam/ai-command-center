---
title: "Tauri Capabilities and Security"
owner: "Frontend Engineering"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

Fine-grained capability per window for XSS containment, CI manifest validation against official schema, v2.7.0 stable with capability audit CI, delta updates roadmap only, mobile for internal tools.

## Key Facts

### Tauri Capability Security

**TAURI_CAP**: Fine-grained capability per window

- XSS containment
- CI manifest validation

### Tauri v2

**TAURI_V2**: v2.7.0 stable

- Capability audit CI
- Delta updates roadmap only
- Mobile for internal tools

### Capability Model

**TAURI_CAP_MODEL**: Capabilities as grouping and boundary mechanism

- Controls application windows' and webviews' fine-grained access to Tauri core, application, or plugin commands
- Windows added to capability by exact name (e.g., main-window) or glob patterns (e.g., *, admin-*)
- Window can have none, one, or multiple associated capabilities
- If webview or its window not matching any capability, has no access to IPC layer at all
- Capabilities can be platform-specific (linux, macOS, windows, iOS, android)
- Remote API access configured to allow remote sources access to certain Tauri commands (e.g., https://*.tauri.app)

#### Security Boundaries

- Minimize impact of frontend compromise
- Prevent exposure of local system interfaces and data
- Prevent privilege escalation from frontend to backend/system

#### Limitations

Does NOT protect against:

- Malicious/insecure Rust code
- Too lax scopes and configuration
- Incorrect scope checks in command implementation
- Intentional bypasses from Rust code
- 0-days or unpatched 1-days in system WebView
- Supply chain attacks or compromised developer systems

#### IDE Autocompletion

- Tauri generates JSON schemas with all available permissions through tauri-build
- Schemas: gen/schemas/desktop-schema.json, gen/schemas/mobile-schema.json

### XSS Containment

**TAURI_XSS_CONTAINMENT**: Content Security Policy (CSP) restriction

- Restricts CSP of HTML pages to reduce or prevent impact of common web-based vulnerabilities like XSS
- Local scripts hashed, styles and external scripts referenced using cryptographic nonce
- Prevents unallowed content from being loaded
- CSP protection only enabled if set on Tauri configuration file

#### Configuration Example

```json
"csp": {
  "default-src": "'self' customprotocol: asset:",
  "connect-src": "ipc: http://ipc.localhost",
  "font-src": ["https://fonts.gstatic.com"],
  "img-src": "'self' asset: http://asset.localhost blob: data:",
  "style-src": "'unsafe-inline' 'self' https://fonts.googleapis.com"
}
```

#### Isolation Pattern

- Injects secure application between frontend and Tauri Core to intercept and modify incoming IPC messages
- Uses sandboxing feature of `<iframe>`s to run JavaScript securely
- Messages encrypted using AES-GCM with runtime-generated keys (new keys each time application runs)
- Performance implications: additional overhead due to encryption, but most applications should not notice runtime costs (AES-GCM is relatively fast, messages are relatively small)
- Limitations: external files don't load correctly inside sandboxed `<iframe>`s on Windows (script inlining step during build time), ES Modules won't successfully load
- Tauri highly recommends using isolation pattern whenever possible, especially when using external Tauri APIs or applications with many dependencies

### CI Validation

**TAURI_CI_VALIDATION**: JSON Schema validation in CI

- Tauri configuration validated against JSON Schema at <https://schema.tauri.app/config/2>
- Schema validation ensures configuration file structure correct before build
- CI integration patterns: Use GitHub Actions with JSON Schema Validate action to validate tauri.conf.json (or Tauri.toml) against official schema

#### Example Workflow

```yaml
name: Validate Config
on: [push, pull_request]
jobs:
  validate-config:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: SchemaStore/schemastore-action@v1
        with:
          schema: https://schema.tauri.app/config/2
          files: src-tauri/tauri.conf.json
```

- Alternative: Use validate-json action with schema parameter
- Tauri supports JSON5 and TOML formats via config-json5 and config-toml Cargo features
- Platform-specific configuration files (tauri.linux.conf.json, tauri.windows.conf.json, etc.) merged with main configuration
- Schema validation should run on all configuration files to catch misconfigurations early in CI pipeline

### Tauri Client Configuration

**Tauri**: v2, GH Actions build

- Mac signing + notarization
- Auto-update tauri-plugin-updater
- Capabilities per window
- Dependency chain audit (Rust + npm)

### Passkeys

**Passkeys**: SB Auth MFA

- Cross-device QR
- Platform sync (iCloud/Google)
- Recovery codes
- Phishing-resistant

#### Passkey QR Flow

**PASSKEY_QR_FLOW**: Cross-device QR code authentication (hybrid transport)

1. User initiates authentication on device without passkey
2. Server generates unique time-sensitive session identifier
3. QR code encodes FIDO URI with CBOR-encoded handshake and ephemeral secrets
4. User scans QR code with device containing passkey
5. Scanned device communicates with server via FIDO URI
6. Server generates cryptographic challenge
7. Challenge sent to user's device with passkey
8. Device creates digital signature using private key (never leaves device)
9. Signed challenge sent via encrypted internet tunnel
10. Server validates signature using public key
11. Authentication confirmed

#### Security

- One-time use session ID
- CBOR-encoded ephemeral handshake
- Bluetooth proximity check (not data exchange)
- Private keys never leave device
- No sensitive data exposure
- Asymmetric cryptography challenge-response

#### Complexity

- Medium - requires QR code generation, FIDO URI handling, cryptographic challenge-response, encrypted tunnel, signature verification

### Supabase Passkeys Gap

**PASSKEYS_SUPABASE_GAP**: Supabase Auth lacks native WebAuthn

- Use SimpleWebAuthn + RPC
- Table: webauthn_challenges

## Why It Matters

- Fine-grained capabilities minimize attack surface by limiting IPC access
- XSS containment prevents common web vulnerabilities from compromising system
- CI validation catches configuration errors before deployment
- Isolation pattern adds security layer for external API usage
- Passkeys provide phishing-resistant MFA

## Sources

- Tauri v2 documentation
- Tauri security best practices
- WebAuthn/FIDO2 specifications
