{ nixpkgs-unstable, pkgs, config, ... }:
let
  unstable = import nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in {
  config = {
    age.secrets = {
      netdata-basic-auth = {
        file = ../secrets/netdata-basic-auth.age;
        owner = "nginx";
      };
    };

    # The current config is exposed via https://netdata.schwalbe.felixzieger.de/netdata.conf
    services.nginx.virtualHosts."netdata.${config.networking.hostName}.felixzieger.de" =
      {
        basicAuthFile = config.age.secrets.netdata-basic-auth.path;
        forceSSL = true;
        enableACME = true;
        # http3 = true;
        # quic = true;
        locations."/" = { proxyPass = "http://localhost:${toString 19999}"; };
      };

    services.netdata = {
      enable = true;
      package = unstable.netdata;
      enableAnalyticsReporting = false;
      # TODO Configure storage limits <4GB (which is the default or move home to /data/netdata/home
      configDir = {
        # https://github.com/netdata/netdata/blob/master/src/go/plugin/go.d/config/go.d.conf
        "go.d.conf" = pkgs.writeText "go.d.conf" ''
          enabled: yes

          # Enable/disable default value for all modules.
          default_run: yes

          # Maximum number of used CPUs. Zero means no limit.
          max_procs: 0

          modules:
            docker: yes
            nginx: yes
            web_log: yes
        '';
      };
    };

    # Expose stub status page from nginx on locahost
    # services.nginx.statusPage = true; # This exposes a status page on /nginx_status which is not found by netdata
    services.nginx.virtualHosts."127.0.0.1" = {
      listenAddresses = [ "0.0.0.0" ];
      locations."/stub_status" = {
        extraConfig = ''
          stub_status on;
          access_log off;

          allow 127.0.0.1;
          deny all; 
        '';
      };
    };
  };
}
