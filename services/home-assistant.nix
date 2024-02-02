{ pkgs, config, ... }:
let
  homeAssistantPort = 8123;
  whisperPort = 10300;
  piperPort = 10200;
in
{
  config = {
    networking = {
      firewall = {
        allowedTCPPorts = [ homeAssistantPort whisperPort piperPort ];
      };
    };

    # This requires setting use_x_forwarded_for and trusted_proxies in configuration.yaml
    # Check docker container logs for the address of the proxy. Was ::1 for me.
    services.nginx.virtualHosts."home.${config.networking.hostName}.local" = {
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
            image = "ghcr.io/home-assistant/home-assistant:2024.1";
            volumes = [
              "/home/felix/HomeAssistant:/config"
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
            volumes = [ "/home/felix/whisper/data:/data" ];
            cmd = [ "--model=tiny-int8" ];
          };
        piper = {
          autoStart = true;
          image = "rhasspy/wyoming-piper:1.4.0";
          ports = [ "${builtins.toString piperPort}:${builtins.toString piperPort}" ];
          volumes = [
            "/home/felix/piper/data:/data"
          ];
          cmd = [ "--voice=en_US-lessac-medium" ];
        };
      };
    };
  };
}
