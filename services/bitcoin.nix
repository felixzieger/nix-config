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

  # Open the p2p port in the firewall
  networking.firewall.allowedTCPPorts = [ config.services.bitcoind.onionPort ];
}
