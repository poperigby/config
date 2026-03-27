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
        den.url = "github:vic/den";
        flake-file.url = "github:vic/flake-file";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        private-config.url = "git+ssh://git@codeberg.org/PopeRigby/private-config.git";
    };
}
