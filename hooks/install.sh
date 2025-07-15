#!/usr/bin/env bash

# Install git hooks by creating symlinks

set -e

HOOKS_DIR="$(dirname "$0")"
GIT_HOOKS_DIR="$(git rev-parse --git-dir)/hooks"

echo "Installing git hooks..."

# Install pre-commit hook
if [ -f "$GIT_HOOKS_DIR/pre-commit" ] && [ ! -L "$GIT_HOOKS_DIR/pre-commit" ]; then
    echo "Backing up existing pre-commit hook to pre-commit.backup"
    mv "$GIT_HOOKS_DIR/pre-commit" "$GIT_HOOKS_DIR/pre-commit.backup"
fi
ln -sf "../../hooks/pre-commit" "$GIT_HOOKS_DIR/pre-commit"
echo "✅ Installed pre-commit hook"

# Install pre-push hook
if [ -f "$GIT_HOOKS_DIR/pre-push" ] && [ ! -L "$GIT_HOOKS_DIR/pre-push" ]; then
    echo "Backing up existing pre-push hook to pre-push.backup"
    mv "$GIT_HOOKS_DIR/pre-push" "$GIT_HOOKS_DIR/pre-push.backup"
fi
ln -sf "../../hooks/pre-push" "$GIT_HOOKS_DIR/pre-push"
echo "✅ Installed pre-push hook"

echo "✅ All hooks installed successfully!"