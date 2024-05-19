{ config, lib, ... }:

let
    cfg = config.poperigby.suites.desktop;
in
{
    options.poperigby.suites.desktop.enable = lib.mkEnableOption "Enable desktop GUI";

    config = lib.mkIf cfg.enable {
        poperigby = {
            desktop.sway.enable = true;
            programs = {
                firefox.enable = true;
                rofi.enable = true;
                waybar.enable = true;
                wezterm.enable = true;
            };
            services = {
                flameshot.enable = true;
                gammastep.enable = true;
                swaync.enable = true;
            };
        };
    };
}
