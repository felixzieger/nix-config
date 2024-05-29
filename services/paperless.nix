{ config, pkgs, lib, ... }:
let paperlessHost = "paperless.sonnenhof-zieger.de";
in {
  config = {
    services.nginx.virtualHosts."${paperlessHost}" = {
      forceSSL = true;
      enableACME = true;
      http3 = true;
      quic = true;
      locations."/" = {
        proxyPass =
          "http://localhost:${toString config.services.paperless.port}";
        proxyWebsockets = true;
      };
    };

    services = {
      paperless = {
        enable = true;
        paperelss.address = paperlessHost;
        dataDir = "/data/paperless/data";
      };
    };

    age.secrets = {
      paperless-restic-environment.file =
        ../secrets/paperless-restic-environment.age;
      paperless-restic-password.file = ../secrets/paperless-restic-password.age;
    };

    services.restic.backups = {
      paperless = {
        initialize = true;

        paths = [ config.services.paperless.dataDir ];

        repository = "b2:${config.networking.hostName}-paperless";
        environmentFile = config.age.secrets.paperless-restic-environment.path;
        passwordFile = config.age.secrets.paperless-restic-password.path;

        timerConfig = {
          OnCalendar = "16:00";
          RandomizedDelaySec = "5min";
        };

        pruneOpts = [ "--keep-daily 7" "--keep-weekly 5" "--keep-monthly 12" ];
      };
    };
  };
}
