{
  config,
  pkgs,
  ...
}:
{
  services.nginx.virtualHosts."${config.services.nextcloud.hostName}" = {
    forceSSL = true;
    enableACME = true;
    http3 = true;
    quic = true;
  };

  age.secrets = {
    # nextcloud-sonnenhof-zieger-de-restic-environment.file = ../secrets/nextcloud-sonnenhof-zieger-de-restic-environment.age;
    # nextcloud-sonnenhof-zieger-de-restic-password.file = ../secrets/nextcloud-sonnenhof-zieger-de-restic-password.age;

    # nextcloud-sonnenhof-zieger-de-dbpass.file = ../secrets/nextcloud-sonnenhof-zieger-de-dbpass.age;
    nextcloud-sonnenhof-zieger-de-adminpass.file = ../secrets/nextcloud-sonnenhof-zieger-de-adminpass.age;
    nextcloud-sonnenhof-zieger-de-settings.file = ../secrets/nextcloud-sonnenhof-zieger-de-settings.age;
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;
    hostName = "nextcloud.sonnenhof-zieger.de";
    home = "/data/nextcloud/home";
    https = true;
    # configureRedis = true; # https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/caching_configuration.html
    database.createLocally = true;
    config = {
      dbtype = "mysql";
      dbname = "nextcloud";

      # Database is managed via this service and uses unix socket instead of password
      # dbuser = "nextcloud";
      # dbpassFile = config.age.secrets.nextcloud-sonnenhof-zieger-de-dbpass.path;

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

      # Contains paswordsalt, secret, mail_smtppassword
      secretFile = config.age.secrets.nextcloud-sonnenhof-zieger-de-settings.path;
    };
  };
}
