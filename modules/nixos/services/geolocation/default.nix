{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
        ;

    cfg = config.custom.services.geolocation;
in
{
    options.custom.services.geolocation.enable = mkEnableOption "automatic geolocation provider";

    config = mkIf cfg.enable {
        services.geoclue2 = {
            enable = true;
            geoProviderUrl = "https://beacondb.net/v1/geolocate";
        };
    };
}
