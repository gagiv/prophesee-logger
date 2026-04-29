# Step 3 — Generate Document

Write the document in {document_output_language}, populating each template section. Keep requirements at the **system/subsystem level** — avoid low-level software implementation details. Each requirement shall be assigned a project-unique identifier, be stated so that an objective test can be defined for it, and be annotated with qualification method(s).

## Revision History

Before writing any content, add a **Revision History table** immediately after the document title. If this is a new document, create the table with version `1.0`. If updating an existing document, read the existing revision history and add a new row with an incremented version number and a summary of all changes made in this session. See the `document-revision-history` skill for full formatting rules.

```markdown
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | {date} | Agent ({model}) | Initial document generation |
```

## Section 1: Scope
- **1.1 Identification**: Extract system name, version, identifiers from PRD/Product Brief
- **1.2 System overview**: Summarize system purpose, nature, and stakeholders
- **1.3 Document overview**: Describe this SSS document's purpose, contents, and any security/privacy considerations

## Section 2: Referenced documents
- List all project artifacts and external standards used, with number, title, revision, and date

## Section 3: Requirements

- **3.1 Required states and modes**: Identify system-level operational states from Architecture/PRD (e.g., operational, maintenance, degraded, emergency). If none, state so explicitly. If states/modes exist, correlate each requirement to the applicable states/modes.

- **3.2 System capability requirements**: Map high-level PRD features and Product Brief goals to system capabilities (3.2.1, 3.2.2, etc.). Each requirement must have:
  - A unique identifier (SSS-CAP-001 format)
  - Clear, testable statement
  - Parameters: response times, throughput, accuracy, capacity, priorities as applicable
  - Error handling: behavior under unexpected, unallowed, or out-of-bounds conditions
  - Provisions for continuity of operations in emergencies

- **3.3 System external interface requirements**:
  - **3.3.1 Interface identification and diagrams**: Identify all required external interfaces with project-unique identifiers. Designate interfacing entities by name, number, version. State which have fixed vs. developing characteristics. Provide interface diagrams.
  - **3.3.x (per interface)**: For each external interface, specify requirements imposed on the system. Cover:
    - **a.** Priority the system must assign the interface
    - **b.** Type of interface (real-time data transfer, storage-and-retrieval, etc.)
    - **c.** Data elements: names/identifiers, data types, sizes/formats, units, ranges, accuracy/precision, timing/frequency constraints, security constraints, sources and recipients
    - **d.** Data element assemblies: records, messages, files, displays — names, structure, medium, characteristics, relationships, constraints
    - **e.** Communication methods: links/media, message formatting, flow control, data transfer rates, routing, transmission services, security considerations
    - **f.** Protocols: priority/layer, packeting, error control/recovery, synchronization, status/reporting
    - **g.** Physical compatibility (dimensions, tolerances, loads, plug compatibility, voltages)

- **3.4 System internal interface requirements**: Interfaces between major subsystems. If left to design or component specs, state so. If requirements exist, follow 3.3 topics.

- **3.5 System internal data requirements**: System-level data stores, data flows between subsystems. If left to design or component specs, state so.

- **3.6 Adaptation requirements**: Installation and site-specific configuration needs, operational parameters that may vary

- **3.7 Safety requirements**: Requirements for preventing/minimizing unintended hazards to personnel, property, and environment. Include nuclear component requirements if applicable.

- **3.8 Security and privacy requirements**: Security/privacy environment, type/degree of protection, risks, safeguards, policy, accountability, certification criteria

- **3.9 System environment requirements**: Physical, regulatory, and operational environment constraints. For hardware-software systems: transportation, storage, operation conditions (wind, rain, temperature, shock, noise, electromagnetic radiation, explosions)

- **3.10 Computer resource requirements**:
  - **3.10.1 Computer hardware requirements**: Required hardware — processors, memory, I/O devices, auxiliary storage, communications/network equipment (number, type, size, capacity)
  - **3.10.2 Computer hardware resource utilization requirements**: Maximum allowable utilization (% of processor, memory, I/O, storage, network capacity) with conditions for measurement
  - **3.10.3 Computer software requirements**: Required software (OS, DBMS, network software, utilities) with nomenclature, version, and documentation references
  - **3.10.4 Computer communications requirements**: Geographic locations, network topology, transmission techniques, data transfer rates, gateways, use times, data volume, time boundaries, peak volumes, diagnostics

- **3.11 System quality factors**: Quantitative requirements for: functionality, reliability (e.g., MTBF for equipment), maintainability, availability, flexibility, portability, reusability, testability, usability

- **3.12 Design and construction constraints**: Requirements constraining system design and construction. For hardware-software systems, include physical requirements:
  - **a.** Architecture constraints: required subsystems, standard/military/existing components, Government-furnished property
  - **b.** Design/construction standards, data standards, programming languages, workmanship requirements
  - **c.** Physical characteristics: weight limits, dimensional limits, color, protective coatings, interchangeability, transportability, setup requirements
  - **d.** Materials: allowed/prohibited materials, toxic material handling, electromagnetic radiation limits
  - **e.** Nameplates, part marking, serial/lot number marking, other identifying markings
  - **f.** Flexibility and expandability for anticipated growth, technology changes, threat changes, mission changes

- **3.13 Personnel-related requirements**: Number of users, skill levels, duty cycles, training needs, human factors engineering (capabilities/limitations, foreseeable errors, critical indicator placement, adjustable workstations, error message color/duration, auditory signals)

- **3.14 Training-related requirements**: Training devices and training materials to be included in the system

- **3.15 Logistics-related requirements**: System maintenance, software support, transportation modes, supply-system requirements, facility impacts, equipment impacts

- **3.16 Other requirements**: Additional requirements not covered above. Examples: system documentation requirements (specifications, drawings, manuals, test plans)

- **3.17 Packaging requirements**: Requirements for packaging, labeling, and handling for delivery

- **3.18 Precedence and criticality of requirements**: Order of precedence, criticality, or assigned weights. Identify requirements critical to safety, security, or privacy

## Section 4: Qualification provisions
For each requirement in Section 3, specify the qualification method(s). A table may be used:
- **a.** Demonstration: Observable functional operation without instrumentation
- **b.** Test: Operation using instrumentation or special test equipment
- **c.** Analysis: Processing of accumulated data (reduction, interpolation, extrapolation)
- **d.** Inspection: Visual examination of system components, documentation
- **e.** Special qualification methods: Special tools, techniques, procedures, facilities, acceptance limits, standard samples, preproduction samples, pilot models/lots

## Section 5: Requirements traceability
- For **system-level specifications**: This paragraph does not apply (state so).
- For **subsystem-level specifications**:
  - **5.a**: Map each subsystem requirement to the system requirements it addresses. Note: some requirements may trace to "system implementation" or system design decisions.
  - **5.b**: Map each system requirement allocated to this subsystem to the subsystem requirements that address it. All allocated requirements shall be accounted for.

## Section 6: Notes
- Alphabetical listing of all acronyms, abbreviations, and their meanings
- Glossary of terms and definitions

## Appendix A
- Include any supplementary material (requirement matrices, charts, classified data) that supports the main body

---

**CONFIRMATION GATE**: Present the generated document to the user for initial review. Wait for the user to confirm the content before proceeding to validation.
