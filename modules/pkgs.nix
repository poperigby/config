# Wire local custom packages into `pkgs.custom.*` for both NixOS and Home Manager.
{ den, ... }:
let
    overlay = final: prev: {
        lib = prev.lib // {
            custom = import ../lib/create-shell-script { lib = prev.lib; };
        };

        custom =
            let
                packagesDir = ../packages;
                packageEntries = builtins.readDir packagesDir;

                packageFileFor =
                    name:
                    let
                        dir = packagesDir + "/${name}";
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
in
{
    den.default = {
        nixos.nixpkgs.overlays = [ overlay ];
        homeManager.nixpkgs.overlays = [ overlay ];
    };
}
