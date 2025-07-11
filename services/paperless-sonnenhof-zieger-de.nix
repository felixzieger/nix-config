{
  config,
  pkgs,
  ...
}:
let
  paperlessHost = "paperless.sonnenhof-zieger.de";
in
{
  config = {
    services = {
      nginx.virtualHosts."${paperlessHost}" = {
        forceSSL = true;
        enableACME = true;
        http3 = true;
        quic = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.paperless.port}";
          proxyWebsockets = true;
        };
      };

      paperless = {
        enable = true;
        settings = {
          PAPERLESS_OCR_LANGUAGE = "deu+eng";
          PAPERLESS_OCR_USER_ARGS = ''{"invalidate_digital_signatures": true}'';
          PAPERLESS_CSRF_TRUSTED_ORIGINS = "https://${paperlessHost}";
          PAPERLESS_URL = "https://${paperlessHost}";

        };
      };

      fail2ban = {
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

      restic.backups =
        let
          tempBackupDir = "/tmp/paperless-backup";
        in
        {
          paperless = {
            initialize = true;

            backupPrepareCommand = ''
              mkdir -p ${tempBackupDir}
              chown ${config.services.paperless.user}:${config.services.paperless.user} ${tempBackupDir}
              /run/current-system/sw/bin/paperless-manage document_exporter ${tempBackupDir} --delete
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

    age.secrets = {
      paperless-sonnenhof-zieger-de-restic-environment.file = ../secrets/paperless-sonnenhof-zieger-de-restic-environment.age;
      paperless-sonnenhof-zieger-de-restic-password.file = ../secrets/paperless-sonnenhof-zieger-de-restic-password.age;
    };
  };
}
