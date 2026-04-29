---
name: bmad-sprint-planning
description: Bootstrap or update the unified sprint-status.yaml from epics. Creates the file with three sections (epics, backlog, sprints) on first run; refreshes epics and adds new items on subsequent runs.
---
# Sprint Planning Skill

**Goal:** Bootstrap or refresh the unified `sprint-status.yaml` from epics, building a complete three-section file (`epics`, `backlog`, `sprints`).

**Your Role:** You are a Scrum Master bootstrapping or refreshing sprint tracking. Parse epic files, scan bugs, detect story statuses, and produce or update a structured `sprint-status.yaml` with the unified schema.

---

## INITIALIZATION

### Path Resolution

Resolve project root as the directory containing `_bmad-output/`. Then set:

- `implementation_artifacts` = `_bmad-output/implementation-artifacts`
- `planning_artifacts` = `_bmad-output/planning-artifacts`
- `status_file` = `_bmad-output/implementation-artifacts/sprint-status.yaml`
- `done_folder` = `_bmad-output/implementation-artifacts/done/`
- `story_location` = `_bmad-output/implementation-artifacts`

Attempt to read project name from `_bmad/bmm/config.yaml` (field `project_name`). If the file does not exist or `project_name` is absent, derive project name from the root directory name or use `"Unknown Project"`.

---

## EXECUTION

<workflow>

<step n="1" goal="Parse epic files and extract all work items">

**Epic Discovery Process:**

1. Search for whole document first — look for `epics.md`, `bmm-epics.md`, or any `*epic*.md` file in `_bmad-output/planning-artifacts/`
2. If whole document not found, look for `_bmad-output/planning-artifacts/epics/index.md` (sharded version)
3. If sharded version found: read `index.md` then read ALL referenced epic section files
4. If both exist, use the whole document

<action>For each epic file found, extract:</action>

- Epic numbers from headers like `## Epic 1:` or `## Epic 2:`
- Story IDs and titles from patterns like `### Story 1.1: User Authentication`
- Epic status cues from narrative text:
  - "in progress", "started", "active" → `in-progress`
  - "on hold", "paused", "blocked" → `on-hold`
  - "cancelled", "dropped" → `cancelled`
  - default → `backlog`

**Story ID Conversion Rules:**

- Original: `### Story 1.1: User Authentication`
- Replace period with dash: `1-1`
- Convert title to kebab-case: `user-authentication`
- Final ID: `1-1-user-authentication`

<action>Build:
  - `{{all_epics}}` — list of epic objects: `epic_num`, `title`, `detected_status`
  - `{{all_stories}}` — list of story objects: `id`, `epic_num`, `title`
</action>
</step>

<step n="2" goal="Scan bug files">
<action>Glob `_bmad-output/implementation-artifacts/bug-*.md` to find all bug story files</action>
<check if="no bug files found">
  <action>Set `{{all_bugs}}` = []</action>
</check>
<check if="bug files found">
  <action>For each bug file, parse YAML frontmatter to extract: `title`, `severity`, `status`</action>
  <action>Derive bug ID: strip `bug-` prefix and `.md` extension, then prefix with `BUG-` (e.g., `bug-path-spaces.md` → `BUG-path-spaces`)</action>
  <action>Set `{{all_bugs}}` = list of bug objects: `id`, `title`, `severity` (default `medium`), `status` (default `backlog`)</action>
</check>
</step>

<step n="3" goal="Mode detection — bootstrap vs refresh">
<check if="`_bmad-output/implementation-artifacts/sprint-status.yaml` does NOT exist">
  <action>Set `{{mode}}` = `bootstrap`</action>
  <action>Proceed to Step 4 then Step 5</action>
</check>
<check if="`_bmad-output/implementation-artifacts/sprint-status.yaml` EXISTS">
  <action>Set `{{mode}}` = `refresh`</action>
  <action>Read existing file into `{{existing_file}}`</action>
  <action>Proceed to Step 4 then Step 6</action>
</check>
</step>

