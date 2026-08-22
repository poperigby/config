{ den, inputs, ... }:
{
    den.aspects.programs.provides.noctalia.settings =
        {
            settings ? { },
            wallpaper ? null,
        }:
        let
            defaultSettings = {
                audio.enable_sounds = true;
                bar.default = {
                    contact_shadow = true;
                    end = [
                        "tray"
                        "notifications"
                        "group:g1"
                        "session"
                    ];
                    margin_edge = 10;
                    margin_ends = 8;
                    radius = 15;
                    scale = 1.0500000081956387;
                    start = [
                        "taskbar"
                    ];
                    thickness = 40;
                    dead_zone.actions.right = "none";
                    capsule_group = [
                        {
                            accordion = false;
                            accordion_direction = "start";
                            enabled = true;
                            fill = "surface_variant";
                            id = "g1";
                            members = [
                                "clipboard"
                                "network"
                                "bluetooth"
                                "cpu"
                                "volume"
                                "brightness"
                                "battery"
                            ];
                            opacity = 1.0;
                            padding = 6.0;
                            widget_spacing = 10;
                        }
                    ];
                };
                brightness.enable_ddcutil = true;
                calendar.enabled = true;
                control_center = {
                    hidden_tabs = [
                        "audio"
                        "system"
                        "power"
                        "network"
                        "bluetooth"
                        "notifications"
                    ];
                    sidebar = "full";
                    sidebar_section = "none";
                };
                location.auto_locate = true;
                lockscreen_widgets = {
                    enabled = false;
                    schema_version = 2;
                    widget_order = [
                        "lockscreen-login-box@DP-1"
                    ];
                    grid = {
                        cell_size = 16;
                        major_interval = 4;
                        visible = true;
                    };
                    widget = {
                        "lockscreen-login-box@DP-1" = {
                            box_height = 196.0;
                            box_width = 810.0;
                            cx = 1280.0;
                            cy = 1258.0;
                            output = "DP-1";
                            placement_height = 1440.0;
                            placement_width = 2560.0;
                            rotation = 0.0;
                            type = "login_box";
                            settings = {
                                background_color = "surface_variant";
                                background_opacity = 0.88;
                                background_radius = 12.0;
                                center_password_text = false;
                                input_opacity = 1.0;
                                input_radius = 6.0;
                                layout = "regular";
                                show_caps_lock = true;
                                show_keyboard_layout = true;
                                show_login_button = true;
                                show_media = true;
                                show_session_buttons = true;
                                show_unlock_hint = true;
                                show_weather = true;
                            };
                        };
                    };
                };
                nightlight.enabled = true;
                osd.position = "bottom_center";
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
                };
                theme = {
                    builtin = "Gruvbox";
                    community_palette = "Gruvbox Material Hard";
                    source = "community";
                };
                wallpaper.default.path = wallpaper;
                wallpaper.last.path = wallpaper;
                widget = {
                    brightness.show_label = false;
                    clock.actions.left = "panel-toggle control-center";
                    cpu = {
                        show_value = false;
                        visualization = "none";
                    };
                    network.show_label = false;
                    notifications.capsule = true;
                    session.capsule = true;
                    taskbar = {
                        group_by_workspace = true;
                        workspace_group_content = "icons";
                        group_single_icon_per_app = true;
                        hide_empty_workspaces = true;
                    };
                    tray.capsule = true;
                    volume.show_label = false;
                };
            };
        in
        {
            homeManager = { ... }: {
                imports = [ inputs.noctalia.homeModules.default ];

                programs.noctalia = {
                    enable = true;
                    settings = defaultSettings // settings;
                };
            };
        };
}
