# Step 2.5 — CSCI Discovery Interview

Before generating the document, you must establish the correct CSCI decomposition through an interactive interview with {user_name}. **Do NOT map repositories, microservices, or deployment units 1:1 to CSCIs.** A CSCI is a configuration item — a logically cohesive unit that is independently specified, designed, tested, and managed.

## Phase A: Initial Analysis

Analyze the Architecture document and identify:
- All services, modules, repositories, and deployment units mentioned
- Functional domains they belong to (e.g., detection, alerting, user management, frontend)
- Shared release cycles, shared teams, shared test suites
- Data coupling between components (which services share databases or communicate frequently?)

## Phase B: Propose CSCI Hypothesis

Present {user_name} with a proposed CSCI decomposition that groups related services/modules into logically cohesive CSCIs. For each proposed CSCI:
- Give it a descriptive name and project-unique identifier
- List the services/modules/components it contains (these become CSCs — Computer Software Components — within the CSCI)
- State the functional rationale for the grouping
- Identify the system requirements allocated to it

## Phase C: Guided Questions

Ask {user_name} the following questions to validate and refine the decomposition:

1. **Release boundaries**: "Which of these services/modules share a release cycle and are always deployed together?"
2. **Team boundaries**: "Which components are developed and maintained by the same team?"
3. **Test boundaries**: "Which components are always tested together as a unit?"
4. **Delivery boundaries**: "What are your contractual or organizational delivery boundaries — what does the customer/stakeholder receive as distinct deliverables?"
5. **Configuration management**: "Which components are independently baselined and version-controlled as a unit?"

## Phase D: Refine and Confirm

Based on {user_name}'s answers:
- Merge or split CSCIs as needed
- Ensure each CSCI has clear functional cohesion
- Assign final project-unique identifiers (e.g., CSCI-SA for Situational Awareness, CSCI-FE for Frontend)
- Get explicit approval from {user_name} before proceeding to document generation

**Do NOT proceed to Step 3 until {user_name} approves the CSCI decomposition.**

---

**CONFIRMATION GATE**: The user MUST explicitly approve the final CSCI decomposition before proceeding. Do not continue to document generation until approval is received.
