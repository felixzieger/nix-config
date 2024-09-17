{ inputs, pkgs, ... }: {
  home.packages = with pkgs; [
    fzf
    ripgrep
    fd
    bat

    nil
    nixfmt-classic

    lua-language-server
    nodePackages.vim-language-server
    nodePackages.bash-language-server
    nodePackages.yaml-language-server
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      {
        plugin = which-key-nvim;
        type = "lua";
        config = builtins.readFile ./nvim-which-key.lua;
      }

      {
        plugin = conform-nvim;
        type = "lua";
        config = builtins.readFile ./nvim-conform.lua;
      }
      # Languages
      vim-nix
      # Completions
      nvim-cmp
      cmp-nvim-lsp
      luasnip
      cmp_luasnip
      friendly-snippets
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./nvim-lspconfig.lua;
      }
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

      {
        plugin = telescope-nvim; # <leader>f/b/g
        type = "lua";
        config = builtins.readFile ./nvim-telescope.lua;
      }
      plenary-nvim

      {
        plugin = nvim-tree-lua; # <leader>n
        type = "lua";
        config = builtins.readFile ./nvim-tree.lua;
      }
    ];
    extraConfig = builtins.readFile ./neovim.vim;
  };
}
