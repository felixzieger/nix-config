{
  config,
  ...
}:
let
  albyHubPort = 8080;
  albyHubDataDir = "/data/alby-hub";
in
{
  services.nginx.virtualHosts."alby.felixzieger.de" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString albyHubPort}";
      proxyWebsockets = true;
    };
  };

  age.secrets = {
    alby-felixzieger-de-env.file = ../secrets/alby-felixzieger-de-env.age;
  };

  # I followed https://github.com/getAlby/hub/blob/master/docker-compose.yml
  virtualisation.oci-containers = {
    containers = {
      alby-hub = {
        autoStart = true;
        image = "ghcr.io/getalby/hub:latest";
        volumes = [
          "${albyHubDataDir}:/data"
        ];
        ports = [ "${builtins.toString albyHubPort}:8080" ];
        environment = {
          WORK_DIR = "/data/albyhub";
          PORT = toString albyHubPort;
          LOG_LEVEL = toString 3;
        };
        environmentFiles = [ config.age.secrets.alby-felixzieger-de-env.path ];
      };
    };
  };

  age.secrets = {
    alby-felixzieger-de-restic-environment.file = ../secrets/alby-felixzieger-de-restic-environment.age;
    alby-felixzieger-de-restic-password.file = ../secrets/alby-felixzieger-de-restic-password.age;
  };

  services.restic.backups = {
    alby = {
      initialize = true;

      paths = [ albyHubDataDir ];

      repository = "b2:alby-felixzieger-de";
      environmentFile = config.age.secrets.alby-felixzieger-de-restic-environment.path;
      passwordFile = config.age.secrets.alby-felixzieger-de-restic-password.path;

      timerConfig = {
        OnCalendar = "23:00";
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
