{ pkgs, ... }:
let
  tmux-window-name = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-window-name";
    version = "head";
    src = pkgs.fetchFromGitHub {
      owner = "bcotton";
      repo = "tmux-window-name";
      rev = "0bb0148623782dbfb5c15741111f0402609f516f";
      sha256 = "sha256-xb0GGBZ4Ox3LQjKZJ8MzJluElxRJm3BB73F2CMFJEa0=";
    };
  };
in {
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./tmux.conf;
    plugins = [{ plugin = tmux-window-name; }];
  };

  programs.tmux.tmuxinator.enable = true;
  home.file.".config/tmuxinator/nixos.yml".source = ./tmuxinator.nixos.yml;
  home.file.".config/tmuxinator/macos.yml".source = ./tmuxinator.macos.yml;
}

