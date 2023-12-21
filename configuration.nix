{ config, pkgs, agenix, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./services/nginx.nix
    ./services/adguard.nix
    ./services/uptime-kuma.nix
    ./services/plausible.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  console.keyMap = "de";

  users.users.felix = {
    isNormalUser = true;
    description = "Felix";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCmx9zfsn7BMbXCbbaK/bPQaEk/26zFTMu4oqN8Fy77HCeeiqARjwPwfHjkipjn5P+CTpRjjNY1mLhCx7XJsaSAOnIyTdq/cwnD4SzTMsDm40kIY+zUjgc/j3J9XNCOhlnE6YTQADw2cf3clEQy6ngKROvThun54xsQoxh1uT6dzn+DgmC5qbjpPvfaj/wknGpWI2th083sZIoihPPknM26iWhi0wlF46BIwH93PYi52SO2TnAd6Lisxags+flv6bz0b56VuG38tUU08p5LiSoFLlNyZ3RK56wEd9R/Bds0CfF/nt2+lRxZ2hWD0IVoNsRf2pBkl6pPH2hJul34JsdvgQkV8qHLFuqbCQ9Y2+1EafYWVIaJhSBHd0X0vxxDqNHNTIReU1ZcCE27/gq6Fb9dw7BcEYRAyVJUys9nGZxsVfk0+oaFlmzNSaU9WuI7kHKKzti9WgxSVOvfZeriMijuX1hiiQNQTcnvtNQSoWqbtSESorlzLlyya/D1qt5yxM2Jz22NDtghJZzz2qRGbl9m58WNf8/QerbhK4Ip04FgJQO+htQvhBqyM1XkLd4A37FtI6DtqzmZDg8rGcuq62ZpIdk+p6Okxsrbd6kxUFbkm3l07fSTE2nfUNvpMBCoxySLxJZLF+exZEG9BoCx5hc2EabmYrjkSg10YKeQUlIq/w== felix@felix-meshpad"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git
    agenix.packages."${system}".default
  ];

  programs.zsh.enable = true;

  programs.tmux =
    {
      enable = true;
      extraConfig = ''
        # Switch pane layout    CTRL+B SPACE
        # Toggle focus for pane CTRL+B Z
        set -g mouse on
        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        # True color settings
        set -g default-terminal "$TERM"
        set -ag terminal-overrides ",$TERM:Tc"
      '';
    };

  environment.variables.EDITOR = "nvim";
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
