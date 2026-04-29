---
name: Code Review
description: Performs comprehensive code reviews with best practices
---
# Code Review Skill

## Description
Perform comprehensive code reviews following industry best practices and security guidelines.

## Usage
Invoke this skill by typing `/code-review` or asking for a code review.

## Instructions

When performing a code review, you should:

1. **Code Quality Analysis**
   - Check for code clarity and readability
   - Identify potential bugs or logical errors
   - Review variable and function naming conventions
   - Assess code organization and structure

2. **Best Practices**
   - Verify adherence to language-specific best practices
   - Check for proper error handling
   - Review code for performance considerations
   - Identify code duplication and suggest refactoring

3. **Security Review**
   - Look for common security vulnerabilities (OWASP Top 10)
   - Check for SQL injection, XSS, CSRF vulnerabilities
   - Verify input validation and sanitization
   - Review authentication and authorization logic

4. **Testing & Documentation**
   - Assess test coverage
   - Check for edge cases
   - Review inline comments and documentation
   - Suggest improvements to documentation

5. **Output Format**
   Present findings in this format:

   ```
   ## Code Review Summary

   ### ✅ Strengths
   - [List positive aspects]

   ### ⚠️ Issues Found
   - **[Severity]** [Description]
     - Location: [file:line]
     - Recommendation: [how to fix]

   ### 💡 Suggestions
   - [Improvement suggestions]

   ### 📊 Overall Assessment
   [Brief summary and rating]
   ```

## Examples

**User**: "Review this authentication function"
**Assistant**: [Performs thorough review following the structure above]

**User**: "/code-review"
**Assistant**: "I'll review the code in your current selection/file. What would you like me to focus on?"
