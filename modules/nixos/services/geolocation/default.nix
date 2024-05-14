{ config, lib, ... }:

let
  cfg = config.poperigby.services.geolocation;
in
{
    options.poperigby.services.geolocation.enable = lib.mkEnableOption "Enable automatic geolocation provider";

    config = lib.mkIf cfg.enable {
        services.geoclue2.enable = true;
    };
}
