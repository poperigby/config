{ config, lib, ... }:

let
    cfg = config.poperigby.programs.bat;
in
{
    options.poperigby.desktop.sway.enable = lib.mkEnableOption "Enable Sway window manager";

    config = lib.mkIf cfg.enable {
        wayland.windowManager.sway = {
            enable = true;
            config = {
                # We'll just use systemd to start Waybar
                bars = [];
                keybindings = {};
                defaultWorkspace = "workspace number 1";
            };
            systemd.enable = true;
        };
    };
}
