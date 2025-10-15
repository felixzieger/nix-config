# Copied from https://github.com/bcotton/nix-config/blob/main/Justfile

# Build the system config and switch to it when running `just` with no args
default: switch

hostname := `hostname | cut -d "." -f 1`

### macos

# Build the nix-darwin configuration and switch to it
[macos]
switch target_host=hostname:
  @echo "switching to new config for {{target_host}}"
  sudo darwin-rebuild switch --flake ".#{{target_host}}"

[macos]
switch-linux target_host:
  # from https://paretosecurity.com/blog/being-a-happy-nixer-on-a-mac/
  # Sometimes, after reinstalling nix-darwin, the linux-builder can't be reached. Fix this via
  # sudo su -
  # ssh linux-builder
  # exit

  nixos-rebuild switch --fast --flake .#{{target_host}} --target-host {{target_host}} --use-remote-sudo --use-substitutes


### linux

# Build the NixOS configuration and switch to it.
[linux]
switch target_host=hostname:
  sudo nixos-rebuild switch --flake .#{{target_host}}

# Garbage collect old OS generations and remove stale packages from the nix store
gc generations="5d":
  nix-collect-garbage --delete-older-than {{generations}}
