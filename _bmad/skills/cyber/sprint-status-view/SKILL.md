---
name: sprint-status-view
description: Display formatted sprint progress, backlog, and epic status from the unified sprint-status.yaml
---
# Sprint Status View

Display a formatted, read-only dashboard of all sprint, backlog, and epic data from the unified `sprint-status.yaml` file.

> **READ-ONLY SKILL:** This skill NEVER writes to `sprint-status.yaml` or any other file. It is purely a display/reporting skill.

---

## Step 1 — Load sprint-status.yaml

Read `_bmad-output/implementation-artifacts/sprint-status.yaml`.

If the file does not exist:
- Output: "No sprint-status.yaml found. Run `/bmad-sprint-planning` to initialize."
- Exit without error.

Parse all sections from the file:
- **Metadata:** `project`, `last_updated` (plus `generated`, `project_key`, `tracking_system`, `story_location` if present)
- **`epics`** — map of epic entries (keys: `epic-N`)
- **`backlog`** — array of unassigned item objects
- **`sprints`** — map of sprint entries (keys: `sprint-N`)

If the file exists but uses the old flat `development_status` schema (no `epics`/`backlog`/`sprints` sections), output:
"sprint-status.yaml uses the pre-Epic-17 schema. Run `/bmad-sprint-planning` to migrate to the unified schema."
Then exit.

---

## Step 2 — Classify Sprints

Partition the `sprints` map into three groups:
- **active** — entries where `status: active`
- **planning** — entries where `status: planning`
- **closed** — entries where `status: closed`

Sort each group by sprint key (`sprint-N`) ascending by numeric value of N.

---

## Step 3 — Render Header

Output:

```
# Sprint Status — {project}
*Last updated: {last_updated}*

---
```

---

## Step 4 — Render Active Sprints

If there are active sprints, output a `## Active Sprints` section header.

For each active sprint (sorted by key ascending):

1. Sprint header:
   ```
   ### {sprint.name}
   **Status:** active | **Capacity:** {items.length} / {capacity} | **Start:** {start or "—"} | **End:** {end or "—"}
   ```
   If `items.length > capacity`, append inline: `⚠️ over capacity by {items.length - capacity} item(s)`

2. Items table (if items array is non-empty):
   ```
   | Item | Title | Type | Status | Severity |
   |------|-------|------|--------|----------|
   | {id} | {title} | Story | {status} | — |
   | {id} | {title} | Bug   | {status} | {severity} |
   ```
   - Type column: use "Story" for `type: story`, "Bug" for `type: bug`
   - Severity column: show severity value for bugs, "—" for stories

3. If items array is empty, output: `*(No items assigned to this sprint)*`

---

## Step 5 — Render Planning Sprints

If there are planning sprints, output a `## Planning Sprints` section header.

For each planning sprint (sorted by key ascending), use the same format as active sprints (Step 4) with `status: planning`.

---

## Step 6 — Render Closed Sprint Summaries

If there are closed sprints, output a `## Closed Sprints` section header followed by a summary table:

```
| Sprint | Items | Start | End |
|--------|-------|-------|-----|
| {sprint.name} | {items.length} items (archived) | {start or "—"} | {end or "—"} |
```

Do NOT list individual items within closed sprints (collapsed view by default).

---

## Step 7 — Render Backlog

Count total backlog items: `{backlog.length}`.

Output a `## Backlog — {backlog.length} items` section header.

If backlog is empty, output: `*(No items in backlog)*`

Otherwise, output a table in array order (position = priority):

```
| # | Item | Title | Type | Status | Severity |
|---|------|-------|------|--------|----------|
| 1 | {id} | {title} | Story | {status} | — |
| 2 | {id} | {title} | Bug   | {status} | {severity} |
```

- `#` column: 1-based position in the array (= priority rank)
- Severity column: show severity for bugs, "—" for stories

---

## Step 8 — Render Epics Overview

Output a `## Epics` section header.

If the `epics` map is empty, output: `*(No epics defined)*`

Otherwise, for each epic in the map (sorted by key ascending by numeric value of N):

1. Count items referencing this epic across all sections:
   - Scan `backlog` items where `epic == N` (N = epic number, e.g., `17` for `epic-17`)
   - Scan all `sprints[*].items` where `epic == N`
   - Tally counts by status

2. Output a table (header once, one row per epic):
   ```
   | Epic | Status | Retrospective | Items (active) |
   |------|--------|---------------|----------------|
   | {epic-key} | {epic.status} | {epic.retrospective or "—"} | {total_count} total ({status_breakdown}) |
   ```
   - Status breakdown: list non-zero status counts, e.g., "2 in-progress, 1 ready-for-dev"
   - If no items reference the epic, show "0 total" (omit the parenthetical)
   - `retrospective` field: show value or "—" if null

---

## Step 9 — Render Alerts (Conditional)

Scan for alert conditions:

1. **Over-capacity sprints:** Any sprint where `items.length > capacity`
   - Alert: `Over capacity: {sprint.name} is over capacity by {items.length - capacity} item(s) ({items.length} / {capacity})`

2. **Stale in-progress items:** Items with `status: in-progress` in **active** sprints where the sprint's `start` date is more than 14 days before today's date
   - Alert: `Stale in-progress: {item.id} has been in-progress for {N} days ({sprint.name} started {start})`

3. **Empty active sprints:** Active sprints with zero items
   - Alert: `Empty active sprint: {sprint.name} is active but has no items assigned`

If NO alert conditions exist, omit this section entirely (do not output "No alerts" or any placeholder).

If alerts exist, output a `## Alerts` section header followed by a bulleted list.

---

## Notes

- All data comes exclusively from `sprint-status.yaml`. No secondary file reads.
- Empty strings in `start`/`end` fields display as "—".
- This skill is invoked on demand. It does not auto-load for every task.
- For interactive next-actions (assign items, modify sprints), use the BMAD `/sprint-status-view` workflow which adds an interactive menu.
