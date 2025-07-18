{
  config,
  pkgs,
  lib,
  ...
}:
let
  vaultwardenHost = "bitwarden.sonnenhof-zieger.de";
in
{
  config = {
    services = {
      nginx.virtualHosts."${vaultwardenHost}" = {
        forceSSL = true;
        enableACME = true;
        http3 = true;
        quic = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT}";
          proxyWebsockets = true;
        };
      };

      vaultwarden = {
        enable = true;
        backupDir = "/data/vaultwarden/backup";
        environmentFile = config.age.secrets.bitwarden-sonnenhof-zieger-de-environment.path;
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

      # I followed https://github.com/dani-garcia/vaultwarden/wiki/Fail2Ban-Setup
      fail2ban = {
        enable = true;
        jails = {
          vaultwarden.settings = {
            enabled = true;
            filter = "vaultwarden[journalmatch='_SYSTEMD_UNIT=vaultwarden.service']";
            backend = "systemd";
            banaction = "%(banaction_allports)s";
            maxretry = 10;
          };
        };
      };

      restic.backups = {
        bitwarden = {
          initialize = true;

          paths = [ config.services.vaultwarden.backupDir ];

          repository = "b2:schwalbe-vaultwarden";
          environmentFile = config.age.secrets.bitwarden-sonnenhof-zieger-de-restic-environment.path;
          passwordFile = config.age.secrets.bitwarden-sonnenhof-zieger-de-restic-password.path;

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

    # Example log entry
    # Feb 22 00:00:00 blausieb vaultwarden[583428]: [2025-02-22 00:00:00.000][vaultwarden::api::identity][ERROR] Username or password is incorrect. Try again. IP: 0.0.0.0. Username: hans@web.de.
    environment.etc."fail2ban/filter.d/vaultwarden.local".text = pkgs.lib.mkDefault (
      pkgs.lib.mkAfter ''
        [INCLUDES]
        before = common.conf

        [Definition]
        failregex = ^.*Username or password is incorrect\. Try again\. IP: <ADDR>\. Username:.*$
        ignoreregex =
      ''
    );

    age.secrets = {
      bitwarden-sonnenhof-zieger-de-environment.file = ../secrets/bitwarden-sonnenhof-zieger-de-environment.age;
      bitwarden-sonnenhof-zieger-de-restic-environment.file = ../secrets/bitwarden-sonnenhof-zieger-de-restic-environment.age;
      bitwarden-sonnenhof-zieger-de-restic-password.file = ../secrets/bitwarden-sonnenhof-zieger-de-restic-password.age;
    };
  };
}
