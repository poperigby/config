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
                icon-theme = "MoreWaita";
                # Icons
                display-clipboard = " ";
                display-combi = " ";
                display-drun = " ";
                display-emoji = " ";
                display-run = " ";
                display-ssh = "󰖟 ";
                display-window = " ";
                display-calc = " ";
                # Keybindings
                kb-row-up = "Up,Control+k";
                kb-row-down = "Down,Control+j";
                kb-accept-entry = "Control+m,Return,KP_Enter";
                kb-remove-to-eol = "Control+Shift+e";
                kb-mode-next = "Shift+Right,Control+Tab,Control+l";
                kb-mode-previous = "Shift+Left,Control+Shift+Tab,Control+h";
                kb-mode-complete = "Control+i";
                kb-remove-char-back = "BackSpace";
            };
            # terminal = "${pkgs.wezterm}/bin/wezterm --config enable_tab_bar=false start";
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
