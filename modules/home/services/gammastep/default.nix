{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
    ;

    cfg = config.poperigby.services.gammastep;
in
{
    options.poperigby.services.gammastep.enable = mkEnableOption "Gammastep";

    config = mkIf cfg.enable {
        services.gammastep = {
            enable = true;
            temperature = {
                day = 6500;
                night = 4500;
            };
            # Location provider
            provider = "geoclue2";
        };
    };
}
