{ config, lib, ... }:

let
    cfg = config.poperigby.suites.desktop;
in
{
    options.poperigby.suites.desktop.enable = lib.mkEnableOption "Enable desktop GUI";

    config = lib.mkIf cfg.enable {
        wayland.windowManager.sway = {
            enable = true;
        };

        poperigby = {
            programs = {
                firefox.enable = true;
                rofi.enable = true;
                waybar.enable = true;
                wezterm.enable = true;
            };
            services = {
                dunst.enable = true;
                flameshot.enable = true;
                gammastep.enable = true;
            };
        };
    };
}
