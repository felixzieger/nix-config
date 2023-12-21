{ pkgs, lib, ... }:
{
  config = {
    networking = {
      firewall = {
        allowedTCPPorts = [ 8123 ];
      };
    };

    virtualisation.docker.enable = true;
    users.extraGroups.docker.members = [ "felix" ];
    virtualisation.oci-containers = {
      backend = "docker";
      autoStart = true;
      ports = [ "127.0.0.1:8123:8123" ]; # unsure how networking works with --network=host option
      containers.homeassistant = {
        volumes = [ "home-assistant:/config" ];
        environment.TZ = "Europe/Berlin";
        image = "ghcr.io/home-assistant/home-assistant:2023.12.3";
        extraOptions = [
          "--network=host"
        ];
      };
    };
  };
}
