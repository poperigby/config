{ config, lib, ... }:

let
  cfg = config.poperigby.system.swap;
in
{
    options.poperigby.system.swap.enable = lib.mkEnableOption "swap file";

    config = lib.mkIf cfg.enable {
        swapDevices = [
            {
                device = "/var/lib/swapfile";
                # Size is in megabytes
                size = 8000;
            }
        ];
    };
}
