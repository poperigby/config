{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.programs.waybar;
in
{
    options.poperigby.programs.waybar.enable = lib.mkEnableOption "Enable Waybar";

    config = lib.mkIf cfg.enable {
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
                modules-right = [
                    # Variable width, status modules
                    "gamemode"
                    "privacy"
                    "tray"
                    # Fixed width modules
                    "wireplumber"
                    "battery"
                    "bluetooth"
                    "network"
                    "custom/weather"
                    "clock"
                    "custom/notification"
                ];
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
                wireplumber = {
                    format = "{volume}% {icon}";
                    format-muted = "󰝟 ";
                    format-icons = [ " " " " " " ];
                    scroll-step = 5.0;
                    on-click = "${pkgs.pwvucontrol}/bin/pwvucontrol";
                    on-click-right = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
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
                    on-click = "${pkgs.blueman}/bin/blueman-manager";
                };
                network = {
                      format = "{ifname}";
                      format-wifi = "{essid} ({signalStrength}%) ";
                      tooltip-format-wifi = "{essid} ({signalStrength}%) ";
                      format-ethernet = "󰈀";
                      tooltip-format-ethernet = "{ifname}  󰈀";
                      # An empty format will hide the module.
                      format-disconnected = "";
                      max-length = 50;
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
                tray = {
                    spacing = 10;
                };
                # Grabweather
                "custom/weather" = {
                    # TODO: Make hover show detailed weather information
                    exec = "${pkgs.poperigby.grabweather}/bin/grabweather";
                    format = " {} ";
                    interval = 900;
                    tooltip = false;
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
