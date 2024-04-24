# System/process monitor

{ config, lib, ... }:

{
    programs.bottom = {
        enable = true;
    };

    # Create a desktop entry for Bottom if the GUI is enabled
    xdg.desktopEntries.bottom = lib.mkIf config.common.home.gui.enable {
        name = "Bottom";
        genericName = "System Monitor";
        exec = "btm";
        terminal = true;
        categories = [ "System" ];
    };
}
