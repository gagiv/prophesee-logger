# Step 1 — Discover Project Artifacts

Search the project for the following artifacts. Communicate in {communication_language}. Inform {user_name} which artifacts were found and which are missing.

| Priority | Artifact | Search Pattern |
|----------|----------|----------------|
| Required | Product Brief | `**/product-brief*.md` |
| Required | PRD | `**/prd.md`, `**/prd-*.md` |
| Recommended | Architecture | `**/architecture.md`, `**/architecture-*.md` |
| Recommended | Project Context | `**/project-context.md` |
| Optional | Sprint Status | `**/sprint-status*.yaml`, `**/sprint-status*.md` |
| Optional | Epics | `**/epics*.md` |

If **required** artifacts are missing, warn the user and ask whether to proceed with available data or stop.

## Document Dependencies

The SDP describes how the software will be developed. It benefits from knowing the system architecture (SSDD) and what documents are planned for each CSCI.

| Predecessor | Relationship | Search Pattern |
|-------------|-------------|----------------|
| SSDD (System/Subsystem Design Description) | Recommended — provides system architecture, CSCI decomposition, and specification tree | `**/SSDD.md` |
| SSS (System/Subsystem Specification) | Optional — provides system requirements context | `**/SSS.md` |
| OCD (Operational Concept Description) | Optional — provides operational context | `**/OCD.md` |

If the SSDD exists, it MUST be loaded — the SDP should reference the CSCI decomposition when describing plans for CSCI-level activities (Section 5), and the specification tree (SSDD 4.1.f) informs Section 3.b (documentation requirements).

If the SSDD has NOT been generated yet, **inform {user_name}**: "The SSDD has not been generated yet. The SDP benefits from the system architecture and CSCI decomposition in the SSDD. Would you like to proceed without it, or generate the SSDD first?"

---

**CONFIRMATION GATE**: Present the list of discovered artifacts to the user. Wait for the user to confirm before proceeding to the next step.
