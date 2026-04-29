---
name: Test-Accompanied Development
description: Enforces writing unit tests for every new public method created by the agent.
---
# Test-Accompanied Development (TAD)

Enforce a "Test-Alongside" policy where every public method is accompanied by a corresponding unit test.

## Purpose

To ensure high code quality and maintainability by mandating that all public interfaces are verified by automated tests at the moment of creation.

## Policy

**Every new public method/function you write MUST be accompanied by at least one unit test.**

## When to Use

- Use this skill **every time** you are about to write a new public method or function.
- This skill should be active during the coding phase of any feature or bug fix.

## Instructions

1.  **Identify Public Exports**: When preparing to write a new class, module, or function, identify which methods will be public/exported.
2.  **Plan the Test**: Before or immediately after writing the method signature, plan the corresponding test cases (Happy Path, Edge Cases, Error Cases).
3.  **Write the Method**: Implement the public method.
4.  **Write the Tests**: Immediately write the unit tests for the method. 
    - Refer to the `test-generator` skill for best practices on how to structure these tests (AAA pattern, Mocking, etc.).
    - Ensure tests are placed in the appropriate test directory of the project.
5.  **Verify**: Run the tests to ensure they pass before considering the method "done".

## Rules

- **No Public Method without Tests**: Do not consider a public method complete until its corresponding test file exists and passes.
- **Refer to Test Generator**: Use the `test-generator` skill as the standard for test quality and structure.
- **Traceability**: Mention the test file location when adding the public method.

## Example Workflow

### TypeScript (Jest)
1.  **Agent**: "I am adding a `calculateTotal` method to the `InvoiceService`. I will also create `InvoiceService.test.ts` to verify it."
2.  **Agent**: [Writes `calculateTotal` in `InvoiceService.ts`]
3.  **Agent**: [Writes tests in `InvoiceService.test.ts` using `test-generator` patterns]
4.  **Agent**: "Method and tests are complete. Running tests now..."

### Python (Pytest)
1.  **Agent**: "I am adding a `validate_user` function to `auth.py`. I will also create `tests/test_auth.py` to verify it."
2.  **Agent**: [Writes `validate_user` in `auth.py`]
3.  **Agent**: [Writes tests in `tests/test_auth.py` using `test-generator` patterns]
4.  **Agent**: "Implementation and tests are ready. Running `pytest`."
