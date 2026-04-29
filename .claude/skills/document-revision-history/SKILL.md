---
name: Document Revision History
description: Manages a revision history table at the beginning of generated documents, tracking changes per version.
---
# Document Revision History

Manage a revision history table at the beginning of every generated or updated document. This ensures traceability of changes across document versions.

## Policy

### 1. Revision History Table Required

Every document generated or updated by the agent MUST include a **Revision History** table immediately after the document title (before the Table of Contents or Section 1).

### 2. Table Format

Use the following markdown table format:

```markdown
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-03-02 | Agent (Claude) | Initial document generation |
```

### 3. Column Definitions

| Column | Description |
|--------|-------------|
| **Version** | Document version number (e.g., 1.0, 1.1, 2.0). Use semantic versioning: major version for structural changes, minor for content updates |
| **Date** | Date of the change in `YYYY-MM-DD` format |
| **Author** | Who made the change — use `Agent (<model>)` for AI-generated content, or the user's name for user-directed changes |
| **Changes** | Brief summary of ALL changes made in this version. One line per version — consolidate multiple changes into a single descriptive entry |

### 4. Rules for New Documents

When **generating a new document** for the first time:
- Add the revision history table immediately after the document title
- Set version to `1.0`
- Set date to today's date
- Set author to `Agent (<model>)` where `<model>` is the AI model name
- Set changes to `Initial document generation`

### 5. Rules for Updated Documents

When **updating an existing document**:
- Read the existing revision history table
- Determine the new version number:
  - **Minor increment** (e.g., 1.0 → 1.1): Content updates, corrections, additions to existing sections
  - **Major increment** (e.g., 1.1 → 2.0): Structural changes, section reorganization, significant rewrites
- Add a **single new row** summarizing ALL changes made in this update session
- Do NOT create multiple rows for changes made in the same session — consolidate them into one line
- Preserve all previous revision history entries

### 6. Changes Column Guidelines

Write concise but descriptive change summaries:

**Good examples:**
- `Added Sections 7-8 (impacts, analysis), expanded interface requirements to cover categories a-g`
- `Updated capability requirements based on user feedback, added 3 new interfaces`
- `Fixed traceability matrix, corrected section numbering`

**Bad examples:**
- `Updated document` (too vague)
- `Changed section 3.2.1 requirement SRS-CAP-001 description from X to Y, then changed 3.2.2...` (too granular — summarize)

### 7. Placement

The revision history table MUST appear in this order within the document:

```markdown
# Document Title

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-03-02 | Agent (Claude) | Initial document generation |

> MIL-STD-498 or other document metadata...

## Table of Contents (if applicable)

## 1. Scope
...
```

### 8. Multi-Author Sessions

If the user provides their name or the changes are user-directed corrections:
- Use the user's name as author
- If both the agent and user contribute in the same session, use `{user_name} / Agent (<model>)`

## Example

A document updated twice would have:

```markdown
# Software Requirements Specification (SRS)

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-03-01 | Agent (Claude) | Initial document generation from SSDD and PRD artifacts |
| 1.1 | 2026-03-02 | Joseph / Agent (Claude) | Added 4 interface requirements per user feedback, corrected capability traceability to SSDD |
| 2.0 | 2026-03-15 | Agent (Claude) | Major rewrite: restructured CSCI decomposition after SSDD v2.0, updated all requirement IDs |
```
