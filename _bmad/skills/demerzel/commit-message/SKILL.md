---
name: Commit Message Generator
description: Generates conventional commit messages from code changes
---
# Commit Message Generator

Generate meaningful commit messages following Conventional Commits specification.

## Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

## Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style/formatting
- `refactor`: Code refactoring
- `test`: Adding/updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements
- `ci`: CI/CD changes
- `build`: Build system changes
- `revert`: Revert previous commit

## Guidelines

1. **Subject line** (max 50 chars):
   - Use imperative mood ("Add" not "Added")
   - Don't capitalize first letter
   - No period at the end

2. **Body** (optional):
   - Explain what and why, not how
   - Wrap at 72 characters

3. **Footer** (optional):
   - Breaking changes: `BREAKING CHANGE: description`
   - Issue references: `Fixes #123`

## Examples

```
feat(auth): add JWT token refresh mechanism

Implement automatic token refresh to improve user experience
and reduce re-authentication prompts.

Fixes #456
```

```
fix(api): resolve memory leak in user service

The user cache was not being cleared properly, causing
memory to grow over time.
```

```
docs: update installation instructions

Add steps for Windows users and clarify dependency requirements.
```

## Process

1. Analyze the code changes
2. Determine the type of change
3. Identify the scope (component/module affected)
4. Write clear, concise subject
5. Add body if changes need explanation
6. Add footer for breaking changes or issue refs
