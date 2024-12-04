{ pkgs, nixpkgs-unstable, config, lib, ... }:
let
  frigateHost = "frigate.sonnenhof-zieger.de";
  unstable = import nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in {
  config = {

    age.secrets = { oauth2_proxy_key.file = ../secrets/oauth2_proxy_key.age; };

    services.oauth2-proxy = {
      enable = true;
      provider = "google";
      keyFile =
        config.age.secrets.oauth2_proxy_key.path; # sets OAUTH2_PROXY_CLIENT_ID, OAUTH2_PROXY_CLIENT_SECRET, OAUTH2_PROXY_COOKIE_SECRET

      nginx.domain = frigateHost;
      nginx.virtualHosts."${frigateHost}".allowed_email_domains =
        [ "gmail.com" ];

      cookie = {
        refresh = "360h0m0s";
        expire = "720h0m0s";
      };

      redirectURL = "https://${frigateHost}/oauth2/callback";

      email.domains = [
        "gmail.com"
      ]; # I restrict login to the app via Google, no need to filter here
      # google = { ... } only works with Google Workspace, which I don't use
    };

    # Frigate service module configures nginx virtualHost
    # I only need to enforce SSL and Auth (via oauth2_proxy)
    services.nginx.virtualHosts."${frigateHost}" = {
      forceSSL = true;
      enableACME = true;
      http3 = true;
      quic = true;
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
        objects = { track = [ "person" "car" ]; };

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
              roles = [ "detect" ];
            }

            {
              path =
                # ch0 is FHD            
                "rtsp://BJA3Y0v5:gZbBIUBXeyj4w70q@192.168.178.131:1337/live/ch0";
              input_args = "preset-rtsp-restream";
              roles = [ "record" ];
            }
          ];
        };

        telemetry = { version_check = false; };
      };
    };

    systemd.services.set-apex-permissions = {
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
    systemd.services.frigate = { wants = [ "set-apex-permissions.service" ]; };

    # Hardware accelleration for video decoding via VAAPI (on AMD GPU)
    # gives frigate access to /dev/dri/redner128
    users.users.frigate.extraGroups = [ "render" ];
    systemd.services.frigate.environment.LIBVA_DRIVER_NAME = "radeonsi";
  };
}
