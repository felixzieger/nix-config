# strfry {#module-services-strfry}

strfry is a relay for the [nostr protocol](https://github.com/nostr-protocol/nostr).

## Basic usage {#module-services-strfry-server-basic-usage}

By default, the module will execute strfry:

```nix
{ ... }:

{
  services.strfry.enable = true;
}
```
It runs in the systemd service named `strfry`.

If the service fails with an error like `Unable to set NOFILES limit to 1000000, exceeds max of 524288` you must adjust `settings.relay.nofiles`:

```nix
{ ... }:

{
  services.strfry = {
    enable = true;

    settings.relay.nofiles = 524288;
  };
}
```
## Reverse Proxy {#module-services-suwayomi-reverse-proxy}

You can configure nginx as a reverse proxy with:

```nix
{ ... }:

{
  security.acme = {
    acceptTerms = true;
    defaults.email = "foo@bar.com";
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."strfry.example.com" = {
    addSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.strfry.settings.relay.port}";
      proxyWebsockets = true; # nostr uses websockets
    };
  };

  services.strfry.enable = true;
}
```
