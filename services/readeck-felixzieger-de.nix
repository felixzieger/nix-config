{
  config,
  pkgs,
  ...
}:
{
  services = {
    nginx.virtualHosts."readeck.felixzieger.de" = {
      forceSSL = true;
      enableACME = true;
      http3 = true;
      quic = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.readeck.settings.server.port}";
      };
    };

    readeck = {
      enable = true;
      settings = {
        server = {
          port = 9000;
        };
      };
      environmentFile = config.age.secrets.readeck-felixzieger-de-env.path;
    };

    fail2ban = {
      enable = true;
      jails = {
        readeck.settings = {
          enabled = true;
          filter = "readeck[journalmatch='_SYSTEMD_UNIT=readeck.service']";
          backend = "systemd";
          banaction = "%(banaction_allports)s";
          maxretry = 10;
        };
      };
    };
  };

  age.secrets = {
    readeck-felixzieger-de-env.file = ../secrets/readeck-felixzieger-de-env.age;
  };

  # Example log entry for readeck
  # May 30 10:59:13 blausieb readeck[522853]: {"time":"2025-05-30T10:59:13.706290238+02:00","level":"INFO","msg":"http 401 Unauthorized","@id":"blausieb/vP9qJOKw5Z-000063","request":{"method":"POST","path":"/login","proto":"HTTP/1.1","remote_addr":"123.456.0.1"},"response":{"status":401,"length":1881,"elapsed_ms":1.211804}}
  environment.etc."fail2ban/filter.d/readeck.local".text = pkgs.lib.mkDefault (
    pkgs.lib.mkAfter ''
      [INCLUDES]
      before = common.conf

      [Definition]
      failregex = ^.*"msg":"http 401 Unauthorized",".*","remote_addr":"<ADDR>"}.*$
      ignoreregex =
    ''
  );
}
