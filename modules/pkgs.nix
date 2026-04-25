# Wire local custom packages and overlays into both NixOS and Home Manager.
{ ... }:
let
    packageOverlay = final: prev: {
        lib = prev.lib // {
            custom = import ../lib/create-shell-script { lib = prev.lib; };
        };

        custom =
            let
                pkgsDir = ../pkgs;
                packageEntries = builtins.readDir pkgsDir;

                packageFileFor =
                    name:
                    let
                        dir = pkgsDir + "/${name}";
                    in
                    if builtins.pathExists (dir + "/package.nix") then dir + "/package.nix" else dir;

                packageNames = prev.lib.filter (
                    name: packageEntries.${name} == "directory" && packageFileFor name != null
                ) (builtins.attrNames packageEntries);
            in
            builtins.listToAttrs (
                map (name: {
                    inherit name;
                    value = final.callPackage (packageFileFor name) { };
                }) packageNames
            );
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
}
