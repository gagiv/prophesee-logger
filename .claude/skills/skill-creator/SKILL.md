---
name: Skill Creator
description: Guide for creating effective skills that extend Claude's capabilities with specialized knowledge, workflows, and tool integrations
---
# Skill Creator

## Description
Guide for creating effective skills that extend Claude's capabilities with specialized knowledge, workflows, and tool integrations.

## Usage
Invoke this skill when creating or updating a skill package.

## Instructions

### Skill Creation Process

Follow these steps in order:

1. **Understand** the skill with concrete examples
2. **Plan** reusable skill contents (scripts, references, assets)
3. **Initialize** the skill (run `scripts/init_skill.py <name> --path <dir>`)
4. **Edit** the skill (implement resources, write SKILL.md)
5. **Package** the skill (run `scripts/package_skill.py <path>`)
6. **Iterate** based on real usage

### Core Principles

- **Concise is key**: Claude is already smart — only add context it doesn't have. Challenge each piece of information: "Does Claude really need this?"
- **Appropriate freedom**: Match specificity to task fragility. High freedom for flexible tasks, low freedom for fragile operations.
- **Progressive disclosure**: Keep SKILL.md under 500 lines. Use references/ for detailed content.

### Skill Structure

```
skill-name/
├── skill.json (required — single source of truth for metadata)
├── SKILL.md (required — pure Markdown, no frontmatter)
├── scripts/          (executable code, Python/Bash)
├── references/       (documentation loaded into context as needed)
├── examples/         (sample outputs showing expected format)
├── hooks/            (git hooks or other hook scripts)
└── assets/           (files used in output: templates, images, fonts)
```

### skill.json (metadata)

Contains `name`, `description`, `version`, `author`, `tags`. The `description` is the primary trigger mechanism — include both what the skill does AND when to use it. The installer automatically injects YAML frontmatter from skill.json into the installed SKILL.md.

### Bundled Resources

- **scripts/**: For code that's rewritten repeatedly or needs deterministic reliability
- **references/**: For documentation Claude should reference while working (schemas, APIs, policies)
- **assets/**: For files used in output but not loaded into context (templates, images, fonts)

### What NOT to Include

Do NOT create README.md, INSTALLATION_GUIDE.md, QUICK_REFERENCE.md, CHANGELOG.md, or other auxiliary docs. Only include what an AI agent needs to execute tasks.

### Design Patterns

- **Multi-step processes**: See [references/workflows.md](references/workflows.md)
- **Output formats**: See [references/output-patterns.md](references/output-patterns.md)

### Tools

- **Initialize**: `scripts/init_skill.py <skill-name> --path <output-dir>`
- **Validate**: `scripts/quick_validate.py <skill-dir>`
- **Package**: `scripts/package_skill.py <skill-dir> [output-dir]`
