---
name: prioritize-backlog
description: Reprioritize backlog items using multiple criteria -- severity, business value, dependencies, type, age
---
# Prioritize Backlog

Reprioritize backlog items in `sprint-status.yaml` using multiple criteria: severity, business value, dependencies, type, and age.

<workflow>

<step n="0" goal="Load configuration and validate file existence">
  <action>Read `_bmad-output/implementation-artifacts/sprint-status.yaml` — the single source of truth for all sprint and backlog state.</action>
  <check if="sprint-status.yaml does not exist">
    <output>No sprint-status.yaml found. Run sprint planning first to initialize the file.</output>
    <action>Exit workflow — do not create any file.</action>
  </check>
  <action>Parse the full file: read `epics`, `backlog`, and `sprints` sections plus all metadata fields (`generated`, `last_updated`, `project`, `project_key`, `tracking_system`, `story_location`). Store the entire parsed structure as {{file_data}} for later atomic write.</action>
  <check if="legacy backlog.yaml exists in _bmad-output/implementation-artifacts/">
    <output>Note: Legacy backlog.yaml detected. Run migration to consolidate.</output>
    <action>Continue — do NOT read from or write to the legacy file. Operate on sprint-status.yaml only.</action>
  </check>
  <check if="{{file_data.backlog}} is empty or null">
    <output>Backlog is empty. Nothing to prioritize.</output>
    <action>Exit workflow — do not modify the file.</action>
  </check>
  <action>Store {{backlog_items}} = {{file_data.backlog}} (the array of items to work with).</action>
  <action>Store {{original_order}} = copy of {{backlog_items}} with their current priority values, for use in the change summary later.</action>
</step>

<step n="1" goal="Display current backlog order">
  <action>Read {{backlog_items}} in their current array order (position 0 = highest priority).</action>
  <output>
## Current Backlog ({{backlog_items.length}} items)

