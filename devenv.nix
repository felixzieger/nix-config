{
  pkgs,
  lib,
  ...
}:

{
  claude.code.enable = true;

  git-hooks.hooks = {
    nixfmt-rfc-style = {
      enable = true;
      stages = [ "pre-commit" ];
    };

    statix = {
      enable = true;
      stages = [ "pre-commit" ];
    };

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
