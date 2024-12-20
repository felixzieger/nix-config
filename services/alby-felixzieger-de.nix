{
  config,
  ...
}:
let
  albyHubPort = 8080;
  albyHubDataDir = "/data/alby-hub/data"; 
in {
  services.nginx.virtualHosts."alby.felixzieger.de" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString albyHubPort}";
      proxyWebsockets = true;
    };
  };

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
        };
    };
  };
}
