---
name: Test Generator
description: Generates comprehensive unit and integration tests
---
# Test Generator

Generate comprehensive unit and integration tests for code.

## Process

1. **Analyze**: Understand code purpose, paths, dependencies, edge cases
2. **Framework**: Determine or ask for testing framework
3. **Generate**: Create test cases covering:
   - Happy path (normal behavior)
   - Edge cases (boundaries, empty/null inputs)
   - Error cases (invalid inputs, exceptions)
   - Integration scenarios (if applicable)

## Test Structure (AAA Pattern)

```
- Arrange: Setup test data
- Act: Execute code
- Assert: Verify results
```

## Coverage Goals

- 80%+ code coverage
- All public methods
- All conditional branches
- Positive and negative cases

## Best Practices

- One assertion per test
- Independent tests
- Descriptive test names
- Mock external dependencies
- Clear assertion messages

## Example Output

```javascript
describe('ComponentName', () => {
  test('should [behavior] when [condition]', () => {
    // Arrange
    const input = setupTestData();

    // Act
    const result = functionUnderTest(input);

    // Assert
    expect(result).toEqual(expectedOutput);
  });

  test('should handle edge case', () => {
    // ...
  });

  test('should throw on invalid input', () => {
    expect(() => fn(invalid)).toThrow();
  });
});
```
