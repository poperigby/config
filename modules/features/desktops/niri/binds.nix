{ den, ... }:
{
    den.aspects.desktops.provides.niri.binds.homeManager = {
        wayland.windowManager.niri.settings.binds = {
            "Mod+Shift+Slash".show-hotkey-overlay = { };

            "Mod+Pause".spawn = [
                "wl-freeze"
                "-c"
                "niri msg --json focused-window | jq '.pid'"
            ];

            "Mod+Return" = {
                _props.hotkey-overlay-title = "Open a terminal";
                spawn = [ "wezterm" ];
            };
            "Mod+E" = {
                _props.hotkey-overlay-title = "Open file browser";
                spawn = [
                    "wezterm"
                    "start"
                    "yazi"
                ];
            };

            "XF86AudioPlay" = {
                _props.allow-when-locked = true;
                spawn = [
                    "playerctl"
                    "play-pause"
                ];
            };
            "XF86AudioStop" = {
                _props.allow-when-locked = true;
                spawn = [
                    "playerctl"
                    "stop"
                ];
            };
            "XF86AudioPrev" = {
                _props.allow-when-locked = true;
                spawn = [
                    "playerctl"
                    "previous"
                ];
            };
            "XF86AudioNext" = {
                _props.allow-when-locked = true;
                spawn = [
                    "playerctl"
                    "next"
                ];
            };

            "Mod+W" = {
                _props.repeat = false;
                toggle-overview = { };
            };
            "Mod+Q" = {
                _props = {
                    hotkey-overlay-title = "Quit the focused window";
                    repeat = false;
                };
                close-window = { };
            };
            "Mod+Alt+Q" = {
                _props = {
                    hotkey-overlay-title = "Force kill the focused window";
                    repeat = false;
                };
                spawn = [ "wkill" ];
            };

            "Mod+H".focus-column-left = { };
            "Mod+L".focus-column-right = { };
            "Mod+J".focus-window-or-workspace-down = { };
            "Mod+K".focus-window-or-workspace-up = { };

            "Mod+WheelScrollDown" = {
                _props.cooldown-ms = 150;
                focus-workspace-down = { };
            };
            "Mod+WheelScrollUp" = {
                _props.cooldown-ms = 150;
                focus-workspace-up = { };
            };

            "Mod+Home".focus-column-first = { };
            "Mod+End".focus-column-last = { };

            "Mod+Alt+H".move-column-left = { };
            "Mod+Alt+L".move-column-right = { };
            "Mod+Alt+J".move-window-down = { };
            "Mod+Alt+K".move-window-up = { };
            "Mod+Ctrl+WheelScrollDown" = {
                _props.cooldown-ms = 150;
                move-column-to-workspace-down = { };
            };
            "Mod+Ctrl+WheelScrollUp" = {
                _props.cooldown-ms = 150;
                move-column-to-workspace-up = { };
            };

            "Mod+1".focus-workspace = 1;
            "Mod+2".focus-workspace = 2;
            "Mod+3".focus-workspace = 3;
            "Mod+4".focus-workspace = 4;
            "Mod+5".focus-workspace = 5;
            "Mod+6".focus-workspace = 6;
            "Mod+7".focus-workspace = 7;
            "Mod+8".focus-workspace = 8;
            "Mod+9".focus-workspace = 9;

            "Mod+Alt+1".move-column-to-workspace = 1;
            "Mod+Alt+2".move-column-to-workspace = 2;
            "Mod+Alt+3".move-column-to-workspace = 3;
            "Mod+Alt+4".move-column-to-workspace = 4;
            "Mod+Alt+5".move-column-to-workspace = 5;
            "Mod+Alt+6".move-column-to-workspace = 6;
            "Mod+Alt+7".move-column-to-workspace = 7;
            "Mod+Alt+8".move-column-to-workspace = 8;
            "Mod+Alt+9".move-column-to-workspace = 9;

            "Mod+F".maximize-column = { };
            "Mod+Shift+F".fullscreen-window = { };
            "Mod+M".maximize-window-to-edges = { };

            "Mod+Minus".set-column-width = "-10%";
            "Mod+Equal".set-column-width = "+10%";
            "Mod+Shift+Minus".set-window-height = "-10%";
            "Mod+Shift+Equal".set-window-height = "+10%";

            "Mod+R".switch-preset-column-width = { };
            "Mod+Shift+R".switch-preset-column-width-back = { };

            "Mod+BracketLeft".consume-or-expel-window-left = { };
            "Mod+BracketRight".consume-or-expel-window-right = { };

            "Mod+D".toggle-window-floating = { };
            "Mod+Shift+D".switch-focus-between-floating-and-tiling = { };
            "Mod+T".toggle-column-tabbed-display = { };

            "Print".screenshot-screen = { };
            "Ctrl+Print".screenshot = { };
            "Alt+Print".screenshot-window = { };
        };
    };
}
