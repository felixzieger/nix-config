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
  programs.fish.enable = true;

  users.users.xilef.shell = pkgs.fish;

  home-manager =
    {
      useGlobalPkgs = true;
      useUserPackages = true;
            users.xilef = {
        home.username = lib.mkForce "xilef";
        home.homeDirectory = lib.mkForce "/Users/xilef";

        programs.home-manager.enable = true;

        imports = [
          ./../../modules/fzf
          ./../../modules/git
          ./../../modules/neovim
          ./../../modules/tmux
        ];

        programs.zsh.enable = false;
        programs.fish.enable = true;

        # Additional plugins for tmux
        programs.tmux.plugins = [ unstable.tmuxPlugins.fzf-tmux-url ]; #  Open Hyperlink-Picker via CTRL+b u

        # Additional plugins for nvim
        home.packages = with pkgs; [
          nodePackages.vscode-langservers-extracted
        ];
        programs.neovim.plugins = with pkgs.vimPlugins; [
          friendly-snippets
          {
            plugin = nvim-lspconfig;
            type = "lua";
            config = builtins.readFile ./xilef/nvim-lspconfig.lua;
          }
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
      users.fzieger = {
        home.username = lib.mkForce "fzieger";
        home.homeDirectory = lib.mkForce "/Users/fzieger";

        programs.home-manager.enable = true;

        imports = [
          ./../../modules/fzf
          ./../../modules/zsh
          ./../../modules/git
          ./../../modules/neovim
          ./../../modules/tmux
        ];

        programs.zsh.initExtra = builtins.readFile ./fzieger/zshrc;

        # Additional plugins for tmux
        programs.tmux.plugins = [ unstable.tmuxPlugins.fzf-tmux-url ]; #  Open Hyperlink-Picker via CTRL+b u
        programs.tmux.extraConfig = ''
          set -g @fzf-url-history-limit '2000'
        '';
        home.file.".config/tmuxinator/mesh.yml".text = ''
          name: mesh
          root: ~/
          
          # Specifies (by name or index) which window will be selected on project startup. If not set, the first window is used.
          startup_window: me
          
          # Specifies (by index) which pane of the specified window will be selected on project startup. If not set, the first pane is used.
          # startup_pane: 1
          
          # Controls whether the tmux session should be attached to automatically. Defaults to true.
          # attach: false
          
          windows:
            - nix:
                root: ~/.nixpkgs
                layout: even-horizontal
                panes:
                  - nvim -c "NvimTreeOpen"
                  - lazygit
            - mf:
                root: ~/meshcloud/meshfed-release
                layout: even-horizontal
                panes:
                  - nvim -c "NvimTreeOpen"
                  - lazygit
            - me: 
                root: ~/meshcloud
        '';

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
            config = builtins.readFile ./fzieger/nvim-lspconfig.lua;
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
      pkgs.fish


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
    ++
    [
      # Python development environment
      pkgs.python3
      pkgs.poetry
      pkgs.nodePackages.pyright
      pkgs.ruff-lsp
      pkgs.ngrok
    ]
  ;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
