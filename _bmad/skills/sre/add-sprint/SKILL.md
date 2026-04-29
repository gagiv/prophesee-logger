---
name: add-sprint
description: Guided workflow to create a new sprint entry in the sprints section of sprint-status.yaml with capacity limits, optional ISO dates, and auto-incremented ID
---
# Add Sprint

Guided workflow to create a new sprint entry in the `sprints` section of `sprint-status.yaml` with capacity limits, optional ISO dates, and auto-incremented sprint ID.

<workflow>

<step n="0" goal="Load configuration and validate file existence">
  <action>Locate `sprint-status.yaml` at `_bmad-output/implementation-artifacts/sprint-status.yaml` relative to the project root</action>
  <check if="sprint-status.yaml does not exist">
    <output>No sprint-status.yaml found. Run sprint planning first to initialize the file.</output>
    <action>Exit workflow</action>
  </check>
  <action>Read and parse the full file: `epics`, `backlog`, and `sprints` sections plus all metadata fields</action>
  <action>Store parsed content as {{file_content}}</action>
</step>

<step n="1" goal="Auto-increment sprint ID and derive default name">
  <action>Extract all keys from the `sprints` map in {{file_content}}</action>
  <action>Parse numeric suffix from each key matching pattern `sprint-N` (e.g., `sprint-1` → 1, `sprint-3` → 3)</action>
  <check if="no sprint keys exist in sprints map">
    <action>Set {{new_number}} = 1</action>
    <action>Set {{default_name}} = "Sprint 1"</action>
  </check>
  <check if="sprint keys exist">
    <action>Find the highest numeric suffix among all sprint keys; store as {{max_number}}</action>
    <action>Set {{new_number}} = {{max_number}} + 1</action>
    <action>Look up the sprint entry whose key has suffix {{max_number}}; read its `name` field</action>
    <action>If the name matches pattern "Sprint N" or "Sprint N — description" or "Sprint N - description", set {{default_name}} = "Sprint {{new_number}}"; otherwise set {{default_name}} = "Sprint {{new_number}}" as safe fallback</action>
  </check>
  <action>Set {{sprint_id}} = "sprint-{{new_number}}"</action>
  <action>Set {{sprint_name}} = {{default_name}}</action>
  <output>
Auto-generated Sprint ID: **{{sprint_id}}**
Default Sprint Name: **{{sprint_name}}**
  </output>
  <ask>Sprint ID: {{sprint_id}} — press Enter to accept or type a different number:</ask>
  <check if="user provides a different number">
    <action>Set {{sprint_id}} = "sprint-{user_number}"</action>
    <action>Check if {{sprint_id}} already exists as a key in the `sprints` map</action>
    <check if="sprint_id already exists">
      <output>Sprint ID {{sprint_id}} already exists in sprint-status.yaml. Please choose a different number.</output>
      <goto step="1" sub="re-prompt for number only" />
    </check>
    <action>Update {{sprint_name}} default to "Sprint {user_number}"</action>
  </check>
  <ask>Sprint name: '{{sprint_name}}' — press Enter to accept or type a different name:</ask>
  <check if="user provides a different name">
    <action>Set {{sprint_name}} = user input</action>
  </check>
</step>

<step n="2" goal="Gather capacity (required)">
  <action>Explain: capacity is the maximum number of items (stories + bugs) that can be assigned to this sprint. This is advisory — skills will warn but not block when exceeded.</action>
  <ask>What is the sprint capacity? (Enter a positive integer)</ask>
  <action>Store input as {{capacity_input}}</action>
  <action>Validate {{capacity_input}} is a positive integer (greater than zero, no decimals, no non-numeric characters)</action>
  <check if="{{capacity_input}} is NOT a positive integer">
    <output>Invalid capacity: "{{capacity_input}}". Capacity must be a positive integer (e.g., 5, 10, 20). Zero and negative values are not allowed.</output>
    <goto step="2" />
  </check>
  <action>Store as {{capacity}} (integer)</action>
</step>

