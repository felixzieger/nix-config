{
  config,
  ...
}:
{
  # Check stored notes via https://jumble.social/?r=nostr.felixzieger.de
  # Check relay performance on https://nostr.watch/
  services = {
    nginx.virtualHosts."nostr.felixzieger.de" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.nostr-rs-relay.port}";
        proxyWebsockets = true;
      };
    };

    nostr-rs-relay = {
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

    restic.backups = {
      nostr = {
        initialize = true;

        paths = [ config.services.nostr-rs-relay.dataDir ];

        repository = "b2:nostr-felixzieger-de";
        environmentFile = config.age.secrets.nostr-felixzieger-de-restic-environment.path;
        passwordFile = config.age.secrets.nostr-felixzieger-de-restic-password.path;

        timerConfig = {
          OnCalendar = "04:00";
          RandomizedDelaySec = "5min";
        };

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
        ];
      };
    };
  };

  age.secrets = {
    nostr-felixzieger-de-restic-environment.file = ../secrets/nostr-felixzieger-de-restic-environment.age;
    nostr-felixzieger-de-restic-password.file = ../secrets/nostr-felixzieger-de-restic-password.age;
  };
}
