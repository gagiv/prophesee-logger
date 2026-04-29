#!/bin/bash
# validate-workflow.sh - Check if current state follows git workflow rules
# Usage: validate-workflow.sh [--list]
#
# Worktree-aware: detects whether you're in a worktree or main repo
# and validates accordingly.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

error() { echo -e "${RED}x ERROR: $1${NC}"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "${YELLOW}! WARNING: $1${NC}"; WARNINGS=$((WARNINGS + 1)); }
ok() { echo -e "${GREEN}+ $1${NC}"; }
info() { echo -e "  $1"; }

# Handle --list flag to show active worktrees
if [[ "$1" == "--list" ]]; then
    echo "Active Worktrees"
    echo "================"
    git worktree list 2>/dev/null || echo "Not in a git repository"
    exit 0
fi

echo "Git Workflow Validation (Worktree-Aware)"
echo "========================================="
echo ""

# Check we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not in a git repository"
    exit 1
fi

# Detect worktree status
GIT_COMMON=$(git rev-parse --git-common-dir 2>/dev/null)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
CURRENT_DIR=$(git rev-parse --show-toplevel)

IS_WORKTREE=false
if [[ "$GIT_COMMON" != "$GIT_DIR" && "$GIT_COMMON" != "." ]]; then
    IS_WORKTREE=true
    MAIN_REPO=$(cd "$GIT_COMMON/.." && pwd)
    echo -e "${CYAN}Context: Inside worktree${NC}"
    info "Worktree: $CURRENT_DIR"
    info "Main repo: $MAIN_REPO"
else
    MAIN_REPO="$CURRENT_DIR"
    echo -e "${CYAN}Context: Main repository${NC}"
    info "Repo: $MAIN_REPO"
fi

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Branch: $CURRENT_BRANCH"
echo ""

