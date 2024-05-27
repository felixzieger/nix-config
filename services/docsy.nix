{ pkgs, config, ... }:
let
  docsyPort = 8080;
in
{
  config = {
    # This requires setting use_x_forwarded_for and trusted_proxies in configuration.yaml
    # Check docker container logs for the address of the proxy. Was ::1 for me.
    services.nginx.virtualHosts."docsy.${config.networking.hostName}.local" = {
      rejectSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString docsyPort}";
        proxyWebsockets = true;
      };
    };

#     services.nginx.virtualHosts."docsy.${config.networking.hostName}.felixzieger.de" = {
#       forceSSL = true;
#       enableACME = true;
#       http3 = true;
#       quic = true;
#       locations."/" = {
#         proxyPass = "http://localhost:${toString docsyPort}";
#         proxyWebsockets = true;
#       };
#     };

    age.secrets = {
      ghcr-secret.file = ../secrets/home-assistant-restic-environment.age;
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
          };
      };
    };
  };
}
