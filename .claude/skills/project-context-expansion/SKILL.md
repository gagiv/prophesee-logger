---
name: project-context-expansion
description: Post-retrospective workflow to update project-context.md with discovered patterns and conventions
type: skill
triggers:
  - "project context expansion"
  - "expand project context"
---

# Project Context Expansion Workflow

Post-retrospective companion workflow to update `_bmad-output/project-context.md` with
patterns and conventions discovered during the sprint.

Run this workflow at the end of `/bmad-retrospective` to close the living document lifecycle loop.
The agent proposes additions; the human decides what gets written.

<workflow>

<step n="1" goal="Check whether project-context.md exists">

  <action>Check if `_bmad-output/project-context.md` exists in the project root</action>

  <check if="file does NOT exist">
    <output>
ℹ️ **No project-context.md found.**

`_bmad-output/project-context.md` does not exist in this project yet.

To create it, either:
- Run `npx ma-agents install` at the project level (auto-generates on first install)
- Run `/bmad-generate-project-context` to create it manually

Skipping project-context expansion — nothing to update.
    </output>
    <action>Exit workflow</action>
  </check>

  <check if="file exists">
    <output>
✅ Found `_bmad-output/project-context.md` — proceeding with expansion review.
    </output>
  </check>

</step>

<step n="2" goal="Read and present the current Project-Specific Rules section">

  <action>Read the complete contents of `_bmad-output/project-context.md`</action>

  <action>Extract the `## Project-Specific Rules` section:
    - Find the line starting with `## Project-Specific Rules`
    - Read all content until the next `##` section header (or end of file)
    - Store as {{current_rules_content}}
  </action>

  <check if="{{current_rules_content}} contains only the TODO comment or is effectively empty">
    <action>Set {{rules_are_empty}} = true</action>
  </check>

  <check if="{{current_rules_content}} contains substantive rules">
    <action>Set {{rules_are_empty}} = false</action>
  </check>

  <output>
## Current Project-Specific Rules

{{current_rules_content}}

---

I will now review the retrospective discussion to propose additions to this section.
  </output>

</step>

<step n="3" goal="Gather sprint patterns — from retrospective context or user input">

  <action>Check whether there is active retrospective context in this session (i.e., this workflow
  was invoked immediately after running /bmad-retrospective and discussion content is available).
  </action>

  <check if="retrospective context IS present in this session">
    <action>Use the retrospective discussion to identify patterns, conventions, and lessons.
    Skip the user prompt below — proceed directly to the proposal step.
    </action>
  </check>

  <check if="retrospective context is NOT present (workflow invoked cold or standalone)">
    <output>
ℹ️ **No retrospective session detected in this context.**

This workflow is designed to run after `/bmad-retrospective`, but it can also be used
standalone to capture any conventions or patterns you've observed.
    </output>
    <ask>
Briefly describe the patterns or conventions you want to add to Project-Specific Rules.
For example: "agents kept omitting error handling in async functions" or
"we decided all PRs need a test-plan section in the description".

You can also just say "run retrospective first" to cancel.
    </ask>
    <check if="user says 'run retrospective first' or equivalent cancel">
      <output>
ℹ️ To get the most value, run `/bmad-retrospective` first, then invoke `/project-context-expansion`
at the end of that session. No changes made.
      </output>
      <action>Exit workflow</action>
    </check>
    <action>Store the user-described patterns as {{sprint_patterns}} and use them as the source
    material for the proposal in the next action below.
    </action>
  </check>

  <action>Based on the retrospective discussion OR user-described patterns, identify items that
  should become standing rules for AI agents — specifically:
    - Coding conventions agents got wrong or needed correction on during the sprint
    - Patterns agents should consistently apply in this project
    - Architectural decisions that agents must respect (and that are not obvious from the code)
    - Testing or review conventions specific to this project
    - Gotchas or anti-patterns agents kept producing that should be explicitly prohibited
    - Workflow or communication rules specific to this team's practices
  </action>

  <action>Filter OUT anything that belongs in other sections:
    - Technology Stack updates → belongs in `## Technology Stack` (use `/bmad-generate-project-context`)
    - Mandatory pre-task rules → belongs in `## AI Agent Mandatory Rules` (set at install time)
    - Do NOT propose changes to any section other than `## Project-Specific Rules`
  </action>

  <check if="no relevant patterns found from retrospective">
    <output>
