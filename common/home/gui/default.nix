{ config, lib, ... }:

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
    ];

    config = lib.mkIf cfg.enable {
        wayland.windowManager.sway = {
            enable = true;
        };

        # Desktop environment related applications
        common.home.gui = {
            dunst.enable = true;
            flameshot.enable = true;
            gammastep.enable = true;
            waybar.enable = true;
            rofi.enable = true;
        };

        # Useful applications
        common.home = {
            wezterm.enable = true;
            firefox.enable = true;
        };
    };
}
