{ config, lib, ... }:

let
    cfg = config.poperigby.services.dunst;
in
{
    options.poperigby.services.dunst.enable = lib.mkEnableOption "Enable Dunst notification manager";

    config = lib.mkIf cfg.enable {
        services.dunst = {
            enable = true;
        };
    };
}
