{ pkgs, lib, ... }:
let
  uptimeKumaPort = 3001;
  uptimeKumaHost = "up.felixzieger.de";
in
{
  config = {
    services.nginx.virtualHosts."${uptimeKumaHost}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString uptimeKumaPort}";
        proxyWebsockets = true;
      };
    };

    services = {
      uptime-kuma = {
        enable = true;
        settings = {
          UPTIME_KUMA_HOST = "localhost";
          UPTIME_KUMA_PORT = builtins.toString uptimeKumaPort;
        };
      };
    };
  };
}
