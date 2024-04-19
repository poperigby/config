{ config, lib, ... }:

let
    cfg = config.common.home.river;
in
{
    options.common.home.river.enable = lib.mkEnableOption "Enable River WM";

    config = lib.mkIf cfg.enable {
        wayland.windowManager.river = {
            enable = true;
        };
    };
}
