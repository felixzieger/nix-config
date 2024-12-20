{
  config,
  ...
}:
{
  imports = [ ./alby-hub.nix ];

  services.nginx.virtualHosts."alby.felixzieger.de" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.alby-hub.port}";
      proxyWebsockets = true;
    };
  };

  services.alby-hub = {
    enable = true;
  };
}