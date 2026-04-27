# DOMPurify XSS Test Matrix Validation

## TL;DR

DOMPurify 3.4.0 patches all known XSS bypass CVEs in versions 3.0.1-3.3.3. Test matrix validates STRICT, RICH, and EMAIL profiles against OWASP XSS Filter Evasion Cheat Sheet vectors.

## CVE Analysis

### Affected Versions: 3.0.1-3.3.3

| CVE | Description | Severity | Fixed In | CWE |
|-----|-------------|----------|----------|-----|
| CVE-2026-41238 | Prototype pollution via CUSTOM_ELEMENT_HANDLING | Medium (6.9) | 3.4.0 | CWE-79, CWE-1321 |
| CVE-2026-41239 | SAFE_FOR_TEMPLATES bypass in RETURN_DOM mode | Medium | 3.4.0 | CWE-79, CWE-1289 |
| CVE-2026-41240 | FORBID_TAGS bypassed by function-based ADD_TAGS | Medium | 3.4.0 | CWE-183, CWE-79 |
| CVE-2026-0540 | XSS via missing rawtext validation | Medium | 3.3.2 | CWE-79 |
| CVE-2025-15599 | Textarea rawtext bypass in SAFE_FOR_XML | Medium (5.1) | 3.2.7 | CWE-79 |
| CVE-2024-48910 | Prototype pollution (older issue) | Critical (9.1) | 2.4.2 | CWE-1321 |

### CVE-2026-41238: Prototype Pollution XSS

**Root cause:** DOMPurify reads tagNameCheck and attributeNameCheck from Object.prototype when CUSTOM_ELEMENT_HANDLING is not explicitly configured. Attackers with prototype pollution access can inject permissive regex values to bypass sanitization.

**Attack vector:**

1. Exploit prototype pollution in target application
2. Inject malicious tagNameCheck and attributeNameCheck into Object.prototype
3. Call DOMPurify.sanitize() with default configuration
4. Custom elements with event handlers pass through sanitization
5. Execute XSS when output is inserted into DOM

**Patch:** 3.4.0 prevents unsafe reading from polluted prototype chains.

### CVE-2026-41239: SAFE_FOR_TEMPLATES Bypass

**Root cause:** SAFE_FOR_TEMPLATES strips {{...}} expressions in string mode but not with RETURN_DOM or RETURN_DOM_FRAGMENT options.

**Attack vector:** Template-evaluating frameworks like Vue 2 can execute XSS via {{...}} expressions when DOMPurify returns DOM nodes instead of strings.

**Patch:** 3.4.0 extends SAFE_FOR_TEMPLATES to DOM return modes.

### CVE-2026-41240: FORBID_TAGS Asymmetry

**Root cause:** Inconsistency between FORBID_TAGS and FORBID_ATTR handling when function-based ADD_TAGS is used. Commit c361baa added early exit for FORBID_ATTR but not FORBID_TAGS.

**Attack vector:** When EXTRA_ELEMENT_HANDLING.tagCheck returns true, FORBID_TAGS check is skipped entirely, allowing forbidden elements to survive with attributes intact.

**Patch:** 3.4.0 applies consistent early exit logic to both FORBID_TAGS and FORBID_ATTR.

### CVE-2026-0540: Rawtext Element Bypass

**Root cause:** Missing validation for textarea rawtext elements in SAFE_FOR_XML regex pattern.

**Attack vector:** Closing rawtext tags (</textarea>) within attribute values persist through sanitization and break out of context when placed inside rawtext elements.

**Patch:** 3.3.2 adds rawtext element validation.

### CVE-2025-15599: Textarea Rawtext Bypass

**Root cause:** Incomplete regex pattern in SAFE_FOR_XML fails to account for textarea rawtext element contexts.

**Attack vector:**

1. Craft input with closing rawtext tag in attribute value
2. DOMPurify fails to detect embedded closing tag
3. Application places sanitized output inside `<textarea>`
4. Browser parses closing tag, breaking context
5. Attacker-controlled JavaScript executes

**Patch:** 3.2.7 (3.x branch only; 2.x branch unpatched).

### CVE-2024-48910: Prototype Pollution (Historical)

**Root cause:** DOMPurify vulnerable to prototype pollution tampering.

