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
                        # Launch Wofi
                        "Super Space" = "spawn ${pkgs.wofi}/bin/wofi";
                        # Exit River
                        "Super+Shift E" = "exit";
                    };
                };
            };
        };

        common.home.gui.dunst.enable = true;
        common.home.gui.flameshot.enable = true;
        common.home.gui.gammastep.enable = true;
        common.home.gui.waybar.enable = true;
        common.home.gui.wofi.enable = true;
    };
}
