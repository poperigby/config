# Flake wiring
{ inputs, ... }:
{
    imports = [
        (inputs.flake-file.flakeModules.dendritic or { })
        (inputs.den.flakeModules.dendritic or { })
    ];

    # Minimum necessary inputs. Other flake inputs should be defined
    # in the aspect where they are needed.
    #
    # Run `nix run .#write-flake` to regenerate the flake.nix
    flake-file.inputs = {
        cosmic-manager = {
            url = "github:HeitorAugustoLN/cosmic-manager";
            inputs = {
                nixpkgs.follows = "nixpkgs";
                home-manager.follows = "home-manager";
            };
        };
        den.url = "github:vic/den";
        flake-file.url = "github:vic/flake-file";
        flux = {
            url = "github:IogaMaster/flux";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        jj-starship.url = "github:dmmulroy/jj-starship";
        lanzaboote = {
            url = "github:nix-community/lanzaboote";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nix = {
            url = "github:NixOS/nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nix-colors.url = "github:misterio77/nix-colors";
        nix-index-database = {
            url = "github:nix-community/nix-index-database";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nix-minecraft = {
            url = "github:Infinidoge/nix-minecraft";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        nixcord.url = "github:kaylorben/nixcord";
        nix-flatpak.url = "github:gmodena/nix-flatpak";
        openmw-nix = {
            url = "git+https://codeberg.org/PopeRigby/openmw-nix.git";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        piggyback = {
            url = "git+https://codeberg.org/PopeRigby/piggyback.git";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        private-config.url = "git+ssh://git@codeberg.org/PopeRigby/private-config.git?ref=trunk";
        rustical.url = "github:poperigby/nixpkgs/rustical-module";
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        ucodenix = {
            url = "github:e-tho/ucodenix";
        };
        vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";
    };
}
