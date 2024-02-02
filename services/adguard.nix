{ pkgs, config, ... }:
let
  adguardPort = 3000;
in
{
  config = {
    networking = {
      firewall = {
        allowedTCPPorts = [ adguardPort ];
        allowedUDPPorts = [ 53 ];
      };
    };

    services.nginx.virtualHosts."adguard.${config.networking.hostName}.local" = {
      locations."/" = {
        proxyPass = "http://localhost:${toString adguardPort}";
      };
    };

    services = {
      adguardhome = {
        enable = true;
        openFirewall = true;
        settings = {
          bind_port = adguardPort;
          schema_version = 20;
        };
      };
    };
  };
}
