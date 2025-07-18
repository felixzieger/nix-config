{
  self,
  pkgs,
  config,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
  boot.loader.systemd-boot.configurationLimit = 30; # prevent boot partition running out of disk space

  imports = [ ../../services/systemd-email-notify.nix ];

  nix = {
    settings = {
      trusted-users =
        # Needed for pushing changes via `nixos-rebuild --target-host felix@<host>.felixzieger.de switch`
        # Adding a user equals password-less sudo. See https://github.com/NixOS/nix/issues/2127#issuecomment-2214837817
        # TODO separate deployment users
        [ "felix" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "Sat *-*-* 04:30:00";
      options = "--delete-older-than 30d";
    };
  };

  systemd.enableEmergencyMode = false;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false; # allows user-level programs to silently obtain sudo permissions which is a risk; but it's very comfrotable

  users.users.felix = {
    isNormalUser = true;
    description = "felix";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
    packages = [ ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCmx9zfsn7BMbXCbbaK/bPQaEk/26zFTMu4oqN8Fy77HCeeiqARjwPwfHjkipjn5P+CTpRjjNY1mLhCx7XJsaSAOnIyTdq/cwnD4SzTMsDm40kIY+zUjgc/j3J9XNCOhlnE6YTQADw2cf3clEQy6ngKROvThun54xsQoxh1uT6dzn+DgmC5qbjpPvfaj/wknGpWI2th083sZIoihPPknM26iWhi0wlF46BIwH93PYi52SO2TnAd6Lisxags+flv6bz0b56VuG38tUU08p5LiSoFLlNyZ3RK56wEd9R/Bds0CfF/nt2+lRxZ2hWD0IVoNsRf2pBkl6pPH2hJul34JsdvgQkV8qHLFuqbCQ9Y2+1EafYWVIaJhSBHd0X0vxxDqNHNTIReU1ZcCE27/gq6Fb9dw7BcEYRAyVJUys9nGZxsVfk0+oaFlmzNSaU9WuI7kHKKzti9WgxSVOvfZeriMijuX1hiiQNQTcnvtNQSoWqbtSESorlzLlyya/D1qt5yxM2Jz22NDtghJZzz2qRGbl9m58WNf8/QerbhK4Ip04FgJQO+htQvhBqyM1XkLd4A37FtI6DtqzmZDg8rGcuq62ZpIdk+p6Okxsrbd6kxUFbkm3l07fSTE2nfUNvpMBCoxySLxJZLF+exZEG9BoCx5hc2EabmYrjkSg10YKeQUlIq/w== felix@felix-meshpad"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDMgJyrlOc5k7LBZzPE+3SbWKlRgB4s7JU29xmu4ISWE felix@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZYRUQMRILMUlmxyONcKMrHR6VA6R7tYueaF2dCNuOy"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKAr2B730R5M9rMgyb92NALs5G4TLmF0+ua743dEbffv felix@macbook"
    ];
  };

  # See https://ghostty.org/docs/help/terminfo#ssh for a good explanation of terminfo
  environment.enableAllTerminfo = true;

  environment.systemPackages = [
    # view systemctl interactively
    # pkgs.systemctl-tui
    # pkgs.sysz

    # view journalctl interactively
    # pkgs.lazyjournal
  ];

  programs.zsh.enable = true;

  services = {
    journald.extraConfig = "SystemMaxUse=1000M"; # Reduce journald log size
    fail2ban = {
      enable = true; # comes with a default jail for SSH
      jails.sshd.settings = {
        maxretry = 5;
        findtime = 3600;
      };
      bantime = "24h"; # Ban IPs for one day on the first ban
      bantime-increment = {
        enable = true; # Enable increment of bantime after each violation
        multipliers = "1 2 4 8 16 32 64 128";
        maxtime = "1680h"; # Do not ban for more than 10 week
        overalljails = true; # Calculate the bantime based on all the violations
      };
      ignoreIP = [
        # "10.0.0.0/8"
        # "172.16.0.0/12"
        # "192.168.0.0/16"
        "hof.sonnenhof-zieger.de"
        "nextcloud.sonnenhof-zieger.de"
      ];
    };
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        LogLevel = "VERBOSE"; # fail2ban requires a log level that shows failed login attempts
      };
    };
    eternal-terminal = {
      enable = true;
      port = 2022;
    };
  };
  networking = {
    firewall = {
      allowedTCPPorts = [ config.services.eternal-terminal.port ];
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.felix = {
      home = {
        username = "felix";
        homeDirectory = "/home/felix";
        file.".ssh/rc".text = ''
          # SSH agent forwarding for attached sessions
          if test "$SSH_AUTH_SOCK"; then
            ln -sf "$SSH_AUTH_SOCK" $HOME/.ssh/ssh_auth_sock
          fi
        '';
        # This value determines the home Manager release that your
        # configuration is compatible with. This helps avoid breakage
        # when a new home Manager release introduces backwards
        # incompatible changes.
        #
        # You can update home Manager without changing this value. See
        # the home Manager release notes for a list of state version
        # changes in each release.
        stateVersion = "23.11";
      };

      imports = [ ./../../modules/zsh ];

      programs.tmux = {
        extraConfig = ''
          # SSH agent forwarding for attached sessions
          set-option -g -u update-environment[3]
          set-environment -g SSH_AUTH_SOCK $HOME/.ssh/ssh_auth_sock
        '';
      };
      programs.zsh.initContent = ''
        # SSH agent forwarding for attached sessions
        if test "$SSH_AUTH_SOCK" && [ "$SSH_AUTH_SOCK" != "$HOME/.ssh/ssh_auth_sock" ]; then
          ln -sf "$SSH_AUTH_SOCK" $HOME/.ssh/ssh_auth_sock
        fi
      '';
    };
  };
}