<step n="4" goal="Done exclusion scan">
<action>Scan `_bmad-output/implementation-artifacts/done/` for archived files. Build `{{done_item_ids}}` = set of basenames (without `.md`) from all files in the done folder</action>
<check if="`{{mode}}` == `refresh`">
  <action>Scan `{{existing_file}}` for items with `status: done` in `backlog` or any `sprints[*].items`</action>
  <check if="any done items found in backlog or sprints">
    <output>
## Warning: Done Items Detected in Active File

The following items have `status: done` but are still present in the active `sprint-status.yaml`:

{{#each done_items_in_file}}
- `{{id}}` (in: {{location}})
{{/each}}

These items should be archived before adding new items. Consider running `cleanup-done` to archive them first.

Continuing with planning — done items will be excluded from new additions.
    </output>
    <action>Add these IDs to `{{done_item_ids}}`</action>
  </check>
</check>
</step>

<step n="5" goal="Bootstrap mode — build complete file from scratch">
<check if="`{{mode}}` != `bootstrap`">
  <action>Skip this step</action>
</check>

**Build metadata:**
- `generated` = current ISO-8601 datetime
- `last_updated` = current ISO-8601 datetime
- `project` = resolved project name
- `project_key` = `NOKEY`
- `tracking_system` = `file-system`
- `story_location` = `_bmad-output/implementation-artifacts`

**Build `epics` section:**
<action>For each epic in `{{all_epics}}`:
  - Key: `epic-{epic_num}`
  - `status`: use detected status from epic narrative, default `backlog`
  - `retrospective`: `optional`
</action>

**Build `backlog` section:**
<action>Combine `{{all_stories}}` and `{{all_bugs}}` into candidate list, excluding any IDs in `{{done_item_ids}}`</action>
<action>For each story candidate:
  - Detect status: check if `_bmad-output/implementation-artifacts/{story_id}.md` exists → `ready-for-dev`; else → `backlog`
</action>

**Ordering rules for initial priority:**
1. Bugs with `severity: critical` — first (highest priority)
2. Stories in epic order, then story number within each epic
3. Remaining bugs (`high`, `medium`, `low`) — after stories

<action>Assign sequential `priority` values (1, 2, 3...) based on ordering</action>

**Build each backlog item:**
```
id:       story ID (e.g., "1-1-user-auth") or bug ID (e.g., "BUG-path-spaces")
type:     "story" or "bug"
epic:     epic number as integer for stories, null for bugs
title:    story/bug title
priority: sequential integer (1 = highest)
status:   detected status for stories; "backlog" for bugs (or from frontmatter)
severity: null for stories; value for bugs
```

**`sprints` section:** empty map `{}`

<action>Write complete `sprint-status.yaml` to `_bmad-output/implementation-artifacts/sprint-status.yaml`</action>
</step>

<step n="6" goal="Refresh mode — additive merge">
<check if="`{{mode}}` != `refresh`">
  <action>Skip this step</action>
</check>

<action>From `{{existing_file}}` extract:
  - `generated` timestamp (preserve — never change)
  - existing `epics` map
  - existing `backlog` array
  - existing `sprints` map
</action>

**Regenerate `epics` section with status preservation:**
<action>For each epic in `{{all_epics}}`:
  - If epic already exists in existing file: apply never-downgrade rule for `status`; preserve existing `retrospective`
  - If epic is NEW: use detected status (default `backlog`), `retrospective: optional`
</action>

**Never-downgrade status rules:**
- `done` → keep `done` (no downgrade)
- `in-progress` + detected `backlog` → keep `in-progress`
- `on-hold` → keep `on-hold` (sticky)
- `cancelled` → keep `cancelled` (terminal)
- Otherwise → use detected status

**Build exclusion sets:**
- `{{existing_backlog_ids}}` = all `id` values in existing `backlog` array
- `{{sprint_item_ids}}` = all `id` values in any `sprints[*].items` arrays
- `{{excluded_ids}}` = union of above + `{{done_item_ids}}`

**Find new items to append:**
<action>From `{{all_stories}}` and `{{all_bugs}}`, identify items whose ID is NOT in `{{excluded_ids}}`</action>

**Append new items:**
<action>Calculate `{{max_priority}}` = max `priority` in existing backlog (0 if empty)</action>
<action>For each new item (stories in epic order first, then bugs):
  - `priority` = `{{max_priority}}` + sequential increment
  - For stories: detect status from file existence
  - For bugs: use frontmatter status or default `backlog`
</action>

**Final file:**
- `backlog` = existing items (unchanged) + new items (appended)
- `sprints` = existing sprints (unchanged — pass through exactly)
- `epics` = regenerated (with preservation)
- `last_updated` = current ISO-8601 datetime
- `generated` = original value (NEVER change)

<action>Write updated file (atomic read-modify-write)</action>
</step>

<step n="7" goal="Validation">
<action>Validate the written file:</action>

- [ ] File is valid YAML syntax
- [ ] 6 metadata fields present: `generated`, `last_updated`, `project`, `project_key`, `tracking_system`, `story_location`
- [ ] 3 data sections: `epics`, `backlog`, `sprints`
- [ ] No `development_status` section (old flat format must not appear)
- [ ] Every epic in source files appears in `epics` section
- [ ] Every story appears in exactly one location (backlog, sprint, or done/)
- [ ] No item ID in more than one active location (single-location invariant)
- [ ] All `status` values are legal (epic: backlog/in-progress/done/on-hold/cancelled; item: backlog/ready-for-dev/in-progress/review/done/on-hold/cancelled)
- [ ] Backlog `priority` values are sequential 1..N
- [ ] `sprints` section unchanged (refresh mode)
- [ ] `generated` timestamp unchanged (refresh mode)

<check if="validation errors found">
  <output>
## Validation Errors

{{#each validation_errors}}
- {{message}}
{{/each}}

Please review `_bmad-output/implementation-artifacts/sprint-status.yaml` and correct the issues.
  </output>
</check>
</step>

<step n="8" goal="Report summary">
<output>
## Sprint Planning Complete

**Mode:** {{mode}} ({{#if bootstrap}}first run — file created{{else}}refresh — file updated{{/if}})
**File:** `_bmad-output/implementation-artifacts/sprint-status.yaml`

### Summary

| Section | Count |
|---------|-------|
| Total epics | {{epic_count}} |
| Total stories | {{story_count}} |
| Total bugs | {{bug_count}} |
{{#if refresh}}
| New items added | {{new_items_count}} |
| Items preserved (backlog) | {{preserved_backlog_count}} |
| Items excluded (sprint-assigned) | {{sprint_assigned_count}} |
| Items excluded (done-archived) | {{done_archived_count}} |
{{/if}}

### Epic Status Overview

| Epic | Title | Status |
|------|-------|--------|
{{#each epics_summary}}
| `{{id}}` | {{title}} | {{status}} |
{{/each}}

### Next Steps

1. Review the generated `_bmad-output/implementation-artifacts/sprint-status.yaml`
2. Run `generate-backlog` to refresh and reprioritize backlog items
3. Run `add-sprint` to create a sprint for the next iteration
4. Run `add-to-sprint` to assign backlog items to a sprint
</output>
</step>

</workflow>

---

## Additional Documentation

### Status State Machines

**Epic Status Flow:**
```
backlog → in-progress → done
              ↕
           on-hold

Any non-done → cancelled (terminal)
```

**Story/Bug Status Flow:**
```
backlog → ready-for-dev → in-progress → review → done
               ↕              ↕           ↕
            on-hold        on-hold      on-hold

Any non-done → cancelled (terminal)
```

### Three-Section Schema Summary

```yaml
epics:        # Map keyed by epic-N — regenerated each run with preservation
backlog:      # Array of items — additive only (new items appended, existing preserved)
sprints:      # Map keyed by sprint-N — NEVER modified by this skill
```

### Never-Downgrade Rule

Status is never downgraded on refresh. If the existing file says `in-progress`, a re-detected `backlog` from the epic file does NOT override it. This ensures human-set statuses are preserved across planning runs.

### Schema Quick Reference

**Backlog item fields:** `id`, `type`, `epic`, `title`, `priority`, `status`, `severity`
**Sprint item fields:** `id`, `type`, `epic`, `title`, `status`, `severity` (no `priority`)
**Epic fields:** `status`, `retrospective`
