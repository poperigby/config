# Adjusts screen gamma based on time of day
{ config, lib, ... }:

let
    cfg = config.common.home.gui.gammastep;
in
{
    options.common.home.gui.gammastep.enable = lib.mkEnableOption "Enable GammaStep";

    config = lib.mkIf cfg.enable {
        services.gammastep = {
            enable = true;
            # Location provider
            provider = "geoclue2";
        };
    };
}
