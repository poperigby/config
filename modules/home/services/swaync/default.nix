{ config, lib, ... }:

let
    cfg = config.poperigby.services.swaync;
in
{
    options.poperigby.services.swaync.enable = lib.mkEnableOption "Enable Sway Notification Center";

    config = lib.mkIf cfg.enable {
        services.swaync = {
            enable = true;
        };
    };
}
