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

      # Formatting
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

      # pkgs.vimPlugins.tokyonight-nvim
      pkgs.vimPlugins.bluloco-nvim

      {
        plugin = pkgs.vimPlugins.lualine-nvim;
        type = "lua";
        config = builtins.readFile ./nvim-lualine.lua;
      }
      pkgs.vimPlugins.nvim-web-devicons
      pkgs.vimPlugins.git-blame-nvim # Git blame with lualine-nvim integration
      pkgs.vimPlugins.vim-sleuth # Work out tabs vs spaces etc. automatically.

      {
        plugin = pkgs.vimPlugins.fzf-lua; # <leader>f/b/g
        type = "lua";
        config = builtins.readFile ./nvim-fzf-lua.lua;
      }

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
        plugin = unstable.vimPlugins.lazygit-nvim; # space+gg
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
