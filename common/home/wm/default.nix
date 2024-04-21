{ config, lib, ... }:

let
    cfg = config.common.home.river;
in
{
    options.common.home.river.enable = lib.mkEnableOption "Enable River WM";

    config = lib.mkIf cfg.enable {
        imports = [
            ./dunst.nix
            ./flameshot.nix
            ./waybar.nix
            ./wofi.nix
        ];

        wayland.windowManager.river = {
            enable = true;
        };
    };
}
