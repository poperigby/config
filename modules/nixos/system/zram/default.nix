{ config, lib, ... }:

let
  cfg = config.poperigby.system.zram;
in
{
    options.poperigby.system.zram.enable = lib.mkEnableOption "Enable zRAM swap";

    config = lib.mkIf cfg.enable {
        zramSwap.enable = true;
    };

}
