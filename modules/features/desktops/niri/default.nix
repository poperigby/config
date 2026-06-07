{ den, ... }:
{
    den.aspects.desktops.provides.niri = {
        includes = [
            den.aspects.gui
        ];

        nixos =
            { pkgs, ... }:
            {
                programs.niri = {
                    enable = true;
                };

                programs.dms-shell = {
                    enable = true;

                    systemd = {
                        enable = true; # Systemd service for auto-start
                        restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
                    };

                    # Core features
                    enableSystemMonitoring = true; # System monitoring widgets (dgop)
                    enableVPN = true; # VPN management widget
                    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
                    enableAudioWavelength = true; # Audio visualizer (cava)
                    enableCalendarEvents = true; # Calendar integration (khal)
                    enableClipboardPaste = true; # Pasting from the clipboard history (wtype)
                };

                programs.dsearch.enable = true;

                environment.systemPackages = with pkgs; [
                    xwayland-satellite
                    papirus-icon-theme
                ];

                services.displayManager.dms-greeter = {
                    enable = true;
                    compositor.name = "niri";
                };
            };

        homeManager =
            { lib, pkgs, ... }:
            {
                xdg.configFile = {
                    "niri/config.kdl".text = lib.mkBefore (builtins.readFile ./config.kdl);
                    "niri/binds.kdl".source = ./binds.kdl;
                    "niri/rules.kdl".source = ./rules.kdl;
                };

                xdg.mimeApps.defaultApplications = {
                    "image/jpeg" = "oculante.desktop";
                    "image/png" = "oculante.desktop";
                    "image/webp" = "oculante.desktop";
                };

                home.packages = with pkgs; [
                    adwaita-icon-theme
                    oculante
                    custom.wkill
                ];

                # Fix Steam not using correct cursor theme
                home.file.".icons/default".source = "${pkgs.adwaita-icon-theme}/share/icons/Adwaita";
            };
    };
}