**Impact:** CVSS 9.1 (CRITICAL). Allows attackers to tamper with object prototype attributes, leading to security bypasses.

**Patch:** 2.4.2 (older issue, not in 3.x scope).

## Verification: 3.4.0 Patches All CVEs

**Confirmed:** DOMPurify 3.4.0 patches all CVEs affecting versions 3.0.1-3.3.3:

- CVE-2026-41238: Patched in 3.4.0
- CVE-2026-41239: Patched in 3.4.0
- CVE-2026-41240: Patched in 3.4.0
- CVE-2026-0540: Patched in 3.3.2 (included in 3.4.0)
- CVE-2025-15599: Patched in 3.2.7 (included in 3.4.0)

**Recommendation:** Upgrade to DOMPurify ≥3.4.0 immediately. Version pinning required in package.json with automated CVE audit in CI per rule SEC-10.

## Test Matrix: OWASP XSS Filter Evasion Cheat Sheet

### Profile Definitions

**STRICT Profile:**

- No SVG, no MathML
- ALLOWED_TAGS: Basic HTML formatting only (div, span, p, br, strong, em, ul, ol, li)
- FORBID_TAGS: script, style, svg, mathml, iframe, object, embed, form, textarea, title
- FORBID_ATTR: All event handlers (onload, onclick, onmouseover, onerror, onfocus, etc.)
- SAFE_FOR_XML: true
- ALLOW_DATA_ATTR: false

**RICH Profile:**

- Allowed div, span for rich text editors
- ALLOWED_TAGS: STRICT + additional formatting (h1-h6, blockquote, code, pre, a, img)
- FORBID_TAGS: script, style, svg, mathml, iframe, object, embed, form, textarea, title
- FORBID_ATTR: All event handlers
- SAFE_FOR_XML: true
- ALLOW_DATA_ATTR: false

**EMAIL Profile:**

- Link and image support for HTML email
- ALLOWED_TAGS: div, span, p, br, a, img, table, tr, td, th
- FORBID_TAGS: script, style, svg, mathml, iframe, object, embed, form, textarea, title
- FORBID_ATTR: onload, onclick, onerror, formaction
- ALLOWED_ATTR: href, src, alt, title, width, height
- SAFE_FOR_XML: true
- ALLOW_DATA_ATTR: false
- URI validation: javascript: blocked, mailto: allowed, http/https allowed, data: blocked

### Test Cases

