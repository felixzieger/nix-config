{
  self,
  pkgs,
  agenix,
  home-manager,
  ...
}:
{
  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "DejaVuSansMono"
        "SourceCodePro"
      ];
    })
  ];

  environment.systemPackages = [ pkgs.ghostty pkgs.eternal-terminal ];

  home-manager.backupFileExtension = "backup";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.felix = {
    home.username = "felix";
    home.homeDirectory = "/home/felix";

    programs.firefox = {
      enable = true;
      policies = {
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DisableFirefoxAccounts = false;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        OfferToSaveLoginsDefault = false;
        PasswordManagerEnabled = false;
        FirefoxHome = {
          Search = true;
          Pocket = false;
          Snippets = false;
          TopSites = false;
          Highlights = false;
        };
        UserMessaging = {
          ExtensionRecommendations = false;
          SkipOnboarding = true;
        };
      };
    };

    imports = [
      ./../../modules/fzf
      ./../../modules/zsh
      ./../../modules/tmux
      ./../../modules/neovim
      ./../../modules/git
      ./../../modules/ssh
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
  };
}
