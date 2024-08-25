# How to use

Config files for nixos are in `/etc/nixos`.
Reload config via `sudo nixos-rebuild switch`

Config files for mac os are in `~/.nixpkgs`.
Relod config via `darwin-rebuild switch --flake ~/.nixpkgs `

## Add a new machine

- `mv /etc/nixos /etc/old_nixos`
- `nix-shell -p git`
- ssh-keygen
- add public key to github repo
- `git clone git@github.com:felixzieger/nix-config.git /etc/nixos`
- `mkdir hosts/<path-to-new-host-config>`
- `cp /etc/old_nixos/*.nix hosts/<path-to-new-host-config>`
- `git add hosts/<path-to-new-host-config>`
- add `<hostname>` config to flake.nix
- `nixos-rebuild switch --flake .#<hostname>`
- rm -rf /etc/old_nixos

## Update inputs

```
# Update flake.lock
nix flake update
```

## Debug a service

Use journalctrl to insepct logs. For example, to watch uptime-kuma related logs:

`journalctl -u uptime-kuma.service -b0`

Where the 
- `-u` argument is a unit name (retrievable by using systemctl) and
- `-b 0` filters by current boot.

## Show a config variable for debugging

Add the following bit and rebuild switch

```
system.extraDependencies = let
  debugVal = config.networking.firewall.allowedTCPPorts;
in lib.traceSeqN 3 debugVal [];
```

# Backups

The flake uses restic to create backups on b2. I followed https://www.arthurkoziel.com/restic-backups-b2-nixos/ and https://francis.begyn.be/blog/nixos-restic-backups for setup.

Start the service manually to trigger a new backup run:
`$ sudo systemctl start restic-$job.service`
Check the ouput for errors:
`$ journalctl -u restic-$job.service`

The restic service creates wrapper scripts for each job. 
The script is name `restic-$job`. It will automatically load the environment variables, repository name and password from the service definition.

For example, to restore the uptime-kuma backup run:
`sudo restic-uptime-kuma restore latest --target /`

# Home Assistant

- For Emfit integration I used https://github.com/jxlarrea/ha-emfitqs but I don't exactly remember how I set it up but I don't exactly remember how I set it up
- Voice control in German is pretty bad https://community.home-assistant.io/t/whisper-is-really-bad-at-understanding-german-what-can-i-do-about-that/599167/3

# Up next

- Observability https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
- Deploying to remote hosts https://nixos-and-flakes.thiscute.world/best-practices/remote-deployment (colema or nixos-rebuild)
- Write proper modules (with options and all). See https://guekka.github.io/nixos-server-2/ for an example
- Nextcloud backup to Schwalbe
- Encryption at rest for servers (password for decryption via SSH at boot; see https://www.return12.net/decrypt-nixos-via-ssh/)
- Get rid of ../../ imports. Have a look at https://github.com/NotAShelf/nyx/
