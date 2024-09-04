{ pkgs, config, lib, ... }:
let
  plausibleHost = "plausible.felixzieger.de";
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
      plausible-admin-password.file =
        ../../secrets/plausible-admin-password.age;
      plausible-conf-env.file = ../../secrets/plausible-conf-env.age;
    };

    virtualisation.docker.enable = true;
    # virtualisation.docker.extraOptions = ''
    #   ulimits:
    #     nofile:
    #       soft: 262144
    #       hard: 262144'';
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        plausible_db = {
          autoStart = true;
          image = "postgres:16-alpine";
          environment = { POSTGRES_PASSWORD = "postgres"; };
          volumes = [ "/data/plausible/db-data:/var/lib/postgresql/data" ];
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
        };

        plausible = {
          autoStart = true;
          image = "ghcr.io/plausible/community-edition:v2.1.1";
          cmd = [
            ''
              sh -c "sleep 10 && /entrypoint.sh db createdb && /entrypoint.sh db migrate && /entrypoint.sh run"''
          ];
          dependsOn = [ "plausible_db" "plausible_events_db" ];
          ports = [ "127.0.0.1:${toString plausiblePort}:8000" ];
          environment = {
            BASE_URL = plausibleHost;
            MAILER_EMAIL = "bot@sonnenhof-zieger.de";
            SMTP_HOST_ADDR = "smtp.strato.de";
            SMTP_HOST_PORT = toString 465;
            SMTP_USER_NAME = "bot@sonnenhof-zieger.de";
            SMTP_HOST_SSL_ENABLED = toString true;
            # DISABLE_REGISTRATION = "invite_only";
          };
          environmentFiles = [ config.age.secrets.plausible-conf-env.path ];
        };
      };

    };

    environment.etc."clickhouse/clickhouse-config.xml".source =
      ./clickhouse-config.xml;

    environment.etc."clickhouse/clickhouse-user-config.xml".source =
      ./clickhouse-user-config.xml;
  };
}