ℹ️ **No new rules to propose.**

Based on the retrospective discussion, no patterns were identified that would add value
as standing rules in `## Project-Specific Rules`. The section is already up to date.

If you noticed patterns the agents got wrong, you can manually edit
`_bmad-output/project-context.md` to add your own rules at any time.
    </output>
    <action>Exit workflow</action>
  </check>

  <action>Draft proposed additions as clear, imperative rules:
    - Each rule is a single actionable statement (e.g., "Always use X when Y")
    - Rules are specific enough to change agent behavior, not vague principles
    - Each rule is distinct — no overlap with existing rules
    - Store as {{proposed_additions}}
  </action>

  <output>
## Proposed Additions to Project-Specific Rules

Based on patterns from this sprint's retrospective, here are the additions I recommend:

{{proposed_additions}}

---

**Review these carefully.** These additions will be appended to `## Project-Specific Rules`
in `_bmad-output/project-context.md` and will govern all future AI agent sessions.
  </output>

</step>

<step n="4" goal="Human review and confirmation gate">

  <ask>
Review the proposed additions above.

Options:
- **[y] Accept all** — append all proposed additions as shown
- **[n] Reject all** — skip without any changes
- **[e] Edit** — describe which rules to add, remove, or reword before writing
  </ask>

  <check if="user selects 'n'">
    <output>
❌ **Expansion skipped.** No changes were made to `_bmad-output/project-context.md`.
    </output>
    <action>Exit workflow</action>
  </check>

  <check if="user selects 'e'">
    <ask>Describe your edits — which rules to keep, drop, or reword:</ask>
    <action>Apply user edits to {{proposed_additions}}</action>
    <action>Re-display the revised proposal</action>
    <ask>Proceed with this revised version? [y] Yes / [n] Cancel:</ask>
    <check if="user selects 'n'">
      <output>
❌ **Expansion cancelled.** No changes were made to `_bmad-output/project-context.md`.
      </output>
      <action>Exit workflow</action>
    </check>
  </check>

</step>

<step n="5" goal="Write approved additions to Project-Specific Rules only">

  <action>Read the current full contents of `_bmad-output/project-context.md` again (to ensure freshness)</action>

  <action>Locate the `## Project-Specific Rules` section:
    - Find the line starting with `## Project-Specific Rules`
    - Identify the end of the section (next `##` header or end of file)
    - Preserve all existing content in the section — do NOT remove or reorder existing rules
  </action>

  <action>Append the approved additions at the END of the `## Project-Specific Rules` section,
  before the next `##` header. Insert a blank line separator if the section is not empty.
  </action>

  <action>CRITICAL CONSTRAINTS — do NOT touch any other section:
    - Do NOT modify `## AI Agent Mandatory Rules`
    - Do NOT modify `## Technology Stack`
    - Do NOT modify any other section
    - Do NOT reformat or reorganize the file
    - Only append to `## Project-Specific Rules`
  </action>

  <action>Save the updated `_bmad-output/project-context.md`</action>

  <output>
✅ **Project-Specific Rules updated successfully!**

- **File:** `_bmad-output/project-context.md`
- **Rules added:** {{count_of_added_rules}}

The new rules will be active in all AI agent sessions that load `project-context.md`
via `critical_actions` (all BMAD agents load it automatically on activation).

**Next:** Commit `_bmad-output/project-context.md` to version control so the rules
are shared across the team and persist across sessions.
  </output>

</step>

</workflow>
