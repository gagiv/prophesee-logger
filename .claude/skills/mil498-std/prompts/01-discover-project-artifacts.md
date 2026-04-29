# Step 1 — Discover Project Artifacts

Search the project for the following artifacts. Communicate in {communication_language}. Inform {user_name} which artifacts were found and which are missing.

| Priority | Artifact | Search Pattern |
|----------|----------|----------------|
| Required | Epics & Stories | `**/epics*.md`, `**/epic-*.md`, `**/stories/*.md` |
| Required | Architecture | `**/architecture.md`, `**/architecture-*.md` |
| Recommended | SRS | `**/SRS.md` |
| Recommended | PRD | `**/prd.md`, `**/prd-*.md` |
| Optional | Existing test files | `**/test/**`, `**/tests/**`, `**/__tests__/**`, `**/*.test.*`, `**/*.spec.*` |

If **required** artifacts are missing, warn the user and ask whether to proceed with available data or stop.

## Document Dependencies

The STD defines test descriptions that verify requirements specified in the SRS. It should be generated after both the SSDD and the SRS for the CSCI being tested.

| Predecessor | Relationship | Search Pattern |
|-------------|-------------|----------------|
| SRS (Software Requirements Specification) | **Required** — provides the requirements that tests must verify | `**/SRS.md`, `**/SRS-*.md` |
| SSDD (System/Subsystem Design Description) | **Required** — provides system context and CSCI decomposition | `**/SSDD.md` |
| SDD (Software Design Description) | Recommended — provides design details useful for test planning | `**/SDD.md`, `**/SDD-*.md` |

If the SRS has NOT been generated yet, **alert {user_name}**: "The SRS has not been generated yet. The STD needs the SRS to know which requirements must be verified by tests. Would you like to proceed without the SRS, or generate the SRS first?"

If the SSDD has NOT been generated yet, **alert {user_name}**: "The SSDD has not been generated yet. The STD benefits from the system design context in the SSDD. Would you like to proceed without it, or generate the SSDD first?"

If predecessor documents exist, they MUST be loaded and used as primary inputs. Test cases MUST trace back to specific SRS requirements.

## CSCI/System Scoping

Ask {user_name}: **"Is this STD for CSCI-level testing or system-level testing? If CSCI-level, which CSCI?"**

- For CSCI-level testing: requirements come from the CSCI's SRS
- For system-level testing: requirements come from the SSS

If the SSDD exists, present the list of CSCIs and ask the user to select scope.

---

**CONFIRMATION GATE**: Present the list of discovered artifacts and the selected test scope to the user. Wait for the user to confirm before proceeding to the next step.
