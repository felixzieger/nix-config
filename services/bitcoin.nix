{ nix-bitcoin, ... }:
{
  config = {
    # Automatically generate all secrets required by services.
    # The secrets are stored in /etc/nix-bitcoin-secrets
    nix-bitcoin.generateSecrets = true;

    services.bitcoind = {
      enable = true;
      dataDir = "/data/bitcoind";
      dbCache = 8192;
    };
    # When using nix-bitcoin as part of a larger NixOS configuration, set the following to enable
    # interactive access to nix-bitcoin features (like bitcoin-cli) for your system's main user
    nix-bitcoin.operator = {
      enable = true;
      name = "felix";
    };
  };
}
