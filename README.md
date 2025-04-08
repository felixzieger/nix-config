# nixos and darwin config

Config for nixos servers and macbook.

## Add a new nixos machine

Log into the machine and run:

- `mv /etc/nixos /etc/old_nixos`
- `nix-shell -p git`
- `git clone git@github.com:felixzieger/nix-config.git /etc/nixos` (use agent forwarding to clone via SSH)
- `mkdir hosts/<path-to-new-host-config>`
- `cp /etc/old_nixos/*.nix hosts/<path-to-new-host-config>`
- `git add hosts/<path-to-new-host-config>`
- add `<hostname>` config to flake.nix
- `nixos-rebuild switch --flake .#<hostname>`
- `systemctl reboot`
- `systemctl status`
- If everyrhing looks good, clean up via `rm -rf /etc/old_nixos`

If SSH access has been established write new config in this repo and run:

- `nixos-rebuild --target-host felix@address-of-new-host> switch`

## Switch to new config

Config files for nixos are in `/etc/nixos`.
Switch to config via `sudo nixos-rebuild switch`.

Config files for mac os are in `~/.nixpkgs`.
Switch to config via `darwin-rebuild switch --flake ~/.nixpkgs `.


## Update inputs

Update versions in flake.lock via

```
nix flake update
```

## Debug a service

Use journalctrl to insepct logs. 

For example, to check uptime-kuma related logs run

```
journalctl -u uptime-kuma.service -e
```

Useful flags are `-e` for directly show the latest logs or `--follow` for showing a live stream of logs.

# Backups

The flake uses restic to create backups on b2. I followed https://www.arthurkoziel.com/restic-backups-b2-nixos/ and https://francis.begyn.be/blog/nixos-restic-backups for setup.

The [restic service](https://mynixos.com/nixpkgs/options/services.restic) creates wrapper scripts for each job. 
The script is name `restic-$job`. It will automatically load the environment variables, repository name and password from the service definition.

```
# Start the service manually to trigger a new backup run
systemctl start restic-$job.service

# Check the ouput for errors
journalctl -u restic-$job.service
```

For example, to restore the uptime-kuma backup run:

```
restic-uptime-kuma restore latest --target /
```

# Home Assistant

- For Emfit integration I used https://github.com/jxlarrea/ha-emfitqs by copying it to data dir manually.
- Voice control in German is pretty bad https://community.home-assistant.io/t/whisper-is-really-bad-at-understanding-german-what-can-i-do-about-that/599167/3

# Up next

- Impermanence https://lantian.pub/en/article/modify-computer/nixos-impermanence.lantian/
- Nextcloud backup to Schwalbe
- Get rid of ../../ imports. Have a look at https://github.com/NotAShelf/nyx/
