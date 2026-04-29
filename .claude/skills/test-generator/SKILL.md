---
name: Test Generator
description: Generates comprehensive unit and integration tests
---
# Test Generator Skill

## Description
Automatically generate comprehensive unit tests and integration tests for code.

## Usage
Invoke with `/test-generator` or ask to "generate tests" for specific code.

## Instructions

When generating tests:

1. **Analyze the Code**
   - Understand the function/module purpose
   - Identify all code paths and branches
   - Note dependencies and side effects
   - Determine edge cases and boundary conditions

2. **Test Framework Selection**
   - Ask user for preferred framework if not obvious from project
   - Common frameworks:
     - JavaScript/TypeScript: Jest, Mocha, Vitest
     - Python: pytest, unittest
     - Java: JUnit, TestNG
     - C#: xUnit, NUnit
     - Go: testing package

3. **Generate Test Cases**
   - **Happy path tests**: Normal expected behavior
   - **Edge cases**: Boundary values, empty inputs, null/undefined
   - **Error cases**: Invalid inputs, exception handling
   - **Integration tests**: If applicable, test interactions with dependencies

4. **Test Structure**
   ```
   - Setup/Arrange: Prepare test data and environment
   - Execute/Act: Run the code under test
   - Assert: Verify expected outcomes
   - Cleanup: Reset state if needed
   ```

5. **Coverage Goals**
   - Aim for 80%+ code coverage
   - Cover all public methods/functions
   - Test all conditional branches
   - Include both positive and negative test cases

6. **Mocking & Stubbing**
   - Mock external dependencies (APIs, databases, file system)
   - Stub complex dependencies
   - Use dependency injection where needed

7. **Test Quality**
   - Each test should test one thing
   - Tests should be independent
   - Use descriptive test names
   - Include helpful assertion messages
   - Follow AAA pattern (Arrange, Act, Assert)

## Output Format

```typescript
// Example output for JavaScript/TypeScript with Jest

describe('FunctionName', () => {
  describe('happy path', () => {
    test('should [expected behavior] when [condition]', () => {
      // Arrange
      const input = ...;

      // Act
      const result = functionName(input);

      // Assert
      expect(result).toBe(...);
    });
  });

  describe('edge cases', () => {
    test('should handle empty input', () => {
      ...
    });

    test('should handle null/undefined', () => {
      ...
    });
  });

  describe('error cases', () => {
    test('should throw error for invalid input', () => {
      expect(() => functionName(invalid)).toThrow();
    });
  });
});
```

## Examples

**User**: "Generate tests for this authentication function"
**Assistant**: [Analyzes the function and generates comprehensive test suite]

**User**: "/test-generator"
**Assistant**: "I'll generate tests for your code. Which testing framework are you using?"
