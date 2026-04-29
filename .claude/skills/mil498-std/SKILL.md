---
name: mil498-std
description: Generate MIL-STD-498 Software Test Description (STD)
type: complex-workflow
triggers:
  - "generate STD"
  - "create software test description"
---

# MIL-498: Software Test Description (STD)

> MIL-STD-498 Data Item Description: DI-IPSC-81439

## Workflow

This workflow generates a MIL-STD-498 STD document through progressive steps.
The STD defines the test preparations, test cases, and test procedures for software qualification testing.

### Steps

1. [Discover Project Artifacts](prompts/01-discover-project-artifacts.md)
2. [Load Template](prompts/02-load-template.md)
3. [Generate Document](prompts/03-generate-document.md)
4. [Validate](prompts/04-validate.md)
5. [Review](prompts/05-review.md)
6. [Save](prompts/06-save.md)

### Template

Output template: [template.md](template.md)
