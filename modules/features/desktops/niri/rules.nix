{ ... }:

{
    den.aspects.desktops.provides.niri.homeManager.programs.niri.settings.window-rules = [
        {
            open-maximized = true;
            geometry-corner-radius =
                let
                    radius = 8.0;
                in
                {
                    bottom-left = radius;
                    bottom-right = radius;
                    top-left = radius;
                    top-right = radius;
                };
            clip-to-geometry = true;
        }
        {
            matches = [
                { app-id = "steam"; }
                { title = "^notificationtoasts_\\d+_desktop$"; }
            ];
            default-floating-position = {
                x = 10;
                y = 10;
                relative-to = "bottom-right";
            };
        }
    ];
}
