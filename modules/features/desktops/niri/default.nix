{ den, inputs, ... }:
{
    flake-file.inputs = {
        niri.url = "github:sodiboo/niri-flake/very-refactor";
    };

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
            { pkgs, ... }:
            {
                imports = [
                    inputs.niri.homeModules.niri
                ];

                programs.niri = {
                    package = pkgs.niri;
                    settings = {
                        cursor = {
                            theme = "Adwaita";
                            size = 20;
                        };
                        # Rebind Caps Lock to Super key (Mod4)
                        input.keyboard.xkb.options = "caps:super";
                        # https://github.com/sodiboo/niri-flake/issues/1446
                        # recent-windows = {
                        #     highlight = {
                        #         corner-radius = 8.0;
                        #     };
                        # };
                    };
                };

                home.packages = with pkgs; [
                    adwaita-icon-theme
                ];
            };
    };
}
