# Sprint Status Health Workflow

**Goal:** Produce an analysis-focused sprint health summary with risk flags and next-action recommendations by reading the unified `sprint-status.yaml`.

**Your Role:** You are a Scrum Master providing clear, actionable sprint visibility. Focus on health metrics, risk flags, and next steps — not display tables (use `/sprint-status-view` for that).

**READ-ONLY:** This skill NEVER writes to `sprint-status.yaml` or any other file.

---

## INITIALIZATION

### Configuration Loading

Load config from `{project-root}/_bmad/bmm/config.yaml` and resolve:

- `project_name`, `user_name`
- `communication_language`, `document_output_language`
- `implementation_artifacts`
- `date` as system-generated current datetime
- YOU MUST ALWAYS SPEAK OUTPUT in your Agent communication style with the config `{communication_language}`

### Paths

- `sprint_status_file` = `{implementation_artifacts}/sprint-status.yaml`
- `done_folder` = `{implementation_artifacts}/done/`

### Input Files

| Input | Path | Load Strategy |
|-------|------|---------------|
| Sprint status | `{sprint_status_file}` | FULL_LOAD |

### Context

- `project_context` = `**/project-context.md` (load if exists)

---

## EXECUTION

<workflow>

<step n="0" goal="Determine execution mode">
  <action>Set mode = {{mode}} if provided by caller; otherwise mode = "interactive"</action>

  <check if="mode == data">
    <action>Jump to Step 20</action>
  </check>

  <check if="mode == validate">
    <action>Jump to Step 30</action>
  </check>

  <check if="mode == interactive">
    <action>Continue to Step 1</action>
  </check>
</step>

<step n="1" goal="Locate and load sprint-status.yaml">
  <action>Load {project_context} for project-wide patterns and conventions (if exists)</action>
  <action>Try to read {sprint_status_file}</action>
  <check if="file not found">
    <output>No sprint-status.yaml found. Run `/bmad-sprint-planning` to initialize.</output>
    <action>Exit workflow</action>
  </check>
  <action>Parse YAML — extract metadata fields: generated, last_updated, project, project_key, tracking_system, story_location</action>
  <action>Parse three data sections: epics (map), backlog (array), sprints (map)</action>
  <action>Continue to Step 2</action>
</step>

<step n="2" goal="Analyze active sprint health">
  <action>Scan sprints map for the sprint entry with status: active</action>
  <check if="no active sprint found">
    <action>Set active_sprint = null</action>
    <action>Continue to Step 2b (backlog health)</action>
  </check>
  <check if="active sprint found">
    <action>Store as active_sprint with all its fields (name, capacity, start, end, items)</action>
    <action>Compute items_by_status: count items in active_sprint.items grouped by status field (in-progress, review, ready-for-dev, backlog, on-hold, cancelled, done)</action>
    <action>capacity_used = length of active_sprint.items array</action>
    <action>capacity_total = active_sprint.capacity</action>
    <action>capacity_pct = if capacity_total > 0 then round((capacity_used / capacity_total) * 100) else 0 (treat capacity=0 as "no limit set")</action>
    <action>If active_sprint.start is populated: compute sprint_age_days = number of days between active_sprint.start date and today</action>
    <action>For each item in active_sprint.items with status: in-progress: compute item_age_days = sprint_age_days (proxy — item assumed in-progress since sprint start)</action>
  </check>
</step>

<step n="2b" goal="Analyze backlog health">
  <action>backlog_total = length of backlog array</action>
  <action>backlog_bugs = count of backlog items where type == "bug"</action>
  <action>backlog_stories = backlog_total - backlog_bugs</action>
  <action>backlog_critical_bugs = count of backlog bugs where severity == "critical" or severity == "high"</action>
  <action>Continue to Step 2c</action>
</step>

<step n="2c" goal="Compute epic progress">
  <action>For each epic key in the epics map:
    - epic_number = numeric portion of key (e.g., key "epic-17" → epic_number = 17)
    - active_count = count of items across backlog array AND all sprints[*].items arrays where item.epic == epic_number
    - done_count = count of files in {done_folder} whose filename starts with "{epic_number}-" (e.g., "17-*.md")
    - total_count = done_count + active_count
    - Store as: {epic_key, status, retrospective, done_count, active_count, total_count}
  </action>
  <action>Continue to Step 2d</action>
</step>

<step n="2d" goal="Compute sprint history">
  <action>closed_sprints = all sprint entries where status == "closed"</action>
  <action>closed_count = length of closed_sprints</action>
  <action>For each closed sprint: capture name, item count (length of items array), start, end dates</action>
  <action>Continue to Step 3</action>
</step>

