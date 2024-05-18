{ config, lib, ... }:

let
  cfg = config.poperigby.hardware.bluetooth;
in
{
    options.poperigby.hardware.bluetooth.enable = lib.mkEnableOption "Enable Bluetooth";

    config = lib.mkIf cfg.enable {
        hardware.bluetooth = {
            enable = true;
        };
    };
}
