{ pkgs, config, ... }:
let
  homeAssistantPort = 8123;
  homeAssistantConfigDir = "/data/HomeAssistant";
  whisperPort = 10300;
  piperPort = 10200;
in {
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

    services.nginx.virtualHosts."home.${config.networking.hostName}.felixzieger.de" =
      {
        forceSSL = true;
        enableACME = true;
        http3 = true;
        quic = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString homeAssistantPort}";
          proxyWebsockets = true;
        };
      };

    networking = {
      firewall = {
        allowedTCPPorts = [ 1400 ]; # Sonos integration uses TCP port 1400 for push based updates
        allowedUDPPorts = [ 5353 ]; # Home assistant uses UDP port 5353 for mDNS based auto-discovery
      };
    };

    virtualisation.docker.enable = true;
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        homeassistant = {
          autoStart = true;
          image = "ghcr.io/home-assistant/home-assistant:latest";
          volumes = [
            "${homeAssistantConfigDir}:/config"
            "/etc/localtime:/etc/localtime:ro"
          ];
          environment.TZ = "Europe/Berlin";
          extraOptions = [ "--network=host" "--privileged" ];
        };
        whisper = {
          autoStart = true;
          image = "rhasspy/wyoming-whisper:latest";
          ports = [
            "${builtins.toString whisperPort}:${builtins.toString whisperPort}"
          ];
          volumes = [ "/data/whisper/data:/data" ];
          cmd = [ "--model=tiny-int8" ];
        };
        piper = {
          autoStart = true;
          image = "rhasspy/wyoming-piper:latest";
          ports =
            [ "${builtins.toString piperPort}:${builtins.toString piperPort}" ];
          volumes = [ "/data/piper/data:/data" ];
          cmd = [ "--voice=en_US-lessac-medium" ];
        };
      };
    };

    age.secrets = {
      home-assistant-restic-environment.file =
        ../secrets/home-assistant-restic-environment.age;
      home-assistant-restic-password.file =
        ../secrets/home-assistant-restic-password.age;
    };

    services.restic.backups = {
      home-assistant = {
        initialize = true;

        paths = [ homeAssistantConfigDir ];

        repository = "b2:${config.networking.hostName}-home-assistant";
        environmentFile =
          config.age.secrets.home-assistant-restic-environment.path;
        passwordFile = config.age.secrets.home-assistant-restic-password.path;

        timerConfig = {
          OnCalendar = "10:00";
          RandomizedDelaySec = "5min";
        };

        pruneOpts = [ "--keep-daily 7" "--keep-weekly 5" "--keep-monthly 12" ];
      };
    };
  };
}
