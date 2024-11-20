{ agenix, lib, pkgs, mac-app-util, nixpkgs-unstable, ... }:
let
  unstable = import nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
  scooter = pkgs.callPackage ./scooter.nix { };
in {
  nixpkgs.config.allowUnfree = true;
  services.nix-daemon.enable = true;
  nix = {
    settings = { "extra-experimental-features" = [ "nix-command" "flakes" ]; };

    # build linux hosts from darwin
    linux-builder = {
      enable = true;
      ephemeral = true;
      maxJobs = 4;
      config = {
        virtualisation = {
          darwin-builder = {
            diskSize = 40 * 1024;
            memorySize = 8 * 1024;
          };
          cores = 4;
        };
      };
    };
    settings.trusted-users = [ "@admin" ];
  };

  programs.zsh.enable = true;
  programs.fish.enable = true;

  users.users.felix.shell = pkgs.zsh;

  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=20
  '';

  fonts.packages = with pkgs;
    [ (nerdfonts.override { fonts = [ "SourceCodePro" ]; }) ];

  home-manager = {
    sharedModules = [ mac-app-util.homeManagerModules.default ];

    users.felix = { home.username = lib.mkForce "felix";
      home.homeDirectory = lib.mkForce "/Users/felix";

      imports = [ ./../../modules/fish ./../../modules/ssh ];

      programs.fish = { shellInit = builtins.readFile ./fishrc; };
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
        nodePackages.typescript-language-server # provides tsserver for nvim lsp
      ];
      programs.neovim = {
        package = unstable.neovim-unwrapped;
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

      programs.kitty = {
        enable = false;
        settings = { font_family = "SourceCodePro"; };
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
  environment.systemPackages = [
    pkgs.nixos-rebuild # deploy to linux machines; https://nixcademy.com/posts/macos-linux-builder/

    pkgs.doggo
    pkgs.wget
    pkgs.ripgrep
    pkgs.shellcheck
    pkgs.fish
    pkgs.eternal-terminal

    # pkgs.jan # LLM gui; currently only packaged for linux on nixos
    # pkgs.elia # llm tui https://github.com/NixOS/nixpkgs/pull/317782 
    # pkgs.posting # HTTP tui https://github.com/NixOS/nixpkgs/pull/325971
    unstable.aider-chat
    pkgs.rectangle
    pkgs.spotify
    pkgs.monitorcontrol
    unstable.signal-desktop # darwin support got added in October
    # pkgs.kitty / broken for macos 15.1. see https://github.com/NixOS/nixpkgs/pull/352795
    pkgs.watchman
    pkgs.opentofu
    # unstable.calibre # marked as broken

    # Python development environment
    pkgs.python3
    pkgs.poetry # package management
    pkgs.ruff # formatting and linting
    pkgs.pyright # static type checking
    pkgs.ngrok
    pkgs.litecli
    pkgs.oci-cli
    pkgs.vale

    scooter

    # Landing page
    pkgs.nodejs_22
    pkgs.bun
    pkgs.typescript

    agenix.packages."${pkgs.system}".default
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
