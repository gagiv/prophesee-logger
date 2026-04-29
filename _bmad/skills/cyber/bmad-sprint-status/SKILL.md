---
name: bmad-sprint-status
description: Analyze sprint health, surface risk flags, and recommend next actions from the unified sprint-status.yaml
---
# bmad-sprint-status

Analyze sprint health, surface risk flags, and recommend next actions from the unified `sprint-status.yaml`.

**READ-ONLY:** This skill NEVER writes to `sprint-status.yaml` or any other file.

**Path resolution:** This skill resolves paths directly from the project structure. The sprint status file is at `_bmad-output/implementation-artifacts/sprint-status.yaml` relative to the project root. The done folder is at `_bmad-output/implementation-artifacts/done/`.

---

## Invocation Modes

This skill supports three execution modes. Set `mode` before invoking:

- `mode = interactive` (default) — full health summary with risk flags and interactive action menu
- `mode = data` — structured key-value output for consumption by other skills/workflows
- `mode = validate` — schema validation of sprint-status.yaml against the unified schema

---

## Step 0: Determine Execution Mode

Set `mode` = value provided by caller; if not provided, default to `"interactive"`.

- If `mode == "data"` → skip to Step 20
- If `mode == "validate"` → skip to Step 30
- If `mode == "interactive"` → continue to Step 1

---

## Step 1: Locate and Load sprint-status.yaml

1. Try to read `_bmad-output/implementation-artifacts/sprint-status.yaml` from the project root.
2. If file not found: output `"No sprint-status.yaml found. Run /bmad-sprint-planning to initialize."` and stop.
3. Parse YAML — extract:
   - Metadata fields: `generated`, `last_updated`, `project`, `project_key`, `tracking_system`, `story_location`
   - Three data sections: `epics` (map), `backlog` (array), `sprints` (map)

---

## Step 2: Analyze Active Sprint Health

1. Scan the `sprints` map for the entry with `status: active`.
2. If no active sprint found: set `active_sprint = null` and skip to Step 2b.
3. If active sprint found, store it and compute:
   - `items_by_status`: count items in `active_sprint.items` grouped by `status` field
   - `capacity_used` = length of `active_sprint.items` array
   - `capacity_total` = `active_sprint.capacity`
   - `capacity_pct` = `round((capacity_used / capacity_total) * 100)` if `capacity_total > 0`, else `0`
   - If `active_sprint.start` is populated: `sprint_age_days` = days between `active_sprint.start` and today

---

## Step 2b: Analyze Backlog Health

1. `backlog_total` = length of `backlog` array
2. `backlog_bugs` = count of backlog items where `type == "bug"`
3. `backlog_stories` = `backlog_total - backlog_bugs`
4. `backlog_critical_bugs` = count of backlog bugs where `severity == "critical"` or `severity == "high"`

---

## Step 2c: Compute Epic Progress

For each epic key in the `epics` map:

1. `epic_number` = numeric portion of key (e.g., `"epic-17"` → `17`)
2. `active_count` = count of items across `backlog` array AND all `sprints[*].items` arrays where `item.epic == epic_number`
3. `done_count` = count of files in `_bmad-output/implementation-artifacts/done/` whose filename starts with `"{epic_number}-"` (e.g., `"17-*.md"`)
4. `total_count` = `done_count + active_count`
5. Store: `{epic_key, status, retrospective, done_count, active_count, total_count}`

---

## Step 2d: Compute Sprint History

1. `closed_sprints` = all sprint entries where `status == "closed"`
2. `closed_count` = length of `closed_sprints`
3. For each closed sprint: capture `name`, item count (length of `items` array), `start`, `end`

---

## Step 3: Detect Risk Flags

Initialize `risks = []` (empty list). Check each risk condition and append messages as applicable:

**Risk: No active sprint**
- If `active_sprint == null`: append `"No active sprint — consider running /add-sprint to create one or activating a planning sprint"`

**Risk: Stale in-progress items** (sprint has been running for more than 14 days)
- If `active_sprint` exists AND `sprint_age_days > 14`: for each item in `active_sprint.items` with `status == "in-progress"`:
  append `"Item {item.id} has been in-progress for {sprint_age_days} days (sprint started {active_sprint.start})"`

**Risk: Items not started**
- If `active_sprint` exists: count items where `status == "ready-for-dev"` or `status == "backlog"` → `not_started_count`
- If `not_started_count > 0`: append `"{not_started_count} of {capacity_used} items still in ready-for-dev status — not yet started"`

**Risk: Over-capacity**
- If `active_sprint` exists AND `capacity_total > 0` AND `capacity_used > capacity_total`:
  `overage = capacity_used - capacity_total`
  append `"Sprint over capacity: {capacity_used}/{capacity_total} items ({overage} over limit)"`

**Risk: At capacity with unstarted items**
- If `active_sprint` exists AND `capacity_total > 0` AND `capacity_used >= capacity_total` AND `not_started_count > 0`:
  append `"Sprint at {capacity_pct}% capacity ({capacity_used}/{capacity_total}) with {not_started_count} items still in ready-for-dev"`

