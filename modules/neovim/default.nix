{ inputs, pkgs, ... }:
let
  updated-cheatsheet-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "cheatsheet.nvim";
    version = "2024-05-12";
    src = pkgs.fetchFromGitHub {
      owner = "doctorfree";
      repo = "cheatsheet.nvim";
      rev = "6753ad9b7a58d57a94735cab75b3c53efc7b2abe";
      sha256 = "sha256-QMd6QdsxGcinoO+I6m0DQ665LckUBFMz814eJ9wU4bY";
    };
    meta.homepage = "https://github.com/doctorfree/cheatsheet.nvim/";
  };
in {
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
        plugin = updated-cheatsheet-nvim; # <space>?/ß
        type = "lua";
        config = builtins.readFile ./nvim-cheatsheet.lua;
      }
      {
        plugin = nvim-tree-lua; # <leader>n
        type = "lua";
        config = builtins.readFile ./nvim-tree.lua;
      }
    ];
    extraConfig = builtins.readFile ./neovim.vim;
  };

  # Cheetsheet used by cheetsheet-nvim
  home.file.".config/nvim/cheatsheet.txt".text = ''
    ## lsp @quick @reference
    Hover Information               | <leader>h
    Signature Help                  | <C-h>

    Go to Implementation            | <leader>gi
    Go to Definition                | <leader>gd
    Go to Declaration               | <leader>gD
    Go to Type Definition           | <leader>D
    Go to References                | <leader>gr

    Rename Symbol                   | <leader>rn
    Format Code                     | <space>f
  '';
}
