# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### macOS Development
- `just` or `just switch` - Build and switch to the new configuration
- `just build [target_host]` - Build configuration without switching
- `just trace [target_host]` - Build with --show-trace for debugging
- `just switch-linux [target_host]` - Deploy to a Linux host from macOS

### NixOS/Linux Development
- `just switch [target_host]` - Build and switch configuration (uses sudo)
- `just build [target_host]` - Build configuration without switching
- `just trace [target_host]` - Build with --show-trace for debugging

### Maintenance
- `just gc [generations]` - Garbage collect old generations (default: 5d)
- `nix flake check` - Validate the flake configuration
- `nix flake update` - Update all flake inputs

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
2. **Service Organization**: Each service gets its own file in `/services/`
3. **Remote Deployment**: Use `just switch-linux [host]` from macOS to deploy to Linux hosts
4. **Backup System**: Uses restic with Backblaze B2 backend
5. **Module Pattern**: Common functionality is extracted into modules for reuse across hosts
