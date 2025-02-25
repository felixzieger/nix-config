{ pkgs, config, ... }: {
  config = {

    age.secrets = {
      watchtower-environment.file = ../secrets/watchtower-environment.age;
    };

    virtualisation.docker.enable = true;
    virtualisation.docker.autoPrune.enable = true;
    virtualisation.docker.autoPrune.flags = [ "--all" ];
    users.extraGroups.docker.members = [ "felix" ];
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        watchtower = {
          autoStart = true;
          image = "containrrr/watchtower:1.7.1";
          environment = {
            WATCHTOWER_LABEL_ENABLE = "false";
            WATCHTOWER_NOTIFICATIONS = "email";
            WATCHTOWER_NOTIFICATIONS_LEVEL = "warn";
            WATCHTOWER_NOTIFICATION_TITLE_TAG = config.networking.hostName;
            WATCHTOWER_NOTIFICATION_EMAIL_FROM = "bot@sonnenhof-zieger.de";
            WATCHTOWER_NOTIFICATION_EMAIL_TO = "alerts@felixzieger.de";
            WATCHTOWER_NOTIFICATION_EMAIL_SERVER = "smtp.strato.de";
            WATCHTOWER_NOTIFICATION_EMAIL_SERVER_PORT = "465";
            WATCHTOWER_NOTIFICATION_EMAIL_SERVER_USER =
              "bot@sonnenhof-zieger.de";
            WATCHTOWER_NOTIFICATION_EMAIL_DELAY = "10";
          };
          volumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
          environmentFiles = [ config.age.secrets.watchtower-environment.path ];
        };
      };
    };
  };
}
