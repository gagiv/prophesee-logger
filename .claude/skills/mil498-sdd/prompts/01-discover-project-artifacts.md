# Step 1 — Discover Project Artifacts

Search the project for the following artifacts. Communicate in {communication_language}. Inform {user_name} which artifacts were found and which are missing.

| Priority | Artifact | Search Pattern |
|----------|----------|----------------|
| Required | Architecture | `**/architecture.md`, `**/architecture-*.md` |
| Required | Epics | `**/epics*.md`, `**/epic-*.md` |
| Required | User Stories | `**/stories/*.md`, `**/story-*.md`, `**/user-stories*.md` |
| Recommended | PRD | `**/prd.md`, `**/prd-*.md` |
| Optional | UX Designs | `**/ux-design*.md`, `**/ux-*.md` |
| Optional | Product Brief | `**/product-brief*.md` |

If **required** artifacts are missing, warn the user and ask whether to proceed with available data or stop.

## Document Dependencies

The SDD is a **per-CSCI document** that designs the internal structure of a CSCI against its requirements. It MUST be generated after the SRS (which defines what the CSCI must do) and the SSDD (which defines the CSCI boundaries).

| Predecessor | Relationship | Search Pattern |
|-------------|-------------|----------------|
| SRS (Software Requirements Specification) | **Required** — provides the CSCI requirements this SDD designs against | `**/SRS.md`, `**/SRS-*.md` |
| SSDD (System/Subsystem Design Description) | **Required** — defines CSCI boundaries, system-wide design decisions, and allocated requirements | `**/SSDD.md` |
| SSS (System/Subsystem Specification) | Optional — provides system-level requirements context | `**/SSS.md` |

If the SRS has NOT been generated yet, **alert {user_name}**: "The SRS has not been generated yet. The SDD designs the internal structure of a CSCI against the requirements defined in its SRS. Would you like to proceed without the SRS, or generate the SRS first?"

If the SSDD has NOT been generated yet, **alert {user_name}**: "The SSDD has not been generated yet. The SDD needs the SSDD to understand CSCI boundaries and system-wide design decisions. Would you like to proceed without the SSDD, or generate the SSDD first?"

If predecessor documents exist, they MUST be loaded and used as primary inputs. The SDD should reference them in Section 2 and trace design decisions to SRS requirements.

## CSCI Scoping

Ask {user_name}: **"Which CSCI is this SDD for?"**

If the SSDD exists, present the list of CSCIs defined in it and ask the user to select one. The SDD will describe the design of ONLY the selected CSCI — its internal CSCs (Computer Software Components) and software units.

If generating SDD documents for multiple CSCIs, generate them one at a time, each as a separate document.

## Source Mapping

For the selected CSCI, the agent must:
1. From the **SSDD**: Extract the CSCI's allocated system requirements, its CSCs, and the system-wide design decisions that constrain it
2. From the **SRS**: Extract all CSCI requirements (capabilities, interfaces, quality factors, constraints) — these are what the SDD must design against
3. From the **Architecture**: Extract the internal structure, technology stack, patterns, and integration approach for this CSCI's components
4. From **Epics/Stories**: Extract detailed behavioral specifications, acceptance criteria, algorithms, business rules, and processing logic that inform the detailed design (Section 5)

---

**CONFIRMATION GATE**: Present the list of discovered artifacts and the selected CSCI to the user. Wait for the user to confirm before proceeding to the next step.
