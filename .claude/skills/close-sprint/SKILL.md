---
name: close-sprint
description: Close an active sprint — archive done/cancelled items, disposition incomplete items (move to next sprint or return to backlog), set sprint status to closed
---
# Close Sprint Workflow

Close an active sprint — archive done/cancelled items, disposition incomplete items (move to next sprint or return to backlog), and set sprint status to `closed`.

**Schema Reference:** `_bmad-output/planning-artifacts/sprint-status-schema.md` (Story 17.9)

<workflow>

<step n="0" goal="Load configuration and validate file existence">
  <action>Set {{status_file}} = `_bmad-output/implementation-artifacts/sprint-status.yaml`</action>
  <action>Set {{story_location}} = resolve from {{status_file}} metadata field `story_location` (default: `_bmad-output/implementation-artifacts`)</action>

  <check if="{{status_file}} does NOT exist">
    <output>**Error:** No sprint-status.yaml found. Run sprint planning first to initialize the file.</output>
    <action>Exit workflow</action>
  </check>

  <action>Read the FULL {{status_file}}</action>
  <action>Parse into {{data}} with sections: metadata, `epics`, `backlog`, and `sprints`</action>
  <action>Store {{story_location}} from {{data}}.metadata.story_location</action>
</step>

<step n="1" goal="Identify the active sprint">
  <action>Scan {{data}}.sprints for a sprint with `status: active`</action>
  <check if="no active sprint found">
    <output>No active sprint found. Nothing to close.</output>
    <action>Exit workflow</action>
  </check>
  <action>Store the active sprint as {{active_sprint}} (id + full sprint data)</action>
  <action>Store {{active_sprint_id}} = the sprint's map key (e.g., `sprint-1`)</action>
</step>

<step n="2" goal="Display sprint summary and confirm closure">
  <action>Read {{active_sprint}}.items array</action>
  <action>Store {{all_items}} = {{active_sprint}}.items</action>
  <action>Store {{total_count}} = length of {{all_items}}</action>

  <!-- Initialize counters and collections (always, to prevent undefined in summary output) -->
  <action>Set {{done_count}} = 0</action>
  <action>Set {{cancelled_count}} = 0</action>
  <action>Set {{moved_to_sprint_count}} = 0</action>
  <action>Set {{moved_to_sprint_name}} = ""</action>
  <action>Set {{returned_to_backlog_count}} = 0</action>
  <action>Set {{archived_done_files}} = []</action>
  <action>Set {{archived_cancelled_files}} = []</action>
  <action>Set {{skipped_done}} = []</action>
  <action>Set {{skipped_cancelled}} = []</action>

  <check if="{{total_count}} == 0">
    <action>Set {{empty_sprint_fast_path}} = true</action>
    <action>Jump to step 7 (empty sprint fast path)</action>
  </check>

  <action>Set {{empty_sprint_fast_path}} = false</action>
  <action>Categorize items:
    - {{done_items}} = items where status == `done`
    - {{cancelled_items}} = items where status == `cancelled`
    - {{incomplete_items}} = items where status is `ready-for-dev`, `in-progress`, `review`, or `on-hold`
  </action>

  <output>
## Sprint Closure Summary: {{active_sprint.name}} ({{active_sprint_id}})

**Total items:** {{total_count}}
- Done: {{done_items.length}} (will be archived)
- Cancelled: {{cancelled_items.length}} (will be archived)
- Incomplete: {{incomplete_items.length}} (requires disposition)

