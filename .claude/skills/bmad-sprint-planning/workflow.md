# Sprint Planning Workflow

**Goal:** Bootstrap or refresh the unified `sprint-status.yaml` from epics, building a complete three-section file (`epics`, `backlog`, `sprints`).

**Your Role:** You are a Scrum Master bootstrapping or refreshing sprint tracking. Parse epic files, scan bugs, detect story statuses, and produce or update a structured `sprint-status.yaml` with the unified schema.

---

## INITIALIZATION

### Configuration Loading

Load config from `{project-root}/_bmad/bmm/config.yaml` and resolve:

- `project_name`, `user_name`
- `communication_language`, `document_output_language`
- `implementation_artifacts`
- `planning_artifacts`
- `date` as system-generated current ISO-8601 datetime
- YOU MUST ALWAYS SPEAK OUTPUT in your Agent communication style with the config `{communication_language}`

### Paths

- `tracking_system` = `file-system`
- `project_key` = `NOKEY`
- `story_location` = `{implementation_artifacts}`
- `epics_location` = `{planning_artifacts}`
- `epics_pattern` = `*epic*.md`
- `status_file` = `{implementation_artifacts}/sprint-status.yaml`
- `done_folder` = `{implementation_artifacts}/done/`

### Input Files

| Input | Path | Load Strategy |
|-------|------|---------------|
| Epics | `{planning_artifacts}/*epic*.md` (whole) or `{planning_artifacts}/epics/index.md` + parts (sharded) | FULL_LOAD |
| Bugs | `{implementation_artifacts}/bug-*.md` | FULL_LOAD |

### Context

- `project_context` = `**/project-context.md` (load if exists)

---

## EXECUTION

<workflow>

<step n="1" goal="Parse epic files and extract all work items">
<action>Load `{project_context}` for project-wide patterns and conventions (if exists)</action>
<action>Communicate in `{communication_language}` with `{user_name}`</action>

**Epic Discovery Process:**

1. Search for whole document first — look for `epics.md`, `bmm-epics.md`, or any `*epic*.md` file in `{epics_location}`
2. If whole document not found, look for `epics/index.md` (sharded version)
3. If sharded version found:
   - Read `index.md` to understand structure
   - Read ALL epic section files listed in the index (e.g., `epic-1.md`, `epic-2.md`)
   - Process all epics and stories from combined content
4. If both whole and sharded versions exist, use the whole document

<action>For each epic file found, extract:</action>

- Epic numbers from headers like `## Epic 1:` or `## Epic 2:`
- Story IDs and titles from patterns like `### Story 1.1: User Authentication`
- Epic status cues from narrative text: keywords like "in progress", "started", "active" → `in-progress`; "on hold", "paused", "blocked" → `on-hold`; "cancelled", "dropped" → `cancelled`; default → `backlog`

**Story ID Conversion Rules:**

- Original: `### Story 1.1: User Authentication`
- Replace period with dash: `1-1`
- Convert title to kebab-case: `user-authentication`
- Final key: `1-1-user-authentication`

<action>Build complete inventory: `{{all_epics}}` (list of epic numbers + titles + detected statuses) and `{{all_stories}}` (list of story objects: `id`, `epic_num`, `title`)</action>
</step>

<step n="2" goal="Scan bug files">
<action>Glob `{implementation_artifacts}/bug-*.md` to find all bug story files</action>
<check if="no bug files found">
  <action>Set `{{all_bugs}}` = [] (empty list)</action>
</check>
<check if="bug files found">
  <action>For each bug file, parse YAML frontmatter to extract: `title`, `severity`, `status`</action>
  <action>Derive bug ID from filename: strip path and `.md` extension, then prefix with `BUG-` after removing `bug-` prefix (e.g., `bug-path-spaces.md` → `BUG-path-spaces`)</action>
  <action>Set `{{all_bugs}}` = list of bug objects: `id`, `title`, `severity` (default `medium` if missing), `status` (default `backlog` if missing)</action>
</check>
</step>

<step n="3" goal="Mode detection — bootstrap vs refresh">
<check if="`{status_file}` does NOT exist">
  <action>Set `{{mode}}` = `bootstrap`</action>
  <action>Proceed to Step 4 then Step 5</action>
