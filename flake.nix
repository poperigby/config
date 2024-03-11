{
    description = "My NixOS flake";

    # Inputs for building the NixOS system, such as software repositories.
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        manix.url = "github:nix-community/manix";
        sops-nix.url = "github:Mic92/sops-nix";
        nh = {
            url = "github:viperML/nh";
            inputs.nixpkgs.follows = "nixpkgs"; # override this repo's nixpkgs snapshot
        };
    };

    # This function is run on `nixos-rebuild switch`, and generates NixOS systems
    # based on the `inputs` attribute set, and any `modules` specified.
    outputs = inputs@{ self, nixpkgs, ... }: {
        nixosConfigurations = {
            haddock = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = { inherit inputs; };
                modules = [
                    ./hosts/haddock
                ];
            };
        };
    };
}
