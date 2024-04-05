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

      # SSH agent forwarding for attached sessions
      # I followed https://werat.dev/blog/happy-ssh-agent-forwarding/ for this
      set-environment -g 'SSH_AUTH_SOCK' ~/.ssh/ssh_auth_sock
    '';
  };

  home.file.".ssh/rc".text = ''
    # SSH agent forwarding for attached sessions
    if [ ! -S ~/.ssh/ssh_auth_sock ] && [ -S "$SSH_AUTH_SOCK" ]; then
      ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
    fi
  '';
}

