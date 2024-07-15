{ lib, ... }:

{
    # Recursively constructs an attrset of a given folder, recursing on directories, value of attrs is the filetype
    getDir = dir: lib.mapAttrs (file: type:
        if type == "directory" then
            lib.poperigby.getDir "${dir}/${file}"
        else
            type
    ) (builtins.readDir dir);

    # Collects all files of a directory as a list of strings of paths
    getFiles = dir: lib.collect lib.isString (
        lib.mapAttrsRecursive (
            path: type: lib.concatStringsSep "/" path
        ) (lib.poperigby.getDir dir)
    );

    # Recursively get a list of valid Nix files in a directory
    getValidFiles = dir: lib.map (file: dir + "/${file}") (
        # Filters out directories that don't end with .nix or are this file, also makes the strings absolute
        lib.filter (
            file:
                lib.hasSuffix ".nix" file
                && file != "default.nix"
        ) (lib.poperigby.getFiles dir)
    );
}
