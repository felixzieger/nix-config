{ pkgs, lib, ... }:
let acmePort = 3000;
in {
  security.acme = {
    acceptTerms = true;
    email = "admin@sonnenhof-zieger.de";
  };
}
