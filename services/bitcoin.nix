{ pkgs, config, nix-bitcoin, ... }:
{
  config = {
    # nix-bitcoin.useVersionLockedPkgs = true;

    # Automatically generate all secrets required by services.
    # The secrets are stored in /etc/nix-bitcoin-secrets
    nix-bitcoin.generateSecrets = true;

    # nodeinfo is a small helper script
    nix-bitcoin.nodeinfo.enable = true;
    environment.systemPackages = with pkgs; [
      jq
    ];

    services.bitcoind = {
      enable = true;
      listen = true;
      dataDir = "/data/bitcoind";
      dbCache = 2048;
    };

    services.clightning = {
      enable = true;
      address = "127.0.0.1";
      port = 9735;
    };
    services.clightning-rest.port = 3002;

    services.nginx.virtualHosts."rtl.${config.networking.hostName}.local" = {
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.rtl.port}";
      };
    };
    services.rtl = {
      enable = true;
      address = "127.0.0.1";
      port = 3003;
      nodes.clightning.enable = true;
      extraCurrency = "EUR";
    };

    nix-bitcoin.operator = {
      enable = true;
      name = "felix";
    };

    services.nginx.virtualHosts."pay.sonnenhof-zieger.de" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.btcpayserver.port}";
      };
    };
    services.btcpayserver = {
      enable = true;
      lightningBackend = "clightning";
      dataDir = "/data/btcpayserver";
    };
    services.nbxplorer = {
      dataDir = "/data/nbxplorer";
    };

  };
}
