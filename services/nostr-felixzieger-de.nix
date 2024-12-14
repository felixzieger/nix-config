{
  config,
  ...
}:
{
  imports = [ ./nostr-rs-relay.nix ];

  services.nginx.virtualHosts."nostr.felixzieger.de" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.nostr-rs-relay.port}";
      proxyWebsockets = true;
    };
  };

  services.nostr-rs-relay = {
    enable = true;
    settings = {

      info = {
        relay_url = "wss://nostr.felixzieger.de/";
        name = "nostr.felixzieger.de";
        description = "This my personal relay.";
      };

      authorization = {
        pubkey_whitelist = [
          "764e0b2e0791453bc77d7b43df789050b7518f9f0e874170135043a0ce324f77"
        ];
      };

      limits = {
        subscriptions_per_min = 10;
        limit_scrapers = false;
      };

    };
  };
}
