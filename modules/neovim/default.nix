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
        plugin = pkgs.vimPlugins.blink-cmp;
        type = "lua";
        config = builtins.readFile ./nvim-blink.lua;
      }
      pkgs.vimPlugins.blink-compat # Compatibility layer for LSP

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
        plugin = pkgs.vimPlugins.oil-nvim; # - or <leader>e
        type = "lua";
        config = builtins.readFile ./nvim-oil.lua;
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
        plugin = pkgs.vimPlugins.toggleterm-nvim; # <leader>gg for lazygit
        type = "lua";
        config = builtins.readFile ./nvim-toggleterm.lua;
      }
      pkgs.vimPlugins.plenary-nvim # used for flaoting window management

      {
        plugin = unstable.vimPlugins.multicursor-nvim; # arrow keys / CTRL+left click
        type = "lua";
        config = builtins.readFile ./nvim-multicursor.lua;
      }

      # We integrate rainbow-delimiters with indent-blankline
      pkgs.vimPlugins.rainbow-delimiters-nvim
      {
        plugin = pkgs.vimPlugins.indent-blankline-nvim;
        type = "lua";
        config = ''
          local highlight = {
              "RainbowRed",
              "RainbowYellow",
              "RainbowBlue",
              "RainbowOrange",
              "RainbowGreen",
              "RainbowViolet",
              "RainbowCyan",
          }
          local hooks = require "ibl.hooks"
          -- create the highlight groups in the highlight setup hook, so they are reset
          -- every time the colorscheme changes
          hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
              vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
              vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
              vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
              vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
              vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
              vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
              vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
          end)

          vim.g.rainbow_delimiters = { highlight = highlight }
          require("ibl").setup { scope = { highlight = highlight } }

          hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
        '';
      }

    ];
    extraConfig = builtins.readFile ./neovim.vim;
  };
}
