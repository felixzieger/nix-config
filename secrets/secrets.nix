let
  felix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTTX+nJfoLV+smER/g7CbqZQNN0W++HwCK8EP4oggCJ";
  users = [ felix ];

  nixos-hpt630 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHunIW8dfsxIcafgHHG/lNBW55Tk6aS7Qy86x3TFQG3X";
  systems = [ nixos-hpt630 ];
in
{
  "email-password-bot-sonnenhof-zieger.age".publicKeys = [ felix nixos-hpt630 ];
  "plausible-keybase.age".publicKeys = [ felix nixos-hpt630 ];
  "plausible-admin-password.age".publicKeys = [ felix nixos-hpt630 ];
}
