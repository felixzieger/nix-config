{
  pkgs,
  config,
  nixpkgs-felix,
  ...
}:
let
  felix = import nixpkgs-felix {
    system = pkgs.system;
  };
in
{
  imports = [ ./strfry.nix ];

  services.nginx.virtualHosts."strfry.felixzieger.de" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.strfry.port}";
      proxyWebsockets = true;
    };
  };

  services.strfry = {
    enable = true;
    package = felix.strfry;
    settings = {

      relay = {
        nofiles = 20000;

        info = {
          name = "Felix' strfry";
          description = "This is a strfry instance.";
          pubkey = "764e0b2e0791453bc77d7b43df789050b7518f9f0e874170135043a0ce324f77";
        };
      };
    };
  };
}