| # | ID | Title | Type | Status | Disposition |
|---|----|----|----|----|---|
{{#each done_items}}
| {{@index+1}} | {{id}} | {{title}} | {{type}} | done | archive to done/ |
{{/each}}
{{#each cancelled_items}}
| {{@index+1}} | {{id}} | {{title}} | {{type}} | cancelled | archive to done/ |
{{/each}}
{{#each incomplete_items}}
| {{@index+1}} | {{id}} | {{title}} | {{type}} | {{status}} | pending decision |
{{/each}}
  </output>

  <ask>Proceed with sprint closure? [c] Confirm and proceed / [x] Cancel:</ask>
  <check if="user selects 'x'">
    <output>Sprint closure cancelled. No changes made.</output>
    <action>Exit workflow</action>
  </check>
</step>

<step n="3" goal="Archive done items (AC: 2)">
  <check if="{{done_items}} is empty">
    <action>Skip to step 4 (done_count stays 0, archived_done_files stays [])</action>
  </check>

  <action>Ensure `{{story_location}}/done/` directory exists. If it does not exist, create it.</action>

  <action>For each item in {{done_items}}:
    1. Resolve source path: `{{story_location}}/{{item.id}}.md`
       - For bug items (type == bug): also try `{{story_location}}/bug-{{item.id_slug}}.md` as fallback (handle case variations)
    2. Resolve destination path: `{{story_location}}/done/{{item.id}}.md`
    3. If source file does NOT exist:
       - Log warning: "File not found: {{source_path}} — skipping file move."
       - Add item to {{skipped_done}} with reason "source missing"
       - Continue to next item
    4. If destination file ALREADY EXISTS in done/:
       - Log warning: "File already exists at destination: {{destination_path}} — skipping file move."
       - Add item to {{skipped_done}} with reason "destination exists"
       - Continue to next item
    5. Move (rename) the file: source → destination
    6. Add item to {{archived_done_files}}
  </action>

  <action>Remove ALL done items from {{active_sprint}}.items in {{data}}</action>
  <action>Store {{done_count}} = length of {{done_items}}</action>
</step>

<step n="4" goal="Archive cancelled items (AC: 3)">
  <check if="{{cancelled_items}} is empty">
    <action>Skip to step 5 (cancelled_count stays 0, archived_cancelled_files stays [])</action>
  </check>

  <action>Ensure `{{story_location}}/done/` directory exists (may already exist from step 3)</action>

  <action>For each item in {{cancelled_items}}:
    1. Resolve source path: `{{story_location}}/{{item.id}}.md`
       - For bug items (type == bug): also try `{{story_location}}/bug-{{item.id_slug}}.md` as fallback (handle case variations)
    2. Resolve destination path: `{{story_location}}/done/{{item.id}}.md`
    3. If source file does NOT exist:
       - Log warning: "File not found: {{source_path}} — skipping file move."
       - Add item to {{skipped_cancelled}} with reason "source missing"
       - Continue to next item
    4. If destination file ALREADY EXISTS in done/:
       - Log warning: "File already exists at destination: {{destination_path}} — skipping file move."
       - Add item to {{skipped_cancelled}} with reason "destination exists"
       - Continue to next item
    5. Move (rename) the file: source → destination
    6. Add item to {{archived_cancelled_files}}
  </action>

  <action>Remove ALL cancelled items from {{active_sprint}}.items in {{data}}</action>
  <action>Store {{cancelled_count}} = length of {{cancelled_items}}</action>
</step>

<step n="5" goal="Disposition incomplete items (AC: 4, 11)">
  <check if="{{incomplete_items}} is empty">
    <action>Skip to step 6</action>
  </check>

  <output>
## Incomplete Items Requiring Disposition

| # | ID | Title | Type | Status |
|---|----|----|----|----|
{{#each incomplete_items}}
| {{@index+1}} | {{id}} | {{title}} | {{type}} | {{status}} |
{{/each}}

**Options:**
**(a)** Move all to the next sprint
**(b)** Return all to backlog
**(c)** Decide per item
  </output>

  <ask>Choose disposition option [a/b/c]:</ask>

  <!-- OPTION A: Move all to next sprint -->
  <check if="user selects 'a'">
    <action>Scan {{data}}.sprints for sprints with `status: planning`</action>
    <action>Store {{planning_sprints}} = list of planning sprints</action>

    <check if="{{planning_sprints}} is empty">
      <output>**No planning sprint found.** Run `/add-sprint` to create one, or choose option (b) to return items to backlog.</output>
      <ask>Choose disposition option [b] Return all to backlog / [c] Decide per item:</ask>
      <check if="user selects 'b'"><goto option_b /></check>
      <check if="user selects 'c'"><goto option_c /></check>
    </check>

    <check if="{{planning_sprints}}.length > 1">
      <output>
## Planning Sprints Available

| # | Sprint | Capacity | Items | Remaining |
|---|---|---|---|---|
{{#each planning_sprints}}
| {{@index+1}} | {{name}} ({{id}}) | {{capacity}} | {{items_count}} | {{remaining}} |
{{/each}}
      </output>
      <ask>Select target sprint (enter number):</ask>
      <action>Store {{target_sprint}} = selected planning sprint</action>
    </check>

    <check if="{{planning_sprints}}.length == 1">
      <action>Store {{target_sprint}} = {{planning_sprints}}[0]</action>
    </check>

    <action>Calculate {{new_count}} = {{target_sprint}}.items.length + {{incomplete_items}}.length</action>
    <check if="{{new_count}} > {{target_sprint}}.capacity">
      <output>**Capacity Warning:** Adding {{incomplete_items.length}} items would bring {{target_sprint.name}} to {{new_count}}/{{target_sprint.capacity}} capacity (exceeds limit). Proceeding anyway (capacity is advisory).</output>
    </check>

    <action>For each item in {{incomplete_items}}:
      1. REMOVE the item from {{active_sprint}}.items in {{data}}
      2. ADD the item to {{target_sprint}}.items in {{data}}
      3. PRESERVE the item's current `status` unchanged (no reset)
    </action>
    <action>Store {{moved_to_sprint_count}} = length of {{incomplete_items}}</action>
    <action>Store {{moved_to_sprint_name}} = {{target_sprint}}.name</action>
    <action>Store {{returned_to_backlog_count}} = 0</action>
  </check>

  <!-- OPTION B: Return all to backlog -->
  <check if="user selects 'b'" id="option_b">
    <action>Calculate {{max_priority}} = max `priority` value among all items currently in {{data}}.backlog (0 if backlog is empty)</action>

    <action>For each item in {{incomplete_items}} (processing in order):
      1. REMOVE the item from {{active_sprint}}.items in {{data}}
      2. SET item.status = `ready-for-dev` (schema section 4.5 — status reset on backlog return)
      3. SET item.priority = {{max_priority}} + 1 (then increment {{max_priority}} for the next item)
      4. APPEND the item to the END of {{data}}.backlog
      5. PRESERVE all other fields: `id`, `type`, `epic`, `title`, `severity`
    </action>

    <action>Re-number ALL {{data}}.backlog items' `priority` fields sequentially 1..N (array position 0 = priority 1) to maintain the denormalized index invariant</action>
    <action>Store {{returned_to_backlog_count}} = length of {{incomplete_items}}</action>
    <action>Store {{moved_to_sprint_count}} = 0</action>
    <action>Store {{moved_to_sprint_name}} = ""</action>
  </check>

  <!-- OPTION C: Per-item decision -->
  <check if="user selects 'c'" id="option_c">
    <action>Initialize {{per_item_sprint_targets}} = {} and {{per_item_backlog}} = []</action>
    <action>Initialize {{moved_to_sprint_count}} = 0 and {{returned_to_backlog_count}} = 0</action>

    <action>For each item in {{incomplete_items}} (iterate one by one):
      Display: "**Item:** {{item.id}} — {{item.title}} (status: {{item.status}})"
    </action>
    <ask>**[s]** Move to next sprint / **[b]** Return to backlog:</ask>

    <check if="user selects 's'">
      <action>Scan {{data}}.sprints for sprints with `status: planning`</action>
      <check if="no planning sprint exists">
        <output>No planning sprint found. Returning this item to the backlog instead.</output>
        <action>Add item to {{per_item_backlog}}</action>
      </check>
      <check if="planning sprint(s) exist">
        <check if="multiple planning sprints">
          <output>Select target sprint:</output>
          <ask>Planning sprint number:</ask>
          <action>Store selected sprint as {{item_target_sprint}}</action>
        </check>
        <check if="single planning sprint">
          <action>Store as {{item_target_sprint}}</action>
        </check>
        <action>Check capacity warning (same advisory logic as option a)</action>
        <action>REMOVE item from {{active_sprint}}.items in {{data}}</action>
        <action>ADD item to {{item_target_sprint}}.items in {{data}} preserving current status</action>
        <action>Increment {{moved_to_sprint_count}}</action>
      </check>
    </check>

    <check if="user selects 'b'">
      <action>Add item to {{per_item_backlog}}</action>
    </check>

    <action>After all per-item decisions, process {{per_item_backlog}}:
      1. Calculate {{max_priority}} = max `priority` value among all items in {{data}}.backlog (0 if empty)
      2. For each item in {{per_item_backlog}}:
         - REMOVE item from {{active_sprint}}.items in {{data}}
         - SET item.status = `ready-for-dev`
         - SET item.priority = {{max_priority}} + 1 (then increment for next)
         - APPEND to END of {{data}}.backlog
      3. Re-number ALL {{data}}.backlog items' `priority` fields sequentially 1..N
      4. Set {{returned_to_backlog_count}} = length of {{per_item_backlog}}
    </action>
    <action>Store {{moved_to_sprint_name}} = name of the planning sprint used (if any items moved to sprint)</action>
  </check>
</step>

<step n="6" goal="Validate single-location invariant before write">
  <action>Build a flat list of all item IDs across {{data}}.backlog and all sprints in {{data}}.sprints</action>
  <action>Check for any ID that appears more than once across all locations</action>
  <check if="any duplicate ID found">
    <output>**Error:** Data integrity violation — item {{duplicate_id}} appears in more than one location. Aborting write to prevent data corruption. Please report this as a bug in the skill.</output>
    <action>Exit workflow without writing</action>
  </check>
</step>

<step n="7" goal="Finalize sprint closure (AC: 5, 8)">
  <action>Set {{data}}.sprints.{{active_sprint_id}}.status = `closed`</action>
  <action>Verify {{data}}.sprints.{{active_sprint_id}}.items is now empty (`[]`)</action>
  <check if="items array is NOT empty">
    <output>**Warning:** Sprint items array is not empty after disposition. This may indicate a processing error. Proceeding with closure anyway — remaining items are listed below for manual review.</output>
  </check>
  <action>Update {{data}}.metadata.last_updated = current ISO-8601 timestamp</action>
  <action>Preserve {{data}}.metadata.generated unchanged</action>
  <action>Preserve {{data}}.epics unchanged</action>
  <action>Preserve all other sprints in {{data}}.sprints unchanged</action>

  <critical>Write the complete updated {{data}} to {{status_file}} as a SINGLE atomic write. This one write includes: item removals from the active sprint, backlog additions, next-sprint additions, sprint status change to closed, and metadata update.</critical>
</step>

<step n="8" goal="Display summary output">
  <!-- Handle empty sprint fast path from step 2 -->
  <check if="{{empty_sprint_fast_path}} == true">
    <output>
## Sprint Closed Successfully

**Sprint:** {{active_sprint.name}} ({{active_sprint_id}})
**Status:** closed

Sprint {{active_sprint.name}} closed. No items to disposition.

**Next Steps:**
- Use `/add-sprint` to create the next sprint
- Use `/sprint-status-view` to review the updated status
    </output>
    <action>Exit workflow</action>
  </check>

  <output>
## Sprint Closed Successfully

**Sprint:** {{active_sprint.name}} ({{active_sprint_id}})
**Status:** closed

**Disposition:**
- Done items archived: {{done_count}}
- Cancelled items archived: {{cancelled_count}}
{{#if moved_to_sprint_count}}
- Items moved to {{moved_to_sprint_name}}: {{moved_to_sprint_count}}
{{/if}}
{{#if returned_to_backlog_count}}
- Items returned to backlog: {{returned_to_backlog_count}}
{{/if}}

{{#if archived_done_files.length}}
**Files moved to done/:**
{{#each archived_done_files}}
- {{id}} → done/
{{/each}}
{{/if}}

{{#if archived_cancelled_files.length}}
**Cancelled files moved to done/:**
{{#each archived_cancelled_files}}
- {{id}} → done/
{{/each}}
{{/if}}

{{#if skipped_done.length}}
**Skipped (warnings):**
{{#each skipped_done}}
- {{id}} — {{reason}}
{{/each}}
{{/if}}

{{#if skipped_cancelled.length}}
**Skipped (warnings):**
{{#each skipped_cancelled}}
- {{id}} — {{reason}}
{{/each}}
{{/if}}

**Next Steps:**
- Use `/add-sprint` to create the next sprint
- Use `/prioritize-backlog` to reorder the backlog after returns
- Use `/sprint-status-view` to review the updated status
  </output>
</step>

</workflow>
