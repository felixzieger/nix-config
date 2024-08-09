{ pkgs, config, lib, ... }:
let
  goaccess_host = "nginx.${config.networking.hostName}.felixzieger.de";
  goaccess_root = "/var/www/${goaccess_host}";
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
      restartIfChanged = true;
      description = "Serves Nginx access logs as HTML file.";
      path = [ pkgs.goaccess ];
      script = ''
        goaccess /var/log/nginx/access.log \
          -o ${goaccess_root}/index.html \
          --log-format=COMBINED \
          --real-time-html \
          --html-report-title="${config.networking.hostName} nginx logs" \
          --ws-url=wss://${goaccess_host}:443/ws \
          --port=7890 \
          --no-global-config \
          --origin=https://${goaccess_host}
      '';
      serviceConfig = {
        Type = "simple";
        User = config.services.nginx.user;
        Group = config.services.nginx.group;
      };
    };

    system.activationScripts.makeWwwDir = lib.stringAfter [ "var" ] ''
      mkdir -p ${goaccess_root}
      chown ${config.services.nginx.user}:${config.services.nginx.group} ${goaccess_root}
    '';

    services.nginx.virtualHosts."${goaccess_host}" = # TODO restrict access; e.g. via oauth2-proxy
      {
        forceSSL = true;
        enableACME = true;
        http3 = true;
        quic = true;
        root = goaccess_root;
        locations."/ws" = {
          proxyPass =
            "http://127.0.0.1:7890"; # GoAccess serves websocket on port 7890 by default
          proxyWebsockets = true;
        };
      };
  };
}
