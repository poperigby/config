# Global settings
{ lib, den, ... }:
let
    stateVersion = "25.11";
in
{
    den.default = {
        includes = [ inputs.private-config.den.aspects.secrets ];

        nixos.system.stateVersion = stateVersion;
        homeManager.home.stateVersion = stateVersion;

    };

    # Enable home-manager by default
    den.schema.user.classes = lib.mkDefault [ "homeManager" ];

    # host<->user provides
    den.ctx.user.includes = [ den._.mutual-provider ];
}
