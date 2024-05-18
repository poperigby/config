# Screenshot tool
{ config, lib, ... }:

let
    cfg = config.common.home.gui.flameshot;
in
{
    options.common.home.gui.flameshot.enable = lib.mkEnableOption "Enable Flameshot screenshot tool";

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
