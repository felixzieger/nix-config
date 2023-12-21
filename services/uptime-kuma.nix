{ pkgs, lib, ... }:
let
  uptimeKumaPort = 3001;
in
{
  config = {

    services.nginx.virtualHosts."up.sonnenhof-zieger.de" = {
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
