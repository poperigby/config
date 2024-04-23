{
    description = "My NixOS flake";

    # Inputs for building the NixOS system, such as software repositories.
    inputs = {
        # Official inputs
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        # Extra inputs
        caligula = {
            url = "github:ifd3f/caligula";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        disko = {
            url = "github:nix-community/disko";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nh = {
            url = "github:viperML/nh";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nix-colors.url = "github:misterio77/nix-colors";
        nix-index-database = {
            url = "github:nix-community/nix-index-database";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixos-hardware.url = "github:NixOS/nixos-hardware/master";
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        stylix = {
            url = "github:danth/stylix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    # This function is run on `nixos-rebuild switch`, and generates NixOS systems
    # based on the `inputs` attribute set, and any `modules` specified.
    outputs = inputs@{ self, disko, home-manager, nixpkgs, nixos-hardware, ... }: {
        nixosConfigurations = {
            # Home server
            haddock = nixpkgs.lib.nixosSystem {
                modules = [
                    disko.nixosModules.disko
                    home-manager.nixosModules.default
                    ./systems/haddock
                ];
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
            };
            # Desktop
            snowy = nixpkgs.lib.nixosSystem {
                modules = [
                    disko.nixosModules.disko
                    home-manager.nixosModules.default
                    ./systems/snowy
                ];
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
            };
            # Laptop
            allan = nixpkgs.lib.nixosSystem {
                modules = [
                    nixos-hardware.nixosModules.framework-11th-gen-intel
                    disko.nixosModules.disko
                    home-manager.nixosModules.default
                    ./systems/allan
                ];
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
            };
            # Installation/recovery ISO
            iso = nixpkgs.lib.nixosSystem {
                modules = [
                    "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                    "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
                    ./systems/iso
                ];
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
            };
        };
    };
}
