{ pkgs, config, ... }:
{
  config = {
    networking = {
      firewall = {
        allowedUDPPorts = [ 53 ];
      };
    };

    services.nginx.virtualHosts."adguard.${config.networking.hostName}.local" = {
      rejectSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.adguardhome.port}";
      };
    };

    services = {
      adguardhome = {
        enable = true;
        settings = {
          schema_version = 20;
        };
        port = 3000;
      };
    };
  };
}
