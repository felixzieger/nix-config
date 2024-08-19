{
  description = "fzieger's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";

    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    mac-app-util.url =
      "github:hraban/mac-app-util"; # https://discourse.nixos.org/t/mac-applications-installed-by-nix-are-not-loaded-by-spotlight/14129/16
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixpkgs-darwin, nix-darwin
    , nixpkgs-unstable, mac-app-util, ... }: {
      nixosConfigurations = {
        "schwalbe" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = inputs;
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/nixos
            ./hosts/nixos/schwalbe/configuration.nix
            ./services/nginx.nix
            ./services/adguard.nix
            ./services/uptime-kuma.nix
            ./services/vaultwarden.nix
            ./services/calibre.nix

            ./services/docker.nix
            ./services/ghost.nix
            ./services/home-assistant.nix
            ./services/docsy.nix

            ./services/netdata.nix
            ./services/systemd-email-notify.nix

            inputs.agenix.nixosModules.default

          ];
        };
        "cameron" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = inputs;
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/nixos
            ./hosts/nixos/cameron/configuration.nix
            ./services/nginx.nix
            ./services/frigate.nix

            inputs.agenix.nixosModules.default
          ];
        };
        "schenkerpad" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = inputs;
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/schenkerpad
            ./hosts/schenkerpad/configuration.nix
          ];
        };
      };
      darwinConfigurations = {
        "Felixs-MacBook-Pro" = nix-darwin.lib.darwinSystem {
          system = "x86_64-darwin";

          specialArgs = inputs;
          modules = [
            home-manager.darwinModules.home-manager
            mac-app-util.darwinModules.default
            ./hosts/meshpad
            inputs.agenix.nixosModules.default
          ];
        };
      };
    };
}
