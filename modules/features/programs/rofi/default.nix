{ den, ... }:
{
    den.aspects.programs.provides.rofi.homeManager =
        { lib, pkgs, ... }:
        {
            programs.rofi = {
                enable = true;
                extraConfig = {
                    ssh-command = "{terminal} ssh {host}";
                    run-shell-command = "{terminal} start {cmd}";

                    display-clipboard = " ";
                    display-combi = " ";
                    display-drun = " ";
                    display-emoji = " ";
                    display-run = " ";
                    display-ssh = "󰖟 ";
                    display-window = " ";
                    display-calc = " ";

                    show-icons = true;
                    icon-theme = "Papirus-Dark";

                    kb-row-up = "Up,Control+k";
                    kb-row-down = "Down,Control+j";
                    kb-accept-entry = "Control+m,Return,KP_Enter";
                    kb-remove-to-eol = "Control+Shift+e";
                    kb-mode-next = "Shift+Right,Control+Tab,Control+l";
                    kb-mode-previous = "Shift+Left,Control+Shift+Tab,Control+h";
                    kb-mode-complete = "Control+i";
                    kb-remove-char-back = "BackSpace";
                };
                terminal = "${lib.getExe pkgs.wezterm}";
                font = "Noto Sans";
                theme = ./theme.rasi;
            };

            home.packages = with pkgs; [
                wtype
                papirus-icon-theme
            ];

            xdg.configFile."rofimoji.rc".source = ./rofimoji.rc;
        };
}
