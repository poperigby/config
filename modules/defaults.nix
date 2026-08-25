# Shared Den, schema, and instantiator defaults

{
    config,
    inputs,
    lib,
    den,
    ...
}:
let
    inherit (lib) mkDefault mkIf optionalAttrs;

    stateVersion = "25.11";

    localLib = config.flake.lib.local;
    nixosLib = lib // {
        local = localLib;
    };
    homeManagerLib = (import (inputs.home-manager + "/modules/lib/stdlib-extended.nix") nixosLib) // {
        local = localLib;
    };

    localNixosSystem =
        args:
        let
            # Den provides host-specific nixosSystem arguments. Preserve any extra
            # specialArgs, then add the repo-wide inputs and extended lib.
            specialArgs =
                (args.specialArgs or { })
                // inputs
                // {
                    lib = nixosLib;
                };
        in
        inputs.nixpkgs-patcher.lib.nixosSystem (args // { inherit specialArgs; });
in
{
    flake-file.inputs = {
        disko.url = "github:nix-community/disko";
        ucodenix.url = "github:e-tho/ucodenix";
    };

    den = {
        default = {
            includes = [
                den.aspects.sops

                # Batteries: https://den.denful.dev/guides/batteries
                den.batteries.define-user
                den.batteries.hostname
                den.batteries.inputs'
            ];

            nixos =
                {
                    host ? { },
                    ...
                }:
                {
                    imports = [
                        inputs.disko.nixosModules.disko
                        inputs.ucodenix.nixosModules.default
                    ];

                    # Some legacy NixOS modules still expect the full `inputs` set.
                    _module.args.inputs = inputs;

                    nixpkgs.config.allowUnfree = true;

                    system.stateVersion = mkDefault stateVersion;
                }
                # Wire in local library to home-manager through an argument.
                # Only applies to hosts that have home-manager enabled.
                // optionalAttrs (host."home-manager".enable or false) {
                    home-manager.extraSpecialArgs.lib = homeManagerLib;
                };

            homeManager =
                { ... }:
                {
                    # Some legacy HM modules still expect the full `inputs` set.
                    _module.args.inputs = inputs;

                    nixpkgs.config.allowUnfree = true;

                    home.stateVersion = mkDefault stateVersion;
                };

        };
        schema = {
            host.imports = [
                (
                    { config, ... }:
                    mkIf (config.class == "nixos") {
                        instantiate = mkDefault localNixosSystem;
                    }
                )
            ];

            # Enable home-manager for all hosts
            user.classes = mkDefault [ "homeManager" ];
        };
    };
}
