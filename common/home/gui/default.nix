{ config, lib, ... }:

let
    cfg = config.common.home.gui;
in
{
    options.common.home.gui.enable = lib.mkEnableOption "Enable GUI";

    config = lib.mkIf cfg.enable {
        imports = [
            ./dunst.nix
            ./flameshot.nix
            ./gammastep.nix
            ./waybar.nix
            ./wofi.nix
        ];

        wayland.windowManager.river = {
            enable = true;
        };
    };
}
