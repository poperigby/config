{ config, lib, ... }:

let
    cfg = config.common.home.gui.dunst;
in
{
    options.common.home.gui.dunst.enable = lib.mkEnableOption "Enable Dunst notification manager";

    config = lib.mkIf cfg.enable {
        services.dunst = {
            enable = true;
        };
    };
}
