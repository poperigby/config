{ ... }:
{
    den.aspects.programs.provides.bottom.homeManager =
        { lib, user, ... }:
        let
            hasGui = lib.local.aspects.hasGui user;
        in
        {
            programs.bottom = {
                enable = true;
                settings.flags.color = "gruvbox";
            };

            xdg.desktopEntries.bottom = lib.mkIf hasGui {
                name = "Bottom";
                genericName = "System Monitor";
                icon = "utilities-system-monitor";
                exec = "btm";
                terminal = true;
                type = "Application";
                categories = [ "System" ];
            };
        };
}
