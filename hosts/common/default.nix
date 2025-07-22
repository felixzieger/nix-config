{
  self,
  pkgs,
  agenix,
  config,
  ...
}:
{
  environment.variables.EDITOR = "nvim";
  environment.systemPackages = with pkgs; [
    git
    btop
    just
    dua
    just
    which
    tree
    lsd # missing: icon support; https://github.com/Peltoche/lsd/issues/199

    agenix.packages."${system}".default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";

    users.felix = {
      imports = [
        ./../../modules/git
        ./../../modules/fzf
        ./../../modules/tmux
        ./../../modules/neovim
        ./../../modules/ghostty
      ];

      # Let home Manager install and manage itself.
      programs.home-manager.enable = true;
    };
  };

}
