{ pkgs, config, lib, ... }:
let
  plausiblePort = 8000;
  plausibleHost = "plausible.felixzieger.de";
in
{
  config = {

    # services.nginx.virtualHosts."${plausibleHost}" = {
    #   forceSSL = true;
    #   enableACME = true;
    #   locations."/" = {
    #     proxyPass = "http://localhost:${toString plausiblePort}";
    #   };
    # };

    # networking = {
    #   firewall = {
    #     allowedTCPPorts = [ plausiblePort ];
    #   };
    # };

    age.secrets = {
      email-password-bot-sonnenhof-zieger.file = ./secrets/email-password-bot-sonnenhof-zieger.age;
      plausible-keybase.file = ./secrets/plausible-keybase.age;
      plausible-admin-password.file = ./secrets/plausible-admin-password.age;
    };

    services = {
      plausible = {
        enable = true;

        server = {
          baseUrl = plausibleHost;
          port = plausiblePort;
          # disableRegistration = true;
          secretKeybaseFile = config.age.secrets.plausible-keybase.path;
        };

        adminUser = {
          activate = true;
          name = "felix";
          email = "felix@sonnenhof-zieger.de";
          passwordFile = config.age.secrets.plausible-admin-password.path;
        };

        mail = {
          email = "bot@sonnenhof-zieger.de";
          smtp = {
            hostAddr = "smtp.strato.de";
            hostPort = 465;
            enableSSL = true;
            user = "bot@sonnenhof-zieger.de";
            passwordFile = config.age.secrets.email-password-bot-sonnenhof-zieger.path;
          };
        };
      };
    };
  };
}
