let
  felix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTTX+nJfoLV+smER/g7CbqZQNN0W++HwCK8EP4oggCJ";
  users = [ felix ];
in
{
  "email-password-bot-sonnenhof-zieger.age".publicKeys = [ felix ];
  "plausible-keybase.age".publicKeys = [ felix ];
  "plausible-admin-password.age".publicKeys = [ felix ];
}
