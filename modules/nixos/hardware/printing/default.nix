{ config, lib, ... }:

let
  cfg = config.poperigby.hardware.printing;
in
{
    options.poperigby.hardware.printing.enable = lib.mkEnableOption "Enable printing";

    config = lib.mkIf cfg.enable {
        services.printing = {
            enable = true;
        };
    };
}
