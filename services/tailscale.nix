{ config, pkgs, ... }:
# I mostly followed
# https://tailscale.com/kb/1096/nixos-minecraft
{
  age.secrets = { tailscale-authkey.file = ../secrets/tailscale-authkey.age; };

  networking.firewall = { trustedInterfaces = [ "tailscale0" ]; };

  environment.systemPackages = [ pkgs.tailscale ];

  services.tailscale.enable = true;
  services.tailscale = {
    authKeyFile = config.age.secrets.tailscale-authkey.path;
    useRoutingFeatures = "server";
    extraUpFlags = [ "--advertise-exit-node" ];
    port = 41641;
    openFirewall = true;
  };
}

