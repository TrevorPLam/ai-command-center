# AI-Assisted Development Workflow

This document provides guidelines for effective AI-assisted development of the AI Command Center platform.

---

## Domain Boundary Enforcement

When modifying a component within one domain, only reference interfaces exposed by other domains.

**Example**:
- ✅ Use `ModelGateway.route()` from Domain C.1
- ❌ Do not inline routing logic into Domain D.1

This ensures clean separation of concerns and maintains the domain architecture.

---

## Version Pinning

All packages in the blueprint are pinned to specific versions. AI agents must verify compatibility against these versions before proposing changes.

**Process**:
1. Check the blueprint for the pinned version
2. Verify the proposed change is compatible with that version
3. If a version upgrade is needed, update the blueprint first
4. Document the reason for the version change

---

## Dependency Validation

Before adding new technology, verify it does not duplicate capability already present in another domain.

**Example**:
- If adding a new monitoring tool, confirm it does not overlap with:
  - Domain A.4 (OpenTelemetry `gen_ai` traces)
  - Domain C.6 (circuit breaker metrics)

**Validation Checklist**:
- [ ] Does this duplicate existing functionality?
- [ ] Is there already a tool in another domain that solves this?
- [ ] Can the existing solution be extended instead?
- [ ] Is this the right domain for this capability?

---

## Cross-Cutting Security Checks

Any change must be evaluated against Domain E (Security & Compliance).

**Required Evaluations**:
- New model added to Domain C.1 → EU AI Act documentation update (E.3) and bias assessment (E.4)
- New API endpoint → APS Gateway integration (E.1) and audit logging (E.2)
- New data collection → GDPR compliance (E.2) and PII redaction (A.4)
- New agent tool → MCP security enforcement (E.1) and supply chain validation (E.1)

**Process**:
1. Identify which Domain E controls apply
2. Verify compliance with those controls
3. Update relevant documentation
4. Add necessary tests or validations

---

## Semantic Versioning for Prompts & Agents

All prompt versions, agent definitions, and model configurations must use semantic versioning with changelog entries, integrated into Domain C.4 (Agent Studio).

**Versioning Scheme**:
- `MAJOR.MINOR.PATCH` (e.g., `1.2.3`)
- MAJOR: Breaking changes
- MINOR: New features, backward compatible
- PATCH: Bug fixes, backward compatible

**Changelog Requirements**:
- Document what changed and why
- Note any breaking changes
- Reference related issues or decisions
- Include migration guide for breaking changes

**Integration with Agent Studio**:
- Store prompt versions in Agent Studio
- Track model configuration versions
- Maintain version history for rollback
- Enable A/B testing of different versions

---

## AI Agent Interaction Patterns

### When to Use AI Agents

Use AI agents for:
- Complex reasoning tasks
- Multi-step planning
- Code generation with context
- Refactoring with architectural awareness
- Test generation
- Documentation updates

Do not use AI agents for:
- Simple string replacements
- Trivial edits (single-line changes)
- Mechanical tasks better done with tools
- Tasks requiring precise domain knowledge not in context

### Providing Context to AI Agents

Always provide:
- The specific domain context (e.g., "This is in Domain C.1")
- Relevant blueprint sections
- Current file state
- Related files if needed
- Specific requirements or constraints

### Reviewing AI Suggestions

Before accepting AI suggestions:
- Verify they respect domain boundaries
- Check for security implications
- Ensure version compatibility
- Validate against blueprint requirements
- Test the changes if possible

---

## Common Anti-Patterns

### ❌ Ignoring Domain Boundaries

**Bad**: AI agent suggests moving logic from Domain C to Domain D without justification.

**Good**: AI agent identifies the correct domain for the capability and references the appropriate interface.

### ❌ Skipping Version Checks

**Bad**: AI agent proposes upgrading a package without checking the blueprint.

**Good**: AI agent checks the pinned version, verifies compatibility, and updates the blueprint if needed.

### ❌ Duplicating Functionality

**Bad**: AI agent suggests adding a new monitoring tool when OpenTelemetry already covers it.

**Good**: AI agent extends the existing OpenTelemetry configuration or explains why a new tool is necessary.

### ❌ Ignoring Security

**Bad**: AI agent suggests adding a new API without considering Domain E controls.

**Good**: AI agent evaluates against Domain E requirements and implements necessary security controls.

---

## Continuous Improvement

This document should be updated as:
- New patterns emerge in AI-assisted development
- Lessons are learned from actual AI agent interactions
- The domain architecture evolves
- New security considerations are identified

Maintain this as a living document to improve AI-assisted development effectiveness over time.