**Risk: No progress toward completion** (only flag if sprint is at least 3 days old)
- If `active_sprint` exists AND `sprint_age_days >= 3`:
  `review_or_done_count` = count of items where `status == "review"` or `status == "done"`
  If `review_or_done_count == 0`: append `"No items in review or done — sprint may be at risk (sprint is {sprint_age_days} days old)"`

**Risk: On-hold or cancelled items in active sprint**
- If `active_sprint` exists: for each item where `status == "on-hold"` or `status == "cancelled"`:
  append `"1 item {item.status}: {item.id}"`

**Risk: Stale sprint-status.yaml file**
- `staleness_date` = `last_updated` if present, else `generated`
- `file_age_days` = days between `staleness_date` and today
- If `file_age_days > 7`: append `"\`last_updated\` is {file_age_days} days old — sprint-status.yaml may be stale"`

**Risk: Orphaned stories** (item references epic not in epics section)
- For each item in `backlog` array AND each item in all `sprints[*].items` arrays:
  If `item.epic` is not null AND `"epic-{item.epic}"` does not exist in `epics` map:
  append `"Orphaned story detected: item {item.id} references epic-{item.epic} which is not in the epics section"`

**Risk: In-progress epic with no stories**
- For each epic in `epics` map where `epic.status == "in-progress"`:
  If `active_count == 0` AND `done_count == 0`:
  append `"In-progress epic {epic_key} has no associated stories"`

**Risk: Critical/high bugs in backlog**
- For each item in `backlog` array where `type == "bug"` AND (`severity == "critical"` or `severity == "high"`):
  append `"Critical/high severity bug in backlog: {item.id} ({item.severity})"`

---

## Step 4: Select Next Action Recommendation

Priority order (highest to lowest). When selecting "first" item: prefer active sprint items over backlog items; within each group, sort by epic number then story number.

1. If any item in `active_sprint.items` has `status == "in-progress"` → `next_workflow_id = "dev-story"`, `next_story_id` = first such item's id
2. Else if any item in `active_sprint.items` has `status == "review"` → `next_workflow_id = "code-review"`, `next_story_id` = first such item's id
3. Else if any item in `active_sprint.items` OR `backlog` has `status == "ready-for-dev"` → `next_workflow_id = "dev-story"`, `next_story_id` = first such item's id
4. Else if any item in `backlog` has `status == "backlog"` → `next_workflow_id = "create-story"`, `next_story_id` = first such item's id
5. Else if any epic has `retrospective == "optional"` AND `status == "done"` → `next_workflow_id = "retrospective"`, `next_story_id` = that epic's key
6. Else → `next_workflow_id = null`, `next_story_id = null` (all work complete)

---

## Step 5: Display Interactive Health Summary

Output this health summary (replace all `{{...}}` with computed values):

```
## Sprint Health Summary

- Project: {{project}} ({{project_key}})
- Tracking: {{tracking_system}}
- Last updated: {{last_updated}}

### Active Sprint: {{active_sprint.name}}
(If no active sprint: "No active sprint found.")
**Capacity:** {{capacity_used}} / {{capacity_total}} ({{capacity_pct}}%)
**Dates:** {{active_sprint.start}} to {{active_sprint.end}}
**Items by status:** in-progress {{n}}, review {{n}}, ready-for-dev {{n}}, backlog {{n}}, on-hold {{n}}

### Risk Flags
- {{risk_1}}
- {{risk_2}}
(or "No risks detected." if empty)

### Backlog Health
- Total unassigned: {{backlog_total}} ({{backlog_stories}} stories, {{backlog_bugs}} bugs)
- Critical/high bugs in backlog: {{backlog_critical_bugs}}

### Epic Progress
- {{epic_key}} ({{status}}): {{done_count}}/{{total_count}} done
(one line per epic)

### Sprint History
- {{closed_count}} closed sprint(s)
- {{sprint_name}}: {{item_count}} items, {{start}} to {{end}}
(one line per closed sprint)

### Next Recommendation
/{{next_workflow_id}} ({{next_story_id}})
(or "All work complete — great job!" if no recommendation)
```

---

## Step 6: Offer Interactive Actions

Present the following menu and handle the user's choice:

```
Pick an option:
1) Run recommended workflow now
2) Show all items grouped by status (active sprint + backlog)
3) Show detailed sprint view (runs /sprint-status-view)
4) Show raw sprint-status.yaml
5) Exit
Choice:
```

- **Choice 1:** If `next_workflow_id` is null, output "No workflow to run — all work is complete." Otherwise output: `"Run /{next_workflow_id}. If the command targets a story, set story_key={next_story_id} when prompted."`
- **Choice 2:** List items grouped by status: in-progress, review, ready-for-dev (sprint), ready-for-dev (backlog), backlog (unassigned). Show `id: title` per item.
- **Choice 3:** Output: `"For a full formatted table view with all items, run /sprint-status-view."`
- **Choice 4:** Display the full contents of `sprint-status.yaml`.
- **Choice 5:** Exit.

