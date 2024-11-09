let
  felix =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTTX+nJfoLV+smER/g7CbqZQNN0W++HwCK8EP4oggCJ";
  users = [ felix ];

  blausieb =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6l59mQ8I0u6laoKksbh1HcD/iHmjujta+XTBbPPiBb";

  schwalbe =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHunIW8dfsxIcafgHHG/lNBW55Tk6aS7Qy86x3TFQG3X";
  cameron =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMPgvfVIcLInSlxUxdU/X0roocVNzEu6FPSOvkhkiLnQ";
  hedwig =
    # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBqSDXUVcrS7OnDVFfYdcnMU24m+6USTJRudXVV8aNK";
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILS4TPSLCkMkxXH+fhqXo1XgVBZhnpyJSbPqS2vPyiJI";

  systems = [ schwalbe cameron hedwig blausieb ];
in {
  "email-password-bot-sonnenhof-zieger.age".publicKeys = systems;

  "tailscale-authkey.age".publicKeys = [ schwalbe ];

  "netdata-basic-auth.age".publicKeys = systems;

  "uptime-kuma-restic-password.age".publicKeys = systems;
  "uptime-kuma-restic-environment.age".publicKeys = systems;
  "home-assistant-restic-password.age".publicKeys = [ schwalbe ];
  "home-assistant-restic-environment.age".publicKeys = [ schwalbe ];

  "bitwarden-sonnenhof-zieger-de-environment.age".publicKeys =
    [ schwalbe blausieb ];
  "bitwarden-sonnenhof-zieger-de-restic-password.age".publicKeys =
    [ schwalbe blausieb ];
  "bitwarden-sonnenhof-zieger-de-restic-environment.age".publicKeys =
    [ schwalbe blausieb ];

  "blog-felixzieger-de-environment.age".publicKeys = [ schwalbe blausieb ];
  "blog-felixzieger-de-restic-password.age".publicKeys = [ schwalbe blausieb ];
  "blog-felixzieger-de-restic-environment.age".publicKeys =
    [ schwalbe blausieb ];

  "watchtower-environment.age".publicKeys = systems;

  "oauth2_proxy_key.age".publicKeys = systems;

  "ghcr-secret.age".publicKeys = systems;
  "app-getdocsy-com-env.age".publicKeys = systems;
  "app-getdocsy-com-restic-password.age".publicKeys = systems;
  "app-getdocsy-com-restic-environment.age".publicKeys = systems;

  "up-sonnenhof-zieger-de-restic-environment.age".publicKeys =
    [ hedwig ];
  "up-sonnenhof-zieger-de-restic-password.age".publicKeys = [ hedwig ];

  "paperless-sonnenhof-zieger-de-restic-environment.age".publicKeys =
    [ blausieb ];
  "paperless-sonnenhof-zieger-de-restic-password.age".publicKeys = [ blausieb ];

  "plausible-sonnenhof-zieger-de--conf-env.age".publicKeys = [ blausieb ];
  "plausible-sonnenhof-zieger-de-restic-environment.age".publicKeys =
    [ blausieb ];
  "plausible-sonnenhof-zieger-de-restic-password.age".publicKeys = [ blausieb ];
}
