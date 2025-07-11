{
  pkgs,
  nixpkgs-unstable,
  config,
  lib,
  ...
}:
let
  frigateHost = "frigate.sonnenhof-zieger.de";
  unstable = import nixpkgs-unstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in
{
  config = {

    # Frigate service module configures nginx virtualHost
    # I only need to enforce SSL and Auth (via oauth2_proxy)
    services.nginx.virtualHosts."${frigateHost}" = {
      forceSSL = true;
      enableACME = true;
      http3 = true;
      quic = true;
    };

    # The directory is not configurable so we create a bind mount instead
    # I tried using a symlink but systemd failed with "Too many levels of symbolic links"
    fileSystems."/var/lib/frigate" = {
      device = "/data/frigate";
      fsType = "none";
      options = [ "bind" ];
    };

    services.frigate = {
      enable = true;
      hostname = frigateHost;
      settings = {
        detectors = {
          coral = {
            type = "edgetpu";
            device = "pci";
          };
        };

        mqtt.enabled = false;

        ffmpeg.hwaccel_args = "preset-vaapi";

        record = {
          enabled = true;
          retain.days = 2;
          events.retain.default = 5;
        };

        # The object detection for the 1 stream is already using 50% CPU most of the time
        # Frigate supports Coral AI; before adding more streams, I will get a Coral AI extension card
        # https://buyzero.de/products/google-coral-m-2-accelerator-a-e-key
        objects = {
          track = [
            "person"
            "car"
          ];
        };

        snapshots.enabled = true;

        cameras."kartoffelbox" = {
          # It's ugly to have the camera credential checked into git.
          # The service implementation stores the frigate.yml in nix store and I couldn't figure out how to
          # get the path of that file to do the Agenix "Replace inplace strings with secrets" trick.
          # While this would be an improvement, the nix store wouldn't be ideal since it's world readable.
          # Since the camera is only reachable from within the private network and RTSP is not encrypted anyway I decided to leave it like that.
          ffmpeg.inputs = [
            {
              path =
                # ch1 is lower resolution
                "rtsp://BJA3Y0v5:gZbBIUBXeyj4w70q@192.168.178.131:1337/live/ch1";
              input_args = "preset-rtsp-restream";
              roles = [
                "detect"
                "record"
              ];
            }

            # {
            #   path =
            #     # ch0 is FHD; it's broken, so we use ch1 above
            #     "rtsp://BJA3Y0v5:gZbBIUBXeyj4w70q@192.168.178.131:1337/live/ch0";
            #   input_args = "preset-rtsp-restream";
            #   roles = [ "record" ];
            # }
          ];
        };

        telemetry = {
          version_check = false;
        };
      };
    };

    systemd.services = {
      set-apex-permissions = {
        description = "Set permissions for /dev/apex_0";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "set-apex-permissions" ''
            chown frigate:frigate /dev/apex_0
            chmod 660 /dev/apex_0
          '';

        };
        wantedBy = [ "multi-user.target" ];
      };
      frigate = {
        wants = [ "set-apex-permissions.service" ];
        environment.LIBVA_DRIVER_NAME = "radeonsi";
      };
    };

    # Hardware accelleration for video decoding via VAAPI (on AMD GPU)
    # gives frigate access to /dev/dri/redner128
    users.users.frigate.extraGroups = [ "render" ];
  };
}
