# Exposes helpers from <root>/lib as lib.local in NixOS and Home Manager modules.
{
    inputs,
    lib,
    ...
}:
let
    localLibDir = ../lib;

    # Load lib/foo.nix and lib/foo/default.nix as lib.local.foo. Function
    # helpers receive inputs, the extended lib, and sibling local helpers.
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

            entryFor =
                name:
                let
                    entryType = entries.${name};
                    path = localLibDir + "/${name}";
                in
                if entryType == "regular" && lib.hasSuffix ".nix" name && name != "default.nix" then
                    {
                        name = lib.removeSuffix ".nix" name;
                        value = callLocalLib localLib path;
                    }
                else if entryType == "directory" && builtins.pathExists (path + "/default.nix") then
                    {
                        inherit name;
                        value = callLocalLib localLib (path + "/default.nix");
                    }
                else
                    null;

            entries' = builtins.filter (entry: entry != null) (map entryFor (builtins.attrNames entries));
            names = map (entry: entry.name) entries';
        in
        if builtins.length names != builtins.length (lib.unique names) then
            throw "lib.local has duplicate entries; use either <name>.nix or <name>/default.nix"
        else
            builtins.listToAttrs entries';

    nixosLib = lib // {
        local = localLib;
    };

    # Home Manager modules expect lib.hm to exist, so build from Home Manager's
    # extended stdlib and keep the repository helpers attached.
    homeManagerLib = (import (inputs.home-manager + "/modules/lib/stdlib-extended.nix") nixosLib) // {
        local = localLib;
    };

    # The module system gets its lib argument from specialArgs at instantiation.
    localNixosSystem =
        args:
        inputs.nixpkgs.lib.nixosSystem (
            args
            // {
                specialArgs = (args.specialArgs or { }) // {
                    lib = nixosLib;
                };
            }
        );

    localHomeManagerConfiguration =
        args:
        inputs.home-manager.lib.homeManagerConfiguration (
            args
            // {
                extraSpecialArgs = (args.extraSpecialArgs or { }) // {
                    lib = homeManagerLib;
                };
            }
        );
in
{
    den.default.nixos =
        {
            host ? null,
            ...
        }:
        lib.optionalAttrs (host != null && (host."home-manager".enable or false)) {
            home-manager.extraSpecialArgs.lib = homeManagerLib;
        };

    # Den host/home entities expose instantiate; setting defaults here keeps
    # explicit custom instantiators, like Nestor's Raspberry Pi builder, intact.
    den.schema.host.imports = [
        (
            { config, lib, ... }:
            lib.mkIf (config.class == "nixos") {
                instantiate = lib.mkDefault localNixosSystem;
            }
        )
    ];

    den.schema.home.imports = [
        (
            { config, lib, ... }:
            lib.mkIf (config.class == "homeManager") {
                instantiate = lib.mkDefault localHomeManagerConfiguration;
            }
        )
    ];

    flake.lib.local = localLib;
}