---

## Step 20: Data Mode Output

Load and parse sprint-status.yaml (same as Steps 1–2d), detect risks (same as Step 3), compute recommendation (same as Step 4), then output these key-value pairs:

```
active_sprint_id = {{active_sprint_id}}
active_sprint_name = {{active_sprint_name}}
next_workflow_id = {{next_workflow_id}}
next_story_id = {{next_story_id}}
count_backlog = {{count_backlog}}
count_ready = {{count_ready}}
count_in_progress = {{count_in_progress}}
count_review = {{count_review}}
count_done = {{count_done}}
count_on_hold = {{count_on_hold}}
capacity_used = {{capacity_used}}
capacity_total = {{capacity_total}}
capacity_pct = {{capacity_pct}}
backlog_total = {{backlog_total}}
backlog_bugs = {{backlog_bugs}}
backlog_critical_bugs = {{backlog_critical_bugs}}
epic_summary = {{epic_summary}}
risks = {{risks}}
```

**Count field semantics:**
- `count_backlog` = items with `status "backlog"` across active sprint items + backlog array
- `count_ready` = items with `status "ready-for-dev"` across active sprint items + backlog array
- `count_in_progress` = items with `status "in-progress"` in active sprint
- `count_review` = items with `status "review"` in active sprint
- `count_done` = items with `status "done"` in active sprint (does not count `done/` archived items)
- `count_on_hold` = items with `status "on-hold"` or `"cancelled"` in active sprint

**Backward compatibility:** `count_backlog`, `count_ready`, `count_in_progress`, `count_review`, `count_done`, `next_workflow_id`, `next_story_id`, and `risks` are preserved from the original built-in data mode output. The additional keys (`active_sprint_id`, `active_sprint_name`, `capacity_*`, `backlog_*`, `epic_summary`, `count_on_hold`) are new extensions that do not break existing consumers.

Return output to caller.

---

## Step 30: Validate Mode

Validate `_bmad-output/implementation-artifacts/sprint-status.yaml` against the unified schema. Return `is_valid`, `error`, `suggestion` (or `message`) keys.

1. **File exists?** If not: `is_valid = false`, `error = "sprint-status.yaml missing"`, `suggestion = "Run /bmad-sprint-planning to create it"`

2. **Required metadata fields present?** Check: `generated`, `last_updated`, `project`, `project_key`, `tracking_system`, `story_location`. If any missing: `is_valid = false`, `error = "Missing required metadata field(s): {missing_fields}"`, `suggestion = "Re-run /bmad-sprint-planning or add missing fields manually"`

3. **Three data sections present?** Check: `epics` (map or `{}`), `backlog` (array or `[]`), `sprints` (map or `{}`). If any missing: `is_valid = false`, `error = "Missing data section(s): {missing_sections}. Expected: epics, backlog, sprints"`, `suggestion = "Re-run /bmad-sprint-planning or repair the file manually"`

4. **Valid epic statuses?** Check all epic `status` values against: `backlog`, `in-progress`, `done`, `on-hold`, `cancelled`. If invalid: `is_valid = false`, `error = "Invalid epic status value(s): {invalid_entries}"`, `suggestion = "Valid epic statuses: backlog, in-progress, done, on-hold, cancelled"`

5. **Valid item statuses?** Check all item `status` values (across `backlog` array AND all `sprints[*].items` arrays) against: `backlog`, `ready-for-dev`, `in-progress`, `review`, `done`, `on-hold`, `cancelled`. If invalid: `is_valid = false`, `error = "Invalid item status value(s): {invalid_entries}"`, `suggestion = "Valid item statuses: backlog, ready-for-dev, in-progress, review, done, on-hold, cancelled"`

6. **Valid sprint statuses?** Check all sprint `status` values against: `planning`, `active`, `closed`. If invalid: `is_valid = false`, `error = "Invalid sprint status value(s): {invalid_entries}"`, `suggestion = "Valid sprint statuses: planning, active, closed"`

7. **Single active sprint?** Count sprints with `status: active`. If count > 1: `is_valid = false`, `error = "Multiple active sprints detected ({count}). At most one sprint may have status: active."`, `suggestion = "Close or set other active sprints to planning status"`

8. **Single-location invariant (spot check)?** Sample up to 5 item IDs from all locations. Verify each ID appears in exactly one location (either `backlog` array OR one sprint's `items` array, never both). If duplicate: `is_valid = false`, `error = "Single-location invariant violated: item(s) {duplicate_ids} appear in multiple locations"`, `suggestion = "Remove duplicate item entries — each item ID must appear in exactly one location"`

9. **All checks passed:** `is_valid = true`, `message = "sprint-status.yaml valid: unified schema structure verified"`
