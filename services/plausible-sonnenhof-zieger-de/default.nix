{ pkgs, config, lib, ... }:
let
  plausibleHost = "plausible.sonnenhof-zieger.de";
  plausiblePort = 8000;
in {
  config = {

    services.nginx.virtualHosts."${plausibleHost}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString plausiblePort}";
      };
    };

    age.secrets = {
      email-password-bot-sonnenhof-zieger.file =
        ../../secrets/email-password-bot-sonnenhof-zieger.age;
      plausible-sonnenhof-zieger-de-conf-env.file =
        ../../secrets/plausible-sonnenhof-zieger-de-conf-env.age;
      plausible-sonnenhof-zieger-de-restic-environment.file =
        ../../secrets/plausible-sonnenhof-zieger-de-restic-environment.age;
      plausible-sonnenhof-zieger-de-restic-password.file =
        ../../secrets/plausible-sonnenhof-zieger-de-restic-password.age;
    };

    virtualisation.docker.enable = true;
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        plausible_db = {
          autoStart = true;
          image = "postgres:16-alpine";
          environment = { POSTGRES_PASSWORD = "postgres"; };
          volumes = [ "/data/plausible/db-data:/var/lib/postgresql/data" ];
          extraOptions = [ "--network=plausible-bridge" ];
        };

        plausible_events_db = {
          autoStart = true;
          image = "clickhouse/clickhouse-server:24.3.3.102-alpine";
          volumes = [
            "/data/plausible/event-data:/var/lib/clickhouse"
            "/data/plausible/event-logs:/var/log/clickhouse-server"
            "/etc/clickhouse/clickhouse-config.xml:/etc/clickhouse-server/config.d/logging.xml:ro"
            "/etc/clickhouse/clickhouse-user-config.xml:/etc/clickhouse-server/users.d/logging.xml:ro"
          ];
          extraOptions =
            [ "--ulimit" "nofile=262144:262144" "--network=plausible-bridge" ];
        };

        plausible = {
          autoStart = true;
          image = "ghcr.io/plausible/community-edition:v2.1.1";
          entrypoint = "sh";
          cmd = [
            "-c"
            "sleep 10 && /entrypoint.sh db createdb && /entrypoint.sh db migrate && /entrypoint.sh run"
          ];
          dependsOn = [ "plausible_db" "plausible_events_db" ];
          ports = [ "127.0.0.1:${toString plausiblePort}:8000" ];
          environment = {
            BASE_URL = "https://${plausibleHost}";
            MAILER_EMAIL = "bot@sonnenhof-zieger.de";
            SMTP_HOST_ADDR = "smtp.strato.de";
            SMTP_HOST_PORT = toString 465;
            SMTP_USER_NAME = "bot@sonnenhof-zieger.de";
            SMTP_HOST_SSL_ENABLED = toString true;
          };
          environmentFiles =
            [ config.age.secrets.plausible-sonnenhof-zieger-de-conf-env.path ];
          extraOptions = [ "--network=plausible-bridge" ];
        };
      };

    };

    systemd.services.init-plausible-network = {
      description = "Create the network plausible-bridge for Plausible.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";
      script =
        let dockercli = "${config.virtualisation.docker.package}/bin/docker";
        in ''
          check=$(${dockercli} network ls | grep "plausible-bridge" || true)
          if [ -z "$check" ]; then
            ${dockercli} network create plausible-bridge
          else
            echo "plausible-bridge already exists in docker"
          fi
        '';
    };

    environment.etc."clickhouse/clickhouse-config.xml".source =
      ./clickhouse-config.xml;

    environment.etc."clickhouse/clickhouse-user-config.xml".source =
      ./clickhouse-user-config.xml;

    services.restic.backups.plausible = {
      initialize = true;

      paths = [ "/data/plausible" ];

      repository = "b2:plausible-sonnenhof-zieger-de";
      environmentFile =
        config.age.secrets.plausible-sonnenhof-zieger-de-restic-environment.path;
      passwordFile =
        config.age.secrets.plausible-sonnenhof-zieger-de-restic-password.path;

      timerConfig = {
        OnCalendar = "19:00";
        RandomizedDelaySec = "5min";
      };

      pruneOpts = [ "--keep-daily 7" "--keep-weekly 5" "--keep-monthly 12" ];
    };
  };
}
