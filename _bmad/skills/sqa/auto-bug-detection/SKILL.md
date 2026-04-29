---
name: auto-bug-detection
description: Instructs agents to identify and report defects in already-delivered code
---
# Auto Bug Detection

Proactively identify and report defects found in already-delivered code during all agent sessions.

## Purpose

When you encounter code that has already been delivered (story/task marked done), you must scan for defects
and report them using the structured format below. Do not silently ignore bugs in delivered code.

## Detection Scope

### Delivered Code (MUST scan and report bugs)

- Code whose associated story/task is marked **done** or **completed**, regardless of branch.
- Committed code on `main` or release branches.
- Committed code on feature branches whose **parent story is completed**.

### Work-in-Progress (DO NOT flag as bugs)

- Uncommitted changes in the working tree.
- Committed code on a branch whose associated story is still **in-progress** or **not-started**.
- `TODO` / `FIXME` markers in code added as part of the **current story under review**.
- Incomplete implementations explicitly tied to an active story.

### Ambiguous Boundary — Feature Branches

Committed code on a feature branch where the story status is **unknown** must be treated as WIP.

To resolve the status, use the `story-status-lookup` skill — it defines how to identify the story slug,
which file to read, and how to map status values to delivered vs WIP. Follow its fallback rule:
when status cannot be determined, **default to WIP and do NOT flag as a bug**.

---

## Detection Criteria

Scan delivered code for the following categories of defects. Each category includes examples of what qualifies.

### 1. Logic Errors

Incorrect computational logic, wrong conditionals, or inverted boolean expressions that cause the code
to produce incorrect results.

**Examples:**
- Using `>` instead of `>=` in a boundary check, silently excluding a valid edge value.
- An accumulator initialized to `1` instead of `0`, skewing totals.
- A loop that iterates one too many or one too few times (off-by-one error).

### 2. Unhandled Edge Cases

Inputs or states that the code does not handle, leading to incorrect behavior or crashes.

**Examples:**
- A function that accepts a list but does not handle an empty list, throwing an index error.
- A parser that crashes on a valid but empty string input.
- Division without a zero-check on the divisor.

### 3. Missing Error Handling

Absence of error handling for operations that can fail, causing unhandled exceptions or silent failures.

**Examples:**
- File I/O calls with no try/catch, crashing the process on a missing file.
- Network requests with no timeout or error callback.
- A database query whose rejection is swallowed without logging or recovery.

### 4. Broken Contracts

Code that violates the API contract it published: wrong return types, missing required fields in
responses, or side effects not documented in the interface.

**Examples:**
- A function documented to return `string | null` but sometimes returns `undefined`.
- A REST endpoint returning HTTP 200 for a failed operation instead of the correct 4xx/5xx code.
- A class method mutating shared state that is not documented as a side effect.

### 5. Regressions

Previously working behavior that is now broken, typically introduced by a change in a related component.

**Examples:**
- A utility function refactored to accept a new parameter that broke all existing callers that pass no argument.
- A config key renamed in one place but not updated in all consumers, causing silent runtime failures.
- A test that was green before a dependency upgrade and now fails due to an incompatible API change.

### 6. Security Vulnerabilities

Code patterns that introduce exploitable security weaknesses in existing, delivered functionality.

**Examples:**
- User-supplied input passed directly into a shell command without sanitization (command injection).
- Secrets or API keys hard-coded in source files committed to the repository.
- SQL queries constructed via string concatenation with unsanitized user input (SQL injection).
- Sensitive data (passwords, tokens) logged at INFO level in production code.

---

## Reporting Format

When a defect is detected in delivered code, report it using this structured template:

```
## Bug Report

**Title:** [Short, descriptive title]
**Severity:** [critical | high | medium | low]
**Category:** [logic-error | unhandled-edge-case | missing-error-handling | broken-contract | regression | security-vulnerability]
**Affected Component:** [Module, file, or system area]

**Reproduction Steps:**
1. [Step 1]
2. [Step 2]

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happens]

**Affected Files:**
- path/to/file.ext (line N)
```

**Severity Guidelines:**
- `critical` — Data loss, security breach, or system crash in normal usage.
- `high` — Core feature broken or serious security risk; blocks users.
- `medium` — Feature partially broken or degraded; workaround exists.
- `low` — Minor issue, cosmetic defect, or edge case with minimal user impact.

---

## What NOT to Flag

Do **not** report the following as bugs:

- **Work-in-progress code** — Uncommitted changes or code on a branch with an active story.
- **TODO / FIXME comments** in code added as part of the **current story** being reviewed.
- **Incomplete implementations** explicitly tied to an active or not-yet-started story.
- **Style preferences** — Naming conventions, formatting, or architectural opinions not related to correctness.
- **Speculative issues** — Theoretical attack scenarios or failure modes with no demonstrable code path in the current codebase (e.g., an attack vector that requires filesystem access the process can never obtain).

---

## Required Action on Detection

The required action depends on severity:

### critical or high severity

**Immediately run `/create-bug-story`** without waiting for user confirmation. These defects represent
broken core functionality or security risks that must not be left untracked. Inform the user as you act:

> "I found a **[severity]** bug in delivered code — running `create-bug-story` now to ensure it is tracked."

Do not ask permission. Do not proceed with other tasks until the bug story is created.

### medium or low severity

**Recommend** that the user create a formal bug story, but do not act without their confirmation:

> "I found a **[severity]** bug in delivered code. Would you like me to run `create-bug-story` to log it
> formally so it can be scheduled in the sprint?"

If the user declines or does not respond, note the finding in your response and continue. The bug report
remains visible in the conversation but is not written to a file.
