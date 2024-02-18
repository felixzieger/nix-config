let
  felix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTTX+nJfoLV+smER/g7CbqZQNN0W++HwCK8EP4oggCJ";
  users = [ felix ];

  schwalbe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHunIW8dfsxIcafgHHG/lNBW55Tk6aS7Qy86x3TFQG3X";
  cameron = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMPgvfVIcLInSlxUxdU/X0roocVNzEu6FPSOvkhkiLnQ";
  systems = [ schwalbe cameron ];
in
{
  "email-password-bot-sonnenhof-zieger.age".publicKeys = [ schwalbe ];
  "plausible-keybase.age".publicKeys = [ schwalbe ];
  "plausible-admin-password.age".publicKeys = [ schwalbe ];

  "frigate-basic-auth.age".publicKeys = [ cameron ];
  "tailscale-authkey.age".publicKeys = [ schwalbe ];
}
