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
    den.default = {
        includes = [
            den.aspects.sops
            den._.hostname
            den._.inputs'
        ];

        nixos =
            { pkgs, ... }:
            {
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
