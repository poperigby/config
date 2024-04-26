{ config, lib, pkgs, ... }:

let
    cfg = config.common.home.gui;
in
{
    options.common.home.gui.enable = lib.mkEnableOption "Enable GUI";

    imports = [
        ./dunst.nix
        ./flameshot.nix
        ./gammastep.nix
        ./waybar.nix
        ./wofi.nix
    ];

    config = lib.mkIf cfg.enable {
        wayland.windowManager.river = {
            enable = true;
            settings = {
                default-layout = "rivertile";
                map = {
                    normal = {
                        ### Basics
                        # Close focused view
                        "Super Q" = "close";
                        # Focus next/previous view in layout stack
                        "Super J" = "focus-view next";
                        "Super K" = "focus-view previous";
                        # Exit River
                        "Super+Shift E" = "exit";
                        ### Applications
                        # Launch Wofi
                        "Super Space" = "spawn '${pkgs.wofi}/bin/wofi --show drun --allow-images'";
                        # Launch WezTerm
                        "Super Return" = "spawn ${pkgs.wezterm}/bin/wezterm";
                    };
                };
            };
            extraConfig = ''
                # Tab focusing
                for i in $(seq 1 9)
                do
                    tags=$((1 << ($i - 1)))

                    # Super+[1-9] to focus tag [0-8]
                    riverctl map normal Super $i set-focused-tags $tags

                    # Super+Shift+[1-9] to tag focused view with tag [0-8]
                    riverctl map normal Super+Shift $i set-view-tags $tags

                    # Super+Control+[1-9] to toggle focus of tag [0-8]
                    riverctl map normal Super+Control $i toggle-focused-tags $tags

                    # Super+Shift+Control+[1-9] to toggle tag [0-8] of focused view
                    riverctl map normal Super+Shift+Control $i toggle-view-tags $tags
                done
            '';
        };

        # Desktop environment related applications
        common.home.gui.dunst.enable = true;
        common.home.gui.flameshot.enable = true;
        common.home.gui.gammastep.enable = true;
        common.home.gui.waybar.enable = true;
        common.home.gui.wofi.enable = true;

        # Useful applications
        common.home.wezterm.enable = true;
        common.home.firefox.enable = true;
    };
}
