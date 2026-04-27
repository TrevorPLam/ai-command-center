---
title: "HTML Sanitization and Security"
owner: "Security"
status: "active"
updated: "2026-04-26"
canonical: ""
---

## TL;DR

DOMPurify ≥3.4 with STRICT, RICH, EMAIL profiles, CVE mitigation for XSS vulnerabilities, SVG security with event handler removal, email security with link and image validation.

## Key Facts

### DOMPurify Profiles

**SanitizedHTML_Profiles**: Three DOMPurify profiles

- STRICT: no SVG
- RICH: allowed div/span
- EMAIL: link + img
- Component prop driven

### DOMPurify CVEs

**DOMPURIFY_CVES**: Version ≥3.4.0 mitigates

- CVE-2025-15599
- CVE-2026-0540
- CVE-2026-41238
- CVE-2026-41240
- CVE-2025-25141

### SVG Security

**SVG_Security**: DOMPurify SVG sanitization

- Removes event handlers (onload, onclick, onmouseover, onerror) to prevent JavaScript injection via SVG
- SVG security risks: JavaScript execution through event handlers, MathML rendering process vulnerabilities, namespace confusion leading to mXSS

#### Safe Patterns

- USE_PROFILES: { svg: true } for SVG-only content
- FORBID_ATTR: ['onload', 'onclick', 'onmouseover', 'onerror', 'onfocus']
- FORBID_TAGS: ['script', 'style'] within SVG
- SAFE_FOR_XML: true (default) to prevent namespace confusion

#### RICH Profile Validation

- FORBID_TAGS: ['svg', 'mathml'] blocks SVG entirely in RICH profile (recommended for rich text editors)
- ALLOWED_TAGS limited to HTML formatting tags only, no SVG event handlers allowed
- SVG handling in RICH profile: BLOCKED - RICH profile explicitly forbids SVG tags to prevent SVG-based XSS attacks

### Email Security

**Email_Security**: DOMPurify EMAIL profile for HTML email sanitization

#### Configuration

- USE_PROFILES: { html: true }
- ALLOWED_TAGS: ['div', 'span', 'p', 'br', 'a', 'img', 'table', 'tr', 'td', 'th']
- ALLOWED_ATTR: ['href', 'src', 'alt', 'title', 'width', 'height']
- FORBID_TAGS: ['svg', 'mathml', 'script', 'style', 'iframe', 'object', 'embed', 'form']
- FORBID_ATTR: ['onload', 'onclick', 'onerror', 'formaction']
- ALLOW_DATA_ATTR: false

#### Link Safety

- href attributes allowed but validated by DOMPurify's URI sanitization (javascript: protocol blocked)
- mailto: links allowed
- http/https links allowed
- data: URIs blocked by default

#### Image Safety

- src attribute allowed but validated (javascript: protocol blocked)
- http/https URLs allowed
- data: URIs for images blocked by default
- alt and title attributes allowed for accessibility

#### Additional Validation

- KEEP_CONTENT: true preserves content when tags removed
- FORBID_TAGS: ['form'] prevents CSRF via email forms
- FORBID_ATTR: ['formaction'] prevents form action hijacking
- ALLOW_DATA_ATTR: false prevents ujs-based XSS via data-* attributes

#### Email-Specific Considerations

- HTML email clients have varying CSS support
- Inline styles recommended (but blocked in EMAIL profile for security)
- Table-based layouts common (tables allowed in EMAIL profile)
- Responsive design via media queries (not supported in all email clients)

## Why It Matters

- DOMPurify prevents XSS attacks via user-generated HTML
- SVG event handlers are common XSS vector
- Email sanitization prevents phishing and malware delivery
- Profile-based approach allows flexibility for different use cases

## Sources

- DOMPurify documentation
- CVE database entries
- OWASP XSS prevention guide
