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

    # Configuration shared between NixOS and Home Manager
    stateVersion = "26.11";
    moduleArgs = {
        inherit inputs;
        privateInfo = inputs.private-config.privateInfo;
    };
    nixpkgsDefaults = {
        config.allowUnfree = true;
        # We can use the overlay exposed by the flake in overlay.nix
        overlays = [ config.flake.overlays.default ];
    };

    # Extend the upstream libraries with local functions
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
        private-config = {
            url = "git+ssh://git@codeberg.org/PopeRigby/private-config.git?ref=trunk";
            inputs.sops-nix.follows = "sops-nix";
        };
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        ucodenix.url = "github:e-tho/ucodenix";
    };

    den = {
        # Hosts accept their users' nixos content, such as password secrets.
        schema.host.includes = [ den.batteries.user-aspects ];

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

                    _module.args = moduleArgs;
                    nixpkgs = nixpkgsDefaults;

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

                    _module.args = moduleArgs;
                    nixpkgs = nixpkgsDefaults;

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
                                denSpecialArgs = args.specialArgs or { };

                                # Extend Den's nixosSystem arguments with the merged local library
                                specialArgs = denSpecialArgs // {
                                    lib = nixosLib;
                                };

                                # Supply flake inputs to nixpkgs-patcher
                                nixpkgsPatcher = (args.nixpkgsPatcher or { }) // {
                                    inherit inputs;
                                };
                            in
                            inputs.nixpkgs-patcher.lib.nixosSystem (
                                args
                                // {
                                    inherit nixpkgsPatcher specialArgs;
                                }
                            )
                        );
                    }
                )
            ];

            # Add Den's Home Manager class to users by default, so each user gets a
            # Home Manager module evaluation in addition to their NixOS user configuration.
            user.classes = mkDefault [ "homeManager" ];
        };
    };
}
