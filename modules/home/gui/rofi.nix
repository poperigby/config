# Application launcher

{ config, lib, pkgs, ... }:

let
    cfg = config.common.home.gui.rofi;
in
{
    options.common.home.gui.rofi.enable = lib.mkEnableOption "Enable Rofi";

    config = lib.mkIf cfg.enable {
        programs.rofi = {
            enable = true;
            package = pkgs.rofi-wayland;
            plugins = with pkgs; [
                rofi-calc
                rofi-emoji
            ];
        };

        home.packages = with pkgs; [
            # Needed for rofi-emoji
            wtype
            wl-clipboard
        ];
    };
}
