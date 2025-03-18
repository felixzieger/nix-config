{ pkgs, config, ... }:
let
  omnivoreDataDir = "/data/omnivore";
  postgresDataDir = "${omnivoreDataDir}/postgres";
  redisDataDir = "${omnivoreDataDir}/redis";
in
{
  config = {
    services.nginx.virtualHosts."omnivore.felixzieger.de" = {
      forceSSL = true;
      enableACME = true;
      http3 = true;
      quic = true;
      locations = {
        "/api/client/auth" = {
          proxyPass = "http://localhost:3000";
          proxyWebsockets = true;
        };
        "/api/save" = {
          proxyPass = "http://localhost:3000";
          proxyWebsockets = true;
        };
        "/api" = {
          proxyPass = "http://localhost:4000";
          proxyWebsockets = true;
        };
        "/bucket" = {
          proxyPass = "http://localhost:1010";
          proxyWebsockets = true;
        };
        "/images" = {
          proxyPass = "http://localhost:7070";
          proxyWebsockets = true;
          extraConfig = ''
            rewrite ^/images/(.*)$ /$1 break;
          '';
        };
        "/" = {
          proxyPass = "http://localhost:3000";
          proxyWebsockets = true;
        };
        "/mail" = {
          proxyPass = "http://localhost:4398/mail";
          proxyWebsockets = true;
        };
      };
    };

    age.secrets = {
      omnivore-felixzieger-de-google-service-account.file = ../secrets/omnivore-felixzieger-de-google-service-account.age;
      omnivore-felixzieger-de-environment.file = ../secrets/omnivore-felixzieger-de-environment.age;
    };

    virtualisation.oci-containers = {
      containers = {
        omnivore-web = {
          autoStart = true;
          image = "ghcr.io/omnivore-app/sh-web:latest";
          ports = [ "3000:8080" ];
          environment.GCS_UPLOAD_SA_KEY_FILE_PATH =
            config.age.secrets.omnivore-felixzieger-de-google-service-account.path;
          environmentFiles = [
            config.age.secrets.omnivore-felixzieger-de-environment.path
          ];
          dependsOn = [
            "omnivore-postgres"
            "omnivore-redis"
            "omnivore-api"
            # "omnivore-migrate"
          ];
          extraOptions = [ "--network=omnivore-bridge" ];
        };

        omnivore-minio = {
          autoStart = true;
          image = "minio/minio:latest";
          ports = [ "1010:9000" ];
          environment = {
            MINIO_ACCESS_KEY = "minio";
            MINIO_SECRET_KEY = "miniominio";
            AWS_S3_ENDPOINT_URL = "http://omnivore-minio:1010";
          };
          volumes = [ "${omnivoreDataDir}/minio:/data" ];
          cmd = [
            "server"
            "/data"
          ];
          extraOptions = [ "--network=omnivore-bridge" ];
        };

        # omnivore-minio-bucket = {
        #   autoStart = false;
        #   image = "minio/mc:latest";
        #   environment = {
        #     MINIO_ACCESS_KEY = "minio";
        #     MINIO_SECRET_KEY = "miniominio";
        #     BUCKET_NAME = "omnivore";
        #     ENDPOINT = "http://omnivore-minio:9000";
        #     AWS_S3_ENDPOINT_URL = "http://omnivore-minio:9000";
        #   };
        #   dependsOn = [ "omnivore-minio" ];
        #   entrypoint = "sh";
        #   cmd = [
        #     "-c"
        #     ''
        #       sleep 5;
        #       until (/usr/bin/mc config host add myminio http://omnivore-minio:9000 minio miniominio) do echo '...waiting...' && sleep 1; done;
        #       /usr/bin/mc mb myminio/omnivore;
        #       /usr/bin/mc anonymous set public myminio/omnivore;
        #       exit 0;
        #     ''
        #   ];
        #   extraOptions = [ "--network=omnivore-bridge" ];
        # };

        omnivore-postgres = {
          autoStart = true;
          image = "pgvector/pgvector:pg17";
          volumes = [ "${postgresDataDir}:/var/lib/postgresql/data" ];
          environmentFiles = [
            config.age.secrets.omnivore-felixzieger-de-environment.path
          ];
          extraOptions = [ "--network=omnivore-bridge" ];
        };

        omnivore-redis = {
          autoStart = true;
          image = "redis:7.2.4";
          volumes = [ "${redisDataDir}:/data" ];
          extraOptions = [ "--network=omnivore-bridge" ];
        };

        # omnivore-migrate = {
        #   autoStart = true;
        #   image = "ghcr.io/omnivore-app/sh-migrate:latest";
        #   cmd = [
        #     "/bin/sh"
        #     "./packages/db/setup.sh"
        #   ];
        #   environment = {
        #     PG_HOST = "omnivore-postgres";
        #   };
        #   environmentFiles = [
        #     config.age.secrets.omnivore-felixzieger-de-environment.path
        #   ];
        #   dependsOn = [
        #     "omnivore-postgres"
        #   ];
        #   extraOptions = [ "--network=omnivore-bridge" ];
        # };

        omnivore-api = {
          autoStart = true;
          image = "ghcr.io/omnivore-app/sh-backend:latest";
          ports = [ "4000:8080" ];
          environment = {
            API_ENV = "local";
            PG_HOST = "omnivore-postgres";

            GCS_USE_LOCAL_HOST = "false";
            GCP_PROJECT_ID = "omnivore-felixzieger-de";
            GCS_UPLOAD_BUCKET = "omnivore-felixzieger-de";
            GCS_UPLOAD_SA_KEY_FILE_PATH =
              config.age.secrets.omnivore-felixzieger-de-google-service-account.path;
          };
          environmentFiles = [
            config.age.secrets.omnivore-felixzieger-de-environment.path
          ];
          dependsOn = [
            # "omnivore-migrate" # since migration is restarting all the time, ignore it
            "omnivore-redis"
          ];
          extraOptions = [ "--network=omnivore-bridge" ];
        };

        omnivore-queue-processor = {
          autoStart = true;
          image = "ghcr.io/omnivore-app/sh-queue-processor:latest";
          environmentFiles = [
            config.age.secrets.omnivore-felixzieger-de-environment.path
          ];
          dependsOn = [
            "omnivore-api"
          ];
          extraOptions = [ "--network=omnivore-bridge" ];
        };

        omnivore-image-proxy = {
          autoStart = true;
          image = "ghcr.io/omnivore-app/sh-image-proxy:latest";
          ports = [ "7070:8080" ];
          environmentFiles = [
            config.age.secrets.omnivore-felixzieger-de-environment.path
          ];
          extraOptions = [ "--network=omnivore-bridge" ];
        };

        omnivore-content-fetch = {
          autoStart = true;
          image = "ghcr.io/omnivore-app/sh-content-fetch:latest";
          ports = [ "9090:8080" ];
          environment = {
            USE_FIREFOX = "true";
          };
          environmentFiles = [
            config.age.secrets.omnivore-felixzieger-de-environment.path
          ];
          dependsOn = [
            "omnivore-redis"
            "omnivore-api"
          ];
          extraOptions = [ "--network=omnivore-bridge" ];
        };

        #         omnivore-mail-watch-server = {
        #           autoStart = true;
        #           image = "ghcr.io/omnivore-app/sh-local-mail-watcher:latest";
        #           ports = ["4398:8080"];
        #           environmentFiles = [
        #             config.age.secrets.omnivore-felixzieger-de-environment.path
        #           ];
        #           dependsOn = [
        #             "omnivore-redis"
        #           ];
        # extraOptions = [ "--network=omnivore-bridge" ];
        #         };
      };
    };
    systemd.services.init-omnivore-network = {
      description = "Create the network omnivore-bridge for Omnivore.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";
      script =
        let
          dockercli = "${config.virtualisation.docker.package}/bin/docker";
        in
        ''
          check=$(${dockercli} network ls | grep "omnivore-bridge" || true)
          if [ -z "$check" ]; then
            ${dockercli} network create omnivore-bridge
          else
            echo "omnivore-bridge already exists in docker"
          fi
        '';
    };
  };
}
