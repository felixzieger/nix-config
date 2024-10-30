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
      dog = "doggo"; # doesn't work. don't know why
      dig = "dog";
      docsy = "cd ~/Documents/docsy/cli && bun run docsy";
    };
    shellAbbrs = { unset = "set --erase"; };
  };
  programs.zoxide.enable = true;
}
