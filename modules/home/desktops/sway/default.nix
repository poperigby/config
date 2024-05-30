{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.desktops.sway;
in
{
    options.poperigby.desktops.sway = {
        enable = lib.mkEnableOption "Enable Sway window manager";
        adaptiveSync = lib.mkEnableOption "Enable adaptive sync (FreeSync)";
        wallpaper = lib.mkOption {
            type = with lib.types; nullOr path;
            default = null;
            description = "The path to a wallpaper you want to use.";
        };
    };

    config = lib.mkIf cfg.enable {
        wayland.windowManager.sway = {
            enable = true;
            package = pkgs.swayfx;
            config = {
                input = {
                    "type:keyboard" = {
                        # Rebind Caps Lock to Super key (Mod4)
                        xkb_options = "caps:super";
                    };
                };
                output = {
                    "*" = {
                        adaptive_sync = lib.mkIf cfg.adaptiveSync "on";
                        bg = lib.mkIf (cfg.wallpaper != null) "${cfg.wallpaper} fill";
                    };
                };
                modifier = "Mod4";
                menu = "${pkgs.rofi-wayland}/bin/rofi";
                terminal = "${pkgs.wezterm}/bin/wezterm";
                keybindings = with config.wayland.windowManager.sway.config; lib.mkOptionDefault {
                    ## Basics
                    # Kill focused window
                    "${modifier}+q" = "kill";

                    ## Applications
                    # Application launcher
                    "${modifier}+Space" = "exec ${menu} -show run";
                    # Terminal
                    "${modifier}+Return" = "exec ${terminal}";
                    # Browser
                    "${modifier}+n" = "exec ${pkgs.firefox}/bin/firefox";
                };
                defaultWorkspace = "workspace number 1";
                # We'll just use systemd to start Waybar
                bars = [];
            };
            # SwayFX settings will have to go here
            extraConfig = ''
                corner_radius = 1;
            '';
            systemd.enable = true;
        };
    };
}
