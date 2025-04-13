{ pkgs, ... }:
{
  config = {
    networking = {
      firewall = {
        allowedTCPPorts = [
          80
          443
        ];
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

    # We force users to use proper server names
    services.nginx.virtualHosts."_" = {
      default = true;
      rejectSSL = true;
      extraConfig = ''
        deny all; 
      '';
    };
    services.fail2ban = {
      jails = {
        nginx-http-auth.settings = {
          enabled = true;
          port = "http,https";
          logpath = "/var/log/nginx/access.log";
          backend = "auto";
        };
        nginx-botsearch.settings = {
          enabled = true;
          port = "http,https";
          logpath = "/var/log/nginx/access.log";
          backend = "auto";
        };
        nginx-url-probe.settings = {
          enabled = true;
          filter = "nginx-url-probe";
          logpath = "/var/log/nginx/access.log";
          backend = "auto";
        };
        nginx-ip-host.settings = {
          enabled = true;
          filter = "nginx-ip-host";
          logpath = "/var/log/nginx/access.log";
          backend = "auto";
        };
      };
    };
    environment.etc = {
      "fail2ban/filter.d/nginx-url-probe.local".text = pkgs.lib.mkDefault (
        pkgs.lib.mkAfter ''
          [Definition]
          failregex = ^.*<HOST> - .* "(GET|POST) /(wp-|boaform|phpmyadmin|\.env|\.git|.*\.(dll|so|cfm|asp)) HTTP/.*" 4[0-9]{2} .*
        ''
      );
      "fail2ban/filter.d/nginx-ip-host.local".text = pkgs.lib.mkDefault (
        pkgs.lib.mkAfter ''
          [Definition]
          failregex = ^\s*\S+ nginx\[\d+\]: \d+/\d+/\d+ \d+:\d+:\d+ \[error\] \d+#\d+: \*\d+ access forbidden by rule, client: <HOST>, server: .*, request: "(?:GET|POST) .*", host: "\d+\.\d+\.\d+\.\d+"$
        ''
      );
    };
  };
}
