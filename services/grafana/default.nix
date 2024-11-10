{ config, pkgs, ... }: {

  services.nginx.virtualHosts."${config.services.grafana.settings.server.domain}" =
    {
      forceSSL = true;
      enableACME = true;
      http3 = true;
      quic = true;
      locations."/" = {
        proxyPass = "http://${
            toString config.services.grafana.settings.server.http_addr
          }:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
      };
    };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3002;
        enforce_domain = true;
        enable_gzip = true;
        domain = "grafana.${config.networking.hostName}.felixzieger.de";
      };
    };
    provision = {
      enable = true;

      dashboards.settings.providers = [{
        name = "my dashboards";
        options.path = "/etc/grafana-dashboards";
      }];

      datasources.settings.datasources = [{
        name = "Prometheus";
        type = "prometheus";
        url = "http://${config.services.prometheus.listenAddress}:${
            toString config.services.prometheus.port
          }";
      }];
      datasources.settings.deleteDatasources = [{
        name = "prometheus schwalbe";
        orgId = 1;
      }];
    };
  };

  services.nginx.statusPage = true; # nginx exporter scrapes from this page

  age.secrets = {
    all-buckets-read-only-restic-environment.file =
      ../../secrets/all-buckets-read-only-restic-environment.age;
  };

  services.prometheus = {
    enable = true;
    port = 9090;
    exporters = {
      node = {
        enable = true;
        port = 20100;
        enabledCollectors = [ "systemd" ];
      };

      nginx = {
        enable = true;
        port = 20101;
        scrapeUri = "http://localhost/nginx_status";
      };

      systemd = {
        enable = true;
        port = 20102;
      };

      restic = {
        enable = true;
        port = 20103;
        environmentFile =
          config.age.secrets.all-buckets-read-only-restic-environment.path;
        repository = config.services.restic.backups.home-assistant.repository;
        passwordFile = config.services.restic.backups.home-assistant.passwordFile;
      };
    };
    scrapeConfigs = [{
      job_name = "job ${config.networking.hostName}";
      static_configs = [{
        targets = [
          "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
          "127.0.0.1:${
            toString config.services.prometheus.exporters.nginx.port
          }"
          "127.0.0.1:${
            toString config.services.prometheus.exporters.systemd.port
          }"
          "127.0.0.1:${
            toString config.services.prometheus.exporters.restic.port
          }"
        ];
      }];
    }];
  };

  environment.etc."grafana-dashboards/node-exporter-full.json" = {
    # https://github.com/rfmoz/grafana-dashboards/blob/master/prometheus/node-exporter-full.json
    source = ./dashboards/node-exporter-full.json;
    group = "grafana";
    user = "grafana";
  };
  environment.etc."grafana-dashboards/nginx.json" = {
    # https://github.com/nginxinc/nginx-prometheus-exporter/blob/main/grafana/dashboard.json 
    source = ./dashboards/nginx.json;
    group = "grafana";
    user = "grafana";
  };
  environment.etc."grafana-dashboards/restic.json" = {
    # https://github.com/ngosang/restic-exporter/blob/main/grafana/grafana_dashboard.json
    source = ./dashboards/restic.json;
    group = "grafana";
    user = "grafana";
  };
}
