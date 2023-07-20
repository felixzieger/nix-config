{ config, pkgs, ... }:


{
  nixpkgs.config.allowUnfree = true;
  environment.variables.EDITOR = "vim";

  # To find packages use https://search.nixos.org/packages
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
      pkgs.nerdfonts
      # pkgs.tmux
      pkgs.mycli
      pkgs.vscode
      pkgs.shellcheck
      pkgs.vale
      pkgs.ipcalc
      pkgs.asciinema
      pkgs.asciinema-scenario
      pkgs.bitwarden-cli
      pkgs.deno

      # Language Servers
      pkgs.terraform-ls
      pkgs.rnix-lsp
      pkgs.nodePackages.vscode-langservers-extracted
      pkgs.nodePackages.bash-language-server
      pkgs.nodePackages.yaml-language-server
      pkgs.gopls

      pkgs.go
      pkgs.terraform
      pkgs.terraform-docs
      pkgs.terragrunt
      pkgs.pass
      pkgs.parallel
      pkgs.kubectl
      pkgs.k9s
      pkgs.nodejs
      pkgs.vault
      pkgs.jq
      pkgs.yarn
      pkgs.kotlin
      pkgs.jdk
      pkgs.python39
      # pkgs.google-cloud-sdk # Managed externally, because of plugin gke-gcloud-auth-plugin
      pkgs.azure-cli
      pkgs.awscli2
      pkgs.pre-commit
      pkgs.tldr
      pkgs.bat # Used for FZF preview in vim

      pkgs.erlang
      pkgs.elixir
      pkgs.elixir_ls
      pkgs.postgresql

      (
        pkgs.neovim.override {
          viAlias = true;
          vimAlias = true;
          configure = {
            packages.myPlugins = with pkgs.vimPlugins; {
              start = [
                nvim-lspconfig
                vim-sleuth # Work out tabs vs spaces etc. automatically.

                lualine-nvim
                nvim-web-devicons
                git-blame-nvim # Git blame with lualine-nvim integration

                vim-commentary # gcc
                vim-fugitive # :Git

                fzf-vim # <leader>f/b/a
                nvim-tree-lua # <leader>n
                vim-easymotion # <leader>j/k/s

                # Languages
                vim-nix
                kotlin-vim
                dhall-vim
                vim-terraform
                vim-elixir

                null-ls-nvim # Part of vale setup, see https://bhupesh.me/writing-like-a-pro-with-vale-and-neovim/
              ];
              opt = [ ];
            };
            customRC = builtins.readFile ./neovim.vim;
          };
        }
      )
    ]
    ++ (import ./versions.nix)
  ;

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

  programs.tmux =
    {
      enable = true;
      extraConfig = ''
        set -g mouse on
        set -g default-terminal "xterm-256color"
        set-option -g history-limit 100000
      '';
    };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
