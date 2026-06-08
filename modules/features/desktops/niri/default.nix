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

                    plugins = {
                        calculator.src = pkgs.applyPatches {
                            src = pkgs.fetchFromGitHub {
                                owner = "rochacbruno";
                                repo = "DankCalculator";
                                rev = "main";
                                hash = "sha256-hiqrO8WkzmWGVlUrzxmffUZBs4t1QM2mMTBUxZqCIyU=";
                            };
                            patches = [ ./dank-calculator-numbat-debounce.patch ];
                        };
                        emoji-unicode-picker.src = pkgs.fetchFromGitHub {
                            owner = "devnullvoid";
                            repo = "dms-emoji-launcher";
                            rev = "main";
                            hash = "sha256-NQ14YenDiNK2VqXQ3z7jAkatbSRtYJHhOhvv7AJlUD8=";
                        };
                    };

                    enableSystemMonitoring = true;
                    enableVPN = true;
                    enableDynamicTheming = true;
                    enableAudioWavelength = true;
                    enableCalendarEvents = true;
                    enableClipboardPaste = true;
                };

                programs.dsearch.enable = true;

                environment.systemPackages = with pkgs; [
                    xwayland-satellite
                    papirus-icon-theme
                    adw-gtk3
                ];

                services.displayManager.dms-greeter = {
                    enable = true;
                    compositor.name = "niri";
                };
            };

        homeManager =
            {
                lib,
                pkgs,
                ...
            }:
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
                    custom.wkill
                    numbat
                    oculante
                    wl-freeze
                ];

                # Fix Steam not using correct cursor theme
                home.file.".icons/default".source = "${pkgs.adwaita-icon-theme}/share/icons/Adwaita";
            };
    };
}
