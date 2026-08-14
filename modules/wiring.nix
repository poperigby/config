# Wires together flake by importing Den modules and local packages and overlays.
{ inputs, lib, ... }:
let
    packageOverlay = final: prev: {
        local = lib.filesystem.packagesFromDirectoryRecursive {
            callPackage = lib.callPackageWith (prev // { inherit inputs; });
            directory = ../pkgs;
        };
    };
    localOverlays =
        let
            overlaysDir = ../overlays;
            overlayEntries = builtins.readDir overlaysDir;

            overlayFileFor =
                name:
                let
                    entryType = overlayEntries.${name};
                    path = overlaysDir + "/${name}";
                in
                if entryType == "regular" && builtins.match ".*\\.nix" name != null then
                    path
                else if entryType == "directory" && builtins.pathExists (path + "/default.nix") then
                    path + "/default.nix"
                else
                    null;

            overlayNames = builtins.filter (name: overlayFileFor name != null) (
                builtins.attrNames overlayEntries
            );
        in
        map (name: import (overlayFileFor name)) overlayNames;
in
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
        nixpkgs-lib.follows = "nixpkgs";

        flake-parts = {
            url = "github:hercules-ci/flake-parts";
            inputs.nixpkgs-lib.follows = "nixpkgs-lib";
        };

        import-tree.url = "github:vic/import-tree";

        flake-file.url = "github:vic/flake-file";
        den.url = "github:vic/den";

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    den.default = {
        nixos.nixpkgs.overlays = [ packageOverlay ] ++ localOverlays;
        homeManager.nixpkgs.overlays = [ packageOverlay ] ++ localOverlays;
    };

    # Expose local packages in flake outputs
    flake.packages = lib.genAttrs lib.systems.flakeExposed (
        system:
        let
            pkgs = import inputs.nixpkgs {
                inherit system;
                overlays = [ packageOverlay ] ++ localOverlays;
                config.allowUnfree = true;
            };
        in
        lib.filterAttrs (_: lib.isDerivation) pkgs.local
    );

}
