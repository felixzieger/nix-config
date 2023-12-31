{ pkgs, lib, ... }:
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

    # Compare https://kressle.in/articles/2023/home-assistant-on-docker-with-nixos
    virtualisation.docker.enable = true;
    users.extraGroups.docker.members = [ "felix" ];
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        homeassistant =
          {
            autoStart = true;
            image = "ghcr.io/home-assistant/home-assistant:2023.12.3";
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
            image = "rhasspy/wyoming-whisper";
            ports = [ "${builtins.toString whisperPort}:${builtins.toString whisperPort}" ];
            volumes = [ "/home/felix/whisper/data:/data" ];
            cmd = [ "--model=tiny-int8" ];
          };
        piper = {
          autoStart = true;
          image = "rhasspy/wyoming-piper";
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
