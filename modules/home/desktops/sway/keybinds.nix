{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.desktops.sway;
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
            screenshooter = "${pkgs.flameshot}/bin/flameshot";
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
            "${mod}+b" = "exec ${browser}";
            # Toggle control center
            "${mod}+n" = "exec ${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";

            ## Screenshots
            # Full screen
            "Print" = "exec ${screenshooter} full";
            # A region of the screen
            "Shift+Print" = "exec ${screenshooter} gui";

            ## Pickers
            # Emoji
            "${mod}+period" = "exec ${menu} -modi emoji -show emoji";
            # Clipboard history
            "${mod}+slash" = ''
                exec ${menu} -modi clipboard:${pkgs.poperigby.cliphist-rofi-img}/bin/cliphist-rofi-img -show clipboard -show-icons
            '';
        };
    };
}
