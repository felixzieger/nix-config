{ config, ... }:
{
  age.secrets = {
    ghcr-secret.file = ../secrets/ghcr-secret.age;
    note-to-quote-env.file = ../secrets/note-to-quote-env.age;
  };
  virtualisation.oci-containers = {
    containers = {
      note-to-quote = {
        autoStart = true;
        image = "ghcr.io/felixzieger/note-to-quote:latest";
        login = {
          registry = "ghcr.io";
          username = "felixzieger";
          passwordFile = config.age.secrets.ghcr-secret.path;
        };
        environmentFiles = [ config.age.secrets.note-to-quote-env.path ];
      };
    };
  };
}
