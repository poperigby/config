# Wires together flake-parts, flake-file, and Den.
{ inputs, ... }:
{
    imports = [
        (inputs.flake-file.flakeModules.dendritic or { })
        (inputs.den.flakeModules.dendritic or { })
    ];

    # Minimum necessary flake inputs. Feature-specific inputs should be declared
    # in the module that uses them (flake-file will merge them into flake.nix).
    #
    # Run `nix run .#write-flake` to regenerate flake.nix after changing inputs.
    flake-file.inputs = {
        nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
        nixpkgs-multiverse.url = "github:fzakaria/nixpkgs-multiverse";

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        den.url = "github:vic/den";

        flake-parts = {
            url = "github:hercules-ci/flake-parts";
            inputs.nixpkgs-lib.follows = "nixpkgs";
        };

        flake-file.url = "github:vic/flake-file";

        import-tree.url = "github:vic/import-tree";
    };
}
