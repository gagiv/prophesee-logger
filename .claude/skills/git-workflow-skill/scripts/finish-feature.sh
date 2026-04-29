#!/bin/bash
# finish-feature.sh - Rebase, validate, push, create PR, and clean up worktree
# Usage: finish-feature.sh [worktree-path]
#
# Run from inside a worktree, or pass the worktree path as an argument.
# After creating the PR, the worktree is removed automatically.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

error() { echo -e "${RED}ERROR: $1${NC}" >&2; exit 1; }
warn() { echo -e "${YELLOW}WARNING: $1${NC}" >&2; }
success() { echo -e "${GREEN}$1${NC}"; }
info() { echo -e "${CYAN}$1${NC}"; }

# Determine working directory
WORK_DIR="${1:-$(pwd)}"
cd "$WORK_DIR"

# Check we're in a git repo
git rev-parse --git-dir > /dev/null 2>&1 || error "Not in a git repository"

# Detect if we're in a worktree
GIT_COMMON=$(git rev-parse --git-common-dir 2>/dev/null)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
WORKTREE_PATH=$(git rev-parse --show-toplevel)

IS_WORKTREE=false
if [[ "$GIT_COMMON" != "$GIT_DIR" && "$GIT_COMMON" != "." ]]; then
    IS_WORKTREE=true
    MAIN_REPO=$(cd "$GIT_COMMON/.." && pwd)
    info "Working in worktree: ${WORKTREE_PATH}"
else
    MAIN_REPO="$WORKTREE_PATH"
    info "Working in main repository (not a worktree)"
fi

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Validate we're on a feature branch
if [[ "$CURRENT_BRANCH" == "dev" || "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
    error "You are on '$CURRENT_BRANCH'. Switch to a feature branch first."
fi

if ! echo "$CURRENT_BRANCH" | grep -qE '^(feature|bugfix|hotfix|chore)/'; then
    warn "Branch '$CURRENT_BRANCH' doesn't follow naming convention (feature|bugfix|hotfix|chore)/<description>"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    error "You have uncommitted changes. Please commit them first."
fi

# Check there are commits to push
COMMITS_AHEAD=$(git rev-list --count origin/dev..HEAD 2>/dev/null || echo "0")
if [[ "$COMMITS_AHEAD" == "0" ]]; then
    error "No commits to push. Make some changes first."
fi

echo "Found $COMMITS_AHEAD commit(s) to push"

# Validate commit messages
echo ""
echo "Validating commit messages..."
INVALID_COMMITS=0
while IFS= read -r commit_msg; do
    if ! echo "$commit_msg" | grep -qE '^(feat|fix|chore|docs|refactor|test)(\([^)]+\))?: .+'; then
        echo -e "${RED}  x Invalid: $commit_msg${NC}"
        INVALID_COMMITS=$((INVALID_COMMITS + 1))
    else
        echo -e "${GREEN}  + Valid: $commit_msg${NC}"
    fi
done < <(git log origin/dev..HEAD --pretty=format:"%s")

if [[ $INVALID_COMMITS -gt 0 ]]; then
    warn "$INVALID_COMMITS commit(s) don't follow conventional commit format"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 1
fi

# Fetch and rebase on dev
echo ""
echo "Fetching latest from origin..."
git fetch origin dev

echo "Rebasing on dev..."
if ! git rebase origin/dev; then
    error "Rebase failed. Resolve conflicts, then run 'git rebase --continue' and try again."
fi

success "Rebased successfully on dev"

# Push to remote
echo ""
echo "Pushing branch to origin..."
git push -u origin "$CURRENT_BRANCH" --force-with-lease

success "Branch '${CURRENT_BRANCH}' pushed to origin"

# Create Pull Request using gh CLI
echo ""
echo "Creating Pull Request..."

PR_CREATED=false

if ! command -v gh &> /dev/null; then
    warn "GitHub CLI (gh) not installed. Skipping PR creation."
    echo "Install gh: https://cli.github.com/"
elif ! gh auth status &> /dev/null; then
    warn "GitHub CLI not authenticated. Run: gh auth login"
else
    # Generate PR title from branch name
    PR_TITLE=$(echo "$CURRENT_BRANCH" | sed 's/^[^/]*\///' | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')

    # Get commit messages for PR body
    FIRST_COMMIT=$(git log origin/dev..HEAD --reverse --pretty=format:"%s" | head -1)

    if gh pr create --base dev --head "$CURRENT_BRANCH" --title "$PR_TITLE" --body "## Changes

$FIRST_COMMIT

## Commits
$(git log origin/dev..HEAD --pretty=format:"- %s")

---
Generated with [AI Agent Skills](https://github.com/mayafit/AI_Agents)"; then
        success "Pull Request created successfully"
        PR_URL=$(gh pr view "$CURRENT_BRANCH" --json url -q .url 2>/dev/null || echo "")
        if [[ -n "$PR_URL" ]]; then
            echo ""
            info "PR URL: ${PR_URL}"
        fi
        PR_CREATED=true
    else
        warn "Failed to create PR. You may need to create it manually."
    fi
fi

# Clean up worktree
if [[ "$IS_WORKTREE" == true ]]; then
    echo ""
    echo "Cleaning up worktree..."

    # Move back to main repo before removing the worktree
    cd "$MAIN_REPO"

    # Remove the worktree
    if git worktree remove "$WORKTREE_PATH" 2>/dev/null; then
        success "Worktree removed: ${WORKTREE_PATH}"
    else
        warn "Could not auto-remove worktree. Remove manually:"
        echo "  cd ${MAIN_REPO}"
        echo "  git worktree remove ${WORKTREE_PATH}"
    fi
else
    # Not a worktree — switch back to dev (legacy behavior)
    echo ""
    echo "Switching back to dev branch..."
    git checkout dev
    git pull origin dev
    success "Switched back to dev branch"
fi

# Prune stale worktree references
git worktree prune 2>/dev/null || true

echo ""
success "Done!"
echo ""
echo "Next steps:"
if [[ "$PR_CREATED" == true ]]; then
    echo "  1. Request code review on the PR"
    echo "  2. Merge after approval"
else
    echo "  1. Create a Pull Request to merge '${CURRENT_BRANCH}' into 'dev'"
    echo "  2. Request code review"
    echo "  3. Merge after approval"
fi
echo "  Start new work: ./scripts/start-feature.sh <type> <description>"
echo ""
echo "Active worktrees:"
git worktree list
