---
name: mil498-sss
description: Generate MIL-STD-498 System/Subsystem Specification (SSS)
type: complex-workflow
triggers:
  - "generate SSS"
  - "create system specification"
  - "create subsystem specification"
---

# MIL-498: System/Subsystem Specification (SSS)

> MIL-STD-498 Data Item Description: DI-IPSC-81431

## Workflow

This workflow generates a MIL-STD-498 SSS document through progressive steps.
The SSS specifies requirements at the system or subsystem level, not at the software (CSCI) level.

### Steps

1. [Discover Project Artifacts](prompts/01-discover-project-artifacts.md)
2. [Load Template](prompts/02-load-template.md)
3. [Generate Document](prompts/03-generate-document.md)
4. [Validate](prompts/04-validate.md)
5. [Review](prompts/05-review.md)
6. [Save](prompts/06-save.md)

### Template

Output template: [template.md](template.md)
