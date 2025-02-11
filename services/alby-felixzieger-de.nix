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

  virtualisation.docker.enable = true;
  # I followed https://github.com/getAlby/hub/blob/master/docker-compose.yml
  virtualisation.oci-containers = {
    backend = "docker";
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
        };
        environmentFiles = [ config.age.secrets.alby-felixzieger-de-env.path ];
      };
    };
  };
}
