{ pkgs, config, ... }: {
  config = {
    networking = { firewall = { allowedUDPPorts = [ 53 ]; }; };

    services.nginx.virtualHosts."adguard.${config.networking.hostName}.local" =
      {
        rejectSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${
              toString config.services.adguardhome.settings.bind_port
            }";
        };
      };

    services = {
      adguardhome = {
        enable = true;
        settings = {
          bind_port = 3000;
          schema_version = 20;
        };
      };
    };
  };
}