<step n="3" goal="Gather optional start and end dates">
  <ask>Optional — Sprint start date (ISO format YYYY-MM-DD, press Enter to skip):</ask>
  <action>Store as {{start_input}}</action>
  <check if="start_input is not empty">
    <action>Validate {{start_input}} matches ISO date pattern YYYY-MM-DD (4-digit year, 2-digit month 01-12, 2-digit day 01-31)</action>
    <check if="start_input does not match ISO date pattern">
      <output>Invalid date format: "{{start_input}}". Please use YYYY-MM-DD (e.g., 2026-04-15).</output>
      <goto step="3" sub="re-prompt for start date only" />
    </check>
    <action>Store as {{start}} = {{start_input}}</action>
  </check>
  <check if="start_input is empty">
    <action>Store as {{start}} = "" (empty string)</action>
  </check>
  <ask>Optional — Sprint end date (ISO format YYYY-MM-DD, press Enter to skip):</ask>
  <action>Store as {{end_input}}</action>
  <check if="end_input is not empty">
    <action>Validate {{end_input}} matches ISO date pattern YYYY-MM-DD</action>
    <check if="end_input does not match ISO date pattern">
      <output>Invalid date format: "{{end_input}}". Please use YYYY-MM-DD (e.g., 2026-04-28).</output>
      <goto step="3" sub="re-prompt for end date only" />
    </check>
    <check if="end_input is before start and start is not empty">
      <output>Warning: end date {{end_input}} is before start date {{start}}. Continuing as requested.</output>
    </check>
    <action>Store as {{end}} = {{end_input}}</action>
  </check>
  <check if="end_input is empty">
    <action>Store as {{end}} = "" (empty string)</action>
  </check>
</step>

<step n="4" goal="Confirmation">
  <output>
## New Sprint Summary — Please Confirm

- Sprint ID: {{sprint_id}}
- Sprint Name: {{sprint_name}}
- Capacity: {{capacity}} items
- Start Date: {{start}} *(empty if skipped)*
- End Date: {{end}} *(empty if skipped)*
- Status: planning
- Items: [] *(empty — use /add-to-sprint to assign items)*
- Target: sprint-status.yaml sprints section
  </output>
  <ask>Confirm creation? [y] Yes / [n] Cancel / [e] Edit a field</ask>
  <check if="user selects 'e'">
    <ask>Which field to edit? (id / name / capacity / start / end)</ask>
    <check if="field == 'id'"><goto step="1" /></check>
    <check if="field == 'name'">
      <ask>Sprint name (or press Enter to use "{{sprint_name}}"):</ask>
      <check if="input is not empty"><action>Set {{sprint_name}} = user input</action></check>
      <goto step="4" />
    </check>
    <check if="field == 'capacity'"><goto step="2" /></check>
    <check if="field == 'start'"><goto step="3" sub="start date only" /></check>
    <check if="field == 'end'"><goto step="3" sub="end date only" /></check>
  </check>
  <check if="user selects 'n'">
    <output>Sprint creation cancelled.</output>
    <action>Exit workflow</action>
  </check>
</step>

<step n="5" goal="Write sprint entry to sprint-status.yaml">
  <action>Re-read the current content of `_bmad-output/implementation-artifacts/sprint-status.yaml` to get the latest state</action>
  <action>Get the current ISO-8601 timestamp for `last_updated`</action>
  <action>Append a new entry to the `sprints` map with this structure:
```yaml
  {{sprint_id}}:
    name: "{{sprint_name}}"
    status: planning
    capacity: {{capacity}}
    start: "{{start}}"
    end: "{{end}}"
    items: []
```
  </action>
  <action>Preserve the `epics` section unchanged</action>
  <action>Preserve the `backlog` section unchanged</action>
  <action>Preserve all existing entries in the `sprints` section unchanged</action>
  <action>Update the `last_updated` metadata field to the current ISO-8601 timestamp</action>
  <action>Preserve the `generated` field unchanged (never modify)</action>
  <action>Write the complete updated file to `_bmad-output/implementation-artifacts/sprint-status.yaml` in a single atomic write (read-modify-write pattern)</action>
</step>

<step n="6" goal="Summary output">
  <output>
Sprint created successfully!

- Sprint: {{sprint_name}} ({{sprint_id}})
- Capacity: {{capacity}} items
- Status: planning

Next Steps:
- Use /add-to-sprint to assign backlog items to this sprint
- Use /modify-sprint to update sprint details later
- Use /sprint-status-view to view sprint progress
  </output>
</step>

</workflow>
