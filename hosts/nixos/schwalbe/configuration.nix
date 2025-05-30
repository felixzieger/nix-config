{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "schwalbe";

  virtualisation.docker.daemon.settings = {
    data-root = "/data/docker/data-root";
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g status-bg blue
    '';
  };

  home-manager.users.felix = {
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "adapta";
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
