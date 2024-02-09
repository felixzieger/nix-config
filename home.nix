{ config, pkgs, ... }:
{
  home.username = "felix";
  home.homeDirectory = "/home/felix";
  home.packages = with pkgs; [
    silver-searcher # used for fzf in vim

    # used for nvim
    lua-language-server
    nodePackages.vim-language-server
    nixd
    nixpkgs-fmt

    systemctl-tui # view systemctl interactively
    sysz
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    initExtra = builtins.readFile ./modules/zsh/zsh.rc;
  };

  programs.git = {
    enable = true;
    userName = "Felix Zieger";
    userEmail = "github@felixzieger.de";
    delta.enable = true;
  };

  programs.lazygit.enable = true;

  programs.fzf.enable = true;

  programs.bat.enable = true;

  imports = [
    ./modules/tmux
    ./modules/neovim
  ];

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
