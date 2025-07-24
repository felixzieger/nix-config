{
  pkgs,
  unstable,
  ...
}:
{
  home.packages = with pkgs; [
    fzf
    ripgrep
    fd
    bat

    nil
    nixfmt-rfc-style

    lua-language-server
    nodePackages.bash-language-server
    nodePackages.vim-language-server
    # nodePackages.yaml-language-server
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = [
      {
        plugin = pkgs.vimPlugins.which-key-nvim;
        type = "lua";
        config = builtins.readFile ./nvim-which-key.lua;
      }

      {
        plugin = pkgs.vimPlugins.conform-nvim;
        type = "lua";
        config = builtins.readFile ./nvim-conform.lua;
      }
      # Languages
      pkgs.vimPlugins.vim-nix
      # Completions
      {
        plugin = pkgs.vimPlugins.nvim-cmp;
        type = "lua";
        config = builtins.readFile ./nvim-cmp.lua;
      }
      pkgs.vimPlugins.cmp-nvim-lsp
      pkgs.vimPlugins.lspkind-nvim # icons in cmp dropwdown; requires nerdfont
      pkgs.vimPlugins.luasnip
      pkgs.vimPlugins.cmp_luasnip
      pkgs.vimPlugins.friendly-snippets
      {
        plugin = pkgs.vimPlugins.nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./nvim-lspconfig.lua;
      }
      pkgs.vimPlugins.tokyonight-nvim

      {
        plugin = pkgs.vimPlugins.lualine-nvim;
        type = "lua";
        config = builtins.readFile ./nvim-lualine.lua;
      }
      pkgs.vimPlugins.nvim-web-devicons
      pkgs.vimPlugins.git-blame-nvim # Git blame with lualine-nvim integration
      pkgs.vimPlugins.vim-sleuth # Work out tabs vs spaces etc. automatically.
      # pkgs.vimPlugins.vim-commentary # gcc

      {
        plugin = pkgs.vimPlugins.telescope-nvim; # <leader>f/b/g
        type = "lua";
        config = builtins.readFile ./nvim-telescope.lua;
      }
      pkgs.vimPlugins.plenary-nvim

      {
        plugin = pkgs.vimPlugins.nvim-tree-lua; # <leader>n
        type = "lua";
        config = builtins.readFile ./nvim-tree.lua;
      }

      {
        plugin = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
        type = "lua";
        config = ''
          require'nvim-treesitter.configs'.setup {
            highlight = {
              enable = true,
            },
            indent = {
              enable = true,
            },
          }
        '';
      }

      {
        plugin = pkgs.vimPlugins.supermaven-nvim;
        type = "lua";
        config = ''
          require("supermaven-nvim").setup({})
        '';
      }

      {
        plugin = unstable.vimPlugins.lazygit-nvim;
        type = "lua";
        config = builtins.readFile ./nvim-lazygit.lua;
      }

      {
        plugin = unstable.vimPlugins.multicursor-nvim; # arrow keys / CTRL+left click
        type = "lua";
        config = builtins.readFile ./nvim-multicursor.lua;
      }

    ];
    extraConfig = builtins.readFile ./neovim.vim;
  };
}
