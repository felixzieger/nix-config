{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    tmux
  ];
  programs.tmux = {
    enable = true;
    extraConfig = ''
      # Switch pane layout    CTRL+B SPACE
      # Toggle focus for pane CTRL+B Z

      set -g mouse on

      # Split panes start in current path
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # True color settings
      set -g default-terminal "$TERM"
      set -ag terminal-overrides ",$TERM:Tc"

      # nvim :healthcheck recommends setting escape-time
      set-option -sg escape-time 10
    '';
  };
}

