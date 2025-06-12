{
  agenix,
  lib,
  pkgs,
  mac-app-util,
  nixpkgs-unstable,
  homebrew-core,
  homebrew-cask,
  ...
}:
let
  unstable = import nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      "extra-experimental-features" = [
        "nix-command"
        "flakes"
      ];
    };

    # build linux hosts from darwin
    # verify that it's running with `sudo launchctl list org.nixos.linux-builder`
    linux-builder = {
      enable = true;
      # ephemeral = true;
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

  # Enable logging for the linux builder
  launchd.daemons.linux-builder = {
    serviceConfig = {
      StandardOutPath = "/var/log/darwin-builder.log";
      StandardErrorPath = "/var/log/darwin-builder.log";
    };
  };

  programs.fish.enable = true;

  users.users.felix.shell = pkgs.fish;

  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=20
  '';

  fonts.packages = [
    pkgs.nerd-fonts.sauce-code-pro
  ];

  home-manager = {
    sharedModules = [ mac-app-util.homeManagerModules.default ];
    backupFileExtension = "backup";

    users.felix = {
      home.username = lib.mkForce "felix";
      home.homeDirectory = lib.mkForce "/Users/felix";

      imports = [
        ./../../modules/fish
        ./../../modules/ssh
      ];

      programs.fish = {
        shellInit = builtins.readFile ./fishrc;
      };
      programs.zsh = {
        initContent = ''
          if [[ $(ps -o command= -p "$PPID" | awk '{print $1}') != 'fish' ]]
          then
              exec fish -l
          fi
        '';
      };
      programs.btop = {
        enable = true;
        settings = {
          color_theme = "TTY";
        };
      };

      # Additional plugins for tmux
      programs.tmux.plugins = [ pkgs.tmuxPlugins.fzf-tmux-url ]; # Open Hyperlink-Picker via CTRL+b u
      programs.tmux.extraConfig = ''
        set -g @fzf-url-history-limit '2000'
      '';

      # Additional plugins for nvim
      home.packages = with pkgs; [
        terraform-ls
        nodePackages.vscode-langservers-extracted

        # disabled because it tried to pull in nodejs-20.19 which failed to build
        # nodePackages.typescript-language-server # provides ts_ls for nvim lsp
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

      programs.helix = {
        enable = true;

        languages.language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          }
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

  system.primaryUser = "felix";
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

  environment.shells = [
    pkgs.fish
  ];
  environment.systemPackages = [
    pkgs.nixos-rebuild # deploy to linux machines; https://nixcademy.com/posts/macos-linux-builder/

    pkgs.doggo
    pkgs.wget
    pkgs.ripgrep
    pkgs.shellcheck
    pkgs.fish
    pkgs.eternal-terminal
    pkgs.helix

    pkgs.rectangle
    pkgs.monitorcontrol
    pkgs.spotify
    pkgs.gimp
    # pkgs.slack
    # pkgs.opentofu
    pkgs.audacity

    # Python development environment
    pkgs.uv
    pkgs.ruff
    pkgs.pyright
    pkgs.ngrok
    pkgs.litecli
    pkgs.oci-cli
    pkgs.gh
    pkgs.vale
    pkgs.opentofu

    unstable.scooter

    unstable.aider-chat
    (unstable.python3.withPackages (ps: [
      ps.llm
      ps.llm-gemini
    ]))
    (pkgs.python3Packages.buildPythonApplication {
      pname = "shell_sage";
      version = "0.1.0";

      src = pkgs.fetchFromGitHub {
        owner = "AnswerDotAI";
        repo = "shell_sage";
        rev = "80fb2afde8c507079ca0b0faec0951c99eb3d70d";
        sha256 = "sha256-I7CWGU06kP5p8KCe6A+Syy1ZUssjjI0V+9cE3+Oro5g";
      };

      pypiDeps = true;
    })

    # Landing page
    pkgs.pnpm
    pkgs.bun
    pkgs.nodejs_22
    pkgs.typescript

    #esp32
    pkgs.ninja
    pkgs.dfu-util
    pkgs.cmake
    pkgs.esphome

    agenix.packages."${pkgs.system}".default
  ];

  nix-homebrew = {
    enable = true;
    user = "felix";
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };
    mutableTaps = false;
  };

  homebrew = {
    onActivation.autoUpdate = true;
    enable = true;
    casks = [
      # unstable.signal-desktop # not available on darwin as of 2025-4-22
      "signal"
      # unstable.whatsapp-for-mac # Too often outdated
      "whatsapp"
      # unstable.ghostty # marked as broken for darwin as of 2024-12-30
      "ghostty"
      # pkgs.calibre # marked as broken for darwin as of 2024-12-30
      "calibre"
      # pkgs.thunderbird # Not supported for x86_64-apple-darwin as of 2024-01-22
      # "thunderbird"
      # pkgs.firefox # Not supported for x86_64-apple-darwin as of 2024-01-22
      # "firefox"
      "slack"
      "nextcloud"
      "zen-browser"
    ];
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
