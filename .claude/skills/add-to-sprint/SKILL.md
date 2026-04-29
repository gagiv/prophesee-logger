---
name: add-to-sprint
description: Guided workflow to move backlog items to a sprint in the unified sprint-status.yaml using movement semantics
---
# Add-to-Sprint Skill

Guided workflow to move backlog items to a sprint in the unified `sprint-status.yaml` using movement semantics.

**Movement semantics:** Each item exists in exactly one location — either the `backlog` array OR a sprint's `items` array, never both. This skill atomically removes items from `backlog` and appends them to the target sprint's `items` array in a single file write.

<workflow>

<step n="0" goal="Load configuration and validate file existence">
  <action>Locate `sprint-status.yaml` at `_bmad-output/implementation-artifacts/sprint-status.yaml`</action>
  <check if="file does not exist">
    <output>❌ No sprint-status.yaml found. Run sprint planning first to initialize the file (e.g., `/bmad-sprint-planning`).</output>
    <action>Exit workflow</action>
  </check>
  <action>Read and parse the full file: `epics`, `backlog`, and `sprints` sections plus metadata fields</action>
  <action>Store the complete parsed document as {{sprint_status}} for atomic write-back later</action>
</step>

<step n="1" goal="Identify assignable sprints">
  <action>Parse the `sprints` map from {{sprint_status}}</action>
  <action>Filter to sprints with `status: planning` or `status: active` — exclude `status: closed` sprints</action>
  <check if="no assignable sprints remain (all sprints are closed or sprints map is empty)">
    <output>❌ No assignable sprints found. Run `/add-sprint` first to create a sprint before assigning items.</output>
    <action>Exit workflow</action>
  </check>
  <check if="exactly one assignable sprint">
    <action>Auto-select it as {{target_sprint}} (skip selection prompt)</action>
    <output>ℹ️ Auto-selected the only assignable sprint: **{{target_sprint.name}}** ({{target_sprint.status}})</output>
  </check>
  <check if="multiple assignable sprints">
    <action>Build a sprint selection table from the assignable sprints</action>
    <output>
## Available Sprints

