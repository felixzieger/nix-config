{ inputs, pkgs, ... }:
{
  # FZF shortcuts
  # Ctrl + T: paste the path of file or directory found on the command line
  # Ctrl + R: find history command and paste command on the command line
  # Alt + C: cd to specific directory
  programs = {
    fzf.enable = true;
    bat.enable = true;
    
    zsh.initContent = ''
      if [ -n "''${commands[fzf-share]}" ]; then
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      fi
    '';
    
    bash.initExtra = ''
      if command -v fzf-share >/dev/null; then
        source "$(fzf-share)/key-bindings.bash"
        source "$(fzf-share)/completion.bash"
      fi
    '';
  };
}
