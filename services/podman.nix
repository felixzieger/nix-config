{ config, ... }:
{
  # Auto update containers on podman; check https://www.howtogeek.com/devops/how-to-enable-podmans-automatic-container-updates/
  # Also see https://nixcademy.com/posts/auto-update-containers/
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  virtualisation.oci-containers = {
    backend = "podman";
  };

  users.users.felix = {
    isNormalUser = true;
    extraGroups = [ "podman" ];
  };
}
