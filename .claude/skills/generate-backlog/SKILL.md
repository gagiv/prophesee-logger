---
name: generate-backlog
description: Generate or refresh the backlog section of sprint-status.yaml from epics and bug stories, preserving existing priorities and sprint assignments
---
# Generate Backlog

Generate or refresh the `backlog` section of `sprint-status.yaml` from epics and bug story files, while preserving existing sprint assignments and priorities.

## Purpose

This skill reads `epics.md` and `bug-*.md` files and writes the `backlog` and `epics` sections of `sprint-status.yaml`. The `sprints` section is preserved unchanged. This implements the single-source-of-truth model: all unassigned stories and bugs live in the `backlog` section of the unified file rather than a separate `backlog.yaml`.

**Output target:** `_bmad-output/implementation-artifacts/sprint-status.yaml` (`backlog` and `epics` sections only)
**Never writes:** A standalone `backlog.yaml` file.

---

<workflow>

<step n="1" goal="Load existing sprint-status.yaml state">
  <action>Check whether `_bmad-output/implementation-artifacts/sprint-status.yaml` exists</action>
  <check if="file does not exist">
    <output>ERROR: `sprint-status.yaml` not found. Run `/bmad-sprint-planning` first to bootstrap the file before using `generate-backlog`.</output>
    <action>Exit workflow</action>
  </check>
  <action>Read `_bmad-output/implementation-artifacts/sprint-status.yaml`</action>
  <action>Parse the `sprints` section (map keyed by sprint-N). For each sprint, collect all item IDs from the sprint's `items` array. Build {{sprint_item_ids}} = flat set of all item IDs across ALL sprints (across all sprint statuses: planning, active, closed).</action>
  <action>Parse the `backlog` section (array). Build {{existing_backlog_map}} = map from item ID to the full item object (to preserve priority and status during merge).</action>
  <action>Preserve the top-level metadata fields: {{generated}}, {{project}}, {{project_key}}, {{tracking_system}}, {{story_location}}</action>
  <action>Preserve the full {{sprints}} section verbatim (will be passed through unchanged on write)</action>
  <action>Preserve the existing {{epics}} section for status/retrospective merge later</action>
</step>

<step n="2" goal="Build done-items exclusion set from done/ archive">
  <action>Glob `_bmad-output/implementation-artifacts/done/*.md` to discover archived story files</action>
  <action>For each file found, derive the item ID from the filename (strip `.md` extension, use basename)</action>
  <action>Build {{done_item_ids}} = set of all archived item IDs</action>
  <check if="no done/ files found">
    <action>Set {{done_item_ids}} = empty set</action>
  </check>
</step>

<step n="3" goal="Extract stories from epics.md">
  <action>Read `_bmad-output/planning-artifacts/epics.md`</action>
  <check if="file does not exist">
    <output>WARNING: `epics.md` not found at `_bmad-output/planning-artifacts/epics.md`. No stories will be extracted from epics. Continuing with bug-only backlog.</output>
    <action>Set {{epic_stories}} = [] and {{parsed_epics}} = []</action>
  </check>
  <action>Parse epics.md to extract:
    - Each epic: epic number (N from "Epic N" header), epic title, epic status (if present in the file)
    - Each story under each epic: story number (M from "Story N.M" format), story title
  </action>
  <action>For each story, generate the kebab-case item ID: `{epic_number}-{story_number}-{title-slug}` where title-slug is the title lowercased, spaces replaced with hyphens, non-alphanumeric characters (except hyphens) removed, consecutive hyphens collapsed</action>
  <action>Exclude stories whose derived ID is in {{sprint_item_ids}} (already assigned to a sprint)</action>
  <action>Exclude stories whose derived ID is in {{done_item_ids}} (archived)</action>
  <action>Store remaining stories as {{epic_stories}} — list of objects with: id, epic (integer), title, type="story", severity=null</action>
  <action>Store parsed epics as {{parsed_epics}} — list of objects with: epic_id (e.g., "epic-5"), epic_number (integer), title</action>
</step>

<step n="4" goal="Extract bugs from bug-*.md files">
  <action>Glob `_bmad-output/implementation-artifacts/bug-*.md` to discover all bug story files</action>
  <check if="no bug files found">
    <action>Set {{bug_stories}} = []</action>
  </check>
  <action>For each bug file found:
    - Parse YAML frontmatter to extract: `id` (or derive from filename: `BUG-{basename-without-bug-prefix-and-extension}`), `title`, `severity` (critical/high/medium/low), `status`
    - If `id` is not in frontmatter, derive from filename: strip `bug-` prefix and `.md` extension, prefix with `BUG-`
    - If `status` is not in frontmatter, default to `backlog`
    - Exclude bugs whose ID is in {{sprint_item_ids}} or {{done_item_ids}}
    - Create bug item: {id, type="bug", epic=null, title, severity, status}
  </action>
  <action>Store as {{bug_stories}}</action>
</step>

