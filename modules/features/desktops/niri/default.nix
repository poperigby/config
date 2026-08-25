{
    den,
    ...
}:
{
    den.aspects.compositors.provides.niri = {
        includes = [
            den.aspects.gui
            den.aspects.compositors._.niri.binds
            den.aspects.compositors._.niri.rules
        ];

        nixos =
            { pkgs, ... }:
            {
                programs.dconf.enable = true;

                programs.niri = {
                    enable = true;
                };

                environment.systemPackages = with pkgs; [
                    adw-gtk3
                    papirus-icon-theme
                    xwayland-satellite
                ];
            };

        homeManager =
            {
                pkgs,
                ...
            }:
            {
                wayland.windowManager.niri = {
                    enable = true;
                    settings = {

                        cursor = {
                            xcursor-theme = "Adwaita";
                            xcursor-size = 20;
                        };

                        input = {
                            keyboard = {
                                numlock = { };
                                xkb.options = "caps:super";
                            };
                            focus-follows-mouse._props.max-scroll-amount = "95%";
                        };

                        recent-windows.highlight.corner-radius = 8;

                        layout = {
                            background-color = "transparent";
                            focus-ring.active-color = "#7daea3";
                            tab-indicator = {
                                width = 8;
                                active-color = "#e78a4e";
                            };
                            preset-column-widths._children = [
                                { proportion = 0.33333; }
                                { proportion = 0.5; }
                                { proportion = 0.66666; }
                            ];
                        };

                        gestures.hot-corners.off = { };
                        hotkey-overlay.skip-at-startup = { };
                        prefer-no-csd = { };

                        animations = {
                            workspace-switch.spring._props = {
                                damping-ratio = 0.825;
                                stiffness = 700;
                                epsilon = 0.0001;
                            };
                            window-open.spring._props = {
                                damping-ratio = 0.825;
                                stiffness = 850;
                                epsilon = 0.0001;
                            };
                            window-close = {
                                duration-ms = 150;
                                curve = "ease-out-quad";
                            };
                            horizontal-view-movement.spring._props = {
                                damping-ratio = 0.825;
                                stiffness = 700;
                                epsilon = 0.0001;
                            };
                            window-movement.spring._props = {
                                damping-ratio = 0.825;
                                stiffness = 700;
                                epsilon = 0.0001;
                            };
                            window-resize.spring._props = {
                                damping-ratio = 0.825;
                                stiffness = 700;
                                epsilon = 0.0001;
                            };
                            config-notification-open-close.spring._props = {
                                damping-ratio = 0.825;
                                stiffness = 900;
                                epsilon = 0.001;
                            };
                            screenshot-ui-open = {
                                duration-ms = 200;
                                curve = "ease-out-quad";
                            };
                            overview-open-close.spring._props = {
                                damping-ratio = 0.825;
                                stiffness = 560;
                                epsilon = 0.0003;
                            };
                        };
                    };
                };

                home.sessionVariables = {
                    XCURSOR_THEME = "Adwaita";
                    XCURSOR_SIZE = 20;
                };

                gtk = {
                    enable = true;
                    colorScheme = "dark";
                    theme = {
                        name = "adw-gtk3-dark";
                        package = pkgs.adw-gtk3;
                    };
                    gtk4.theme = {
                        name = "adw-gtk3-dark";
                        package = pkgs.adw-gtk3;
                    };
                    iconTheme = {
                        name = "Papirus-Dark";
                        package = pkgs.papirus-icon-theme;
                    };
                    font = {
                        name = "Noto Sans";
                        size = 11;
                    };
                };

                qt = {
                    enable = true;
                    style = {
                        name = "kvantum";
                        package = pkgs.kdePackages.qtstyleplugin-kvantum;
                    };
                    kvantum = {
                        enable = true;
                        themes = [ pkgs.local.kvlibadwaita ];
                        settings.General.theme = "KvLibadwaitaDark";
                    };
                };

                dconf.settings."org/gnome/desktop/interface".accent-color = "yellow";

                xdg.mimeApps.defaultApplications = {
                    "image/jpeg" = "oculante.desktop";
                    "image/png" = "oculante.desktop";
                    "image/webp" = "oculante.desktop";
                };

                home.packages = with pkgs; [
                    adwaita-icon-theme
                    local.wkill
                    nautilus
                    numbat
                    oculante
                    wl-freeze
                ];

                # Fix Steam not using correct cursor theme
                home.file.".icons/default".source = "${pkgs.adwaita-icon-theme}/share/icons/Adwaita";
            };
    };
}
