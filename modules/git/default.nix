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
    userEmail = "67903933+felixzieger@users.noreply.github.com";
    extraConfig.pull.rebase = true;
    delta.enable = true;
  };
}
