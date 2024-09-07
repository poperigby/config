{ config, lib, ... }:

let
    cfg = config.poperigby.services.earlyoom;
    gui = config.poperigby.suites.gui.enable;
in
{
    options.poperigby.services.earlyoom.enable = lib.mkEnableOption "Early OOM";

    config = lib.mkIf cfg.enable {
        services.earlyoom = {
            enable = true;
            # <%5 free
            freeMemThreshold = 5;
            # Enable desktop notifications if GUI suite is enabled
            enableNotifications = gui;
        };
    };
}
