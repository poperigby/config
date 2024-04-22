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
        ./wofi.nix
    ];

    config = lib.mkIf cfg.enable {
        wayland.windowManager.river = {
            enable = true;
        };

        common.home.gui.dunst.enable = true;
        common.home.gui.flameshot.enable = true;
        common.home.gui.gammastep.enable = true;
        common.home.gui.waybar.enable = true;
        common.home.gui.wofi.enable = true;
    };
}
