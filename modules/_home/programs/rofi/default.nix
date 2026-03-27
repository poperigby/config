{
    config,
    lib,
    pkgs,
    ...
}:

let
    inherit (lib)
        getExe
        mkEnableOption
        mkIf
        ;

    cfg = config.custom.programs.rofi;
in
{
    options.custom.programs.rofi.enable = mkEnableOption "Enable Rofi";

    config = mkIf cfg.enable {
        programs.rofi = {
            enable = true;
            extraConfig = {
                # Commands
                ssh-command = "{terminal} ssh {host}";
                run-shell-command = "{terminal} start {cmd}";
                # Icons
                display-clipboard = " ";
                display-combi = " ";
                display-drun = " ";
                display-emoji = " ";
                display-run = " ";
                display-ssh = "󰖟 ";
                display-window = " ";
                display-calc = " ";
                # Desktop entry icons
                show-icons = true;
                icon-theme = "Papirus-Dark";
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
            terminal = "${getExe pkgs.wezterm}";
            font = "Noto Sans";
            theme = ./theme.rasi;
        };

        home.packages = with pkgs; [
            # Needed for rofimoji
            wtype
            # Needed for drun icons
            papirus-icon-theme
        ];

        xdg.configFile."rofimoji.rc".source = ./rofimoji.rc;
    };
}
