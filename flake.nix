{
  description = "Felix's NixOS and Darwin Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-bitcoin = {
      url = "github:fort-nix/nix-bitcoin/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.05";
      inputs.nixpkgs-25_05.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Darwin inputs
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    mac-app-util.url = "github:hraban/mac-app-util"; # https://discourse.nixos.org/t/mac-applications-installed-by-nix-are-not-loaded-by-spotlight/14129/16
    mac-app-util.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # Setup see https://github.com/zhaofengli/nix-homebrew
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    nix-search-tui.url = "github:misaelaguayo/nix-search-tui";
    nix-search-tui.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      nixpkgs-darwin,
      nix-darwin,
      nixpkgs-unstable,
      mac-app-util,
      nix-bitcoin,
      simple-nixos-mailserver,
      nix-homebrew,
      nix-search-tui,
      ...
    }:
    let
      # Overlay for custom packages
      customPackages = final: prev: {
        context-creator = final.callPackage ./packages/context-creator.nix { };
      };
    in
    {
      nixosConfigurations = {
        "schwalbe" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = inputs;
          modules = [
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ customPackages ];
              }
            )
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
            ./services/note-to-quote.nix
            inputs.agenix.nixosModules.default

          ];
        };
        "hedwig" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = inputs;
          modules = [
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ customPackages ];
              }
            )
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
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ customPackages ];
              }
            )
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
            ./services/twenty-getdocsy-com.nix
            ./services/paperless-sonnenhof-zieger-de.nix
            ./services/readeck-felixzieger-de.nix
            ./services/tailscale.nix
            ./services/nostr-felixzieger-de.nix
            ./services/strfry-felixzieger-de.nix
            ./services/waha.nix
            inputs.agenix.nixosModules.default
          ];
        };
        "schenkerpad" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = inputs;
          modules = [
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ customPackages ];
              }
            )
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
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ customPackages ];
              }
            )
            ./hosts/common
            ./hosts/macbook
            home-manager.darwinModules.home-manager
            mac-app-util.darwinModules.default
            inputs.agenix.nixosModules.default
            nix-homebrew.darwinModules.nix-homebrew
          ];
        };
      };

      # Custom packages
      packages = {
        x86_64-linux =
          let
            pkgs = import nixpkgs {
              system = "x86_64-linux";
              overlays = [ customPackages ];
            };
          in
          {
            # inherit (pkgs) claude-code;
            inherit (pkgs) context-creator;
          };

        x86_64-darwin =
          let
            pkgs = import nixpkgs-darwin {
              system = "x86_64-darwin";
              overlays = [ customPackages ];
            };
          in
          {
            # inherit (pkgs) claude-code;
            inherit (pkgs) context-creator;
          };

        aarch64-linux =
          let
            pkgs = import nixpkgs {
              system = "aarch64-linux";
              overlays = [ customPackages ];
            };
          in
          {
            # inherit (pkgs) claude-code;
            inherit (pkgs) context-creator;
          };

        aarch64-darwin =
          let
            pkgs = import nixpkgs-darwin {
              system = "aarch64-darwin";
              overlays = [ customPackages ];
            };
          in
          {
            # inherit (pkgs) claude-code;
            inherit (pkgs) context-creator;
          };
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      formatter.x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.nixfmt-rfc-style;
    };
}
