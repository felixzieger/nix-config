{ ... }: {
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./tmux.conf;
  };

  programs.tmux.tmuxinator.enable = true;
  home.file.".config/tmuxinator/nix-config.yml".source = ./tmuxinator.yml;
}

