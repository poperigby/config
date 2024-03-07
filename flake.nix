{
  description = "My NixOS flake";

  # Inputs for building the NixOS system, such as software respositories.
  inputs = {
    nixpkgs = {
        url = "github:NixOS/nixpkgs/nixos-23.11";
    };
    nh = {
        url = "github:viperML/nh";
        inputs.nixpkgs.follows = "nixpkgs"; # override this repo's nixpkgs snapshot
    };
  };

  # This function is run on `nixos-rebuild switch`, and generates a 
  # NixOS system based on the `inputs` attribute set (which in this 
  # case contains the nixpkgs repository), and any `modules` specified.
  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations.haddock = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
      ];
    };
  };
}
