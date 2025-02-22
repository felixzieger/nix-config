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
