{ inputs, pkgs, ... }: {
  home.packages = with pkgs; [
    fzf
    ripgrep
    fd
    bat

    nil
    nixfmt-classic

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
        plugin =
          # Will be available in 24.10
          # https://search.nixos.org/packages?channel=unstable&show=vimPlugins.grug-far-nvim&from=0&size=50&sort=relevance&type=packages&query=grug+far+nvim
          pkgs.vimUtils.buildVimPlugin {
            pname = "grug-far.nvim";
            version = "2024-09-09";
            src = pkgs.fetchFromGitHub {
              owner = "MagicDuck";
              repo = "grug-far.nvim";
              rev = "76d86580f71bd2f07d4264c782ab8d1c12302e13";
              sha256 = "0zn847nfzh1ps9b1czsg1xmhdygvjg7dgq3wa5b6l7frv75lhwhk";
            };
            meta.homepage = "https://github.com/MagicDuck/grug-far.nvim/";
          };
        type = "lua";
        config = builtins.readFile ./nvim-grug-far.lua;
      }

    ];
    extraConfig = builtins.readFile ./neovim.vim;
  };
}
