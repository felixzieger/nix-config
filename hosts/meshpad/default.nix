{ inputs, home-manager, lib, config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  services.nix-daemon.enable = true;
  nix = {
    settings = {
      "extra-experimental-features" = [ "nix-command" "flakes" ];
    };
  };
  programs.zsh.enable = true;

  home-manager =
    {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.fzieger = {
        home.username = lib.mkForce "fzieger";
        home.homeDirectory = lib.mkForce "/Users/fzieger";

        programs.lazygit.enable = true;
        programs.home-manager.enable = true;

        imports = [
          ./../../modules/fzf
          ./../../modules/zsh
          ./../../modules/git
          ./../../modules/neovim
          ./../../modules/tmux
        ];

        programs.zsh.initExtra = builtins.readFile ./zshrc;

        # Additional plugins for nvim
        home.packages = with pkgs; [
          terraform-ls
          nodePackages.vscode-langservers-extracted
          nodePackages.bash-language-server
          nodePackages.yaml-language-server
          gopls
        ];
        programs.neovim.plugins = with pkgs.vimPlugins; [
          # Languages
          vim-nix
          kotlin-vim
          dhall-vim
          vim-terraform

          null-ls-nvim # Part of vale setup, see https://bhupesh.me/writing-like-a-pro-with-vale-and-neovim/

          # Completions
          nvim-cmp
          cmp-nvim-lsp
          luasnip
          cmp_luasnip
          friendly-snippets
        ];

        # This value determines the home Manager release that your
        # configuration is compatible with. This helps avoid breakage
        # when a new home Manager release introduces backwards
        # incompatible changes.
        #
        # You can update home Manager without changing this value. See
        # the home Manager release notes for a list of state version
        # changes in each release.
        home.stateVersion = "23.11";
      };
    };

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      # cleanup = "zap";
      upgrade = true;
    };
    casks = [
      # "firefox"
      "raycast"
      "shottr"
      "rectangle"
      "spotify"
      "bitwarden"
      "monitorcontrol"
      "kitty"
    ];
  };

  system.defaults = {
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
    };
    dock = {
      autohide = true;
      orientation = "bottom";
      show-recents = false;
      static-only = true;
      show-process-indicators = false;
    };
  };

  environment.systemPackages = with pkgs;
    [
      systemctl-tui # view systemctl interactively
      sysz

      pkgs.btop
      pkgs.git
      pkgs.tig
      pkgs.tree
      pkgs.wget
      pkgs.starship
      pkgs.ripgrep
      pkgs.lsd # missing: icon support; https://github.com/Peltoche/lsd/issues/199#issuecomment-494218334
      pkgs.mycli
      pkgs.vscode
      pkgs.shellcheck
      pkgs.vale
      pkgs.bitwarden-cli
      pkgs.deno
      pkgs.gh


      pkgs.watchman

      pkgs.go
      pkgs.terraform
      pkgs.opentofu
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
      pkgs.pre-commit

      # Cloud CLIs
      pkgs.awscli2
      # pkgs.google-cloud-sdk # Managed externally, because of plugin gke-gcloud-auth-plugin
      # pkgs.azure-cli # Managed externall, because plugin installs fail otherwise
    ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

}
