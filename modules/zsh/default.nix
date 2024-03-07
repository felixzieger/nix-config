{ pkgs, ... }:
{
  home.packages = with pkgs; [
    zsh
  ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      unsetopt BEEP

      HYPHEN_INSENSITIVE="true"
      
      bindkey "^A" vi-beginning-of-line
      bindkey "^E" vi-end-of-line

      alias ..="cd .."
      alias ...="cd ../.."
      
      alias l='ls'
      alias l='ls -l'
      alias la='ls -a'
      alias lla='ls -la'

      # TODO fix for nix
      # alias zshconfig="$EDITOR ~/.zshrc"
      # alias sourcezshrc="source ~/.zshrc"
    '';
  };
}
