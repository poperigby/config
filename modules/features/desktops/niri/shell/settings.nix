{ inputs, ... }:
{
    den.aspects.shells.provides.noctalia.settings =
        {
            wallpaper ? null,
        }:
        {
            homeManager =
                {
                    config,
                    lib,
                    pkgs,
                    ...
                }:
                let
                    inherit (lib) getExe;

                    niri = getExe pkgs.niri;
                    noctalia = getExe config.programs.noctalia.package;
                in
                {
                    imports = [ inputs.noctalia.homeModules.default ];

                    programs.noctalia = {
                        enable = true;
                        settings = {
                            audio.enable_sounds = true;
                            bar.default = {
                                start = [
                                    "taskbar"
                                ];
                                center = [
                                    "clock"
                                ];
                                end = [
                                    "tray"
                                    "group:utilities"
                                    "notifications"
                                ];
                                capsule_group = [
                                    {
                                        id = "utilities";
                                        members = [
                                            "privacy"
                                            "clipboard"
                                            "cpu"
                                            "network"
                                            "bluetooth"
                                            "volume"
                                            "battery"
                                        ];
                                        widget_spacing = 10;
                                    }
                                ];
                                contact_shadow = true;
                                background_opacity = 0.7;
                                margin_edge = 10;
                                margin_ends = 8;
                                radius = 15;
                                scale = 1.05;
                                thickness = 40;
                                dead_zone.actions.right = "none";
                            };
                            widget = {
                                privacy.hide_inactive = true;
                                brightness.show_label = false;
                                clock.actions.left = "panel-toggle control-center";
                                cpu = {
                                    show_value = false;
                                    visualization = "none";
                                    actions.right = "exec ${getExe pkgs.wezterm} start ${getExe pkgs.bottom}";
                                };
                                network.show_label = false;
                                notifications.capsule = true;
                                session.capsule = true;
                                taskbar = {
                                    group_by_workspace = true;
                                    workspace_group_content = "icons";
                                    group_single_icon_per_app = true;
                                    hide_empty_workspaces = true;
                                    show_workspace_label = false;
                                };
                                tray.capsule = true;
                                volume.show_label = false;
                            };
                            control_center = {
                                hidden_tabs = [
                                    "audio"
                                    "system"
                                    "network"
                                    "bluetooth"
                                    "notifications"
                                ];
                                sidebar = "full";
                                sidebar_section = "none";
                            };
                            brightness.enable_ddcutil = true;
                            calendar.enabled = true;
                            location.auto_locate = true;
                            osd = {
                                position = "bottom_center";
                                kinds = {
                                    media = false;
                                };
                            };
                            lockscreen = {
                                transition = [ "fade" ];
                                transition_duration = 200;
                                blur_intensity = 0.0;
                                tint_intensity = 0.0;
                            };
                            shell = {
                                font_family = "Noto Sans";
                                launch_apps_as_systemd_services = true;
                                launcher = {
                                    # Disable category indicator
                                    categories = false;
                                    show_app_actions = true;
                                    show_app_origin_indicator = false;
                                    providers = {
                                        calculator.prefix = "";
                                        emoji = {
                                            global = false;
                                            prefix = "emo";
                                        };
                                    };
                                };
                                panel = {
                                    clipboard_position = "auto";
                                    control_center_placement = "floating";
                                    open_near_click_clipboard = true;
                                    open_near_click_control_center = true;
                                    open_near_click_session = true;
                                    session_placement = "floating";
                                    transparency_mode = "glass";
                                };
                                session = {
                                    grid = true;
                                    grid_columns = 2;
                                    show_shortcuts = false;
                                    actions = [
                                        {
                                            action = "lock";
                                            countdown_seconds = 0.0;
                                            enabled = true;
                                            shortcut = "1";
                                            variant = "default";
                                        }
                                        {
                                            action = "logout";
                                            countdown_seconds = 0.0;
                                            enabled = true;
                                            shortcut = "2";
                                            variant = "default";
                                        }
                                        {
                                            action = "lock_and_suspend";
                                            countdown_seconds = 0.0;
                                            enabled = false;
                                            shortcut = "3";
                                            variant = "default";
                                        }
                                        {
                                            action = "reboot";
                                            countdown_seconds = 0.0;
                                            enabled = true;
                                            shortcut = "4";
                                            variant = "default";
                                        }
                                        {
                                            action = "shutdown";
                                            countdown_seconds = 0.0;
                                            enabled = true;
                                            shortcut = "5";
                                            variant = "destructive";
                                        }
                                    ];
                                };
                                privacy.mic_filter_regex = "HushMic";
                            };
                            theme = {
                                builtin = "Gruvbox";
                                community_palette = "Gruvbox Material Hard";
                                source = "community";
                            };
                            wallpaper.default.path = wallpaper;
                            wallpaper.last.path = wallpaper;
                            hooks = {
                                session_locked = "sleep 60; ${niri} msg action power-off-monitors";
                            };
                            idle = {
                                behavior = {
                                    lock-and-turn-off-screen = {
                                        action = "command";
                                        command = "${noctalia} msg session lock && ${niri} msg action power-off-monitors";
                                        enabled = true;
                                        timeout = 600;
                                    };
                                };
                                behavior_order = [ "lock-and-turn-off-screen" ];
                            };
                        };
                    };
                };
        };
}
