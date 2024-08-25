{ ... }: {
  imports = [
    ./hardware-configuration.nix
    
    
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "hedwig";
  networking.domain = "";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZYRUQMRILMUlmxyONcKMrHR6VA6R7tYueaF2dCNuOy xilef@meshpad'' ];
  system.stateVersion = "23.11";
}
