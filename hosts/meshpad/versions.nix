# Fixing packages
# 1. Find out which package is needed under https://search.nixos.org/packages
# 2. Search package under https://lazamar.co.uk/nix-versions/ and pick version
# 3. Extract the packages as per instructions
# 4. Add packages in pkgs.mkShell

let
  pkgs_fix_dhall = import (builtins.fetchGit {
    # Descriptive name to make the store path easier to identify
    name = "my-old-revision";
    url = "https://github.com/NixOS/nixpkgs/";
    ref = "refs/heads/nixpkgs-unstable";
    rev = "7cf5ccf1cdb2ba5f08f0ac29fc3d04b0b59a07e4";
  }) { };

  fix_dhall = pkgs_fix_dhall.haskellPackages.dhall_1_41_1;
  fix_dhall_docs =
    pkgs_fix_dhall.haskellPackages.dhall-docs; # https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=dhall-docs
  fix_dhall_json =
    pkgs_fix_dhall.haskellPackages.dhall-json; # https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=dhall-json
  fix_dhall_lsp = pkgs_fix_dhall.dhall-lsp-server;
in [
  fix_dhall
  fix_dhall_docs
  (fix_dhall_json.override { dhall = fix_dhall; })
  fix_dhall_lsp
]
