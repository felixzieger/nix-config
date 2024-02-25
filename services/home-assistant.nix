{ pkgs, config, ... }:
let
  homeAssistantPort = 8123;
  whisperPort = 10300;
  piperPort = 10200;
in
{
  config = {
    # This requires setting use_x_forwarded_for and trusted_proxies in configuration.yaml
    # Check docker container logs for the address of the proxy. Was ::1 for me.
    services.nginx.virtualHosts."home.${config.networking.hostName}.local" = {
      rejectSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString homeAssistantPort}";
        proxyWebsockets = true;
      };
    };

    services.nginx.virtualHosts."home.${config.networking.hostName}.felixzieger.de" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        allow 192.168.0.0/16;
        allow 172.16.0.0/12;
        allow 10.0.0.0/8;
        deny all;
        '';
      locations."/" = {
        proxyPass = "http://localhost:${toString homeAssistantPort}";
        proxyWebsockets = true;
      };
    };

    virtualisation.docker.enable = true;
    virtualisation.docker.autoPrune.enable = true;
    virtualisation.docker.autoPrune.flags = [ "--all" ];
    users.extraGroups.docker.members = [ "felix" ];
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        homeassistant =
          {
            autoStart = true;
            image = "ghcr.io/home-assistant/home-assistant:2024.2";
            volumes = [
              "/data/HomeAssistant:/config"
              "/etc/localtime:/etc/localtime:ro"
            ];
            environment.TZ = "Europe/Berlin";
            extraOptions = [
              "--network=host"
              "--privileged"
              # "--device=/dev/ttyUSB0" # USB devices
            ];
          };
        whisper =
          {
            autoStart = true;
            image = "rhasspy/wyoming-whisper:1.0.0";
            ports = [ "${builtins.toString whisperPort}:${builtins.toString whisperPort}" ];
            volumes = [ "/data/whisper/data:/data" ];
            cmd = [ "--model=tiny-int8" ];
          };
        piper = {
          autoStart = true;
          image = "rhasspy/wyoming-piper:1.4.0";
          ports = [ "${builtins.toString piperPort}:${builtins.toString piperPort}" ];
          volumes = [
            "/data/piper/data:/data"
          ];
          cmd = [ "--voice=en_US-lessac-medium" ];
        };
      };
    };
  };
}
