{
  pkgs,
  nixpkgs-felix,
  ...
}:
let
  felix = import nixpkgs-felix {
    system = pkgs.system;
  };
in
{
  environment.systemPackages = [ felix.strfry ];
}
