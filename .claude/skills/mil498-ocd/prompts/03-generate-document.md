# Step 3 — Generate Document

Write the document in {document_output_language}, populating each template section. The OCD should be written in language accessible to users and stakeholders, minimizing technical jargon.

## Revision History

Before writing any content, add a **Revision History table** immediately after the document title. If this is a new document, create the table with version `1.0`. If updating an existing document, read the existing revision history and add a new row with an incremented version number and a summary of all changes made in this session. See the `document-revision-history` skill for full formatting rules.

```markdown
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | {date} | Agent ({model}) | Initial document generation |
```

## Section 1: Scope
- **1.1 Identification**: Extract system name, version, identifiers from PRD
- **1.2 System overview**: Summarize the system purpose from the user's perspective
- **1.3 Document overview**: Describe this OCD document's purpose and contents

## Section 2: Referenced documents
- List all project artifacts used as input sources, with number, title, revision, and date

## Section 3: Current system or situation
- **3.1 Background, objectives, and scope**: Describe the problem domain, mission/objectives, and scope from the PRD
- **3.2 Operational policies and constraints**: Current business rules, operational policies, and constraints
- **3.3 Description of current system or situation**: How things work today. Describe differences associated with different states or modes of operation. Include all of the following (items a through h per the DID):
  - **a.** The operational environment and its characteristics
  - **b.** Major system components and the interconnections among them
  - **c.** Interfaces to external systems or procedures
  - **d.** Capabilities/functions of the current system
  - **e.** Charts and descriptions depicting inputs, outputs, data flow, and manual/automated processes sufficient to understand the current system from the user's point of view
  - **f.** Performance characteristics: speed, throughput, volume, frequency
  - **g.** Quality attributes: reliability, maintainability, availability, flexibility, portability, usability, efficiency
  - **h.** Provisions for safety, security, privacy, and continuity of operations in emergencies
- **3.4 Users or involved personnel**: Identify all user types and stakeholders. Include organizational structures, training/skills, responsibilities, activities, and interactions
- **3.5 Support concept**: Current support and maintenance approach — support agencies, facilities, equipment, support software, repair/replacement criteria, maintenance levels and cycles

## Section 4: Justification for and nature of changes
- **4.1 Justification for change**:
  - **a.** New or modified aspects of user needs, threats, missions, objectives, environments, interfaces, personnel, or other factors requiring a new/modified system
  - **b.** Deficiencies or limitations in the current system that make it unable to respond to these factors
- **4.2 Description of needed changes**: New or modified capabilities, functions, processes, interfaces, or other changes needed
- **4.3 Priorities among the changes**: Identify each change as essential, desirable, or optional. Prioritize the desirable and optional changes
- **4.4 Changes considered but not included**: Identify changes that were considered but excluded, with rationale for not including them
- **4.5 Assumptions and constraints**: Any assumptions and constraints applicable to the changes identified

## Section 5: Concept for the new or modified system
- **5.1 Background, objectives, and scope**: Vision, mission/objectives, and scope for the new system from Product Brief/PRD
- **5.2 Operational policies and constraints**: New or changed operational policies and constraints
- **5.3 Description of the new or modified system**: How the new system will work. Describe differences associated with different states or modes. Include all of the following (items a through h, mirroring Section 3.3):
  - **a.** The operational environment and its characteristics
  - **b.** Major system components and the interconnections among them
  - **c.** Interfaces to external systems or procedures
  - **d.** Capabilities/functions of the new or modified system
  - **e.** Charts and descriptions depicting inputs, outputs, data flow, and manual/automated processes from the user's point of view
  - **f.** Performance characteristics: speed, throughput, volume, frequency
  - **g.** Quality attributes: reliability, maintainability, availability, flexibility, portability, usability, efficiency
  - **h.** Provisions for safety, security, privacy, and continuity of operations in emergencies
- **5.4 Users/affected personnel**: How user roles change with the new system — organizational structures, training/skills, responsibilities, and interactions
- **5.5 Support concept**: Planned support approach — support agencies, facilities, equipment, support software, repair/replacement criteria, maintenance levels and cycles

## Section 6: Operational scenarios
- Document one or more operational scenarios that illustrate the role of the new/modified system
- Each scenario should include: the system's interaction with users, interfaces with other systems, and all states/modes identified
- Include: events, actions, stimuli, information, interactions
- Cover both normal operation and exception/error scenarios
- Reference may be made to other media (e.g., videos, mockups) to provide part of this information

## Section 7: Summary of impacts
- **7.1 Operational impacts**: Anticipated operational impacts on user, acquirer, developer, and support agencies. Include: changes in interfaces with operating centers, procedure changes, use of new data sources, changes in data input quantity/type/timing, changes in data retention, new modes of operation
- **7.2 Organizational impacts**: Anticipated organizational impacts. Include: modification of responsibilities, addition/elimination of positions, training/retraining needs, changes in number/skill levels/locations of personnel
- **7.3 Impacts during development**: Anticipated impacts during the development effort. Include: meetings/discussions, database development/modification, training, parallel operation of new and existing systems, testing impacts, monitoring activities

## Section 8: Analysis of the proposed system
- **8.1 Summary of advantages**: Qualitative and quantitative summary of advantages — new capabilities, enhanced capabilities, improved performance, and their relationship to deficiencies identified in 4.1
- **8.2 Summary of disadvantages/limitations**: Qualitative and quantitative summary of disadvantages — degraded/missing capabilities, less-than-desired performance, excessive resource use, undesirable operational impacts, conflicts with user assumptions
- **8.3 Alternatives and trade-offs considered**: Major alternatives considered, trade-offs among them, and rationale for the decisions reached

## Section 9: Notes
- Alphabetical listing of all acronyms, abbreviations, and their meanings
- Glossary of terms and definitions
- Background information to aid understanding

## Appendix A
- Include any supplementary material (charts, detailed data, classified information) that supports the main body
- Reference each appendix from the main body where the data would normally appear

---

**CONFIRMATION GATE**: Present the generated document to the user for initial review. Wait for the user to confirm the content before proceeding to validation.
