{ config
, pkgs
, lib
, ...
}:
let
  cfg = config.services.alby-hub;
  albyHub = pkgs.callPackage ./alby-hub-pkg.nix {};
in
{
  options.services.alby-hub = {
    enable = lib.mkEnableOption "Alby Hub service";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8029;
      description = "Port to listen on";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/alby-hub";
      description = "Directory for Alby Hub data files";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.alby-hub = {
      description = "Alby Hub";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "1";
        DynamicUser = true;

        Environment = [
          "PORT=${toString cfg.port}"
          "WORK_DIR=${cfg.dataDir}"
          "LOG_EVENTS=true"
          "LDK_GOSSIP_SOURCE="
        ];

        # You'll need to package alby-hub and reference it here
        ExecStart = "${pkgs.alby-hub}/bin/albyhub";

        StateDirectory = "alby-hub";
        ReadWritePaths = [ cfg.dataDir ];

        # Security hardening similar to nostr-rs-relay
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
      };
    };
  };
}