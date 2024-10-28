{ inputs, home-manager, agenix, lib, config, pkgs, mac-app-util, ... }: {
  nixpkgs.config.allowUnfree = true;
  services.nix-daemon.enable = true;
  nix = {
    settings = { "extra-experimental-features" = [ "nix-command" "flakes" ]; };
  };
  programs.zsh.enable = true;
  programs.fish.enable = true;

  users.users.felix.shell = pkgs.zsh;

  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=20
  '';

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [ mac-app-util.homeManagerModules.default ];

    users.felix = {
      home.username = lib.mkForce "felix";
      home.homeDirectory = lib.mkForce "/Users/felix";

      programs.home-manager.enable = true;

      imports = [
        ./../../modules/fzf
        ./../../modules/fish
        # ./../../modules/zsh
        ./../../modules/git
        ./../../modules/neovim
        ./../../modules/tmux
        ./../../modules/ssh
      ];

      # programs.fish = {
      #   shellInit = builtins.readFile ./fishrc;
      #   shellAliases = { sm = "smerge"; };
      # };
      # programs.zsh.initExtra = builtins.readFile ./zshrc;
      programs.zsh = {
        initExtra = ''
          if [[ $(ps -o command= -p "$PPID" | awk '{print $1}') != 'fish' ]]
          then
              exec fish -l
          fi
        '';
      };

      # Additional plugins for tmux
      programs.tmux.plugins =
        [ pkgs.tmuxPlugins.fzf-tmux-url ]; # Open Hyperlink-Picker via CTRL+b u
      programs.tmux.extraConfig = ''
        set -g @fzf-url-history-limit '2000'
      '';

      # Additional plugins for nvim
      home.packages = with pkgs; [
        terraform-ls
        nodePackages.vscode-langservers-extracted
      ];
      programs.neovim = {
        plugins = with pkgs.vimPlugins; [
          vim-terraform

          friendly-snippets
          {
            plugin = nvim-lspconfig;
            type = "lua";
            config = builtins.readFile ./nvim-lspconfig.lua;
          }

          # Potential successor for copilot-vim: avante
          # https://github.com/yetone/avante.nvim
          copilot-vim
          {
            plugin = CopilotChat-nvim;
            type = "lua";
            config = builtins.readFile ./nvim-copilotchat.lua;
          }
          plenary-nvim # Dependency for CopilotChat-nvim
        ];
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

  environment.shells = [ pkgs.zsh pkgs.fish ];
  environment.variables.EDITOR = "nvim";
  environment.systemPackages = [
    pkgs.btop
    pkgs.git
    pkgs.doggo
    pkgs.tree
    pkgs.wget
    pkgs.ripgrep
    pkgs.lsd # missing: icon support; https://github.com/Peltoche/lsd/issues/199
    pkgs.shellcheck
    pkgs.fish
    pkgs.eternal-terminal

    # pkgs.jan # LLM gui; currently only packaged for linux on nixos
    # pkgs.elia # llm tui https://github.com/NixOS/nixpkgs/pull/317782 
    # pkgs.posting # HTTP tui https://github.com/NixOS/nixpkgs/pull/325971
    pkgs.rectangle
    pkgs.spotify
    pkgs.monitorcontrol
    pkgs.vscode
    pkgs.kitty
    pkgs.watchman
    pkgs.opentofu

    # Python development environment
    pkgs.python3
    pkgs.poetry
    pkgs.nodePackages.pyright
    pkgs.ruff-lsp
    pkgs.ngrok
    pkgs.mkdocs
    pkgs.litecli
    pkgs.just
    pkgs.oci-cli

    # Landing page
    pkgs.nodejs_22
    pkgs.bun
    pkgs.typescript
    pkgs.pnpm

    agenix.packages."${pkgs.system}".default
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
