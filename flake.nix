{
    description = "My NixOS flake";

    # Inputs for building the NixOS system, such as software repositories.
    inputs = {
        ## Official inputs
        # nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        ## Extra inputs
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
        nixos-generators = {
            url = "github:nix-community/nixos-generators";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nix-index-database = {
            url = "github:nix-community/nix-index-database";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixos-hardware.url = "github:NixOS/nixos-hardware/master";
        snowfall-lib = {
            url = "github:snowfallorg/lib";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    # This function is run on `nixos-rebuild switch`, and generates NixOS systems
    # based on the `inputs` attribute set, and any `modules` specified.
    outputs = inputs: inputs.snowfall-lib.mkFlake {
        inherit inputs;
        src = ./.;

        # A namespace to use for my flake's packages, library, and overlays.
        namespace = "poperigby";

        systems.hosts = {
            # Home server
            haddock = {
                modules = with inputs; [
                    disko.nixosModules.disko
                    home-manager.nixosModules.default
                ];
            };
            # Desktop
            snowy = {
                modules = with inputs; [
                    disko.nixosModules.disko
                    home-manager.nixosModules.default
                ];
            };
            # Laptop
            allan = {
                modules = with inputs; [
                    disko.nixosModules.disko
                    home-manager.nixosModules.default
                    nixos-hardware.nixosModules.framework-11th-gen-intel
                ];
            };
            # Installation/recovery ISO
            iso = {
                modules = with inputs; [
                    "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                    "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
                ];
            };
        };
    };
}
