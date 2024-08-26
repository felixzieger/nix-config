let
  felix =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTTX+nJfoLV+smER/g7CbqZQNN0W++HwCK8EP4oggCJ";
  users = [ felix ];

  schwalbe =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHunIW8dfsxIcafgHHG/lNBW55Tk6aS7Qy86x3TFQG3X";
  cameron =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMPgvfVIcLInSlxUxdU/X0roocVNzEu6FPSOvkhkiLnQ";
  hedwig =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBqSDXUVcrS7OnDVFfYdcnMU24m+6USTJRudXVV8aNK";
  systems = [ schwalbe cameron hedwig ];
in {
  "email-password-bot-sonnenhof-zieger.age".publicKeys = [ schwalbe ];
  "plausible-keybase.age".publicKeys = [ schwalbe ];
  "plausible-admin-password.age".publicKeys = [ schwalbe ];

  "tailscale-authkey.age".publicKeys = [ schwalbe ];

  "netdata-basic-auth.age".publicKeys = systems;

  "uptime-kuma-restic-password.age".publicKeys = [ schwalbe hedwig ];
  "uptime-kuma-restic-environment.age".publicKeys = [ schwalbe hedwig ];
  "home-assistant-restic-password.age".publicKeys = [ schwalbe ];
  "home-assistant-restic-environment.age".publicKeys = [ schwalbe ];

  "vaultwarden-environment.age".publicKeys = [ schwalbe ];
  "vaultwarden-restic-password.age".publicKeys = [ schwalbe ];
  "vaultwarden-restic-environment.age".publicKeys = [ schwalbe ];

  "ghost-environment.age".publicKeys = [ schwalbe ];
  "ghost-restic-password.age".publicKeys = [ schwalbe ];
  "ghost-restic-environment.age".publicKeys = [ schwalbe ];

  "watchtower-environment.age".publicKeys = [ schwalbe ];

  "oauth2_proxy_key.age".publicKeys = [ cameron ];

  "ghcr-secret.age".publicKeys = systems;
  "docsy-env.age".publicKeys = systems;
  "docsy-restic-password.age".publicKeys = [ schwalbe ];
  "docsy-restic-environment.age".publicKeys = [ schwalbe ];
}
