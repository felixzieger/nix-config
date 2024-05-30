{ inputs, pkgs, ... }: {
  programs.lazygit = {
    enable = true;
    settings = {
      git.paging = {
        colorArg = "always";
        pager = "delta --dark --paging=never";
      };
    };
  };
  programs.git = {
    enable = true;
    userName = "Felix Zieger";
    delta.enable = true;
  };
}
