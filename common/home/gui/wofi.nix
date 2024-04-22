# Application launcher

{ config, lib, ... }:

let
    cfg = config.common.home.gui.wofi;
in
{
    options.common.home.gui.wofi.enable = lib.mkEnableOption "Enable Wofi";

    config = lib.mkIf cfg.enable {
        programs.wofi = {
            enable = true;
        };
    };
}
