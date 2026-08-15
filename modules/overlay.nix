# Provides pkgs.local and applies repository overlays.
{ inputs, lib, ... }:
let
    # Expose every package under <root>/pkgs as pkgs.local.<name>.
    packageOverlay = final: prev: {
        local = lib.filesystem.packagesFromDirectoryRecursive {
            callPackage = lib.callPackageWith (prev // { inherit inputs; });
            directory = ../pkgs;
        };
    };

    # Repository overlays live under <root>/overlays as either foo.nix or
    # foo/default.nix. Each file must evaluate to a normal Nixpkgs overlay.
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

    overlays = [ packageOverlay ] ++ localOverlays;
in
{
    den.default = {
        # Den applies these defaults to both NixOS and Home Manager evaluations,
        # so pkgs.local is available from either module system.
        nixos.nixpkgs.overlays = overlays;
        homeManager.nixpkgs.overlays = overlays;
    };

    # pkgs.local can hold pkgs-scoped helpers alongside packages. Flake package
    # outputs must stay derivations so `nix flake show` and `nix build` see a
    # valid package set.
    flake.packages = lib.genAttrs lib.systems.flakeExposed (
        system:
        let
            pkgs = import inputs.nixpkgs {
                inherit system overlays;
                config.allowUnfree = true;
            };
        in
        lib.filterAttrs (_: lib.isDerivation) pkgs.local
    );
}
