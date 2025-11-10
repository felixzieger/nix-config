{
  pkgs,
  lib,
  ...
}:

{
  devenv.warnOnNewVersion = false;

  claude.code.enable = true;

  scripts = {
    just-switch.exec = ''
      target_host=''${1:-$(hostname | cut -d "." -f 1)}
      if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Switching to new config for $target_host"
        sudo darwin-rebuild switch --flake ".#$target_host"
      else
        sudo nixos-rebuild switch --flake ".#$target_host"
      fi
    '';

    just-switch-linux.exec = ''
      target_host=$1
      if [[ -z "$target_host" ]]; then
        echo "Usage: switch-linux <target_host>"
        exit 1
      fi
      nixos-rebuild switch --fast --flake ".#$target_host" \
        --target-host "$target_host" --use-remote-sudo --use-substitutes
    '';

    just-gc.exec = ''
      generations=''${1:-5d}
      nix-collect-garbage --delete-older-than $generations
    '';
  };

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