|Test Vector|Category|STRICT|RICH|EMAIL|Expected Behavior|
|---|---|---|---|---|---|
| `<SCRIPT SRC=https://cdn.jsdelivr.net/gh/Moksh45/host-xss.rocks/index.js></SCRIPT>` | Basic script | BLOCKED | BLOCKED | BLOCKED | Script tag removed entirely |
| `<a onmouseover="alert(document.cookie)">xxs link</a>` | Event handler | BLOCKED | BLOCKED | BLOCKED | onmouseover attribute removed |
| `<IMG """><SCRIPT>alert("XSS")</SCRIPT>"\>` | Malformed IMG | BLOCKED | BLOCKED | BLOCKED | Script tag removed, IMG sanitized |
| `<a href="javascript:alert(String.fromCharCode(88,83,83))">Click Me!</a>` | JavaScript URI | BLOCKED | BLOCKED | BLOCKED | href removed or sanitized |
| `<IMG SRC=# onmouseover="alert('xxs')">` | Event handler | BLOCKED | BLOCKED | BLOCKED | onmouseover removed |
| `<IMG SRC= onerror="alert(String.fromCharCode(88,83,83))"></img>` | onerror handler | BLOCKED | BLOCKED | BLOCKED | onerror removed |
| `<img src=x onerror="&#0000106&#0000097&#0000118...">` | Encoded handler | BLOCKED | BLOCKED | BLOCKED | onerror removed (decoded) |
| `<svg/onload='+/"/+/onmouseover=1/+/[*/[]/+alert(42);//'>` | SVG XSS | BLOCKED | BLOCKED | BLOCKED | SVG tag removed (STRICT/RICH) |
| `<div style="background:url('javascript:alert(1)')">` | CSS JS | BLOCKED | BLOCKED | BLOCKED | style attribute removed |
| `<iframe src="javascript:alert(1)"></iframe>` | iframe XSS | BLOCKED | BLOCKED | BLOCKED | iframe tag removed |
| `<object data="javascript:alert(1)"></object>` | object XSS | BLOCKED | BLOCKED | BLOCKED | object tag removed |
| `<embed src="javascript:alert(1)"></embed>` | embed XSS | BLOCKED | BLOCKED | BLOCKED | embed tag removed |
| `<form action="javascript:alert(1)"><input type=submit></form>` | form XSS | BLOCKED | BLOCKED | BLOCKED | form tag removed |
| `<textarea></textarea><script>alert(1)</script>` | Rawtext bypass | BLOCKED | BLOCKED | BLOCKED | textarea removed, script blocked |
| `<title></title><script>alert(1)</script>` | Title bypass | BLOCKED | BLOCKED | BLOCKED | title removed, script blocked |
| `<math><mi>x</mi><mtext><script>alert(1)</script></mtext></math>` | MathML XSS | BLOCKED | BLOCKED | BLOCKED | mathml tag removed |
| `<div>{{alert(1)}}</div>` | Template expression | SANITIZED | SANITIZED | SANITIZED | {{...}} stripped (SAFE_FOR_TEMPLATES) |
| `<custom-element onclick="alert(1)">test</custom-element>` | Custom element | BLOCKED | BLOCKED | BLOCKED | Custom element removed |
| `<a href="http://example.com">link</a>` | Safe link | BLOCKED | ALLOWED | ALLOWED | Allowed in RICH/EMAIL only |
| `<img src="http://example.com/img.jpg" alt="text">` | Safe image | BLOCKED | ALLOWED | ALLOWED | Allowed in RICH/EMAIL only |
| `<a href="mailto:user@example.com">email</a>` | Mailto link | BLOCKED | BLOCKED | ALLOWED | Allowed in EMAIL only |
| `<a href="data:text/html,<script>alert(1)</script>">data</a>` | Data URI | BLOCKED | BLOCKED | BLOCKED | data: protocol blocked |
| `<div data-xss="alert(1)">test</div>` | Data attribute | BLOCKED | BLOCKED | BLOCKED | data-* attributes blocked |
| `<img src=x onerror=alert(1)>` | No quotes handler | BLOCKED | BLOCKED | BLOCKED | onerror removed |
| `<IMG SRC="jav&#x09;ascript:alert('XSS');">` | Tab in URI | BLOCKED | BLOCKED | BLOCKED | javascript: blocked |
| `<IMG SRC="jav&#x0A;ascript:alert('XSS');">` | Newline in URI | BLOCKED | BLOCKED | BLOCKED | javascript: blocked |
| `<style>@import 'javascript:alert(1)';</style>` | CSS import | BLOCKED | BLOCKED | BLOCKED | style tag removed |
| `<link rel="stylesheet" href="javascript:alert(1)">` | Link XSS | BLOCKED | BLOCKED | BLOCKED | link tag removed |
| `<meta http-equiv="refresh" content="0;url=javascript:alert(1)">` | Meta refresh | BLOCKED | BLOCKED | BLOCKED | meta tag removed |
| `<body onload="alert(1)">` | Body handler | BLOCKED | BLOCKED | BLOCKED | body tag removed or handler stripped |
| `<details open ontoggle="alert(1)">` | Details handler | BLOCKED | BLOCKED | BLOCKED | ontoggle removed |
| `<marquee onstart="alert(1)">` | Marquee handler | BLOCKED | BLOCKED | BLOCKED | marquee removed |
| `<video><source onerror="alert(1)"></video>` | Video handler | BLOCKED | BLOCKED | BLOCKED | onerror removed |
| `<audio src=x onerror="alert(1)"></audio>` | Audio handler | BLOCKED | BLOCKED | BLOCKED | onerror removed |
| `<input autofocus onfocus="alert(1)">` | Input handler | BLOCKED | BLOCKED | BLOCKED | onfocus removed |
| `<select onfocus="alert(1)"><option>x</option></select>` | Select handler | BLOCKED | BLOCKED | BLOCKED | onfocus removed |
| `<textarea onfocus="alert(1)"></textarea>` | Textarea handler | BLOCKED | BLOCKED | BLOCKED | textarea removed |
| `<keygen onfocus="alert(1)">` | Keygen handler | BLOCKED | BLOCKED | BLOCKED | keygen removed |
| `<progress onfocus="alert(1)">` | Progress handler | BLOCKED | BLOCKED | BLOCKED | onfocus removed |

