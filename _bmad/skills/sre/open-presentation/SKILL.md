---
name: Open Presentation
description: Opens the BMAD-METHOD AI Development Training presentation from _bmad-output/methodology/
---
# Open Presentation Skill

## Description
Opens the BMAD-METHOD AI Development Training presentation installed at `_bmad-output/methodology/`.

## Usage
Invoke this skill by typing `/open-presentation`.

## Instructions

When the user invokes `/open-presentation`:

1. **Locate the presentation** at `_bmad-output/methodology/BMAD_AI_Development_Training.pptx` relative to the project root.

2. **Open it** using the OS default viewer via the Bash tool:
   - **Windows**: `start "" "_bmad-output/methodology/BMAD_AI_Development_Training.pptx"`
   - **macOS**: `open "_bmad-output/methodology/BMAD_AI_Development_Training.pptx"`
   - **Linux**: `xdg-open "_bmad-output/methodology/BMAD_AI_Development_Training.pptx"`

3. **If the file does not exist**, inform the user:
   > "The methodology presentation has not been installed yet. Run `npx ma-agents install` with BMAD to deploy it to `_bmad-output/methodology/`."

4. **Detect the OS** using the Node.js `process.platform` convention or by checking which command is available, then run the appropriate open command.

## Examples

**User**: `/open-presentation`
**Assistant**: Opens `_bmad-output/methodology/BMAD_AI_Development_Training.pptx` in the system default PowerPoint viewer.

**User**: "open the methodology slides"
**Assistant**: [Treats this as /open-presentation and follows the instructions above]
