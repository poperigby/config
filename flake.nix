{
    description = "My NixOS flake";

    # Inputs for building the NixOS system, such as software repositories.
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        sops-nix.url = "github:Mic92/sops-nix";
        nixos-hardware.url = "github:NixOS/nixos-hardware/master";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        disko = {
            url = "github:nix-community/disko";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nh = {
            url = "github:viperML/nh";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    # This function is run on `nixos-rebuild switch`, and generates NixOS systems
    # based on the `inputs` attribute set, and any `modules` specified.
    outputs = inputs@{ self, disko, nixpkgs, nixos-hardware, ... }: {
        nixosConfigurations = {
            # Installation/recovery ISO
            iso = nixpkgs.lib.nixosSystem {
                modules = [
                    "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                    "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
                    ./hosts/iso
                ];
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
            };
            # Home server
            haddock = nixpkgs.lib.nixosSystem {
                modules = [
                    disko.nixosModules.disko
                    ./hosts/haddock
                ];
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
            };
            # Laptop
            allan = nixpkgs.lib.nixosSystem {
                modules = [
                    disko.nixosModules.disko
                    nixos-hardware.nixosModules.framework-11th-gen-intel
                    ./hosts/allan
                ];
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
            };
        };
    };
}
