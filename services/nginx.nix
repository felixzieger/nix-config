{ pkgs, config, lib, ... }:
let
  access_logs_root =
    "/var/www/nginx.${config.networking.hostName}.felixzieger.de";
in {
  config = {
    networking = {
      firewall = {
        allowedTCPPorts = [ 80 443 ];
        allowedUDPPorts = [ 443 ];
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "admin@sonnenhof-zieger.de";
    };
    # Use Nginx as reverse proxy.
    # Nginx supports Let's Encrypt certificates
    # See https://nixos.wiki/wiki/Nginx
    services.nginx = {
      enable = true;
      package = pkgs.nginxQuic; # HTTP/3 support

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };

    services.nginx.virtualHosts."_" = {
      default = true;
      extraConfig = "deny all;";
    };

    # Nginx Access logs HTML page via GoAccess
    environment.systemPackages = with pkgs; [ goaccess ];

    systemd.services.goaccess-html = {
      enable = true;
      description = "Serves Nginx access logs as HTML file.";
      path = [ pkgs.goaccess ];
      script =
        "goaccess /var/log/nginx/access.log -o ${access_logs_root}/index.html --log-format=COMBINED --real-time-html";
      serviceConfig = {
        Type = "simple";
        User = config.services.nginx.user;
        Group = config.services.nginx.group;
      };
    };

    system.activationScripts.makeWwwDir = lib.stringAfter [ "var" ] ''
      mkdir -p ${access_logs_root}
      chown ${config.services.nginx.user}:${config.services.nginx.group} ${access_logs_root}
    '';

    services.nginx.virtualHosts."nginx.${config.networking.hostName}.felixzieger.de" = # TODO restrict access; e.g. via oauth2-proxy
      {
        forceSSL = true;
        enableACME = true;
        http3 = true;
        quic = true;
        root = access_logs_root;
      };
  };
}
