{ config, ... }:
{
  # stored under /etc/nix-bitcoin-secrets
  nix-bitcoin.generateSecrets = true;

  # nodeinfo cli
  nix-bitcoin.nodeinfo.enable = true;

  # access bitcoin features without sudo
  nix-bitcoin.operator = {
    enable = true;
    name = "felix";
  };

  services.bitcoind = {
    enable = true;
    listen = true;
    dataDir = "/data/bitcoind";
    dbCache = 4096;
  };

  services.nginx.virtualHosts."pay.sonnenhof-zieger.de" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.btcpayserver.port}";
    };
  };

  services.btcpayserver = {
    enable = true;
    dataDir = "/data/btcpayserver";
  };

  # Open the p2p port in the firewall
  networking.firewall.allowedTCPPorts = [ config.services.bitcoind.onionPort ];
}
