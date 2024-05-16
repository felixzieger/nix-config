{ inputs, home-manager, lib, config, pkgs, nixpkgs-unstable, ... }:
let
  unstable = import nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
  gcloud = pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
    gke-gcloud-auth-plugin
  ]);
in
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

        programs.home-manager.enable = true;

        imports = [
          ./../../modules/fzf
          ./../../modules/zsh
          ./../../modules/git
          ./../../modules/neovim
          (import ./../../modules/tmux { inherit unstable; })
        ];

        programs.zsh.initExtra = builtins.readFile ./zshrc;

        # Additional plugins for nvim
        home.packages = with pkgs; [
          terraform-ls
          nodePackages.vscode-langservers-extracted
          gopls
        ];
        programs.neovim.plugins = with pkgs.vimPlugins; [
          # Languages
          kotlin-vim
          dhall-vim
          vim-terraform

          friendly-snippets
          {
            plugin = nvim-lspconfig;
            type = "lua";
            config = builtins.readFile ./nvim-lspconfig.lua;
          }
        ];

        programs.k9s.enable = true;
        programs.k9s.package = unstable.k9s;
        programs.k9s.plugin = {
          db-connect = {
            shortCut = "Ctrl-J";
            description = "Open DB";
            scopes =
              [ "pod" ];
            command = "kubectl";
            background = "false";
            args = [
              "--context"
              "$CONTEXT"
              "-n"
              "$NAMESPACE"
              "exec"
              "-it"
              "$NAME"
              "--"
              "bash"
              "-c"
              "mysql -u $MARIADB_USER -p$MARIADB_PASSWORD $MARIADB_DATABASE"
            ];
          };
        };

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
      upgrade = true;
    };
    brews = [
      "azure-cli"
    ];
    casks = [
      # "firefox"
      "raycast"
      "logi-options-plus"
      "shottr"
      "rectangle"
      "spotify"
      "bitwarden"
      "monitorcontrol"
      "kitty"
      "visual-studio-code"
      "bruno"
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


  environment.variables.EDITOR = "nvim";
  environment.systemPackages = 
    [
      pkgs.btop
      pkgs.git
      pkgs.tig
      pkgs.tree
      pkgs.wget
      pkgs.ripgrep
      pkgs.lsd # missing: icon support; https://github.com/Peltoche/lsd/issues/199#issuecomment-494218334
      pkgs.mycli
      pkgs.shellcheck
      pkgs.bitwarden-cli
      pkgs.deno
      pkgs.gh


      pkgs.watchman

      pkgs.go
      pkgs.opentofu
      pkgs.terraform
      pkgs.terraform-docs
      unstable.terragrunt # unstable because support for opentofu got better after 23.10
      pkgs.pass
      pkgs.parallel
      pkgs.kubectl
      unstable.k9s # untstable because plugins didn't work with 23.10
      pkgs.nodejs
      unstable.vault-bin # untstable because stable in 23.10 had CVE-2024-2660
      pkgs.jq
      pkgs.yarn
      pkgs.kotlin
      pkgs.jdk
      pkgs.python39
      pkgs.pre-commit

      pkgs.cntlm

      # Cloud CLIs
      pkgs.openshift
      pkgs.cloudfoundry-cli
      pkgs.openstackclient
      pkgs.awscli2
      gcloud
      # pkgs.azure-cli # Managed via brew, because plugin installs fail otherwise
    ]
    # I haven't figured out how to fix the dhall versions in the new flakes based setup yet
    # ++ import (./versions.nix)
  ;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
