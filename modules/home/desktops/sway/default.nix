{ config, lib, pkgs, ... }:

let
    cfg = config.poperigby.desktops.sway;
    gui = config.poperigby.suites.gui;
in
{
    options.poperigby.desktops.sway.enable = lib.mkEnableOption "Enable Sway window manager";

    imports = [
        ./keybinds.nix
        ./windowRules.nix
        ./styling.nix
    ];

    config = lib.mkIf cfg.enable {
        wayland.windowManager.sway = {
            enable = true;
            # Integrates Sway with systemd, which will allow applications to depend on it
            # by depending on "graphical.target".
            systemd.enable = true;
            package = pkgs.swayfx;
            # Required for SwayFX to work
            checkConfig = false;
            config = {
                input = {
                    "type:keyboard" = {
                        # Rebind Caps Lock to Super key (Mod4)
                        xkb_options = "caps:super";
                    };
                };
                output = {
                    "*" = {
                        adaptive_sync = lib.mkIf gui.adaptiveSync "on";
                        mode = "${gui.resolution}@${builtins.toString gui.refreshRate}Hz";
                        bg = lib.mkIf (gui.wallpaper != null) "${gui.wallpaper} fill";
                    };
                };
                modifier = "Mod4";
                menu = "${pkgs.rofi-wayland}/bin/rofi";
                terminal = "${pkgs.wezterm}/bin/wezterm";
                defaultWorkspace = "workspace number 1";
                # We'll just use systemd to start Waybar
                bars = [];
                # Programs to launch when Sway starts
                startup = [
                    {
                        command = "${pkgs.ckb-next}/bin/ckb-next --background";
                    }
                ];
            };
        };

        # Start sway if we open a login shell on TTY1
        programs.bash.profileExtra = ''
            if [ "$(tty)" = "/dev/tty1" ]; then
                exec sway
            fi
        '';

        xdg.portal = {
            extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
            config.common = {
                # The WLR portal can only handle these two
                "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
                "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
            };
        };
    };
}
