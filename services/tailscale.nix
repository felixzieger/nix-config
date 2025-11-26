{
  config,
  pkgs,
  nixpkgs-unstable,
  ...
}:
# I mostly followed
# https://tailscale.com/kb/1096/nixos-minecraft
let
  unstable = import nixpkgs-unstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in
{
  age.secrets = {
    tailscale-authkey.file = ../secrets/tailscale-authkey.age;
  };

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
  };

  environment.systemPackages = [ unstable.tailscale ];

  services.tailscale.enable = true;
  services.tailscale = {
    package = unstable.tailscale;
    authKeyFile = config.age.secrets.tailscale-authkey.path;
    useRoutingFeatures = "server";
    extraUpFlags = [ "--advertise-exit-node" ];
    port = 41641;
    openFirewall = true;
  };
  networking = {
    networkmanager = {
      # workaround for systemd-networkd-wait-online.service timing out on generation activation
      # https://github.com/NixOS/nixpkgs/issues/180175
      unmanaged = [ "tailscale0" ];
    };
  };
}
