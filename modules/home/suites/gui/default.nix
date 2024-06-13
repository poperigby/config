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
            desktops.sway.enable = true;
            programs = {
                element-desktop.enable = true;
                firefox.enable = true;
                mpv.enable = true;
                rofi.enable = true;
                swaylock.enable = true;
                thunderbird.enable = true;
                vesktop.enable = true;
                waybar.enable = true;
                wezterm.enable = true;
                zathura.enable = true;
                imv = {
                    enable = true;
                    default = true;
                };
            };
            services = {
                clipboard.enable = true;
                gammastep.enable = true;
                swaync.enable = true;
                udiskie.enable = true;
            };
        };

        # Packages that don't need any configuration
        home.packages = with pkgs; [
            gnome.nautilus
            grim
            onlyoffice-bin
            pwvucontrol
            satty
            slurp
        ];

        xdg.portal = {
            enable = true;
            # Fallback portal
            config.common.default = "gtk";
            extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        };

        # Theming
        home.pointerCursor = {
            name = "Adwaita";
            package = pkgs.gnome.adwaita-icon-theme;
            size = 24;
            gtk.enable = true;
        };

        gtk = {
            enable = true;
            theme = {
                name = "adw-gtk3-dark";
                package = pkgs.adw-gtk3;
            };
            gtk4.extraCss = builtins.readFile ./gtk.css;
            gtk3.extraCss = builtins.readFile ./gtk.css;
        };

        dconf.settings = {
            # Get rid of GTK titlebar buttons
            "org/gnome/desktop/wm/preferences".button-layout = ":";
            "org/blueman/general".plugin-list = [
                # Disable annoying Blueman plugins
                "!ConnectionNotifier"
                "!StatusNotifierItem"
            ];
        };
    };
}
