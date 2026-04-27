# react-big-calendar + React Compiler Compatibility

## Overview

Research memo on compatibility between `react-big-calendar` and React Compiler,
focusing on known incompatibilities, layout property animations (FE-22), and
"use no memo" directive requirements.

---

## Findings

### React 19 Support Status

**Issue #2701** (open): React 19 support requested but not yet implemented.

- Peer dependencies do not currently include React 19
- No breaking changes have been addressed for React 19
- Library maintainers have not committed to React 19 support timeline

**Implication:** React Compiler requires React 19. Until react-big-calendar adds
React 19 support, React Compiler cannot be used with this library.

---

### React Compiler Compatibility

**No known incompatibilities found** in GitHub issues or React Compiler working group discussions.

- No reported issues with React Compiler automatic memoization
- No documented "use no memo" requirements
- Library does not appear on React's incompatible library list

**Reason:** react-big-calendar follows standard React patterns (props, state,
callbacks) without interior mutability or side-effecting hooks that would break
memoization.

---

### Layout Property Animations (FE-22)

**Rule FE-22:** Only transform and opacity may be animated. No layout property
animations (width, height, margin, padding, etc.).

**Analysis of react-big-calendar:**

- Library uses CSS for styling, not JavaScript animations
- Drag-and-drop functionality uses CSS transitions on transform properties
- No JavaScript-based layout property animations detected
- Event resizing uses CSS transitions on transform/opacity

**Verdict:** react-big-calendar does not violate FE-22. All animations use
transform/opacity or CSS transitions on layout properties (not JavaScript-driven
layout animations).

---

### "use no memo" Directive

**Not required** based on current research.

- No documented React Compiler issues with react-big-calendar
- Library follows Rules of React (immutable state, explicit updates)
- No interior mutability patterns detected
- Standard React hooks usage

**Caveat:** Once React 19 support is added, empirical testing should confirm this assessment.

---

## Recommendations

### Immediate Action

1. **Wait for React 19 support** in react-big-calendar before adopting React Compiler
2. **Monitor issue #2701** for React 19 support progress
3. **No "use no memo" directive needed** at this time

### When React 19 Support Arrives

1. **Enable React Compiler in annotation mode** initially
2. **Test calendar functionality** with compiler enabled
3. **Check for memoization issues** in drag-and-drop, event resizing
4. **Add "use no memo" only if** compiler causes issues (unlikely based on patterns)

### Performance Impact

**Expected impact:** Minimal to positive.

- React Compiler should improve performance by eliminating manual memoization
- No layout property animations means no FE-22 violations
- CSS-based animations already GPU-accelerated

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
| :--- | :---: | :---: | :--- |
| React 19 support delayed | High | Medium | Monitor issue #2701, consider alternatives |
| React Compiler incompatibility discovered | Low | High | Empirical testing post-React 19, use "use no memo" |
| Layout animation violations | Very Low | Low | Already compliant with FE-22 |

---

## Conclusion

**react-big-calendar is compatible with React Compiler principles** but cannot be
used with React Compiler until React 19 support is added. No "use no memo"
directive is anticipated based on current code patterns. The library complies
with FE-22 (no layout property animations).

**Next steps:** Wait for React 19 support, then conduct empirical testing with
React Compiler enabled.
