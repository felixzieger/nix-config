# How to use

Config files for nixos are in `/etc/nixos`.
Reload config via `sudo nixos-rebuild switch`

Config files for mac os are in `~/.nixpkgs`.
Relod config via `darwin-rebuild switch --flake ~/.nixpkgs `

# Service Debugging

`journalctl -u plausible.service -b0`

Where the 
- `-u` argument is a unit name (retrievable by using systemctl) and
- `-b 0` filters by current boot.

# Nix config Debugging

Show values. Add and rebuild switch

```
system.extraDependencies = let
  debugVal = config.networking.firewall.allowedTCPPorts;
in lib.traceSeqN 3 debugVal [];
```

# Home Assistant

- Emfit integration https://github.com/jxlarrea/ha-emfitqs
- Voice control in German is pretty bad https://community.home-assistant.io/t/whisper-is-really-bad-at-understanding-german-what-can-i-do-about-that/599167/3

# Up next

- Observability https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
- Write proper modules (with options and all). See https://guekka.github.io/nixos-server-2/ for an example
- Nextcloud backup to Schwalbe
- Restrict redirection of nginx to adguard
