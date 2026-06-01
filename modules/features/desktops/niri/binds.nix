{ ... }:

{
    den.aspects.desktops.provides.niri.homeManager =
        { lib, pkgs, ... }:
        let
            inherit (lib) getExe;

            dms = getExe pkgs.dms-shell;
        in
        {
            programs.niri.settings.binds = {
                # Mod-Shift-/, usually Mod-?, shows important hotkeys
                "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

                ##########################################################
                # Program launchers
                ##########################################################

                "Mod+Return" = {
                    action.spawn = getExe pkgs.wezterm;
                    hotkey-overlay.title = "Open a terminal";
                };

                "Mod+Space" = {
                    action.spawn = [
                        dms
                        "ipc"
                        "launcher"
                        "open"
                    ];
                    hotkey-overlay.title = "Open the application launcher";
                };

                "Mod+Escape" = {
                    action.spawn = [
                        dms
                        "ipc"
                        "lock"
                        "lock"
                    ];
                    hotkey-overlay.title = "Lock the screen";
                };

                ##########################################################
                # Volume (PipeWire / WirePlumber)
                ##########################################################

                "XF86AudioRaiseVolume" = {
                    action.spawn = [
                        "wpctl"
                        "set-volume"
                        "@DEFAULT_AUDIO_SINK@"
                        "0.1+"
                        "-l"
                        "1.0"
                    ];
                    allow-when-locked = true;
                };

                "XF86AudioLowerVolume" = {
                    action.spawn = [
                        "wpctl"
                        "set-volume"
                        "@DEFAULT_AUDIO_SINK@"
                        "0.1-"
                    ];
                    allow-when-locked = true;
                };

                "XF86AudioMute" = {
                    action.spawn = [
                        "wpctl"
                        "set-mute"
                        "@DEFAULT_AUDIO_SINK@"
                        "toggle"
                    ];
                    allow-when-locked = true;
                };

                "XF86AudioMicMute" = {
                    action.spawn = [
                        "wpctl"
                        "set-mute"
                        "@DEFAULT_AUDIO_SOURCE@"
                        "toggle"
                    ];
                    allow-when-locked = true;
                };

                ##########################################################
                # Media keys
                ##########################################################

                "XF86AudioPlay" = {
                    action.spawn = [
                        "playerctl"
                        "play-pause"
                    ];
                    allow-when-locked = true;
                };

                "XF86AudioStop" = {
                    action.spawn = [
                        "playerctl"
                        "stop"
                    ];
                    allow-when-locked = true;
                };

                "XF86AudioPrev" = {
                    action.spawn = [
                        "playerctl"
                        "previous"
                    ];
                    allow-when-locked = true;
                };

                "XF86AudioNext" = {
                    action.spawn = [
                        "playerctl"
                        "next"
                    ];
                    allow-when-locked = true;
                };

                ##########################################################
                # Brightness
                ##########################################################

                "XF86MonBrightnessUp" = {
                    action.spawn = [
                        "brightnessctl"
                        "--class=backlight"
                        "set"
                        "+10%"
                    ];
                    allow-when-locked = true;
                };

                "XF86MonBrightnessDown" = {
                    action.spawn = [
                        "brightnessctl"
                        "--class=backlight"
                        "set"
                        "10%-"
                    ];
                    allow-when-locked = true;
                };

                ##########################################################
                # Window / overview
                ##########################################################

                "Mod+W" = {
                    action.toggle-overview = [ ];
                    repeat = false;
                };
                "Mod+Q" = {
                    action.close-window = [ ];
                    repeat = false;
                };

                ##########################################################
                # Focus (vim + arrows)
                ##########################################################

                # Arrow keys
                "Mod+Left".action.focus-column-left = [ ];
                "Mod+Right".action.focus-column-right = [ ];
                "Mod+Down".action.focus-window-down = [ ];
                "Mod+Up".action.focus-window-up = [ ];

                # Vim keys
                "Mod+H".action.focus-column-left = [ ];
                "Mod+L".action.focus-column-right = [ ];
                "Mod+J".action.focus-window-down = [ ];
                "Mod+K".action.focus-window-up = [ ];

                ##########################################################
                # Move (vim + arrows)
                ##########################################################

                # Arrow keys
                "Mod+Ctrl+Left".action.move-column-left = [ ];
                "Mod+Ctrl+Right".action.move-column-right = [ ];
                "Mod+Ctrl+Down".action.move-window-down = [ ];
                "Mod+Ctrl+Up".action.move-window-up = [ ];

                # Vim keys
                "Mod+Ctrl+H".action.move-column-left = [ ];
                "Mod+Ctrl+L".action.move-column-right = [ ];
                "Mod+Ctrl+J".action.move-window-down = [ ];
                "Mod+Ctrl+K".action.move-window-up = [ ];

                ##########################################################
                # Workspace scrolling
                ##########################################################

                "Mod+WheelScrollDown" = {
                    action.focus-workspace-down = [ ];
                    cooldown-ms = 150;
                };

                "Mod+WheelScrollUp" = {
                    action.focus-workspace-up = [ ];
                    cooldown-ms = 150;
                };

                "Mod+Ctrl+WheelScrollDown" = {
                    action.move-column-to-workspace-down = [ ];
                    cooldown-ms = 150;
                };

                "Mod+Ctrl+WheelScrollUp" = {
                    action.move-column-to-workspace-up = [ ];
                    cooldown-ms = 150;
                };

                ##########################################################
                # Workspace numbers
                ##########################################################

                # Note: niri workspaces are dynamic
                "Mod+1".action.focus-workspace = 1;
                "Mod+2".action.focus-workspace = 2;
                "Mod+3".action.focus-workspace = 3;
                "Mod+4".action.focus-workspace = 4;
                "Mod+5".action.focus-workspace = 5;
                "Mod+6".action.focus-workspace = 6;
                "Mod+7".action.focus-workspace = 7;
                "Mod+8".action.focus-workspace = 8;
                "Mod+9".action.focus-workspace = 9;

                "Mod+Alt+1".action.move-column-to-workspace = 1;
                "Mod+Alt+2".action.move-column-to-workspace = 2;
                "Mod+Alt+3".action.move-column-to-workspace = 3;
                "Mod+Alt+4".action.move-column-to-workspace = 4;
                "Mod+Alt+5".action.move-column-to-workspace = 5;
                "Mod+Alt+6".action.move-column-to-workspace = 6;
                "Mod+Alt+7".action.move-column-to-workspace = 7;
                "Mod+Alt+8".action.move-column-to-workspace = 8;
                "Mod+Alt+9".action.move-column-to-workspace = 9;

                ##########################################################
                # Layout / sizing
                ##########################################################

                "Mod+F".action.maximize-column = [ ];
                "Mod+Shift+F".action.fullscreen-window = [ ];
                "Mod+M".action.maximize-window-to-edges = [ ];

                "Mod+Minus".action.set-column-width = "-10%";
                "Mod+Equal".action.set-column-width = "+10%";

                "Mod+Shift+Minus".action.set-window-height = "-10%";
                "Mod+Shift+Equal".action.set-window-height = "+10%";

                ##########################################################
                # Layout modes
                ##########################################################

                "Mod+V".action.toggle-window-floating = [ ];
                "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];

                "Mod+T".action.toggle-column-tabbed-display = [ ];

                ##########################################################
                # Screenshots
                ##########################################################

                "Print".action.screenshot-screen = [ ];
                "Ctrl+Print".action.screenshot = [ ];
                "Alt+Print".action.screenshot-window = [ ];

                ##########################################################
                # Safety / session control
                ##########################################################

                "Mod+Shift+E".action.quit = [ ];
                "Ctrl+Alt+Delete".action.quit = [ ];

                "Mod+Shift+P".action.power-off-monitors = [ ];
            };
        };
}
