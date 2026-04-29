---
name: mil498-sdp
description: Generate MIL-STD-498 Software Development Plan (SDP)
type: complex-workflow
triggers:
  - "generate SDP"
  - "create software development plan"
---

# MIL-498: Software Development Plan (SDP)

> MIL-STD-498 Data Item Description: DI-IPSC-81427

## Workflow

This workflow generates a MIL-STD-498 SDP document through progressive steps.
The SDP describes how the software will be developed, including processes, methods, standards, and management plans.

### Steps

1. [Discover Project Artifacts](prompts/01-discover-project-artifacts.md)
2. [Load Template](prompts/02-load-template.md)
3. [Generate Document](prompts/03-generate-document.md)
4. [Validate](prompts/04-validate.md)
5. [Review](prompts/05-review.md)
6. [Save](prompts/06-save.md)

### Template

Output template: [template.md](template.md)
