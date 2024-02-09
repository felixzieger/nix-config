{ inputs, pkgs, ... }:
{
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
}
