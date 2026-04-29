<!-- MA-AGENTS-START -->
# AI Agent Skills - Planning Instruction

You have access to a library of skills in your skills directory. Before starting any task:

1. Read the skill manifest at .claude/skills/MANIFEST.yaml
2. Based on the task description, select which skills are relevant
3. Read only the selected skill files
4. Then proceed with the task

Always load skills marked with always_load: true.
Do not load skills that are not relevant to the current task.

## Respond in TEXT vs. create FILES

Choose your response medium deliberately. Defaulting to file creation when the user asked a question is a common failure mode — especially for coding agents running in web UIs.

- **Create or modify FILES when the user's request contains file-action keywords:** `create`, `write`, `generate`, `build`, `implement` (and obvious synonyms such as `add`, `produce`, `refactor`, `fix`, `update <file>`). These signal a concrete artifact is expected.
- **Respond in TEXT when the request contains text-response keywords:** `what do you think`, `how should we`, `discuss`, `opinion` (and obvious synonyms such as `explain`, `why`, `should I`, `compare`, `recommend`). These signal that a conversation is expected, not a deliverable.
- **If unsure, respond in TEXT.** A text answer can always be followed by file creation on confirmation; an unwanted file cannot be cleanly undone.
- **Never create `response.md`, `output.md`, or any similarly named scratch file as a reply.** A reply belongs in the chat transcript, not on disk.
- **Confirm file paths before writing.** When you are about to create or modify a file whose path the user has not explicitly named, state the intended path in text and wait for confirmation, unless the path is unambiguous from the task context.

## BMAD phase discipline

BMAD-METHOD organizes work into declared phases (analysis, planning, architecture, story-creation, implementation, review). Respect the currently declared phase.

- **Do not skip ahead to implementation during planning.** If the project is in a planning phase — or the user has asked for requirements, architecture, or a story — produce planning artifacts, not code.
- **Do not retroactively plan after you have already coded.** If implementation has already started, flag the gap instead of fabricating back-dated planning documents.
- The declared phase is established by the active skill, the story status, or an explicit statement from the user. When none of these is available, ask before assuming.
<!-- MA-AGENTS-END -->
