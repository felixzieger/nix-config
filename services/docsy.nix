{ pkgs, config, ... }:
let
  docsySlackPort = 8080;
  docsyDashboardPort = 8050;
  docsyDataDir = "/data/docsy/data";
  docsyVersion = "v0.6.6";
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
        proxyPass = "http://localhost:${toString docsySlackPort}";
        proxyWebsockets = true;
      };
      locations."/dashboard" = {
        proxyPass = "http://localhost:${toString docsyDashboardPort}/dashboard";
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
          image = "ghcr.io/felixzieger/docsy:${docsyVersion}";
          environment.TZ = "Europe/Berlin";
          ports = [ "${builtins.toString docsySlackPort}:3000" ];
          volumes = [ "${docsyDataDir}:/app/data" ];
          login = {
            registry = "ghcr.io";
            username = "felixzieger";
            passwordFile = config.age.secrets.ghcr-secret.path;
          };
          environmentFiles = [ config.age.secrets.docsy-env.path ];
          labels = {
            "com.centurylinklabs.watchtower.enable" = "false";
          }; # Private registry pulls fail for my watchtower config. Don't need them anyway right now.
        };
        docsy_dashboard = {
          autoStart = true;
          image = "ghcr.io/felixzieger/docsy:${docsyVersion}";
          environment.TZ = "Europe/Berlin";
          ports = [ "${builtins.toString docsyDashboardPort}:8050" ];
          volumes = [ "${docsyDataDir}:/app/data" ];
          login = {
            registry = "ghcr.io";
            username = "felixzieger";
            passwordFile = config.age.secrets.ghcr-secret.path;
          };
          entrypoint = "poetry";
          cmd = [
            "run"
            "gunicorn"
            "-w"
            "1"
            "-b"
            "0.0.0.0:8050"
            "docsy.dashboard:flask_app"
          ];
          labels = {
            "com.centurylinklabs.watchtower.enable" = "false";
          }; # Private registry pulls fail for my watchtower config. Don't need them anyway right now.
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
