{ pkgs, ... }:
{
  home.packages = with pkgs; [ fish ];
  programs.fish = {
    enable = true;
    shellAliases = {
      l = "ls";
      ls = "lsd";
      ll = "ls -l";
      la = "ls -la";
      tree = "ls --tree";
      npm = "pnpm";
      # Modern CLI tool aliases
      find = "fd";
      grep = "rg";
      cat = "bat";
      dig = "dog";
      sed = "sd";
    };
    shellInit = ''
      # Disable fish greeting
      set -U fish_greeting

      # Lazy load heavy initializations
      function __lazy_load_zoxide
        if not set -q ZOXIDE_INITIALIZED
          ${pkgs.zoxide}/bin/zoxide init fish | source
          set -g ZOXIDE_INITIALIZED 1
        end
      end

      function z
        __lazy_load_zoxide
        __zoxide_z $argv
      end

      function zi
        __lazy_load_zoxide
        __zoxide_zi $argv
      end
    '';
  };
  programs.zoxide = {
    enable = true;
    enableFishIntegration = false;
  };
}
