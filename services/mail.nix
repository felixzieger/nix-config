{ config, pkgs, ... }:
{
  age.secrets = {
    think-in-sync-mail.file = ../secrets/think-in-sync-mail.age;
  };
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
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "security@think-in-sync.com";
}
