{ config, lib, pkgs, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
        mkOption
        readFile
    ;

    inherit (lib.types)
        int
        nullOr
        path
        str
    ;

    cfg = config.poperigby.suites.gui;
in
{
    options.poperigby.suites.gui = {
        enable = mkEnableOption "GUI";
        adaptiveSync = mkEnableOption "adaptive sync (FreeSync)";
        resolution = mkOption {
            type = str;
            default = "";
            description = "The resolution you want to use, in the form of <width>x<height>";
        };
        refreshRate = mkOption {
            type = int;
            default = 60;
            description = "The refresh rate you want to use";
        };
        wallpaper = mkOption {
            type = nullOr path;
            default = null;
            description = "The path to a wallpaper you want to use.";
        };
    };

    config = mkIf cfg.enable {
        poperigby = {
            desktops.sway.enable = true;
            programs = {
                discord.enable = true;
                element-desktop.enable = true;
                firefox.enable = true;
                mpv.enable = true;
                rofi.enable = true;
                swaylock.enable = true;
                thunderbird.enable = true;
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
            gimp
            grim
            nautilus
            onlyoffice-bin
            pwvucontrol
            satty
            slurp
            tor-browser
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
            package = pkgs.adwaita-icon-theme;
            size = 24;
            gtk.enable = true;
        };

        gtk = let
            css = readFile ./gtk.css;
        in {
            enable = true;
            theme = {
                name = "adw-gtk3-dark";
                package = pkgs.adw-gtk3;
            };
            gtk4.extraCss = css;
            gtk3.extraCss = css;
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
