{
  config,
  nixpkgs-unstable,
  pkgs,
  lib,
  ...
}:
let
  paperlessHost = "paperless.sonnenhof-zieger.de";
  unstable = import nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  config = {
    services.nginx.virtualHosts."${paperlessHost}" = {
      forceSSL = true;
      enableACME = true;
      http3 = true;
      quic = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.paperless.port}";
        proxyWebsockets = true;
      };
    };

    services = {
      paperless = {
        enable = true;
        package = unstable.paperless-ngx;
        # address = paperlessHost;
        settings.PAPERLESS_OCR_LANGUAGE = "deu+eng";
      };
    };

    # Example log entry
    # Feb 22 00:00:00 blausieb paperless-web-start[443349]: [2025-02-22 00:00:00,000] [INFO] [paperless.auth] Login failed for user `hans` from IP `0.0.0.0`.
    environment.etc."fail2ban/filter.d/paperless.local".text = pkgs.lib.mkDefault (
      pkgs.lib.mkAfter ''
        [INCLUDES]
        before = common.conf

        [Definition]
        failregex = ^.*Login failed for user `.*` from IP `<ADDR>`\.$
        ignoreregex =
      ''
    );

    services.fail2ban = {
      enable = true;
      jails = {
        paperless.settings = {
          enabled = true;
          filter = "paperless[journalmatch='_SYSTEMD_UNIT=paperless-web.service']";
          backend = "systemd";
          banaction = "%(banaction_allports)s";
          maxretry = 10;
        };
      };
    };


    age.secrets = {
      paperless-sonnenhof-zieger-de-restic-environment.file = ../secrets/paperless-sonnenhof-zieger-de-restic-environment.age;
      paperless-sonnenhof-zieger-de-restic-password.file = ../secrets/paperless-sonnenhof-zieger-de-restic-password.age;
    };

    services.restic.backups =
      let
        tempBackupDir = "/tmp/paperless-backup";
      in
      {
        paperless = {
          initialize = true;

          backupPrepareCommand = ''
            mkdir -p ${tempBackupDir}
            ${config.services.paperless.dataDir}/paperless-manage document_exporter ${tempBackupDir} --delete
          '';
          paths = [ tempBackupDir ];
          backupCleanupCommand = "rm -rf ${tempBackupDir}";

          repository = "b2:paperless-sonnenhof-zieger-de";
          environmentFile = config.age.secrets.paperless-sonnenhof-zieger-de-restic-environment.path;
          passwordFile = config.age.secrets.paperless-sonnenhof-zieger-de-restic-password.path;

          timerConfig = {
            OnCalendar = "16:00";
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
}
