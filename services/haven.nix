{
  config,
  pkgs,
  lib,
  ...
}:
let
  defaultSettings = lib.attrsets.mapAttrs (name: value: 
    if builtins.isBool value then
      if value then "true" else "false"
    else
      toString value
  ) (
    builtins.fromTOML (builtins.readFile "${cfg.package}/share/haven/.env.example")
  );
  mergedSettings =
    defaultSettings
    // {
      OWNER_NPUB = cfg.ownerNpub;
      RELAY_URL = cfg.relayUrl;
      RELAY_PORT = toString cfg.port;
      PRIVATE_RELAY_NAME = "${cfg.ownerName}'s private relay";
      PRIVATE_RELAY_NPUB = cfg.ownerNpub;
      CHAT_RELAY_NAME = "${cfg.ownerName}'s chat relay";
      CHAT_RELAY_NPUB = cfg.ownerNpub;
      OUTBOX_RELAY_NAME = "${cfg.ownerName}'s outbox relay";
      OUTBOX_RELAY_NPUB = cfg.ownerNpub;
      INBOX_RELAY_NAME = "${cfg.ownerName}'s inbox relay";
      INBOX_RELAY_NPUB = cfg.ownerNpub;
      IMPORT_SEED_RELAYS_FILE = "${pkgs.writeText "relays_import.json" (
        builtins.toJSON cfg.importRelays
      )}";
      BLASTR_RELAYS_FILE = "${pkgs.writeText "relays_blastr.json" (builtins.toJSON cfg.blastrRelays)}";
    }
    // cfg.settings;

  cfg = config.services.haven;
in
{
  options.services.haven = {
    enable = lib.mkEnableOption "haven";

    package = lib.mkOption {
      type = lib.types.package;
      # TODO add default once merged to nixpkgs
      description = "The Haven package to use.";
    };

    port = lib.mkOption {
      default = 3355;
      type = lib.types.port;
      description = "Listen on this port.";
    };

    relayUrl = lib.mkOption {
      default = "relay.utxo.one";
      type = lib.types.str;
      description = "The URL of the relay.";
    };

    ownerNpub = lib.mkOption {
      type = lib.types.str;
      description = "The NPUB of the owner.";
    };

    ownerName = lib.mkOption {
      type = lib.types.str;
      description = "The name of the owner. Used for relay names and descriptions.";
      default = "a nostrich";
    };

    blastrRelays = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of relay configurations for blastr";
      example = lib.literalExpression ''
        [
          "relay.example.com"
        ]
      '';
    };

    importRelays = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of relay configurations for importing historical events";
      example = lib.literalExpression ''
        [
          "relay.example.com"
        ]
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Additional environment variables to set for the Haven service. See https://github.com/bitvora/haven for documentation.";
      example = lib.literalExpression ''
        {
          PRIVATE_RELAY_NAME = "My Custom Relay Name";
          BACKUP_PROVIDER = "s3";
        }
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a file containing sensitive environment variables. See https://github.com/bitvora/haven for documentation.
        The file should contain environment-variable assignments like:
        S3_SECRET_KEY=mysecretkey
        S3_ACCESS_KEY_ID=myaccesskey
      '';
      example = "/var/lib/haven/secrets.env";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.haven = {
      description = "Haven daemon user";
      group = "haven";
      isSystemUser = true;
    };

    users.groups.haven = { };

    systemd.services.haven = {
      description = "haven";
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = mergedSettings;

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/haven";
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        User = "haven";
        Group = "haven";
        Restart = "on-failure";
        Type = "simple";

        RuntimeDirectory = "haven";
        StateDirectory = "haven";
        WorkingDirectory = "/var/lib/haven";

        # Create symlink to templates in the working directory
        ExecStartPre = "+${pkgs.coreutils}/bin/ln -sfT ${cfg.package}/share/haven/templates /var/lib/haven/templates";

        PrivateTmp = true;
        PrivateUsers = true;
        PrivateDevices = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        NoNewPrivileges = true;
        MemoryDenyWriteExecute = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectClock = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        ProtectControlGroups = true;
        LockPersonality = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        RestrictRealtime = true;
        ProtectHostname = true;
        CapabilityBoundingSet = "";
        SystemCallFilter = [
          "@system-service"
        ];
        SystemCallArchitectures = "native";
      };
    };
  };

  meta.maintainers = with lib.maintainers; [
    felixzieger
  ];
}
