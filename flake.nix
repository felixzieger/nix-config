{
  description = "fzieger's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";

    nix-bitcoin.url = "github:fort-nix/nix-bitcoin/release";
    nix-bitcoin.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-bitcoin, nixpkgs-darwin, nix-darwin, ... }: {
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

          nix-bitcoin.nixosModules.default
          (nix-bitcoin + "/modules/presets/enable-tor.nix")
          ./services/bitcoin.nix

          inputs.agenix.nixosModules.default

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.felix = import ./home.nix;
          }
        ];
      };
      "cameron" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = inputs;
        modules = [
          ./hosts/cameron/configuration.nix
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
  darwinConfigurations = {
      "Felixs-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";

        specialArgs = inputs;
	modules = [
          home-manager.darwinModules.home-manager
          ./hosts/meshpad
	];
      };
    };
  };
}
