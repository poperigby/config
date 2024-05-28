{ config, lib, ... }:

let
    cfg = config.poperigby.suites.gui;
in
{
    options.poperigby.suites.gui = {
        enable = lib.mkEnableOption "Enable GUI";
    };

    config = lib.mkIf cfg.enable {
        services = {
            udisks2.enable = true;
        };
    };
}
