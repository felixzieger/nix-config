{
  pkgs,
  config,
  nixpkgs-unstable,
  ...
}@args:
let
  unstable = import nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  imports = [
    "${args.nixpkgs-unstable}/nixos/modules/services/web-apps/strfry.nix"
  ];

  services.nginx.virtualHosts."strfry.felixzieger.de" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.strfry.settings.relay.port}";
      proxyWebsockets = true;
    };
  };

  services.strfry = {
    enable = true;
    package = unstable.strfry;
    settings = {

      relay.info = {
        name = "Felix' strfry";
        description = "This is a strfry instance.";
        pubkey = "764e0b2e0791453bc77d7b43df789050b7518f9f0e874170135043a0ce324f77";
      };
    };
  };
}
