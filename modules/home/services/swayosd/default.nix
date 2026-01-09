{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
        ;

    cfg = config.custom.services.swayosd;
in
{
    options.custom.services.swayosd.enable = mkEnableOption "SwayOSD";

    config = mkIf cfg.enable {
        services.swayosd = {
            enable = true;
        };
    };
}
