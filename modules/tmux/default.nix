{ inputs, pkgs, ... }:
{
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

      # SSH agent forwarding for attached sessions
      set-option -g -u update-environment[3]
      set-environment -g SSH_AUTH_SOCK $HOME/.ssh/ssh_auth_sock
    '';
  };

  home.file.".ssh/rc".text = ''
    # SSH agent forwarding for attached sessions
    if test "$SSH_AUTH_SOCK"; then
      ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
    fi
  '';

  programs.tmux.tmuxinator.enable = true;
  home.file.".config/tmuxinator/nix-config.yml".text = ''
    name: nix-config
    root: /etc/nixos

    # Specifies (by name or index) which window will be selected on project startup. If not set, the first window is used.
    startup_window: nix

    # Specifies (by index) which pane of the specified window will be selected on project startup. If not set, the first pane is used.
    # startup_pane: 1

    # Controls whether the tmux session should be attached to automatically. Defaults to true.
    # attach: false

    windows:
      - top: btop
      - nix:
          layout: even-horizontal
          panes:
            - sudo -E nvim -c "NvimTreeOpen"
            - 
      - git: sudo -E lazygit
  '';
}

