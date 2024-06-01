{ config, lib, ... }:

let
  cfg = config.poperigby.hardware.corsair;
in
{
    options.poperigby.hardware.corsair.enable = lib.mkEnableOption "Enable Corsair hardware control";

    config = lib.mkIf cfg.enable {
        hardware.ckb-next = {
            enable = true;
        };
    };
}
