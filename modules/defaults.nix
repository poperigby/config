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

    privateInfo = inputs.private-config.privateInfo;

    # Local library definitions
    localLib = config.flake.lib.local;
    nixosLib = lib // {
        local = localLib;
    };
    homeLib = (import "${inputs.home-manager}/modules/lib/stdlib-extended.nix" nixosLib) // {
        local = localLib;
    };
in
{
    flake-file.inputs = {
        disko.url = "github:nix-community/disko";
        private-config.url = "git+ssh://git@codeberg.org/PopeRigby/private-config.git?ref=trunk";
        ucodenix.url = "github:e-tho/ucodenix";
    };

    den = {
        default = {
            includes = [
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
                        inputs.private-config.nixosModules.default
                        inputs.ucodenix.nixosModules.default
                    ];

                    _module.args = {
                        inherit inputs privateInfo;
                    };

                    nixpkgs.config.allowUnfree = true;

                    system.stateVersion = mkDefault stateVersion;
                }
                # Wire in local library to home-manager through an argument.
                # Only applies to hosts that have home-manager enabled.
                // optionalAttrs (host."home-manager".enable or false) {
                    home-manager.extraSpecialArgs.lib = homeLib;
                };

            homeManager =
                { ... }:
                {
                    imports = [
                        inputs.private-config.homeModules.default
                    ];

                    _module.args = {
                        inherit inputs privateInfo;
                    };

                    nixpkgs.config.allowUnfree = true;

                    home.stateVersion = mkDefault stateVersion;
                };

        };
        schema = {
            host.imports = [
                (
                    { config, ... }:
                    mkIf (config.class == "nixos") {
                        instantiate = mkDefault (
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
                            inputs.nixpkgs-patcher.lib.nixosSystem (args // { inherit specialArgs; })
                        );
                    }
                )
            ];

            # Add Den's Home Manager class to users by default, so each user gets a
            # Home Manager module evaluation in addition to their NixOS user config.
            user.classes = mkDefault [ "homeManager" ];
        };
    };
}
