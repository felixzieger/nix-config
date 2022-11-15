{ config, pkgs, ... }:

# For setup I followed
# https://wickedchicken.github.io/post/macos-nix-setup/

# Inspiration
# https://github.com/a-h/dotfiles/blob/master/.nixpkgs/darwin-configuration.nix
# AWESOME: https://github.com/kubukoz/nix-config
# https://www.nmattia.com/posts/2018-03-21-nix-reproducible-setup-linux-macos.html
# https://markhudnall.com/2021/01/27/first-impressions-of-nix/

# Search packages at https://search.nixos.org/packages

# Home manager <-> nix-darwin integration
# https://nix-community.github.io/home-manager/index.html#sec-install-nix-darwin-module

# Configuration collection
# AWESOME: https://github.com/biosan/dotfiles
# Has LOGITECH and other brew stuff as file: https://github.com/biosan/dotfiles/blob/master/config/macos/Brewfile
# https://nixos.wiki/wiki/Configuration_Collection



# Fixing packages
# 1. Find out which package is needed under https://search.nixos.org/packages
# 2. Search package under https://lazamar.co.uk/nix-versions/ and pick version
# 3. Extract the packages as per instructions
# 4. Add packages in pkgs.mkShell
let
  fix_deno = (import
    (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/bf972dc380f36a3bf83db052380e55f0eaa7dcb6.tar.gz";
    })
    { }).deno;

  pkgs_fix_dhall = import
    (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/d86bcbb415938888e7f606d55c52689aec127f43.tar.gz";
    })
    { };

  fix_dhall = pkgs_fix_dhall.haskellPackages.dhall_1_41_1; # https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=dhall
  fix_dhall_docs = pkgs.haskellPackages.dhall-docs; # https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=dhall-docs
  fix_dhall_json = pkgs.haskellPackages.dhall-json; # https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=dhall-json
  fix_dhall_yaml = pkgs.haskellPackages.dhall-yaml; # https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=dhall-yaml

  fix_dhall_lsp_server = (import
    (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/89f196fe781c53cb50fef61d3063fa5e8d61b6e5.tar.gz"; # https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=dhall-lsp-server
    })
    { }).dhall-lsp-server;

in
{
  nixpkgs.config.allowUnfree = true;
  environment.variables.EDITOR = "vim";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [
      pkgs.git
      pkgs.tree
      pkgs.wget
      pkgs.oh-my-zsh
      pkgs.starship
      pkgs.zsh-z
      pkgs.fzf # add ZSH shortcuts by following https://nixos.wiki/wiki/Fzf
      pkgs.silver-searcher
      pkgs.ripgrep
      pkgs.lsd # missing: icon support; https://github.com/Peltoche/lsd/issues/199#issuecomment-494218334
      # pkgs.nerdfonts
      pkgs.tmux
      pkgs.mycli
      pkgs.vscode
      pkgs.shellcheck
      pkgs.vale
      pkgs.ipcalc
      pkgs.asciinema
      pkgs.asciinema-scenario

      # Azure IPAM deployment
      pkgs.powershell
      pkgs.clang

      # Vim Stuff
      pkgs.code-minimap # Used by minimap-vim

      # Language Servers
      pkgs.terraform-ls
      pkgs.rnix-lsp
      pkgs.nodePackages.vscode-langservers-extracted
      pkgs.nodePackages.bash-language-server
      pkgs.nodePackages.yaml-language-server
      fix_dhall_lsp_server

      fix_dhall
      fix_dhall_json
      fix_dhall_yaml
      pkgs.terraform
      pkgs.terraform-docs
      pkgs.terragrunt
      # pkgs.pass # fails to build
      pkgs.fly
      pkgs.parallel
      pkgs.kubectl
      pkgs.k9s
      pkgs.nodejs
      pkgs.vault
      pkgs.jq
      pkgs.yarn
      pkgs.kotlin
      pkgs.jdk
      # pkgs.google-cloud-sdk # Managed externally, because of plugin gke-gcloud-auth-plugin
      pkgs.azure-cli
      # pkgs.awscli2
      # pkgs.deno
      fix_deno
      pkgs.pre-commit
      pkgs.tldr
      pkgs.bat # Used for FZF preview in vim

      # pkgs.zoom-us # Now has darwin support, but i am too lazy to switch from the package right now
      # pkgs.teams # Now has darwin support, but i am too lazy to switch from the package right now
      # pkgs.alacritty # Too lazy to switch
      # pkgs.slack # Too lazy to switch


      pkgs.php
      pkgs.python39
      # Still making problems...
      # pkgs.firefox # maybe https://github.com/cmacrae/config/tree/b33ccb041861b56c97e1744b0fd8c606e343164c/overlays/firefox
      # pkgs.autoconf # needed for idea-community as of 2021-11-13?
      # pkgs.jetbrains.idea-community
      #
      # Linux support
      # pkgs.flameshot # https://github.com/flameshot-org/flameshot
      # pkgs.nextcloud-client
      # pkgs.sublime-merge
      # pkgs.spotify
      #
      # Find out how to install
      # https://github.com/rxhanson/Rectangle
      # Alfred
      # Alfred can show applciations installed via nix. See https://markhudnall.com/2021/01/27/first-impressions-of-nix/
      #
      #From https://github.com/a-h/dotfiles/blob/master/.nixpkgs/darwin-configuration.nix
      (
        pkgs.neovim.override {
          viAlias = true;
          vimAlias = true;
          configure = {
            packages.myPlugins = with pkgs.vimPlugins; {
              start = [
                nvim-lspconfig

                lualine-nvim
                nvim-web-devicons
                git-blame-nvim # Git blame with lualine-nvim integration

                vim-commentary # gcc
                vim-fugitive # :Git

                fzf-vim # <leader>f/b/a
                minimap-vim # <leader>m
                nvim-tree-lua # <leader>n
                vim-easymotion # <leader><leader>w/b/f/F AND <leader>j/k

                telescope-nvim # <leader>ff/fb/fa
                telescope-fzf-native-nvim
                plenary-nvim

                # Languages
                vim-nix
                kotlin-vim
                dhall-vim
                ansible-vim
                vim-terraform

                null-ls-nvim # Part of vale setup, see https://bhupesh.me/writing-like-a-pro-with-vale-and-neovim/
              ];
              opt = [ ];
            };
            customRC = builtins.readFile ./neovim.vim;
          };
        }
      )
    ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  programs.zsh = {
    enable = true;
    # oh-my-zsh = {
    #   enable = true;
    #   plugins = [ "git" "thefuck" ];
    #   theme = "robbyrussell";
    # };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
