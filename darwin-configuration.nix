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

{
  # Do not use home-manager as it gives errors with runCommand
  # imports = [ <home-manager/nix-darwin> ];

  # users.users.fzieger = {
  #   name = "fzieger";
  #   home = "/Users/fzieger";
  #   shell = pkgs.zsh;
  # };
  # users.users.xilef = {
  #   name = "xilef";
  #   home = "/Users/xilef";
  #   shell = pkgs.zsh;
  # };

  # home-manager = {
  #   useGlobalPkgs = true;
  # };

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
      pkgs.lsd # missing: icon support; https://github.com/Peltoche/lsd/issues/199#issuecomment-494218334
      # pkgs.nerdfonts
      pkgs.tmux
      pkgs.mycli
      pkgs.vscode
      pkgs.shellcheck
      pkgs.vale
      pkgs.ipcalc

      # Vim Stuff
      pkgs.code-minimap # Used by minimap-vim

      # Language Servers
      pkgs.terraform-ls
      pkgs.rnix-lsp
      pkgs.nodePackages.vscode-langservers-extracted
      pkgs.nodePackages.bash-language-server
      pkgs.nodePackages.yaml-language-server
      # pkgs.dhall-lsp-server # todo: fix version

      # pkgs.dhall # todo: fix version
      # pkgs.dhall-json # todo: fix version
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
      pkgs.deno
      pkgs.pre-commit
      pkgs.tldr

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
      # pkgs.keepassxc # Install went through but did not show up when I wanted to use it. 
      # pkgs.iterm2 # Code signing stuff
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
                fzf-vim # <leader>f/b/a; Alternative: telescope
                vim-commentary # TLDR: gcc for quick un/commenting
                git-blame-nvim # Git blame with lualine-nvim integration
                lualine-nvim
                vim-fugitive # :Git
                minimap-vim # <leader>m
                nvim-tree-lua # <leader>n


                # Languages
                vim-nix
                kotlin-vim
                dhall-vim
                ansible-vim
                vim-terraform # Alternative: vim-terraform-completion

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
