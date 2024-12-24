{ config, lib, ... }:

let
  cfg = config.custom.hardware.corsair;
in
{
    options.custom.hardware.corsair.enable = lib.mkEnableOption "Enable Corsair hardware control";

    config = lib.mkIf cfg.enable {
        hardware.ckb-next = {
            enable = true;
        };
    };
}
