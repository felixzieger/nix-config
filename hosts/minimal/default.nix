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
    neovim

    agenix.packages."${system}".default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.felix = {
      imports = [
        ./../../modules/git
      ];

      # Let home Manager install and manage itself.
      programs.home-manager.enable = true;
    };
  };

}
