---
name: cleanup-done
description: Archive done and cancelled items — remove from sprint-status.yaml and move story/bug files to done/ subfolder
---
# Cleanup Done

Archive done and cancelled items from `sprint-status.yaml` — remove them from the active file and move their story/bug `.md` files to the `done/` subfolder.

## Purpose

Keeps the active sprint view lean by archiving completed and cancelled work. Preserves story artifacts in `done/` for historical reference. Updates epic statuses when all stories for an epic have been archived.

---

<workflow>

<step n="0" goal="Load configuration and validate file existence">
  <action>Set default `story_location` = `_bmad-output/implementation-artifacts`. Check whether `{story_location}/sprint-status.yaml` exists at the default path.</action>
  <check if="file does not exist">
    <output>Error: No sprint-status.yaml found at `{story_location}/sprint-status.yaml`. Run sprint planning first to initialize the file.</output>
    <action>Exit — no changes made.</action>
  </check>
  <action>Read `{story_location}/sprint-status.yaml` and parse all sections: metadata, `epics`, `backlog`, `sprints`.</action>
  <action>If the parsed metadata contains a `story_location` field, update `story_location` to that value (allows the skill to resolve file paths correctly for non-default locations).</action>
  <action>Store parsed data as {{sprint_data}} with sub-objects: {{sprint_data.metadata}}, {{sprint_data.epics}}, {{sprint_data.backlog}}, {{sprint_data.sprints}}.</action>
</step>

<step n="1" goal="Scan all sections for archivable items">
  <action>Initialize {{archivable_items}} = [] (empty list).</action>

  <action>Scan the `backlog` array: for each item where `status` is `done` or `cancelled`, add to {{archivable_items}} with source = "backlog".</action>

  <action>Scan ALL sprints in the `sprints` map — including sprints with `status: closed` (schema section 6.7 explicitly permits cleanup-done to archive items from closed sprints):
    For each sprint key (e.g., `sprint-1`, `sprint-2`):
      For each item in sprint's `items` array:
        If item's `status` is `done` or `cancelled`:
          Add to {{archivable_items}} with source = "{sprint_key} ({sprint_name})"
  </action>

  <check if="archivable_items is empty">
    <output>No done or cancelled items found. Nothing to clean up.</output>
    <action>Exit — no changes made.</action>
  </check>
</step>

<step n="2" goal="Display archivable items and confirm">
  <action>Count done vs cancelled: {{done_count}} = items where status = "done", {{cancelled_count}} = items where status = "cancelled".</action>
  <output>
## Items to Archive

