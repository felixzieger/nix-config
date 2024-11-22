{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "schwalbe";

  users.users.felix = {
    openssh.authorizedKeys.keys = [
      # For nextcloud backup from sonnenhof-server
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDI8BXQgjO/Gk6b2piezoFIjeT6weGr0gAB1yAqj4z4oSDE/oM+DcToi9+Ca10jnza/Y+L6lcwZELZ8SNGt91daGy/pbzglgTlg+Mz5MJZtPCMv6CBFg4nigP6THlBfQQBsZrnWCkYOpzNiuIf10DRSkkpNXCRBYmlqlCWx1qzrZqlMjdH60flegsWpk/yrdrBON51oE0x5g3rZt2+ASZ2xvS1dsbGpO4AdNu7Xo/p5fzxLpMl3mixzAJEHihH9j0Wpw1tnyQUCiiS9Zna8yixUOsBjfdunEt0XCZrEC+ExepM7N/L4DnJ9SlMnIqC1mhlqfptUC/zX9aPJarR0ZIIeZIMvG8SC7slyz2GskRSDs3e9cTItBJ6iiazYyFrbLoyfQLsL/L3fB1JrsdFB3tYvaOX9MaXgssfgI6FgogcD+fzJIDv+tJNHeuu/qIlSeiubNZlCYEkdapxTg1utFu3QUVBBi3UVyOTGDq6fMwViCxHminlxMrrsk2AregYKM7lAHcTDq7+ITi5Apy4QRbPdfDxxIo1Laq0qFPpfJg6eZkrVexRK9789RCajx9QEydPgJnxs0o9hkb4nmvhx2f47v2g2on+lgxRunCuKQKzVR5CmHBk9gBp5Yf7yHySPbymfYo4HRjLr6yuOAjxelIep8LXxPqmezAyX0hlOEzOaXQ== felix@sonnenhofserver-2020-11-21"
    ];
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g status-bg blue
    '';
  };

  home-manager.users.felix = {
    programs.btop.settings = { color_theme = "flat-remix"; };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
