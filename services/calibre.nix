{ pkgs, config, ... }:
{
  services.nginx.virtualHosts."calibre.${config.networking.hostName}.local" = {
    rejectSSL = true;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.calibre-web.listen.port}";
    };
  };

  services = {
    calibre-web = {
      enable = true;
      options.enableBookUploading = true;
    };
  };
}
