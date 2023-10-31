# nix-config

Path for darwin: `~/.nixpkgs`

For setup I followed https://wickedchicken.github.io/post/macos-nix-setup/

For Home manager <-> nix-darwin integration I consulted https://nix-community.github.io/home-manager/index.html#sec-install-nix-darwin-module

## Configuration collection & Inspiration
https://github.com/a-h/dotfiles
https://github.com/kubukoz/nix-config
https://github.com/lovesegfault/nix-config

https://nixos.wiki/wiki/Configuration_Collection
https://github.com/biosan/dotfiles
https://www.nmattia.com/posts/2018-03-21-nix-reproducible-setup-linux-macos.html
https://markhudnall.com/2021/01/27/first-impressions-of-nix/


## For future installations I might want to play with

### GUI applications do not play together with Spotlight for me
Alfred could show applications installed via nix. See https://markhudnall.com/2021/01/27/first-impressions-of-nix/
pkgs.zoom-us
pkgs.teams
pkgs.alacritty
pkgs.slack
pkgs.firefox
pkgs.jetbrains.idea-community

### Linux support only
pkgs.flameshot # https://github.com/flameshot-org/flameshot
pkgs.nextcloud-client
pkgs.sublime-merge
pkgs.spotify

### Find out how to install
https://github.com/rxhanson/Rectangle
