{ config, lib, ... }:

let
    cfg = config.modules.home.river;
in
{
    options.modules.home.river.enable = lib.mkEnableOption "Enable River WM";

    config = lib.mkIf cfg.enable {
        wayland.windowManager.river = {
            enable = true;
        };
    };
}
