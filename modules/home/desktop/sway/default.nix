{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.desktop.sway;
in
{
    options.poperigby.desktop.sway = {
        enable = lib.mkEnableOption "Enable Sway window manager";
        adaptiveSync = lib.mkEnableOption "Enable adaptive sync (FreeSync)";
    };

    config = lib.mkIf cfg.enable {
        wayland.windowManager.sway = {
            enable = true;
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
                    };
                };
                modifier = "Mod4";
                menu = "${pkgs.rofi-wayland}/bin/rofi";
                terminal = "${pkgs.wezterm}/bin/wezterm";
                keybindings = let
                    menu = config.wayland.windowManager.sway.config.menu;
                    mod = config.wayland.windowManager.sway.config.modifier;
                    term = config.wayland.windowManager.sway.config.terminal;
                in lib.mkOptionDefault {
                    ## Basics
                    # Kill focused window
                    "${mod}+q" = "kill";

                    ## Applications
                    # Application launcher
                    "${mod}+Space" = "exec ${menu} -show run";
                    # Terminal
                    "${mod}+Return" = "exec ${term}";
                    # Firefox
                    "${mod}+n" = "exec ${pkgs.firefox}/bin/firefox";
                };
                defaultWorkspace = "workspace number 1";
                # We'll just use systemd to start Waybar
                bars = [];
            };
            systemd.enable = true;
        };
    };
}
