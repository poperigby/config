{ config, lib, ... }:

let
  cfg = config.custom.hardware.bluetooth;
  gui = config.custom.suites.gui.enable;
in
{
    options.custom.hardware.bluetooth.enable = lib.mkEnableOption "Enable Bluetooth";

    config = lib.mkIf cfg.enable {
        hardware.bluetooth = {
            enable = true;
        };

        # Enable Blueman if GUI suite is enabled
        services.blueman.enable = lib.mkIf gui true;
    };
}
