{ config, inputs, lib, pkgs, ... }:

let
    cfg = config.poperigby.desktops.sway;
    colors = config.colorScheme.palette;
    fonts = config.fonts.fontconfig.defaultFonts;
    gui = config.poperigby.suites.gui;
    sway = config.wayland.windowManager.sway;
in
{
    options.poperigby.desktops.sway.enable = lib.mkEnableOption "Enable Sway window manager";

    imports = [ inputs.nix-colors.homeManagerModules.default ];

    config = lib.mkIf cfg.enable {
        wayland.windowManager.sway = {
            enable = true;
            # Integrates Sway with systemd, which will allow applications to depend on it
            # by depending on "graphical.target".
            systemd.enable = true;
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
                        adaptive_sync = lib.mkIf gui.adaptiveSync "on";
                        mode = "${gui.resolution}@${builtins.toString gui.refreshRate}Hz";
                        bg = lib.mkIf (gui.wallpaper != null) "${gui.wallpaper} fill";
                    };
                };
                fonts = {
                   names = fonts.sansSerif;
                   style = "normal";
                   size = 11.0;
                };
                modifier = "Mod4";
                menu = "${pkgs.rofi-wayland}/bin/rofi";
                terminal = "${pkgs.wezterm}/bin/wezterm";
                keybindings = let
                    browser = "${pkgs.firefox}/bin/firefox";
                    # We need to use this version to use our plugins
                    menu = "${config.programs.rofi.finalPackage}/bin/rofi";
                    mod = sway.config.modifier;
                    term = sway.config.terminal;
                in lib.mkOptionDefault {
                    ## Basics
                    # Kill focused window
                    "${mod}+q" = "kill";
                    # Swap focus between the tiling area and the floating area
                    "${mod}+d" = "focus mode_toggle";
                    # Toggle the current focus between tiling and floating mode
                    "${mod}+Shift+d" = "floating toggle";

                    # TODO: Make Meta+Alt+{h,j,k,l} move windows between workspaces

                    ## Applications
                    # Application launcher
                    "${mod}+space" = "exec ${menu} -show drun -show-icons";
                    # Terminal
                    "${mod}+Return" = "exec ${term}";
                    # File manager
                    "${mod}+e" = "exec ${term} start ${pkgs.yazi}/bin/yazi";
                    # Browser
                    "${mod}+n" = "exec ${browser}";

                    ## Pickers
                    # Emoji
                    "${mod}+period" = "exec ${menu} -modi emoji -show emoji";
                    # Clipboard history
                    "${mod}+slash" = ''
                        exec ${menu} -modi clipboard:${pkgs.poperigby.cliphist-rofi-img}/bin/cliphist-rofi-img -show clipboard -show-icons
                    '';
                };
                defaultWorkspace = "workspace number 1";
                # Floating window rules
                floating = {
                    titlebar = true;
                    # Windows to make floating
                    criteria = [
                        {
                            # Steam friends
                            title = "Friends List";
                        }
                        {
                            title = "Steam Settings";
                        }
                        {
                            title = "Create or select new Steam library folder";
                        }
                    ];
                };
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
                        background = "#${colors.base08}";
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
        };

        # Start sway if we open a login shell on TTY1
        programs.bash.profileExtra = ''
            if [ "$(tty)" = "/dev/tty1" ]; then
                exec sway
            fi
        '';

        xdg.portal = {
            config.common.default = "wlr";
            extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
        };
    };
}
