{ config, lib, pkgs, ... }:

let
    inherit (lib)
        getExe
        getExe'
        mkEnableOption
        mkIf
    ;

    cfg = config.poperigby.programs.waybar;
    colors = config.colorScheme.palette;
in
{
    options.poperigby.programs.waybar.enable = mkEnableOption "Enable Waybar";

    config = mkIf cfg.enable {
        programs.waybar = {
            enable = true;
            settings.mainBar = {
                ## Global
                layer = "top";
                position = "top";
                height = 42;
                modules-left = [
                    "sway/workspaces"
                    "sway/mode"
                ];
                modules-center = [
                    "clock"
                ];
                modules-right = [
                    # Variable width, status modules
                    "gamemode"
                    "privacy"
                    "tray"
                    # Fixed width modules
                    "wireplumber"
                    "bluetooth"
                    "network"
                    "battery"
                    "custom/weather"
                    "custom/notification"
                ];
                ## Modules - Center
                clock = {
                    format = "{:%H:%M}";
                    tooltip-format = "<tt><small>{calendar}</small></tt>";
                    calendar = {
                        mode = "month";
                        mode-mon-col = 3;
                        weeks-pos = "right";
                        on-scroll = 1;
                        format = {
                            months = "<span color='#${colors.base0C}'><b>{}</b></span>";
                            days = "<span color='#${colors.base06}'><b>{}</b></span>";
                            weeks = "<span color='#${colors.base0D}'><b>W{}</b></span>";
                            weekdays = "<span color='#${colors.base0E}'><b>{}</b></span>";
                            today = "<span color='#${colors.base09}'><b>{}</b></span>";
                        };
                    };
                    actions = {
                        on-click-right = "mode";
                        on-click-forward = "tz_up";
                        on-click-backward = "tz_down";
                        on-scroll-up = "shift_up";
                        on-scroll-down = "shift_down";
                    };
                };
                ## Modules - Right
                gamemode = {
                    format = "{glyph}";
                    format-alt = "{glyph} {count}";
                    glyph = "󰊴";
                    use-icon = false;
                    hide-not-running = true;
                    tooltip = true;
                    tooltip-format = "Games running: {count}";
                };
                tray = {
                    spacing = 10;
                };
                wireplumber = {
                    format = "{icon}";
                    format-muted = " ";
                    format-icons = [ " " " " " " ];
                    scroll-step = 5.0;
                    on-click = "${getExe pkgs.pwvucontrol}";
                    on-click-right = "${getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SINK@ toggle";
                };
                battery = {
                    format = "{capacity}% {icon}";
                    format-icons = [ " " " " " " " " " " ];
                };
                bluetooth = rec {
                    format = "󰂯";
                    format-disabled = "󰂲";
                    format-off = format-disabled;
                    format-connected = "󰂱";
                    tooltip-format-connected = "{device_alias}";
                    tooltip-format-connected-battery = "{device_alias} - 󰁹 {device_battery_percentage}%";
                    tooltip-format-enumerate-connected = "{device_alias}";
                    tooltip-format-enumerate-connected-battery = "{device_alias} - 󰁹 {device_battery_percentage}%";
                    on-click = "${getExe' pkgs.blueman "blueman-manager"}";
                };
                network = {
                      format = "{ifname}";
                      format-wifi = " ";
                      tooltip-format-wifi = "{essid} ({signalStrength}%)";
                      format-ethernet = "󰈀";
                      tooltip-format-ethernet = "{ifname}";
                      on-click = "${getExe pkgs.wezterm} start ${getExe' pkgs.networkmanager "nmtui"}";
                      # An empty format will hide the module.
                      format-disconnected = "";
                      max-length = 50;
                };
                # Grabweather
                "custom/weather" = {
                    # TODO: Make hover show detailed weather information
                    exec = "${getExe pkgs.poperigby.grabweather}";
                    format = " {} ";
                    interval = 900;
                    tooltip = false;
                };
                # Sway Notification Center
                "custom/notification" = {
                    tooltip = false;
                    format = " {icon} ";
                    format-icons = {
                        notification = "<span foreground='red'><sup></sup></span>";
                        none = "";
                        dnd-notification = "<span foreground='red'><sup></sup></span>";
                        dnd-none = "";
                        inhibited-notification = "<span foreground='red'><sup></sup></span>";
                        inhibited-none = "";
                        dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
                        dnd-inhibited-none = "";
                    };
                    return-type = "json";
                    exec = "${pkgs.swaynotificationcenter}/bin/swaync-client -swb";
                    on-click = "${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw";
                    on-click-right = "${pkgs.swaynotificationcenter}/bin/swaync-client -d -sw";
                    escape = true;
                };
            };
            style = ./style.css;
            # Enable systemd integration
            systemd.enable = true;
        };

        # Required for bar to display correctly
        home.packages = [ pkgs.noto-fonts ];
    };
}