<step n="5" goal="Merge with existing backlog — preserve priorities, detect orphans">
  <action>Build {{all_source_ids}} = set of all IDs from {{epic_stories}} + {{bug_stories}}</action>

  <action>**Orphan detection:** For each item in {{existing_backlog_map}} whose ID is NOT in {{all_source_ids}} AND NOT in {{sprint_item_ids}} AND NOT in {{done_item_ids}}:
    - Flag the item as orphaned
    - Collect orphaned items in {{orphaned_items}} list
    - Keep the orphaned item in the backlog (do NOT auto-remove — human review required)
  </action>

  <action>**New item detection:** For each item in {{epic_stories}} and {{bug_stories}} whose ID is NOT in {{existing_backlog_map}}:
    - Assign status = "backlog"
    - Mark as new in {{new_items}} list
  </action>

  <action>**Existing item preservation:** For each item in {{epic_stories}} and {{bug_stories}} whose ID IS in {{existing_backlog_map}}:
    - Preserve the existing item's `priority` and `status` values from {{existing_backlog_map}}
    - Update title from the source file (in case it was renamed)
  </action>

  <action>Assemble {{merged_items}} = all items from {{epic_stories}} (with preserved or new priority/status) + all items from {{bug_stories}} (with preserved or new priority/status) + all items from {{orphaned_items}} (with existing priority/status preserved)</action>

  <action>**Backlog-sprint conflict detection:** Set {{backlog_sprint_conflicts}} = list of items that were in {{existing_backlog_map}} AND in {{sprint_item_ids}} (items found in both the backlog and a sprint — data integrity violation corrected by removing them from the backlog; sprint assignment takes precedence)</action>
</step>

<step n="6" goal="Sort and renumber backlog items by priority">
  <action>Sort {{merged_items}} by the following criteria (most important first):
    1. **Critical bugs first:** Items with type="bug" AND severity="critical" rank highest
       - Among critical bugs: existing items ordered by their current priority (ascending); new critical bugs ordered by their position in the discovered bug file list (alphabetical by filename)
    2. **Explicit priority (preserved from existing backlog):** Items that existed in the previous backlog are ranked by their preserved priority value (lower number = higher rank)
    3. **New items by epic order:** New items (not in existing backlog) are ranked by their epic number (ascending), then by story number within the epic (ascending)
    4. **Bugs without explicit priority:** New bugs (not in existing backlog) are appended after all stories, sorted by severity (high → medium → low → null)
    5. **Orphaned items:** Orphaned items are appended last, maintaining their relative order
  </action>
  <action>Re-number priorities sequentially: assign priority = 1 to the first item, priority = 2 to the second, etc. (position 0 in array = priority 1)</action>
  <action>Store as {{sorted_backlog}}</action>
</step>

<step n="7" goal="Build refreshed epics section">
  <action>For each epic in {{parsed_epics}}:
    - Look up the epic in the existing {{epics}} section by key (e.g., "epic-5")
    - If the epic already exists: preserve its `status` and `retrospective` values. Do NOT downgrade status (e.g., if existing status is "in-progress" and the source implies "backlog", keep "in-progress").
    - If the epic is new (not in existing epics): set status = "backlog", retrospective = "optional"
  </action>
  <action>Build {{refreshed_epics}} = map of all epics from the existing file PLUS any newly discovered epics. Existing epics not present in parsed_epics are preserved unchanged (do not remove epics that are no longer in the source, as they may be in-progress or done).</action>
</step>

<step n="8" goal="Write sprint-status.yaml atomically">
  <action>Assemble the complete file content:
    1. Preserve top-level metadata: `generated`, `project`, `project_key`, `tracking_system`, `story_location` (unchanged)
    2. Set `last_updated` = current ISO-8601 datetime string (e.g., "2026-04-06T10:00:00Z")
    3. Write `epics` section from {{refreshed_epics}}
    4. Write `backlog` section from {{sorted_backlog}} (array, ordered by priority)
    5. Write `sprints` section from the preserved {{sprints}} section (verbatim, NO changes)
  </action>
  <action>Validate before writing:
    - Every backlog item has all 7 required fields: id, type, epic, title, priority, status, severity
    - priority values are sequential starting from 1 and match array position
    - No item ID appears in both backlog and any sprint's items array
    - Every epic has both status and retrospective fields
  </action>
  <action>Write the assembled content to `_bmad-output/implementation-artifacts/sprint-status.yaml` as a single atomic write (read-modify-write pattern)</action>
</step>

<step n="9" goal="Report summary">
  <output>
## Generate Backlog — Complete

**Backlog section refreshed in `sprint-status.yaml`**

| Metric | Count |
|--------|-------|
| Total stories from epics.md | {{epic_story_count}} |
| Total bugs from bug-*.md | {{bug_count}} |
| New items added to backlog | {{new_items_count}} |
| Existing items preserved | {{preserved_count}} |
| Items excluded (sprint-assigned) | {{sprint_excluded_count}} |
| Items excluded (archived in done/) | {{done_excluded_count}} |
| Items corrected (removed from backlog — already in sprint) | {{backlog_sprint_conflicts.length}} |
| Total backlog items | {{total_backlog_count}} |

{{#if backlog_sprint_conflicts}}
⚠️ **Data integrity corrections:**
The following items were found in both the backlog and a sprint. They have been removed from the backlog (sprint assignment takes precedence):
{{#each backlog_sprint_conflicts}}
- {{id}} — {{title}}
{{/each}}

{{/if}}
{{#if orphaned_items}}
### Orphaned Items (WARNING — Human Review Required)

The following items exist in the backlog but were NOT found in `epics.md` or any `bug-*.md` file. They have been kept in the backlog but should be reviewed:

{{#each orphaned_items}}
- `{{id}}` — {{title}} (priority: {{priority}}, status: {{status}})
{{/each}}

These items may represent: renamed stories, deleted epics, or manually added items. Remove them manually if they are no longer needed.
{{/if}}

**Next steps:**
- Use `/prioritize-backlog` to reorder items
- Use `/add-to-sprint` to assign items to a sprint
- Use `/bmad-sprint-planning` to plan a full sprint
  </output>
</step>

</workflow>
