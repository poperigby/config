{ config, lib, ... }:

let
    cfg = config.poperigby.programs.waybar;
in
{
    options.poperigby.programs.waybar.enable = lib.mkEnableOption "Enable Waybar";

    config = lib.mkIf cfg.enable {
        programs.waybar = {
            enable = true;
            # Enable systemd integration
            systemd.enable = true;
            settings.mainBar = {
                layer = "top";
                position = "top";
                height = 30;
            };
        };
    };
}
