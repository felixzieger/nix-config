{ ... }: {
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./tmux.conf;
  };

  programs.tmux.tmuxinator.enable = true;
  home.file.".config/tmuxinator/nixos.yml".source = ./tmuxinator.nixos.yml;
  home.file.".config/tmuxinator/macos.yml".source = ./tmuxinator.macos.yml;
}