| Priority | ID | Title | Type | Epic | Severity | Status |
|---|---|---|---|---|---|---|
{{#each backlog_items}}
| {{priority}} | {{id}} | {{title}} | {{type}} | {{#if epic}}epic-{{epic}}{{else}}—{{/if}} | {{severity or "—"}} | {{status}} |
{{/each}}

*Note: Items assigned to sprints are not shown — only unassigned backlog items are listed here.*
  </output>
</step>

<step n="2" goal="Choose prioritization mode">
  <ask>Select a prioritization mode:

**[f] Full** — Interactive: generates a suggested order, presents current vs proposed side-by-side. You review and approve (or adjust) before any write occurs.
**[q] Quick** — Automated: applies default multi-criteria rules immediately, then shows a summary of what moved.
**[a] Auto-suggest** — Read-only: shows the suggested order with per-item rationale. No file is modified.
**[x] Cancel** — Exit without changes.

Choice:</ask>
  <check if="user selects 'x'">
    <output>Cancelled — no changes made.</output>
    <action>Exit workflow.</action>
  </check>
  <action>Store {{selected_mode}} = user choice.</action>
</step>

<step n="3" goal="Multi-criteria prioritization analysis">
  <action>For each item in {{backlog_items}}, compute a composite priority score using the following weighted criteria (highest weight listed first):</action>

  <action>**1. Severity weight (highest impact):**
  - `severity: critical` → +40 points
  - `severity: high`     → +30 points
  - `severity: medium`   → +10 points
  - `severity: low`      → +5 points
  - `severity: null`     → +0 points (no adjustment for stories)
  </action>

  <action>**2. Business value weight:**
  - Use the item's existing `priority` value as a signal for current business value ranking. Items with lower `priority` values (higher priority) receive a proportional boost: score += max(0, ({{backlog_items.length}} - current_priority + 1) * 2). This preserves existing prioritization signals while allowing other criteria to override.
  - Items from lower-numbered epics (or `epic: null`) receive a slight additional boost: score += max(0, (20 - epic_number)) * 1, treating null as epic 0.
  </action>

  <action>**3. Dependency weight:**
  - Read `_bmad-output/planning-artifacts/epics.md` if it exists to identify explicit inter-story dependencies.
  - Within the same epic, items with lower story numbers are assumed to be prerequisites for higher-numbered stories. Items that block others get a +15 point boost.
  - Items that are explicitly blocked by other UNASSIGNED backlog items get a -10 point adjustment (they cannot proceed anyway).
  - If epics.md cannot be read or does not define explicit dependencies, use only the intra-epic ordering heuristic.
  </action>

  <action>**4. Type weight (tiebreaker):**
  - `type: bug` → +3 points (bugs receive a slight boost over stories at equal composite score)
  - `type: story` → +0 points
  </action>

  <action>**5. Age weight (starvation prevention — weakest signal):**
  - Items from epics with lower epic numbers receive +1 point per 5 epic numbers below the maximum epic in the backlog (e.g., if max epic is 17, epic-12 gets +1, epic-7 gets +2).
  - Items with `epic: null` are treated as oldest (receive the maximum age boost among all items).
  - This is a tiebreaker only — it prevents starvation but does not override higher-priority signals.
  </action>

  <action>Compute {{composite_score}} for each item = severity_score + business_value_score + dependency_score + type_score + age_score.</action>
  <action>Sort items by {{composite_score}} descending (highest score = priority 1). Break ties by current `priority` value (lower = higher priority stays higher).</action>
  <action>Store {{suggested_order}} = sorted list of items. Store {{rationale_map}} = per-item map of score breakdown and reason summary.</action>
</step>

<step n="3a" goal="Full mode: present comparison and get approval" condition="{{selected_mode}} == 'f'">
  <output>
## Prioritization Analysis: Current vs Suggested

| Current Priority | ID | Suggested Priority | Change | Key Rationale |
|---|---|---|---|---|
{{#each original_order}}
| {{priority}} | {{id}} | {{suggested_position}} | {{change_indicator}} | {{rationale}} |
{{/each}}

*Items highlighted with ↑ move up, ↓ move down, = stay in place.*
  </output>
  <ask>Options:
- **[a]** Accept the suggested order as-is
- **[m]** Manually adjust — enter item IDs in your preferred order (comma-separated)
- **[c]** Cancel — exit without changes

Choice:</ask>
  <check if="user selects 'c'">
    <output>Cancelled — no changes made.</output>
    <action>Exit workflow.</action>
  </check>
  <check if="user selects 'a'">
    <action>Set {{final_order}} = {{suggested_order}}.</action>
  </check>
  <check if="user selects 'm'">
    <ask>Enter item IDs in your preferred priority order (highest priority first), comma-separated. You MUST include all {{backlog_items.length}} items — no duplicates or omissions allowed:
Example: 17-10-rework-generate-backlog, 17-11-rework-add-to-sprint, ...</ask>
    <action>Parse the user-provided list into {{manual_order_ids}}.</action>
    <action>Validate:
    - Count must equal {{backlog_items.length}} (no missing items)
    - All IDs must exist in {{backlog_items}} (no unknown IDs)
    - No duplicate IDs
    </action>
    <check if="validation fails">
      <output>Invalid input: {{validation_error}}. Please re-enter the complete list of all {{backlog_items.length}} item IDs in your preferred order.</output>
      <action>Repeat the manual-entry prompt until valid input is received or user cancels.</action>
    </check>
    <action>Reorder {{backlog_items}} to match {{manual_order_ids}} sequence. Set {{final_order}} = reordered list.</action>
  </check>
  <action>Proceed to Step 4 with {{final_order}}.</action>
</step>

<step n="3b" goal="Quick mode: apply suggested order automatically" condition="{{selected_mode}} == 'q'">
  <action>Set {{final_order}} = {{suggested_order}}.</action>
  <action>Proceed to Step 4 with {{final_order}}.</action>
</step>

<step n="3c" goal="Auto-suggest mode: display suggestions without writing" condition="{{selected_mode}} == 'a'">
  <output>
## Suggested Backlog Order (Read-Only — No Changes Written)

| New Priority | ID | Title | Old Priority | Change | Rationale |
|---|---|---|---|---|---|
{{#each suggested_order}}
| {{new_priority}} | {{id}} | {{title}} | {{old_priority}} | {{change_indicator}} | {{rationale}} |
{{/each}}

**Summary:**
- Items that would move up: {{move_up_count}}
- Items that would move down: {{move_down_count}}
- Items unchanged: {{unchanged_count}}

Suggestions displayed. No changes written. Run again in Full or Quick mode to apply.
  </output>
  <action>Exit workflow — do NOT proceed to Step 4.</action>
</step>

<step n="4" goal="Apply reordering and persist">
  <action>Take {{final_order}} (from Full or Quick mode).</action>
  <action>Renumber `priority` field on each item sequentially: position 0 in the array gets `priority: 1`, position 1 gets `priority: 2`, and so on through position N-1 gets `priority: N`. This keeps the denormalized index in sync with array position (schema section 3.3).</action>
  <action>Get the current ISO-8601 timestamp (format: YYYY-MM-DDTHH:MM:SS). Update {{file_data.last_updated}} to this timestamp.</action>
  <action>Preserve {{file_data.generated}} unchanged.</action>
  <action>Preserve {{file_data.epics}} section unchanged — do NOT modify any epic entries.</action>
  <action>Preserve {{file_data.sprints}} section unchanged — do NOT modify any sprint entries or items within sprints.</action>
  <action>Set {{file_data.backlog}} = {{final_order}} (the reordered array with renumbered priorities).</action>
  <action>Write the complete updated {{file_data}} back to `_bmad-output/implementation-artifacts/sprint-status.yaml` in a single atomic write (read-modify-write pattern). This single write replaces the file entirely — no partial updates.</action>
</step>

<step n="5" goal="Display summary output">
  <action>Compute change summary by comparing {{original_order}} (old positions) against {{final_order}} (new positions).</action>
  <output>
## Reprioritization Complete

**Mode:** {{mode_label}} ({{current_datetime}})
**Items reordered:** {{backlog_items.length}} total

### Changes Made

| ID | Title | Old Priority | New Priority | Direction |
|---|---|---|---|---|
{{#each changed_items}}
| {{id}} | {{title}} | {{old_priority}} | {{new_priority}} | {{direction}} |
{{/each}}

{{#if unchanged_items.length > 0}}
**Unchanged ({{unchanged_items.length}} items):** {{unchanged_ids_list}}
{{/if}}

**sprint-status.yaml updated successfully.**

**Next steps:**
- `/add-to-sprint` — Assign the top-priority backlog items to the current sprint
- `/sprint-status-view` — View overall sprint progress and capacity
  </output>
</step>

</workflow>
