# Git Hooks

This directory contains git hooks for the nixpkgs repository.

## Hooks

### pre-commit
- Runs on staged files only (fast)
- Checks only changed `.nix` files
- Runs Nix formatter and statix linter in parallel
- Skips entirely if no `.nix` files are changed

### pre-push
- Runs comprehensive checks on all files
- Ensures code quality before pushing to remote
- Runs `nix fmt` and `just lint` in parallel

## Installation

Run the install script to set up the hooks:

```bash
./hooks/install.sh
```

This will create symlinks from `.git/hooks/` to this directory, allowing the hooks to be version controlled.

## Manual Installation

If you prefer to install manually:

```bash
ln -sf ../../hooks/pre-commit .git/hooks/pre-commit
ln -sf ../../hooks/pre-push .git/hooks/pre-push
```