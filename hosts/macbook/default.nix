{
  agenix,
  lib,
  pkgs,
  mac-app-util,
  nixpkgs-unstable,
  homebrew-core,
  homebrew-cask,
  nix-search-tui,
  ...
}:
let
  unstable = import nixpkgs-unstable {
    inherit (pkgs) system;
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
    extraSpecialArgs = { inherit unstable; };

    users.felix = {
      home = {
        username = lib.mkForce "felix";
        homeDirectory = lib.mkForce "/Users/felix";
        # Additional plugins for nvim
        packages = with pkgs; [
          terraform-ls
          nodePackages.vscode-langservers-extracted

          nodePackages.typescript-language-server # provides ts_ls for nvim lsp
        ];
        # This value determines the home Manager release that your
        # configuration is compatible with. This helps avoid breakage
        # when a new home Manager release introduces backwards
        # incompatible changes.
        #
        # You can update home Manager without changing this value. See
        # the home Manager release notes for a list of state version
        # changes in each release.
        stateVersion = "23.11";
      };

      imports = [
        ./../../modules/fish
        ./../../modules/ssh
        ./../../modules/claude
      ];

      programs = {
        fish = {
          shellInit = builtins.readFile ./fishrc;
        };
        zsh = {
          initContent = ''
            if [[ $(ps -o command= -p "$PPID" | awk '{print $1}') != 'fish' ]]
            then
                exec fish -l
            fi
          '';
        };
        btop = {
          enable = true;
          settings = {
            color_theme = "TTY";
          };
        };
        tmux = {
          plugins = [ pkgs.tmuxPlugins.fzf-tmux-url ]; # Open Hyperlink-Picker via CTRL+b u
          extraConfig = ''
            set -g @fzf-url-history-limit '2000'
          '';
        };
        neovim = {
          plugins = with pkgs.vimPlugins; [
            vim-terraform

            friendly-snippets
            {
              plugin = nvim-lspconfig;
              type = "lua";
              config = builtins.readFile ./nvim-lspconfig.lua;
            }

            {
              plugin = yazi-nvim;
              type = "lua";
              config = ''
                vim.keymap.set("n", "<leader>-", function()
                  require("yazi").yazi()
                end)
              '';
            }
          ];
        };
      };
    };
  };

  system = {
    primaryUser = "felix";
    defaults = {
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
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 4;
  };

  environment.shells = [
    pkgs.fish
  ];
  environment.systemPackages = [
    pkgs.nixos-rebuild # deploy to linux machines; https://nixcademy.com/posts/macos-linux-builder/

    pkgs.wget
    pkgs.ripgrep
    pkgs.shellcheck
    pkgs.fish
    pkgs.eternal-terminal
    pkgs.yazi

    pkgs.rectangle
    pkgs.monitorcontrol
    # pkgs.spotify # too far behind the latest version
    pkgs.ncspot
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
    pkgs.postgresql # includes psql CLI
    pkgs.oci-cli
    pkgs.gh
    pkgs.vale
    pkgs.opentofu

    unstable.scooter

    (unstable.python3.withPackages (ps: [
      ps.llm
      ps.llm-gemini
    ]))

    # Landing page
    pkgs.pnpm
    pkgs.bun
    pkgs.deno
    pkgs.nodejs_22
    pkgs.typescript
    pkgs.libwebp
    pkgs.imagemagick
    pkgs.google-cloud-sdk

    #esp32
    pkgs.ninja
    pkgs.dfu-util
    pkgs.cmake
    pkgs.esphome

    agenix.packages."${pkgs.system}".default

    unstable.nix-search-cli # dependency for nix-search-tui
    nix-search-tui.packages."${pkgs.system}".default
    pkgs.statix
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
    onActivation.upgrade = true;
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
      # "zen-browser" # fails to update via brew as of 2025-06-13
      "espanso"
    ];
  };
}
