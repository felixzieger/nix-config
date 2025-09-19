{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.services.domainExpiryCheck;

  normalizedDomains = map (domain: {
    inherit (domain) name;
    warnDays =
      if domain ? warnDays && domain.warnDays != null then domain.warnDays else cfg.warnDaysDefault;
    rdapUrl = if domain ? rdapUrl && domain.rdapUrl != null then domain.rdapUrl else null;
  }) cfg.domains;

  domainsJsonFile = pkgs.writeText "domain-expiry-check-domains.json" (
    builtins.toJSON normalizedDomains
  );

  rdapParser = pkgs.writeText "domain-expiry-rdap-parser.jq" (
    builtins.readFile ./domain-expiry-check-rdap.jq
  );

  domainExpiryChecker = pkgs.writeShellApplication {
    name = "domain-expiry-check";
    runtimeInputs = with pkgs; [
      curl
      jq
      coreutils
    ];
    text = builtins.replaceStrings [ "@rdap_parser@" ] [ (toString rdapParser) ] (
      builtins.readFile ./domain-expiry-check.sh
    );
  };

in
{
  options.services.domainExpiryCheck = {
    enable = mkEnableOption "daily domain expiration checks";

    domains = mkOption {
      type = types.listOf (
        types.submodule (
          { lib, ... }:
          {
            options = {
              name = lib.mkOption {
                type = types.str;
                description = "Domain name to check (apex domain).";
              };
              warnDays = lib.mkOption {
                type = types.nullOr types.ints.unsigned;
                default = null;
                description = "Warn when the domain expires within this many days. Uses the default threshold when unset.";
              };
              rdapUrl = lib.mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Custom RDAP endpoint for this domain, overriding the default rdap.org lookup.";
              };
            };
          }
        )
      );
      default = [ ];
      example = [
        {
          name = "example.com";
          warnDays = 21;
        }
        {
          name = "example.org";
        }
      ];
      description = "List of domains to monitor for upcoming expiration.";
    };

    warnDaysDefault = mkOption {
      type = types.ints.unsigned;
      default = 30;
      description = "Default threshold, in days, before expiration that will trigger an alert.";
    };

    onCalendar = mkOption {
      type = types.str;
      default = "daily";
      description = "systemd OnCalendar expression controlling how often the check runs.";
    };

    randomizedDelaySec = mkOption {
      type = types.str;
      default = "30min";
      description = "RandomizedDelaySec value to avoid hitting RDAP services at the exact same time.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.domain-expiry-check = {
      description = "Domain expiration check";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${domainExpiryChecker}/bin/domain-expiry-check ${domainsJsonFile}";
        # Allow network access for RDAP calls
        DynamicUser = false;
      };
    };

    systemd.timers.domain-expiry-check = {
      description = "Run domain expiration check";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.onCalendar;
        Persistent = true;
        RandomizedDelaySec = cfg.randomizedDelaySec;
      };
    };

    environment.systemPackages = [ domainExpiryChecker ];
  };
}
