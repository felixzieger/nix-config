{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    fzf
    silver-searcher

    rnix-lsp
    nixd
    nixpkgs-fmt

    lua-language-server
    nodePackages.vim-language-server
          nodePackages.bash-language-server
          nodePackages.yaml-language-server
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
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
      fzf-vim # <leader>f/b/a
      {
        plugin = nvim-tree-lua; # <leader>n
        type = "lua";
        config = builtins.readFile ./nvim-tree.lua;
      }
    ];
    extraConfig = builtins.readFile ./neovim.vim;
  };
}
