---
name: Code Documentation Best Practices
description: Standardize file headers and method documentation across C++, C#, JS, TS, and Python.
---
# Code Documentation Best Practices

This skill enforces high-quality, standardized documentation for source code files and methods. It ensures consistent metadata and clear explanations of intent across different programming languages.

## Policies

### 1. Mandatory File Headers
*   **Rule**: Every source file must begin with a standardized header block.
*   **Contents**:
    - **Purpose**: A brief description of what the file contains/solves.
    - **Author/Project**: Project name or author information.
    - **Metadata**: Date created/modified and version if applicable.

### 2. Mandatory Method Documentation
*   **Rule**: Every public or non-trivial internal function/method must have a documentation block immediately preceding it.
*   **Standards**:
    - **C++**: Use Doxygen style (`/** ... */`).
    - **C#**: Use XML Documentation style (`/// <summary> ...`).
    - **JS/TS**: Use JSDoc style (`/** ... */`).
    - **Python**: Use PEP 257 Docstrings (`""" ... """`).
*   **Required Fields**:
    - **Summary**: Concise description of what the method does.
    - **Parameters**: Name and purpose of each argument.
    - **Return Value**: Description of the output.
    - **Exceptions/Errors**: Document significant error states or exceptions thrown.

### 3. Focus on "Why" and "What"
*   **Rule**: Do not document trivial code (e.g., `i++ // increment i`).
*   **Action**: Document the **intent** and **usage constraints**. If the code is complex, explain the high-level logic rather than line-by-line mechanics.

### 4. Semantic Linking
*   **Rule**: Use language-specific linking features (e.g., `@see`, `{@link}`, `<see cref=.../>`) to refer to related types or methods.

## Language Specifics

| Language | Format | Key Tags |
| :--- | :--- | :--- |
| **C++** | Doxygen | `\brief`, `\param`, `\return`, `\throw` |
| **C#** | XML Doc | `<summary>`, `<param>`, `<returns>`, `<exception>` |
| **JS/TS** | JSDoc | `@description`, `@param`, `@returns`, `@throws` |
| **Python** | Docstrings | `Args:`, `Returns:`, `Raises:` (Google/NumPy style) |

---

## Example (Generic Pattern)

```text
[File Header]
[Imports]

[Component Documentation]
[Implementation]
```
