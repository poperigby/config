{ config, lib, pkgs, ... }:

let
    inherit (lib)
        getExe
        getExe'
    ;

    cfg = config.custom.desktops.sway;
    sway = config.wayland.windowManager.sway;
in
{
    config = lib.mkIf cfg.enable {
        wayland.windowManager.sway.config.keybindings = let
            mod = sway.config.modifier;
            # We need to use this version to use our plugins
            menu = "${config.programs.rofi.finalPackage}/bin/rofi";
            browser = "${pkgs.firefox}/bin/firefox";
            term = sway.config.terminal;
            # Screenshooting
            grim = "${pkgs.grim}/bin/grim";
            slurp = "${pkgs.slurp}/bin/slurp";
            screenshotLocation = "${config.xdg.userDirs.pictures}/Screenshots/$(date +'Screenshot_%Y-%m-%d_%H-%M-%S-%N.png')";
            # Media
            swayosd = getExe' pkgs.swayosd "swayosd-client";
        in lib.mkOptionDefault {
            ## Basics
            # Quit the focused window
            "${mod}+q" = "kill";
            # Force kill the focused window
            "${mod}+Shift+q" = ''
                exec kill -KILL $(${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq '.. | select(.type?) | select(.focused==true) | .pid')
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
            "${mod}+e" = "exec ${term} start ${pkgs.yazi}/bin/yazi";
            # Browser
            "${mod}+b" = "exec ${browser}";
            # Resource monitor
            "${mod}+m" = "exec ${term} start ${pkgs.bottom}/bin/btm";
            # Toggle control center
            "${mod}+n" = "exec ${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";

            "${mod}+o" = "exec ${getExe config.programs.wlogout.package}";
            "${mod}+p" = "exec ${getExe config.programs.swaylock.package}";

            ## Screenshots
            # Full screen
            "Print" = "exec ${grim} ${screenshotLocation}";
            # A region of the screen
            "Control+Print" = "exec ${grim} -g \"$(${slurp})\" ${screenshotLocation}";

            ## Pickers
            # Emoji
            "${mod}+period" = "exec ${menu} -modi emoji -show emoji";
            # Clipboard history
            "${mod}+slash" = ''
                exec ${menu} -modi clipboard:${pkgs.custom.cliphist-rofi-img}/bin/cliphist-rofi-img -show clipboard -show-icons
            '';

            ## Media keys
            # Volume
            "XF86AudioRaiseVolume"  = "exec ${swayosd} --output-volume raise";
            "XF86AudioLowerVolume" = "exec ${swayosd} --output-volume lower";
            "XF86AudioMute" = "exec ${swayosd} --output-volume mute-toggle";
            # Brightness
            "XF86MonBrightnessUp" = "exec ${swayosd} --brightness +10";
            "XF86MonBrightnessDown" = "exec ${swayosd} --brightness -10";
        };
    };
}
