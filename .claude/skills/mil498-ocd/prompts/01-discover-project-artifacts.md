# Step 1 — Discover Project Artifacts

Search the project for the following artifacts. Communicate in {communication_language}. Inform {user_name} which artifacts were found and which are missing.

| Priority | Artifact | Search Pattern |
|----------|----------|----------------|
| Required | PRD | `**/prd.md`, `**/prd-*.md` |
| Recommended | Architecture | `**/architecture.md`, `**/architecture-*.md` |
| Recommended | UX Designs | `**/ux-design*.md`, `**/ux-*.md` |
| Optional | Product Brief | `**/product-brief*.md` |
| Optional | Epics & Stories | `**/epics*.md`, `**/stories/*.md` |

If the **PRD** is missing, warn the user and ask whether to proceed with available data or stop.

## Document Dependencies

The OCD is the **first document** in the MIL-STD-498 generation chain. It has no MIL-STD-498 predecessor documents — it draws from project artifacts (PRD, Product Brief, UX Designs) only.

**Note**: The OCD feeds into the SSS and other downstream documents. Ensure the operational scenarios and user descriptions are thorough, as they will be referenced by:
- **SSS** — for deriving system requirements from operational needs
- **SSDD** — for understanding operational context behind design decisions
- **SDP** — for understanding the operational environment

---

**CONFIRMATION GATE**: Present the list of discovered artifacts to the user. Wait for the user to confirm before proceeding to the next step.
