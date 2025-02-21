{
  config,
  pkgs,
  ...
}:
let
  haven-package = pkgs.callPackage ./haven-package.nix { };
in
{
  imports = [ ./haven.nix ];

  services.nginx.virtualHosts."nostr.sonnenhof-zieger.de" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.haven.port}";
    };
  };

  services.haven = {
    enable = true;
    package = haven-package;
    relayUrl = "nostr.sonnenhof-zieger.de";
    ownerName = "sonnenhof-zieger";
    ownerNpub = "npub1we8qkts8j9znh3ma0dpa77ys2zm4rrulp6r5zuqn2pp6pn3jfamsy7c6je";
    blastrRelays = [
      "nostr.felixzieger.de"
    ];
    importRelays = [
      "nostr.felixzieger.de"
    ];
  };
}
