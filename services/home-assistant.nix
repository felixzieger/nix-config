{ pkgs, config, ... }:
let
  homeAssistantPort = 8123;
  homeAssistantConfigDir = "/data/HomeAssistant";
  whisperPort = 10300;
  piperPort = 10200;
in
{
  config = {
    # This requires setting use_x_forwarded_for and trusted_proxies in configuration.yaml
    # Check container logs for the address of the proxy. Was ::1 for me.
    services.nginx.virtualHosts."home.${config.networking.hostName}.local" = {
      rejectSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString homeAssistantPort}";
        proxyWebsockets = true;
      };
    };

    services.nginx.virtualHosts."home.${config.networking.hostName}.felixzieger.de" = {
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

    virtualisation.oci-containers = {
      containers = {
        homeassistant = {
          autoStart = true;
          image = "ghcr.io/home-assistant/home-assistant:latest";
          volumes = [
            "${homeAssistantConfigDir}:/config"
            "/etc/localtime:/etc/localtime:ro"
          ];
          environment.TZ = "Europe/Berlin";
          extraOptions = [
            "--network=host"
            "--privileged"
          ];
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
        whisper = {
          autoStart = true;
          image = "rhasspy/wyoming-whisper:latest";
          ports = [
            "${builtins.toString whisperPort}:${builtins.toString whisperPort}"
          ];
          volumes = [ "/data/whisper/data:/data" ];
          cmd = [ "--model=tiny-int8" ];
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
        piper = {
          autoStart = true;
          image = "rhasspy/wyoming-piper:latest";
          ports = [ "${builtins.toString piperPort}:${builtins.toString piperPort}" ];
          volumes = [ "/data/piper/data:/data" ];
          cmd = [ "--voice=en_US-lessac-medium" ];
          labels = {
            "io.containers.autoupdate" = "registry";
            "com.centurylinklabs.watchtower.stop-signal" = "SIGHUP";
          };
        };
      };
    };

    # Example log entry with obfuscated IP
    # Mai 30 11:08:07 schwalbe docker-homeassistant-start[2361020]: 2025-05-30 11:08:07.453 WARNING (MainThread) [homeassistant.components.http.ban] Login attempt or request with invalid authentication from XXX.XXX.XXX.XXX (XXX.XXX.XXX.XXX). Requested URL: '/auth/login_flow/815ce2fbc2ba7e1d5c9579697cd0ff42'. (Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:138.0) Gecko/20100101 Firefox/138.0)
    environment.etc."fail2ban/filter.d/homeassistant.local".text = pkgs.lib.mkDefault (
      pkgs.lib.mkAfter ''
        [INCLUDES]
        before = common.conf

        [Definition]
        failregex = ^.*Login attempt or request with invalid authentication from <ADDR>.*$
        ignoreregex =
      ''
    );

    services.fail2ban = {
      enable = true;
      jails = {
        homeassistant.settings = {
          enabled = true;
          filter = "homeassistant[journalmatch='_SYSTEMD_UNIT=docker-homeassistant.service']";
          backend = "systemd";
          banaction = "%(banaction_allports)s";
          maxretry = 5;
        };
      };
    };

    age.secrets = {
      home-assistant-restic-environment.file = ../secrets/home-assistant-restic-environment.age;
      home-assistant-restic-password.file = ../secrets/home-assistant-restic-password.age;
    };

    services.restic.backups = {
      home-assistant = {
        initialize = true;

        paths = [ homeAssistantConfigDir ];

        repository = "b2:${config.networking.hostName}-home-assistant";
        environmentFile = config.age.secrets.home-assistant-restic-environment.path;
        passwordFile = config.age.secrets.home-assistant-restic-password.path;

        timerConfig = {
          OnCalendar = "10:00";
          RandomizedDelaySec = "5min";
        };

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
        ];
      };
    };
  };
}
