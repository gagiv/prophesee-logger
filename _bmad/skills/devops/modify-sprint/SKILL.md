---
name: modify-sprint
description: Guided workflow to modify an existing sprint's metadata (name, capacity, dates, status) within the sprints section of sprint-status.yaml
---
# Modify Sprint Skill

Guided workflow to modify an existing sprint's metadata (name, capacity, dates, status) within the `sprints` section of `sprint-status.yaml`.

> **Scope:** This skill modifies sprint **metadata only** — name, capacity, start date, end date, and status.
> To assign items to a sprint, use `/add-to-sprint`. To remove items, use `/remove-from-sprint`.

<workflow>

<step n="0" goal="Load configuration and validate file existence">
  <action>Locate `sprint-status.yaml` at `_bmad-output/implementation-artifacts/sprint-status.yaml`</action>
  <check if="file does not exist">
    <output>No sprint-status.yaml found. Run sprint planning first to initialize the file.</output>
    <action>Exit workflow</action>
  </check>
  <action>Read and parse the full file, retaining all three sections: `epics`, `backlog`, and `sprints`</action>
  <action>Store file contents as {{file_content}} for use in the final atomic write</action>
</step>

<step n="1" goal="Identify available sprints and select one to modify">
  <action>Parse the `sprints` section from the loaded file</action>
  <check if="sprints section is empty ({})">
    <output>No sprints found. Run `/add-sprint` first to create a sprint.</output>
    <action>Exit workflow</action>
  </check>
  <action>Build sprint list with: sprint ID (map key), name, status, capacity, item count (length of items array), start, end</action>
  <output>
## Available Sprints

