# Repository Guidelines

## Project Structure & Module Organization
- `flake.nix`: Flake entry; defines hosts, packages, formatter.
- `hosts/`: Machine configs (e.g., `hosts/nixos/schwalbe/configuration.nix`, `hosts/macbook`).
- `modules/`: Reusable Nix modules for shared logic.
- `services/`: Service modules (e.g., `services/nginx.nix`, `services/docker.nix`).
- `packages/`: Custom derivations (e.g., `packages/context-creator.nix`).
- `secrets/`: Encrypted secrets managed via agenix.
- `Justfile`: Build/run tasks for Linux and macOS.

## Build, Test, and Development Commands
- `just lint`: Run statix checks on `.nix` files.
- `nix fmt`: Format using the flake’s `nixfmt-rfc-style`.
- Linux
  - `just build target_host=<host>`: Build NixOS config.
  - `just switch target_host=<host>`: Switch to built config (sudo).
- macOS
  - `just build target_host=<host>`: Build nix-darwin config.
  - `just switch target_host=<host>`: Switch using `darwin-rebuild`.
- Debug: `just trace target_host=<host>` adds `--show-trace`.

## Coding Style & Naming Conventions
- Run `nix fmt` before committing; keep diffs clean.
- Lint with `statix check .` (or `just lint`).
- Filenames: lowercase, hyphenated, end with `.nix`.
- Modules: prefer small, composable files under `modules/` and `services/`.

## Testing Guidelines
- Treat tests as evaluation + build:
  - `just build target_host=<host>` must succeed.
  - Use `just trace` to iterate on failures.
- Optionally add `flake checks` and run `nix flake check`.

## Commit & Pull Request Guidelines
- Commits: short, imperative, lowercase (e.g., "update inputs", "fix lsp").
- Scope clearly (service/module/host) and group related changes.
- PRs: include a summary, affected hosts/services, and commands run (e.g., `just build target_host=schwalbe`). Link issues when applicable.

## Security & Configuration Tips
- Secrets: commit only encrypted `.age` files under `secrets/` via agenix.
- Keys: ensure age recipients exist for hosts/users before switching.
- Avoid committing machine-local state; keep host config in `hosts/<platform>/<host>/`.

