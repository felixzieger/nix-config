{ inputs, home-manager, agenix, lib, config, pkgs, mac-app-util, ... }:
let
  gcloud = pkgs.google-cloud-sdk.withExtraComponents
    (with pkgs.google-cloud-sdk.components; [ gke-gcloud-auth-plugin ]);
in {
  nixpkgs.config.allowUnfree = true;
  services.nix-daemon.enable = true;
  nix = {
    settings = { "extra-experimental-features" = [ "nix-command" "flakes" ]; };
  };
  programs.zsh.enable = true;
  programs.fish.enable = true;

  users.users.xilef.shell = pkgs.fish;

  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=20
  '';

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [ mac-app-util.homeManagerModules.default ];

    users.fzieger = {
      home.username = lib.mkForce "fzieger";
      home.homeDirectory = lib.mkForce "/Users/fzieger";

      programs.home-manager.enable = true;

      imports = [
        ./../../modules/fzf
        ./../../modules/fish
        ./../../modules/zsh
        ./../../modules/git
        ./../../modules/neovim
        ./../../modules/tmux
      ];

      programs.fish = {
        shellInit = builtins.readFile ./fzieger/fishrc;
        shellAliases = {
          me = "cd $HOME/meshcloud";
          mf = "cd $HOME/meshcloud/meshfed-release";
          mi = "cd $HOME/meshcloud/infrastructure";
          md = "cd $HOME/meshcloud/deployments";
          mdocs = "cd $HOME/meshcloud/meshcloud-docs";
          chub = "cd $HOME/meshcloud/collie-hub";
          ccli = "cd $HOME/meshcloud/collie-cli";
          validate-dhall = "mf && deployment/test/validate.sh";
          validate-override = "mf && ci/deployment/overrides-idempotent.sh";
          format-dhall = "mf && deployment/bin/format-all-osx.sh";
          fk = "fly -t k";
          sm = "smerge";
          vault-forward = "mi && meshstack-infra-k8s/vault-forward.sh";
        };
      };
      programs.zsh.initExtra = builtins.readFile ./fzieger/zshrc;

      # Additional plugins for tmux
      programs.tmux.plugins =
        [ pkgs.tmuxPlugins.fzf-tmux-url ]; # Open Hyperlink-Picker via CTRL+b u
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
              layout: main-vertical
              panes:
                - nvim -c "NvimTreeOpen"
                - lazygit
                - pwd
          - mf:
              root: ~/meshcloud/meshfed-release
              layout: even-horizontal
              panes:
                - nvim -c "NvimTreeOpen"
                - lazygit
          - mdocs: 
              root: ~/meshcloud/meshcloud-docs
              layout: main-vertical
              panes:
                - nvim -c "NvimTreeOpen"
                - lazygit
                - cd website
      '';

      # Additional plugins for nvim
      home.packages = with pkgs; [
        terraform-ls
        nodePackages.vscode-langservers-extracted
        gopls
      ];
      programs.neovim = {
        plugins = with pkgs.vimPlugins; [
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

          copilot-vim
          {
            plugin = CopilotChat-nvim;
            type = "lua";
            config = builtins.readFile ./fzieger/nvim-copilotchat.lua;
          }
          plenary-nvim # Dependency for CopilotChat-nvim
        ];
      };

      programs.k9s.enable = true;
      programs.k9s.package = pkgs.k9s;
      programs.k9s.plugin = {
        plugins =
          { # Repeat the plugins key here, because k9s doesn't load the plugin otherwise
            db-connect = {
              shortCut = "Ctrl-J";
              description = "Open DB";
              scopes = [ "pod" ];
              command = "kubectl";
              background = false;
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
  environment.systemPackages = [
    pkgs.btop
    pkgs.git
    pkgs.doggo
    pkgs.tree
    pkgs.wget
    pkgs.ripgrep
    pkgs.lsd # missing: icon support; https://github.com/Peltoche/lsd/issues/199#issuecomment-494218334
    pkgs.shellcheck
    pkgs.bitwarden-cli
    pkgs.deno
    pkgs.gh
    pkgs.fish

    # pkgs.elia # Add this once https://github.com/NixOS/nixpkgs/pull/317782 is merged
    # pkgs.posting # Like postman but for CLI; no PR available in nxpkgs yet. https://github.com/darrenburns/posting

    pkgs.raycast
    pkgs.rectangle
    pkgs.spotify
    pkgs.monitorcontrol
    pkgs.vscode
    # pkgs.teams # Still the old version
    pkgs.kitty
    pkgs.slack
    pkgs.watchman

    pkgs.go
    pkgs.opentofu
    pkgs.terraform-docs
    pkgs.terragrunt
    pkgs.pass
    pkgs.parallel
    pkgs.kubectl
    pkgs.nodejs
    pkgs.vault-bin
    pkgs.jq
    pkgs.yarn
    pkgs.kotlin
    pkgs.jdk
    pkgs.pre-commit

    pkgs.cntlm

    pkgs.powershell

    # Cloud CLIs
    pkgs.openshift
    pkgs.cloudfoundry-cli
    pkgs.openstackclient
    pkgs.awscli2
    gcloud
    pkgs.azure-cli
    pkgs.azure-storage-azcopy
  ] ++ [
    # Python development environment
    pkgs.python3
    pkgs.poetry
    pkgs.nodePackages.pyright
    pkgs.ruff-lsp
    pkgs.ngrok
    pkgs.mkdocs

    agenix.packages."${pkgs.system}".default
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
