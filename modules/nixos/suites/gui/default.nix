{ config, lib, ... }:

let
    cfg = config.poperigby.suites.gui;
in
{
    options.poperigby.suites.gui = {
        enable = lib.mkEnableOption "Enable GUI";
    };

    config = lib.mkIf cfg.enable {
        poperigby = {
            services = {
                udisks2.enable = true;
            };
        };

        # Required for Sway to launch
        security.polkit.enable = true;

        # Required for Swaylock to work
        security.pam.services.swaylock = {};

        # Required for tweaking GTK settings
        programs.dconf.enable = true;
    };
}
