{ den, ... }:
{
    den.aspects.programs.provides.bottom.homeManager.programs.bottom = {
        enable = true;
        settings.flags.color = "gruvbox";
    };

    den.aspects.programs.provides.bottom-gui.homeManager.xdg.desktopEntries.bottom = {
        name = "Bottom";
        genericName = "System Monitor";
        icon = "utilities-system-monitor";
        exec = "btm";
        terminal = true;
        type = "Application";
        categories = [ "System" ];
    };
}
