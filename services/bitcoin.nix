{ pkgs, config, nix-bitcoin, ... }:
let
  rtlPort = 3003;
in
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
      dbCache = 4096;
    };

    services.clightning.enable = true;
    services.clightning = {
      address = "127.0.0.1";
      port = 9735;
    };

    services.clightning-rest.port = 3002;

    services.nginx.virtualHosts."rtl.${config.networking.hostName}.local" = {
      locations."/" = {
        proxyPass = "http://localhost:${toString rtlPort}";
      };
    };
    services.rtl.enable = true;
    services.rtl = {
      address = "127.0.0.1";
      port = rtlPort;
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
