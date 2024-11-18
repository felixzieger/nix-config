{ pkgs, config, lib, ... }: {
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
      extraConfig = ''
        deny all; 
      '';
    };
    services.fail2ban = {
      jails = {
        ngnix-url-probe.settings = {
          enabled = true;
          filter = "nginx-url-probe";
          logpath = "/var/log/nginx/access.log";
          action = ''
            %(action_)s[blocktype=DROP]
          '';
          backend =
            "auto"; # Do not forget to specify this if your jail uses a log file
          maxretry = 5;
          findtime = 600;
        };
      };
    };
    environment.etc = {
      # Defines a filter that detects URL probing by reading the Nginx access log
      "fail2ban/filter.d/nginx-url-probe.local".text = pkgs.lib.mkDefault
        (pkgs.lib.mkAfter ''
          [Definition]
          failregex = ^<HOST>.*(GET /(wp-|admin|boaform|phpmyadmin|\.env|\.git)|\.(dll|so|cfm|asp)|(\?|&)(=PHPB8B5F2A0-3C92-11d3-A3A9-4C7B08C10000|=PHPE9568F36-D428-11d2-A769-00AA001ACF42|=PHPE9568F35-D428-11d2-A769-00AA001ACF42|=PHPE9568F34-D428-11d2-A769-00AA001ACF42)|\\x[0-9a-zA-Z]{2})
        '');
    };
  };
}
