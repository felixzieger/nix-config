# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  console.keyMap = "de";

  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "ehci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      # For frigate hwaccell
      kernelModules = [ "amdgpu" ];
    };
    kernelModules = [ "kvm-amd" ];

    extraModulePackages = [
      # Coral Gasket Driver allows usage of the Coral EdgeTPU; needed for Frigate
      # Needs to be updated when the kernel is updated. For example at channel updates.
      pkgs.linuxKernel.packages.linux_6_12.gasket
    ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/7dfe4ec9-8818-436e-ab68-12b79462ce12";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/BF5C-11EC";
      fsType = "vfat";
    };

    "/data" = {
      device = "/dev/disk/by-uuid/9b69fad5-23b1-400f-8675-e135734e6a2c";
      fsType = "ext4";
    };
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
