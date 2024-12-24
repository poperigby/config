{ config, lib, ... }:

let
    cfg = config.custom.services.udiskie;
in
{
    options.custom.services.udiskie.enable = lib.mkEnableOption "Enable Udiskie";

    config = lib.mkIf cfg.enable {
        services.udiskie = {
            enable = true;
            tray = "never";
        };
    };
}
