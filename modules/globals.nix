# Global settings
{
    inputs,
    lib,
    den,
    ...
}:
let
    stateVersion = "25.11";
in
{
    flake-file.inputs = {
        disko.url = "github:nix-community/disko";
        ucodenix.url = "github:e-tho/ucodenix";
    };

    den.default = {
        includes = [
            den.aspects.sops
            den._.hostname
            den._.inputs'
        ];

        nixos =
            { pkgs, ... }:
            {
                imports = [
                    inputs.disko.nixosModules.disko
                    inputs.ucodenix.nixosModules.default
                ];

                # Some legacy NixOS modules still expect the full `inputs` set.
                _module.args.inputs = inputs;
                _module.args.system = pkgs.stdenv.hostPlatform.system;

                nixpkgs.config.allowUnfree = true;
                system.stateVersion = lib.mkDefault stateVersion;
            };

        homeManager =
            { pkgs, ... }:
            {
                # Some legacy HM modules still expect the full `inputs` set.
                _module.args.inputs = inputs;
                _module.args.system = pkgs.stdenv.hostPlatform.system;

                nixpkgs.config.allowUnfree = true;
                home.stateVersion = lib.mkDefault stateVersion;
            };

    };

    # Enable home-manager by default
    den.schema.user.classes = lib.mkDefault [ "homeManager" ];

    # host<->user provides
    den.ctx.user.includes = [ den._.mutual-provider ];
}
