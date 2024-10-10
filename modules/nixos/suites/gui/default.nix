{ config, lib, ... }:

let
    cfg = config.poperigby.suites.gui;
in
{
    options.poperigby.suites.gui = {
        enable = lib.mkEnableOption "GUI";
    };

    config = lib.mkIf cfg.enable {
        poperigby = {
            services = {
                udisks2.enable = true;
            };
        };

        security = {
            # Required for Sway to launch
            polkit.enable = true;
            # Required for Swaylock to work
            pam.services.swaylock = {};
        };

        # Show desktop notifications for system bus
        services.systembus-notify.enable = true;

        # Required for tweaking GTK settings
        programs.dconf.enable = true;

        # Required for Sway to run
        hardware.graphics.enable = true;
    };
}
