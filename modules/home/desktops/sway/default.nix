{ config, inputs, lib, pkgs, ... }:

let
    cfg = config.poperigby.desktops.sway;
    colors = config.colorScheme.palette;
in
{
    options.poperigby.desktops.sway = {
        enable = lib.mkEnableOption "Enable Sway window manager";
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
            type = with lib.types; nullOr path;
            default = null;
            description = "The path to a wallpaper you want to use.";
        };
    };

    imports = [ inputs.nix-colors.homeManagerModules.default ];

    config = lib.mkIf cfg.enable {
        wayland.windowManager.sway = {
            enable = true;
            package = pkgs.swayfx;
            # Required for SwayFX to work
            checkConfig = false;
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
                        mode = "${cfg.resolution}@${builtins.toString cfg.refreshRate}Hz";
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
                    # Swap focus between the tiling area and the floating area
                    "${modifier}+d" = "focus mode_toggle";
                    # Toggle the current focus between tiling and floating mode
                    "${modifier}+Shift+d" = "floating toggle";

                    ## Applications
                    # Application launcher
                    "${modifier}+space" = "exec ${menu} -show drun -show-icons";
                    # Terminal
                    "${modifier}+Return" = "exec ${terminal}";
                    # Browser
                    "${modifier}+n" = "exec ${pkgs.firefox}/bin/firefox";
                };
                defaultWorkspace = "workspace number 1";
                # We'll just use systemd to start Waybar
                bars = [];
                gaps.inner = 5;
                colors = {
                    background = "#${colors.base00}";
                    focused = rec {
                        background = "#${colors.base01}";
                        border = "#${colors.base01}";
                        childBorder = border;
                        indicator = "#${colors.base01}";
                        text = "#${colors.base07}";
                    };
                    focusedInactive = rec {
                        background = "#${colors.base00}";
                        border = "#${colors.base02}";
                        childBorder = border;
                        indicator = "#${colors.base02}";
                        text = "#${colors.base06}";
                    };
                    placeholder = {
                        background = "#${colors.base06}";
                        # Ignored
                        border = "#000000";
                        childBorder = "#${colors.base02}";
                        # Ignored
                        indicator = "#000000";
                        text = "#${colors.base07}";
                    };
                    unfocused = rec {
                        background = "#${colors.base00}";
                        border = "#${colors.base02}";
                        childBorder = border;
                        indicator = "#${colors.base02}";
                        text = "#${colors.base06}";
                    };
                    urgent = rec {
                        background = "#${colors.base0E}";
                        border = "#${colors.base06}";
                        childBorder = border;
                        indicator = "#${colors.base06}";
                        text = "#${colors.base07}";
                    };
                };
            };
            # SwayFX settings will have to go here
            extraConfig = ''
                corner_radius 10
            '';
            systemd.enable = true;
        };
    };
}
