# Global settings
{ inputs, lib, den, ... }:
let
    stateVersion = "25.11";
    allowUnfreePredicate =
        pkg:
        let
            name = lib.getName pkg;
        in
        # Various parts of this config intentionally use unfree packages.
        (builtins.elem name [
            "epkowa"
            "graphite"
            "ouch"
        ])
        || lib.hasPrefix "iscan" name
        || lib.hasPrefix "steam" name;
in
{
    den.default = {
        includes = [
            den.aspects.sops
            den._.hostname
            den._.inputs'
        ];

        # Some legacy NixOS modules still expect the full `inputs` set.
        nixos._module.args.inputs = inputs;
        homeManager._module.args.inputs = inputs;

        nixos.nixpkgs.config.allowUnfreePredicate = allowUnfreePredicate;
        homeManager.nixpkgs.config.allowUnfreePredicate = allowUnfreePredicate;

        nixos.system.stateVersion = lib.mkDefault stateVersion;
        homeManager.home.stateVersion = lib.mkDefault stateVersion;

    };

    # Enable home-manager by default
    den.schema.user.classes = lib.mkDefault [ "homeManager" ];

    # host<->user provides
    den.ctx.user.includes = [ den._.mutual-provider ];
}
