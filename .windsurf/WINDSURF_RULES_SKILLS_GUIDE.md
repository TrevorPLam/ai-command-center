# Windsurf Rules and Skills - Complete Implementation Guide

Official documentation compiled from [docs.windsurf.com](https://docs.windsurf.com)

---

## Project-Specific Configuration

This workspace is configured for a **React 18 + TypeScript AI Command Center** frontend. All rules and skills are tailored to this specific project.

### Project Overview

- **Tech Stack**: React 18 + TypeScript (Vite), Tailwind CSS + shadcn/ui, TanStack Query v5, Zustand, React Router v6
- **Purpose**: Personal AI command center UI shell (no backend, no database, no auth)
- **API Base**: http://localhost:8000 (all data mocked)
- **Visual Identity**: Dark theme with electric blue accents, glass panels, 150ms transitions

---

## Table of Contents

- [Overview](#overview)
- [Rules](#rules)
- [Skills](#skills)
- [Workflows](#workflows)
- [Comparison: Rules vs Skills vs Workflows](#comparison-rules-vs-skills-vs-workflows)
- [Best Practices](#best-practices)
- [Enterprise Configuration](#enterprise-configuration)

---

## Overview

Windsurf provides three mechanisms for customizing Cascade behavior:

1. **Rules** - Behavioral guidelines that persist across conversations
2. **Skills** - Multi-step procedures with supporting files for complex tasks
3. **Workflows** - Reusable markdown workflows invoked via slash commands

---

## Rules

### Purpose

Rules provide persistent, reusable context at the prompt level. They are behavioral guidelines that tell Cascade "how to behave" rather than "what to do."

### Storage Locations

**Workspace Rules**

- `.windsurf/rules/` in current workspace directory
- `.windsurf/rules/` in any sub-directory of workspace
- `.windsurf/rules/` in parent directories up to git root (for git repositories)

**Global Rules**

- `global_rules.md` - applied across all workspaces

**System-Level Rules (Enterprise)**

- **macOS**: `/Library/Application Support/Windsurf/rules/*.md`
- **Linux/WSL**: `/etc/windsurf/rules/*.md`
- **Windows**: `C:\ProgramData\Windsurf\rules\*.md`

### Rule Discovery

Windsurf automatically discovers rules from:

- Current workspace and sub-directories
- Git repository structure (up to git root)
- Multiple workspace support (deduplicated with shortest relative path)

### Activation Modes

Rules can be activated in four ways:

1. **always_on** - Always applied
2. **glob** - Applied based on file pattern matching
3. **model_decision** - Cascade decides when to apply
4. **manual** - User manually activates

### File Format

Rules are markdown files with optional frontmatter. Maximum 12,000 characters per file.

### Best Practices for Rules

**Keep Rules Simple and Specific**

- Avoid long or vague rules that may confuse Cascade
- No need for generic rules (e.g., "write good code") - these are baked into training data

**Use Structured Formatting**

- Bullet points and numbered lists are easier for Cascade to follow
- XML tags can group similar rules effectively

**Example Rule:**

```markdown
# Coding Guidelines

<coding_guidelines>

- My project's programming language is python
- Use early returns when possible
- Always add documentation when creating new functions and classes
  </coding_guidelines>

<security>
- Never hardcode API keys
- Validate all user inputs
- Use parameterized queries for database operations
</security>
```

**Management**

- Access via Customizations icon in Cascade panel
- Click Edit to modify existing rules
- Example templates available at [windsurf.com/editor/directory](https://windsurf.com/editor/directory)

---

## Skills

### Purpose

Skills help Cascade handle complex, multi-step tasks by bundling instructions, templates, checklists, and supporting files into folders that Cascade can invoke.

### Key Concept: Progressive Disclosure

Only the skill's `name` and `description` are shown to the model by default. The full `SKILL.md` content and supporting files are loaded **only when Cascade decides to invoke the skill** (or when you `@mention` it). This keeps the context window lean even with many skills defined.

### Storage Locations

**Workspace Skills (project-specific)**

- `.windsurf/skills/<skill-name>/`
- Committed with your repo
- Available only in current workspace

**Global Skills**

- `~/.codeium/windsurf/skills/<skill-name>/`
- Available in all workspaces on your machine
- Not committed to repo

**System-Level Skills (Enterprise)**

- **macOS**: `/Library/Application Support/Windsurf/skills/`
- **Linux/WSL**: `/etc/windsurf/skills/`
- **Windows**: `C:\ProgramData\Windsurf\skills\`
- Read-only, deployed by IT

**Cross-Agent Compatibility**
Windsurf also discovers skills in:

- `.agents/skills/` and `~/.agents/skills/`
- `.claude/skills/` and `~/.claude/skills/` (if Claude Code config reading enabled)

### Skill Structure

```
.windsurf/skills/<skill-name>/
├── SKILL.md (required)
├── deployment-checklist.md (optional)
├── rollback-procedure.md (optional)
└── config-template.yaml (optional)
```

### SKILL.md File Format

**Required Frontmatter Fields:**

- **name**: Unique identifier (lowercase letters, numbers, hyphens only)
- **description**: Brief explanation to help Cascade decide when to invoke

**Example SKILL.md:**

```markdown
---
name: deploy-to-production
description: Guides the deployment process to production with safety checks
---

## Pre-deployment Checklist

1. Run all tests
2. Check for uncommitted changes
3. Verify environment variables

## Deployment Steps

Follow these steps to deploy safely...

[Reference supporting files in this directory as needed]
```

### Creating Skills

**Using the UI (easiest):**

1. Open Cascade panel
2. Click three dots → Customizations menu
3. Click Skills section
4. Click + Workspace or + Global
5. Name the skill (lowercase, numbers, hyphens only)

**Manual Creation:**

- Create directory: `.windsurf/skills/<skill-name>/`
- Add SKILL.md with YAML frontmatter
- Add any supporting files

### Invoking Skills

**Automatic Invocation**

- Cascade automatically invokes skills when request matches description
- The `description` field is critical for this
- Most common usage pattern

**Manual Invocation**

- Type `@skill-name` in Cascade input
- Useful when you want to ensure specific skill is used
- Or when skill might not be automatically triggered

### Example Use Cases

**Deployment Workflow**

```
.windsurf/skills/deploy-staging/
├── SKILL.md
├── pre-deploy-checks.sh
├── environment-template.env
└── rollback-steps.md
```

**Code Review Guidelines**

```
.windsurf/skills/code-review/
├── SKILL.md
├── style-guide.md
├── security-checklist.md
└── review-template.md
```

**Testing Procedures**

```
.windsurf/skills/run-tests/
├── SKILL.md
├── test-template.py
├── coverage-config.json
└── ci-workflow.yaml
```

### Best Practices for Skills

1. **Write Clear Descriptions**
   - Be specific about what the skill does
   - Explain when it should be used
   - This is key for automatic invocation

2. **Include Relevant Resources**
   - Templates, checklists, examples make skills more useful
   - Think about what files would help complete the task

3. **Use Descriptive Names**
   - `deploy-to-staging` is better than `deploy1`
   - Names should clearly indicate purpose

---

## Workflows

### Purpose

Workflows provide a structured sequence of steps at the trajectory level, guiding Cascade through a series of interconnected tasks. They are prompt templates for repeatable tasks that you trigger explicitly.

### Storage Locations

- `.windsurf/workflows/` in current workspace directory
- `.windsurf/workflows/` in any sub-directory
- `.windsurf/workflows/` in parent directories up to git root
- Maximum 12,000 characters per file

### Workflow Discovery

Same as rules - automatic discovery from workspace, subdirectories, and git root.

### Creating Workflows

1. Click Customizations icon in Cascade
2. Navigate to Workflows panel
3. Click + Workflow button
4. Workflows saved as markdown files with title, description, and steps

### Invoking Workflows

- Use slash command: `/[workflow-name]`
- Manual invocation only
- Can call other workflows from within a workflow

### Workflow Features

- Sequential processing of steps
- Can include instructions like "Call /workflow-2"
- Particularly good for CLI tool procedures
- Can be generated by Cascade (ask it to create workflows)

---

## Comparison: Rules vs Skills vs Workflows

| Aspect                | Skills                                                   | Rules                                          | Workflows                                |
| --------------------- | -------------------------------------------------------- | ---------------------------------------------- | ---------------------------------------- |
| **Purpose**           | Multi-step procedures with supporting files              | Behavioral guidelines ("how to behave")        | Prompt templates for repeatable tasks    |
| **Structure**         | Folder with SKILL.md + resource files                    | Single .md file with frontmatter               | Single .md file                          |
| **Invocation**        | Model decides (progressive disclosure) or @mention       | always_on / glob / model_decision / manual     | Manual only via /slash-command           |
| **In System Prompt?** | No - only name + description until invoked               | Depends on activation mode                     | No - listed as available commands        |
| **Best For**          | Deployments, code review, testing with scripts/templates | Coding style, project conventions, constraints | One-shot runbooks you trigger explicitly |

### Rule of Thumb

- **Use Skills** if Cascade should pick it up automatically AND it needs supporting files
- **Use Rules** if it's a short behavioral constraint
- **Use Workflows** if you always want to trigger it yourself

---

## Best Practices

### General Principles

**1. Keep It Simple**

- Avoid overly complex rules or skills
- Simple, specific instructions are more effective

**2. Use Structured Formatting**

- Bullet points and numbered lists
- XML tags for grouping related rules
- Clear headings and sections

**3. Be Specific**

- Avoid generic instructions
- Use concrete examples
- Specify exact behaviors

**4. Test and Iterate**

- Start with basic rules/skills
- Refine based on actual usage
- Monitor Cascade's adherence

### Rule-Specific Best Practices

- **Length**: Keep under 12,000 characters
- **Format**: Use markdown structure (headings, lists, code blocks)
- **Scope**: Define clear activation modes
- **Content**: Focus on behavioral constraints, not task instructions
- **Avoid**: Generic "write good code" rules (already in training)

### Skill-Specific Best Practices

- **Description**: Write clear, specific descriptions for automatic invocation
- **Resources**: Include all necessary supporting files
- **Naming**: Use descriptive, lowercase names with hyphens
- **Structure**: Organize supporting files logically
- **Progressive Disclosure**: Leverage by keeping SKILL.md focused

### Workflow-Specific Best Practices

- **Steps**: Break down into clear, sequential steps
- **Composition**: Can call other workflows for modularity
- **Generation**: Ask Cascade to generate workflows for CLI procedures
- **Length**: Keep under 12,000 characters

---

## Enterprise Configuration

### System-Level Rules

**Deployment**

- Managed by IT/security team
- Use MDM or configuration management tools
- Cannot be modified by end users
- Displayed with "System" label in Cascade UI

**Behavior**

- Merged with workspace and global rules
- Provide additional context without overriding user rules
- Establish baseline standards while allowing team customizations

### System-Level Skills

**Deployment**

- Same OS-specific paths as rules
- Read-only for end users
- Deployed by IT teams

**Use Cases**

- Organization-wide deployment procedures
- Standardized code review processes
- Enterprise security checklists

### Management

**Tools**

- Mobile Device Management (MDM)
- Configuration Management systems
- Standard deployment workflows

**Compliance**

- Ensure internal teams handle deployment and updates
- Follow organization's security policies
- Maintain version control for rule/skill changes

---

## Related Documentation

- [Workflows Documentation](https://docs.windsurf.com/windsurf/cascade/workflows)
- [AGENTS.md](https://docs.windsurf.com/windsurf/cascade/agents-md) - Directory-scoped instructions
- [Memories & Rules](https://docs.windsurf.com/windsurf/cascade/memories) - Auto-generated memories and user-defined rules
- [Agent Skills Specification](https://agentskills.io/home) - Detailed skills specification

---

## Quick Reference

### Rule File Locations

- Workspace: `.windsurf/rules/*.md`
- Global: `global_rules.md`
- System (macOS): `/Library/Application Support/Windsurf/rules/*.md`
- System (Linux): `/etc/windsurf/rules/*.md`
- System (Windows): `C:\ProgramData\Windsurf\rules\*.md`

### Skill File Locations

- Workspace: `.windsurf/skills/<name>/SKILL.md`
- Global: `~/.codeium/windsurf/skills/<name>/SKILL.md`
- System (macOS): `/Library/Application Support/Windsurf/skills/<name>/SKILL.md`
- System (Linux): `/etc/windsurf/skills/<name>/SKILL.md`
- System (Windows): `C:\ProgramData\Windsurf\skills\<name>\SKILL.md`

### Workflow File Locations

- Workspace: `.windsurf/workflows/*.md`
- Subdirectories: `.windsurf/workflows/*.md`
- Parent directories up to git root

### Character Limits

- Rules: 12,000 characters per file
- Workflows: 12,000 characters per file
- Skills: No explicit limit on SKILL.md (use good judgment)

### Invocation Methods

- Rules: always_on, glob, model_decision, manual
- Skills: Automatic (based on description) or @skill-name
- Workflows: /workflow-name (manual only)
