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
  };
}
