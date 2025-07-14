{ inputs, pkgs, ... }:
let
  modes-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "modes-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "mvllow";
      repo = "modes.nvim";
      rev = "HEAD";
      sha256 = "03c9l3lsfl5glkszc510f5dswskz2fh8n7x5vb04klj6hvvyikn0";
    };
  };
in
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
      {
        plugin = nvim-cmp;
        type = "lua";
        config = builtins.readFile ./nvim-cmp.lua;
      }
      cmp-nvim-lsp
      lspkind-nvim # icons in cmp dropwdown; requires nerdfont
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
        plugin = modes-nvim;
        type = "lua";
        config = ''
          require('modes').setup()
        '';
      }

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

      {
        plugin = nvim-treesitter.withAllGrammars;
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

    ];
    extraConfig = builtins.readFile ./neovim.vim;
  };
}
