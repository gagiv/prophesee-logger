#!/bin/bash
# install-hooks.sh - Install git hooks for workflow enforcement
# Usage: install-hooks.sh [hooks-source-dir]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

error() { echo -e "${RED}ERROR: $1${NC}" >&2; exit 1; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
warn() { echo -e "${YELLOW}WARNING: $1${NC}"; }

# Check we're in a git repo
git rev-parse --git-dir > /dev/null 2>&1 || error "Not in a git repository"

# Find hooks source directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_SOURCE="${1:-$SCRIPT_DIR/../hooks}"

if [[ ! -d "$HOOKS_SOURCE" ]]; then
    error "Hooks source directory not found: $HOOKS_SOURCE"
fi

# Get git hooks directory
GIT_DIR=$(git rev-parse --git-dir)
HOOKS_DEST="$GIT_DIR/hooks"

echo "Installing git hooks..."
echo "Source: $HOOKS_SOURCE"
echo "Destination: $HOOKS_DEST"
echo ""

# Install each hook
for hook in pre-commit commit-msg prepare-commit-msg; do
    if [[ -f "$HOOKS_SOURCE/$hook" ]]; then
        if [[ -f "$HOOKS_DEST/$hook" ]]; then
            warn "Hook '$hook' already exists, backing up to ${hook}.backup"
            cp "$HOOKS_DEST/$hook" "$HOOKS_DEST/${hook}.backup"
        fi
        cp "$HOOKS_SOURCE/$hook" "$HOOKS_DEST/$hook"
        chmod +x "$HOOKS_DEST/$hook"
        success "Installed: $hook"
    fi
done

echo ""
success "Git hooks installed successfully"
echo ""
echo "Installed hooks:"
echo "  - pre-commit: Blocks commits on dev/main branches"
echo "  - commit-msg: Validates conventional commit format"
echo "  - prepare-commit-msg: Adds commit template"