</check>
<check if="`{status_file}` EXISTS">
  <action>Set `{{mode}}` = `refresh`</action>
  <action>Read existing `{status_file}` into `{{existing_file}}`</action>
  <action>Proceed to Step 4 then Step 6</action>
</check>
</step>

<step n="4" goal="Done exclusion scan">
<action>Scan `{done_folder}` for archived files. Build `{{done_item_ids}}` = set of basenames (without `.md`) from all files in the done folder (e.g., `done/1-1-user-auth.md` → `1-1-user-auth`)</action>
<check if="`{{mode}}` == `refresh`">
  <action>Scan `{{existing_file}}` for items with `status: done` in `backlog` or any `sprints[*].items`</action>
  <check if="any done items found in backlog or sprints">
    <output>
## Warning: Done Items Detected in Active File

The following items have `status: done` but are still present in the active `sprint-status.yaml`:

{{#each done_items_in_file}}
- `{{id}}` (in: {{location}})
{{/each}}

These items should be archived before adding new items. Consider running `cleanup-done` (Story 17.14) to archive them first.

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
- `generated` = `{date}` (current ISO-8601 datetime)
- `last_updated` = `{date}`
- `project` = `{project_name}`
- `project_key` = `NOKEY`
- `tracking_system` = `file-system`
- `story_location` = `{story_location}`

**Build `epics` section:**
<action>For each epic in `{{all_epics}}`:
  - Key: `epic-{epic_num}`
  - `status`: use detected status from epic narrative, default `backlog`
  - `retrospective`: `optional`
</action>

**Build `backlog` section:**
<action>Combine `{{all_stories}}` and `{{all_bugs}}` into a candidate list</action>
<action>For each candidate item:
  - Skip if item ID is in `{{done_item_ids}}`
  - For stories: detect status by checking if `{story_location}/{story_id}.md` exists → `ready-for-dev`; else → `backlog`
  - Assign `priority` = sequential index (1, 2, 3...) ordered by: critical bugs first, then by epic order
</action>

**Ordering rules:**
1. Bugs with `severity: critical` — highest priority group
2. Stories by epic order, then story number within epic
3. Bugs with `severity: high`, `medium`, `low` — after stories

<action>Build backlog array with each item:
  - `id`: story ID (e.g., `1-1-user-auth`) or bug ID (e.g., `BUG-path-spaces`)
  - `type`: `story` or `bug`
  - `epic`: epic number as integer for stories, `null` for bugs
  - `title`: story/bug title
  - `priority`: sequential integer (1 = highest)
  - `status`: detected status for stories, `backlog` for bugs (or from frontmatter if set)
  - `severity`: `null` for stories, value for bugs
</action>

**`sprints` section:** empty map `{}`

<action>Write complete `sprint-status.yaml` to `{status_file}` with the following structure:</action>

```yaml
generated: "{date}"
last_updated: "{date}"
project: "{project_name}"
project_key: NOKEY
tracking_system: file-system
story_location: "{story_location}"

epics:
  epic-1:
    status: {status}
    retrospective: optional
  # ... all epics

backlog:
  - id: "{id}"
    type: {story|bug}
    epic: {num|null}
    title: "{title}"
    priority: {n}
    status: {status}
    severity: {null|critical|high|medium|low}
  # ... all non-done items

sprints: {}
```
</step>

<step n="6" goal="Refresh mode — additive merge">
<check if="`{{mode}}` != `refresh`">
  <action>Skip this step</action>
</check>

<action>Read existing `{{existing_file}}`:
  - Extract `generated` timestamp (preserve — never change)
  - Extract existing `epics` section
  - Extract existing `backlog` array
  - Extract existing `sprints` map
</action>

**Regenerate `epics` section (reference data — always overwritten with preservation):**
<action>For each epic in `{{all_epics}}`:
  - If epic already exists in `{{existing_file.epics}}`:
    - Apply never-downgrade rule for `status`: keep existing if it's more advanced than detected
    - Status advancement order: `backlog` < `in-progress` < `done` (never downgrade; `on-hold` and `cancelled` are sticky)
    - Preserve existing `retrospective` value
  - If epic is NEW (not in existing file):
    - Set `status` = detected status from narrative (default `backlog`)
    - Set `retrospective` = `optional`
</action>

**Status preservation rules (never downgrade):**
- If existing `status` is `done` → keep `done` regardless
- If existing `status` is `in-progress` and detected is `backlog` → keep `in-progress`
- If existing `status` is `on-hold` → keep `on-hold` (sticky)
- If existing `status` is `cancelled` → keep `cancelled` (terminal state)
- Otherwise → use detected status

**Build exclusion sets:**
<action>
  - `{{existing_backlog_ids}}` = set of all `id` values in existing `backlog` array
  - `{{sprint_item_ids}}` = set of all `id` values in any `sprints[*].items` array
  - `{{excluded_ids}}` = union of `{{existing_backlog_ids}}`, `{{sprint_item_ids}}`, `{{done_item_ids}}`
</action>

**Identify new items:**
<action>For each story in `{{all_stories}}`:
  - If story ID is NOT in `{{excluded_ids}}` → it is a NEW item to append
</action>
<action>For each bug in `{{all_bugs}}`:
  - If bug ID is NOT in `{{excluded_ids}}` → it is a NEW item to append
</action>

**Append new items to backlog:**
<action>Calculate `{{max_priority}}` = maximum `priority` value in existing backlog (0 if empty)</action>
<action>For each new item (stories first in epic order, then bugs):
  - Assign `priority` = `{{max_priority}}` + sequential increment (1, 2, 3...)
  - For stories: detect status by checking if `{story_location}/{story_id}.md` exists → `ready-for-dev`; else → `backlog`
  - For bugs: use status from frontmatter or default `backlog`
  - Build item with same schema as bootstrap mode
</action>

**Preserve existing sections:**
- `backlog`: keep all existing items unchanged (status, priority, all fields) + append new items at end
- `sprints`: pass through unchanged — do NOT modify sprint data

**Update metadata:**
- `last_updated` = `{date}` (current ISO-8601 datetime)
- `generated` = preserve original value (NEVER change)

<action>Write updated `sprint-status.yaml` to `{status_file}` (atomic read-modify-write)</action>
</step>

<step n="7" goal="Validation">
<action>Run validation checklist (see checklist.md):</action>

- [ ] File is valid YAML syntax
- [ ] Exactly 6 metadata fields present: `generated`, `last_updated`, `project`, `project_key`, `tracking_system`, `story_location`
- [ ] Exactly 3 data sections: `epics`, `backlog`, `sprints`
- [ ] Every epic in `epics.md` appears in the `epics` section
- [ ] Every story in `epics.md` appears in exactly one location: `backlog`, a sprint's `items`, or `done/` folder
- [ ] No item ID appears in more than one active location (single-location invariant)
- [ ] All epic `status` values are legal: `backlog`, `in-progress`, `done`, `on-hold`, `cancelled`
- [ ] All item `status` values are legal: `backlog`, `ready-for-dev`, `in-progress`, `review`, `done`, `on-hold`, `cancelled`
- [ ] Backlog `priority` values are sequential 1..N matching array positions
- [ ] `sprints` section is unchanged from existing (refresh mode only)
- [ ] `generated` timestamp is unchanged (refresh mode only)

<check if="validation fails">
  <output>
## Validation Errors

The following issues were detected:

{{#each validation_errors}}
- {{message}}
{{/each}}

Please review and correct the file before proceeding.
  </output>
</check>
</step>

<step n="8" goal="Report summary">
<action>Count and display totals:</action>

<output>
## Sprint Planning Complete

**Mode:** {{mode}} ({{#if bootstrap}}first run — file created{{else}}refresh — file updated{{/if}})
**File:** `{status_file}`

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

1. Review the generated `{status_file}`
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

### Never-Downgrade Rule

Status is never downgraded on refresh. If the existing file says `in-progress`, a re-detected `backlog` from the epic file does NOT override it. This ensures human-set statuses are preserved across planning runs.

### Three-Section Schema Summary

```yaml
epics:        # Map keyed by epic-N — regenerated each run with preservation
backlog:      # Array of items — additive only (new items appended, existing preserved)
sprints:      # Map keyed by sprint-N — NEVER modified by this skill
```
