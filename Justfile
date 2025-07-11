# Copied from https://github.com/bcotton/nix-config/blob/main/Justfile

# Build the system config and switch to it when running `just` with no args
default: switch

hostname := `hostname | cut -d "." -f 1`

# Lint Nix files using statix
lint:
  @echo "Linting Nix files with statix..."
  @statix check . || echo "Found $(statix check . 2>&1 | grep -c 'Warning:') warnings"

### macos
# Build the nix-darwin system configuration without switching to it
[macos]
build target_host=hostname flags="":
  @echo "Building nix-darwin config..."
  # nix fmt # my flake doesn't offer a formatter, so I leave it out for now
  nix --extra-experimental-features 'nix-command flakes'  build ".#darwinConfigurations.{{target_host}}.system" {{flags}}

# Build the nix-darwin config with the --show-trace flag set
[macos]
trace target_host=hostname: (build target_host "--show-trace")

# Build the nix-darwin configuration and switch to it
[macos]
switch target_host=hostname: (build target_host)
  @echo "switching to new config for {{target_host}}"
  ./result/sw/bin/darwin-rebuild switch --flake ".#{{target_host}}"

[macos]
switch-linux target_host:
  # from https://paretosecurity.com/blog/being-a-happy-nixer-on-a-mac/
  # Sometimes, after reinstalling nix-darwin, the linux-builder can't be reached. Fix this via
  # sudo su -
  # ssh linux-builder
  # exit

  nixos-rebuild switch --fast --flake .#{{target_host}} --target-host {{target_host}} --use-remote-sudo --use-substitutes


### linux
# Build the NixOS configuration without switching to it
[linux]
build target_host=hostname flags="":
  nix fmt
  nixos-rebuild build --flake .#{{target_host}} {{flags}}

# Build the NixOS config with the --show-trace flag set
[linux]
trace target_host=hostname: (build target_host "--show-trace")

# Build the NixOS configuration and switch to it.
[linux]
switch target_host=hostname:
  sudo nixos-rebuild switch --flake .#{{target_host}}

# Garbage collect old OS generations and remove stale packages from the nix store
gc generations="5d":
  nix-env --delete-generations {{generations}}
  nix-collect-garbage --delete-older-than {{generations}}
  nix-store --gc
