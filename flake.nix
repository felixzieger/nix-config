{
  description = "Felix's NixOS and Darwin Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    agenix.url = "github:ryantm/agenix";

    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";


    nix-bitcoin.url = "github:fort-nix/nix-bitcoin/release";

    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.11";


    mac-app-util.url =
      "github:hraban/mac-app-util"; # https://discourse.nixos.org/t/mac-applications-installed-by-nix-are-not-loaded-by-spotlight/14129/16
    # mac-app-util.inputs.nixpkgs.follows = "nixpkgs"; # Requires specific versions
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixpkgs-darwin, nix-darwin
    , nixpkgs-unstable, mac-app-util, nix-bitcoin, simple-nixos-mailserver, ... }: {
      nixosConfigurations = {
        "schwalbe" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = inputs;
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/common
            ./hosts/nixos
            ./hosts/nixos/schwalbe/configuration.nix
            ./services/nginx.nix
            ./services/up-felixzieger-de.nix
            ./services/frigate-sonnenhof-zieger-de.nix
            ./services/tailscale.nix

            nix-bitcoin.nixosModules.default
            (nix-bitcoin + "/modules/presets/enable-tor.nix")
            ./services/bitcoin.nix

            ./services/docker.nix
            ./services/home-assistant.nix
            ./services/alby-felixzieger-de.nix

            inputs.agenix.nixosModules.default

          ];
        };
        "cameron" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = inputs;
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/common
            ./hosts/nixos
            ./hosts/nixos/cameron/configuration.nix
            ./services/nginx.nix
            ./services/nextcloud-sonnenhof-zieger-de.nix

            inputs.agenix.nixosModules.default
          ];
        };
        "hedwig" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = inputs;
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/minimal
            ./hosts/nixos
            ./hosts/nixos/hedwig/configuration.nix
            ./services/nginx.nix
            ./services/up-sonnenhof-zieger-de.nix

            simple-nixos-mailserver.nixosModule
            ./services/mail-think-in-sync-com.nix

            inputs.agenix.nixosModules.default
          ];
        };
        "blausieb" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";

          specialArgs = inputs;
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/common
            ./hosts/nixos
            ./hosts/nixos/blausieb/configuration.nix
            ./services/nginx.nix
            ./services/docker.nix
            ./services/blog-felixzieger-de.nix
            ./services/app-getdocsy-com.nix
            ./services/plausible-sonnenhof-zieger-de
            ./services/bitwarden-sonnenhof-zieger-de.nix
            ./services/paperless-sonnenhof-zieger-de.nix
            ./services/tailscale.nix
            ./services/nostr-felixzieger-de.nix
            inputs.agenix.nixosModules.default
          ];
        };
        "schenkerpad" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = inputs;
          modules = [
            home-manager.nixosModules.home-manager
            ./hosts/common
            ./hosts/schenkerpad
            ./hosts/schenkerpad/configuration.nix
          ];
        };
      };
      darwinConfigurations = {
        "macbook" = nix-darwin.lib.darwinSystem {
          system = "x86_64-darwin";

          specialArgs = inputs;
          modules = [
            ./hosts/common
            ./hosts/macbook
            home-manager.darwinModules.home-manager
            mac-app-util.darwinModules.default
            inputs.agenix.nixosModules.default
          ];
        };
      };
    };
}
