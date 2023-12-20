{ pkgs, lib, ... }:
{
  config = {
    networking = {
      firewall = {
        allowedTCPPorts = [ 80 443 ];
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
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };
  };
}