| # | Sprint | Status | Capacity | Assigned | Remaining |
|---|--------|--------|----------|----------|-----------|
{{#each assignable_sprints}}
| {{@index+1}} | {{name}} | {{status}} | {{capacity}} | {{items.length}} | {{capacity - items.length}} |
{{/each}}
    </output>
    <ask>Select target sprint (enter number):</ask>
    <action>Resolve entered number to the corresponding sprint entry and store as {{target_sprint}} (the sprint's map key and full sprint object)</action>
  </check>
</step>

<step n="2" goal="Display backlog items eligible for sprint assignment">
  <action>Read the `backlog` array from {{sprint_status}}</action>
  <action>Filter to items with `status: ready-for-dev` ONLY — schema section 4.5 movement rules require this status for sprint assignment</action>
  <check if="no ready-for-dev items exist in the backlog">
    <output>❌ No items eligible for sprint assignment. Items must have `status: ready-for-dev` to be added to a sprint. Items with `status: backlog` must first have a story file created (which advances them to `ready-for-dev`).</output>
    <action>Exit workflow</action>
  </check>
  <action>Display eligible backlog items in priority order (array order = priority order, position 0 = highest priority)</action>
  <output>
## Backlog Items (eligible for sprint assignment)

| # | ID | Title | Type | Epic | Severity |
|---|-----|-------|------|------|----------|
{{#each eligible_backlog_items}}
| {{@index+1}} | {{id}} | {{title}} | {{type}} | {{epic}} | {{severity}} |
{{/each}}

*Total eligible: {{eligible_count}} items (status: ready-for-dev)*
  </output>
</step>

<step n="3" goal="Display sprint capacity">
  <action>Calculate capacity usage: current assigned count = `{{target_sprint.items.length}}`</action>
  <action>Calculate remaining = `{{target_sprint.capacity}} - {{target_sprint.items.length}}`</action>
  <output>
## Sprint Capacity: {{target_sprint.name}}

- **Capacity:** {{target_sprint.capacity}} items
- **Assigned:** {{target_sprint.items.length}} items
- **Remaining:** {{remaining_capacity}} slots

{{#if remaining_capacity <= 0}}
⚠️ This sprint is **at or over capacity**. Adding items will exceed the limit.
{{/if}}
  </output>
</step>

<step n="4" goal="Select candidate items for this sprint">
  <ask>Which backlog items do you want to consider for this sprint? Enter item numbers (comma-separated), or "all" to evaluate the full eligible backlog:</ask>
  <check if="user enters 'all'">
    <action>Set {{candidate_items}} = all items from the eligible backlog list displayed in step 2</action>
  </check>
  <check if="user enters item numbers">
    <action>Resolve the entered numbers against the eligible backlog table from step 2</action>
    <action>Validate all entered numbers correspond to displayed items — report error for any invalid numbers</action>
    <action>Set {{candidate_items}} = those specific items</action>
  </check>
</step>

<step n="5" goal="Multi-criteria prioritization analysis">
  <action>For each item in {{candidate_items}}, evaluate and score across criteria:
    - **Business value:** High (H) / Medium (M) / Low (L) — impact on users or project goals
    - **Dependency status:** Blocked (blocked by another item) / Blocking (blocks other items) / Independent
    - **Severity** (bugs only): Critical / High / Medium / Low — N/A for stories
    - **Effort estimation:** Small (S ≤ 1 day) / Medium (M 2–3 days) / Large (L 4+ days)
  </action>
  <action>Generate a ranked ordering recommendation, factoring in:
    1. Blocking dependencies first (items that unlock others)
    2. High business value + low/medium effort (quick wins)
    3. Critical/High bugs ahead of Medium/Low bugs
    4. Avoid blocked items unless capacity allows waiting
  </action>
  <output>
## Prioritization Analysis

| Rank | ID | Title | Type | Business Value | Dependencies | Severity | Effort | Rationale |
|------|----|-------|------|----------------|--------------|----------|--------|-----------|
{{#each ranked_items}}
| {{rank}} | {{id}} | {{title}} | {{type}} | {{business_value}} | {{dependency_status}} | {{severity}} | {{effort}} | {{rationale}} |
{{/each}}

**Recommended selection** (up to {{remaining_capacity}} items to stay within capacity): {{recommended_selection}}
  </output>
</step>

<step n="6" goal="User confirms or adjusts selection">
  <ask>Review the ranking above. Options:
- [c] Confirm recommended selection as-is
- [m] Modify selection (specify item numbers to include)
- [r] Re-rank items (provide new priority order)
- [x] Cancel without assigning

Choice:</ask>
  <check if="user selects 'x'">
    <output>❌ Assignment cancelled — no changes made.</output>
    <action>Exit workflow</action>
  </check>
  <check if="user selects 'm'">
    <ask>Enter item numbers to assign (comma-separated):</ask>
    <action>Resolve entered numbers against the eligible backlog table from step 2</action>
    <action>Set {{confirmed_items}} = those specific items</action>
  </check>
  <check if="user selects 'r'">
    <ask>Enter item numbers in your preferred priority order (comma-separated). Only items you include will be assigned — items not listed will be excluded from this session and remain in the backlog:</ask>
    <action>Set {{confirmed_items}} = items matching the user-provided numbers, in the order provided. Items from {{candidate_items}} NOT mentioned are excluded from this session (they remain in the backlog for future sprints).</action>
  </check>
  <check if="user selects 'c'">
    <action>Set {{confirmed_items}} = recommended selection from step 5</action>
  </check>
  <action>Store confirmed ranking in {{confirmed_ranking}} for the audit record</action>
</step>

<step n="7" goal="Execute movement with capacity enforcement">
  <action>Initialize {{current_sprint_count}} = {{target_sprint.items.length}} (current assigned count before any additions this session)</action>
  <action>Initialize {{items_to_move}} = [] (items confirmed for movement)</action>
  <action>For each item in {{confirmed_items}}, in confirmed ranking order:</action>
  <check if="adding this item would exceed sprint capacity (current_sprint_count + 1 > target_sprint.capacity)">
    <output>⚠️ **Capacity Warning:** Adding "{{item.title}}" would bring assigned items to {{current_sprint_count + 1}}/{{target_sprint.capacity}} — exceeding sprint capacity by {{current_sprint_count + 1 - target_sprint.capacity}}.</output>
    <ask>Options:
- [a] Add anyway (over-capacity acknowledged)
- [s] Skip this item (leave in backlog)
- [m] Exit to run `/modify-sprint` to increase capacity first

Choice:</ask>
    <check if="user selects 's'">
      <action>Skip this item — do NOT add to {{items_to_move}}. Continue to next item.</action>
    </check>
    <check if="user selects 'm'">
      <output>💡 Run `/modify-sprint` to increase capacity for **{{target_sprint.name}}**, then re-run `/add-to-sprint`.</output>
      <action>Exit workflow without making any changes</action>
    </check>
    <check if="user selects 'a'">
      <action>Add to {{items_to_move}} and increment {{current_sprint_count}}</action>
    </check>
  </check>
  <check if="item is within capacity">
    <action>Add to {{items_to_move}} and increment {{current_sprint_count}}</action>
  </check>
</step>

<step n="8" goal="Atomic write — persist all movements to sprint-status.yaml">
  <action>If {{items_to_move}} is empty (all items were skipped or cancelled), exit without writing.</action>

  <action>**Pre-write: single-location invariant check.** Build {{all_sprint_item_ids}} = flat set of all item IDs across ALL sprints in {{sprint_status}}.sprints (every sprint, every status). For each item in {{items_to_move}}: check if its ID exists in {{all_sprint_item_ids}}. If ANY match is found:
    <output>**Error:** Data integrity violation — item {{item.id}} already exists in a sprint. Aborting to prevent duplicate. The sprint-status.yaml file may be corrupted. No changes have been written.</output>
    <action>Exit workflow without writing</action>
  </action>

  <action>**Pre-write: backlog re-validation.** Build {{current_backlog_ids}} = set of all item IDs currently in {{sprint_status}}.backlog. For each item in {{items_to_move}}: check if its ID exists in {{current_backlog_ids}}. If ANY item is missing:
    <output>**Error:** Item {{item.id}} was selected for sprint assignment but is no longer in the backlog. The file may have been modified externally. No changes have been written. Please re-run `/add-to-sprint` to start fresh.</output>
    <action>Exit workflow without writing</action>
  </action>

  <action>Perform ALL of the following in a single atomic write to `sprint-status.yaml`:</action>
  <action>1. For each item in {{items_to_move}}:
    - Build the sprint item object: copy `id`, `type`, `epic`, `title`, `status`, `severity` from the backlog item — DROP the `priority` field (sprint items do not have priority)
    - APPEND the sprint item object to `sprints[{{target_sprint_key}}].items`
    - REMOVE the original item object from the `backlog` array
  </action>
  <action>2. Renumber remaining backlog items' `priority` values sequentially (1..N) to match their new array positions (position 0 → priority 1, position 1 → priority 2, etc.)</action>
  <action>3. Update `last_updated` to the current ISO-8601 timestamp</action>
  <action>4. Preserve `generated`, `epics`, and all other metadata fields unchanged</action>
  <action>5. Write the complete updated `sprint-status.yaml` in a single write operation (all removals + additions + renumbering happen together — no partial state)</action>
</step>

<step n="9" goal="Display summary">
  <output>
## Assignment Complete

**Sprint:** {{target_sprint.name}}
**Items assigned this session:** {{items_to_move.length}}

| # | ID | Title | Type |
|---|----|-------|------|
{{#each items_to_move}}
| {{@index+1}} | {{id}} | {{title}} | {{type}} |
{{/each}}

### Confirmed Ranking (Audit Record)

| Rank | ID | Title | Type | Business Value | Dependencies | Severity | Effort |
|------|----|-------|------|----------------|--------------|----------|--------|
{{#each confirmed_ranking}}
| {{rank}} | {{id}} | {{title}} | {{type}} | {{business_value}} | {{dependency_status}} | {{severity}} | {{effort}} |
{{/each}}

**Updated Capacity:** {{current_sprint_count}}/{{target_sprint.capacity}} items used ({{target_sprint.capacity - current_sprint_count}} remaining)

**Next Steps:**
- Use `/remove-from-sprint` to move items back to backlog if needed
- Use `/modify-sprint` to adjust capacity or sprint metadata
- Use `/sprint-status-view` to view the full sprint with all assigned items
  </output>
</step>

</workflow>
