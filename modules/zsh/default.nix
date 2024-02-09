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
      
      # used for sad 
      export GIT_PAGER='delta -s'
    '';
  };
}