<step n="3" goal="Detect risk flags">
  <action>Initialize risks = [] (empty list)</action>

  <!-- Risk: No active sprint -->
  <check if="active_sprint == null">
    <action>Append to risks: "No active sprint — consider running `/add-sprint` to create one or activating a planning sprint"</action>
  </check>

  <!-- Risk: Stale items (in-progress for more than 14 days based on sprint start) -->
  <check if="active_sprint is not null AND sprint_age_days > 14">
    <action>For each item in active_sprint.items where status == "in-progress":
      Append to risks: "Item {{item.id}} has been in-progress for {{sprint_age_days}} days (sprint started {{active_sprint.start}})"
    </action>
  </check>

  <!-- Risk: Items not started -->
  <check if="active_sprint is not null">
    <action>not_started_count = count of items in active_sprint.items where status == "ready-for-dev" or status == "backlog"</action>
    <check if="not_started_count > 0">
      <action>Append to risks: "{{not_started_count}} of {{capacity_used}} items still in ready-for-dev status — not yet started"</action>
    </check>
  </check>

  <!-- Risk: Over-capacity -->
  <check if="active_sprint is not null AND capacity_total > 0 AND capacity_used > capacity_total">
    <action>overage = capacity_used - capacity_total</action>
    <action>Append to risks: "Sprint over capacity: {{capacity_used}}/{{capacity_total}} items ({{overage}} over limit)"</action>
  </check>

  <!-- Risk: At capacity with unstarted items -->
  <check if="active_sprint is not null AND capacity_total > 0 AND capacity_used >= capacity_total AND not_started_count > 0">
    <action>Append to risks: "Sprint at {{capacity_pct}}% capacity ({{capacity_used}}/{{capacity_total}}) with {{not_started_count}} items still in ready-for-dev"</action>
  </check>

  <!-- Risk: No progress toward completion -->
  <check if="active_sprint is not null AND sprint_age_days >= 3">
    <action>review_or_done_count = count of items in active_sprint.items where status == "review" or status == "done"</action>
    <check if="review_or_done_count == 0">
      <action>Append to risks: "No items in review or done — sprint may be at risk (sprint is {{sprint_age_days}} days old)"</action>
    </check>
  </check>

  <!-- Risk: On-hold or cancelled items in active sprint -->
  <check if="active_sprint is not null">
    <action>For each item in active_sprint.items where status == "on-hold" or status == "cancelled":
      Append to risks: "1 item {{item.status}}: {{item.id}}"
    </action>
  </check>

  <!-- Risk: Stale sprint-status.yaml file -->
  <action>staleness_date = last_updated if present, else generated</action>
  <action>file_age_days = number of days between staleness_date and today</action>
  <check if="file_age_days > 7">
    <action>Append to risks: "`last_updated` is {{file_age_days}} days old — sprint-status.yaml may be stale"</action>
  </check>

  <!-- Risk: Orphaned stories (item references epic not in epics section) -->
  <action>For each item in backlog array AND each item in all sprints[*].items arrays:
    If item.epic is not null AND "epic-{{item.epic}}" key does not exist in epics map:
      Append to risks: "Orphaned story detected: item {{item.id}} references epic-{{item.epic}} which is not in the epics section"
  </action>

  <!-- Risk: In-progress epic with no stories -->
  <action>For each epic in epics map where epic.status == "in-progress":
    active_count from Step 2c for this epic
    If active_count == 0 AND done_count (from Step 2c) == 0:
      Append to risks: "In-progress epic {{epic_key}} has no associated stories"
  </action>

  <!-- Risk: Critical bugs in backlog -->
  <action>For each item in backlog array where type == "bug" AND (severity == "critical" or severity == "high"):
    Append to risks: "Critical/high severity bug in backlog: {{item.id}} ({{item.severity}})"
  </action>

  <action>Continue to Step 4</action>
</step>

<step n="4" goal="Select next action recommendation">
  <note>When selecting "first" item: prefer active sprint items over backlog items; within each group, sort by epic number then story number</note>
  <action>Scan for next recommended workflow using priority order:</action>
  1. If any item in active_sprint.items has status == "in-progress" → set next_workflow_id = "dev-story", next_story_id = first such item's id
  2. Else if any item in active_sprint.items has status == "review" → set next_workflow_id = "code-review", next_story_id = first such item's id
  3. Else if any item in active_sprint.items OR backlog has status == "ready-for-dev" → set next_workflow_id = "dev-story", next_story_id = first such item's id
  4. Else if any item in backlog has status == "backlog" → set next_workflow_id = "create-story", next_story_id = first such item's id
  5. Else if any epic has retrospective == "optional" AND status == "done" → set next_workflow_id = "retrospective", next_story_id = that epic's key
  6. Else → set next_workflow_id = null, next_story_id = null (all work complete)
  <action>Store next_workflow_id, next_story_id</action>
  <action>Continue to Step 5</action>
