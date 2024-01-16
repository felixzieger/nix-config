{ config, pkgs, ... }:
{
  home.username = "felix";
  home.homeDirectory = "/home/felix";
  home.packages = with pkgs; [
    which
    tree

    silver-searcher # used for fzf in vim

    # for nvim
    lua-language-server
    nodePackages.vim-language-server
    nixd
    nixpkgs-fmt
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    initExtra = builtins.readFile ./zsh.rc;
  };

  programs.git = {
    enable = true;
    userName = "Felix Zieger";
    userEmail = "github@felixzieger.de";
  };

  programs.fzf = {
    enable = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.tmux =
    {
      enable = true;
      extraConfig = ''
        # Switch pane layout    CTRL+B SPACE
        # Toggle focus for pane CTRL+B Z

        set -g mouse on

        # Split panes start in current path
        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        # True color settings
        set -g default-terminal "$TERM"
        set -ag terminal-overrides ",$TERM:Tc"
      '';
    };


  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./nvim-lspconfig.lua;
      }
      vim-nix
      tokyonight-nvim

      {
        plugin = lualine-nvim;
        type = "lua";
        config = builtins.readFile ./nvim-lualine.lua;
      }
      nvim-web-devicons
      git-blame-nvim # Git blame with lualine-nvim integration
      vim-sleuth # Work out tabs vs spaces etc. automatically.
      vim-commentary # gcc
      fzf-vim # <leader>f/b/a
      {
        plugin = nvim-tree-lua; # <leader>n
        type = "lua";
        config = builtins.readFile ./nvim-tree.lua;
      }
    ];
    extraConfig = builtins.readFile ./neovim.vim;
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

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
