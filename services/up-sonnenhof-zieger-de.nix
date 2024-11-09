{ config, pkgs, lib, ... }:
let
  uptimeKumaPort = 3001;
  uptimeKumaHost = "up.sonnenfhof-zieger.de";
in {
  config = {
    services.nginx.virtualHosts."${uptimeKumaHost}" = {
      forceSSL = true;
      enableACME = true;
      http3 = true;
      quic = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString uptimeKumaPort}";
        proxyWebsockets = true;
      };
    };

    services = {
      uptime-kuma = {
        enable = true;
        settings = {
          UPTIME_KUMA_HOST = "localhost";
          UPTIME_KUMA_PORT = builtins.toString uptimeKumaPort;
        };
      };
    };

    age.secrets = {
      up-sonnenhof-zieger-de-restic-environment.file =
        ../secrets/up-sonnenhof-zieger-de-restic-environment.age;
      up-sonnenhof-zieger-de-restic-password.file =
        ../secrets/up-sonnenhof-zieger-de-restic-password.age;
    };

    services.restic.backups.uptime-kuma = {
      initialize = true;

      # Since Restic doesn't follow symlinks, this would only backup the symlink to the dir we want to backup
      # paths = [ config.services.uptime-kuma.settings.DATA_DIR ];
      paths = [ "/var/lib/private/uptime-kuma" ];

      repository = "b2:up-sonnenhof-zieger-de";
      environmentFile =
        config.age.secrets.up-sonnenhof-zieger-de-restic-environment.path;
      passwordFile =
        config.age.secrets.up-sonnenhof-zieger-de-restic-password.path;

      timerConfig = {
        OnCalendar = "16:00";
        RandomizedDelaySec = "5min";
      };

      pruneOpts = [ "--keep-daily 7" "--keep-weekly 5" "--keep-monthly 12" ];
    };
  };
}
