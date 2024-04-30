{ config, lib, ... }:

let
    cfg = config.common.home.gui.waybar;
in
{
    options.common.home.gui.waybar.enable = lib.mkEnableOption "Enable Waybar";

    config = lib.mkIf cfg.enable {
        programs.waybar = {
            enable = true;
            # Enable systemd integration
            systemd.enable = true;
            settings.mainBar = {
                layer = "top";
                position = "top";
                height = 30;
                modules-left = [
                    "river/tags"
                ];
            };
        };
    };
}
