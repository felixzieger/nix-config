{
  config,
  pkgs,
  ...
}:
{
  # Inspect mysql database
  environment.systemPackages = with pkgs; [ mycli ];

  services.nginx.virtualHosts."${config.services.nextcloud.hostName}" = {
    forceSSL = true;
    enableACME = true;
    http3 = true;
    quic = true;
  };

  age.secrets = {
    # nextcloud-sonnenhof-zieger-de-restic-environment.file = ../secrets/nextcloud-sonnenhof-zieger-de-restic-environment.age;
    # nextcloud-sonnenhof-zieger-de-restic-password.file = ../secrets/nextcloud-sonnenhof-zieger-de-restic-password.age;

    nextcloud-sonnenhof-zieger-de-adminpass = {
      file = ../secrets/nextcloud-sonnenhof-zieger-de-adminpass.age;
      owner = "nextcloud";
    };
    nextcloud-sonnenhof-zieger-de-settings.file = ../secrets/nextcloud-sonnenhof-zieger-de-settings.age;
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;
    hostName = "nextcloud.sonnenhof-zieger.de";

    home = "/data/nextcloud_basic/home";
    datadir = "/data/nextcloud_basic/data"; # https://github.com/NixOS/nixpkgs/issues/369585
    https = true;
    # configureRedis = true; # https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/caching_configuration.html
    database.createLocally = true;
    config = {
      dbtype = "mysql";
      dbname = "nextcloud";

      adminuser = "root";
      adminpassFile = config.age.secrets.nextcloud-sonnenhof-zieger-de-adminpass.path;
    };

    settings = {
      instanceid = "oc9q0e2kg0pj";
      default_phone_region = "DE";
      mysql.utf8mb4 = toString true;

      mail_from_address = "nextcloud";
      mail_smtpmode = "smtp";
      mail_sendmailmode = "smtp";
      mail_domain = "sonnenhof-zieger.de";
      mail_smtpauthtype = "LOGIN";
      mail_smtpauth = toString true;
      mail_smtphost = "smtp.strato.de";
      mail_smtpport = "465";
      mail_smtpsecure = "ssl";
      mail_smtpname = "nextcloud@sonnenhof-zieger.de";

      apps_paths = [
        {
          url = "/apps";
          path = "${config.services.nextcloud.datadir}/custom_apps";
          writable = toString true;
        }
      ];
      # Contains paswordsalt, secret, mail_smtppassword
      secretFile = config.age.secrets.nextcloud-sonnenhof-zieger-de-settings.path;
    };
  };
}
