{ config, lib, ... }:

let
    cfg = config.poperigby.services.udiskie;
in
{
    options.poperigby.services.udiskie.enable = lib.mkEnableOption "Enable Udiskie";

    config = lib.mkIf cfg.enable {
        services.udiskie = {
            enable = true;
            tray = "never";
        };
    };
}
