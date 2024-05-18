# Adjusts screen gamma based on time of day
{ config, lib, ... }:

let
    cfg = config.poperigby.services.gammastep;
in
{
    options.poperigby.services.gammastep.enable = lib.mkEnableOption "Enable GammaStep";

    config = lib.mkIf cfg.enable {
        services.gammastep = {
            enable = true;
            # Location provider
            provider = "geoclue2";
        };
    };
}
