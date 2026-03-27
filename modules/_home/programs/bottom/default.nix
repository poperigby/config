{ config, lib, ... }:

let
    cfg = config.custom.programs.bottom;
in
{
    options.custom.programs.bottom.enable = lib.mkEnableOption "Enable bottom";

    config = lib.mkIf cfg.enable {
        programs.bottom = {
            enable = true;
            settings = {
                flags = {
                    color = "gruvbox";
                };
            };
        };

        # Create a desktop entry for Bottom if the desktop GUI is enabled
        xdg.desktopEntries.bottom = lib.mkIf config.custom.suites.gui.enable {
            name = "Bottom";
            genericName = "System Monitor";
            icon = "utilities-system-monitor";
            exec = "btm";
            terminal = true;
            categories = [ "System" ];
        };
    };
}
