---
name: mil498-ssdd
description: Generate MIL-STD-498 System/Subsystem Design Description (SSDD)
type: complex-workflow
triggers:
  - "generate SSDD"
  - "create system design description"
  - "create subsystem design description"
---

# MIL-498: System/Subsystem Design Description (SSDD)

> MIL-STD-498 Data Item Description: DI-IPSC-81432

## Workflow

This workflow generates a MIL-STD-498 SSDD document through progressive steps.
The SSDD describes the system-level design — how the system is organized into components (HWCIs, CSCIs, and manual operations) and how they interact.

### Steps

1. [Discover Project Artifacts](prompts/01-discover-project-artifacts.md)
2. [Load Template](prompts/02-load-template.md)
3. [CSCI Discovery Interview](prompts/03-csci-discovery-interview.md)
4. [Generate Document](prompts/04-generate-document.md)
5. [Validate](prompts/05-validate.md)
6. [Review](prompts/06-review.md)
7. [Save](prompts/07-save.md)

### Template

Output template: [template.md](template.md)
