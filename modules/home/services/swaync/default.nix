{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.services.swaync;
in
{
    options.poperigby.services.swaync.enable = lib.mkEnableOption "Enable Sway Notification Center";

    config = lib.mkIf cfg.enable {
        services.swaync = {
            enable = true;
            settings = {
                control-center-width = 700;
                control-center-height = 250;
                widgets = [
                    "title"
                    "dnd"
                    "volume"
                    "mpris"
                    "backlight"
                    "buttons-grid"
                    "inhibitors"
                    "notifications"
                ];
                widget-config = {
                    title = {
                        text = "Control Center";
                    };
                    volume = {
                        label = " ";
                    };
                    backlight = {
                        label = "󰃞 ";
                    };
                    buttons-grid.actions = [
                        (let
                            sh = "${pkgs.bash}/bin/sh";
                            nmcli = "${pkgs.networkmanager}/bin/nmcli";
                        in {
                            label = " ";
                            type = "toggle";
                            active = true;
                            command = ''
                                ${sh} -c '[[ $SWAYNC_TOGGLE_STATE == true ]] && ${nmcli} radio wifi on || ${nmcli} radio wifi off'
                            '';
                            update-command = ''
                                ${sh} -c '[[ $(${nmcli} radio wifi) == "enabled" ]] && echo true || echo false'
                            '';
                        })
                    ];
                };
            };
        };

        # Required for icons to display correctly
        home.packages = [ pkgs.gnome.adwaita-icon-theme ];
    };
}
