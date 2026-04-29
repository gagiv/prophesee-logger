# Step 1 — Discover Project Artifacts

Search the project for the following artifacts. Communicate in {communication_language}. Inform {user_name} which artifacts were found and which are missing.

| Priority | Artifact | Search Pattern |
|----------|----------|----------------|
| Required | PRD | `**/prd.md`, `**/prd-*.md` |
| Required | Architecture | `**/architecture.md`, `**/architecture-*.md` |
| Recommended | Product Brief | `**/product-brief*.md` |
| Recommended | SSS | `**/SSS.md` |
| Optional | UX Designs | `**/ux-design*.md`, `**/ux-*.md` |
| Optional | Epics | `**/epics*.md`, `**/epic-*.md` |
| Optional | Any client documentation | Ask {user_name} if there are additional documents to consider |

If **required** artifacts are missing, warn the user and ask whether to proceed with available data or stop.

## Document Dependencies

The SSDD is best generated after the following MIL-STD-498 predecessor documents:

| Predecessor | Relationship | Search Pattern |
|-------------|-------------|----------------|
| SSS (System/Subsystem Specification) | Recommended — provides the system requirements the SSDD designs against | `**/SSS.md` |
| OCD (Operational Concept Description) | Optional — provides operational context | `**/OCD.md` |

If predecessor documents exist, they MUST be loaded and used as primary inputs. The SSDD should reference them in Section 2 and trace design decisions to their requirements.

If recommended predecessors have NOT been generated yet, **alert {user_name}**: "The SSS has not been generated yet. The SSDD is typically produced after the SSS, since it designs against system requirements defined there. Would you like to proceed without it, or generate the SSS first?"

---

**CONFIRMATION GATE**: Present the list of discovered artifacts to the user. Wait for the user to confirm before proceeding to the next step.
