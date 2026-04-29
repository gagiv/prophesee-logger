# Step 1 — Discover Project Artifacts

Search the project for the following artifacts. Communicate in {communication_language}. Inform {user_name} which artifacts were found and which are missing.

| Priority | Artifact | Search Pattern |
|----------|----------|----------------|
| Required | PRD | `**/prd.md`, `**/prd-*.md` |
| Required | Architecture | `**/architecture.md`, `**/architecture-*.md` |
| Recommended | UX Designs | `**/ux-design*.md`, `**/ux-*.md` |
| Recommended | Epics | `**/epics*.md`, `**/epic-*.md` |
| Optional | Product Brief | `**/product-brief*.md` |
| Optional | Existing SRS | `**/SRS.md` |

If **required** artifacts are missing, warn the user and ask whether to proceed with available data or stop.

If an existing SRS is found, ask the user whether to update it or generate from scratch.

## Document Dependencies

The SRS is a **per-CSCI document** — it specifies requirements for one Computer Software Configuration Item. It MUST be generated after the SSDD, which defines the CSCI decomposition and allocates system requirements to each CSCI.

| Predecessor | Relationship | Search Pattern |
|-------------|-------------|----------------|
| SSDD (System/Subsystem Design Description) | **Required** — defines CSCIs and allocates system requirements | `**/SSDD.md` |
| SSS (System/Subsystem Specification) | Recommended — provides system requirements to trace to | `**/SSS.md` |
| OCD (Operational Concept Description) | Optional — provides operational context | `**/OCD.md` |

If the SSDD has NOT been generated yet, **alert {user_name}**: "The SSDD has not been generated yet. The SRS requires the SSDD to know which CSCI this specification covers and which system requirements are allocated to it. Would you like to proceed without the SSDD, or generate the SSDD first?"

If predecessor documents exist, they MUST be loaded and used as primary inputs. The SRS should reference them in Section 2 and trace requirements to the SSDD's allocation.

## CSCI Scoping

Ask {user_name}: **"Which CSCI is this SRS for?"**

If the SSDD exists, present the list of CSCIs defined in it and ask the user to select one. Only requirements allocated to the selected CSCI (per SSDD Section 4.1 and 5) should be included in this SRS.

If generating SRS documents for multiple CSCIs, generate them one at a time, each as a separate document.

---

**CONFIRMATION GATE**: Present the list of discovered artifacts and the selected CSCI to the user. Wait for the user to confirm before proceeding to the next step.
