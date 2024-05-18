{ config, lib, ... }:

let
    cfg = config.poperigby.services.flameshot;
in
{
    options.poperigby.services.flameshot.enable = lib.mkEnableOption "Enable Flameshot screenshot tool";

    config = lib.mkIf cfg.enable {
        services.flameshot = {
            enable = true;
            settings = {
                General = {
                    disabledTrayIcon = true;
                };
            };
        };
    };
}
