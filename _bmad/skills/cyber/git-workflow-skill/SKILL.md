---
name: Git Workflow
description: MANDATORY worktree-based workflow for ALL file-changing activities. Enforces isolated feature branches, conventional commits, and PR-based merging.
---
# Mandatory Usage Policy (CRITICAL)

**This skill is MANDATORY for all activities that modify tracked files in this repository.**

1.  **Before starting ANY work** that changes source code, config files, or documentation: You MUST run `./scripts/start-feature.sh` (or the equivalent `git worktree add`) to create an isolated feature branch and worktree.
2.  **During development**: You MUST perform all file-writing activities inside the newly created worktree directory.
3.  **After completing work**: You MUST run `./scripts/finish-feature.sh` (or the equivalent rebase/push/PR/cleanup sequence) to integrate your changes and clean up the worktree.

**Failure to follow this workflow is a violation of repository standards.**

---

# Git Workflow (Worktree-Based)

Multi-agent parallel development using git worktrees. Each agent gets an isolated working directory — no branch switching, no conflicts between agents.

## Bundled Tools

### Scripts (scripts/)
| Script | Purpose |
|--------|---------|
| `start-feature.sh <type> <desc>` | Create worktree + feature branch from dev |
| `finish-feature.sh [path]` | Rebase, push, create PR, remove worktree |
| `validate-workflow.sh [--list]` | Check workflow compliance / list worktrees |
| `install-hooks.sh` | Install git hooks to repo |

### Git Hooks (hooks/)
| Hook | Purpose |
|------|---------|
| `pre-commit` | Blocks commits on dev/main (shared across worktrees) |
| `commit-msg` | Validates conventional commit format |
| `prepare-commit-msg` | Adds commit message template |

**Install hooks:** Run `scripts/install-hooks.sh` in target repository.

### Requirements
- Git (2.15+ for worktree support)
- GitHub CLI (`gh`) - Required for automatic PR creation
  ```bash
  # macOS
  brew install gh
  # Windows
  winget install --id GitHub.cli
  # Linux
  apt install gh

  # Authenticate
  gh auth login
  ```

---

## Mandatory Pre-Change Check

Before making ANY change to repository files (that are not in .gitignore):

1. Check if files to be changed are tracked:
   ```bash
   git check-ignore -v <file-path>
   ```
   If file is ignored → proceed without this workflow
   If file is tracked → continue with steps below

2. Verify `dev` branch exists:
   ```bash
   git fetch origin
   git branch -a | grep -E '(^|\/)dev$'
   ```
3. If `dev` does not exist → **STOP and ask user** to create it or specify base branch

## Multi-Agent Development Flow

```
Main repo (stays on dev) ─── always clean, never modified directly
  │
  ├── .worktrees/auth-system/     ← Agent 1: feature/auth-system
  │     └── (isolated copy of repo, own branch, own changes)
  │
  ├── .worktrees/api-refactor/    ← Agent 2: bugfix/api-refactor
  │     └── (isolated copy of repo, own branch, own changes)
  │
  └── .worktrees/update-docs/     ← Agent 3: chore/update-docs
        └── (isolated copy of repo, own branch, own changes)

Each worktree:
  1. Has its own directory and branch
  2. Shares git history with the main repo
  3. Can commit, push, and create PRs independently
  4. Gets cleaned up automatically after finish-feature.sh
```

### Starting Work

**Using script (recommended):**
```bash
./scripts/start-feature.sh feature my-feature-name
# Output: .worktrees/my-feature-name/ created
cd .worktrees/my-feature-name/
```

**Manual:**
```bash
git worktree add .worktrees/<desc> -b feature/<desc> origin/dev
cd .worktrees/<desc>
```

### Branch Naming

| Type | Use Case |
|------|----------|
| `feature/<desc>` | New functionality |
| `bugfix/<desc>` | Bug fixes |
| `hotfix/<desc>` | Urgent production fixes |
| `chore/<desc>` | Maintenance tasks |

### Completing Work

**Using script (recommended):**
```bash
# Run from inside the worktree
./scripts/finish-feature.sh
```

This script will:
1. Validate you're on a feature branch
2. Validate commit messages (conventional commits)
3. Rebase on latest `dev` branch
4. Push the feature branch
5. **Automatically create a PR to `dev`** (requires `gh` CLI)
6. **Remove the worktree** (auto-cleanup)

**Note:** If `gh` CLI is not installed, the script will skip PR creation. The branch will still be pushed.

**Manual:**
```bash
# From inside the worktree
git fetch origin dev
git rebase origin/dev
git push -u origin <branch-name>
gh pr create --base dev --head <branch-name>

# Clean up from main repo
cd /path/to/main/repo
git worktree remove .worktrees/<desc>
```

### Managing Worktrees

```bash
# List all active worktrees
git worktree list
# or
./scripts/validate-workflow.sh --list

# Remove a specific worktree
git worktree remove .worktrees/<desc>

# Clean up stale references
git worktree prune

# Validate workflow compliance
./scripts/validate-workflow.sh
```

## Commit Format (Conventional Commits)

```
<type>(<scope>): <description>

[optional body]
```

**Types:** `feat`, `fix`, `chore`, `docs`, `refactor`, `test`

**Examples:**
- `feat(auth): add OAuth2 flow support`
- `fix(api): handle null response from endpoint`
- `chore(deps): update Helm chart dependencies`
- `docs(readme): add deployment instructions`

## Critical Rules

- **NEVER** modify tracked files without being in a worktree on a feature branch.
- **NEVER** commit directly to `dev` or `main`.
- **ALWAYS** check if a file is gitignored before applying this workflow.
- **ALWAYS** create a worktree **BEFORE** calling any file-writing tools (write_to_file, replace_file_content, etc.).
- **ALWAYS** rebase on `dev` before pushing.
- **ALWAYS** use conventional commit format.
- **ALWAYS** add `.worktrees/` to your `.gitignore`.
- **ALWAYS** finish the workflow by creating a PR and removing the worktree once work is verified.
