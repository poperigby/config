{ config, lib, ... }:

let
    cfg = config.poperigby.programs.waybar;
in
{
    options.poperigby.programs.waybar.enable = lib.mkEnableOption "Enable Waybar";

    config = lib.mkIf cfg.enable {
        programs.waybar = {
            enable = true;
            settings.mainBar = {
                # Global
                layer = "top";
                position = "top";
                height = 30;
                modules-left = [
                    "sway/workspaces"
                    "sway/mode"
                ];
                modules-right = [
                    "wireplumber"
                    "memory"
                    "temperature"
                    "battery"
                    # "custom/weather"
                    "clock#date"
                    "clock#time"
                    "tray"
                ];
                # Modules
            };
            # style = ./style.css;
            # Enable systemd integration
            systemd.enable = true;
        };
    };
}