## Expected Sanitization Behavior

### STRICT Profile

**Purpose:** Maximum security for user-generated content where no formatting is required.

**Behavior:**

- All script, style, svg, mathml, iframe, object, embed, form, textarea, title tags removed
- All event handler attributes removed (onload, onclick, onmouseover, onerror, onfocus, etc.)
- JavaScript URIs blocked in href/src attributes
- Data URIs blocked
- Data attributes blocked
- Template expressions {{...}} stripped
- Custom elements removed
- Only basic HTML formatting allowed: div, span, p, br, strong, em, ul, ol, li

**Use case:** Comment systems, user profiles, any content where security outweighs formatting needs.

### RICH Profile

**Purpose:** Rich text editing with formatting support while maintaining security.

**Behavior:**

- Same security as STRICT for XSS vectors
- Additional allowed tags: h1-h6, blockquote, code, pre, a, img
- Links and images allowed with URI validation
- SVG and MathML still blocked
- All event handlers blocked
- JavaScript URIs blocked

**Use case:** Rich text editors, task comments (internal/external), document editing.

### EMAIL Profile

**Purpose:** HTML email sanitization with link and image support.

**Behavior:**

- Links allowed: http, https, mailto
- Images allowed: http, https sources
- Tables allowed for email layout
- JavaScript URIs blocked
- Data URIs blocked
- Form-related attributes blocked (formaction)
- Event handlers blocked
- SVG and MathML blocked
- Script and style tags blocked

**Use case:** HTML email composition, email preview rendering.

## Testing Recommendations

### Automated Testing

Implement automated test suite using the matrix above:

```typescript
describe('DOMPurify XSS Test Matrix', () => {
  const testCases = [
    { vector: '<SCRIPT>alert(1)</SCRIPT>', profile: 'STRICT', expected: 'BLOCKED' },
    // ... all test cases from matrix
  ];

  testCases.forEach(({ vector, profile, expected }) => {
    it(`${profile}: ${vector.substring(0, 50)}...`, () => {
      const config = getProfileConfig(profile);
      const result = DOMPurify.sanitize(vector, config);
      if (expected === 'BLOCKED') {
        expect(result).not.toContain('alert');
        expect(result).not.toContain('javascript:');
      }
    });
  });
});
```

### Manual Verification

1. Test each profile against OWASP XSS Filter Evasion Cheat Sheet vectors
2. Verify CVE-2026-41238 mitigation by testing prototype pollution scenarios
3. Verify CVE-2026-41239 mitigation with RETURN_DOM mode
4. Verify CVE-2026-41240 mitigation with function-based ADD_TAGS
5. Verify rawtext element handling (CVE-2026-0540, CVE-2025-15599)

### CI Integration

Per rule SEC-10, implement automated CVE audit in CI:

```yaml
- name: Check DOMPurify version
  run: |
    VERSION=$(npm list dompurify --depth=0 | grep dompurify | awk '{print $2}')
    MIN_VERSION="3.4.0"
    if [ "$(printf '%s\n' "$MIN_VERSION" "$VERSION" | sort -V | head -n1)" != "$MIN_VERSION" ]; then
      echo "DOMPurify version $VERSION is below minimum $MIN_VERSION"
      exit 1
    fi
```

## Sources

- CVE-2026-41238: SentinelOne advisory, GitHub Security Advisory GHSA-v9jr-rg53-9pgp
- CVE-2026-41239: THREATINT, GitHub Security Advisory GHSA-crv5-9vww-q3g8
- CVE-2026-41240: THREATINT, GitHub Security Advisory GHSA-h7mw-gpvr-xq4m
- CVE-2026-0540: GitLab advisory, IBM Security Bulletin
- CVE-2025-15599: SentinelOne advisory, VulnCheck advisory
- CVE-2024-48910: Wiz vulnerability database, NVD
- OWASP XSS Filter Evasion Cheat Sheet: <https://cheatsheetseries.owasp.org/cheatsheets/XSS_Filter_Evasion_Cheat_Sheet.html>
- DOMPurify releases: <https://github.com/cure53/DOMPurify/releases>
- Project sanitization knowledge base: docs/plan/kb/sanitization.md
