{
  pkgs,
  ...
}:

{
  packages = [
    pkgs.opentofu
    pkgs.oci-cli
  ];
}
