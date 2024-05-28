{ config, lib, ... }:

let
    cfg = config.poperigby.suites.gui;
in
{
    options.poperigby.suites.gui = {
        enable = lib.mkEnableOption "Enable GUI";
        adaptiveSync = lib.mkEnableOption "Enable adaptive sync (FreeSync)";
    };

    config = lib.mkIf cfg.enable {
        poperigby = {
            desktop.sway = {
                enable = true;
                adaptiveSync = cfg.adaptiveSync;
            };
            programs = {
                firefox.enable = true;
                imv.enable = true;
                rofi.enable = true;
                waybar.enable = true;
                wezterm.enable = true;
            };
            services = {
                flameshot.enable = true;
                gammastep.enable = true;
                swaync.enable = true;
                udiskie.enable = true;
            };
        };
    };
}
