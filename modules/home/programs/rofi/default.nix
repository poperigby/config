{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.programs.rofi;
in
{
    options.poperigby.programs.rofi.enable = lib.mkEnableOption "Enable Rofi";

    config = lib.mkIf cfg.enable {
        programs.rofi = {
            enable = true;
            package = pkgs.rofi-wayland;
            extraConfig = {
                show-icons = true;
                # Icons
                display-clipboard = " ";
                display-combi = " ";
                display-drun = " ";
                display-emoji = " ";
                display-run = " ";
                display-ssh = " ";
                display-window = " ";
                # Icon theme for drun
                icon-theme = "MoreWaita";
            };
            # terminal = "${pkgs.wezterm}/bin/wezterm start";
            plugins = with pkgs; [
                rofi-calc
                rofi-emoji
            ];
            font = "Noto Sans";
            theme = ./theme.rasi;
        };

        home.packages = with pkgs; [
            # Needed for rofi-emoji
            wtype
            wl-clipboard
            # Needed for drun icons
            morewaita-icon-theme
        ];
    };
}
