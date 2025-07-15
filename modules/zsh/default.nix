{ pkgs, ... }:
{
  home.packages = with pkgs; [ zsh ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      unsetopt BEEP

      HYPHEN_INSENSITIVE="true"

      bindkey "^A" vi-beginning-of-line
      bindkey "^E" vi-end-of-line

      alias ..="cd .."
      alias ...="cd ../.."

      alias l='ls'
      alias ll='ls -l'
      alias la='ls -a'
      alias lla='ls -la'

      # Modern CLI tool aliases
      alias find='fd'
      alias grep='rg'
      alias cat='bat'
      alias dig='dog'

      # TODO fix for nix
      # alias zshconfig="$EDITOR ~/.zshrc"
      # alias sourcezshrc="source ~/.zshrc"
    '';
  };
  programs.zoxide.enable = true;
}
