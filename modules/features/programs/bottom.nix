{ den, ... }:
{
    den.aspects.programs.provides.bottom.homeManager.programs.bottom.enable = true;

    den.aspects.programs.provides.bottom-gui.homeManager.xdg.desktopEntries.bottom = {
        name = "bottom";
        genericName = "System Monitor";
        exec = "btm";
        terminal = true;
        type = "Application";
    };
}
