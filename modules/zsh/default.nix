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
    initExtra = builtins.readFile ./zsh.rc;
  };
}
