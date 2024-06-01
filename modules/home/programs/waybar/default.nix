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
                height = 30;
                modules-left = [
                    "sway/workspaces"
                    "sway/mode"
                ];
                modules-right = [
                    "privacy"
                    "wireplumber"
                    "memory"
                    "temperature"
                    "battery"
                    "bluetooth"
                    "network"
                    "custom/weather"
                    "tray"
                    "clock"
                    "custom/notification"
                ];
                ## Modules
                wireplumber = {
                    format = "{volume}% {icon}";
                    format-muted = "󰝟 ";
                    on-click = "${pkgs.pwvucontrol}/bin/pwvucontrol";
                    format-icons = [ " " " " " " ];
                };
                bluetooth = rec {
                    format = " 󰂯 ";
                    format-disabled = " 󰂲 ";
                    format-off = format-disabled;
                    format-connected = " 󰂱 ";
                    on-click = "${pkgs.blueman}/bin/blueman-manager";
                };
                network = {
                      format = "{ifname}";
                      format-wifi = "{essid} ({signalStrength}%) ";
                      format-ethernet = "󰈀";
                      format-disconnected = ""; # An empty format will hide the module.
                      tooltip-format-wifi = "{essid} ({signalStrength}%) ";
                      tooltip-format-ethernet = "{ifname}  󰈀";
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
    };
}
