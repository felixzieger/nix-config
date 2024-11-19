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
        ngnix-botsearch.settings = {
          enabled = true;
          filter = "nginx-botsearch";
          maxretry = 5;
          findtime = 3600;
        };
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
          findtime = 3600;
        };
      };
    };
    environment.etc = {
      "fail2ban/filter.d/nginx-url-probe.local".text = pkgs.lib.mkDefault
        (pkgs.lib.mkAfter ''
          [Definition]
          failregex = ^<HOST> - .* "(GET|POST) /(wp-|admin|boaform|phpmyadmin|\.env|\.git|.*\.(dll|so|cfm|asp)) HTTP/.*" 4[0-9]{2} .*
        '');
    };
  };
}
