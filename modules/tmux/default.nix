_: {
  programs.tmux = {
    # Look into tmux-window-name plugin https://github.com/bcotton/nix-config/blob/a4171d340334532a0c75cf489ba9729ec33309b1/home/bcotton.nix#L9C1-L20C7
    enable = true;
    extraConfig = builtins.readFile ./tmux.conf;
  };

  programs.tmux.tmuxinator.enable = true;

  home.file = {
    ".config/tmuxinator/nixos.yml".source = ./tmuxinator.nixos.yml;
    ".config/tmuxinator/macos.yml".source = ./tmuxinator.macos.yml;
    # Install tclip script
    ".config/tmux/tclip" = {
      source = ./tclip;
      executable = true;
    };
  };
}
