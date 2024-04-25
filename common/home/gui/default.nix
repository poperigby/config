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
                        "Super Space" = "spawn ${pkgs.wofi}/bin/wofi --show drun --allow-images --prompt=""";
                        # Launch WezTerm
                        "Super Return" = "spawn ${pkgs.wezterm}/bin/wezterm";
                    };
                };
            };
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
