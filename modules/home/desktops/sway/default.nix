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
                        # I'm using a script to automatically set this for fullscreen apps only
                        adaptive_sync = "off";
                        mode = "${gui.resolution}@${builtins.toString gui.refreshRate}Hz";
                        bg = lib.mkIf (gui.wallpaper != null) "${gui.wallpaper} fill";
                        # https://github.com/swaywm/sway/issues/7714#issuecomment-1694356639
                        max_render_time = lib.mkIf gui.adaptiveSync "1";
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
                    {
                        command = "${pkgs.element-desktop}/bin/element-desktop --hidden";
                    }
                ] ++ lib.optionals gui.adaptiveSync [
                    {
                        command = "${pkgs.poperigby.automatic-vrr-fullscreen}/bin/automatic-vrr-fullscreen";
                        always = true;
                    }
                ];
            };
            extraOptions = lib.mkIf gui.adaptiveSync [
                # It may be possible to remove this on Sway 1.10
                # https://github.com/swaywm/sway/issues/7714#issuecomment-1694356639
                "-Dnoscanout"
            ];
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
