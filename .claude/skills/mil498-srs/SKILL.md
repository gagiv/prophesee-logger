---
name: mil498-srs
description: Generate MIL-STD-498 Software Requirements Specification (SRS)
type: complex-workflow
triggers:
  - "generate SRS"
  - "create software requirements specification"
---

# MIL-498: Software Requirements Specification (SRS)

> MIL-STD-498 Data Item Description: DI-IPSC-81433

## Workflow

This workflow generates a MIL-STD-498 SRS document through progressive steps.
The SRS specifies requirements for a single CSCI (Computer Software Configuration Item).

### Steps

1. [Discover Project Artifacts](prompts/01-discover-project-artifacts.md)
2. [Load Template](prompts/02-load-template.md)
3. [Generate Document](prompts/03-generate-document.md)
4. [Validate](prompts/04-validate.md)
5. [Review](prompts/05-review.md)
6. [Save](prompts/06-save.md)

### Template

Output template: [template.md](template.md)
