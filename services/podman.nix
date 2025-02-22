{ config, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    autoUpdate = {
      enable = true;
      onCalendar = "*-*-* 04:00";
    };
  };
  virtualisation.oci-containers = {
    backend = "podman";
  };
}
