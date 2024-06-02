{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.programs.element-desktop;
in
{
    options.poperigby.programs.element-desktop.enable = lib.mkEnableOption "Enable element-desktop";

    config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.element-desktop ];

        # TODO: Make this an option
        xdg.configFile."Element/config.json".text = builtins.toJSON {
            setting_defaults = {
                custom_themes = [
                    {
                        name = "Gruvbox Dark";
                        is_dark = true;
                        colors = {
                            accent-color = "#d3869b";
                            primary-color = "#fe8019";
                            warning-color = "#fb4934";
                            sidebar-color = "#282828";
                            roomlist-background-color = "#1d2021";
                            roomlist-text-color = "#a89984";
                            roomlist-text-secondary-color = "#98971a";
                            roomlist-highlights-color = "#00000030";
                            roomlist-separator-color = "#4d4d4d90";
                            timeline-background-color = "#282828";
                            timeline-text-color = "#ebdbb2";
                            secondary-content = "#928374";
                            tertiary-content = "#928374";
                            quinary-content = "#504945";
                            timeline-text-secondary-color = "#a89984";
                            timeline-highlights-color = "#00000030";
                            reaction-row-button-selected-bg-color = "#689d6a";
                            menu-selected-color = "#504945";
                            icon-button-color = "#928374";
                            accent = "#689d6a";
                            alert = "#cc241d";
                            username-colors = [
                                "#cc241d"
                                "#98971a"
                                "#d79921"
                                "#458588"
                                "#b16286"
                                "#689d6a"
                                "#a89984"
                                "#d65d0e"
                            ];
                            avatar-background-colors = [
                                "#458588"
                                "#b16286"
                                "#689d6a"
                            ];
                        };
                    }
                ];
            };
            show_labs_settings = true;
        };
    };
}
