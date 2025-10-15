{
  pkgs,
  lib,
  ...
}:

{
  devenv.warnOnNewVersion = false;

  claude.code.enable = true;

  git-hooks.hooks = {
    flake-checker.enable = true;
    deadnix.enable = true;
    nixfmt-rfc-style.enable = true;
    statix.enable = true;

    nixfmt-rfc-style-all = {
      enable = true;
      name = "nixfmt-rfc-style-all";
      entry = "${lib.getExe pkgs.fd} -e nix -t f . --exclude .git --exclude result -x ${pkgs.nixfmt-rfc-style}/bin/nixfmt";
      files = "\\.nix$";
      stages = [ "pre-push" ];
      pass_filenames = false;
    };

    statix-all = {
      enable = true;
      name = "statix-all";
      entry = "${pkgs.statix}/bin/statix check .";
      files = "\\.nix$";
      stages = [ "pre-push" ];
      pass_filenames = false;
    };
  };
}
