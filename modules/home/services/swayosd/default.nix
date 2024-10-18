{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
    ;

    cfg = config.poperigby.services.swayosd;
in
{
    options.poperigby.services.swayosd.enable = mkEnableOption "SwayOSD";

    config = mkIf cfg.enable {
        services.swayosd = {
            enable = true;
        };
    };
}
