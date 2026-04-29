#!/bin/bash
# start-feature.sh - Create a new feature branch in an isolated worktree
# Usage: start-feature.sh <branch-type> <description>
# Example: start-feature.sh feature add-oauth-support
#
# Creates a git worktree so multiple agents can work in parallel
# without interfering with each other's working directories.

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

# Validate arguments
BRANCH_TYPE="$1"
DESCRIPTION="$2"

if [[ -z "$BRANCH_TYPE" || -z "$DESCRIPTION" ]]; then
    echo "Usage: $0 <branch-type> <description>"
    echo "Branch types: feature, bugfix, hotfix, chore"
    echo "Example: $0 feature add-oauth-support"
    echo ""
    echo "Creates an isolated worktree for parallel multi-agent development."
    exit 1
fi

# Validate branch type
case "$BRANCH_TYPE" in
    feature|bugfix|hotfix|chore) ;;
    *) error "Invalid branch type '$BRANCH_TYPE'. Use: feature, bugfix, hotfix, chore" ;;
esac

# Sanitize description (replace spaces with dashes, lowercase)
DESCRIPTION=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
BRANCH_NAME="${BRANCH_TYPE}/${DESCRIPTION}"

# Check we're in a git repo
git rev-parse --git-dir > /dev/null 2>&1 || error "Not in a git repository"

# Resolve the main repo root (works from inside a worktree too)
GIT_COMMON=$(git rev-parse --git-common-dir 2>/dev/null)
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)

if [[ "$GIT_COMMON" != "$GIT_DIR" && "$GIT_COMMON" != "." ]]; then
    # We're inside a worktree — resolve main repo from .git/worktrees/xxx/../../..
    MAIN_REPO=$(cd "$GIT_COMMON/.." && pwd)
else
    MAIN_REPO=$(git rev-parse --show-toplevel)
fi

WORKTREE_DIR="${MAIN_REPO}/.worktrees/${DESCRIPTION}"

# Fetch latest from remote
echo "Fetching from remote..."
git fetch origin

# Verify dev branch exists
if ! git branch -a | grep -qE '(^|\s)origin/dev$'; then
    error "Branch 'dev' does not exist on remote. Please create it first."
fi

# Check if branch already exists
if git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}" 2>/dev/null || \
   git show-ref --verify --quiet "refs/remotes/origin/${BRANCH_NAME}" 2>/dev/null; then
    error "Branch '${BRANCH_NAME}' already exists. Use a different description or clean up the old branch."
fi

# Check if worktree directory already exists
if [[ -d "$WORKTREE_DIR" ]]; then
    error "Worktree directory already exists: ${WORKTREE_DIR}
  To remove it: git worktree remove ${WORKTREE_DIR}"
fi

# Ensure .worktrees directory exists and is gitignored
mkdir -p "${MAIN_REPO}/.worktrees"
if [[ -f "${MAIN_REPO}/.gitignore" ]]; then
    if ! grep -q '^\.worktrees' "${MAIN_REPO}/.gitignore" 2>/dev/null; then
        echo ".worktrees/" >> "${MAIN_REPO}/.gitignore"
        info "Added .worktrees/ to .gitignore"
    fi
else
    echo ".worktrees/" > "${MAIN_REPO}/.gitignore"
    info "Created .gitignore with .worktrees/"
fi

# Create worktree with new branch based on origin/dev
echo "Creating worktree for '${BRANCH_NAME}'..."
git worktree add -b "$BRANCH_NAME" "$WORKTREE_DIR" origin/dev

success "Worktree created successfully"
echo ""
info "  Branch:    ${BRANCH_NAME}"
info "  Directory: ${WORKTREE_DIR}"
echo ""
echo "Next steps:"
echo "  1. cd ${WORKTREE_DIR}"
echo "  2. Make your changes in this isolated directory"
echo "  3. Commit: git commit -m 'type(scope): description'"
echo "  4. Finish: run finish-feature.sh from inside the worktree"
echo ""
echo "Active worktrees:"
git worktree list
