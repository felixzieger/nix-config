{
  config,
  pkgs,
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
  # TODO rm upon channel upgrade
  imports = [
    "${args.nixpkgs-unstable}/nixos/modules/services/web-apps/haven.nix"
  ];

  services.nginx.virtualHosts."nostr.sonnenhof-zieger.de" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.haven.settings.RELAY_PORT}";
      proxyWebsockets = true;
    };
  };

  services.haven = {
    enable = true;
    package = unstable.haven;
    blastrRelays = [
      "nostr.felixzieger.de"
    ];
    importRelays = [
      "nostr.felixzieger.de"
    ];
    settings = {
      RELAY_URL = "nostr.sonnenhof-zieger.de";
      OWNER_NAME = "sonnenhof-zieger";
      OWNER_NPUB = "npub1we8qkts8j9znh3ma0dpa77ys2zm4rrulp6r5zuqn2pp6pn3jfamsy7c6je";
    };
  };
}
