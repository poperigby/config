# Constructs a local library from entries in <root>/lib

{
    inputs,
    lib,
    ...
}:
let
    localLibDir = ../lib;

    # Load lib/foo.nix as lib.local.foo. Function helpers receive inputs, the
    # extended lib, and sibling local helpers.
    callLocalLib =
        localLib: path:
        let
            value = import path;
        in
        if builtins.isFunction value then
            lib.callPackageWith (
                {
                    inherit inputs;
                    lib = lib // {
                        local = localLib;
                    };
                }
                // localLib
            ) value { }
        else
            value;

    localLib =
        let
            entries = if builtins.pathExists localLibDir then builtins.readDir localLibDir else { };
            localFiles = lib.filterAttrs (
                name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
            ) entries;

            callLocalFile =
                name: _:
                lib.nameValuePair (lib.removeSuffix ".nix" name) (callLocalLib localLib (localLibDir + "/${name}"));
        in
        lib.mapAttrs' callLocalFile localFiles;
in
{
    flake.lib.local = localLib;
}
