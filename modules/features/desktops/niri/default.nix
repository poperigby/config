{
    den,
    ...
}:
{
    den.aspects.desktops.provides.niri =
        {
            hostConfig ? null,
        }:
        {
            includes = [
                den.aspects.gui
            ];

            nixos =
                { pkgs, ... }:
                {
                    programs.niri = {
                        enable = true;
                    };

                    environment.systemPackages = with pkgs; [
                        xwayland-satellite
                        papirus-icon-theme
                        adw-gtk3
                    ];
                };

            homeManager =
                {
                    lib,
                    pkgs,
                    ...
                }:
                {
                    xdg.configFile = {
                        "niri/config.kdl".text = lib.mkMerge (
                            [
                                (lib.mkBefore (builtins.readFile ./config.kdl))
                            ]
                            ++ lib.optionals (hostConfig != null) [
                                (lib.mkAfter ''

                                    include "host.kdl"
                                '')
                            ]
                        );
                        "niri/binds.kdl".text = ''
                            binds {
                            ${builtins.readFile ./binds.kdl}
                            }
                        '';
                        "niri/rules.kdl".source = ./rules.kdl;
                    }
                    // lib.optionalAttrs (hostConfig != null) {
                        "niri/host.kdl".source = hostConfig;
                    };

                    xdg.mimeApps.defaultApplications = {
                        "image/jpeg" = "oculante.desktop";
                        "image/png" = "oculante.desktop";
                        "image/webp" = "oculante.desktop";
                    };

                    home.packages = with pkgs; [
                        adwaita-icon-theme
                        custom.wkill
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