</step>

<step n="5" goal="Display interactive health summary">
  <output>
## Sprint Health Summary

- Project: {{project}} ({{project_key}})
- Tracking: {{tracking_system}}
- Last updated: {{last_updated}}

{{#if active_sprint}}
### Active Sprint: {{active_sprint.name}}
**Capacity:** {{capacity_used}} / {{capacity_total}} ({{capacity_pct}}%)
**Dates:** {{active_sprint.start}} to {{active_sprint.end}}
**Items by status:** in-progress {{items_by_status.in-progress}}, review {{items_by_status.review}}, ready-for-dev {{items_by_status.ready-for-dev}}, backlog {{items_by_status.backlog}}, on-hold {{items_by_status.on-hold}}
{{else}}
### Active Sprint
No active sprint found.
{{/if}}

### Risk Flags
{{#if risks}}
{{#each risks}}
- {{this}}
{{/each}}
{{else}}
No risks detected.
{{/if}}

### Backlog Health
- Total unassigned: {{backlog_total}} ({{backlog_stories}} stories, {{backlog_bugs}} bugs)
- Critical/high bugs in backlog: {{backlog_critical_bugs}}

### Epic Progress
{{#each epic_progress}}
- {{epic_key}} ({{status}}): {{done_count}}/{{total_count}} done
{{/each}}

### Sprint History
- {{closed_count}} closed sprint(s)
{{#each closed_sprints}}
- {{name}}: {{item_count}} items, {{start}} to {{end}}
{{/each}}

### Next Recommendation
{{#if next_workflow_id}}
/{{next_workflow_id}} ({{next_story_id}})
{{else}}
All work complete — great job!
{{/if}}
  </output>
</step>

<step n="6" goal="Offer interactive actions">
  <ask>Pick an option:
1) Run recommended workflow now
2) Show all items grouped by status (active sprint + backlog)
3) Show detailed sprint view (runs `/sprint-status-view`)
4) Show raw sprint-status.yaml
5) Exit
Choice:</ask>

  <check if="choice == 1">
    <check if="next_workflow_id is null">
      <output>No workflow to run — all work is complete.</output>
    </check>
    <check if="next_workflow_id is not null">
      <output>Run `/{{next_workflow_id}}`.
If the command targets a story, set `story_key={{next_story_id}}` when prompted.</output>
    </check>
  </check>

  <check if="choice == 2">
    <output>
### Items by Status

**In Progress:**
{{#each active_sprint.items where status == "in-progress"}}
- {{id}}: {{title}}
{{/each}}

**Review:**
{{#each active_sprint.items where status == "review"}}
- {{id}}: {{title}}
{{/each}}

**Ready for Dev (sprint):**
{{#each active_sprint.items where status == "ready-for-dev"}}
- {{id}}: {{title}}
{{/each}}

**Ready for Dev (backlog):**
{{#each backlog where status == "ready-for-dev"}}
- {{id}}: {{title}}
{{/each}}

**Backlog (unassigned):**
{{#each backlog where status == "backlog"}}
- {{id}}: {{title}}
{{/each}}
    </output>
  </check>

  <check if="choice == 3">
    <output>For a full formatted table view with all items, run `/sprint-status-view`.</output>
  </check>

  <check if="choice == 4">
    <action>Display the full contents of {sprint_status_file}</action>
  </check>

  <check if="choice == 5">
    <action>Exit workflow</action>
  </check>
</step>

<!-- ========================= -->
<!-- Data mode for other flows -->
<!-- ========================= -->

<step n="20" goal="Data mode output">
  <action>Load and parse {sprint_status_file} same as Steps 1–2d</action>
  <action>Detect risks same as Step 3</action>
  <action>Compute recommendation same as Step 4</action>
  <template-output>active_sprint_id = {{active_sprint_id}}</template-output>
  <template-output>active_sprint_name = {{active_sprint_name}}</template-output>
  <template-output>next_workflow_id = {{next_workflow_id}}</template-output>
  <template-output>next_story_id = {{next_story_id}}</template-output>
  <template-output>count_backlog = {{count_backlog}}</template-output>
  <template-output>count_ready = {{count_ready}}</template-output>
  <template-output>count_in_progress = {{count_in_progress}}</template-output>
  <template-output>count_review = {{count_review}}</template-output>
  <template-output>count_done = {{count_done}}</template-output>
  <template-output>count_on_hold = {{count_on_hold}}</template-output>
  <template-output>capacity_used = {{capacity_used}}</template-output>
  <template-output>capacity_total = {{capacity_total}}</template-output>
  <template-output>capacity_pct = {{capacity_pct}}</template-output>
  <template-output>backlog_total = {{backlog_total}}</template-output>
  <template-output>backlog_bugs = {{backlog_bugs}}</template-output>
  <template-output>backlog_critical_bugs = {{backlog_critical_bugs}}</template-output>
  <template-output>epic_summary = {{epic_summary}}</template-output>
  <template-output>risks = {{risks}}</template-output>
  <action>Return to caller</action>
</step>

<!-- Notes on count_* field semantics in data mode:
  count_backlog   = items with status "backlog" across active sprint items + backlog array
  count_ready     = items with status "ready-for-dev" across active sprint items + backlog array
  count_in_progress = items with status "in-progress" in active sprint
  count_review    = items with status "review" in active sprint
  count_done      = items with status "done" in active sprint (not counting done/ folder archived items)
  count_on_hold   = items with status "on-hold" or "cancelled" in active sprint
  Backward compatibility: count_backlog, count_ready, count_in_progress, count_review, count_done,
    next_workflow_id, next_story_id, and risks keys are preserved from the original built-in data mode output.
-->

<!-- ========================= -->
<!-- Validate mode -->
<!-- ========================= -->

<step n="30" goal="Validate sprint-status.yaml against unified schema">
  <action>Check that {sprint_status_file} exists</action>
  <check if="missing">
    <template-output>is_valid = false</template-output>
    <template-output>error = "sprint-status.yaml missing"</template-output>
    <template-output>suggestion = "Run /bmad-sprint-planning to create it"</template-output>
    <action>Return</action>
  </check>

  <action>Read and parse {sprint_status_file}</action>

  <action>Validate required metadata fields exist: generated, last_updated, project, project_key, tracking_system, story_location</action>
  <check if="any required field missing">
    <template-output>is_valid = false</template-output>
    <template-output>error = "Missing required metadata field(s): {{missing_fields}}"</template-output>
    <template-output>suggestion = "Re-run /bmad-sprint-planning or add missing fields manually"</template-output>
    <action>Return</action>
  </check>

  <action>Verify three data sections exist: epics (map or empty map {}), backlog (array or empty array []), sprints (map or empty map {})</action>
  <check if="any data section missing">
    <template-output>is_valid = false</template-output>
    <template-output>error = "Missing data section(s): {{missing_sections}}. Expected: epics, backlog, sprints"</template-output>
    <template-output>suggestion = "Re-run /bmad-sprint-planning or repair the file manually to add missing sections"</template-output>
    <action>Return</action>
  </check>

  <action>Validate all epic status values: must be one of backlog, in-progress, done, on-hold, cancelled</action>
  <check if="invalid epic status found">
    <template-output>is_valid = false</template-output>
    <template-output>error = "Invalid epic status value(s): {{invalid_epic_entries}}"</template-output>
    <template-output>suggestion = "Valid epic statuses: backlog, in-progress, done, on-hold, cancelled"</template-output>
    <action>Return</action>
  </check>

  <action>Validate all item status values (across backlog array and all sprints[*].items arrays): must be one of backlog, ready-for-dev, in-progress, review, done, on-hold, cancelled</action>
  <check if="invalid item status found">
    <template-output>is_valid = false</template-output>
    <template-output>error = "Invalid item status value(s): {{invalid_item_entries}}"</template-output>
    <template-output>suggestion = "Valid item statuses: backlog, ready-for-dev, in-progress, review, done, on-hold, cancelled"</template-output>
    <action>Return</action>
  </check>

  <action>Validate all sprint status values: must be one of planning, active, closed</action>
  <check if="invalid sprint status found">
    <template-output>is_valid = false</template-output>
    <template-output>error = "Invalid sprint status value(s): {{invalid_sprint_entries}}"</template-output>
    <template-output>suggestion = "Valid sprint statuses: planning, active, closed"</template-output>
    <action>Return</action>
  </check>

  <action>Check single-active-sprint constraint: count sprints with status == "active"</action>
  <check if="active_sprint_count > 1">
    <template-output>is_valid = false</template-output>
    <template-output>error = "Multiple active sprints detected ({{active_sprint_count}}). At most one sprint may have status: active."</template-output>
    <template-output>suggestion = "Close or set other active sprints to planning status"</template-output>
    <action>Return</action>
  </check>

  <action>Spot check single-location invariant: sample up to 5 item IDs from across all locations and verify each ID appears in exactly one location (either backlog array OR one sprint's items array, never both)</action>
  <check if="any item found in multiple locations">
    <template-output>is_valid = false</template-output>
    <template-output>error = "Single-location invariant violated: item(s) {{duplicate_ids}} appear in multiple locations"</template-output>
    <template-output>suggestion = "Remove duplicate item entries — each item ID must appear in exactly one location"</template-output>
    <action>Return</action>
  </check>

  <template-output>is_valid = true</template-output>
  <template-output>message = "sprint-status.yaml valid: unified schema structure verified"</template-output>
</step>

</workflow>
