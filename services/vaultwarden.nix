{ config, pkgs, lib, ... }:
let
  vaultwardenHost = "bitwarden.sonnenhof-zieger.de";
in
{
  config = {
    services.nginx.virtualHosts."${vaultwardenHost}" = {
      forceSSL = true;
      enableACME = true;
      http3 = true;
      quic = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.vaultwarden.config.ROCKET_PORT}";
        proxyWebsockets = true;
      };
    };

    age.secrets = {
      vaultwarden-environment.file = ../secrets/vaultwarden-environment.age;
    };

    services = {
      vaultwarden = {
        enable = true;
        backupDir = "/data/vaultwarden/backup";
        environmentFile = config.age.secrets.vaultwarden-environment.path;
        config = {
          DOMAIN = "https://${vaultwardenHost}";
          WEBSOCKET_ENABLED = "true";

          SIGNUPS_ALLOWED = false;
          SIGNUPS_DOMAINS_WHITELIST = "sonnenhof-zieger.de";
          INVITATIONS_ALLOWED = "false";
          SHOW_PASSWORD_HINT = "false";

          ROCKET_PORT = 8222;

          SMTP_HOST = "smtp.strato.de";
          SMTP_USERNAME = "bot@sonnenhof-zieger.de";
          SMTP_FROM = "bot@sonnenhof-zieger.de";
          SMTP_FROM_NAME = "Sonnenhof Bitwarden";
          SMTP_SECURITY = "force_tls";
          SMTP_PORT = "465";
          SMTP_TIMEOUT = "15";
        };
      };
    };


    age.secrets = {
      vaultwarden-restic-environment.file = ../secrets/vaultwarden-restic-environment.age;
      vaultwarden-restic-password.file = ../secrets/vaultwarden-restic-password.age;
    };

    services.restic.backups = {
      vaultwarden = {
        initialize = true;

        paths = [ config.services.vaultwarden.backupDir ];

        repository = "b2:${config.networking.hostName}-vaultwarden";
        environmentFile = config.age.secrets.vaultwarden-restic-environment.path;
        passwordFile = config.age.secrets.vaultwarden-restic-password.path;

        timerConfig = {
          # Ideally, this would always run directly after systemd.services.backup-vaultwarden
          # But I don't know how to set this up. The vaultwarden backup unit starts at 23:00, so this just starts a bit later
          # See https://github.com/NixOS/nixpkgs/blob/2230a20f2b5a14f2db3d7f13a2dc3c22517e790b/nixos/modules/services/security/vaultwarden/default.nix#L225
          OnCalendar = "23:30";
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
