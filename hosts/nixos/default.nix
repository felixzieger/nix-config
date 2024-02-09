{ self, pkgs, agenix, ... }: {
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

  nixpkgs.config.allowUnfree = true;

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


  security.doas.enable = true;
  security.doas.extraRules = [{
    users = [ "felix" ];
    keepEnv = true;
    setEnv = [ "HOME" ];
    noPass = true;
  }];
  security.sudo.enable = false;
  environment.shellAliases.sudo = "doas";

  users.users.felix = {
    isNormalUser = true;
    description = "felix";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCmx9zfsn7BMbXCbbaK/bPQaEk/26zFTMu4oqN8Fy77HCeeiqARjwPwfHjkipjn5P+CTpRjjNY1mLhCx7XJsaSAOnIyTdq/cwnD4SzTMsDm40kIY+zUjgc/j3J9XNCOhlnE6YTQADw2cf3clEQy6ngKROvThun54xsQoxh1uT6dzn+DgmC5qbjpPvfaj/wknGpWI2th083sZIoihPPknM26iWhi0wlF46BIwH93PYi52SO2TnAd6Lisxags+flv6bz0b56VuG38tUU08p5LiSoFLlNyZ3RK56wEd9R/Bds0CfF/nt2+lRxZ2hWD0IVoNsRf2pBkl6pPH2hJul34JsdvgQkV8qHLFuqbCQ9Y2+1EafYWVIaJhSBHd0X0vxxDqNHNTIReU1ZcCE27/gq6Fb9dw7BcEYRAyVJUys9nGZxsVfk0+oaFlmzNSaU9WuI7kHKKzti9WgxSVOvfZeriMijuX1hiiQNQTcnvtNQSoWqbtSESorlzLlyya/D1qt5yxM2Jz22NDtghJZzz2qRGbl9m58WNf8/QerbhK4Ip04FgJQO+htQvhBqyM1XkLd4A37FtI6DtqzmZDg8rGcuq62ZpIdk+p6Okxsrbd6kxUFbkm3l07fSTE2nfUNvpMBCoxySLxJZLF+exZEG9BoCx5hc2EabmYrjkSg10YKeQUlIq/w== felix@felix-meshpad"
    ];
  };

  environment.systemPackages = with pkgs; [
    which
    tree
    git
    btop # monitor resources like cpu, memory, disk
    dig # DNS lookup
    sad # batch find and replace; use like find "$FIND_ARGS" | sad '<pattern>' '<replacement>'; select edits with "tab"

    agenix.packages."${system}".default


    systemctl-tui # view systemctl interactively
    sysz
  ];

  programs.zsh.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.felix =
    {
      home.username = "felix";
      home.homeDirectory = "/home/felix";

      programs.git = {
        enable = true;
        userName = "Felix Zieger";
        userEmail = "github@felixzieger.de";
        delta.enable = true;
      };

      programs.lazygit.enable = true;

      imports = [
        ./../../modules/fzf
        ./../../modules/zsh
        ./../../modules/tmux
        ./../../modules/neovim
      ];

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
