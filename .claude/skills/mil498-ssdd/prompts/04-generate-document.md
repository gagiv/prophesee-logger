# Step 3 — Generate Document

Write the document in {document_output_language}, populating each template section.

## Revision History

Before writing any content, add a **Revision History table** immediately after the document title. If this is a new document, create the table with version `1.0`. If updating an existing document, read the existing revision history and add a new row with an incremented version number and a summary of all changes made in this session. See the `document-revision-history` skill for full formatting rules.

```markdown
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | {date} | Agent ({model}) | Initial document generation |
```

## Section 1: Scope
- **1.1 Identification**: Extract system name, version, and project-unique identifiers from PRD/Product Brief
- **1.2 System overview**: Summarize system purpose, history, stakeholders, and operating sites from Product Brief and PRD
- **1.3 Document overview**: Describe this SSDD document's purpose, contents, and any security/privacy considerations

## Section 2: Referenced documents
- List all project artifacts, standards, and external references used as inputs. Include number, title, revision, and date for each

## Section 3: System-wide design decisions

**CRITICAL BEHAVIORAL GUIDANCE**: This section describes the system's behavioral design — how it will behave from a user's point of view in meeting its requirements, ignoring internal implementation. Follow these rules strictly:

1. **Requirements-driven**: Every design decision MUST cite the specific requirement(s) it satisfies (e.g., "To satisfy NFR-P2 (< 1s detection latency)...")
2. **Behavioral, not implementation**: Describe patterns and approaches, NOT specific tools or products. Write "An asynchronous message distribution pattern is selected..." NOT "RabbitMQ serves as the message broker..."
3. **Technology names belong in the Architecture document**, not here. If a technology choice is essential context, mention it parenthetically after the behavioral description
4. **State-dependent decisions**: If a design decision depends on system states or modes, indicate this dependency explicitly

For each of the following subsections, document the design decisions and reference their driving requirements:

- **a. Input/output design**: What the system accepts and produces. Describe system inputs, outputs, and user/external interfaces from the user's perspective. If Interface Design Descriptions (IDDs) exist, they may be referenced
- **b. Behavioral design**: How the system behaves in response to inputs and conditions — actions, response times, performance characteristics, selected algorithms/rules, and handling of invalid inputs or error conditions. Describe behavioral patterns (event-driven processing, request-response cycles, etc.) without naming specific tools
- **c. Database/data design**: How databases and data files appear to users and external systems. Describe data models, storage approaches, and data lifecycle from the user's perspective. If Database Design Descriptions (DBDDs) exist, they may be referenced
- **d. Safety, security, privacy**: Selected approaches to meeting safety, security, and privacy requirements. Place these in **separate subparagraphs** as the DID requires special treatment for critical requirements
- **e. Hardware/physical design choices**: Physical characteristics if applicable (for hardware-software systems) — size, color, shape, weight, materials, markings
- **f. Other system-wide decisions**: Flexibility, availability, maintainability approaches. Describe the rationale for architectural patterns selected (e.g., "A service-isolation pattern is selected to satisfy NFR-A1 availability requirement, enabling independent failure recovery")

## Section 4: System architectural design

- **4.1 System components** (items a through f — all are required):

  **a.** Identify all system components using the approved CSCI decomposition from Step 2.5. Each CSCI shall have a project-unique identifier. For each CSCI, list the CSCs (services, modules) it contains. Also identify HWCIs and manual operations as applicable. Note: a database may be treated as a CSCI or as part of a CSCI.

  **b.** Show the static ("consists of") relationships using component/block diagrams. Multiple relationship views may be presented (structural, deployment, data ownership).

  **c.** State each component's purpose and the system requirements allocated to it. (Alternatively, allocation may be provided in Section 5.a.)

  **d.** Identify each component's development status: new development, existing reuse as-is, existing design reuse, reengineering, planned for a specific build, etc. For existing components, provide identifying information (name, version, documentation references, location).

  **e.** For each computer system or hardware aggregate, describe computer hardware resources: processors, memory, I/O devices, auxiliary storage, communications/network equipment. Include:
    - Manufacturer, model, speed/capacity for processors
    - Type, size, speed, configuration for memory
    - Type, speed/capacity for I/O devices
    - Type, amount, speed for auxiliary storage
    - Data transfer rates, topologies, protocols for network equipment
    - Growth capabilities and diagnostic capabilities
    - Resource utilization allocation per CSCI (e.g., "20% of resource capacity allocated to CSCI-SA")

  **f.** Present a **specification tree** — a diagram that identifies and shows the relationships among the planned specifications for the system components. This is a tree showing which specification documents (SSS, SRS, SDD, IRS, etc.) apply to which components.

- **4.2 Concept of execution**:
  - Describe dynamic relationships between components — how they interact during system operation
  - Include: execution flow, data flow, dynamically controlled sequencing, state transitions, timing/sequencing, priorities, interrupt handling, concurrent execution, dynamic allocation/deallocation, exception handling
  - Use sequence diagrams, timing diagrams, or state transition diagrams where helpful

- **4.3 Interface design**:
  - **4.3.1 Interface identification and diagrams**: List all interfaces with project-unique identifiers. Identify interfacing entities by name, number, version. State which entities have fixed interface characteristics vs. developing ones. Provide interface diagrams.
  - **4.3.x (per interface)**: For each interface, document the following as applicable:
    - **a.** Priority assigned to the interface
    - **b.** Type of interface (real-time data transfer, storage-and-retrieval, etc.)
    - **c.** Data elements: names/identifiers (project-unique, natural-language, technical), data types, sizes/formats, units, ranges, accuracy/precision, timing/frequency/volume constraints, security/privacy constraints, sources and recipients
    - **d.** Data element assemblies: records, messages, files, displays — their names, structure, medium, visual/auditory characteristics, relationships, constraints, sources and recipients
    - **e.** Communication methods: links/media, message formatting, flow control, data transfer rates, routing/addressing, transmission services, safety/security considerations
    - **f.** Protocols: priority/layer, packeting/fragmentation, error control/recovery, synchronization, status/reporting
    - **g.** Physical compatibility considerations (dimensions, tolerances, loads, voltages, plug compatibility)

## Section 5: Requirements traceability
- **5.a**: Map each system component to the system requirements it satisfies
- **5.b**: Map each system requirement to the components that address it
- Ensure every system requirement is accounted for in both directions

## Section 6: Notes
- Alphabetical listing of all acronyms, abbreviations, and their meanings
- Glossary of terms and definitions needed to understand this document
- Background information to aid understanding

## Appendix A
- Include any supplementary material (charts, detailed data, classified information) that supports the main body
- Reference each appendix from the main body where the data would normally appear

---

**CONFIRMATION GATE**: Present the generated document to the user for initial review. Wait for the user to confirm the content before proceeding to validation.