| # | ID | Title | Type | Status | Source |
|---|----|----|------|--------|--------|
{{#each archivable_items}}
| {{@index+1}} | {{id}} | {{title}} | {{type}} | {{status}} | {{source}} |
{{/each}}

**Found {{archivable_items.length}} items to archive ({{done_count}} done, {{cancelled_count}} cancelled).**
  </output>

  <ask>Options:
- [c] Confirm and archive all listed items
- [s] Select specific items (enter numbers, e.g. 1,3,5)
- [x] Cancel without changes

Choice:</ask>

  <check if="user selects 'x'">
    <output>Cancelled — no changes made.</output>
    <action>Exit.</action>
  </check>

  <check if="user selects 's'">
    <ask>Enter item numbers to archive (comma-separated):</ask>
    <action>Filter {{archivable_items}} to only the items matching the user's selection. Store as {{confirmed_items}}.</action>
  </check>

  <check if="user selects 'c'">
    <action>Set {{confirmed_items}} = {{archivable_items}} (all items).</action>
  </check>
</step>

<step n="3" goal="Archive story/bug files">
  <action>Ensure `{story_location}/done/` directory exists. Create it if it does not exist.</action>
  <action>Initialize {{files_moved}} = [], {{files_skipped_missing}} = [], {{files_skipped_exists}} = [].</action>

  <action>For each item in {{confirmed_items}}:
    1. Resolve source path: `{story_location}/{item.id}.md`
       - For bug items, also try `{story_location}/bug-{slug}.md` and `{story_location}/BUG-{slug}.md` as fallbacks if the primary path does not exist (where {slug} is derived from the id by removing any leading BUG- or bug- prefix, lowercased).
    2. Resolve destination path: `{story_location}/done/{item.id}.md`

    3. If no source file exists at any resolved path:
       - Log warning: "File not found: {resolved_path} — skipping file move."
       - Add to {{files_skipped_missing}}.
       - Continue to next item (YAML removal proceeds regardless).

    4. If destination file already exists:
       - Log warning: "File already exists at destination: {destination_path} — skipping file move."
       - Add to {{files_skipped_exists}}.
       - Continue to next item (YAML removal proceeds regardless).

    5. Move (rename) the source file to the destination path.
       Use a move/rename operation (not copy+delete) to preserve git history.
       Add {from: source_path, to: destination_path} to {{files_moved}}.
  </action>
</step>

<step n="4" goal="Remove archived items from sprint-status.yaml">
  <action>For each item in {{confirmed_items}}:
    - If item's source is "backlog": remove the item object from {{sprint_data.backlog}} array.
    - If item's source is a sprint (e.g., "sprint-1 (Sprint Name)"): extract the sprint key from the source string (the part before the space and parenthesis, e.g., "sprint-1"), then remove the item object from that sprint's `items` array in {{sprint_data.sprints}}.
  </action>

  <action>Track whether any backlog items were removed. If yes: renumber remaining backlog items' `priority` values sequentially starting at 1 to match their new array positions (priority[0] = 1, priority[1] = 2, ..., priority[N-1] = N). Store the count of remaining backlog items as {{backlog_items_renumbered}} (0 if no backlog items were removed). This keeps the `priority` field in sync with array position per schema section 3.3.</action>
</step>

<step n="5" goal="Update epic statuses">
  <action>For each epic in {{sprint_data.epics}} where epic's current `status` is `in-progress`:
    1. Determine the epic number N from the key (e.g., `epic-5` → N = 5).
    2. Check if ANY items with `epic: N` remain in:
       a. {{sprint_data.backlog}} (after removal in Step 4)
       b. Any sprint's `items` array in {{sprint_data.sprints}} (after removal in Step 4)
    3. Also verify that at least one item for this epic was archived now or previously exists in `{story_location}/done/` (to guard against marking an epic done that never had stories — epics with zero items anywhere should NOT be auto-marked done unless there are archived stories for them).
    4. If no remaining items for this epic exist in backlog or any sprint, AND at least one archived item exists for this epic: update the epic's `status` to `done`.
    5. Record which epics were transitioned to `done` in {{epics_marked_done}}.
  </action>
</step>

<step n="6" goal="Detect empty active sprints">
  <action>After item removal (Step 4), check each sprint that had items removed from its `items` array:
    - If the sprint's `items` array is now empty AND the sprint's `status` is `active`:
      - Add to {{empty_active_sprints}} list with sprint name.
  </action>
</step>

<step n="7" goal="Atomic write to sprint-status.yaml">
  <action>Update {{sprint_data.metadata.last_updated}} to the current ISO-8601 date (YYYY-MM-DD). Preserve {{sprint_data.metadata.generated}} unchanged.</action>
  <action>Write the complete updated `sprint-status.yaml` in a single write operation, incorporating:
    - All item removals from sprint `items` arrays (Step 4)
    - All item removals from `backlog` array (Step 4)
    - Backlog priority renumbering (Step 4)
    - Epic status updates (Step 5)
    - Updated `last_updated` metadata (this step)
    - All sections NOT modified pass through unchanged.
  </action>
</step>

<step n="8" goal="Display summary output">
  <output>
## Cleanup Complete

### Items Archived ({{confirmed_items.length}})

| ID | Title | Type | Status | Source |
|----|-------|------|--------|--------|
{{#each confirmed_items}}
| {{id}} | {{title}} | {{type}} | {{status}} | {{source}} |
{{/each}}

### Files Moved ({{files_moved.length}})

{{#each files_moved}}
- `{{from}}` → `{{to}}`
{{/each}}

{{#if files_skipped_missing.length > 0}}
### Warnings — Files Not Found (skipped, YAML still cleaned up)

{{#each files_skipped_missing}}
- File not found: `{{this}}` — skipping file move.
{{/each}}
{{/if}}

{{#if files_skipped_exists.length > 0}}
### Warnings — Destination Already Exists (skipped, YAML still cleaned up)

{{#each files_skipped_exists}}
- File already exists at destination: `{{this}}` — skipping file move.
{{/each}}
{{/if}}

{{#if backlog_items_renumbered > 0}}
### Backlog Renumbered

{{backlog_items_renumbered}} remaining backlog items renumbered (priorities 1..{{backlog_items_renumbered}}).
{{/if}}

{{#if epics_marked_done.length > 0}}
### Epics Marked Done

{{#each epics_marked_done}}
- **{{this}}** — all stories archived; epic status updated to `done`.
{{/each}}
{{/if}}

{{#if empty_active_sprints.length > 0}}
### Suggestion

{{#each empty_active_sprints}}
Sprint **{{this}}** has no remaining items. Consider running `/close-sprint` (Story 17.21) to close it.
{{/each}}
{{/if}}

**Next steps:** `/sprint-status-view` to review the updated sprint | `/close-sprint` if a sprint is empty | `/generate-backlog` to refresh the backlog
  </output>
</step>

</workflow>
