{ config, lib, ... }:

let
  cfg = config.poperigby.hardware.bluetooth;
  gui = config.poperigby.suites.gui.enable;
in
{
    options.poperigby.hardware.bluetooth.enable = lib.mkEnableOption "Enable Bluetooth";

    config = lib.mkIf cfg.enable {
        hardware.bluetooth = {
            enable = true;
        };

        # Enable Blueman if GUI suite is enabled
        services.blueman.enable = lib.mkIf gui true;
    };
}
