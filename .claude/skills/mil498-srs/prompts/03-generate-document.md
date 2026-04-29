# Step 3 — Generate Document

Write the document in {document_output_language}, populating each template section. Each requirement shall be assigned a project-unique identifier, be stated so that an objective test can be defined for it, and be annotated with qualification method(s) and traceability to system requirements.

## Revision History

Before writing any content, add a **Revision History table** immediately after the document title. If this is a new document, create the table with version `1.0`. If updating an existing document, read the existing revision history and add a new row with an incremented version number and a summary of all changes made in this session. See the `document-revision-history` skill for full formatting rules.

```markdown
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | {date} | Agent ({model}) | Initial document generation |
```

## Section 1: Scope
- **1.1 Identification**: Extract software name, version, CSCI identifiers from the SSDD, PRD, and Architecture
- **1.2 System overview**: Summarize purpose, nature, development history from PRD. Identify this CSCI's role within the system
- **1.3 Document overview**: Describe this SRS document's purpose, contents, and any security/privacy considerations

## Section 2: Referenced documents
- List all predecessor MIL-STD-498 documents (SSDD, SSS) and project artifacts used, with number, title, revision, and date

## Section 3: Requirements

- **3.1 Required states and modes**: Identify operational modes from Architecture (e.g., normal, degraded, maintenance, training). If none, state "The CSCI does not have distinct operational states or modes." If states/modes exist, correlate each requirement or group of requirements to the applicable states/modes.

- **3.2 CSCI capability requirements**: Map Epics/features from the PRD to numbered capability requirements (3.2.1, 3.2.2, etc.). **Only include capabilities allocated to this CSCI per the SSDD.** Each requirement must have:
  - A unique project identifier (e.g., SRS-CAP-001)
  - Clear, testable acceptance criteria
  - Parameters: response times, throughput, accuracy, capacity, priorities, continuous operation requirements as applicable
  - Error handling: behavior under unexpected, unallowed, or out-of-bounds conditions
  - Provisions for continuity of operations in emergencies

- **3.3 CSCI external interface requirements**:
  - **3.3.1 Interface identification and diagrams**: Identify all required external interfaces with project-unique identifiers. Designate interfacing entities by name, number, version. State which have fixed vs. developing characteristics. Provide interface diagrams.
  - **3.3.x (per interface)**: For each external interface, specify requirements imposed on the CSCI. State other entities' characteristics as assumptions ("When [entity] does this, the CSCI shall..."). Cover:
    - **a.** Priority the CSCI must assign the interface
    - **b.** Type of interface (real-time data transfer, storage-and-retrieval, etc.)
    - **c.** Data elements: names/identifiers (project-unique, natural-language, technical), data types, sizes/formats, units, ranges, accuracy/precision, timing/frequency/volume constraints, security/privacy constraints, sources and recipients
    - **d.** Data element assemblies: records, messages, files, displays — names, structure, medium, visual/auditory characteristics, relationships, constraints, sources and recipients
    - **e.** Communication methods: links/media, message formatting, flow control, data transfer rates, routing/addressing, transmission services, security considerations
    - **f.** Protocols: priority/layer, packeting/fragmentation, error control/recovery, synchronization, status/reporting
    - **g.** Physical compatibility (dimensions, tolerances, loads, plug compatibility, voltages)

- **3.4 CSCI internal interface requirements**: Document internal component interfaces. If all internal interfaces are left to design, state so. If requirements exist, follow the same topics as 3.3.x.

- **3.5 CSCI internal data requirements**: Identify persistent data stores, databases, and data models. If all decisions are left to design, state so. If requirements exist, follow data element topics from 3.3.x.c and 3.3.x.d.

- **3.6 Adaptation requirements**: Site-specific or installation-dependent data and operational parameters that may vary

- **3.7 Safety requirements**: Requirements for preventing/minimizing unintended hazards — safeguards against inadvertent actions and non-actions

- **3.8 Security and privacy requirements**: Security/privacy environment, type/degree of protection, risks to withstand, required safeguards, policy requirements, accountability, certification criteria

- **3.9 CSCI environment requirements**: Runtime environment constraints (hardware, operating system)

- **3.10 Computer resource requirements**:
  - **3.10.1 Computer hardware requirements**: Required hardware — processors, memory, I/O devices, auxiliary storage, communications/network equipment (number, type, size, capacity, characteristics)
  - **3.10.2 Computer hardware resource utilization requirements**: Maximum allowable utilization (e.g., % of processor, memory, I/O, storage, network capacity) with conditions for measurement
  - **3.10.3 Computer software requirements**: Required software (OS, DBMS, network software, utilities, simulators) with nomenclature, version, and documentation references
  - **3.10.4 Computer communications requirements**: Geographic locations, network topology, transmission techniques, data transfer rates, gateways, system use times, data volume, time boundaries, peak volumes, diagnostics

- **3.11 Software quality factors**: Quantitative requirements for: functionality, reliability, maintainability, availability, flexibility, portability, reusability, testability, usability

- **3.12 Design and implementation constraints**: Constraints on architecture, databases, standard components, Government-furnished property; required design/implementation standards, programming languages; flexibility/expandability for anticipated growth

- **3.13 Personnel-related requirements**: Number of users, skill levels, duty cycles, training needs, human factors engineering (capabilities/limitations of humans, foreseeable errors, critical indicator placement, auditory signals)

- **3.14 Training-related requirements**: Training software or features to be included

- **3.15 Logistics-related requirements**: System maintenance, software support, transportation, supply-system requirements, facility/equipment impacts

- **3.16 Other requirements**: Any additional requirements not covered above

- **3.17 Packaging requirements**: Requirements for packaging, labeling, and handling for delivery

- **3.18 Precedence and criticality of requirements**: Order of precedence, criticality, or assigned weights. Identify requirements critical to safety, security, or privacy for special treatment

## Section 4: Qualification provisions
For each requirement in Section 3, specify the qualification method(s). A table may be used, or requirements may be annotated inline:
- **a.** Demonstration: Observable functional operation without instrumentation
- **b.** Test: Operation using instrumentation or special test equipment
- **c.** Analysis: Processing of accumulated data from other methods
- **d.** Inspection: Visual examination of code, documentation
- **e.** Special qualification methods: Special tools, techniques, procedures, facilities, or acceptance limits

## Section 5: Requirements traceability
- **5.a**: Map each CSCI requirement to the system (or subsystem) requirements it addresses. Note: some CSCI requirements may trace to "system implementation" or system design decisions rather than specific higher-level requirements.
- **5.b**: Map each system requirement allocated to this CSCI to the CSCI requirements that address it. All allocated system requirements shall be accounted for.

## Section 6: Notes
- Alphabetical listing of all acronyms, abbreviations, and their meanings
- Glossary of terms and definitions

## Appendix A
- Include any supplementary material (requirement matrices, data dictionaries) that supports the main body

---

**CONFIRMATION GATE**: Present the generated document to the user for initial review. Wait for the user to confirm the content before proceeding to validation.
