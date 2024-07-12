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
      dog = "doggo";
      dig = "dog";
    };
    shellAbbrs = { unset = "set --erase"; };
  };
  programs.zoxide.enable = true;
}
