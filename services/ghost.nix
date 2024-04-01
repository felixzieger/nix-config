{ pkgs, config, ... }:
let
  ghostHost = "blog.felixzieger.de";
  ghostPort = 2368;
  ghostDataDir = "/data/ghost/data";
in
{
  config = {
    services.nginx.virtualHosts."${ghostHost}" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString ghostPort}";
      };
    };

    age.secrets = {
      ghost-environment.file = ../secrets/ghost-environment.age;
    };

    virtualisation.docker.enable = true;
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        ghost =
          {
            autoStart = true;
            image = "ghost:5-alpine";
            volumes = [
              "${ghostDataDir}:/var/lib/ghost/content"
              "/data/ghost/logs:/var/lib/ghost/content/logs"
            ];
            ports = [ "${builtins.toString ghostPort}:${builtins.toString ghostPort}" ];
            environment = {
              NODE_ENV = "production";
              url = "https://${ghostHost}";

              server__port = toString ghostPort;

              database__client = "sqlite3";
              database__connection__filename = "/var/lib/ghost/content/data/ghost.db";

              mail__from = "noreply@blog.felixzieger.de";
              mail__transport = "SMTP";
              mail__options__service = "Mailgun";
              mail__options__host = "smtp.eu.mailgun.org";
              mail__options__port = toString 587;
              mail__options__secure = toString false;
              mail__options__requireTLS = toString true;
              mail__options__auth__user = "postmaster@newsletter.felixzieger.de";

              paths__contentPath = "/var/lib/ghost/content";

              privacy__useTinfoil = toString true;
              logging__path = "/var/lib/ghost/content/logs";
            };
            environmentFiles = [
              config.age.secrets.ghost-environment.path
            ];
          };
      };
    };

    age.secrets = {
      ghost-restic-environment.file = ../secrets/ghost-restic-environment.age;
      ghost-restic-password.file = ../secrets/ghost-restic-password.age;
    };

    services.restic.backups = {
      ghost = {
        initialize = true;

        paths = [ ghostDataDir ];

        repository = "b2:${config.networking.hostName}-ghost";
        environmentFile = config.age.secrets.ghost-restic-environment.path;
        passwordFile = config.age.secrets.ghost-restic-password.path;

        timerConfig = {
          OnCalendar = "15:00";
          RandomizedDelaySec = "2h";
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
