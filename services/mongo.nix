{
  config,
  ...
}:
let
  albyHubPort = 8080;
  albyHubDataDir = "/data/alby-hub";
in
{
  age.secrets = {
    mongo.file = ../secrets/mongo.age;
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 27017 ];
    };
  };

  services.mongodb = {
    enableAuth = true;
    initialRootPasswordFile = config.age.secrets.mongo.path;
  };
}
