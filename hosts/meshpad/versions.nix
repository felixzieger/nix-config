# Fixing packages
# 1. Find out which package is needed under https://search.nixos.org/packages
# 2. Search package under https://lazamar.co.uk/nix-versions/ and pick version
# 3. Extract the packages as per instructions
# 4. Add packages in pkgs.mkShell
let
  pkgs_fix_dhall = import
    (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/976fa3369d722e76f37c77493d99829540d43845.tar.gz";
    })
    { };

  fix_dhall = pkgs_fix_dhall.haskellPackages.dhall; # https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=dhall
  fix_dhall_docs = pkgs_fix_dhall.haskellPackages.dhall-docs; # https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=dhall-docs
  fix_dhall_json = pkgs_fix_dhall.haskellPackages.dhall-json; # https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=dhall-json

  pkgs_fix_dhall_lsp = import
    (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/89f196fe781c53cb50fef61d3063fa5e8d61b6e5.tar.gz"; # https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=dhall-lsp-server
    })
    { };

  fix_dhall_lsp = pkgs_fix_dhall_lsp.dhall-lsp-server;
in
[
  fix_dhall
  fix_dhall_docs
  (fix_dhall_json.override {
    dhall = fix_dhall;
  })
  fix_dhall_lsp
]
