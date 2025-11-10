# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

All commands below are available in the devenv shell. Enter the shell with `devenv shell` or let direnv activate it automatically.

- `just-gc [generations]` - Garbage collect old generations (default: 5d)
- `nix flake check` - Validate the flake configuration
- `nix flake update` - Update all flake inputs

Do not try to switch to new configurations. The user will always do this themselves.

### Formatting
- Linux: Automatically runs `nix fmt` before building
- Use `nixfmt-rfc-style` formatter (defined in flake.nix)

## Repository Architecture

This is a Nix flake-based configuration for managing NixOS servers and macOS systems. The repository uses a modular structure with the following key components:

### Directory Structure
- `/hosts/` - Machine-specific configurations
  - `/common/` - Shared configuration for all hosts
  - `/nixos/` - NixOS-specific shared configuration
  - `/macbook/` - macOS-specific shared configuration
  - Individual host directories: `schwalbe`, `hedwig`, `blausieb`, `schenkerpad`
- `/modules/` - Reusable configuration modules (neovim, git, tmux, shell tools)
- `/services/` - Service configurations for self-hosted applications
- `/secrets/` - Encrypted secrets managed with agenix

### Key Dependencies
- **nixpkgs**: Both stable (25.05) and unstable channels
- **home-manager**: User environment management
- **agenix**: Secret encryption and management
- **nix-darwin**: macOS system configuration
- **nix-bitcoin**: Bitcoin node setup
- **simple-nixos-mailserver**: Email server
- **mac-app-util**: macOS application management
- **nix-homebrew**: Homebrew integration for macOS

### Host Systems
- **macbook**: macOS development machine; daily driver
- **schwalbe**: Bitcoin node
- **hedwig**: Mail server
- **blausieb**: Primary server with many services
- **schenkerpad**: Linux laptop

### Important Conventions
1. **Secret Management**: All secrets are encrypted using agenix. Never commit unencrypted secrets.
2. **Service Organization**: Each service gets its own file in `/services/`. File name follows the url the service is reachable under.
3. **Backup System**: Uses restic with Backblaze B2 backend
4. **Module Pattern**: Common functionality is extracted into modules for reuse across hosts
