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
        stub_status on;
        access_log off;
              
        allow 127.0.0.1;
        deny all; 
      '';
    };

    services.nginx.virtualHosts."127.0.0.1" = {
      extraConfig = "stub_status on;";
    };
  };
}
