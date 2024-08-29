{ ... }: {
  imports = [
    ./hardware-configuration.nix

  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "hedwig";
  system.stateVersion = "23.11";
  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g status-bg orange
    '';
  };
  home-manager.users.felix = {
    programs.btop.settings = { color_theme = "dusklight"; };
  };
}
