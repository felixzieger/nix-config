{ pkgs, config, lib, ... }:
let
  frigateHost = "frigate.sonnenhof-zieger.de";
in
{
  config = {
    age.secrets = {
      frigate-basic-auth = {
        file = ../secrets/frigate-basic-auth.age;
        owner = "nginx";
      };
    };

    # Frigate service module configures nginx virtualHost
    # I only need to enforce SSL and Auth
    services.nginx.virtualHosts."${frigateHost}" = {
      basicAuthFile = config.age.secrets.frigate-basic-auth.path;
      forceSSL = true;
      enableACME = true;
    };


    services.frigate = {
      enable = true;
      hostname = frigateHost;
      settings = {
        mqtt.enabled = false;

        record = {
          enabled = true;
        };

        objects = {
          track = [
            "person"
            "car"
          ];
        };

        snapshots.enabled = true;

        cameras."kartoffelbox" = {
          ffmpeg.inputs = [{
            # It's ugly to have the camera credential checked into git.
            # The service implementation stores the frigate.yml in nix store and I couldn't figure out how to 
            # get the path of that file to do the Agenix "Replace inplace strings with secrets" trick.
            # While this would be an improvement, the nix store wouldn't be ideal since it's world readable.
            # Since the camera is only reachable from within the private network and RTSP is not encrypted anyway I decided to leave it like that.
            path = "rtsp://BJA3Y0v5:gZbBIUBXeyj4w70q@192.168.178.131:1337/live/ch1";
            # ch0 is FHD. It stopeed working after 12 hours of streaming. Thus switched to lower resolution ch1
            # path = "rtsp://BJA3Y0v5:gZbBIUBXeyj4w70q@192.168.178.131:1337/live/ch0";
            input_args = "preset-rtsp-restream";
            roles = [ "record" ];
          }];
        };

        telemetry = {
          version_check = false;
        };
      };
    };
  };
}
