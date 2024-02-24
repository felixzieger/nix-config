{ config, pkgs, ... }:
# I mostly followed
# https://tailscale.com/kb/1096/nixos-minecraft
{
  age.secrets = {
    tailscale-authkey.file = ../secrets/tailscale-authkey.age;
  };

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  environment.systemPackages = [ pkgs.tailscale ];

  services.tailscale.enable = true;

  # create a oneshot job to authenticate to Tailscale
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      # (idea with cat'ing file into tailscale up taken from https://guekka.github.io/nixos-server-2/)
      ${tailscale}/bin/tailscale up --authkey=$(cat "${config.age.secrets.tailscale-authkey.path}")
    '';
  };
}

