# Step 1 — Discover Project Artifacts

Search the project for the following artifacts. Communicate in {communication_language}. Inform {user_name} which artifacts were found and which are missing.

| Priority | Artifact | Search Pattern |
|----------|----------|----------------|
| Required | Product Brief | `**/product-brief*.md` |
| Required | PRD | `**/prd.md`, `**/prd-*.md` |
| Recommended | Architecture | `**/architecture.md`, `**/architecture-*.md` |
| Optional | OCD | `**/OCD.md` |
| Optional | UX Designs | `**/ux-design*.md` |

If **required** artifacts are missing, warn the user and ask whether to proceed with available data or stop.

## Document Dependencies

The SSS is typically one of the earliest MIL-STD-498 documents generated, after the OCD. It defines system-level requirements that downstream documents (SSDD, SRS) will design against and trace to.

| Predecessor | Relationship | Search Pattern |
|-------------|-------------|----------------|
| OCD (Operational Concept Description) | Recommended — provides operational context and user needs | `**/OCD.md` |

If the OCD has been generated, it MUST be loaded and used as an input — particularly for deriving capability requirements (3.2) and understanding operational scenarios.

If the OCD has NOT been generated yet, **inform {user_name}**: "The OCD has not been generated yet. The SSS benefits from the operational context in the OCD. Would you like to proceed without it, or generate the OCD first?"

**Note**: The SSS feeds into the SSDD, SRS, and STD. Ensure requirements are written to be traceable — each requirement needs a unique identifier that downstream documents can reference.

---

**CONFIRMATION GATE**: Present the list of discovered artifacts to the user. Wait for the user to confirm before proceeding to the next step.
