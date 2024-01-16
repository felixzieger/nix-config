{
  description = "fzieger's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      "schwalbe" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = inputs;
        modules = [
          ./hosts/schwalbe/configuration.nix
          ./common.nix
          ./services/nginx.nix
          ./services/adguard.nix
          ./services/uptime-kuma.nix
          ./services/home-assistant.nix

          inputs.agenix.nixosModules.default

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.felix = import ./home.nix;
          }
        ];
      };
      "hpt630-sonnenhof" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = inputs;
        modules = [
          ./hosts/hpt630-sonnenhof/configuration.nix
          ./common.nix
          ./services/nginx.nix
          ./services/adguard.nix
          ./services/frigate.nix

          inputs.agenix.nixosModules.default

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.felix = import ./home.nix;
          }
        ];
      };
    };
  };
}
