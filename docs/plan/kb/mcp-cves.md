---
title: "MCP Security Vulnerabilities"
owner: "Security"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

Multiple critical CVEs in MCP ecosystem (2024-2025): CVE-2025-49596 (RCE via CSRF, CVSS 9.4-9.8), CVE-2025-66416 (DNS rebinding, CWE-1188), CVE-2025-6514 (RCE, CVSS 9.6). April 15, 2026 OX Security disclosure revealed 7K exposed servers, 150M+ downloads, 10 CVEs. MCPSec L2 mandatory for production.

## Key Facts

### CVE-2025-4956

#### MCP Inspector Remote Code Execution

- CVSS: 9.4-9.8 (Critical)
- Attack Vector: CSRF in MCP-Inspector leads to RCE via 0.0.0.0 binding
- Mechanism: Malicious website crafts requests to MCP inspector from public domain Javascript context, triggering arbitrary commands via /sse endpoint with stdio transport (command query parameter)
- Affected Versions: Prior to 0.14.1 (Oligo research) / 1.2.3 (security site)
- Discovery: January 2025 (reported Jan 10, patched Jan 15)
- Timeline: Oligo reported April 18, 2025; another researcher reported March 26, 2025; published June 13, 2025
- Impact: Complete system takeover, data exfiltration, lateral movement, supply chain risk (compromise of development environments)
- Exploitation: Requires user interaction (user must inspect malicious server), but 0.0.0.0 Day vulnerability in Chromium/Firefox enables attacks even when binding to localhost
- Exposure: Internet-facing MCP Inspector instances identified as actively exposed
- Fix: Version 0.14.1 added session token by default (similar to Jupyter notebooks) and allowed origins verification to mitigate browser attack vectors completely

### CVE-2025-66416

#### MCP Python SDK DNS Rebinding Protection Disabled

- CWE-1188
- Attack Vector: Malicious website exploits DNS rebinding to bypass same-origin policy and send requests to local MCP server
- Conditions: HTTP-based server on localhost without authentication, using FastMCP with streamable HTTP or SSE transport, no TransportSecuritySettings configured
- Impact: Invoke tools or access resources exposed by MCP server on behalf of user
- Affected Versions: mcp Python SDK prior to v1.23.0
- Scope: Does not affect servers using stdio transport
- Fix: Version 1.23.0 enables DNS rebinding protection by default when host parameter is 127.0.0.1 or localhost
- Custom Config: Users with custom low-level server configurations (StreamableHTTPSessionManager, SseServerTransport) must explicitly configure TransportSecuritySettings

### CVE-2025-6514

#### Critical RCE

- CVSS: 9.6 (Critical)
- Details: Truncated in source (419 bytes)
- Context: Part of MCP vulnerability cluster

### MCP Security Crisis

#### April 15, 2026 OX Security Disclosure

- 7K exposed servers identified
- 150M+ downloads across MCP ecosystem
- 10 CVEs disclosed
- MCPSec L2 mandatory for production per MCP_SEC_CRISIS decision

### MCPSec

#### IETF Draft: Agent Passports

- ECDSA P-256 signing
- Per-message signing
- Tool definition integrity
- Nonce + timestamp replay protection
- Trust levels L0-L4
- Backward-compatible envelope
- Median latency: 8.3ms
- Reduces attack success: 52.8% → 12.4%

### MCP Inspector Security

#### MCP_INSPECTOR_SEC

- CVE-2025-49596 CVSS 9.4
- Pin devDep >= 0.14.1
- Firewall dev network access

### MCP Patching

#### Patching Patterns

- Version-based security updates
- Dependency pinning required
  - MCP Inspector >= 0.14.1
  - MCP Python SDK >= 1.23.0
  - mcp-remote updated for CVE-2025-6514
- Regular dependency updates and security monitoring essential

#### Automation

- GitHub Actions Dependabot for automated PRs
- Renovate for advanced scheduling
- Security advisories monitoring via GitHub Dependabot alerts

#### Patching Workflow

1. Monitor Vulnerable MCP Project and GitHub Security Advisories
2. Evaluate CVSS severity and affected components
3. Test patches in staging environment
4. Roll out via CI/CD with automated rollback
5. Verify patch effectiveness via security scanning

#### CI Integration

- Automated dependency pinning in package.json (exact versions for MCP-related packages)
- Security gate blocking deployment if vulnerable MCP packages detected
- Post-deployment validation via MCP-specific security scanning (MCPTox, MindGuard)

#### Supply Chain Controls

- SCA scanning on all MCP servers before deployment
- Cryptographic verification of server integrity (digital signatures)
- Package scanning for malware and hidden malicious instructions
- Pin specific MCP server versions and alert on changes

#### Governance

- Centralized MCP gateway architecture as single control point
- Approval workflows for new server deployments
- Regular security reviews of tool access patterns
- Audit logging integrated with SIEM platforms

### MCP Policy Guardrails

#### MCPG: Zero-trust architecture

- OAuth tool auth
- Schema allowlist
- Elicitation high-risk detection
- Policy eval deterministic
- SSRF protection
- Sandbox isolation
- CI TrustKit validation

### Vulnerable MCP Project

#### Vulnerablemcp.info

- Comprehensive MCP vulnerability database
- Tracks all MCP-related CVEs and patches
- Reference for security monitoring

## Why It Matters

- MCP ecosystem has critical RCE vulnerabilities that can lead to complete system compromise
- DNS rebinding attacks bypass same-origin policy, enabling unauthorized tool invocation
- Large exposure (7K servers, 150M+ downloads) indicates widespread risk
- Production systems require MCPSec L2 compliance per April 2026 crisis decision
- Automated patching and supply chain controls essential for security

## Sources

- Oligo Security research (CVE-2025-49596)
- OX Security disclosure (April 15, 2026)
- MCP Python SDK security advisories
- Vulnerable MCP Project (vulnerablemcp.info)
- IETF MCPSec draft specification
