# Step 3 — Generate Document

Write the document in {document_output_language}, populating each template section. **Important**: Each paragraph in Sections 4 and 5 shall identify applicable risks/uncertainties and plans for dealing with them.

## Revision History

Before writing any content, add a **Revision History table** immediately after the document title. If this is a new document, create the table with version `1.0`. If updating an existing document, read the existing revision history and add a new row with an incremented version number and a summary of all changes made in this session. See the `document-revision-history` skill for full formatting rules.

```markdown
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | {date} | Agent ({model}) | Initial document generation |
```

## Section 1: Scope
- **1.1 Identification**: Extract project name, version, identifiers from PRD
- **1.2 System overview**: Summarize from Product Brief and PRD
- **1.3 Document overview**: Describe this SDP document's purpose
- **1.4 Relationship to other plans**: Reference any related project plans (quality assurance plans, configuration management plans, test plans)

## Section 2: Referenced documents
- List all project artifacts, standards, and external references with number, title, revision, and date

## Section 3: Overview of required work
Provide an overview of the following (items a through f per the DID):
- **a.** Requirements and constraints on the system and software to be developed
- **b.** Requirements and constraints on project documentation (reference SSDD specification tree if available)
- **c.** Position of the project in the system life cycle
- **d.** The selected program/acquisition strategy or any requirements/constraints on it
- **e.** Requirements and constraints on project schedules and resources
- **f.** Other requirements and constraints (security, privacy, methods, standards, interdependencies in hardware and software development)

## Section 4: Plans for general software development activities

**4.1 Software development process**: Describe the software development process to be used. Identify planned builds (if applicable), their objectives, and the software development activities in each build.

**4.2 General plans for software development**:

- **4.2.1 Software development methods**: Describe or reference the methods to be used — manual and automated tools and procedures. Map the project's development methodology to MIL-STD-498 activities.
- **4.2.2 Standards for software products**: Describe standards for representing requirements, design, code, test cases, test procedures, and test results. For code standards, include:
  - a. Format standards (indentation, spacing, capitalization, ordering)
  - b. Header comment standards (name, version, modification history, purpose, requirements/design decisions, processing notes, data notes)
  - c. Other comment standards (required number and content)
  - d. Naming conventions (variables, parameters, packages, procedures, files)
  - e. Restrictions on language constructs or features
  - f. Restrictions on code complexity
- **4.2.3 Reusable software products**:
  - 4.2.3.1 Incorporating reusable software products — approach for identifying, evaluating, and incorporating reuse candidates
  - 4.2.3.2 Developing reusable software products — approach for identifying and reporting reuse opportunities
- **4.2.4 Handling of critical requirements**:
  - 4.2.4.1 Safety assurance
  - 4.2.4.2 Security assurance
  - 4.2.4.3 Privacy assurance
  - 4.2.4.4 Assurance of other critical requirements
- **4.2.5 Computer hardware resource utilization**: Approach for allocating and monitoring hardware resource utilization
- **4.2.6 Recording rationale**: Approach for recording rationale for key project decisions
- **4.2.7 Access for acquirer review**: Approach for providing acquirer access to facilities for review

## Section 5: Plans for performing detailed software development activities

For each subsection below, describe the approach (methods/procedures/tools) for: 1) analysis or technical tasks, 2) recording of results, 3) preparation of deliverables. Identify applicable risks/uncertainties and plans for dealing with them.

- **5.1 Project planning and oversight**:
  - 5.1.1 Software development planning (updates to this plan)
  - 5.1.2 CSCI test planning
  - 5.1.3 System test planning
  - 5.1.4 Software installation planning
  - 5.1.5 Software transition planning
  - 5.1.6 Following and updating plans, including management review intervals
- **5.2 Establishing a software development environment**:
  - 5.2.1 Software engineering environment
  - 5.2.2 Software test environment
  - 5.2.3 Software development library
  - 5.2.4 Software development files
  - 5.2.5 Non-deliverable software
- **5.3 System requirements analysis**:
  - 5.3.1 Analysis of user input
  - 5.3.2 Operational concept
  - 5.3.3 System requirements
- **5.4 System design**:
  - 5.4.1 System-wide design decisions
  - 5.4.2 System architectural design
- **5.5 Software requirements analysis**: Approach for deriving CSCI requirements from system requirements
- **5.6 Software design**:
  - 5.6.1 CSCI-wide design decisions
  - 5.6.2 CSCI architectural design
  - 5.6.3 CSCI detailed design
- **5.7 Software implementation and unit testing**:
  - 5.7.1 Software implementation
  - 5.7.2 Preparing for unit testing
  - 5.7.3 Performing unit testing
  - 5.7.4 Revision and retesting
  - 5.7.5 Analyzing and recording unit test results
