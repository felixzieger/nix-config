{ pkgs, config, ... }:
let docsyPort = 8080;
in {
  config = {
    # Inspect sqlite database without docker exec
    environment.systemPackages = with pkgs; [ sqlite ];

    services.nginx.virtualHosts."app.getdocsy.com" = {
      forceSSL = true;
      enableACME = true;
      http3 = true;
      quic = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString docsyPort}";
        proxyWebsockets = true;
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
        docsy = {
          autoStart = true;
          image = "ghcr.io/felixzieger/docsy:v0.6.0";
          environment.TZ = "Europe/Berlin";
          ports = [ "${builtins.toString docsyPort}:3000" ];
          volumes = [ "/data/docsy/data:/app/data" ];
          login = {
            registry = "ghcr.io";
            username = "felixzieger";
            passwordFile = config.age.secrets.ghcr-secret.path;
          };
          environmentFiles = [ config.age.secrets.docsy-env.path ];
        };
      };
    };
  };
}
