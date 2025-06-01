{
  config,
  ...
}:
let
  twentyHostName = "twenty.getdocsy.com";
  twentyServerUrl = "https://${twentyHostName}";

  twentyDataDir = "/data/${twentyHostName}";
  twentyDbDataDir = "${twentyDataDir}/db-data";
  twentyServerLocalDataDir = "${twentyDataDir}/server-local-data";

  pgUser = "twenty";
  pgDatabaseName = "twenty";

  networkName = "twenty-bridge";

in
{
  config = {

    services.nginx.virtualHosts."${twentyHostName}" = {
      forceSSL = true;
      enableACME = true;
      http3 = true;
      quic = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${config.virtualisation.oci-containers.containers.twenty_server.environment.NODE_PORT}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };

    age.secrets = {
      twenty-getdocsy-com-docker-environment.file = ../secrets/twenty-getdocsy-com-docker-environment.age;
      twenty-getdocsy-com-restic-environment.file = ../secrets/twenty-getdocsy-com-restic-environment.age;
      twenty-getdocsy-com-restic-password.file = ../secrets/twenty-getdocsy-com-restic-password.age;
    };

    systemd.services.init-twenty-network = {
      description = "Create the network ${networkName} for Twenty.";
      after = [
        "network.target"
        "docker.service"
      ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script =
        let
          dockercli = "${config.virtualisation.docker.package}/bin/docker";
        in
        ''
          if ! ${dockercli} network inspect ${networkName} >/dev/null 2>&1; then
            ${dockercli} network create ${networkName}
            echo "Network ${networkName} created."
          else
            echo "Network ${networkName} already exists."
          fi
        '';
    };

    virtualisation.oci-containers = {
      containers = {
        twenty_db = {
          autoStart = true;
          image = "postgres:16-alpine";
          volumes = [ "${twentyDbDataDir}:/var/lib/postgresql/data" ];
          environmentFiles = [ config.age.secrets.twenty-getdocsy-com-docker-environment.path ];
          extraOptions = [ "--network=${networkName}" ];
        };

        twenty_redis = {
          autoStart = true;
          image = "redis:alpine";
          extraOptions = [ "--network=${networkName}" ];
          cmd = [
            "--maxmemory-policy"
            "noeviction"
          ];
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };

        twenty_server = {
          autoStart = true;
          image = "twentycrm/twenty:latest";
          ports = [
            "127.0.0.1:${config.virtualisation.oci-containers.containers.twenty_server.environment.NODE_PORT}:3000"
          ];
          volumes = [
            "${twentyServerLocalDataDir}:/app/packages/twenty-server/.local-storage"
          ];
          environment = {
            NODE_PORT = "3000";
            SERVER_URL = twentyServerUrl;
            REDIS_URL = "redis://twenty_redis:6379";
            STORAGE_TYPE = "local";
          };
          environmentFiles = [ config.age.secrets.twenty-getdocsy-com-docker-environment.path ];
          extraOptions = [ "--network=${networkName}" ];
          dependsOn = [
            "twenty_db"
            "twenty_redis"
          ];
        };

        twenty_worker = {
          autoStart = true;
          image = "twentycrm/twenty:latest";
          volumes = [
            "${twentyServerLocalDataDir}:/app/packages/twenty-server/.local-storage"
          ];
          cmd = [
            "yarn"
            "worker:prod"
          ];
          environment = {
            SERVER_URL = twentyServerUrl;
            REDIS_URL = "redis://twenty_redis:6379";
            STORAGE_TYPE = "local";
            DISABLE_DB_MIGRATIONS = "true";
          };
          environmentFiles = [ config.age.secrets.twenty-getdocsy-com-docker-environment.path ];
          extraOptions = [ "--network=${networkName}" ];
          dependsOn = [
            "twenty_db"
            "twenty_redis"
            "twenty_server"
          ];
        };
      };
    };

    # Restic backup configuration
    services.restic.backups.twenty = {
      initialize = true;
      paths = [ twentyDataDir ];
      repository = "b2:twenty-getdocsy-com";
      environmentFile = config.age.secrets.twenty-getdocsy-com-restic-environment.path;
      passwordFile = config.age.secrets.twenty-getdocsy-com-restic-password.path;
      timerConfig = {
        OnCalendar = "03:30";
        RandomizedDelaySec = "5min";
      };
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
      ];
    };
  };
}
