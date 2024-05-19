{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.programs.bat;
in
{
    options.poperigby.desktop.sway.enable = lib.mkEnableOption "Enable Sway window manager";

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
                modifier = "Mod4";
                menu = "${pkgs.rofi-wayland}/bin/rofi -show run";
                terminal = "${pkgs.wezterm}/bin/wezterm";
                keybindings = let
                    menu = config.wayland.windowManager.sway.config.menu;
                    mod = config.wayland.windowManager.sway.config.modifier;
                    term = config.wayland.windowManager.sway.config.terminal;
                in lib.mkOptionDefault {
                    ## Applications
                    # Application launcher
                    "${mod}+Space" = "exec ${menu}";
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
