{ ... }:
{
    den.aspects.desktops.provides.niri.rules.homeManager = {
        wayland.windowManager.niri.settings._children = [
            {
                window-rule._children = [
                    { geometry-corner-radius = 8.0; }
                    { clip-to-geometry = true; }
                ];
            }
            {
                window-rule._children = [
                    { match._props.is-active = false; }
                    { opacity = 0.9; }
                ];
            }
            {
                window-rule._children = [
                    { match._props.app-id = "^org\\.wezfurlong\\.wezterm$"; }
                    { match._props.app-id = "^org\\.gnome\\."; }
                    { draw-border-with-background = false; }
                ];
            }
            {
                window-rule._children = [
                    { match._props.app-id = "^com\\.gabm\\.satty$"; }
                    { open-maximized = true; }
                ];
            }
            {
                window-rule._children = [
                    { match._props.app-id = "steam"; }
                    { open-focused = false; }
                ];
            }
            {
                window-rule._children = [
                    {
                        match._props = {
                            app-id = "steam";
                            title = "^notificationtoasts_\\d+_desktop$";
                        };
                    }
                    {
                        default-floating-position._props = {
                            x = 10;
                            y = 10;
                            relative-to = "bottom-right";
                        };
                    }
                ];
            }
        ];
    };
}
