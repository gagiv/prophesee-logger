---
name: AI Audit Trail
description: Tracks AI agent session activity, time spent, and token usage in a project-level AiAudit.md log file.
---
# AI Audit Trail

At the end of every significant agent session, append an entry to `{project_root}/AiAudit.md`. If the file does not exist, create it with a `# AI Audit Trail` header first.

## Entry Format

```markdown
| Date | Task | Tokens (est.) |
|------|------|---------------|
| YYYY-MM-DD | Brief task description | In: ~X / Out: ~Y |
```

## Rules

- **Append only** — never delete or modify previous entries
- **One row per session** — combine multiple tasks in the same session into one entry
- **Estimate tokens** — round to nearest thousand, prefix with `~`. Write `N/A` if unknown
- Write the entry as the **last action** before presenting results to the user
- Skip trivial interactions (single-question answers, quick lookups)
