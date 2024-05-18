{ config, lib, ... }:

let
    cfg = config.poperigby.programs.bottom;
in
{
    options.poperigby.programs.bottom.enable = lib.mkEnableOption "Enable bottom";

    config = lib.mkIf cfg.enable {
        programs.bottom = {
            enable = true;
        };

        # Create a desktop entry for Bottom if the desktop GUI is enabled
        xdg.desktopEntries.bottom = lib.mkIf config.poperigby.suites.desktop.enable {
            name = "Bottom";
            genericName = "System Monitor";
            exec = "btm";
            terminal = true;
            categories = [ "System" ];
        };
    };
}
