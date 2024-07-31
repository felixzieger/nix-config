# Copied from https://github.com/pSub/configs/blob/master/nixos%2Fserver%2Fmodules%2Fsystemd-email-notify.nix
# Background: https://pascal-wittmann.de/entry/systemd-failure-notification
{ config, lib, pkgs, ... }:

with lib;

let

  checkConditions = pkgs.writeScript "checkConditions" ''
    #!/bin/sh
    STATUS=$(systemctl status --full "$1")

    case "$STATUS" in
      *"activating (auto-restart) (Result: timeout)"*) exit 1 ;;
      *) exit 0 ;;
    esac
  '';

  sendmail = pkgs.writeScript "sendmail" ''
    #!/bin/sh

    ${pkgs.system-sendmail}/bin/sendmail -t <<ERRMAIL
    To: $1
    From: ${config.systemd.email-notify.mailFrom}
    Subject: [${config.networking.hostName}] Status of service $2
    Content-Transfer-Encoding: 8bit
    Content-Type: text/plain; charset=UTF-8

    $(systemctl status --full "$2")
    ERRMAIL
  '';

in {
  options = {
    systemd.email-notify.mailTo = mkOption {
      type = types.str;
      default = null;
      description = "Email address to which the service status will be mailed.";
    };

    systemd.email-notify.mailFrom = mkOption {
      type = types.str;
      default = null;
      description =
        "Email address from which the service status will be mailed.";
    };

    systemd.services = mkOption {
      type = with types;
        attrsOf (submodule { config.onFailure = [ "email@%n.service" ]; });
    };
  };

  config = {
    systemd.services."email@" = {
      description = "Sends a status mail via sendmail on service failures.";
      onFailure = mkForce [ ];
      unitConfig = {
        StartLimitIntervalSec = "5m";
        StartLimitBurst = 1;
      };
      serviceConfig = {
        ExecCondition = "${checkConditions} %i";
        ExecStart = "${sendmail} ${config.systemd.email-notify.mailTo} %i";
        Type = "oneshot";
      };
    };

    systemd.email-notify.mailTo = "alerts@felixzieger.de";
    systemd.email-notify.mailFrom = "bot@sonnenhof-zieger.de";

    age.secrets = {
      email-password-bot-sonnenhof-zieger = {
        file = ../secrets/email-password-bot-sonnenhof-zieger.age;
        mode =
          # msmtp has no daemon and runs as the invoking user so the secret must be readable by anyone invoking msmtp
          # TODO tighter access
          "0444";
      };
    };

    programs.msmtp = {
      enable = true;
      accounts = {
        default = {
          auth = true;
          tls = true;
          # tls_starttls = false;
          host = "smtp.strato.de";
          from = "bot@sonnenhof-zieger.de";
          user = "bot@sonnenhof-zieger.de";
          passwordeval =
            "cat ${config.age.secrets.email-password-bot-sonnenhof-zieger.path}";
        };
      };
    };
  };
}
