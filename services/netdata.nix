{ pkgs, config, ... }: {
  config = {
    environment.systemPackages = with pkgs;
      [
        jq # optional dependency used for transforming docker data
      ];

    services.nginx.virtualHosts."netdata.${config.networking.hostName}.local" =
      {
        locations."/" = { proxyPass = "http://localhost:${toString 19999}"; };
      };

    services.netdata = {
      enable = true;
      enableAnalyticsReporting = false;
      # TODO Configure storage limits <4GB (which is the default or move home to /data/netdata/home
    };
  };
}
