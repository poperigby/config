{ config, lib, ... }:

let
    cfg = config.poperigby.suites.gui;
in
{
    options.poperigby.suites.gui = {
        enable = lib.mkEnableOption "Enable GUI";
        adaptiveSync = lib.mkEnableOption "Enable adaptive sync (FreeSync)";
        resolution = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "The resolution you want to use, in the form of <width>x<height>";
        };
        refreshRate = lib.mkOption {
            type = lib.types.int;
            default = 60;
            description = "The refresh rate you want to use";
        };
        wallpaper = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "The path to a wallpaper you want to use.";
        };
    };

    config = lib.mkIf cfg.enable {
        poperigby = {
            desktops.sway = {
                enable = true;
                resolution = cfg.resolution;
                refreshRate = cfg.refreshRate;
                adaptiveSync = cfg.adaptiveSync;
                wallpaper = cfg.wallpaper;
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
