{
    config,
    lib,
    pkgs,
    ...
}:

let
    inherit (lib)
        getExe
        getExe'
        mkIf
        mkOptionDefault
        ;

    cfg = config.custom.desktops.sway;
    sway = config.wayland.windowManager.sway;
in
{
    config = mkIf cfg.enable {
        wayland.windowManager.sway.config.keybindings =
            let
                mod = sway.config.modifier;
                swaymsg = getExe' pkgs.sway "swaymsg";
                jq = getExe pkgs.jq;

                # We need to use this version to use our plugins
                menu = getExe config.programs.rofi.finalPackage;
                browser = getExe pkgs.firefox;
                term = sway.config.terminal;

                # Tools
                screenshot = getExe pkgs.custom.screenshot;
                swayosd = getExe' pkgs.swayosd "swayosd-client";
            in
            mkOptionDefault {
                ## Basics
                # Quit the focused window
                "${mod}+q" = "kill";
                # Force kill the focused window
                "${mod}+Shift+q" = # bash
                    ''
                        exec kill -KILL $(${swaymsg} -t get_tree | ${jq} '.. | select(.type?) | select(.focused==true) | .pid')
                    '';
                # Swap focus between the tiling area and the floating area
                "${mod}+d" = "focus mode_toggle";
                # Toggle the current focus between tiling and floating mode
                "${mod}+Shift+d" = "floating toggle";

                ## Moving windows
                "${mod}+Alt+0" = "move container to workspace number 10";
                "${mod}+Alt+1" = "move container to workspace number 1";
                "${mod}+Alt+2" = "move container to workspace number 2";
                "${mod}+Alt+3" = "move container to workspace number 3";
                "${mod}+Alt+4" = "move container to workspace number 4";
                "${mod}+Alt+5" = "move container to workspace number 5";
                "${mod}+Alt+6" = "move container to workspace number 6";
                "${mod}+Alt+7" = "move container to workspace number 7";
                "${mod}+Alt+8" = "move container to workspace number 8";
                "${mod}+Alt+9" = "move container to workspace number 9";

                ## Applications
                # Application launcher
                "${mod}+space" = "exec ${menu} -show drun -show-icons";
                # Terminal
                "${mod}+Return" = "exec ${term}";
                # File manager
                "${mod}+e" = "exec ${term} start ${getExe pkgs.yazi}";
                # Browser
                "${mod}+b" = "exec ${browser}";
                # Resource monitor
                "${mod}+m" = "exec ${term} start ${getExe pkgs.bottom}";
                # Toggle control center
                "${mod}+n" = "exec ${getExe' pkgs.swaynotificationcenter "swaync-client"} -t -sw";

                "${mod}+o" = "exec ${getExe config.programs.wlogout.package}";
                "${mod}+p" = "exec ${getExe config.programs.swaylock.package}";

                ## Screenshots
                "Print" = "exec ${screenshot} fullscreen";
                "Control+Print" = "exec ${screenshot} region";
                "Shift+Print" = "exec ${screenshot} focused";

                ## Pickers
                # Emoji
                "${mod}+period" = "exec ${getExe pkgs.rofimoji}";
                # Clipboard history
                "${mod}+slash" = # bash
                    ''
                        exec ${menu} -modi clipboard:${getExe pkgs.custom.cliphist-rofi-img} -show clipboard -show-icons
                    '';

                ## Media keys
                # Volume
                "XF86AudioRaiseVolume" = "exec ${swayosd} --output-volume raise";
                "XF86AudioLowerVolume" = "exec ${swayosd} --output-volume lower";
                "XF86AudioMute" = "exec ${swayosd} --output-volume mute-toggle";
                # Brightness
                "XF86MonBrightnessUp" = "exec ${swayosd} --brightness +10";
                "XF86MonBrightnessDown" = "exec ${swayosd} --brightness -10";
            };
    };
}
