{ pkgs, config, ... }:
let
  docsySlackPort = 8080;
  docsyDashboardPort = 8050;
  docsyWebPort = 8001;
  docsyDataDir = "/data/docsy/data";
  docsyVersion = "v0.7.16";
  docsyWebDataDir = "/data/docsy_web/data";
  docsyWebVersion = "v0.0.92";
in
{
  config = {
    # Inspect sqlite database
    environment.systemPackages = with pkgs; [ litecli ];

    services.nginx = {
      proxyTimeout = "360s"; # we are changing this for all servers running on the host; not ideal but okay for now
      virtualHosts."app.getdocsy.com" = {
        forceSSL = true;
        enableACME = true;
        http3 = true;
        quic = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString docsyWebPort}";
        };
        locations."/v1-dashboard" = {
          proxyPass = "http://localhost:${toString docsyDashboardPort}/dashboard";
        };
        locations."/slack" = {
          proxyPass = "http://localhost:${toString docsySlackPort}/slack";
          proxyWebsockets = true;
        };
      };
    };

    age.secrets = {
      ghcr-secret.file = ../secrets/ghcr-secret.age;
      app-getdocsy-com-legacy-env.file = ../secrets/app-getdocsy-com-legacy-env.age;
      app-getdocsy-com-env.file = ../secrets/app-getdocsy-com-env.age;
    };

    virtualisation.oci-containers = {
      containers = {
        docsy = {
          autoStart = true;
          image = "ghcr.io/getdocsy/slack-bot:${docsyVersion}";
          environment.TZ = "Europe/Berlin";
          ports = [ "${builtins.toString docsySlackPort}:3000" ];
          volumes = [ "${docsyDataDir}:/app/data" ];
          login = {
            registry = "ghcr.io";
            username = "felixzieger";
            passwordFile = config.age.secrets.ghcr-secret.path;
          };
          environmentFiles = [ config.age.secrets.app-getdocsy-com-legacy-env.path ];
          labels = {
            "com.centurylinklabs.watchtower.enable" = "false";
          }; # Private registry pulls fail for my watchtower config. Don't need them anyway right now.
        };
        # docsy_dashboard = {
        #   autoStart = true;
        #   image = "ghcr.io/getdocsy/slack-bot:${docsyVersion}";
        #   environment.TZ = "Europe/Berlin";
        #   ports = [ "${builtins.toString docsyDashboardPort}:8050" ];
        #   volumes = [ "${docsyDataDir}:/app/data" ];
        #   login = {
        #     registry = "ghcr.io";
        #     username = "felixzieger";
        #     passwordFile = config.age.secrets.ghcr-secret.path;
        #   };
        #   entrypoint = "poetry";
        #   cmd = [
        #     "run"
        #     "gunicorn"
        #     "-w"
        #     "1"
        #     "-b"
        #     "0.0.0.0:8050"
        #     "docsy.dashboard:flask_app"
        #   ];
        #   labels = {
        #     "com.centurylinklabs.watchtower.enable" = "false";
        #   }; # Private registry pulls fail for my watchtower config. Don't need them anyway right now.
        # };
        docsy_web = {
          autoStart = true;
          image = "ghcr.io/getdocsy/docsy:${docsyWebVersion}";
          ports = [ "${builtins.toString docsyWebPort}:8000" ];
          volumes = [ "${docsyWebDataDir}/src/data:/app/src/data" ];
          entrypoint = "sh";
          cmd = [
            "-c"
            "uv sync --frozen && uv run python src/manage.py migrate && uv run daphne -b 0.0.0.0 -p 8000 docsy.asgi:application"
          ];
          login = {
            registry = "ghcr.io";
            username = "felixzieger";
            passwordFile = config.age.secrets.ghcr-secret.path;
          };
          environmentFiles = [ config.age.secrets.app-getdocsy-com-env.path ];
          environment = {
            RQ_REDIS_HOST = "docsy_web_redis";
            TZ = "Europe/Berlin";
          };
          labels = {
            "com.centurylinklabs.watchtower.enable" = "false";
          }; # Private registry pulls fail for my watchtower config. Don't need them anyway right now.
          extraOptions = [ "--network=docsy-bridge" ];
        };
        docsy_web_redis = {
          autoStart = true;
          image = "redis:alpine";
          ports = [ "6379:6379" ];
          volumes = [ "${docsyWebDataDir}/redis:/data" ];
          extraOptions = [ "--network=docsy-bridge" ];
        };
        docsy_web_worker = {
          autoStart = true;
          image = "ghcr.io/getdocsy/docsy:${docsyWebVersion}";
          volumes = [ "${docsyWebDataDir}/src/data:/app/src/data" ];
          entrypoint = "sh";
          cmd = [
            "-c"
            "uv sync --frozen && uv run python src/manage.py rqworker default"
          ];
          login = {
            registry = "ghcr.io";
            username = "felixzieger";
            passwordFile = config.age.secrets.ghcr-secret.path;
          };
          environmentFiles = [ config.age.secrets.app-getdocsy-com-env.path ];
          environment = {
            RQ_REDIS_HOST = "docsy_web_redis";
            TZ = "Europe/Berlin";
          };
          labels = {
            "com.centurylinklabs.watchtower.enable" = "false";
          }; # Private registry pulls fail for my watchtower config. Don't need them anyway right now.
          extraOptions = [ "--network=docsy-bridge" ];
        };
      };
    };

    age.secrets = {
      app-getdocsy-com-restic-environment.file = ../secrets/app-getdocsy-com-restic-environment.age;
      app-getdocsy-com-restic-password.file = ../secrets/app-getdocsy-com-restic-password.age;
    };

    services.restic.backups = {
      docsy = {
        initialize = true;

        paths = [
          docsyDataDir
          docsyWebDataDir
        ];

        repository = "b2:app-getdocsy-com";
        environmentFile = config.age.secrets.app-getdocsy-com-restic-environment.path;
        passwordFile = config.age.secrets.app-getdocsy-com-restic-password.path;

        timerConfig = {
          OnCalendar = "19:00";
          RandomizedDelaySec = "5min";
        };

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
        ];
      };
    };

    systemd.services.init-docsy-network = {
      description = "Create the network docsy-bridge for docsy.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";
      script =
        let
          dockercli = "${config.virtualisation.docker.package}/bin/docker";
        in
        ''
          check=$(${dockercli} network ls | grep "docsy-bridge" || true)
          if [ -z "$check" ]; then
            ${dockercli} network create docsy-bridge
          else
            echo "docsy-bridge already exists in docker"
          fi
        '';
    };
  };
}
