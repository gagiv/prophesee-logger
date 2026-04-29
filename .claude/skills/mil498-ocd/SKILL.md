---
name: mil498-ocd
description: Generate MIL-STD-498 Operational Concept Description (OCD)
type: complex-workflow
triggers:
  - "generate OCD"
  - "create operational concept description"
---

# MIL-498: Operational Concept Description (OCD)

> MIL-STD-498 Data Item Description: DI-IPSC-81430

## Workflow

This workflow generates a MIL-STD-498 OCD document through progressive steps.
The OCD describes the system from the user's and stakeholder's perspective, extracting operational concepts from existing project artifacts.

### Steps

1. [Discover Project Artifacts](prompts/01-discover-project-artifacts.md)
2. [Load Template](prompts/02-load-template.md)
3. [Generate Document](prompts/03-generate-document.md)
4. [Validate](prompts/04-validate.md)
5. [Review](prompts/05-review.md)
6. [Save](prompts/06-save.md)

### Template

Output template: [template.md](template.md)
