{ pkgs, config, ... }:
let
  minioApiPort = 9000;

  minioConsoleHost = "s3.felixzieger.de";
  minioConsolePort = 9001;
in
{
  config = {
    networking = {
      firewall = {
        allowedTCPPorts = [ minioApiPort minioConsolePort ];
      };
    };

    services.nginx.virtualHosts."${minioConsoleHost}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString minioConsolePort}";
        proxyWebsockets = true;
      };
    };

    age.secrets = {
      minio-root-credentials.file = ../secrets/minio-root-credentials.age;
    };

    services = {
      minio = {
        enable = true;
        browser = true;

        listenAddress = ":${toString minioApiPort}";
        consoleAddress = ":${toString minioConsolePort}";

        dataDir = [ "/data/s3" ];
        region = "eu-central-1";
        rootCredentialsFile = config.age.secrets.minio-root-credentials.path;
      };
    };
  };
}
