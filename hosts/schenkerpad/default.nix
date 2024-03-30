{ self, pkgs, agenix, home-manager, ... }: {

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
