{ config, lib, ... }:

let
    inherit (lib)
        mkEnableOption
        mkIf
    ;

    cfg = config.custom.suites.gui;
in
{
    options.custom.suites.gui = {
        enable = mkEnableOption "GUI";
    };

    config = mkIf cfg.enable {
        custom = {
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
