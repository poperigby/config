{ config, lib, pkgs, ... }:

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
                imv = {
                    enable = true;
                    default = true;
                };
                rofi.enable = true;
                swaylock.enable = true;
                thunderbird.enable = true;
                waybar.enable = true;
                wezterm.enable = true;
            };
            services = {
                cliphist.enable = true;
                flameshot.enable = true;
                gammastep.enable = true;
                swaync.enable = true;
                udiskie.enable = true;
            };
        };

        # Packages that don't need any configuration
        home.packages = with pkgs; [
            element-desktop
            vesktop
            pwvucontrol
        ];

        xdg.portal = {
            enable = true;
            # Fallback portal
            extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        };
    };
}
