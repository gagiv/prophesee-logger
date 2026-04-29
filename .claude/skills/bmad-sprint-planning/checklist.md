# Sprint Planning Validation Checklist

## Core Validation — Unified Three-Section Schema

### File Structure

- [ ] File is valid YAML syntax
- [ ] Exactly 6 metadata fields present: `generated`, `last_updated`, `project`, `project_key`, `tracking_system`, `story_location`
- [ ] Exactly 3 data sections: `epics` (map), `backlog` (array), `sprints` (map)
- [ ] No `development_status` section present (old flat format must not appear)

### Epics Section Validation

- [ ] Every epic found in `epics.md` (or sharded epic files) has a corresponding entry in the `epics` section
- [ ] Every epic entry has both `status` and `retrospective` fields
- [ ] All epic `status` values are legal: `backlog`, `in-progress`, `done`, `on-hold`, `cancelled`
- [ ] All epic `retrospective` values are legal: `optional`, `done`, or `null`
- [ ] Epic keys follow the pattern `epic-N` (e.g., `epic-1`, `epic-17`)
- [ ] Epic statuses were not downgraded from existing values (never-downgrade rule applied)

### Backlog Section Validation

- [ ] Every story in `epics.md` appears in exactly one location: `backlog` array, a sprint's `items` array, or `done/` folder
- [ ] No item ID appears in more than one active location (single-location invariant)
- [ ] Every backlog item has all 7 required fields: `id`, `type`, `epic`, `title`, `priority`, `status`, `severity`
- [ ] `type` is either `story` or `bug` for every item
- [ ] `severity` is `null` for all story items
- [ ] Bug items have a non-null `severity` value (`critical`, `high`, `medium`, or `low`)
- [ ] All item `status` values are legal: `backlog`, `ready-for-dev`, `in-progress`, `review`, `done`, `on-hold`, `cancelled`
- [ ] Backlog `priority` values are sequential integers starting at 1 (position 0 = `priority: 1`)
- [ ] `priority` field values match array position (array[0].priority == 1, array[1].priority == 2, etc.)
- [ ] Done items (in `done/` folder) are NOT present in the backlog array
- [ ] Existing backlog items are preserved unchanged (refresh mode: status, priority, all fields preserved)
- [ ] New items are appended at the end of the backlog (refresh mode)

### Sprints Section Validation

- [ ] `sprints` section is present (may be empty map `{}`)
- [ ] Sprint keys follow the pattern `sprint-N`
- [ ] Every sprint entry has all 6 required fields: `name`, `status`, `capacity`, `start`, `end`, `items`
- [ ] Sprint items do NOT have a `priority` field (priority is backlog-only)
- [ ] At most one sprint has `status: active`
- [ ] Sprints section is unchanged from existing file (refresh mode — this skill does NOT modify sprints)

### Metadata Validation

- [ ] `generated` timestamp is present and in ISO-8601 format
- [ ] `last_updated` timestamp is present and set to current time
- [ ] `generated` timestamp is unchanged from existing file (refresh mode — never overwritten)
- [ ] `project` matches `project_name` from config
- [ ] `project_key` is set (default: `NOKEY`)
- [ ] `tracking_system` is `file-system` (or a valid alternative)
- [ ] `story_location` matches `implementation_artifacts` path from config

### Parsing Verification

Compare epic files against generated sprint-status.yaml epics section:

```
Epic Files Contains:                Sprint Status epics Contains:
✓ Epic 1: Some Feature              ✓ epic-1: {status: backlog, retrospective: optional}
  ✓ Story 1.1: User Auth              ✓ 1-1-user-auth in backlog or sprint or done/
  ✓ Story 1.2: Account Mgmt           ✓ 1-2-account-mgmt in backlog or sprint or done/
✓ Epic 2: Another Feature           ✓ epic-2: {status: backlog, retrospective: optional}
  ✓ Story 2.1: Personality Model      ✓ 2-1-personality-model in backlog or sprint or done/
```

Note: Unlike the old format, each epic does NOT have a separate retrospective key — retrospective is a field on the epic entry.

### Final Count Check

- [ ] Total count of epics in `epics` section matches count in epic files
- [ ] Total count of stories in `backlog` + all sprints + `done/` folder matches count in epic files
- [ ] Total count of bugs in `backlog` + all sprints + `done/` folder matches count of `bug-*.md` files
