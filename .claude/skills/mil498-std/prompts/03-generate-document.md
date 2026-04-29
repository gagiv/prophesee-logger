# Step 3 — Generate Document

Write the document in {document_output_language}, populating each template section. **Important**: Safety precautions (marked by WARNING or CAUTION) and security/privacy considerations shall be included as applicable throughout Sections 3 and 4.

## Revision History

Before writing any content, add a **Revision History table** immediately after the document title. If this is a new document, create the table with version `1.0`. If updating an existing document, read the existing revision history and add a new row with an incremented version number and a summary of all changes made in this session. See the `document-revision-history` skill for full formatting rules.

```markdown
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | {date} | Agent ({model}) | Initial document generation |
```

## Section 1: Scope
- **1.1 Identification**: Extract system and software identifiers from PRD/Architecture
- **1.2 System overview**: Summarize the system and the CSCI(s) being tested
- **1.3 Document overview**: Describe this STD document's purpose and contents

## Section 2: Referenced documents
- List all project artifacts, test standards, and other references with number, title, revision, and date

## Section 3: Test preparations

Organize as 3.x subsections, one per test. For each test (3.x), provide a brief description and the following:

- **3.x.1 Hardware preparation**: Procedures to prepare hardware for the test:
  - **a.** Specific hardware to be used, identified by name and number
  - **b.** Switch settings and cabling necessary to connect the hardware
  - **c.** Diagrams showing hardware, interconnecting control, and data paths
  - **d.** Step-by-step instructions for placing hardware in a state of readiness
- **3.x.2 Software preparation**: Procedures to prepare software for the test:
  - **a.** Specific software to be used in the test
  - **b.** Storage medium of the item(s) under test
  - **c.** Storage medium of related software (simulators, test drivers, databases)
  - **d.** Instructions for loading software, including required sequence
  - **e.** Instructions for software initialization common to more than one test case
- **3.x.3 Other pre-test preparations**: Any other personnel actions, preparations, or procedures necessary (test data setup, user accounts, external service mocks, environment variables)

When information duplicates another test's preparation, reference it rather than repeating it.

## Section 4: Test descriptions

Organize as a **two-level hierarchy**: 4.x per test, then 4.x.y per test case within each test. Group test cases by capability/feature (mapping to Epics) for clarity.

For each test (4.x), identify the test by project-unique identifier. Then for each test case (4.x.y), provide:

- **4.x.y.1 Requirements addressed**: Identify the CSCI or system requirements addressed by this test case. Reference specific SRS requirement IDs (e.g., SRS-CAP-001). (Alternatively, this traceability may be provided in Section 5.a.)

- **4.x.y.2 Prerequisite conditions**: Conditions that must be established prior to the test case:
  - **a.** Hardware and software configuration
  - **b.** Flags, initial breakpoints, pointers, control parameters, or initial data to be set/reset
  - **c.** Preset hardware conditions or electrical states
  - **d.** Initial conditions for timing measurements
  - **e.** Conditioning of the simulated environment
  - **f.** Other special conditions peculiar to the test case

- **4.x.y.3 Test inputs**: Test inputs necessary for the test case:
  - **a.** Name, purpose, and description (range of values, accuracy) of each test input
  - **b.** Source of the test input and method for selecting it
  - **c.** Whether the test input is real or simulated
  - **d.** Time or event sequence of test input
  - **e.** How input data will be controlled to:
    1. Test with minimum/reasonable number of data types and values
    2. Exercise with a range of valid data (overload, saturation, worst-case)
    3. Exercise with invalid data types and values (error handling)
    4. Permit retesting if necessary

- **4.x.y.4 Expected test results**: All expected results — both intermediate and final results

- **4.x.y.5 Criteria for evaluating results**: Criteria for intermediate and final results:
  - **a.** Range or accuracy over which output can vary and still be acceptable
  - **b.** Minimum number of input/output combinations that constitute acceptable results
  - **c.** Maximum/minimum allowable test duration (time or number of events)
  - **d.** Maximum number of interrupts, halts, or system breaks that may occur
  - **e.** Allowable severity of processing errors
  - **f.** Conditions under which the result is inconclusive and retesting is needed
  - **g.** Conditions indicating irregularities in input data, test database, or procedures
  - **h.** Allowable indications of control, status, and results readiness for next test case
  - **i.** Additional criteria not covered above

- **4.x.y.6 Test procedure**: Defined as individually numbered steps in sequential order:
  - **a.** Test operator actions and equipment operation for each step, including commands to:
    1. Initiate the test case and apply test inputs
    2. Inspect test conditions
    3. Perform interim evaluations of test results
    4. Record data
    5. Halt or interrupt the test case
    6. Request data dumps or other aids
    7. Modify the database/data files
    8. Repeat the test case if unsuccessful
    9. Apply alternate modes as required
    10. Terminate the test case
  - **b.** Expected result and evaluation criteria for each step
  - **c.** If addressing multiple requirements, which steps address which requirements
  - **d.** Actions to follow in event of program stop or error (recording critical data, halting time-sensitive software, collecting records)
  - **e.** Procedures for reducing and analyzing test results (detect output, identify media/location, evaluate for continuation, evaluate against required output)

- **4.x.y.7 Assumptions and constraints**: Assumptions made and constraints imposed (limitations on timing, interfaces, equipment, personnel, database). If waivers/exceptions to limits are approved, address their effects.

## Section 5: Requirements traceability
- **5.a**: Map each test case to the system or CSCI requirements it addresses. If a test case addresses multiple requirements, indicate which test procedure steps address which requirements.
- **5.b**: Map each requirement covered by this STD to the test case(s) that address it. For CSCI testing, trace from each SRS requirement. For system testing, trace from each SSS requirement. Indicate specific test procedure steps where applicable.
- Ensure every requirement has at least one associated test case. Identify any requirements that cannot be tested and explain why.

## Section 6: Notes
- Alphabetical listing of all acronyms, abbreviations, and their meanings
- Glossary of test terminology
- References to test automation frameworks or tools used

## Appendix A
- Test procedures may be included as an appendix for convenience in document maintenance
- Include any supplementary material (test data sets, detailed configurations)

---

**CONFIRMATION GATE**: Present the generated document to the user for initial review. Wait for the user to confirm the content before proceeding to validation.
