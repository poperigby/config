# Wire local custom packages and overlays into NixOS, Home Manager, and flake outputs.
{
    inputs,
    lib,
    ...
}:
let
    packageOverlay = final: prev: {
        custom = lib.filesystem.packagesFromDirectoryRecursive {
            callPackage = prev.callPackage;
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
    den.default = {
        nixos.nixpkgs.overlays = [ packageOverlay ] ++ localOverlays;
        homeManager.nixpkgs.overlays = [ packageOverlay ] ++ localOverlays;
    };

    # Expose custom packages in flake outputs
    flake.packages = lib.genAttrs lib.systems.flakeExposed (
        system:
        let
            pkgs = import inputs.nixpkgs {
                inherit system;
                overlays = [ packageOverlay ] ++ localOverlays;
                config.allowUnfree = true;
            };
        in
        pkgs.custom
    );
}
