{ config, ... }:
{
  # stored under /etc/nix-bitcoin-secrets
  nix-bitcoin = {
    generateSecrets = true;
    # nodeinfo cli
    nodeinfo.enable = true;
    # access bitcoin features without sudo
    operator = {
      enable = true;
      name = "felix";
    };
  };

  services = {
    bitcoind = {
      enable = true;
      listen = true;
      dataDir = "/data/bitcoind";
      dbCache = 4096;
    };

    nginx.virtualHosts."pay.sonnenhof-zieger.de" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.btcpayserver.port}";
      };
    };

    btcpayserver = {
      enable = true;
      dataDir = "/data/btcpayserver";
    };

    postgresqlBackup = {
      enable = true;
      location = "/data/postgresqlbackup";
      startAt = "*-*-* 01:15:00";
    };

    restic.backups = {
      btcpay = {
        initialize = true;

        paths = [
          config.services.btcpayserver.dataDir
          config.services.postgresqlBackup.location
        ];

        repository = "b2:pay-sonnenhof-zieger-de";
        environmentFile = config.age.secrets.pay-sonnenhof-zieger-de-restic-environment.path;
        passwordFile = config.age.secrets.pay-sonnenhof-zieger-de-restic-password.path;

        timerConfig.OnCalendar = "01:30";

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
        ];
      };
    };
  };

  age.secrets = {
    pay-sonnenhof-zieger-de-restic-environment.file = ../secrets/pay-sonnenhof-zieger-de-restic-environment.age;
    pay-sonnenhof-zieger-de-restic-password.file = ../secrets/pay-sonnenhof-zieger-de-restic-password.age;
  };

  # Open the p2p port in the firewall
  networking.firewall.allowedTCPPorts = [ config.services.bitcoind.onionPort ];
}
