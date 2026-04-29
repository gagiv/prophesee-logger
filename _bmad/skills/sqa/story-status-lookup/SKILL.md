---
name: story-status-lookup
description: Looks up the current status of a story by searching the unified sprint-status.yaml (backlog and sprint items arrays) to classify code as delivered or work-in-progress. Supports file-system backend; Jira backend reserved for future configuration.
---
# Story Status Lookup

Look up the current status of a story to determine whether its code is **delivered** or **work-in-progress**.

## Purpose

Used by other skills (notably `auto-bug-detection`) to classify code before deciding whether to flag defects.
Do not flag bugs in WIP code. Do flag bugs in delivered code.

---

## Backend Configuration

Before performing a lookup, check the project context for the configured sprint management backend.

**Where to look (in priority order):**
1. `project-context.md` in the project root — look for a `sprint_management` field
2. The root directives file (`CLAUDE.md`, `.cursor/rules`, or equivalent for the active agent)
3. If neither defines a backend, **default to `file-system`**

| `sprint_management` value | Backend |
|---|---|
| `file-system` or not set | Read `sprint-status.yaml` (see below) |
| `jira` | *(Future — see Jira section below)* |

---

## File-System Backend

**Status file:** `_bmad-output/implementation-artifacts/sprint-status.yaml`

### Step 1 — Identify the story slug

Derive the story slug from the available context, in this order of preference:

1. The story file name currently in scope (e.g. `11-1-auto-bug-detection-skill.md` → slug is `11-1-auto-bug-detection-skill`)
2. The git branch name — strip prefixes (`feature/`, `fix/`, `chore/`) and normalize: lowercase, replace spaces and underscores with hyphens, remove non-alphanumeric characters except hyphens
3. Any explicit story reference in the current task description

### Step 2 — Search for the slug across all sections

Read `sprint-status.yaml` and search the following sections in order. Stop at the first match.

**2a. Backlog search:** Iterate the `backlog` array. For each item, check if `item.id` equals the derived slug.
- If found: record the item's `status` field value and note location as `"in backlog (unassigned)"`.

**2b. Sprint search:** Iterate the `sprints` map. For each sprint entry, iterate its `items` array. For each item, check if `item.id` equals the derived slug.
- If found: record the item's `status` field value and note location as `"in {sprint-id}"` (e.g., `"in sprint-3"`).

**2c. Done archive fallback:** If the slug was not found in any section above, check for a file at `{story_location}/done/{slug}.md`, where `story_location` is the metadata field from `sprint-status.yaml` (default: `_bmad-output/implementation-artifacts`).
- If the file exists: classify as **Delivered** — report `"Story {id} is archived (done)"`.

**2d. Not found:** If not found in backlog, sprints, or done archive, report `"Story {id} not found in sprint-status.yaml or done/ archive"` and classify as **WIP**.

### Step 3 — Map status to delivered / WIP

| Status value | Classification | Action |
|---|---|---|
| `done` | **Delivered** | Flag bugs |
| `review` | **Delivered** | Flag bugs — dev work is complete, code is awaiting review |
| `in-progress` | WIP | Do not flag |
| `ready-for-dev` | WIP | Do not flag |
| `backlog` | WIP | Do not flag |
| `on-hold` | WIP | Do not flag |
| `cancelled` | WIP | Do not flag |

### Fallback rule

Apply the first matching rule; do not continue down the list:

1. Slug cannot be determined from context → **WIP**
2. Slug not found in `sprint-status.yaml` → check `done/` archive (Step 2c)
3. Found in `done/` archive → **Delivered**
4. Not found anywhere → **WIP**
5. Status file does not exist → **WIP**

Never guess or assume delivered status. When in doubt, WIP.

---

## Future: Jira Backend

When `sprint_management: jira` is set in the project context, this extension point applies:

- Jira base URL, project key, and credentials will be defined in the project context or environment config
- Query the Jira issue status API for the relevant issue key
- Map the Jira workflow status to delivered/WIP using a status mapping defined in the project context

**This backend is not yet implemented.** When Jira support is added, update this skill with the lookup procedure and status mapping. The file-system backend remains the default fallback if Jira is unreachable.