# Check 1: Not on protected branch
echo "Checking branch..."
if [[ "$CURRENT_BRANCH" == "dev" || "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
    if [[ "$IS_WORKTREE" == true ]]; then
        error "Worktree is on protected branch '$CURRENT_BRANCH'. Worktrees should be on feature branches."
    else
        # Main repo on dev is fine — that's the expected state
        ok "Main repo is on '$CURRENT_BRANCH' (expected)"
    fi
else
    ok "On feature branch '$CURRENT_BRANCH'"
fi

# Check 2: Branch naming convention (only for feature branches)
if [[ "$CURRENT_BRANCH" != "dev" && "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "master" ]]; then
    if echo "$CURRENT_BRANCH" | grep -qE '^(feature|bugfix|hotfix|chore)/[a-z0-9-]+$'; then
        ok "Branch name follows convention"
    else
        warn "Branch name '$CURRENT_BRANCH' doesn't follow convention: <type>/<description>"
        info "Expected: feature|bugfix|hotfix|chore followed by lowercase alphanumeric with dashes"
    fi
fi

# Check 3: dev branch exists
echo ""
echo "Checking repository setup..."
git fetch origin 2>/dev/null || warn "Could not fetch from origin"

if git branch -a | grep -qE '(^|\s)origin/dev$'; then
    ok "Remote 'dev' branch exists"
else
    error "Remote 'dev' branch not found. Create it before using this workflow."
fi

# Check 4: Up to date with dev (for feature branches)
echo ""
echo "Checking sync status..."
if [[ "$CURRENT_BRANCH" != "dev" && "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "master" ]]; then
    if git branch -a | grep -qE '(^|\s)origin/dev$'; then
        BEHIND=$(git rev-list --count HEAD..origin/dev 2>/dev/null || echo "0")
        if [[ "$BEHIND" == "0" ]]; then
            ok "Branch is up to date with dev"
        else
            warn "Branch is $BEHIND commit(s) behind dev. Consider rebasing."
            info "Run: git fetch origin dev && git rebase origin/dev"
        fi
    fi
else
    ok "On base branch — sync check not needed"
fi

# Check 5: Uncommitted changes
echo ""
echo "Checking working directory..."
if git diff-index --quiet HEAD -- 2>/dev/null; then
    ok "No uncommitted changes"
else
    warn "Uncommitted changes detected"
    info "Run: git status"
fi

# Check 6: Untracked files (that aren't ignored)
UNTRACKED=$(git ls-files --others --exclude-standard | wc -l)
if [[ "$UNTRACKED" -gt 0 ]]; then
    warn "$UNTRACKED untracked file(s) found"
    info "Run: git status"
else
    ok "No untracked files"
fi

# Check 7: Validate recent commit messages (for feature branches)
echo ""
echo "Checking commit messages..."
if [[ "$CURRENT_BRANCH" != "dev" && "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "master" ]]; then
    COMMITS=$(git rev-list --count origin/dev..HEAD 2>/dev/null || echo "0")
    if [[ "$COMMITS" -gt 0 ]]; then
        INVALID=0
        while IFS= read -r msg; do
            if ! echo "$msg" | grep -qE '^(feat|fix|chore|docs|refactor|test)(\([^)]+\))?: .+'; then
                INVALID=$((INVALID + 1))
            fi
        done < <(git log origin/dev..HEAD --pretty=format:"%s" 2>/dev/null)

        if [[ "$INVALID" -eq 0 ]]; then
            ok "All $COMMITS commit(s) follow conventional format"
        else
            warn "$INVALID of $COMMITS commit(s) don't follow conventional format"
            info "Format: <type>(<scope>): <description>"
            info "Types: feat, fix, chore, docs, refactor, test"
        fi
    else
        info "No commits ahead of dev yet"
    fi
else
    info "On base branch — commit check not needed"
fi

# Check 8: Git hooks installed
echo ""
echo "Checking git hooks..."
HOOKS_DIR="${GIT_COMMON}/hooks"
if [[ "$IS_WORKTREE" == true ]]; then
    # Worktrees share hooks with the main repo
    HOOKS_DIR="${GIT_COMMON}/hooks"
fi

if [[ -f "$HOOKS_DIR/pre-commit" && -x "$HOOKS_DIR/pre-commit" ]]; then
    ok "pre-commit hook installed"
else
    warn "pre-commit hook not installed"
    info "Run: ./scripts/install-hooks.sh"
fi

if [[ -f "$HOOKS_DIR/commit-msg" && -x "$HOOKS_DIR/commit-msg" ]]; then
    ok "commit-msg hook installed"
else
    warn "commit-msg hook not installed"
    info "Run: ./scripts/install-hooks.sh"
fi

# Check 9: Worktree health
echo ""
echo "Checking worktrees..."
WORKTREE_COUNT=$(git worktree list | wc -l)
ok "$WORKTREE_COUNT worktree(s) registered"

# Check for stale worktrees
STALE_COUNT=$(git worktree list --porcelain | grep -c "^prunable" 2>/dev/null || echo "0")
if [[ "$STALE_COUNT" -gt 0 ]]; then
    warn "$STALE_COUNT stale worktree(s) found"
    info "Run: git worktree prune"
else
    ok "No stale worktrees"
fi

# Check .worktrees in .gitignore
if [[ -f "${MAIN_REPO}/.gitignore" ]]; then
    if grep -q '^\.worktrees' "${MAIN_REPO}/.gitignore" 2>/dev/null; then
        ok ".worktrees/ is in .gitignore"
    else
        warn ".worktrees/ is NOT in .gitignore"
        info "Add '.worktrees/' to your .gitignore"
    fi
fi

# List active worktrees
echo ""
echo "Active worktrees:"
git worktree list | while IFS= read -r line; do
    echo "  $line"
done

# Summary
echo ""
echo "========================================="
if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}Validation failed: $ERRORS error(s), $WARNINGS warning(s)${NC}"
    exit 1
elif [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}Validation passed with $WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${GREEN}Validation passed: All checks OK${NC}"
    exit 0
fi
