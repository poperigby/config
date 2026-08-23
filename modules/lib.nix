# Exposes helpers from <root>/lib as lib.local in NixOS and Home Manager modules.
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
