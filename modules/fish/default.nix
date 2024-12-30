{ pkgs, ... }: {
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
      dig = "dog";
    };
  };
  programs.zoxide.enable = true;
}