| # | Sprint ID | Name | Status | Capacity | Items | Start | End |
|---|---|---|---|---|---|---|---|
{{#each sprints}}
| {{@index+1}} | {{sprint_id}} | {{name}} | {{status}} | {{capacity}} | {{item_count}}/{{capacity}} | {{start_or_not_set}} | {{end_or_not_set}} |
{{/each}}

Note: closed sprints are immutable and cannot be modified.
  </output>
  <ask>Select sprint to modify (enter number):</ask>
  <action>Store selected sprint as {{target_sprint}} and its map key as {{sprint_id}}</action>
  <check if="{{target_sprint.status}} == 'closed'">
    <output>Sprint '{{target_sprint.name}}' ({{sprint_id}}) is closed. Closed sprints are immutable (schema constraint 6.7). Only archival operations are permitted.</output>
    <action>Exit workflow</action>
  </check>
</step>

<step n="2" goal="Display current sprint state">
  <action>Calculate {{item_count}} = length of {{target_sprint.items}} array</action>
  <action>Calculate {{remaining}} = {{target_sprint.capacity}} - {{item_count}}</action>
  <output>
## Sprint: {{target_sprint.name}} ({{sprint_id}})

- Status: {{target_sprint.status}}
- Capacity: {{target_sprint.capacity}} items ({{item_count}} assigned, {{remaining}} remaining)
- Start: {{target_sprint.start || "not set"}}
- End: {{target_sprint.end || "not set"}}
- Items: {{item_count}} assigned (use /add-to-sprint or /remove-from-sprint to manage items)

### Assigned Items (read-only)
{{#if items_empty}}
*(No items assigned yet)*
{{else}}
| ID | Title | Type | Status |
|---|---|---|---|
{{#each target_sprint.items}}
| {{id}} | {{title}} | {{type}} | {{status}} |
{{/each}}
{{/if}}
  </output>
  <action>Initialize {{working_changes}} = empty map to accumulate changes made during this session</action>
  <action>Initialize working state aliases: {{current_name}} = {{target_sprint.name}}, {{current_capacity}} = {{target_sprint.capacity}}, {{current_start}} = {{target_sprint.start}}, {{current_end}} = {{target_sprint.end}}, {{current_status}} = {{target_sprint.status}}. These aliases are updated in-place as changes are made so Step 3's menu always shows the latest values.</action>
  <action>Store {{original_name}} = {{target_sprint.name}} (preserved as the display name in the confirmation summary)</action>
</step>

<step n="3" goal="Present modification menu">
  <output>
## What would you like to modify?

1. Sprint name (current: "{{current_name}}")
2. Capacity (current: {{current_capacity}})
3. Start date (current: {{current_start || "not set"}})
4. End date (current: {{current_end || "not set"}})
5. Status (current: {{current_status}})
6. Done -- save all changes and exit
  </output>
  <ask>Choice:</ask>
  <check if="choice == 6 or choice == 'done'">
    <goto step="4" />
  </check>
</step>

<step n="3a" goal="Modify sprint name" if="choice == 1">
  <ask>New sprint name (current: '{{current_name}}'):</ask>
  <check if="input is empty">
    <output>Sprint name cannot be empty. Please enter a valid name.</output>
    <goto step="3a" />
  </check>
  <action>Store {{new_name}} = input</action>
  <action>Store change: name: {{current_name}} -> {{new_name}} in {{working_changes}}</action>
  <action>Update current display value: {{current_name}} = {{new_name}}</action>
  <output>Sprint name updated: '{{old_name}}' -> '{{new_name}}'.</output>
  <goto step="3" />
</step>

<step n="3b" goal="Modify capacity" if="choice == 2">
  <ask>New capacity (positive integer, current: {{current_capacity}}):</ask>
  <action>Validate input is a positive integer (greater than zero, no decimals, no non-numeric characters)</action>
  <check if="input is NOT a positive integer">
    <output>Invalid capacity. Must be a positive integer greater than zero.</output>
    <goto step="3b" />
  </check>
  <action>Store {{new_capacity}} = validated integer input</action>
  <action>Calculate {{item_count}} = length of {{target_sprint.items}} array</action>
  <check if="{{new_capacity}} < {{item_count}}">
    <output>Sprint has {{item_count}} items but new capacity would be {{new_capacity}} ({{new_capacity}} < {{item_count}}). Capacity is advisory -- items will not be removed.</output>
    <ask>Options:
- [a] Apply anyway (capacity is advisory per schema section 4.2)
- [s] Skip -- keep current capacity
- [r] Remove items first (direct to /remove-from-sprint)

Choice:</ask>
    <check if="choice == 's'">
      <goto step="3" />
    </check>
    <check if="choice == 'r'">
      <output>Run `/remove-from-sprint` to remove items, then re-run `/modify-sprint`.</output>
      <action>Exit workflow</action>
    </check>
    <!-- if 'a', proceed with the change -->
  </check>
  <action>Calculate {{new_remaining}} = {{new_capacity}} - {{item_count}}</action>
  <action>Store change: capacity: {{current_capacity}} -> {{new_capacity}} in {{working_changes}}</action>
  <action>Update current display value: {{current_capacity}} = {{new_capacity}}</action>
  <output>Capacity updated: {{old_capacity}} -> {{new_capacity}} ({{new_remaining}} slots remaining with {{item_count}} assigned items).</output>
  <goto step="3" />
</step>

<step n="3c" goal="Modify start date" if="choice == 3">
  <ask>New start date (ISO format YYYY-MM-DD, or press Enter to clear):</ask>
  <check if="input is empty">
    <action>Store {{new_start}} = "" (clears the date)</action>
  </check>
  <check if="input is not empty">
    <action>Validate input matches ISO date format YYYY-MM-DD (regex: ^\d{4}-\d{2}-\d{2}$) and represents a valid calendar date</action>
    <check if="invalid format">
      <output>Invalid date format. Use YYYY-MM-DD (e.g., 2026-05-01).</output>
      <goto step="3c" />
    </check>
    <action>Store {{new_start}} = input</action>
  </check>
  <action>Store change: start: {{current_start || "not set"}} -> {{new_start || "not set"}} in {{working_changes}}</action>
  <action>Update current display value: {{current_start}} = {{new_start}}</action>
  <output>Start date updated: '{{old_start || "not set"}}' -> '{{new_start || "not set"}}'.</output>
  <goto step="3" />
</step>

<step n="3d" goal="Modify end date" if="choice == 4">
  <ask>New end date (ISO format YYYY-MM-DD, or press Enter to clear):</ask>
  <check if="input is empty">
    <action>Store {{new_end}} = "" (clears the date)</action>
  </check>
  <check if="input is not empty">
    <action>Validate input matches ISO date format YYYY-MM-DD (regex: ^\d{4}-\d{2}-\d{2}$) and represents a valid calendar date</action>
    <check if="invalid format">
      <output>Invalid date format. Use YYYY-MM-DD (e.g., 2026-05-31).</output>
      <goto step="3d" />
    </check>
    <action>Store {{new_end}} = input</action>
  </check>
  <action>Determine effective start: use {{current_start}} if not changed, else use newly entered start</action>
  <check if="{{new_end}} is not empty AND {{effective_start}} is not empty AND {{new_end}} < {{effective_start}}">
    <output>Warning: End date ({{new_end}}) is before start date ({{effective_start}}). This may be intentional.</output>
  </check>
  <action>Store change: end: {{current_end || "not set"}} -> {{new_end || "not set"}} in {{working_changes}}</action>
  <action>Update current display value: {{current_end}} = {{new_end}}</action>
  <output>End date updated: '{{old_end || "not set"}}' -> '{{new_end || "not set"}}'.</output>
  <goto step="3" />
</step>

<step n="3e" goal="Modify status" if="choice == 5">
  <action>Determine valid transitions based on {{current_status}}:
    - If `planning`: valid next state is `active` only
    - If `active`: valid next state is `closed` only
    - If `closed`: no transitions available (immutable)
  </action>
  <output>
Current status: {{current_status}}
{{#if current_status == 'planning'}}Valid transitions: planning -> active{{/if}}
{{#if current_status == 'active'}}Valid transitions: active -> closed{{/if}}
{{#if current_status == 'closed'}}No transitions available. Closed sprints are immutable.{{/if}}
  </output>
  <check if="{{current_status}} == 'closed'">
    <output>Sprint '{{current_name}}' is closed. Closed sprints are immutable (schema constraint 6.7). Only archival operations are permitted.</output>
    <goto step="3" />
  </check>
  <ask>New status:</ask>
  <action>Validate transition:
    - planning -> active: allowed (proceed to single-active-sprint check)
    - active -> closed: allowed (with warning about /close-sprint)
    - planning -> closed: REJECTED (skip)
    - active -> planning: REJECTED (backward)
    - closed -> anything: REJECTED (immutable -- already handled above)
    - same state -> same state: REJECTED (no change)
    - any unrecognized value: REJECTED
  </action>
  <check if="transition is invalid (backward, skip, or unrecognized)">
    <output>Invalid status transition: {{current_status}} -> {{requested_status}}. Sprint status transitions are forward-only: planning -> active -> closed.</output>
    <goto step="3e" />
  </check>
  <check if="requested_status == 'closed'">
    <output>Warning: To properly close a sprint with item disposition (archiving done items, returning incomplete items to backlog), use `/close-sprint` instead. This will only update the status field.</output>
    <ask>Continue with status-only change? [y/n]</ask>
    <check if="answer == 'n'">
      <output>Status change cancelled. Use `/close-sprint` for full sprint close lifecycle.</output>
      <goto step="3" />
    </check>
  </check>
  <check if="requested_status == 'active'">
    <action>Scan all other sprints in the `sprints` map for any sprint with status: active</action>
    <check if="another active sprint found">
      <output>Sprint '{{other_sprint_name}}' ({{other_sprint_id}}) is already active. Only one sprint can be active at a time (schema constraint 6.4). Close it first or cancel this change.</output>
      <ask>Options:
- [c] Cancel status change
- [x] Exit to run /close-sprint on {{other_sprint_id}} first

Choice:</ask>
      <check if="choice == 'c'">
        <goto step="3" />
      </check>
      <check if="choice == 'x'">
        <output>Run `/close-sprint` on {{other_sprint_id}} first, then re-run `/modify-sprint`.</output>
        <action>Exit workflow</action>
      </check>
    </check>
  </check>
  <action>Store change: status: {{current_status}} -> {{requested_status}} in {{working_changes}}</action>
  <action>Update current display value: {{current_status}} = {{requested_status}}</action>
  <output>Status updated: {{old_status}} -> {{requested_status}}.</output>
  <goto step="3" />
</step>

<step n="4" goal="Confirmation -- review and confirm all changes">
  <check if="{{working_changes}} is empty">
    <output>No modifications made.</output>
    <action>Exit workflow</action>
  </check>
  <output>
## Modification Summary -- Please Confirm

Sprint: {{sprint_id}} ("{{original_name}}")

Changes:
{{#each working_changes}}
- {{field}}: {{old_value}} -> {{new_value}}
{{/each}}

All other sprint data (items, other sprints, epics, backlog) will be preserved unchanged.
  </output>
  <ask>Confirm changes? [y] Yes / [n] Cancel / [e] Edit more</ask>
  <check if="choice == 'n'">
    <output>Changes discarded.</output>
    <action>Exit workflow</action>
  </check>
  <check if="choice == 'e'">
    <goto step="3" />
  </check>
  <!-- if 'y', proceed to Step 5 -->
</step>

<step n="5" goal="Persist changes to sprint-status.yaml">
  <action>Re-read `_bmad-output/implementation-artifacts/sprint-status.yaml` to get the latest file state before writing</action>
  <action>Locate the target sprint entry at `sprints.{{sprint_id}}` in the re-read file</action>
  <action>Apply all confirmed changes to the target sprint entry:
    - If name was changed: update `name` field
    - If capacity was changed: update `capacity` field
    - If start was changed: update `start` field
    - If end was changed: update `end` field
    - If status was changed: update `status` field
  </action>
  <action>Preserve the sprint's `items` array exactly as-is (no modifications)</action>
  <action>Preserve all other sprint entries in the `sprints` map exactly as-is</action>
  <action>Preserve the `epics` section exactly as-is</action>
  <action>Preserve the `backlog` section exactly as-is</action>
  <action>Preserve the `generated` field exactly as-is (never change)</action>
  <action>Set `last_updated` to the current ISO-8601 timestamp</action>
  <action>Write the complete updated file in a single atomic write to `_bmad-output/implementation-artifacts/sprint-status.yaml`</action>
  <output>
Sprint modified successfully!

Sprint: {{sprint_name}} ({{sprint_id}})
{{#each working_changes}}
- {{field}}: {{new_value}}
{{/each}}

Next Steps:
- Use /add-to-sprint to assign backlog items to this sprint
- Use /remove-from-sprint to remove items from this sprint
- Use /sprint-status-view to view sprint progress
- Use /close-sprint to close this sprint when complete
  </output>
</step>

</workflow>
