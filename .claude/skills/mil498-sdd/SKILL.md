---
name: mil498-sdd
description: Generate MIL-STD-498 Software Design Description (SDD)
type: complex-workflow
triggers:
  - "generate SDD"
  - "create software design description"
---

# MIL-498: Software Design Description (SDD)

> MIL-STD-498 Data Item Description: DI-IPSC-81435

## Workflow

This workflow generates a MIL-STD-498 SDD document through progressive steps.
The SDD describes the design of a single CSCI — its internal architecture, components (CSCs), interfaces, and detailed unit design.

### Steps

1. [Discover Project Artifacts](prompts/01-discover-project-artifacts.md)
2. [Load Template](prompts/02-load-template.md)
3. [Generate Document](prompts/03-generate-document.md)
4. [Validate](prompts/04-validate.md)
5. [Review](prompts/05-review.md)
6. [Save](prompts/06-save.md)

### Template

Output template: [template.md](template.md)
