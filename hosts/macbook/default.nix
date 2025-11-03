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

  programs = {
    fish.enable = true;
    nix-index-database.comma.enable = true;
  };

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
        packages = [
          pkgs.nodePackages.vscode-langservers-extracted
          pkgs.nodePackages.typescript-language-server # provides ts_ls for nvim lsp
          pkgs.nil
          pkgs.nixfmt-rfc-style
          pkgs.lua-language-server
          pkgs.nodePackages.bash-language-server
          pkgs.nodePackages.vim-language-server
          pkgs.nodePackages.yaml-language-server
          pkgs.ruff
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
        direnv = {
          enable = true;
          silent = true;
          nix-direnv.enable = true;
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
          extraLuaPackages = ps: [ ps.magick ];
          extraPackages = [
            pkgs.ueberzugpp
            pkgs.imagemagick
          ];
          plugins = [
            pkgs.vimPlugins.friendly-snippets
            {
              plugin = pkgs.vimPlugins.nvim-lspconfig;
              type = "lua";
              config = builtins.readFile ./nvim-lspconfig.lua;
            }
            {
              plugin = pkgs.vimPlugins.yazi-nvim;
              type = "lua";
              config = ''
                vim.keymap.set("n", "<leader>-", function()
                  require("yazi").yazi()
                end)
              '';
            }
            {
              plugin = unstable.vimPlugins.render-markdown-nvim;
              type = "lua";
              config = ''
                require('render-markdown').setup({})
              '';
            }
            {
              plugin = pkgs.vimPlugins.image-nvim;
              type = "lua";
              config = ''
                require("image").setup({})
              '';
            }

            {
              plugin = pkgs.vimPlugins.nvim-colorizer-lua;
              type = "lua";
              config = ''
                require("colorizer").setup()
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
    pkgs.spotify
    # pkgs.gimp # toolbar doesn't show as of 2025-09-18
    # pkgs.localsend

    # Python development environment
    pkgs.gh
    pkgs.vale

    unstable.pnpm

    # pkgs.jujutsu
    # pkgs.jjui

    pkgs.nodejs

    unstable.scooter
    pkgs.lazysql
    unstable.devenv # automatically activated using direnv

    agenix.packages."${pkgs.system}".default

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
      "nextcloud"
      # "zen-browser" # fails to update via brew as of 2025-06-13
      "gimp"
    ];
  };
}
