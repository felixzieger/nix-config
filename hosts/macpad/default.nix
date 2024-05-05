{ inputs, home-manager, lib, config, pkgs, nixpkgs-unstable, ... }:
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
      users.xilef = {
        home.username = lib.mkForce "xilef";
        home.homeDirectory = lib.mkForce "/Users/xilef";

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
          nodePackages.vscode-langservers-extracted
        ];
        programs.neovim.plugins = with pkgs.vimPlugins; [
          friendly-snippets
          {
            plugin = nvim-lspconfig;
            type = "lua";
            config = builtins.readFile ./nvim-lspconfig.lua;
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
      pkgs.lsd
      pkgs.shellcheck
      pkgs.gh
      pkgs.watchman
      pkgs.pass
      pkgs.parallel
      pkgs.nodejs
      pkgs.jq
      pkgs.yarn

      pkgs.ngrok

      # Python development environment
      pkgs.python3
      pkgs.nodePackages.pyright
      pkgs.ruff-lsp

    ]
  ;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
