{ config, lib, ... }:

let
    cfg = config.custom.services.udisks2;
in
{
    options.custom.services.udisks2.enable = lib.mkEnableOption "Enable udisks2";

    config = lib.mkIf cfg.enable {
        services.udisks2 = {
            enable = true;
        };
    };
}
