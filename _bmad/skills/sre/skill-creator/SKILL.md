---
name: Skill Creator
description: Guide for creating effective skills that extend Claude's capabilities with specialized knowledge, workflows, and tool integrations
---
# Skill Creator

This skill provides guidance for creating effective skills.

## About Skills

Skills are modular, self-contained packages that extend Claude's capabilities by providing
specialized knowledge, workflows, and tools. Think of them as "onboarding guides" for specific
domains or tasks—they transform Claude from a general-purpose agent into a specialized agent
equipped with procedural knowledge that no model can fully possess.

### What Skills Provide

1. Specialized workflows - Multi-step procedures for specific domains
2. Tool integrations - Instructions for working with specific file formats or APIs
3. Domain expertise - Company-specific knowledge, schemas, business logic
4. Bundled resources - Scripts, references, and assets for complex and repetitive tasks

## Core Principles

### Concise is Key

The context window is a public good. Skills share the context window with everything else Claude needs: system prompt, conversation history, other Skills' metadata, and the actual user request.

**Default assumption: Claude is already very smart.** Only add context Claude doesn't already have. Challenge each piece of information: "Does Claude really need this explanation?" and "Does this paragraph justify its token cost?"

Prefer concise examples over verbose explanations.

### Set Appropriate Degrees of Freedom

Match the level of specificity to the task's fragility and variability:

**High freedom (text-based instructions)**: Use when multiple approaches are valid, decisions depend on context, or heuristics guide the approach.

**Medium freedom (pseudocode or scripts with parameters)**: Use when a preferred pattern exists, some variation is acceptable, or configuration affects behavior.

**Low freedom (specific scripts, few parameters)**: Use when operations are fragile and error-prone, consistency is critical, or a specific sequence must be followed.

### Anatomy of a Skill

Every skill consists of a required SKILL.md file and optional bundled resources:

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   ├── description: (required)
│   │   └── compatibility: (optional, rarely needed)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/          - Executable code (Python/Bash/etc.)
    ├── references/       - Documentation intended to be loaded into context as needed
    └── assets/           - Files used in output (templates, icons, fonts, etc.)
```

#### SKILL.md (required)

- **Frontmatter** (YAML): Contains `name` and `description` fields (required), plus optional fields like `license`, `metadata`, and `compatibility`. Only `name` and `description` are read by Claude to determine when the skill triggers.
- **Body** (Markdown): Instructions and guidance for using the skill. Only loaded AFTER the skill triggers.

#### Bundled Resources (optional)

##### Scripts (`scripts/`)

Executable code for tasks that require deterministic reliability or are repeatedly rewritten.

- **When to include**: When the same code is being rewritten repeatedly or deterministic reliability is needed
- **Benefits**: Token efficient, deterministic, may be executed without loading into context

##### References (`references/`)

Documentation intended to be loaded as needed into context.

- **When to include**: For documentation that Claude should reference while working
- **Use cases**: Database schemas, API documentation, domain knowledge, company policies
- **Best practice**: If files are large (>10k words), include grep search patterns in SKILL.md
- **Avoid duplication**: Information lives in either SKILL.md or references files, not both

##### Assets (`assets/`)

Files not intended to be loaded into context, but used within the output Claude produces.

- **When to include**: When the skill needs files for final output
- **Use cases**: Templates, images, icons, boilerplate code, fonts, sample documents

#### What NOT to Include

Do NOT create: README.md, INSTALLATION_GUIDE.md, QUICK_REFERENCE.md, CHANGELOG.md, or other auxiliary documentation. The skill should only contain information needed for an AI agent to execute tasks.

### Progressive Disclosure Design Principle

Three-level loading system:

1. **Metadata (name + description)** - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (<5k words)
3. **Bundled resources** - As needed by Claude (Unlimited)

Keep SKILL.md body under 500 lines. Split content into separate files when approaching this limit.

**Pattern 1: High-level guide with references**

```markdown
# PDF Processing
## Quick start
Extract text with pdfplumber: [code example]
## Advanced features
- **Form filling**: See [FORMS.md](FORMS.md) for complete guide
- **API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
```

**Pattern 2: Domain-specific organization**

```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── references/
    ├── finance.md (revenue, billing metrics)
    ├── sales.md (opportunities, pipeline)
    └── product.md (API usage, features)
```

**Pattern 3: Conditional details**

```markdown
# DOCX Processing
## Creating documents
Use docx-js for new documents. See [DOCX-JS.md](DOCX-JS.md).
## Editing documents
For simple edits, modify the XML directly.
**For tracked changes**: See [REDLINING.md](REDLINING.md)
```

## Skill Creation Process

1. Understand the skill with concrete examples
2. Plan reusable skill contents (scripts, references, assets)
3. Initialize the skill (run scripts/init_skill.py)
4. Edit the skill (implement resources and write SKILL.md)
5. Package the skill (run scripts/package_skill.py)
6. Iterate based on real usage

### Step 1: Understanding the Skill with Concrete Examples

Gather concrete examples of how the skill will be used. Ask users clarifying questions about functionality and triggers. Conclude when there's clear understanding of supported functionality.

### Step 2: Planning the Reusable Skill Contents

Analyze each concrete example:
1. Consider how to execute the example from scratch
2. Identify what scripts, references, and assets would be helpful for repeated execution

### Step 3: Initializing the Skill

```bash
scripts/init_skill.py <skill-name> --path <output-directory>
```

Creates skill directory with SKILL.md template, example resource directories, and placeholder files.

### Step 4: Edit the Skill

**Writing guideline:** Always use imperative/infinitive form.

**Update Frontmatter:**
- `name`: The skill name
- `description`: Include both what the skill does AND specific triggers/contexts for when to use it

**Update Body:**
- Write instructions for using the skill and bundled resources
- For multi-step processes: See references/workflows.md
- For specific output formats: See references/output-patterns.md

**Start with Reusable Skill Contents:**
- Implement scripts, references, and assets first
- Test scripts by running them
- Delete example files not needed for the skill

### Step 5: Packaging a Skill

```bash
scripts/package_skill.py <path/to/skill-folder> [output-directory]
```

Validates and packages the skill into a distributable .skill file (zip format).

### Step 6: Iterate

1. Use the skill on real tasks
2. Notice struggles or inefficiencies
3. Identify how SKILL.md or bundled resources should be updated
4. Implement changes and test again
