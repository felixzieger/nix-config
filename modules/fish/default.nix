{ pkgs, ... }:
{
  home.packages = with pkgs; [ fish ];
  programs.fish = {
    enable = true;
    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      l = "ls";
      ls = "lsd";
      ll = "ls -l";
      la = "ls -la";
      tree = "ls --tree";
      # Modern CLI tool aliases
      find = "fd";
      grep = "rg";
      cat = "bat";
      dig = "dog";
      sed = "sd";
    };
  };
  programs.zoxide.enable = true;
}
