{ config, lib, pkgs, ... }:

let
    inherit (lib)
        getExe
        mkEnableOption
        mkIf
    ;

    cfg = config.custom.desktops.sway;
    gui = config.custom.suites.gui;
in
{
    options.custom.desktops.sway.enable = mkEnableOption "Enable Sway window manager";

    imports = [
        ./keybinds.nix
        ./windowRules.nix
        ./styling.nix
    ];

    config = mkIf cfg.enable {
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
                    "type:touchpad" = {
                        # Enable tap to click
                        tap = "enabled";
                    };
                };
                output = {
                    "*" = {
                        mode = "${gui.resolution}@${toString gui.refreshRate}Hz";
                        scale = toString gui.scale;
                        bg = mkIf (gui.wallpaper != null) "${gui.wallpaper} fill";
                        adaptive_sync = mkIf gui.vrr "on";
                        max_render_time = mkIf gui.vrr "1";
                    };
                };
                modifier = "Mod4";
                menu = getExe pkgs.rofi-wayland;
                terminal = getExe pkgs.wezterm;
                defaultWorkspace = "workspace number 1";
                # We'll just use systemd to start Waybar
                bars = [];
                # Programs to launch when Sway starts
                startup = [
                    {
                        command = "${getExe pkgs.element-desktop} --hidden";
                    }
                    {
                        command = getExe pkgs.autotiling-rs;
                    }
                ];
            };
        };

        # Start Sway if we open a login shell on TTY1
        # Fallback to bash shell if Sway fails to start
        programs.bash.profileExtra = # bash
        ''
            if [ "$(tty)" = "/dev/tty1" ]; then
                exec sway || exec bash
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
