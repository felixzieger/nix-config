{ inputs, pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Felix Zieger";
    #   userEmail = "github@felixzieger.de";
    #   delta.enable = true;
  };
}
