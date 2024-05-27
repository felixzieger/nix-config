{ pkgs, config, ... }:
let
  docsyPort = 8080;
in
{
  config = {
    services.nginx.virtualHosts."docsy.felixzieger.de" = {
      forceSSL = true;
      enableACME = true;
      http3 = true;
      quic = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString docsyPort}";
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
        docsy =
          {
            autoStart = true;
            image = "ghcr.io/felixzieger/docsy:latest";
            environment.TZ = "Europe/Berlin";
            ports = [ "${builtins.toString docsyPort}:${builtins.toString docsyPort}" ];
            login = {
              registry = "ghcr.io";
              username = "felixzieger";
              passwordFile = config.age.secrets.ghcr-secret.path;
            };
            environmentFiles = [config.age.secrets.docsy-env.path];
          };
      };
    };
  };
}
