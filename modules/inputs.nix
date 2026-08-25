# Baseline flake inputs and framework imports.
#
# Feature-specific inputs should be declared in the module that uses them
# (flake-file will merge them into flake.nix).
#
# Run `nix run .#write-flake` to regenerate flake.nix after changing inputs.

{ inputs, ... }:

{
    imports = [
        (inputs.flake-file.flakeModules.dendritic or { })
        (inputs.den.flakeModules.dendritic or { })
    ];

    flake-file.inputs = {
        nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
        nixpkgs-multiverse.url = "github:fzakaria/nixpkgs-multiverse";
        nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";

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
