{ self, pkgs, agenix, home-manager, ... }: {
  nixpkgs.config.allowUnfree = true;

  nix.settings.trusted-users =
    # Needed for pushing changes via `nixos-rebuild --target-host felix@<host>.felixzieger.de switch`
    # Adding a user equals password-less sudo. See https://github.com/NixOS/nix/issues/2127#issuecomment-2214837817
    # TODO separate deployment users
    [ "felix" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "Sat *-*-* 14:30:00";
    options = "--delete-older-than 30d";
  };
  system.autoUpgrade = {
    enable = true;
    flake = self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
      "-L" # print build logs
    ];
    dates = "Sat *-*-* 12:30:00";
    allowReboot = true;
  };

  systemd.enableEmergencyMode = false;
  services.journald.extraConfig =
    "SystemMaxUse=1000M"; # Reduce journald log size

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword =
    false; # allows user-level programs to silently obtain sudo permissions which is a risk; but it's very comfrotable

  users.users.felix = {
    isNormalUser = true;
    description = "felix";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCmx9zfsn7BMbXCbbaK/bPQaEk/26zFTMu4oqN8Fy77HCeeiqARjwPwfHjkipjn5P+CTpRjjNY1mLhCx7XJsaSAOnIyTdq/cwnD4SzTMsDm40kIY+zUjgc/j3J9XNCOhlnE6YTQADw2cf3clEQy6ngKROvThun54xsQoxh1uT6dzn+DgmC5qbjpPvfaj/wknGpWI2th083sZIoihPPknM26iWhi0wlF46BIwH93PYi52SO2TnAd6Lisxags+flv6bz0b56VuG38tUU08p5LiSoFLlNyZ3RK56wEd9R/Bds0CfF/nt2+lRxZ2hWD0IVoNsRf2pBkl6pPH2hJul34JsdvgQkV8qHLFuqbCQ9Y2+1EafYWVIaJhSBHd0X0vxxDqNHNTIReU1ZcCE27/gq6Fb9dw7BcEYRAyVJUys9nGZxsVfk0+oaFlmzNSaU9WuI7kHKKzti9WgxSVOvfZeriMijuX1hiiQNQTcnvtNQSoWqbtSESorlzLlyya/D1qt5yxM2Jz22NDtghJZzz2qRGbl9m58WNf8/QerbhK4Ip04FgJQO+htQvhBqyM1XkLd4A37FtI6DtqzmZDg8rGcuq62ZpIdk+p6Okxsrbd6kxUFbkm3l07fSTE2nfUNvpMBCoxySLxJZLF+exZEG9BoCx5hc2EabmYrjkSg10YKeQUlIq/w== felix@felix-meshpad"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDMgJyrlOc5k7LBZzPE+3SbWKlRgB4s7JU29xmu4ISWE felix@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZYRUQMRILMUlmxyONcKMrHR6VA6R7tYueaF2dCNuOy"
    ];
  };

  environment.systemPackages = with pkgs; [
    which
    tree
    git
    btop # monitor resources like cpu, memory, disk

    agenix.packages."${system}".default

    # systemctl-tui # view systemctl interactively
    # sysz
  ];

  programs.zsh.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  services.fail2ban = {
    enable = true; # comes with a default jail for SSH
    jails.sshd.settings = { maxretry = 10; };
  };
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      LogLevel =
        "VERBOSE"; # fail2ban requires a log level that shows failed login attempts
    };
  };
  services.eternalterminal = {
    enable = true;
    port = 2022;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.felix = {
    home.username = "felix";
    home.homeDirectory = "/home/felix";

    imports = [
      ./../../modules/fzf
      ./../../modules/zsh
      ./../../modules/tmux
      ./../../modules/neovim
      ./../../modules/git
    ];

    programs.tmux = {
      extraConfig = ''
        # SSH agent forwarding for attached sessions
        set-option -g -u update-environment[3]
        set-environment -g SSH_AUTH_SOCK $HOME/.ssh/ssh_auth_sock
      '';
    };
    home.file.".ssh/rc".text = ''
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
    home.stateVersion = "23.11";

    # Let home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
