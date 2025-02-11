{ config, pkgs, ... }:
{
  age.secrets = {
    think-in-sync-mail.file = ../secrets/think-in-sync-mail.age;
  };

  # I use msmtp for sendmail (see systemd-email-notify)
  services.postfix.setSendmail = false;

  mailserver = {
    enable = true;
    fqdn = "mail.think-in-sync.com";
    domains = [ "think-in-sync.com" ];

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "hello@think-in-sync.com" = {
        hashedPasswordFile = config.age.secrets.think-in-sync-mail.path;
        aliases = [
          "felix@think-in-sync.com"
          "postmaster@think-in-sync.com"
        ];
      };
    };

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };

  # age.secrets = {
  #   mail-think-in-sync-com-restic-environment.file = ../secrets/mail-think-in-sync-com-restic-environment.age;
  #   mail-think-in-sync-com-restic-password.file = ../secrets/mail-think-in-sync-com-restic-password.age;
  # };

  # services.restic.backups = {
  #   docsy = {
  #     initialize = true;

  #     paths = [ config.services.mailserver.mailDirectory ];

  #     repository = "b2:app-getdocsy-com";
  #     environmentFile = config.age.secrets.mail-think-in-sync-com-restic-environment.path;
  #     passwordFile = config.age.secrets.mail-think-in-sync-com-restic-password.path;

  #     timerConfig = {
  #       OnCalendar = "19:00";
  #       RandomizedDelaySec = "5min";
  #     };

  #     pruneOpts = [
  #       "--keep-daily 7"
  #       "--keep-weekly 5"
  #       "--keep-monthly 12"
  #     ];
  #   };
  # };
}
