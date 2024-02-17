# How to use

Config files are in /etc/nixos.

Reload config via
`(HOME="/root"; doas nixos-rebuild switch)`

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
