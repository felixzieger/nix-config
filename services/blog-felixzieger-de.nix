{ pkgs, config, ... }:
let
  ghostHost = "blog.felixzieger.de";
  ghostPort = 2368;
  ghostDataDir = "/data/blog-felixzieger-de/data";
  ghostDbDir = "/data/blog-felixzieger-de/mysql";
in
{
  config = {
    services.nginx.virtualHosts."${ghostHost}" = {
      forceSSL = true;
      enableACME = true;
      http3 = true;
      quic = true;
      locations."/" = {
        proxyPass = "http://localhost:${toString ghostPort}";
      };
    };

    age.secrets = {
      blog-felixzieger-de-environment.file = ../secrets/blog-felixzieger-de-environment.age;
    };

    virtualisation.oci-containers = {
      containers = {
        ghost-mysql = {
          autoStart = true;
          image = "mysql:8.4.7";
          volumes = [
            "${ghostDbDir}:/var/lib/mysql"
          ];
          environment = {
            MYSQL_DATABASE = "ghost";
            MYSQL_USER = "ghost";
          };
          environmentFiles = [ config.age.secrets.blog-felixzieger-de-environment.path ];
          extraOptions = [ "--network=ghost-bridge" ];
        };

        ghost = {
          autoStart = true;
          image = "ghost:6-alpine";
          volumes = [
            "${ghostDataDir}:/var/lib/ghost/content"
            "/data/ghost/logs:/var/lib/ghost/content/logs"
          ];
          ports = [ "${builtins.toString ghostPort}:${builtins.toString ghostPort}" ];
          dependsOn = [ "ghost-mysql" ];
          environment = {
            NODE_ENV = "production";
            url = "https://${ghostHost}";

            server__port = toString ghostPort;

            database__client = "mysql";
            database__connection__host = "ghost-mysql";
            database__connection__user = "ghost";
            database__connection__database = "ghost";

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
          environmentFiles = [ config.age.secrets.blog-felixzieger-de-environment.path ];
          extraOptions = [ "--network=ghost-bridge" ];
        };
      };
    };

    age.secrets = {
      blog-felixzieger-de-restic-environment.file = ../secrets/blog-felixzieger-de-restic-environment.age;
      blog-felixzieger-de-restic-password.file = ../secrets/blog-felixzieger-de-restic-password.age;
    };

    services.restic.backups = {
      ghost = {
        initialize = true;

        paths = [
          ghostDataDir
          ghostDbDir
        ];

        repository = "b2:blog-felixzieger-de";
        environmentFile = config.age.secrets.blog-felixzieger-de-restic-environment.path;
        passwordFile = config.age.secrets.blog-felixzieger-de-restic-password.path;

        timerConfig = {
          OnCalendar = "15:00";
          RandomizedDelaySec = "5min";
        };

        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
        ];
      };
    };

    systemd.services.init-ghost-network = {
      description = "Create the network ghost-bridge for Ghost.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";
      script =
        let
          dockercli = "${config.virtualisation.docker.package}/bin/docker";
        in
        ''
          check=$(${dockercli} network ls | grep "ghost-bridge" || true)
          if [ -z "$check" ]; then
            ${dockercli} network create ghost-bridge
          else
            echo "ghost-bridge already exists in docker"
          fi
        '';
    };
  };
}