- **5.8 Unit integration and testing**:
  - 5.8.1 Preparing for unit integration and testing
  - 5.8.2 Performing unit integration and testing
  - 5.8.3 Revision and retesting
  - 5.8.4 Analyzing and recording unit integration and test results
- **5.9 CSCI qualification testing**:
  - 5.9.1 Independence in CSCI qualification testing
  - 5.9.2 Testing on the target computer system
  - 5.9.3 Preparing for CSCI qualification testing
  - 5.9.4 Dry run of CSCI qualification testing
  - 5.9.5 Performing CSCI qualification testing
  - 5.9.6 Revision and retesting
  - 5.9.7 Analyzing and recording CSCI qualification test results
- **5.10 CSCI/HWCI integration and testing**:
  - 5.10.1 Preparing for CSCI/HWCI integration and testing
  - 5.10.2 Performing CSCI/HWCI integration and testing
  - 5.10.3 Revision and retesting
  - 5.10.4 Analyzing and recording CSCI/HWCI integration and test results
- **5.11 System qualification testing**:
  - 5.11.1 Independence in system qualification testing
  - 5.11.2 Testing on the target computer system
  - 5.11.3 Preparing for system qualification testing
  - 5.11.4 Dry run of system qualification testing
  - 5.11.5 Performing system qualification testing
  - 5.11.6 Revision and retesting
  - 5.11.7 Analyzing and recording system qualification test results
- **5.12 Preparing for software use**:
  - 5.12.1 Preparing the executable software
  - 5.12.2 Preparing version descriptions for user sites
  - 5.12.3 Preparing user manuals
  - 5.12.4 Installation at user sites
- **5.13 Preparing for software transition**:
  - 5.13.1 Preparing the executable software
  - 5.13.2 Preparing source files
  - 5.13.3 Preparing version descriptions for the support site
  - 5.13.4 Preparing the "as built" CSCI design and other support information
  - 5.13.5 Updating the system design description
  - 5.13.6 Preparing support manuals
  - 5.13.7 Transition to the designated support site
- **5.14 Software configuration management**:
  - 5.14.1 Configuration identification
  - 5.14.2 Configuration control
  - 5.14.3 Configuration status accounting
  - 5.14.4 Configuration audits
  - 5.14.5 Packaging, storage, handling, and delivery
- **5.15 Software product evaluation**:
  - 5.15.1 In-process and final software product evaluations
  - 5.15.2 Software product evaluation records, including items to be recorded
  - 5.15.3 Independence in software product evaluation
- **5.16 Software quality assurance**:
  - 5.16.1 Software quality assurance evaluations
  - 5.16.2 Software quality assurance records, including items to be recorded
  - 5.16.3 Independence in software quality assurance
- **5.17 Corrective action**:
  - 5.17.1 Problem/change reports (including items to be recorded: project name, originator, problem number/name, affected element, dates, category/priority, description, analyst, recommended solution, impacts, status, correction details)
  - 5.17.2 Corrective action system
- **5.18 Joint technical and management reviews**:
  - 5.18.1 Joint technical reviews, including a proposed set of reviews
  - 5.18.2 Joint management reviews, including a proposed set of reviews
- **5.19 Other software development activities**:
  - 5.19.1 Risk management, including known risks and corresponding strategies
  - 5.19.2 Software management indicators, including indicators to be used
  - 5.19.3 Security and privacy
  - 5.19.4 Subcontractor management
  - 5.19.5 Interface with software IV&V agents
  - 5.19.6 Coordination with associate developers
  - 5.19.7 Improvement of project processes
  - 5.19.8 Other activities not covered elsewhere

For subsections that are not applicable to the project, state "Not applicable" with brief justification.

## Section 6: Schedules and activity network
- **a.** Schedule(s) identifying activities in each build, showing initiation of each activity, availability of draft and final deliverables and milestones, and completion of each activity
- **b.** An activity network depicting sequential relationships and dependencies among activities, identifying those that impose the greatest time restrictions

## Section 7: Project organization and resources
- **7.1 Project organization**: Organizational structure, organizations involved, relationships, and authority/responsibility for carrying out activities
- **7.2 Project resources**:
  - **a.** Personnel resources: estimated staff-loading, breakdown by responsibility, skill levels, geographic locations, and security clearances
  - **b.** Developer facilities: geographic locations, facilities, secure areas
  - **c.** Acquirer-furnished items: equipment, software, services, documentation, data, facilities with schedule of when needed
  - **d.** Other required resources with plan for obtaining them, dates needed, and availability

## Section 8: Notes
- Alphabetical listing of all acronyms, abbreviations, and their meanings
- Glossary of terms and definitions
- Background information to aid understanding

## Appendix A
- Include any supplementary material (charts, detailed schedules, classified data) that supports the main body

---

**CONFIRMATION GATE**: Present the generated document to the user for initial review. Wait for the user to confirm the content before proceeding to validation.
