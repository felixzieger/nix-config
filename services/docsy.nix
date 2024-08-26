{ pkgs, config, ... }:
let
  docsyPort = 8080;
  docsyDataDir = "/data/docsy/data";
in {
  config = {
    # Inspect sqlite database without docker exec
    environment.systemPackages = with pkgs; [ litecli ];

    services.nginx.virtualHosts."app.getdocsy.com" = {
      forceSSL = true;
      enableACME = true;
      http3 = true;
      quic = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString docsyPort}";
        proxyWebsockets = true;
      };
    };

    age.secrets = {
      ghcr-secret.file = ../secrets/ghcr-secret.age;
      docsy-env.file = ../secrets/docsy-env.age;
    };

    virtualisation.docker.enable = true;
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        docsy = {
          autoStart = true;
          image = "ghcr.io/felixzieger/docsy:v0.6.4";
          environment.TZ = "Europe/Berlin";
          ports = [ "${builtins.toString docsyPort}:3000" ];
          volumes = [ "${docsyDataDir}:/app/data" ];
          login = {
            registry = "ghcr.io";
            username = "felixzieger";
            passwordFile = config.age.secrets.ghcr-secret.path;
          };
          environmentFiles = [ config.age.secrets.docsy-env.path ];
        };
      };
    };
    age.secrets = {
      docsy-restic-environment.file = ../secrets/docsy-restic-environment.age;
      docsy-restic-password.file = ../secrets/docsy-restic-password.age;
    };

    services.restic.backups = {
      docsy = {
        initialize = true;

        paths = [ docsyDataDir ];

        repository = "b2:${config.networking.hostName}-docsy";
        environmentFile = config.age.secrets.docsy-restic-environment.path;
        passwordFile = config.age.secrets.docsy-restic-password.path;

        timerConfig = {
          OnCalendar = "19:00";
          RandomizedDelaySec = "5min";
        };

        pruneOpts = [ "--keep-daily 7" "--keep-weekly 5" "--keep-monthly 12" ];
      };
    };
  };
}
